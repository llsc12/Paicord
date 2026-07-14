//
//  Conformances.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftProtobuf
import UniformTypeIdentifiers

extension DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder:
  @retroactive Identifiable
{}

extension DiscordChannel: @retroactive Identifiable {}

extension Snowflake: @retroactive Identifiable {
  public var id: String { self.rawValue }
}

extension DiscordChannel.Message: @retroactive Identifiable {}

protocol ActivityData {
  var status: Gateway.Status { get }
  var activities: [Gateway.Activity] { get }
  var hidden_activities: [Gateway.Activity]? { get }
}

extension Gateway.PresenceUpdate: ActivityData {}
extension Gateway.Session: ActivityData {}

extension DiscordUser: @retroactive Identifiable {}
extension PartialUser: @retroactive Identifiable {}

extension Embed: @retroactive Identifiable {
  public var id: Int {
    self.hashValue
  }
}

protocol DiscordMedia {
  var proxyurl: String { get }
  var cdnURL: String { get }
  var height: Int? { get }
  var width: Int? { get }
  var placeholder: String? { get }
  var content_type: String? { get }
  var isGifv: Bool { get }
}

extension DiscordMedia {
  var isGifv: Bool { false }
}

extension Embed.Media: DiscordMedia {
  var proxyurl: String {
    self.proxy_url ?? self.url.asString
  }
  var cdnURL: String {
    self.url.asString
  }
}
extension DiscordChannel.Message.Attachment: DiscordMedia {
  var proxyurl: String {
    self.proxy_url
  }
  var cdnURL: String {
    self.url
  }
}

struct GifvAttachmentMedia: DiscordMedia {
  let media: Embed.Media

  var proxyurl: String { media.proxyurl }
  var cdnURL: String { media.cdnURL }
  var height: Int? { media.height }
  var width: Int? { media.width }
  var placeholder: String? { media.placeholder }
  var content_type: String? { media.content_type }
  var isGifv: Bool { true }
}

extension DiscordMedia {
  var type: UTType {
    if let mimeType = content_type, let type = UTType(mimeType: mimeType) {
      return type
    } else if let ext = proxyurl.split(separator: ".").last.map(String.init),
      let type = UTType(filenameExtension: String(ext.prefix { $0.isLetter || $0.isNumber }))
    {
      return type
    } else {
      return .data
    }
  }

  var aspectRatio: CGFloat? {
    if let width = self.width, let height = self.height {
      return width.toCGFloat / height.toCGFloat
    } else {
      return nil
    }
  }

  var mediaKind: MediaKind {
    if type.conforms(to: .image) || type.conforms(to: .gif) {
      return .image
    } else if type.conforms(to: .movie) || type.conforms(to: .video) {
      return .video
    } else if type.conforms(to: .audio) {
      return .audio
    } else {
      return .other
    }
  }
}

enum MediaKind {
  case image
  case video
  case audio
  case other

  var isViewableMedia: Bool {
    self != .other
  }
}


extension Payloads.CreateMessage: @retroactive Identifiable {
  public var id: MessageSnowflake {
    .init(self.nonce?.asString ?? "unknown")
  }
}
