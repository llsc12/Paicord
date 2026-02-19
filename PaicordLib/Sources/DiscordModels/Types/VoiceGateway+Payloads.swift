//
//  VoiceGateway+Payloads.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 19/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation

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
    public var ssrc: Int
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
      public var address: String
      public var port: Int
      public var mode: EncryptionMode
    }
  }

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
    case xsalsa20_poly1305_lit
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
}
