//
//  Soundboard.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 09/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Foundation

public struct SoundboardSound: Sendable, Codable {
	public var sound_id: SoundSnowflake
	public var name: String
	public var volume: Double
	public var emoji_id: EmojiSnowflake?
	public var emoji_name: String?
	public var guild_id: GuildSnowflake
	public var available: Bool
	public var user: PartialUser?
	public var user_id: UserSnowflake?
}
