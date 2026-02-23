//
//  VoiceGateway+Payloads.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 19/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation
import DaveKit

extension VoiceGateway {

  /// https://docs.discord.food/topics/voice-connections#identify-structure
  public struct Identify: Sendable, Codable {
    public init(
      server_id: GuildSnowflake,
      channel_id: ChannelSnowflake,
      user_id: UserSnowflake,
      session_id: String,
      token: Secret,
      video: Bool? = nil,
      streams: [Stream]? = nil
    ) {
      self.server_id = server_id
      self.channel_id = channel_id
      self.user_id = user_id
      self.session_id = session_id
      self.token = token
      self.video = video
      self.streams = streams
    }

    public var max_dave_protocol_version: Int = .init(DaveSessionManager.maxSupportedProtocolVersion())
    public var server_id: GuildSnowflake
    public var channel_id: ChannelSnowflake
    public var user_id: UserSnowflake
    public var session_id: String
    public var token: Secret
    public var video: Bool?
    public var streams: [Stream]?
  }

  /// https://docs.discord.food/topics/voice-connections#stream-structure
  public struct Stream: Sendable, Codable {
    public init(
      type: Kind,
      rid: String,
      quality: Int? = nil,
      active: Bool? = nil,
      max_bitrate: Int? = nil,
      max_framerate: Int? = nil,
      max_resolution: StreamResolution? = nil
    ) {
      self.type = type
      self.rid = rid
      self.quality = quality
      self.active = active
      self.max_bitrate = max_bitrate
      self.max_framerate = max_framerate
      self.max_resolution = max_resolution
    }

    public var type: Kind
    public var rid: String
    public var quality: Int?
    public var active: Bool?
    public var max_bitrate: Int?
    public var max_framerate: Int?
    public var max_resolution: StreamResolution?

    @UnstableEnum<String>
    public enum Kind: Sendable, Codable {
      case audio
      case video
      case screen
      case speedtest  // test
      case __undocumented(String)
    }

    /// https://docs.discord.food/topics/voice-connections#stream-resolution-structure
    public struct StreamResolution: Sendable, Codable {
      public init(type: Kind, width: Int, height: Int) {
        self.type = type
        self.width = width
        self.height = height
      }

      public var type: Kind
      public var width: Int
      public var height: Int

      @UnstableEnum<String>
      public enum Kind: Sendable, Codable {
        case fixed
        case source
        case __undocumented(String)
      }
    }
  }

  /// https://docs.discord.food/topics/voice-connections#ready-structure
  public struct Ready: Sendable, Codable {
    public var ssrc: UInt32
    public var ip: String
    public var port: Int
    public var modes: [EncryptionMode]
    public var experiments: [String]
    public var streams: [Stream]
  }

  /// https://docs.discord.food/topics/voice-connections#select-protocol-structure
  public struct SelectProtocol: Sendable, Codable {
    public init(
      protocol: String,
      data: ProtocolData,
      rtc_connection_id: String? = nil,
      codecs: [Codec]? = nil,
      experiments: [String]? = nil
    ) {
      self.protocol = `protocol`
      self.data = data
      self.rtc_connection_id = rtc_connection_id
      self.codecs = codecs
      self.experiments = experiments
    }

    public var `protocol`: String
    public var data: ProtocolData
    public var rtc_connection_id: String?
    public var codecs: [Codec]?
    public var experiments: [String]?

    /// https://docs.discord.food/topics/voice-connections#protocol-data-structure
    public struct ProtocolData: Sendable, Codable {
      public init(address: String, port: Int, mode: EncryptionMode) {
        self.address = address
        self.port = port
        self.mode = mode
      }
      
      public var address: String
      public var port: Int
      public var mode: EncryptionMode
    }
  }

  /// https://docs.discord.food/topics/voice-connections#encryption-mode
  @UnstableEnum<String>
  public enum EncryptionMode: Sendable, Codable {
    // preferred
    case aead_aes256_gcm_rtpsize
    // required
    case aead_xchacha20_poly1305_rtpsize
    // optional, deprecated
    case xsalsa20_poly1305_lite_rtpsize
    case aead_aes256_gcm
    case xsalsa20_poly1305
    case xsalsa20_poly1305_suffix
    case xsalsa20_poly1305_lite
    case __undocumented(String)
  }

  /// https://docs.discord.food/topics/voice-connections#codec-structure
  public struct Codec: Sendable, Codable {
    public var name: CodecName
    public var type: String
    public var priority: Int
    public var payload_type: Int
    public var rtx_payload_type: Int?
    public var encode: Bool?
    public var decode: Bool?

    public static let opusCodec = Codec(
      name: .opus,
      type: "audio",
      priority: 1000,
      payload_type: 120,
      rtx_payload_type: nil,
      encode: nil,
      decode: nil
    )

    public static let h265Codec = Codec(
      name: .h265,
      type: "video",
      priority: 2000,
      payload_type: 103,
      rtx_payload_type: 104,
      encode: true,
      decode: true
    )

    public static let h264Codec = Codec(
      name: .h264,
      type: "video",
      priority: 3000,
      payload_type: 105,
      rtx_payload_type: 106,
      encode: true,
      decode: true
    )

    @UnstableEnum<String>
    public enum CodecName: Sendable, Codable {
      case opus
      case av1  // AV1
      case h265  // H265
      case h264  // H264
      case vp8  // VP8
      case vp9  // VP9
      case __undocumented(String)
    }
  }

  /// https://docs.discord.food/topics/voice-connections#session-description-structure
  public struct SessionDescription: Sendable, Codable {
    public var audio_codec: Codec.CodecName
    public var video_codec: Codec.CodecName
    public var media_session_id: String
    public var mode: EncryptionMode?
    public var secretKey: [UInt8]
    public var daveProtocolVersion: UInt16
    public var sdp: String?  // not applicable to udp
    public var keyframe_interval: Int?  // not applicable to udp
  }

  /// https://docs.discord.food/topics/voice-connections#session-update-structure-(send)
  /// https://docs.discord.food/topics/voice-connections#session-update-structure-(receive)
  public struct SessionUpdate: Sendable, Codable {
    // send properties
    public var codecs: [Codec]?

    // receive properties
    public var audio_codec: Codec.CodecName?
    public var video_codec: Codec.CodecName?
    public var media_session_id: String?
    public var keyframe_interval: Int?  // not applicable to udp
  }

  /// https://docs.discord.food/topics/voice-connections#hello-structure
  public struct Hello: Sendable, Codable {
    public var heartbeat_interval: Int
    public var v: Int
  }

  /// https://docs.discord.food/topics/voice-connections#heartbeat-structure
  public struct Heartbeat: Sendable, Codable {
    public init(seq_ack: Int? = nil) {
      self.seq_ack = seq_ack
    }
    public init(t: UInt, seq_ack: Int? = nil) {
      self.t = t
      self.seq_ack = seq_ack
    }

    public var t: UInt = UInt(Date.now.timeIntervalSince1970)
    public var seq_ack: Int? = nil
  }

  /// https://docs.discord.food/topics/voice-connections#speaking-structure
  public struct Speaking: Sendable, Codable {
    public init(speaking: IntBitField<Flag>, ssrc: UInt, delay: UInt? = nil) {
      self.speaking = speaking
      self.ssrc = ssrc
      self.delay = delay
    }
    
    public var speaking: IntBitField<Flag>
    public var ssrc: UInt
    // present on receive
    public var user_id: UserSnowflake?

    // send only
    public var delay: UInt? = nil

    #if Non64BitSystemsCompatibility
      @UnstableEnum<UInt64>
    #else
      @UnstableEnum<UInt>
    #endif
    public enum Flag: Sendable, Codable {
      case voice  // 0
      case soundshare  // 1
      case priority  // 2

      #if Non64BitSystemsCompatibility
        case __undocumented(UInt64)
      #else
        case __undocumented(UInt)
      #endif
    }
  }

  /// https://docs.discord.food/topics/voice-connections#resume-structure
  public struct Resume: Sendable, Codable {
    public init(
      server_id: GuildSnowflake,
      channel_id: ChannelSnowflake,
      session_id: String,
      token: Secret,
      seq_ack: Int? = nil
    ) {
      self.server_id = server_id
      self.channel_id = channel_id
      self.session_id = session_id
      self.token = token
      self.seq_ack = seq_ack
    }

    public var server_id: GuildSnowflake
    public var channel_id: ChannelSnowflake
    public var session_id: String
    public var token: Secret
    public var seq_ack: Int?
  }

  /// https://docs.discord.food/topics/voice-connections#example-client-connect
  public struct ClientConnect: Sendable, Codable {
    public var user_ids: [UserSnowflake]
  }

  /// https://docs.discord.food/topics/voice-connections#client-flags-structure
  public struct ClientFlags: Sendable, Codable {
    public var user_id: UserSnowflake
    public var flags: IntBitField<VoiceStateUpdate.Flags>
  }

  /// https://docs.discord.food/topics/voice-connections#voice-platform
  public struct ClientPlatform: Sendable, Codable {
  }

  /// https://docs.discord.food/topics/voice-connections#client-disconnect-structure
  public struct ClientDisconnect: Sendable, Codable {
    public var user_id: UserSnowflake
  }

  /// https://docs.discord.food/topics/voice-connections#video-structure
  public struct Video: Sendable, Codable {
    public var audio_ssrc: UInt
    public var video_ssrc: UInt
    public var rtx_ssrc: UInt
    public var streams: [Stream]?  // sent by client only
    public var user_id: UserSnowflake?  // sent by server only
  }

  /// https://docs.discord.food/topics/voice-connections#example-media-sink-wants
  public struct MediaSinkWants: Sendable, Codable {
    public var pixelCounts: [String: Double]?
    public var ssrcs: [String: Int]

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
      var pixelCounts: [String: Double] = [:]
      var ssrcs: [String: Int] = [:]
      for key in container.allKeys {
        if key.stringValue == "pixelCounts" {
          pixelCounts = try container.decode([String: Double].self, forKey: key)
        } else {
          let value = try container.decode(Int.self, forKey: key)
          ssrcs[key.stringValue] = value
        }
      }
      self.pixelCounts = pixelCounts
      self.ssrcs = ssrcs
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: DynamicCodingKeys.self)
      try container.encode(pixelCounts, forKey: .pixelCounts)
      for (key, value) in ssrcs {
        try container.encode(value, forKey: .dynamic(key))
      }
    }

    public init(
      ssrcs: [String: Int],
      pixelCounts: [String: Double]?
    ) {
      self.pixelCounts = pixelCounts
      self.ssrcs = ssrcs
    }

    private enum DynamicCodingKeys: CodingKey {
      case pixelCounts
      case dynamic(String)

      init?(stringValue: String) {
        if stringValue == "pixelCounts" {
          self = .pixelCounts
        } else {
          self = .dynamic(stringValue)
        }
      }

      var stringValue: String {
        switch self {
        case .pixelCounts:
          return "pixelCounts"
        case .dynamic(let key):
          return key
        }
      }

      init?(intValue: Int) {
        return nil
      }

      var intValue: Int? {
        return nil
      }
    }
  }

  /// https://docs.discord.food/topics/voice-connections#voice-backend-version-structure
  public struct VoiceBackendVersion: Sendable, Codable {
    public var voice: String
    public var rtc_worker: String
  }

  public struct DavePrepareTransition: Sendable, Codable {
    public var transitionId: UInt16
    public var protocolVersion: UInt16
  }

  public struct DaveCommitTransition: Sendable, Codable {
    public var transitionId: UInt16
  }

  public struct DavePrepareEpoch: Sendable, Codable {
    public var epoch: UInt32
    public var protocolVersion: UInt16
  }

  public struct DaveTransitionReady: Sendable, Codable {
    public init(transitionId: UInt16) {
      self.transitionId = transitionId
    }

    public var transitionId: UInt16
  }

  public struct DaveMLSInvalidCommitWelcome: Sendable, Codable {
    public init(transitionId: UInt16) {
      self.transitionId = transitionId
    }

    public var transitionId: UInt16
  }
}
