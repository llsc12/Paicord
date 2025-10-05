//
//  CurrentUserStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
class CurrentUserStore: DiscordDataStore {
	// MARK: - Protocol Properties
	var gateway: (any GatewayManager)?
	var eventTask: Task<Void, Never>?

	// MARK: - State Properties
	var currentUser: DiscordUser?
	var guilds: [GuildSnowflake: Guild] = [:]
	var privateChannels: [ChannelSnowflake: DiscordChannel] = [:]
	var relationships: [DiscordRelationship] = []

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
				case .ready(let readyData):
					handleReady(readyData)

				case .userUpdate(let user):
					handleUserUpdate(user)

				case .guildCreate(let guildData):
					handleGuildCreate(guildData)

				case .guildDelete(let unavailableGuild):
					handleGuildDelete(unavailableGuild)

				case .relationshipAdd(let relationship):
					handleRelationshipAdd(relationship)

				case .relationshipUpdate(let partialRelationship):
					handleRelationshipUpdate(partialRelationship)

				case .relationshipRemove(let partialRelationship):
					handleRelationshipRemove(partialRelationship)

				case .channelCreate(let channel):
					if channel.type == .dm || channel.type == .groupDm {
						handlePrivateChannelCreate(channel)
					}

				case .channelDelete(let channel):
					if channel.type == .dm || channel.type == .groupDm {
						handlePrivateChannelDelete(channel)
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
	private func handleReady(_ readyData: Gateway.Ready) {
		currentUser = readyData.user
		guilds = readyData.guilds.reduce(into: [:]) { dict, guild in
			dict[guild.id] = guild
		}
		privateChannels = readyData.private_channels.reduce(into: [:]) {
			dict,
			channel in
			dict[channel.id] = channel
		}
		relationships = readyData.relationships
	}

	private func handleUserUpdate(_ user: DiscordUser) {
		guard user.id == currentUser?.id else { return }
		currentUser = user
	}

	private func handleGuildCreate(_ guild: Gateway.GuildCreate) {
		guilds[guild.id] = guild.toGuild()
	}

	private func handleGuildDelete(_ unavailableGuild: UnavailableGuild) {
		guilds.removeValue(forKey: unavailableGuild.id)
	}

	private func handleRelationshipAdd(_ relationship: DiscordRelationship) {
		if let index = relationships.firstIndex(where: { $0.id == relationship.id })
		{
			relationships[index] = relationship
		} else {
			relationships.append(relationship)
		}
	}

	private func handleRelationshipUpdate(
		_ partialRelationship: Gateway.PartialRelationship
	) {
		if let index = relationships.firstIndex(where: {
			$0.id == partialRelationship.id
		}) {
			// Update the existing relationship with new data
			var updatedRelationship = relationships[index]
			updatedRelationship.type = partialRelationship.type
			relationships[index] = updatedRelationship
		}
	}

	private func handleRelationshipRemove(
		_ partialRelationship: Gateway.PartialRelationship
	) {
		relationships.removeAll { $0.id == partialRelationship.id }
	}

	private func handlePrivateChannelCreate(_ channel: DiscordChannel) {
		privateChannels[channel.id] = channel
	}

	private func handlePrivateChannelDelete(_ channel: DiscordChannel) {
		privateChannels.removeValue(forKey: channel.id)
	}

	//	/// Updates the current user's presence
	//	func updatePresence(status: Gateway.Identify.Presence.Status, customStatus: String? = nil) async {
	//		fatalError("Not implemented")
	//	}
	//
	//	/// Updates user settings
	//	func updateSettings(_ settings: Gateway.Ready.UserSettings) async {
	//		fatalError("Not implemented")
	//	}
	//
	//	/// Sends a friend request
	//	func sendFriendRequest(to username: String, discriminator: String) async throws {
	//		fatalError("Not implemented")
	//	}
	//
	//	/// Accepts a friend request
	//	func acceptFriendRequest(_ relationshipId: UserSnowflake) async throws {
	//		fatalError("Not implemented")
	//	}
	//
	//	/// Removes a friend or blocks a user
	//	func removeRelationship(_ relationshipId: UserSnowflake) async throws {
	//		fatalError("Not implemented")
	//	}
	//
	//	/// Creates a new DM channel
	//	func createDMChannel(with userId: UserSnowflake) async throws -> DiscordChannel {
	//		fatalError("Not implemented")
	//	}
}
