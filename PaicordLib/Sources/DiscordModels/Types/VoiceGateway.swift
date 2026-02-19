//
//  VoiceGateway.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 19/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation

public struct VoiceGateway: Sendable, Codable {

  /// https://docs.discord.food/topics/voice-connections
  public enum Opcode: UInt8, Sendable, Codable, CustomStringConvertible {
    case identify = 0  // s
    case selectProtocol = 1  // s
    case clientPlatform = 2  // r
    case heartbeat = 3  // s
    case sessionDescription = 4  // r
    case speaking = 5  // s r
    case heartbeatAck = 6  // r
    case resume = 7  // s
    case hello = 8  // r
    case resumed = 9 // r
    // signal opcode deprecated
    case clientConnect = 11  // r
    case video = 12  // r
    case clientDisconnect = 13  // r
    case sessionUpdate = 14  // s r
    case mediaSinkWants = 15  // s r
    case voiceBackendVersion = 16  // s r
    case channelOptionsUpdate = 17  // unknown, not docced too.

    public var description: String {
      switch self {
      case .identify: return "identify"
      case .selectProtocol: return "selectProtocol"
      case .clientPlatform: return "clientPlatform"
      case .heartbeat: return "heartbeat"
      case .sessionDescription: return "sessionDescription"
      case .speaking: return "speaking"
      case .heartbeatAck: return "heartbeatAck"
      case .resume: return "resume"
      case .hello: return "hello"
      case .resumed: return "resumed"
      case .clientConnect: return "clientConnect"
      case .video: return "video"
      case .clientDisconnect: return "clientDisconnect"
      case .sessionUpdate: return "sessionUpdate"
      case .mediaSinkWants: return "mediaSinkWants"
      case .voiceBackendVersion: return "voiceBackendVersion"
      case .channelOptionsUpdate: return "channelOptionsUpdate"
      }
    }
  }

  /// The top-level gateway event.
  /// https://discord.com/developers/docs/topics/gateway#gateway-events
  public struct Event: Sendable, Codable {

    /// This enum is just for swiftly organizing Discord gateway event's `data`.
    /// You need to read each case's inner payload's documentation for more info.
    ///
    /// `indirect` is used to mitigate this issue: https://github.com/swiftlang/swift/issues/74303
    indirect public enum Payload: Sendable {
      case identify(Identify)
      case ready(Ready)
      case 

      case __undocumented

    }

    public enum GatewayDecodingError: Error, CustomStringConvertible {
      case unhandledDispatchEvent(type: String?)

      public var description: String {
        switch self {
        case .unhandledDispatchEvent(let type):
          return
            "Gateway.Event.GatewayDecodingError.unhandledDispatchEvent(type: \(type ?? "nil"))"
        }
      }
    }

    enum CodingKeys: String, CodingKey {
      case opcode = "op"
      case data = "d"
      case sequenceNumber = "s"
    }

    public var opcode: Opcode
    public var data: Payload?
    public var sequenceNumber: Int?

    public init(
      opcode: Opcode,
      data: Payload? = nil,
      sequenceNumber: Int? = nil,
      type: String? = nil
    ) {
      self.opcode = opcode
      self.data = data
      self.sequenceNumber = sequenceNumber
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.opcode = try container.decode(Opcode.self, forKey: .opcode)
      self.sequenceNumber = try container.decodeIfPresent(
        Int.self,
        forKey: .sequenceNumber
      )

      func decodeData<D: Decodable>(as type: D.Type = D.self) throws -> D {
        try container.decode(D.self, forKey: .data)
      }

      switch opcode {
      //      case .none:
      //        guard try container.decodeNil(forKey: .data) else {
      //          throw DecodingError.typeMismatch(
      //            Optional<Never>.self,
      //            .init(
      //              codingPath: container.codingPath,
      //              debugDescription:
      //                "`\(opcode)` opcode is supposed to have no data."
      //            )
      //          )
      //        }
      //        self.data = nil
      case .identify, .selectProtocol, .heartbeat, .resume:
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: container.codingPath,
            debugDescription:
              "'\(opcode)' opcode is supposed to never be received."
          )
        )
      case .invalidSession:
        self.data = try .invalidSession(canResume: decodeData())
      case .hello:
      }
    }

    public enum EncodingError: Error, CustomStringConvertible {
      /// This event is not supposed to be sent at all. This could be a library issue, please report at https://github.com/DiscordBM/DiscordBM/issues.
      case notSupposedToBeSent(message: String)

      public var description: String {
        switch self {
        case .notSupposedToBeSent(let message):
          return "Gateway.Event.EncodingError.notSupposedToBeSent(\(message))"
        }
      }
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      switch self.opcode {
      case .dispatch, .reconnect, .invalidSession, .heartbeatAccepted, .hello:
        throw EncodingError.notSupposedToBeSent(
          message:
            "`\(self.opcode.rawValue)` opcode is supposed to never be sent."
        )
      default: break
      }
      try container.encode(self.opcode, forKey: .opcode)

      if self.sequenceNumber != nil {
        throw EncodingError.notSupposedToBeSent(
          message:
            "'sequenceNumber' is supposed to never be sent but wasn't nil (\(String(describing: sequenceNumber))."
        )
      }
      if self.type != nil {
        throw EncodingError.notSupposedToBeSent(
          message:
            "'type' is supposed to never be sent but wasn't nil (\(String(describing: type))."
        )
      }

      switch self.data {
      case .none:
        try container.encodeNil(forKey: .data)
      case .heartbeat(let lastSequenceNumber):
        try container.encode(lastSequenceNumber, forKey: .data)
      case .qosHeartbeat(let payload):
        try container.encode(payload, forKey: .data)
      case .identify(let payload):
        try container.encode(payload, forKey: .data)
      case .resume(let payload):
        try container.encode(payload, forKey: .data)
      case .requestGuildMembers(let payload):
        try container.encode(payload, forKey: .data)
      case .requestPresenceUpdate(let payload):
        try container.encode(payload, forKey: .data)
      case .requestVoiceStateUpdate(let payload):
        try container.encode(payload, forKey: .data)
      case .updateGuildSubscriptions(let payload):
        try container.encode(payload, forKey: .data)
      case .updateTimeSpentSessionId(let payload):
        try container.encode(payload, forKey: .data)
      default:
        throw EncodingError.notSupposedToBeSent(
          message: "'\(self)' data is supposed to never be sent."
        )
      }
    }
  }
}

// MARK: + Gateway.Intent
extension Gateway.Intent {
  /// All intents that require no privileges.
  /// https://discord.com/developers/docs/topics/gateway#privileged-intents
  public static var unprivileged: [Gateway.Intent] {
    Gateway.Intent.allCases.filter { !$0.isPrivileged }
  }

  /// https://discord.com/developers/docs/topics/gateway#privileged-intents
  public var isPrivileged: Bool {
    switch self {
    case .guilds: return false
    case .guildMembers: return true
    case .guildModeration: return false
    case .guildEmojisAndStickers: return false
    case .guildIntegrations: return false
    case .guildWebhooks: return false
    case .guildInvites: return false
    case .guildVoiceStates: return false
    case .guildPresences: return true
    case .guildMessages: return false
    case .guildMessageReactions: return false
    case .guildMessageTyping: return false
    case .directMessages: return false
    case .directMessageReactions: return false
    case .directMessageTyping: return false
    case .messageContent: return true
    case .guildScheduledEvents: return false
    case .autoModerationConfiguration: return false
    case .autoModerationExecution: return false
    case .guildMessagePolls: return false
    case .directMessagePolls: return false
    /// Undocumented cases are considered privileged just to be safe than sorry
    case .__undocumented: return true
    }
  }
}
