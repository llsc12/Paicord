//
//  RemoteAuthGatewayManager.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 19/01/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import AsyncHTTPClient
import Atomics
import Crypto
import DiscordGateway
import DiscordModels
import Foundation
import Logging
import NIO
import NIOSSL
import WSClient
import _CryptoExtras

import enum NIOWebSocket.WebSocketErrorCode
import struct NIOWebSocket.WebSocketOpcode

public actor RemoteAuthGatewayManager {

  public enum RemoteAuthOpcode: String, Codable, Sendable {
    case hello
    case `init` = "init"
    case heartbeat
    case heartbeat_ack = "heartbeat_ack"
    case nonce_proof = "nonce_proof"
    case pending_remote_init = "pending_remote_init"
    case pending_ticket = "pending_ticket"
    case pending_login = "pending_login"
    case cancel
  }

  /// A flat payload structure used by the remote-auth gateway. The gateway
  /// uses a flat packet where `op` identifies the payload kind and other keys
  /// are optional depending on the op. Just being lazy sorry
  public struct RemoteAuthPayload: Codable, CustomStringConvertible, Sendable {
    public let op: RemoteAuthOpcode

    // hello
    public var heartbeat_interval: Int?
    public var timeout_ms: Int?

    // init
    public var encoded_public_key: String?

    // nonce_proof (incoming)
    public var encrypted_nonce: String?

    // nonce_proof (outgoing)
    public var nonce: String?

    // pending_remote_init
    public var fingerprint: String?

    // pending_ticket
    public internal(set) var encrypted_user_payload: String?

    public var user_payload: UserPayload?

    public struct UserPayload: Codable, Sendable {
      public let id: String
      public let discriminator: String
      public let avatar: String?
      public let username: String
    }

    // pending_login
    public var ticket: String?

    public init(
      op: RemoteAuthOpcode,
      heartbeat_interval: Int? = nil,
      timeout_ms: Int? = nil,
      encoded_public_key: String? = nil,
      encrypted_nonce: String? = nil,
      nonce: String? = nil,
      fingerprint: String? = nil,
      encrypted_user_payload: String? = nil,
      user_payload: UserPayload? = nil,
      ticket: String? = nil
    ) {
      self.op = op
      self.heartbeat_interval = heartbeat_interval
      self.timeout_ms = timeout_ms
      self.encoded_public_key = encoded_public_key
      self.encrypted_nonce = encrypted_nonce
      self.nonce = nonce
      self.fingerprint = fingerprint
      self.encrypted_user_payload = encrypted_user_payload
      self.user_payload = user_payload
      self.ticket = ticket
    }

    public var description: String { "RemoteAuthPayload(op: \(op), ... )" }
  }

  private struct Message: Sendable {
    let payload: RemoteAuthPayload
    let opcode: WebSocketOpcode?
    let connectionId: UInt?
    var tryCount: Int

    init(
      payload: RemoteAuthPayload,
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
  /// Max frame size we accept to receive through the web-socket connection.
  let maxFrameSize: Int
  /// Generator of `RemoteAuthGatewayManager` ids.
  static let idGenerator = ManagedAtomic(UInt(0))
  /// This gateway manager's identifier.
  public nonisolated let id = idGenerator.wrappingIncrementThenLoad(
    ordering: .relaxed
  )
  let logger: Logger

  //MARK: Event streams
  var eventsStreamContinuations: [AsyncStream<RemoteAuthPayload>.Continuation] =
    []
  var eventsParseFailureContinuations:
    [AsyncStream<(any Error, ByteBuffer)>.Continuation] = []

  /// An async sequence of Gateway events.
  public var events: DiscordAsyncSequence<RemoteAuthPayload> {
    DiscordAsyncSequence<RemoteAuthPayload>(
      base: AsyncStream<RemoteAuthPayload> { continuation in
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

  // MARK: - RSA keypair and fingerprint (SwiftCrypto _RSA)
  /// The client's RSA private key used to decrypt nonces and payloads.
  private var swiftCryptoPrivateKey: _RSA.Encryption.PrivateKey?
  /// The base64-encoded SPKI of the public key.
  private var encodedPublicKeySPKI: String?

  public init(
    eventLoopGroup: any EventLoopGroup = HTTPClient.shared.eventLoopGroup,
    maxFrameSize: Int = 1 << 28,
    stateCallback: (@Sendable (GatewayState) -> Void)? = nil
  ) {
    self.eventLoopGroup = eventLoopGroup
    self.stateCallback = stateCallback
    self.maxFrameSize = maxFrameSize

    var logger = DiscordGlobalConfiguration.makeLogger(
      "RemoteAuthGatewayManager"
    )
    logger[metadataKey: "gateway-id"] = .string(
      "\(Self.idGenerator.wrappingIncrementThenLoad(ordering: .relaxed))"
    )
    self.logger = logger
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
    let gatewayURL = "wss://remote-auth-gateway.discord.gg/"
    let queries: [(String, String)] = [
      ("v", "2")
    ]

    let configuration = WebSocketClientConfiguration(
      maxFrameSize: self.maxFrameSize,
      additionalHeaders: [
        .userAgent: SuperProperties.useragent(ws: false)!,
        .origin: "https://discord.com",
        .cacheControl: "no-cache",
        .acceptLanguage: SuperProperties.GenerateLocaleHeader(),

      ]
    )

    logger.trace(
      "Will try to connect to Remote Auth Gateway through web-socket"
    )
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
            "Connected to Remote Auth Gateway through web-socket."
          )
          await self.onSuccessfulConnection()

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
          "web-socket error while connecting to Remote Auth Gateway. Will try again",
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

  public func sendInit(encodedPublicKey: String) {
    let payload = RemoteAuthPayload(
      op: .`init`,
      encoded_public_key: encodedPublicKey
    )
    self.send(message: .init(payload: payload, opcode: .text))
  }

  public func sendHeartbeat() {
    let payload = RemoteAuthPayload(op: .heartbeat)
    self.send(message: .init(payload: payload, opcode: .text))
  }

  public func sendNonceProof(nonce: String) {
    let payload = RemoteAuthPayload(op: .nonce_proof, nonce: nonce)
    self.send(message: .init(payload: payload, opcode: .text))
  }

  // MARK: End of Gateway actions -

  /// Makes an stream of Gateway events.
  @available(*, deprecated, renamed: "events")
  public func makeEventsStream() -> AsyncStream<RemoteAuthPayload> {
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

extension RemoteAuthGatewayManager {
  private func processEvent(_ event: RemoteAuthPayload) async {
    switch event.op {
    case .heartbeat:
      self.sendHeartbeat()
    case .heartbeat_ack:
      self.lastPongDate = Date()
    case .hello:
      guard let interval = event.heartbeat_interval else { break }
      // Start heart-beating right-away.
      self.setupPingTask(
        forConnectionWithId: self.connectionId.load(ordering: .relaxed),
        every: .milliseconds(Int64(interval))
      )
      // Generate RSA keypair and send Init automatically.
      await self.generateRSAKeyPairIfNeeded()
      if let encodedKey = self.encodedPublicKeySPKI {
        self.sendInit(encodedPublicKey: encodedKey)
      }
    case .nonce_proof:

      guard let encNonce = event.encrypted_nonce,
        let decryptedNonce = self.rsaDecryptOAEPSHA256(encNonce)
      else {
        self.logger.error("Missing or invalid encrypted_nonce in nonce_proof")
        break
      }

      let nonceProof = decryptedNonce.base64EncodedString(
        options: [.endLineWithLineFeed]
      ).replacingOccurrences(of: "=", with: "")
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
      self.logger.debug(
        "Sending nonce_proof",
        metadata: [
          "nonce_proof": .string(nonceProof)
        ]
      )
      self.sendNonceProof(nonce: nonceProof)
    case .`init`: break
    default: break
    }
  }

  private func processBinaryData(
    _ message: WebSocketMessage,
    forConnectionWithId connectionId: UInt
  ) async {
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
      var event = try DiscordGlobalConfiguration.decoder.decode(
        RemoteAuthPayload.self,
        from: Data(buffer: buffer, byteTransferStrategy: .noCopy)
      )
      self.logger.debug(
        "Decoded remote-auth event",
        metadata: [
          "event": .string("\(event)"),
          "op": .string(event.op.rawValue),
        ]
      )

      // If we have an encrypted user payload and our private key exists,
      // attempt to decrypt and populate `user_payload`.
      if let enc = event.encrypted_user_payload,
        self.swiftCryptoPrivateKey != nil
      {
        if let decrypted = self.rsaDecryptOAEPSHA256(enc) {
          if let decryptedString = String(data: decrypted, encoding: .utf8) {
            // id:discriminator:avatar:username
            let parts = decryptedString.split(
              separator: ":",
              omittingEmptySubsequences: false
            ).map(String.init)
            if parts.count >= 4 {
              let payload = RemoteAuthPayload.UserPayload(
                id: parts[0],
                discriminator: parts[1],
                avatar: parts[2].isEmpty ? nil : parts[2],
                username: parts[3]
              )
              event.user_payload = payload
            } else {
              self.logger.error(
                "Failed to parse decrypted user payload: \(decryptedString)"
              )
            }
          } else {
            self.logger.error(
              "Failed to decode decrypted encrypted_user_payload as UTF-8"
            )
          }
        } else {
          self.logger.error("Failed to decrypt encrypted_user_payload")
        }
      }

      Task { await self.processEvent(event) }
      for continuation in self.eventsStreamContinuations {
        continuation.yield(event)
      }
    } catch {
      self.logger.debug(
        "Failed to decode remote-auth event",
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
        "Will try reconnect since gateway allows it.",
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
        "Will not reconnect because gateway does not allow it. Your close code is '\(codeDesc)'."
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
      self.sendHeartbeat()
      self.setupPingTask(forConnectionWithId: connectionId, every: duration)
    }
  }

  private func sendPing(forConnectionWithId connectionId: UInt) {
    logger.trace(
      "Will ping",
      metadata: [
        "connectionId": .stringConvertible(connectionId)
      ]
    )
    self.sendHeartbeat()
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
        // For remote-auth, init and heartbeat are allowed prior to connected state
        switch message.payload.op {
        case .`init`, .heartbeat, .heartbeat_ack:
          break
        default:
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
              "Will send payload",
              metadata: [
                "op": .string(message.payload.op.rawValue)
              ]
            )
            self.logger.trace(
              "Will send payload",
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
            } else if message.payload.op == .heartbeat,
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
          /// Heartbeats are fine if they are sent when a ws connection
          /// is not established.
          self.logger.log(
            level: (message.payload.op == .heartbeat) ? .debug : .warning,
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

  /// Use this to exchange a remote auth ticket for a Discord auth token.
  /// - Parameter ticket: The remote auth ticket received from the gateway.
  /// - Returns: A token.
  public func exchange(ticket: String, client: any DiscordClient) async throws
    -> Secret
  {
    let req = try await client.exchangeRemoteAuthTicket(
      payload: .init(ticket: ticket)
    )
    try req.guardSuccess()
    let data = try req.decode()
    let encrypted_token = data.encrypted_token

    guard let privKey = self.swiftCryptoPrivateKey else {
      self.logger.error("No private key available to decrypt remote auth token")
      throw RemoteAuthError.noPrivateKey
    }

    guard let encryptedData = Data(base64Encoded: encrypted_token) else {
      self.logger.error("Remote auth token is not valid base64")
      throw RemoteAuthError.invalidBase64
    }

    do {
      let decryptedData = try privKey.decrypt(
        encryptedData,
        padding: .PKCS1_OAEP_SHA256
      )
      guard var tokenString = String(data: decryptedData, encoding: .utf8)
      else {
        self.logger.error("Decrypted token is not valid UTF-8")
        throw RemoteAuthError.decryptionFailed(underlying: nil)
      }
      tokenString = tokenString.trimmingCharacters(in: .whitespacesAndNewlines)
      if tokenString.isEmpty {
        self.logger.error("Decrypted remote auth token is empty")
        throw RemoteAuthError.emptyToken
      }
      return Secret(tokenString)
    } catch {
      self.logger.error("Failed to decrypt remote auth token: \(error)")
      throw RemoteAuthError.decryptionFailed(underlying: error)
    }
  }

  // MARK: - Helpers for RSA and fingerprints
  private func generateRSAKeyPairIfNeeded() async {
    if self.swiftCryptoPrivateKey != nil { return }
    do {
      // Use SwiftCrypto's _RSA API to generate a 2048-bit keypair.
      let priv = try _RSA.Encryption.PrivateKey(keySize: .bits2048)
      self.swiftCryptoPrivateKey = priv

      // Export SPKI from the public key.
      let spki = priv.publicKey.derRepresentation
      self.encodedPublicKeySPKI = spki.base64EncodedString()
    } catch {
      self.logger.error("SwiftCrypto RSA key generation failed: \(error)")
    }
  }

  private func rsaDecryptOAEPSHA256(_ ciphertextBase64: String) -> Data? {
    guard let priv = self.swiftCryptoPrivateKey else { return nil }
    guard let cipher = Data(base64Encoded: ciphertextBase64) else {
      self.logger.error("SwiftCrypto RSA decrypt: invalid base64 ciphertext")
      return nil
    }

    do {
      let plain = try priv.decrypt(cipher, padding: .PKCS1_OAEP_SHA256)
      return plain
    } catch {
      self.logger.trace(
        "RSA decrypt attempt failed: \(error)"
      )
      return nil
    }
  }

  enum RemoteAuthError: Error, Sendable {
    case noPrivateKey
    case invalidBase64
    case decryptionFailed(underlying: (any Error)?)
    case emptyToken
  }
}

extension RemoteAuthGatewayManager {
  func addEventsContinuation(
    _ continuation: AsyncStream<RemoteAuthPayload>.Continuation
  ) {
    self.eventsStreamContinuations.append(continuation)
  }

  func addEventsParseFailureContinuation(
    _ continuation: AsyncStream<(any Error, ByteBuffer)>.Continuation
  ) {
    self.eventsParseFailureContinuations.append(continuation)
  }
}
