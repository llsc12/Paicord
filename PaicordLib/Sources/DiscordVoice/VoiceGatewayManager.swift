//
//  VoiceGatewayManager.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 19/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import AsyncAlgorithms
import AsyncHTTPClient
import Atomics
import Crypto
import DaveKit
import DiscordGateway
import DiscordModels
import Foundation
import Logging
import NIO
import WSClient

import enum NIOWebSocket.WebSocketErrorCode
import struct NIOWebSocket.WebSocketOpcode

/// https://docs.discord.food/topics/voice-connections#voice-data-interpolation

/// This actor manages a voice gateway connection, handling the WebSocket communication and
/// UDP audio transmission, as well as the necessary encryption and decryption of audio data.
public actor VoiceGatewayManager {
  private struct Message {
    let payload: VoiceGateway.Event
    let opcode: WebSocketOpcode?
    let connectionId: UInt?
    var tryCount: Int

    init(
      payload: VoiceGateway.Event,
      opcode: WebSocketOpcode? = nil,
      connectionId: UInt? = nil,
      tryCount: Int = 0
    ) {
      self.payload = payload
      self.opcode = opcode
      self.connectionId = connectionId
      self.tryCount = tryCount
    }
  }

  /// Structure used to initialise voice connections
  public struct ConnectionData {
    public var token: Secret  // voice token
    public var guildID: GuildSnowflake
    public var channelID: ChannelSnowflake
    public var userID: UserSnowflake
    public var sessionID: String
    public var endpoint: String?

    public init(
      token: Secret,
      guildID: GuildSnowflake,
      channelID: ChannelSnowflake,
      userID: UserSnowflake,
      sessionID: String,
      endpoint: String
    ) {
      self.token = token
      self.guildID = guildID
      self.channelID = channelID
      self.userID = userID
      self.sessionID = sessionID
      self.endpoint = endpoint
    }
  }

  var outboundWriter: WebSocketOutboundWriter?
  let eventLoopGroup: any EventLoopGroup

  /// Max frame size we accept to receive through the web-socket connection.
  let maxFrameSize: Int
  /// Generator of `UserGatewayManager` ids.
  static let idGenerator = ManagedAtomic(UInt(0))
  /// This gateway manager's identifier.
  public nonisolated let id = idGenerator.wrappingIncrementThenLoad(
    ordering: .relaxed
  )
  let logger: Logger

  private var lastSentPingNonce: Int = 0

  private var connectionData: ConnectionData

  //MARK: Event streams
  var eventsStreamContinuations = [
    AsyncStream<VoiceGateway.Event>.Continuation
  ]()
  var eventsParseFailureContinuations = [
    AsyncStream<(any Error, ByteBuffer)>.Continuation
  ]()

  /// An async sequence of Gateway events.
  public var events: DiscordAsyncSequence<VoiceGateway.Event> {
    DiscordAsyncSequence<VoiceGateway.Event>(
      base: AsyncStream<VoiceGateway.Event> { continuation in
        self.eventsStreamContinuations.append(continuation)
      }
    )
  }
  /// An async sequence of Gateway event parse failures.
  public var eventFailures: DiscordAsyncSequence<(any Error, ByteBuffer)> {
    DiscordAsyncSequence<(any Error, ByteBuffer)>(
      base: AsyncStream<(any Error, ByteBuffer)> { continuation in
        self.eventsParseFailureContinuations.append(continuation)
      }
    )
  }

  //MARK: Connection data
  public nonisolated let identifyPayload: VoiceGateway.Identify
  // discord uses this for analytics but we'll send it anyways
  public nonisolated let rtcConnectionID = UUID().uuidString.lowercased()

  //MARK: Connection state
  public nonisolated let state = ManagedAtomic(GatewayState.noConnection)
  public nonisolated let stateCallback: (@Sendable (GatewayState) -> Void)?

  //MARK: UDP Connection
  /// Created upon ready event receive
  private var udpConnection: VoiceConnection? = nil
  private var udpConnectionTask: Task<Void, any Error>?
  /// Once the session description event is received, we can listen.
  private var udpListeningTask: Task<Void, any Error>?
  private var udpSpeakingTask: Task<Void, Never>?

  private var pendingOpusFrames: [Data] = []
  private var channelDrainTask: Task<Void, Never>?

  /// This contains the speaking payload to send next when there is data to send over UDP.
  public var nextSpeakingPayload: VoiceGateway.Speaking? = nil

  private lazy var dave: DaveSessionManager = {
    return DaveSessionManager(
      selfUserId: connectionData.userID.rawValue,
      groupId: .init(connectionData.channelID.rawValue) ?? 0,
      delegate: self,
    )
  }()

  var audioSSRC: UInt {
    return self.knownSSRCs.first(where: {
      $0.value == self.connectionData.userID
    })?.key ?? 0
  }

  private let outgoingOpusChannel = AsyncChannel<Data>()
  private let incomingOpusChannel = AsyncChannel<Data>()

  public var incomingOpusPackets: AsyncChannel<Data> {
    incomingOpusChannel
  }

  //MARK: Send queue

  /// 120 per 60 seconds (1 every 500ms),
  /// per https://discord.com/developers/docs/topics/gateway#rate-limiting
  let sendQueue = SerialQueue(waitTime: .milliseconds(500))

  //MARK: Current connection properties

  /// An ID to keep track of connection changes.
  nonisolated let connectionId = ManagedAtomic(UInt(0))

  //MARK: Resume-related current-connection properties

  /// The sequence number for the payloads sent to us.
  var sequenceNumber: Int? = nil
  /// Gateway URL for connecting and resuming connections.
  var resumeGatewayURL: String? {
    return connectionData.endpoint.map { "wss://\($0)" }
  }

  //MARK: Backoff

  /// Discord cares about the identify payload for rate-limiting and if you send
  /// more than 1000 identifies in a day, Discord will revoke your bot token
  /// (unless your bot is big enough that has a bigger identify-limit than 1000 per day).
  /// This does not apply for users, but could be deemed suspicious behaviour.
  ///
  /// This Backoff does not necessarily prevent your bot token getting revoked,
  /// but in the worst case, doesn't let it happen sooner than ~6 hours.
  /// This also helps in other situations, for example when there is a Discord outage.
  let connectionBackoff = Backoff(
    base: 2,
    maxExponentiation: 7,
    coefficient: 1,
    minBackoff: 15
  )

  //MARK: Ping-pong tracking properties
  var unsuccessfulPingsCount = 0
  var lastPongDate = Date()

  public init(
    eventLoopGroup: any EventLoopGroup = HTTPClient.shared.eventLoopGroup,
    maxFrameSize: Int = 1 << 28,
    connectionData: ConnectionData,
    stateCallback: (@Sendable (GatewayState) -> Void)? = nil
  ) {
    self.eventLoopGroup = eventLoopGroup
    self.stateCallback = stateCallback
    self.maxFrameSize = maxFrameSize
    self.connectionData = connectionData
    self.identifyPayload = .init(
      server_id: connectionData.guildID,
      channel_id: connectionData.channelID,
      user_id: connectionData.userID,
      session_id: connectionData.sessionID,
      token: connectionData.token,
      video: true,
      streams: [
        .init(
          type: .video,
          rid: "100",
          quality: 100
        ),
        .init(
          type: .video,
          rid: "50",
          quality: 50
        ),
      ]
    )

    var logger = DiscordGlobalConfiguration.makeLogger("VoiceGatewayManager")
    logger[metadataKey: "gateway-id"] = .string("\(self.id)")
    self.logger = logger
  }

  /// Connects to Discord.
  /// `state` must be set to an appropriate value before triggering this function.
  public func connect() async {
    logger.debug("Connect method triggered")
    /// Guard we're attempting to connect too fast
    if let connectIn = connectionBackoff.canPerformIn() {
      logger.warning(
        "Cannot try to connect immediately due to backoff",
        metadata: [
          "wait-time": .stringConvertible(connectIn)
        ]
      )
      try? await Task.sleep(for: connectIn)
    }
    /// Guard if other connections are in process
    let state = self.state.load(ordering: .relaxed)
    guard [.noConnection, .configured, .stopped].contains(state) else {
      logger.error(
        "Gateway state doesn't allow a new connection",
        metadata: [
          "state": .stringConvertible(state)
        ]
      )
      return
    }
    self.state.store(.connecting, ordering: .relaxed)
    self.stateCallback?(.connecting)

    await self.sendQueue.reset()
    let gatewayURL = self.resumeGatewayURL ?? ""
    let queries: [(String, String)] = [
      ("v", "\(DiscordGlobalConfiguration.apiVersion)")
    ]
    let configuration = WebSocketClientConfiguration(
      maxFrameSize: self.maxFrameSize,
      additionalHeaders: [
        .userAgent: SuperProperties.useragent(ws: false)!,
        .origin: "https://discord.com",
        .cacheControl: "no-cache",
        .acceptLanguage: SuperProperties.GenerateLocaleHeader(),

      ],
      extensions: []
    )

    logger.trace("Will try to connect to Discord through web-socket")
    let connectionId = self.connectionId.wrappingIncrementThenLoad(
      ordering: .relaxed
    )
    /// FIXME: remove this `Task` in a future major version.
    /// This is so the `connect()` method does still exit, like it used to.
    /// But for proper structured concurrency, this method should never exit (optimally).
    Task {
      do {
        let url = gatewayURL + "/" + queries.makeForURLQuery()
        let closeFrame = try await WebSocketClient.connect(
          url: url,
          configuration: configuration,
          eventLoopGroup: self.eventLoopGroup,
          logger: self.logger
        ) { inbound, outbound, context in
          await self.setupOutboundWriter(outbound)

          self.logger.debug(
            "Connected to Discord through web-socket. Will configure"
          )
          await self.sendResumeOrIdentify()
          self.state.store(.configured, ordering: .relaxed)
          self.stateCallback?(.configured)

          for try await message in inbound.messages(maxSize: self.maxFrameSize)
          {
            await self.processBinaryData(
              message,
              forConnectionWithId: connectionId
            )
          }
        }

        logger.debug(
          "web-socket connection closed",
          metadata: [
            "closeCode": .string(String(reflecting: closeFrame?.closeCode)),
            "closeReason": .string(String(reflecting: closeFrame?.reason)),
            "connectionId": .stringConvertible(
              self.connectionId.load(ordering: .relaxed)
            ),
          ]
        )
        await self.onClose(
          closeReason: .closeFrame(closeFrame),
          forConnectionWithId: connectionId
        )
      } catch {
        logger.debug(
          "web-socket error while connecting to Discord. Will try again",
          metadata: [
            "error": .string(String(reflecting: error)),
            "connectionId": .stringConvertible(
              self.connectionId.load(ordering: .relaxed)
            ),
          ]
        )
        self.state.store(.noConnection, ordering: .relaxed)
        self.stateCallback?(.noConnection)
        await self.onClose(
          closeReason: .error(error),
          forConnectionWithId: connectionId
        )
      }
    }
  }

  // MARK: - Internal event handling and connection management
  // required to manage connection. library users can watch events to get this instead.
  private var knownSSRCs: [UInt: UserSnowflake] = [:]

  private func processEvent(_ event: VoiceGateway.Event) async {
    if let sequenceNumber = event.sequenceNumber {
      self.sequenceNumber = sequenceNumber
    }

    switch event.data {
    case .heartbeatAck:
      self.lastPongDate = Date()
      self.unsuccessfulPingsCount = 0
      logger.trace(
        "Received heartbeat ack/pong",
        metadata: [
          "opcode": .string(event.opcode.description)
        ]
      )
    case .hello(let payload):
      self.setupPingTask(
        forConnectionWithId: self.connectionId.load(ordering: .relaxed),
        every: .milliseconds(payload.heartbeat_interval / 2)
      )
    case .ready(let payload):
      self.state.store(.connected, ordering: .relaxed)
      self.stateCallback?(.connected)

      self.knownSSRCs[UInt(payload.ssrc)] = self.connectionData.userID
      setupUDP(payload)
    case .sessionDescription(let payload):
      await self.dave.selectProtocol(
        protocolVersion: payload.daveProtocolVersion
      )

      self.nextSpeakingPayload = .init(
        speaking: [.voice],
        ssrc: audioSSRC,
        delay: 0
      )

      guard
        let mode = payload.mode
      else { return }

      let key = SymmetricKey(data: payload.secretKey)

      // find ssrc for current user id in connectionData.userID
      guard
        let ssrc = self.knownSSRCs.first(where: {
          $0.value == self.connectionData.userID
        })?.key
      else {
        self.logger.error(
          "Failed to find SSRC for current user ID when trying to start speaking",
        )
        return
      }

      self.listen(description: payload)
      self.speak(
        ssrc: .init(ssrc),
        mode: mode,
        key: key
      )

      self.send(
        message: .init(
          payload: .init(
            opcode: .voiceBackendVersion,
            data: .voiceBackendVersion(.init()),
          ),
          opcode: .text
        )
      )

      guard
        let discovery = try? await self.udpConnection?.discoverExternalIP(
          ssrc: .init(self.audioSSRC)
        )
      else {
        // udp discovery failed, disconnect and set state to stopped
        logger.error(
          "Failed to discover external IP and port during session description handling"
        )
        await self.disconnect()
        return
      }

      self.send(
        message: .init(
          payload: .init(
            opcode: .selectProtocol,
            data: .selectProtocol(
              .init(
                protocol: "udp",
                data: .init(
                  address: discovery.ip,
                  port: .init(discovery.port),
                  mode: payload.mode ?? .aead_aes256_gcm_rtpsize
                ),
                rtc_connection_id: self.rtcConnectionID,
                codecs: [
                  .opusCodec,
                  .h264Codec,
                  .h265Codec,
                ],
                experiments: [
                  "fixed_keyframe_interval",
                  "keyframe_on_join",
                ]
              )
            )
          ),
          opcode: .text
        )
      )
    case .speaking(let payload):
      self.knownSSRCs[payload.ssrc] = payload.user_id
    case .clientConnect(let payload):
      for id in payload.user_ids {
        await self.dave.addUser(userId: id.rawValue)
      }
    case .clientDisconnect(let payload):
      await self.dave.removeUser(userId: payload.user_id.rawValue)
    case .davePrepareTransition(let payload):
      await self.dave.prepareTransition(
        transitionId: payload.transitionId,
        protocolVersion: payload.protocolVersion
      )
    case .daveExecuteTransition(let payload):
      await self.dave.executeTransition(transitionId: payload.transitionId)
    case .davePrepareEpoch(let payload):
      await self.dave.prepareEpoch(
        epoch: String(payload.epoch),
        protocolVersion: payload.protocolVersion
      )
    case .mlsExternalSender(let data):
      await self.dave.mlsExternalSenderPackage(externalSenderPackage: data)
    case .mlsProposals(let data):
      await self.dave.mlsProposals(proposals: data)
    case .mlsAnnounceCommitTransition(let transitionId, let commit):
      await self.dave.mlsPrepareCommitTransition(
        transitionId: transitionId,
        commit: commit
      )
    case .mlsWelcome(let transitionId, let welcome):
      await self.dave.mlsWelcome(transitionId: transitionId, welcome: welcome)
    default:
      break
    }
  }

  func setupUDP(_ payload: VoiceGateway.Ready) {
    self.udpConnectionTask = Task {
      try await VoiceConnection.connect(
        host: payload.ip,
        port: Int(payload.port)
      ) { connection in
        guard
          let (ip, port) = try await connection.discoverExternalIP(
            ssrc: payload.ssrc,
          )
        else {
          self.logger.error("Failed to discover external IP and port")
          return
        }

        guard
          let mode = VoiceGateway.EncryptionMode.supportedCases.first(where: {
            mode in
            payload.modes.contains(mode)
          })
        else {
          self.logger.error("No supported crypto modes found")
          return
        }

        self.send(
          message: .init(
            payload: .init(
              opcode: .selectProtocol,
              data: .selectProtocol(
                .init(
                  protocol: "udp",
                  data: .init(
                    address: ip,
                    port: .init(port),
                    mode: mode
                  ),
                  rtc_connection_id: self.rtcConnectionID,
                  codecs: [
                    .opusCodec,
                    .h264Codec,
                    .h265Codec,
                  ],
                  experiments: nil
                )
              )
            ),
            opcode: .text
          )
        )

        await self.storeConnection(connection)

        // When this function returns, the UDP connection will be closed, so we
        // need to keep it alive. Other things will be handled in other tasks.
        // Luckily, we also need to send keepalive packets to the voice server.
        // We can accomplish both requirements by awaiting the keepalive task
        // here.
        try await connection.keepalive(ssrc: payload.ssrc)
      }
    }
  }
  private func storeConnection(_ connection: VoiceConnection) {
    self.udpConnection = connection
  }

  /// Start listening for incoming audio packets on the UDP connection.
  private func listen(
    description: VoiceGateway.SessionDescription,
  ) {
    guard let encryption = description.mode,
      VoiceGateway.EncryptionMode.supportedCases.contains(encryption)
    else {
      logger.error(
        "Unsupported crypto mode: \(description.mode?.rawValue ?? "nil")"
      )
      return
    }

    let key = SymmetricKey(data: description.secretKey)

    self.udpListeningTask = Task {
      guard let udpConnection = self.udpConnection else {
        return
      }

      defer {
        // When the UDP listening ends, cancel the UDP connection task
        self.udpConnectionTask?.cancel()
      }

      for try await envelope in udpConnection.inbound {
        guard let packet = RTPPacket(rawValue: envelope.data) else {
          continue
        }

        await self.processIncomingVoicePacket(
          packet,
          mode: encryption,
          key: key
        )
      }
    }
  }

  /// Writes Opus data out through UDP.
  private func speak(
    ssrc: UInt32,
    mode: VoiceGateway.EncryptionMode,
    key: SymmetricKey
  ) {
    startDrainingOutgoingChannel()

    udpSpeakingTask = Task {
      var sequence: UInt16 = 0
      var timestamp: UInt32 = 0

      let clock = ContinuousClock()
      let interval: Duration = .milliseconds(20)

      while !Task.isCancelled {
        let start = clock.now

        let frame: Data?
        if pendingOpusFrames.isEmpty {
          frame = nil
        } else {
          frame = pendingOpusFrames.removeFirst()
        }

        if frame != nil, let payload = self.nextSpeakingPayload {
          // we're going to start talking, send any pending speaking payloads first.
          self.send(
            message: .init(
              payload: .init(opcode: .speaking, data: .speaking(payload)),
              opcode: .text
            )
          )
          self.nextSpeakingPayload = nil
        }

        if let frame {
          await sendPacket(
            frame: frame,
            sequence: sequence,
            timestamp: timestamp,
            ssrc: ssrc,
            mode: mode,
            key: key
          )
        } else {
          await sendSilence(
            sequence: sequence,
            timestamp: timestamp,
            ssrc: ssrc,
            mode: mode,
            key: key
          )
        }

        timestamp &+= 960
        sequence &+= 1

        try? await clock.sleep(until: start + interval)
      }
    }
  }

  private func sendSilence(
    sequence: UInt16,
    timestamp: UInt32,
    ssrc: UInt32,
    mode: VoiceGateway.EncryptionMode,
    key: SymmetricKey
  ) async {
    // Discord Opus silence frame
    let silence = Data([0xF8, 0xFF, 0xFE])

    await sendPacket(
      frame: silence,
      sequence: sequence,
      timestamp: timestamp,
      ssrc: ssrc,
      mode: mode,
      key: key
    )
  }

  private func startDrainingOutgoingChannel() {
    channelDrainTask = Task {
      for await frame in outgoingOpusChannel {
        pendingOpusFrames.append(frame)

        if pendingOpusFrames.count > 5 {
          pendingOpusFrames.removeFirst()
        }
      }
    }
  }

  func sendPacket(
    frame: Data,
    sequence: UInt16,
    timestamp: UInt32,
    ssrc: UInt32,
    mode: VoiceGateway.EncryptionMode,
    key: SymmetricKey
  ) async {

    guard let udpConnection = self.udpConnection else {
      return
    }

    guard
      let encrypted = mode.encrypt(
        buffer: frame,
        using: key
      )
    else {
      logger.error("Voice encryption failed")
      return
    }

    let headerPacket = RTPPacket(
      payloadType: .dynamic(.init(VoiceGateway.Codec.opusCodec.payload_type)),
      sequence: sequence,
      timestamp: timestamp,
      ssrc: ssrc,
      payload: ByteBuffer()  // empty for now
    )

    var headerBuffer = headerPacket.rawValue

    guard let headerBytes = headerBuffer.readBytes(length: 12) else {
      logger.error("Failed to extract RTP header")
      return
    }

    var packet = ByteBuffer()

    packet.writeBytes(headerBytes)
    packet.writeBytes(encrypted.ciphertext)
    packet.writeBytes(encrypted.tag)
    packet.writeBytes(encrypted.nonceSuffix)

    // dave encrypt

    do {
      let daveEncrypted = try await self.dave.encrypt(
        ssrc: ssrc,
        data: .init(buffer: packet, byteTransferStrategy: .noCopy),
        mediaType: .audio
      )
      try await udpConnection.send(buffer: .init(data: daveEncrypted))
    } catch {
      logger.error(
        "Failed to send voice packet",
        metadata: [
          "error": .string(String(reflecting: error))
        ]
      )
    }
  }

  /// Process an incoming voice packet. Voice packets are RTP packets that are encrypted
  /// using the selected crypto mode and key, E2EE encrypted using Dave, and then encoded
  /// using OPUS.
  private func processIncomingVoicePacket(
    _ packet: RTPPacket,
    mode: VoiceGateway.EncryptionMode,
    key: SymmetricKey
  ) async {
    var buffer = packet.payload
    // First, decrypt the RTP packet payload

    var extensionLength: UInt16?
    if packet.extension {
      // If the packet has an extension, the metadata for the extension is stored
      // outside of the encrypted portion of the payload, but the extension data itself
      // is encrypted. This is not compliant with the RTP spec, but is how Discord
      // implements it.
      guard buffer.readInteger(as: UInt16.self) != nil,  // extension info
        let length = buffer.readInteger(as: UInt16.self)
      else {
        return
      }

      extensionLength = length
    }

    guard
      var data = mode.decrypt(
        buffer: packet.payload,
        with: key,
      )
    else {
      return
    }

    if let extensionLength {
      data.removeFirst(Int(extensionLength) * 4)
    }

    if data.isEmpty {
      return
    }

    // We've removed the crypto layer, now to remove the Dave E2EE layer

    guard let userId = knownSSRCs[.init(packet.ssrc)] else {
      return
    }

    guard
      let data = try? await dave.decrypt(
        userId: userId.rawValue,
        data: data,
        mediaType: .audio
      )
    else {
      return
    }

    await incomingOpusChannel.send(data)
  }

  public func sendOpusFrame(_ frame: Data) {

  }

  // MARK: - Gateway actions

  //  /// https://discord.com/developers/docs/topics/gateway-events#update-presence
  //  public func updatePresence(payload: Gateway.Identify.Presence) {
  //    self.send(
  //      message: .init(
  //        payload: .init(
  //          opcode: .presenceUpdate,
  //          data: .requestPresenceUpdate(payload)
  //        ),
  //        opcode: .text
  //      )
  //    )
  //  }
  //
  //  /// https://discord.com/developers/docs/topics/gateway-events#update-voice-state
  //  public func updateVoiceState(payload: VoiceStateUpdate) {
  //    self.send(
  //      message: .init(
  //        payload: .init(
  //          opcode: .voiceStateUpdate,
  //          data: .requestVoiceStateUpdate(payload)
  //        ),
  //        opcode: .text
  //      )
  //    )
  //  }

  // MARK: End of Gateway actions -

  /// Makes an stream of Gateway events.
  @available(*, deprecated, renamed: "events")
  public func makeEventsStream() -> AsyncStream<VoiceGateway.Event> {
    self.events.base
  }

  /// Makes an stream of Gateway event parse failures.
  @available(*, deprecated, renamed: "eventFailures")
  public func makeEventsParseFailureStream() -> AsyncStream<
    (any Error, ByteBuffer)
  > {
    self.eventFailures.base
  }

  /// Disconnects from Discord.
  /// Doesn't end the event streams.
  public func disconnect() async {
    logger.debug(
      "Will disconnect",
      metadata: [
        "connectionId": .stringConvertible(
          self.connectionId.load(ordering: .relaxed)
        )
      ]
    )
    if self.state.load(ordering: .relaxed) == .stopped {
      logger.debug(
        "Already disconnected",
        metadata: [
          "connectionId": .stringConvertible(
            self.connectionId.load(ordering: .relaxed)
          )
        ]
      )
      return
    }
    self.connectionId.wrappingIncrement(ordering: .relaxed)
    self.state.store(.noConnection, ordering: .relaxed)
    self.stateCallback?(.noConnection)
    connectionBackoff.resetTryCount()
    await self.sendQueue.reset()
    await self.closeWebSocket()
    // cancel udp connection tasks
    self.udpConnectionTask?.cancel()
    self.udpListeningTask?.cancel()
    self.udpSpeakingTask?.cancel()
    self.channelDrainTask?.cancel()
    self.udpConnection = nil
    self.nextSpeakingPayload = nil
  }
}

extension VoiceGatewayManager {
  private func sendResumeOrIdentify() async {
    if let lastSequenceNumber = self.sequenceNumber {
      self.sendResume(sequenceNumber: lastSequenceNumber)
    } else {
      logger.debug(
        "Can't resume last Discord connection. Will identify",
        metadata: [
          "lastSequenceNumber": .stringConvertible(self.sequenceNumber ?? -1)
        ]
      )
      await self.sendIdentify()
    }
  }

  private func sendResume(sequenceNumber: Int) {
    let resume = VoiceGateway.Event(
      opcode: .resume,
      data: .resume(
        .init(
          server_id: connectionData.guildID,
          channel_id: connectionData.channelID,
          session_id: connectionData.sessionID,
          token: connectionData.token,
          seq_ack: sequenceNumber
        )
      )
    )
    let opcode = Gateway.Opcode.identify
    self.send(
      message: .init(
        payload: resume,
        opcode: .init(encodedWebSocketOpcode: opcode.rawValue)!
      )
    )

    /// Invalidate `sequenceNumber` info for the next connection, incase this one fails.
    /// This will be a notice for the next connection to
    /// not try resuming anymore, if this connection has failed.
    self.sequenceNumber = nil

    logger.debug("Sent resume request to Discord")
  }

  private func sendIdentify() async {
    connectionBackoff.willTry()
    let identify = VoiceGateway.Event(
      opcode: .identify,
      data: .identify(identifyPayload)
    )
    self.send(message: .init(payload: identify, opcode: .text))
  }

  private func processBinaryData(
    _ message: WebSocketMessage,
    forConnectionWithId connectionId: UInt
  ) {
    guard self.connectionId.load(ordering: .relaxed) == connectionId else {
      return
    }

    var buffer: ByteBuffer
    let isBinary: Bool
    switch message {
    case .text(let string):
      self.logger.debug(
        "Got text from websocket",
        metadata: [
          "text": .string(string)
        ]
      )
      isBinary = false
      buffer = ByteBuffer(string: string)
    case .binary(let _buffer):
      self.logger.debug(
        "Got binary from websocket",
        metadata: [
          "text": .string(String(buffer: _buffer))
        ]
      )
      isBinary = true
      buffer = _buffer
    }

    // check if the raw data is a binary message with valid opcode or json message.
    do {
      let event = try self.tryDecodeBufferAsEvent(&buffer, binary: isBinary)
      Task { await self.processEvent(event) }
      for continuation in self.eventsStreamContinuations {
        continuation.yield(event)
      }
    } catch {
      self.logger.debug(
        "Failed to decode event",
        metadata: [
          "error": .string("\(error)")
        ]
      )
      for continuation in self.eventsParseFailureContinuations {
        continuation.yield((error, buffer))
      }
    }
  }

  func tryDecodeBufferAsEvent(_ buffer: inout ByteBuffer, binary: Bool) throws
    -> VoiceGateway.Event
  {
    if binary {
      // https://github.com/Snazzah/davey/blob/master/docs/USAGE.md
      guard let seq = buffer.readInteger(as: UInt16.self) else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: [],
            debugDescription:
              "Expected the first 2 bytes of the binary data to be the sequence number, but it couldn't be read as UInt16."
          )
        )
      }
      self.sequenceNumber = .init(seq)

      guard let opcode = buffer.readInteger(as: UInt8.self),
        let opcode = VoiceGateway.Opcode(rawValue: opcode)
      else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: [],
            debugDescription:
              "Expected the 3rd byte of the binary data to be the opcode, but it couldn't be read as UInt8 or didn't match any known opcode."
          )
        )
      }

      let data: VoiceGateway.Event.Payload?
      switch opcode {
      case .mlsExternalSender:
        data = .mlsExternalSender(Data(buffer: buffer))
      case .mlsProposals:
        data = .mlsProposals(Data(buffer: buffer))
      case .mlsAnnounceCommitTransition:
        guard let transitionId = buffer.readInteger(as: UInt16.self) else {
          throw DecodingError.dataCorrupted(
            .init(
              codingPath: [],
              debugDescription:
                "Expected the first 2 bytes of the binary data after the mlsAnnounceCommitTransition opcode to be the transition ID, but it couldn't be read as UInt16."
            )
          )
        }
        let commit = Data(buffer: buffer)
        data = .mlsAnnounceCommitTransition(
          transitionId: transitionId,
          commit: commit
        )
      case .mlsWelcome:
        guard let transitionId = buffer.readInteger(as: UInt16.self) else {
          throw DecodingError.dataCorrupted(
            .init(
              codingPath: [],
              debugDescription:
                "Expected the first 2 bytes of the binary data after the mlsWelcome opcode to be the transition ID, but it couldn't be read as UInt16."
            )
          )
        }
        let welcome = Data(buffer: buffer)
        data = .mlsWelcome(
          transitionId: transitionId,
          welcome: welcome
        )
      default:
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: [],
            debugDescription:
              "Received an opcode \(opcode.description) that is not expected to be binary, but it came as binary."
          )
        )
      }
      let event = VoiceGateway.Event(
        opcode: opcode,
        data: data
      )
      self.logger.debug(
        "Decoded binary event",
        metadata: [
          "event": .string("\(event)"),
          "opcode": .string(event.opcode.description),
        ]
      )
      return event
    } else {
      let event = try DiscordGlobalConfiguration.decoder.decode(
        VoiceGateway.Event.self,
        from: Data(buffer: buffer, byteTransferStrategy: .noCopy)
      )
      self.logger.debug(
        "Decoded event",
        metadata: [
          "event": .string("\(event)"),
          "opcode": .string(event.opcode.description),
        ]
      )
      return event
    }
  }

  private enum CloseReason {
    case closeFrame(WebSocketCloseFrame?)
    case error(any Error)
  }

  private func onClose(
    closeReason: CloseReason,
    forConnectionWithId connectionId: UInt
  ) async {
    self.logger.debug("Received connection close notification for a web-socket")
    guard self.connectionId.load(ordering: .relaxed) == connectionId else {
      return
    }
    let (code, codeDesc) = self.getCloseCodeAndDescription(of: closeReason)
    let isDebugLevelCode = [nil, .goingAway, .unexpectedServerError].contains(
      code
    )
    self.logger.log(
      level: isDebugLevelCode ? .debug : .warning,
      "Received connection close notification. Will try to reconnect",
      metadata: [
        "code": .string(codeDesc),
        "closedConnectionId": .stringConvertible(
          self.connectionId.load(ordering: .relaxed)
        ),
      ]
    )
    if self.canTryReconnect(code: code) {
      self.state.store(.noConnection, ordering: .relaxed)
      self.stateCallback?(.noConnection)
      self.logger.trace(
        "Will try reconnect since Discord does allow it.",
        metadata: [
          "code": .string(codeDesc),
          "closedConnectionId": .stringConvertible(
            self.connectionId.load(ordering: .relaxed)
          ),
        ]
      )
      await self.connect()
    } else {
      self.state.store(.stopped, ordering: .relaxed)
      self.stateCallback?(.stopped)
      self.connectionId.wrappingIncrement(ordering: .relaxed)
      self.logger.critical(
        "Will not reconnect because Discord does not allow it. Something is wrong. Your close code is '\(codeDesc)'."
      )

      /// Don't remove/end the event streams just to stop apps from crashing/restarting
      /// which could result in bot-token revocations or even temporary ip bans.
    }
  }

  private nonisolated func getCloseCodeAndDescription(
    of closeReason: CloseReason
  ) -> (WebSocketErrorCode?, String) {
    switch closeReason {
    case .error(let error):
      return (nil, String(reflecting: error))
    case .closeFrame(let closeFrame):
      guard let closeFrame else {
        return (nil, "nil")
      }
      let code = closeFrame.closeCode
      let description: String
      switch code {
      case .unknown(let codeNumber):
        switch VoiceGatewayCloseCode(rawValue: codeNumber) {
        case .some(let discordCode):
          description = "\(discordCode)"
        case .none:
          description = "\(codeNumber)"
        }
      default:
        description = closeFrame.reason ?? "\(code)"
      }
      return (code, description)
    }
  }

  private nonisolated func canTryReconnect(code: WebSocketErrorCode?) -> Bool {
    switch code {
    case .unknown(let codeNumber):
      guard let discordCode = VoiceGatewayCloseCode(rawValue: codeNumber) else {
        return true
      }
      return discordCode.canTryReconnect
    default: return true
    }
  }

  private func setupPingTask(
    forConnectionWithId connectionId: UInt,
    every duration: Duration
  ) {
    Task {
      // Send the first ping immediately, then loop sleeping between sends.
      while self.connectionId.load(ordering: .relaxed) == connectionId {
        self.logger.debug(
          "Will send automatic ping",
          metadata: [
            "connectionId": .stringConvertible(connectionId)
          ]
        )
        self.sendPing(forConnectionWithId: connectionId)

        try? await Task.sleep(for: duration)
      }

      self.logger.trace(
        "Canceled a ping task",
        metadata: [
          "connectionId": .stringConvertible(connectionId)
        ]
      )
    }
  }

  private func sendPing(forConnectionWithId connectionId: UInt) {
    logger.trace(
      "Will ping",
      metadata: [
        "connectionId": .stringConvertible(connectionId)
      ]
    )

    // last sent ping nonce is usually the current unix timestamp:
    // https://docs.discord.food/topics/voice-connections#heartbeat-structure
    self.lastSentPingNonce = Int(Date().timeIntervalSince1970)
    self.send(
      message: .init(
        payload: .init(
          opcode: .heartbeat,
          data: .heartbeat(
            .init(seq_ack: self.sequenceNumber)
          )
        ),
        opcode: .text
      )
    )
    Task {
      try? await Task.sleep(for: .seconds(10))
      guard self.connectionId.load(ordering: .relaxed) == connectionId else {
        return
      }
      /// 15 == 10 + 5. 10 seconds that we slept, + 5 seconds tolerance.
      /// The tolerance being too long should not matter as pings usually happen
      /// only once in ~45 seconds, and a successful ping will reset the counter anyway.
      if self.lastPongDate.addingTimeInterval(15) > Date() {
        logger.trace("Successful ping")
        self.unsuccessfulPingsCount = 0
      } else {
        logger.trace("Unsuccessful ping")
        self.unsuccessfulPingsCount += 1
      }
      if unsuccessfulPingsCount > 2 {
        logger.debug(
          "Too many unsuccessful pings. Will try to reconnect",
          metadata: [
            "connectionId": .stringConvertible(
              self.connectionId.load(ordering: .relaxed)
            )
          ]
        )
        self.state.store(.noConnection, ordering: .relaxed)
        self.stateCallback?(.noConnection)
        await self.connect()
      }
    }
  }

  private nonisolated func send(message: Message) {
    self.sendQueue.perform { [weak self] in
      guard let self = self else { return }
      let state = self.state.load(ordering: .relaxed)
      switch state {
      case .connected:
        break
      case .stopped:
        logger.warning(
          "Will not send message because bot is stopped",
          metadata: [
            "message": .string("\(message)")
          ]
        )
        return
      case .noConnection, .connecting, .configured:
        switch message.payload.opcode.isSentForConnectionEstablishment {
        case true:
          break
        case false:
          /// Recursively try to send through the queue.
          /// The send queue has slowdown mechanisms so it's fine.
          self.send(message: message)
          return
        }
      }
      if let connectionId = message.connectionId,
        self.connectionId.load(ordering: .relaxed) != connectionId
      {
        return
      }
      Task {
        let opcode: WebSocketOpcode =
          message.opcode ?? .text

        let data: Data
        do {
          // switch opcodes bc some are sent as binary.
          switch message.payload.opcode {
          case .mlsKeyPackage, .mlsCommitWelcome:
            switch message.payload.data {
            case .mlsKeyPackage(let payload):
              data = payload
            case .mlsCommitWelcome(let payload):
              data = payload
            default:
              /// never happens, here to initialise data for compile time checks.
              data = Data()
            }
          default:
            data = try DiscordGlobalConfiguration.encoder.encode(
              message.payload
            )
          }
        } catch {
          self.logger.error(
            "Could not encode payload, \(error)",
            metadata: [
              "payload": .string("\(message.payload)"),
              "opcode": .stringConvertible(opcode),
              "connectionId": .stringConvertible(
                self.connectionId.load(ordering: .relaxed)
              ),
            ]
          )
          return
        }

        if let outboundWriter = await self.outboundWriter {
          do {
            self.logger.debug(
              "Will send a payload with opcode",
              metadata: [
                "opcode": .string(message.payload.opcode.description)
              ]
            )
            self.logger.trace(
              "Will send a payload",
              metadata: [
                "payload": .string("\(message.payload)"),
                "opcode": .stringConvertible(opcode),
              ]
            )
            try await outboundWriter.write(
              .custom(
                .init(
                  fin: true,
                  opcode: opcode,
                  data: ByteBuffer(data: data)
                )
              )
            )
          } catch {
            if let channelError = error as? ChannelError,
              case .ioOnClosedChannel = channelError
            {
              self.logger.error(
                "Received 'ChannelError.ioOnClosedChannel' error while sending payload through web-socket. Will fully disconnect and reconnect again"
              )
              await self.disconnect()
              await self.connect()
            } else if message.payload.opcode == .heartbeat,
              let writerError = error as? NIOAsyncWriterError,
              writerError == .alreadyFinished()
            {
              self.logger.debug(
                "Received 'NIOAsyncWriterError.alreadyFinished' error while sending heartbeat through web-socket. Will ignore"
              )
            } else {
              self.logger.error(
                "Could not send payload through web-socket",
                metadata: [
                  "error": .string(String(reflecting: error)),
                  "payload": .string("\(message.payload)"),
                  "opcode": .stringConvertible(opcode),
                  "state": .stringConvertible(
                    self.state.load(ordering: .relaxed)
                  ),
                  "connectionId": .stringConvertible(
                    self.connectionId.load(ordering: .relaxed)
                  ),
                ]
              )
            }
          }
        } else {
          /// Pings aka `heartbeat`s are fine if they are sent when a ws connection
          /// is not established. Pings are not disabled after a connection goes down
          /// so long story short, the gateway manager never gets stuck in a bad
          /// cycle of no-connection.
          self.logger.log(
            level: (message.payload.opcode == .heartbeat) ? .debug : .warning,
            "Trying to send through ws when a connection is not established",
            metadata: [
              "payload": .string("\(message.payload)"),
              "state": .stringConvertible(self.state.load(ordering: .relaxed)),
              "connectionId": .stringConvertible(
                self.connectionId.load(ordering: .relaxed)
              ),
            ]
          )
        }
      }
    }
  }

  private func onSuccessfulConnection() async {
    self.state.store(.connected, ordering: .relaxed)
    self.stateCallback?(.connected)
    connectionBackoff.resetTryCount()
    self.unsuccessfulPingsCount = 0
    await self.sendQueue.reset()
  }

  func setupOutboundWriter(_ outboundWriter: WebSocketOutboundWriter) {
    self.outboundWriter = outboundWriter
  }

  private func closeWebSocket() async {
    logger.debug("Will possibly close a web-socket")
    do {
      try await self.outboundWriter?.close(.goingAway, reason: nil)
    } catch {
      logger.warning(
        "Will ignore WS closure failure",
        metadata: [
          "error": .string(String(reflecting: error))
        ]
      )
    }
    self.outboundWriter = nil
  }

  public func getSessionID() -> String? {
    return self.connectionData.sessionID
  }
}

extension VoiceGatewayManager: DaveSessionDelegate {
  public func mlsKeyPackage(keyPackage: Data) async {
    let event = VoiceGateway.Event(
      opcode: .mlsKeyPackage,
      data: .mlsKeyPackage(keyPackage)
    )
    self.send(
      message: .init(
        payload: event,
        opcode: .binary
      )
    )
  }

  public func mlsCommitWelcome(welcome: Data) async {
    let event = VoiceGateway.Event(
      opcode: .mlsCommitWelcome,
      data: .mlsCommitWelcome(welcome)
    )
    self.send(
      message: .init(
        payload: event,
        opcode: .binary
      )
    )
  }

  public func mlsInvalidCommitWelcome(transitionId: UInt16) async {
    let event = VoiceGateway.Event(
      opcode: .mlsInvalidCommitWelcome,
      data: .mlsInvalidCommitWelcome(.init(transitionId: transitionId))
    )
    self.send(
      message: .init(
        payload: event,
        opcode: .text
      )
    )
  }

  public func readyForTransition(transitionId: UInt16) async {
    let event = VoiceGateway.Event(
      opcode: .daveTransitionReady,
      data: .daveTransitionReady(.init(transitionId: transitionId))
    )
    self.send(
      message: .init(
        payload: event,
        opcode: .text
      )
    )
  }

}

extension VoiceGatewayManager {
  func addEventsContinuation(
    _ continuation: AsyncStream<VoiceGateway.Event>.Continuation
  ) {
    self.eventsStreamContinuations.append(continuation)
  }

  func addEventsParseFailureContinuation(
    _ continuation: AsyncStream<(any Error, ByteBuffer)>.Continuation
  ) {
    self.eventsParseFailureContinuations.append(continuation)
  }
}

extension VoiceGateway.Opcode {
  var isSentForConnectionEstablishment: Bool {
    switch self {
    case .identify, .resume: true
    default: false
    }
  }
}
