//
//  GuildStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
class GuildStore: DiscordDataStore {
	// MARK: - Protocol Properties
	var gateway: (any GatewayManager)?
	var eventTask: Task<Void, Never>?

	// MARK: - Guild Properties
	let guildId: GuildSnowflake
	var guild: Guild?
	var channels: [ChannelSnowflake: DiscordChannel] = [:]
	var members: [UserSnowflake: Guild.Member] = [:]
	var roles: [RoleSnowflake: Role] = [:]
	var emojis: [EmojiSnowflake: Emoji] = [:]
	var stickers: [StickerSnowflake: Sticker] = [:]
	var presences: [UserSnowflake: Gateway.PresenceUpdate] = [:]
	var voiceStates: [UserSnowflake: VoiceState] = [:]

	// MARK: - State Properties
	var isLoadingMembers = false
	var hasAllMembers = false

	init(id: GuildSnowflake, from guild: Guild?) {
		self.guildId = id
		self.guild = guild
		
		// populate properties based on initial guild data
		guard let guild else { return }
		
		// channels
		guild.channels.forEach { channel in
			channels[channel.id] = channel
		}
		
		// roles
		guild.roles.forEach { role in
			roles[role.id] = role
		}
		
		// emojis
		guild.emojis.forEach { emoji in
			if let id = emoji.id {
				emojis[id] = emoji
			}
		}
		
		// stickers
		guild.stickers?.forEach { sticker in
			stickers[sticker.id] = sticker
		}
	}

	// MARK: - Protocol Methods
	func setGateway(_ gateway: (any GatewayManager)?) {
		cancelEventHandling()
		self.gateway = gateway
		if gateway != nil {
			setupEventHandling()
		}
	}

	func setupEventHandling() {
		guard let gateway = gateway else { return }

		eventTask = Task { @MainActor in
			for await event in await gateway.events {
				switch event.data {
				case .guildUpdate(let updatedGuild):
					if updatedGuild.id == guildId {
						handleGuildUpdate(updatedGuild)
					}

				case .guildDelete(let unavailableGuild):
					if unavailableGuild.id == guildId {
						handleGuildDelete(unavailableGuild)
					}

				case .channelCreate(let channel):
					if channel.guild_id == guildId {
						handleChannelCreate(channel)
					}

				case .channelUpdate(let channel):
					if channel.guild_id == guildId {
						handleChannelUpdate(channel)
					}

				case .channelDelete(let channel):
					if channel.guild_id == guildId {
						handleChannelDelete(channel)
					}

				case .guildMemberAdd(let memberAdd):
					if memberAdd.guild_id == guildId {
						handleGuildMemberAdd(memberAdd)
					}

				case .guildMemberUpdate(let memberUpdate):
					if memberUpdate.guild_id == guildId {
						handleGuildMemberUpdate(memberUpdate)
					}

				case .guildMemberRemove(let memberRemove):
					if memberRemove.guild_id == guildId {
						handleGuildMemberRemove(memberRemove)
					}

				case .guildMembersChunk(let membersChunk):
					if membersChunk.guild_id == guildId {
						handleGuildMembersChunk(membersChunk)
					}

				case .guildRoleCreate(let roleCreate):
					if roleCreate.guild_id == guildId {
						handleGuildRoleCreate(roleCreate)
					}

				case .guildRoleUpdate(let roleUpdate):
					if roleUpdate.guild_id == guildId {
						handleGuildRoleUpdate(roleUpdate)
					}

				case .guildRoleDelete(let roleDelete):
					if roleDelete.guild_id == guildId {
						handleGuildRoleDelete(roleDelete)
					}

				case .guildEmojisUpdate(let emojisUpdate):
					if emojisUpdate.guild_id == guildId {
						handleGuildEmojisUpdate(emojisUpdate)
					}

				case .guildStickersUpdate(let stickersUpdate):
					if stickersUpdate.guild_id == guildId {
						handleGuildStickersUpdate(stickersUpdate)
					}

				case .presenceUpdate(let presence):
					if presence.guild_id == guildId {
						handlePresenceUpdate(presence)
					}

				case .voiceStateUpdate(let voiceState):
					if voiceState.guild_id == guildId {
						handleVoiceStateUpdate(voiceState)
					}

				default:
					break
				}
			}
		}
	}

	func cancelEventHandling() {
		eventTask?.cancel()
		eventTask = nil
	}

	// MARK: - Event Handlers
	private func handleGuildUpdate(_ updatedGuild: Guild) {
		guild = updatedGuild

		// Update cached roles
		let guildRoles = updatedGuild.roles
		roles.removeAll()
		for role in guildRoles {
			roles[role.id] = role
		}

		// Update cached emojis
		let guildEmojis = updatedGuild.emojis
		emojis.removeAll()
		for emoji in guildEmojis {
			if let id = emoji.id {
				emojis[id] = emoji
			}
		}
	}

	private func handleGuildDelete(_ unavailableGuild: UnavailableGuild) {
		// Guild was deleted or became unavailable, clear all data
		guild = nil
		channels.removeAll()
		members.removeAll()
		roles.removeAll()
		emojis.removeAll()
		stickers.removeAll()
		presences.removeAll()
		voiceStates.removeAll()
	}

	private func handleChannelCreate(_ channel: DiscordChannel) {
		channels[channel.id] = channel
	}

	private func handleChannelUpdate(_ channel: DiscordChannel) {
		channels[channel.id] = channel
	}

	private func handleChannelDelete(_ channel: DiscordChannel) {
		channels.removeValue(forKey: channel.id)
	}

	private func handleGuildMemberAdd(_ memberAdd: Gateway.GuildMemberAdd) {
		members[memberAdd.user.id] = memberAdd.toMember()
	}

	private func handleGuildMemberUpdate(_ memberUpdate: Gateway.GuildMemberAdd) {
		members[memberUpdate.user.id] = memberUpdate.toMember()
	}

	private func handleGuildMemberRemove(
		_ memberRemove: Gateway.GuildMemberRemove
	) {
		members.removeValue(forKey: memberRemove.user.id)
	}

	private func handleGuildMembersChunk(
		_ membersChunk: Gateway.GuildMembersChunk
	) {
		// TODO: Handle this
	}

	private func handleGuildRoleCreate(_ roleCreate: Gateway.GuildRole) {
		roles[roleCreate.role.id] = roleCreate.role
	}

	private func handleGuildRoleUpdate(_ roleUpdate: Gateway.GuildRole) {
		roles[roleUpdate.role.id] = roleUpdate.role
	}

	private func handleGuildRoleDelete(_ roleDelete: Gateway.GuildRoleDelete) {
		roles.removeValue(forKey: roleDelete.role_id)
	}

	private func handleGuildEmojisUpdate(
		_ emojisUpdate: Gateway.GuildEmojisUpdate
	) {
		emojis.removeAll()
		for emoji in emojisUpdate.emojis {
			guard let id = emoji.id else { continue }
			emojis[id] = emoji
		}
	}

	private func handleGuildStickersUpdate(
		_ stickersUpdate: Gateway.GuildStickersUpdate
	) {
		stickers.removeAll()
		for sticker in stickersUpdate.stickers {
			stickers[sticker.id] = sticker
		}
	}

	private func handlePresenceUpdate(_ presence: Gateway.PresenceUpdate) {
		presences[presence.user.id] = presence
	}

	private func handleVoiceStateUpdate(_ voiceState: VoiceState) {
		if voiceState.channel_id != nil {
			voiceStates[voiceState.user_id] = voiceState
		} else {
			// User left voice channel
			voiceStates.removeValue(forKey: voiceState.user_id)
		}
	}

	//	/// Gets the member for a user ID
	//	func getMember(for userId: UserSnowflake) -> DiscordGuild.Member? {
	//		return members[userId]
	//	}
	//
	//	/// Gets the role for a role ID
	//	func getRole(for roleId: RoleSnowflake) -> DiscordRole? {
	//		return roles[roleId]
	//	}
	//
	//	/// Gets the channel for a channel ID
	//	func getChannel(for channelId: ChannelSnowflake) -> DiscordChannel? {
	//		return channels[channelId]
	//	}
	//
	//	/// Gets the presence for a user ID
	//	func getPresence(for userId: UserSnowflake) -> Gateway.PresenceUpdate? {
	//		return presences[userId]
	//	}
	//
	//	/// Gets the voice state for a user ID
	//	func getVoiceState(for userId: UserSnowflake) -> Gateway.VoiceState? {
	//		return voiceStates[userId]
	//	}
}
