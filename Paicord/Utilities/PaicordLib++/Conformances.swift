//
//  Conformances.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftProtobuf

extension DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder:
  @retroactive Identifiable
{}

extension Guild: @retroactive Identifiable {}

extension DiscordChannel: @retroactive Identifiable {}

extension Snowflake: @retroactive Identifiable {
  public var id: String { self.rawValue }
}

extension DiscordChannel.Message: @retroactive Identifiable {}

extension DiscordUser: @retroactive Identifiable {}
extension PartialUser: @retroactive Identifiable {}

protocol ActivityData {
  var status: Gateway.Status { get }
  var activities: [Gateway.Activity] { get }
  var hidden_activities: [Gateway.Activity] { get }
}

extension Gateway.PresenceUpdate: ActivityData {}
extension Gateway.Session: ActivityData {}
