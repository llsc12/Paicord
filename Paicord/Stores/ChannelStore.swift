//
//  ChannelStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
class ChannelStore: DiscordDataStore {
	// MARK: - Protocol Properties
	var gateway: (any GatewayManager)?
	var eventTask: Task<Void, Never>?
	
	// MARK: - Channel Properties
	let channelId: ChannelSnowflake
	var channel: DiscordChannel?
	var messages: [MessageSnowflake: DiscordChannel.Message] = [:]
	var typingUsers: [UserSnowflake: Date] = [:]
	var messageHistory: [MessageSnowflake] = [] // Ordered list for display
	
	// MARK: - State Properties
	var isLoadingHistory = false
	var hasMoreHistory = true
	var lastReadMessageId: MessageSnowflake?
	
	init(id: ChannelSnowflake) {
		self.channelId = id
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
				case .channelUpdate(let updatedChannel):
					if updatedChannel.id == channelId {
						handleChannelUpdate(updatedChannel)
					}
					
				case .channelDelete(let deletedChannel):
					if deletedChannel.id == channelId {
						handleChannelDelete(deletedChannel)
					}
					
				case .messageCreate(let messageData):
					if messageData.channel_id == channelId {
						handleMessageCreate(messageData)
					}
					
				case .messageUpdate(let partialMessage):
					if partialMessage.channel_id == channelId {
						handleMessageUpdate(partialMessage)
					}
					
				case .messageDelete(let messageDelete):
					if messageDelete.channel_id == channelId {
						handleMessageDelete(messageDelete)
					}
					
				case .messageDeleteBulk(let bulkDelete):
					if bulkDelete.channel_id == channelId {
						handleMessageDeleteBulk(bulkDelete)
					}
//				case .messageReactionAdd(let reactionAdd):
//					if reactionAdd.channel_id == channelId {
//						handleMessageReactionAdd(reactionAdd)
//					}
//					
//				case .messageReactionRemove(let reactionRemove):
//					if reactionRemove.channel_id == channelId {
//						handleMessageReactionRemove(reactionRemove)
//					}
//					
//				case .messageReactionRemoveAll(let removeAll):
//					if removeAll.channel_id == channelId {
//						handleMessageReactionRemoveAll(removeAll)
//					}
//					
//				case .typingStart(let typing):
//					if typing.channel_id == channelId {
//						handleTypingStart(typing)
//					}
					
				case .channelPinsUpdate(let pinsUpdate):
					if pinsUpdate.channel_id == channelId {
						handleChannelPinsUpdate(pinsUpdate)
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
	private func handleChannelUpdate(_ updatedChannel: DiscordChannel) {
		channel = updatedChannel
	}
	
	private func handleChannelDelete(_ deletedChannel: DiscordChannel) {
		// Channel was deleted, clear all data
		messages.removeAll()
		messageHistory.removeAll()
		typingUsers.removeAll()
		channel = nil
	}
	
	private func handleMessageCreate(_ messageData: Gateway.MessageCreate) {
		let message = messageData.toMessage()
		messages[message.id] = message
		
		// Insert message in correct chronological position
		if let insertIndex = messageHistory.firstIndex(where: { messageId in
			guard let existingMessage = messages[messageId] else { return false }
			return message.timestamp < existingMessage.timestamp
		}) {
			messageHistory.insert(message.id, at: insertIndex)
		} else {
			messageHistory.append(message.id)
		}
		
		// Remove typing indicator for this user
		if let userId = message.author?.id {
			typingUsers.removeValue(forKey: userId)
		}
	}
	
	private func handleMessageUpdate(_ partialMessage: DiscordChannel.PartialMessage) {
		guard let existingMessage = messages[partialMessage.id] else { return }
		
		// Update the existing message with new data
		var updatedMessage = existingMessage
		if let content = partialMessage.content {
			updatedMessage.content = content
		}
		if let editedTimestamp = partialMessage.edited_timestamp {
			updatedMessage.edited_timestamp = editedTimestamp
		}
		if let embeds = partialMessage.embeds {
			updatedMessage.embeds = embeds
		}
		if let attachments = partialMessage.attachments {
			updatedMessage.attachments = attachments
		}
		
		messages[partialMessage.id] = updatedMessage
	}
	
	private func handleMessageDelete(_ messageDelete: Gateway.MessageDelete) {
		messages.removeValue(forKey: messageDelete.id)
		messageHistory.removeAll { $0 == messageDelete.id }
	}
	
	private func handleMessageDeleteBulk(_ bulkDelete: Gateway.MessageDeleteBulk) {
		for messageId in bulkDelete.ids {
			messages.removeValue(forKey: messageId)
			messageHistory.removeAll { $0 == messageId }
		}
	}
	
//	private func handleMessageReactionAdd(_ reactionAdd: Gateway.MessageReactionAdd) {
//	}
	
//	private func handleMessageReactionRemove(_ reactionRemove: Gateway.MessageReactionRemove) {
//	}
	
//	private func handleMessageReactionRemoveAll(_ removeAll: Gateway.MessageReactionRemoveAll) {
//	}
	
//	private func handleTypingStart(_ typing: Gateway.TypingStart) {
//	}
	
	private func handleChannelPinsUpdate(_ pinsUpdate: Gateway.ChannelPinsUpdate) {
		// Update channel's last pin timestamp if we have the channel
		guard var currentChannel = channel else { return }
		currentChannel.last_pin_timestamp = pinsUpdate.last_pin_timestamp
		channel = currentChannel
	}
}
