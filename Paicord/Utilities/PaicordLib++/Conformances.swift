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

extension Guild: @retroactive Identifiable {}

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
  var height: Int? { get }
  var width: Int? { get }
  var placeholder: String? { get }
  var content_type: String? { get }
}

extension Embed.Media: DiscordMedia {
  var proxyurl: String {
    self.proxy_url ?? self.url.asString
  }
}
extension DiscordChannel.Message.Attachment: DiscordMedia {
  var proxyurl: String {
    self.proxy_url
  }
}

extension DiscordMedia {
  var type: UTType {
    if let mimeType = content_type, let type = UTType(mimeType: mimeType) {
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
}


extension Payloads.CreateMessage: @retroactive Identifiable {
  public var id: MessageSnowflake {
    .init(self.nonce?.asString ?? "unknown")
  }
}
