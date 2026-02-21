//
//  VoiceGateway.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 19/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation
import NIOCore

public struct VoiceGateway: Sendable, Codable {

  /// https://docs.discord.food/topics/voice-connections
  public enum Opcode: UInt8, Sendable, Codable, CustomStringConvertible {
    // key:
    // r - received by client
    // s - sent by client
    // b - sent/received as binary
    case identify = 0  // s
    case selectProtocol = 1  // s
    case ready = 2  // r
    case heartbeat = 3  // s
    case sessionDescription = 4  // r
    case speaking = 5  // s r
    case heartbeatAck = 6  // r
    case resume = 7  // s
    case hello = 8  // r
    case resumed = 9  // r
    // signal opcode deprecated, but its 10 jsyk ykyk
    case clientConnect = 11  // r
    case video = 12  // r
    case clientDisconnect = 13  // r
    case sessionUpdate = 14  // s r
    case mediaSinkWants = 15  // s r
    case voiceBackendVersion = 16  // s r
    case channelOptionsUpdate = 17  // unknown
    case clientFlags = 18
    case clientPlatform = 20
    // https://github.com/Snazzah/davey/blob/master/docs/USAGE.md
    case davePrepareTransition = 21  // r
    case daveExecuteTransition = 22  // r
    case daveTransitionReady = 23  // s
    case davePrepareEpoch = 24  // r
    case mlsExternalSender = 25  // b r
    case mlsKeyPackage = 26  // b s
    case mlsProposals = 27  // b r
    case mlsCommitWelcome = 28  // b s
    case mlsAnnounceCommitTransition = 29  // b r
    case mlsWelcome = 30  // b r
    case mlsInvalidCommitWelcome = 31  // b s

    public var description: String {
      switch self {
      case .identify: return "identify"
      case .selectProtocol: return "selectProtocol"
      case .ready: return "ready"
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
      case .clientFlags: return "clientFlags"
      case .clientPlatform: return "clientPlatform"
      case .davePrepareTransition: return "davePrepareTransition"
      case .daveExecuteTransition: return "daveExecuteTransition"
      case .daveTransitionReady: return "daveTransitionReady"
      case .davePrepareEpoch: return "davePrepareEpoch"
      case .mlsExternalSender: return "mlsExternalSender"
      case .mlsKeyPackage: return "mlsKeyPackage"
      case .mlsProposals: return "mlsProposals"
      case .mlsCommitWelcome: return "mlsCommitWelcome"
      case .mlsAnnounceCommitTransition: return "mlsAnnounceCommitTransition"
      case .mlsWelcome: return "mlsWelcome"
      case .mlsInvalidCommitWelcome: return "mlsInvalidCommitWelcome"
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
      case selectProtocol(SelectProtocol)
      case heartbeat(Heartbeat)
      case sessionDescription(SessionDescription)
      case speaking(Speaking)
      case heartbeatAck(Heartbeat)
      case resume(Resume)
      case hello(Hello)
      case resumed
      case clientConnect(ClientConnect)
      case video(Video)
      case clientDisconnect(ClientDisconnect)
      case sessionUpdate(SessionUpdate)
      case mediaSinkWants(MediaSinkWants)
      case voiceBackendVersion(VoiceBackendVersion)
      //      case channelOptionsUpdate
      case clientFlags(ClientFlags)
      case clientPlatform(ClientPlatform)

      // dave stuff packages the entire frame.
      case davePrepareTransition(DavePrepareTransition)
      case daveExecuteTransition(DaveCommitTransition)
      case daveTransitionReady(DaveTransitionReady)
      case davePrepareEpoch(DavePrepareEpoch)
      case mlsExternalSender(Data)
      case mlsKeyPackage(Data)
      case mlsProposals(Data)
      case mlsCommitWelcome(Data)
      case mlsAnnounceCommitTransition(transitionId: UInt16, commit: Data)
      case mlsWelcome(transitionId: UInt16, welcome: Data)
      case mlsInvalidCommitWelcome(DaveMLSInvalidCommitWelcome)

      case __undocumented
    }

    public enum GatewayDecodingError: Error, CustomStringConvertible {
      case unhandledDispatchEvent(type: String?)
      case unexpectedBinaryData(message: String)

      public var description: String {
        switch self {
        case .unhandledDispatchEvent(let type):
          return
            "Gateway.Event.GatewayDecodingError.unhandledDispatchEvent(type: \(type ?? "nil"))"
        case .unexpectedBinaryData(let message):
          return
            "Gateway.Event.GatewayDecodingError.unexpectedBinaryData(message: \(message))"
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
      // the data could be binary or json.
      do {
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
        case .resumed:
          guard try container.decodeNil(forKey: .data) else {
            throw DecodingError.typeMismatch(
              Optional<Never>.self,
              .init(
                codingPath: container.codingPath,
                debugDescription:
                  "`\(opcode)` opcode is supposed to have no data."
              )
            )
          }
          self.data = nil
        case .identify, .selectProtocol, .resume, .daveTransitionReady,
          .mlsKeyPackage, .mlsCommitWelcome, .mlsInvalidCommitWelcome:
          throw DecodingError.dataCorrupted(
            .init(
              codingPath: container.codingPath,
              debugDescription:
                "'\(opcode)' opcode is supposed to never be received."
            )
          )
        case .ready:
          self.data = .ready(try decodeData())
        case .sessionDescription:
          self.data = .sessionDescription(try decodeData())
        case .sessionUpdate:
          self.data = .sessionUpdate(try decodeData())
        case .hello:
          self.data = .hello(try decodeData())
        case .heartbeat:
          self.data = .heartbeat(try decodeData())
        case .speaking:
          self.data = .speaking(try decodeData())
        case .heartbeatAck:
          self.data = .heartbeatAck(try decodeData())
        case .clientConnect:
          self.data = .clientConnect(try decodeData())
        case .video:
          self.data = .video(try decodeData())
        case .clientDisconnect:
          self.data = .clientDisconnect(try decodeData())
        case .mediaSinkWants:
          self.data = .mediaSinkWants(try decodeData())
        case .voiceBackendVersion:
          self.data = .voiceBackendVersion(try decodeData())
        case .channelOptionsUpdate:
          self.data = .__undocumented
        case .clientFlags:
          self.data = .clientFlags(try decodeData())
        case .clientPlatform:
          self.data = .clientPlatform(try decodeData())
        case .davePrepareTransition:
          self.data = .davePrepareTransition(try decodeData())
        case .daveExecuteTransition:
          self.data = .daveExecuteTransition(try decodeData())
        case .davePrepareEpoch:
          self.data = .davePrepareEpoch(try decodeData())
        case .mlsExternalSender, .mlsProposals, .mlsAnnounceCommitTransition,
          .mlsWelcome:
          print(
            "Received an opcode \(opcode.description) that is supposed to be binary, but it came as JSON."
          )
          self.data = .none
          break
        }
      } catch let decodingError {
        // try to decode entire thing as a ByteBuffer, then try to get binary out.
        // https://github.com/Snazzah/davey/blob/master/docs/USAGE.md
        if var buffer = try? ByteBuffer(from: decoder) {
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
            let opcode = Opcode(rawValue: opcode)
          else {
            throw DecodingError.dataCorrupted(
              .init(
                codingPath: [],
                debugDescription:
                  "Expected the 3rd byte of the binary data to be the opcode, but it couldn't be read as UInt8 or didn't match any known opcode."
              )
            )
          }
          self.opcode = opcode

          switch opcode {
          case .mlsExternalSender:
            self.data = .mlsExternalSender(Data(buffer: buffer))
          case .mlsProposals:
            self.data = .mlsProposals(Data(buffer: buffer))
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
            self.data = .mlsAnnounceCommitTransition(
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
            self.data = .mlsWelcome(
              transitionId: transitionId,
              welcome: welcome
            )
          default:
            print(
              "Received an opcode \(opcode.description) that is not expected to be binary, but it came as binary."
            )
            self.data = .none
          }
        } else {
          throw decodingError
        }
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
      case .ready, .sessionDescription, .heartbeatAck, .hello, .resumed,
        .clientConnect, .video, .clientDisconnect:
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

      switch self.data {
      case .none:
        try container.encodeNil(forKey: .data)
      case .identify(let payload):
        try container.encode(payload, forKey: .data)
      case .selectProtocol(let payload):
        try container.encode(payload, forKey: .data)
      case .heartbeat(let payload):
        try container.encode(payload, forKey: .data)
      case .speaking(let payload):
        try container.encode(payload, forKey: .data)
      case .resume(let payload):
        try container.encode(payload, forKey: .data)
      case .sessionUpdate(let payload):
        try container.encode(payload, forKey: .data)
      case .mediaSinkWants(let payload):
        try container.encode(payload, forKey: .data)
      case .voiceBackendVersion(let payload):
        try container.encode(payload, forKey: .data)
      default:
        throw EncodingError.notSupposedToBeSent(
          message: "'\(self)' data is supposed to never be sent."
        )
      }
    }
  }
}
