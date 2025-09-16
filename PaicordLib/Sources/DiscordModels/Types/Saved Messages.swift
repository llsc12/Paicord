//
//  Saved Messages.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 07/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

/// https://docs.discord.food/resources/user#saved-message-structure
public struct SavedMessage: Sendable, Codable {
	public var message: Gateway.MessageCreate?
	public var save_data: SaveData
	
	public struct SaveData: Sendable, Codable {
		public var channel_id: ChannelSnowflake
		public var message_id: MessageSnowflake
		public var guild_id: GuildSnowflake?
		public var saved_at: DiscordTimestamp
		public var author_summary: String
		public var channel_summary: String
		public var message_summary: String
		public var notes: String
		public var due_at: DiscordTimestamp?
	}
}
