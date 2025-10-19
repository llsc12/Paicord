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

// sadly i need to add this conformance to the declaration itself. im not writing this manually.
//extension DiscordChannel.Message: @retroactive Equatable {
//	public static func == (lhs: DiscordModels.DiscordChannel.Message, rhs: DiscordModels.DiscordChannel.Message) -> Bool {
//		return lhs.id == rhs.id && lhs.content == rhs.content
//	}
//}
