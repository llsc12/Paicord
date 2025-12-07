//
//  UserGatewayManager.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 26/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import AsyncHTTPClient
import Atomics
import DiscordHTTP
import DiscordModels
import Foundation
import Logging
import NIO
import WSClient

import enum NIOWebSocket.WebSocketErrorCode
import struct NIOWebSocket.WebSocketOpcode

public actor UserGatewayManager: GatewayManager {

  private struct Message {
    let payload: Gateway.Event
    let opcode: WebSocketOpcode?
    let connectionId: UInt?
    var tryCount: Int

    init(
      payload: Gateway.Event,
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

  var outboundWriter: WebSocketOutboundWriter?
  let eventLoopGroup: any EventLoopGroup
  /// A client to send requests to Discord.
  public nonisolated let client: any DiscordClient
  /// Max frame size we accept to receive through the web-socket connection.
  let maxFrameSize: Int
  /// Generator of `UserGatewayManager` ids.
  static let idGenerator = ManagedAtomic(UInt(0))
  /// This gateway manager's identifier.
  public nonisolated let id = idGenerator.wrappingIncrementThenLoad(
    ordering: .relaxed
  )
  let logger: Logger

  //MARK: Event streams
  var eventsStreamContinuations = [AsyncStream<Gateway.Event>.Continuation]()
  var eventsParseFailureContinuations = [
    AsyncStream<(any Error, ByteBuffer)>.Continuation
  ]()

  /// An async sequence of Gateway events.
  public var events: DiscordAsyncSequence<Gateway.Event> {
    DiscordAsyncSequence<Gateway.Event>(
      base: AsyncStream<Gateway.Event> { continuation in
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
  public nonisolated let identifyPayload: Gateway.Identify

  //MARK: Connection state
  public nonisolated let state = ManagedAtomic(GatewayState.noConnection)
  public nonisolated let stateCallback: (@Sendable (GatewayState) -> Void)?

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
  /// The ID of the current Discord-related session.
  var sessionId: String? = nil
  /// Gateway URL for resuming the connection, so we don't need to make an api call.
  var resumeGatewayURL: String? = nil

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
  // TODO: - Reconfigure the backoff to be more suitable for users.

  //MARK: Ping-pong tracking properties
  var unsuccessfulPingsCount = 0
  var lastPongDate = Date()

  /// - Parameters:
  ///   - eventLoopGroup: An `EventLoopGroup`.
  ///   - httpClient: A `HTTPClient`.
  ///   - clientConfiguration: Configuration of the `DiscordClient`.
  ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
  ///   - token: Your Discord user-token.
  ///   - appId: Your Discord application-id. If not provided, it'll be extracted from user-token.
  ///   - largeThreshold: Value between 50 and 250, total number of members where the gateway
  ///     will stop sending offline members in the guild member list.
  ///   - presence: The initial presence of the user.
  ///   - capabilities: The Discord capabilities you want to use.
  ///   - captchaCallback: A callback to solve captcha challenges.
  ///   - mfaCallback: A callback to solve multi-factor authentication challenges.
  public init(
    eventLoopGroup: any EventLoopGroup = HTTPClient.shared.eventLoopGroup,
    httpClient: HTTPClient = .shared,
    clientConfiguration: ClientConfiguration = .init(),
    maxFrameSize: Int = 1 << 28,
    token: Secret,
    appId: ApplicationSnowflake? = nil,
    largeThreshold: Int? = nil,
    presence: Gateway.Identify.Presence? = nil,
    capabilities: [Gateway.Capability] = [
      .lazyUserNotes,
      .authTokenRefresh,
      .userSettingsProto,
      .debounceMessageReactions,
      .nonChannelReadStates,
    ],
    captchaCallback: CaptchaChallengeHandler? = nil,
    mfaCallback: MFAVerificationHandler? = nil,
    stateCallback: (@Sendable (GatewayState) -> Void)? = nil
  ) async {
    self.eventLoopGroup = eventLoopGroup
    self.stateCallback = stateCallback
    self.client = await DefaultDiscordClient.init(
      httpClient: httpClient,
      header: .userToken(token),
      appId: appId,
      configuration: clientConfiguration,
      captchaCallback: captchaCallback,
      mfaCallback: mfaCallback
    )
    self.maxFrameSize = maxFrameSize
    self.identifyPayload = .init(
      token: token,
      properties: .init(ws: true),
      large_threshold: largeThreshold,
      presence: presence,
      capabilities: capabilities
    )

    var logger = DiscordGlobalConfiguration.makeLogger("GatewayManager")
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
    let gatewayURL = await getGatewayURL()
    let queries: [(String, String)] = [
      ("v", "\(DiscordGlobalConfiguration.apiVersion)"),
      ("encoding", "json"),
      ("compress", "zlib-stream"),
    ]

    let decompressorWSExtension: ZlibDecompressorWSExtension
    do {
      decompressorWSExtension = try ZlibDecompressorWSExtension(
        logger: self.logger
      )
    } catch {
      self.logger.critical(
        "Will not connect because can't create a decompressor. Something is wrong. Please report this failure at https://github.com/DiscordBM/DiscordBM/issues",
        metadata: ["error": .string(String(reflecting: error))]
      )
      return
    }

    let configuration = WebSocketClientConfiguration(
      maxFrameSize: self.maxFrameSize,
      additionalHeaders: [
        .userAgent: SuperProperties.useragent(ws: false)!,
        .origin: "https://discord.com",
        .cacheControl: "no-cache",
        .acceptEncoding: "gzip, deflate, br, deflate",
        .acceptLanguage: SuperProperties.GenerateLocaleHeader(),
        
      ],
      extensions: [.nonNegotiatedExtension { decompressorWSExtension }]
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
        let closeFrame = try await WebSocketClient.connect(
          url: gatewayURL + queries.makeForURLQuery(),
          configuration: configuration,
          eventLoopGroup: self.eventLoopGroup,
          logger: self.logger
        ) { inbound, outbound, context in
          await self.setupOutboundWriter(outbound)

          self.logger.debug(
            "Connected to Discord through web-socket. Will configure"
          )
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

  // MARK: - Gateway actions

  /// https://discord.com/developers/docs/topics/gateway-events#update-presence
  public func updatePresence(payload: Gateway.Identify.Presence) {
    self.send(
      message: .init(
        payload: .init(
          opcode: .presenceUpdate,
          data: .requestPresenceUpdate(payload)
        ),
        opcode: .text
      )
    )
  }

  /// https://discord.com/developers/docs/topics/gateway-events#update-voice-state
  public func updateVoiceState(payload: VoiceStateUpdate) {
    self.send(
      message: .init(
        payload: .init(
          opcode: .voiceStateUpdate,
          data: .requestVoiceStateUpdate(payload)
        ),
        opcode: .text
      )
    )
  }

  /// https://docs.discord.food/topics/gateway-events#ping-voice-server
  public func pingVoiceServer() {
    self.send(
      message: .init(
        payload: .init(
          opcode: .voiceServerPing,
          data: nil
        ),
        opcode: .text
      )
    )
  }

  /// https://discord.com/developers/docs/topics/gateway-events#request-guild-members
  /// https://docs.discord.food/topics/gateway-events#request-guild-members
  public func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) {
    self.send(
      message: .init(
        payload: .init(
          opcode: .requestGuildMembers,
          data: .requestGuildMembers(payload)
        ),
        opcode: .text
      )
    )
  }

  /// https://docs.discord.food/topics/gateway-events#update-guild-subscriptions
  public func updateGuildSubscriptions(
    payload: Gateway.UpdateGuildSubscriptions
  ) {
    self.send(
      message: .init(
        payload: .init(
          opcode: .guildSubscriptionsBulk,
          data: .updateGuildSubscriptions(payload)
        ),
        opcode: .text
      )
    )
  }

  //	/// https://docs.discord.food/topics/gateway-events#request-call-connect
  //	public func requestCallConnect(payload: Gateway.) {
  //		self.send(
  //			message: .init(
  //				payload: .init(
  //					opcode:
  //					data:
  //				),
  //				opcode: .text
  //			)
  //		)
  //	}

  //	/// https://docs.discord.food/topics/gateway-events#request-soundboard-sounds
  //	public func requestSoundboardSounds(payload: Gateway.) {
  //		self.send(
  //			message: .init(
  //				payload: .init(
  //					opcode:
  //					data:
  //				),
  //				opcode: .text
  //			)
  //		)
  //	}

  /// https://docs.discord.food/topics/gateway-events#request-last-messages
  public func requestLastMessages(payload: Gateway.RequestLastMessages) {
    self.send(
      message: .init(
        payload: .init(
          opcode: .requestLastMessages,
          data: .requestLastMessages(payload)
        ),
        opcode: .text
      )
    )
  }

  // MARK: End of Gateway actions -

  /// Makes an stream of Gateway events.
  @available(*, deprecated, renamed: "events")
  public func makeEventsStream() -> AsyncStream<Gateway.Event> {
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
  }
}

extension UserGatewayManager {
  private func processEvent(_ event: Gateway.Event) async {
    if let sequenceNumber = event.sequenceNumber {
      self.sequenceNumber = sequenceNumber
    }

    switch event.opcode {
    case .heartbeat:
      self.sendPing(
        forConnectionWithId: self.connectionId.load(ordering: .relaxed)
      )
    case .heartbeatAccepted:
      self.lastPongDate = Date()
    case .reconnect:
      logger.debug(
        "Received reconnect request. Will reconnect after connection closure"
      )
    default:
      break
    }

    switch event.data {
    case .invalidSession(let canResume):
      logger.warning(
        "Got invalid session. Will try to reconnect or resume",
        metadata: [
          "canResume": .stringConvertible(canResume)
        ]
      )
      if !canResume {
        self.sequenceNumber = nil
        self.resumeGatewayURL = nil
        self.sessionId = nil
      }
      self.state.store(.noConnection, ordering: .relaxed)
      self.stateCallback?(.noConnection)
      await self.connect()
    case .hello(let hello):
      logger.debug("Received 'hello'")
      /// Start heart-beating right-away.
      self.setupPingTask(
        forConnectionWithId: self.connectionId.load(ordering: .relaxed),
        every: .milliseconds(Int64(hello.heartbeat_interval))
      )
      /// Sends the update time spent session id payload every 30 minutes, but also on connect too.
      self.sendUpdateTimeSpentSessionID(forConnectionWithId: self.connectionId.load(ordering: .relaxed))
      self.setupUpdateTimeSpentSessionID(forConnectionWithId: self.connectionId.load(ordering: .relaxed), every: .minutes(30))
      logger.trace("Will resume or identify")
      await self.sendResumeOrIdentify()
    case .ready(let payload):
      logger.notice(
        "Received ready notice. The connection is fully established",
        metadata: [
          "connectionId": .stringConvertible(
            self.connectionId.load(ordering: .relaxed)
          )
        ]
      )
      await self.onSuccessfulConnection()
      self.sessionId = payload.session_id
      self.resumeGatewayURL = payload.resume_gateway_url
    case .resumed:
      logger.debug(
        "Received resume notice. The connection is fully established",
        metadata: [
          "connectionId": .stringConvertible(
            self.connectionId.load(ordering: .relaxed)
          )
        ]
      )
      await self.onSuccessfulConnection()
    default:
      break
    }
  }

  private func getGatewayURL() async -> String {
    logger.debug("Will try to get Discord gateway url")
    if self.sequenceNumber != nil,
      /// If can resume at all
      let gatewayURL = self.resumeGatewayURL
    {
      logger.trace("Got Discord gateway url from 'resumeGatewayURL'")
      return gatewayURL
    } else {
      do {
        let gatewayURL = try await client.getGateway().decode().url
        logger.trace("Got Discord gateway url from gateway api call")
        return gatewayURL
      } catch {
        logger.error(
          "Cannot get gateway url to connect to. Will retry in 10 seconds",
          metadata: [
            "error": .string(String(reflecting: error))
          ]
        )
        try? await Task.sleep(for: .seconds(10))
        return await self.getGatewayURL()
      }
    }
  }

  private func sendResumeOrIdentify() async {
    if let sessionId = self.sessionId,
      let lastSequenceNumber = self.sequenceNumber
    {
      self.sendResume(sessionId: sessionId, sequenceNumber: lastSequenceNumber)
    } else {
      logger.debug(
        "Can't resume last Discord connection. Will identify",
        metadata: [
          "sessionId": .stringConvertible(self.sessionId ?? "nil"),
          "lastSequenceNumber": .stringConvertible(self.sequenceNumber ?? -1),
        ]
      )
      await self.sendIdentify()
    }
  }

  private func sendResume(sessionId: String, sequenceNumber: Int) {
    let resume = Gateway.Event(
      opcode: .resume,
      data: .resume(
        .init(
          token: identifyPayload.token,
          session_id: sessionId,
          sequence: sequenceNumber
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
    let identify = Gateway.Event(
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

    let buffer: ByteBuffer
    switch message {
    case .text(let string):
      self.logger.debug(
        "Got text from websocket",
        metadata: [
          "text": .string(string)
        ]
      )
      buffer = ByteBuffer(string: string)
    case .binary(let _buffer):
      self.logger.debug(
        "Got binary from websocket",
        metadata: [
          "text": .string(String(buffer: _buffer))
        ]
      )
      buffer = _buffer
    }

    do {
      let event = try DiscordGlobalConfiguration.decoder.decode(
        Gateway.Event.self,
        from: Data(buffer: buffer, byteTransferStrategy: .noCopy)
      )
      self.logger.debug(
        "Decoded event",
        metadata: [
          "event": .string("\(event)"),
          "opcode": .string(event.opcode.description),
        ]
      )
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
        switch GatewayCloseCode(rawValue: codeNumber) {
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
      guard let discordCode = GatewayCloseCode(rawValue: codeNumber) else {
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
      try? await Task.sleep(for: duration)
      guard self.connectionId.load(ordering: .relaxed) == connectionId else {
        self.logger.trace(
          "Canceled a ping task",
          metadata: [
            "connectionId": .stringConvertible(connectionId)
          ]
        )
        return/// cancel
      }
      self.logger.debug(
        "Will send automatic ping",
        metadata: [
          "connectionId": .stringConvertible(connectionId)
        ]
      )
      self.sendPing(forConnectionWithId: connectionId)
      self.setupPingTask(forConnectionWithId: connectionId, every: duration)
    }
  }
  
  private func setupUpdateTimeSpentSessionID(
    forConnectionWithId connectionId: UInt,
    every duration: Duration
  ) {
    Task {
      try? await Task.sleep(for: duration)
      guard self.connectionId.load(ordering: .relaxed) == connectionId else {
        self.logger.trace(
          "Canceled a session time spent update task",
          metadata: [
            "connectionId": .stringConvertible(connectionId)
          ]
        )
        return/// cancel
      }
      self.logger.debug(
        "Will send automatic session time spent update",
        metadata: [
          "connectionId": .stringConvertible(connectionId)
        ]
      )
      self.sendPing(forConnectionWithId: connectionId)
      self.sendUpdateTimeSpentSessionID(forConnectionWithId: connectionId)
      self.setupUpdateTimeSpentSessionID(forConnectionWithId: connectionId, every: duration)
    }
  }

  private func sendPing(forConnectionWithId connectionId: UInt) {
    logger.trace(
      "Will ping",
      metadata: [
        "connectionId": .stringConvertible(connectionId)
      ]
    )
//        self.send(
//          message: .init(
//            payload: .init(
//              opcode: .heartbeat,
//              data: .heartbeat(lastSequenceNumber: self.sequenceNumber)
//            )
//          )
//        )
    // use QoS Heartbeat instead
    self.send(
      message: .init(
        payload: .init(
          opcode: .qosHeartbeat,
          data: .qosHeartbeat(.init(seq: self.sequenceNumber, qos: .init())) // TODO: use actual client focus data instead
        ),
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

  private func sendUpdateTimeSpentSessionID(forConnectionWithId connectionId: UInt) {
    logger.trace(
      "Will send session time spent update",
      metadata: [
        "connectionId": .stringConvertible(connectionId)
      ]
    )
    self.send(
      message: .init(
        payload: .init(
          opcode: .updateTimeSpentSessionId,
          data: .updateTimeSpentSessionId(Gateway.UpdateTimeSpentSessionID())
        )
      )
    )
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
        // discordbm tried to turn discord's opcodes into a ws opcode. this only work for heartbeats.
        // this is really jank. fall back to .text opcode instead
//        let opcode: WebSocketOpcode =
//          message.opcode ?? .init(
//            encodedWebSocketOpcode: message.payload.opcode.rawValue
//          )!
        let opcode: WebSocketOpcode =
          message.opcode ?? .text
        
        let data: Data
        do {
          data = try DiscordGlobalConfiguration.encoder.encode(message.payload)
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
    return self.sessionId
  }
}

extension UserGatewayManager {
  func addEventsContinuation(
    _ continuation: AsyncStream<Gateway.Event>.Continuation
  ) {
    self.eventsStreamContinuations.append(continuation)
  }

  func addEventsParseFailureContinuation(
    _ continuation: AsyncStream<(any Error, ByteBuffer)>.Continuation
  ) {
    self.eventsParseFailureContinuations.append(continuation)
  }
}
