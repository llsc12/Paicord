//
//  ChannelStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Algorithms
import Collections
import Foundation
import PaicordLib

@Observable
class ChannelStore: DiscordDataStore {
  @ObservationIgnored
  let guildStore: GuildStore?

  // MARK: - Protocol Properties
  var gateway: GatewayStore?
  var eventTask: Task<Void, Never>?

  // MARK: - Channel Properties
  let channelId: ChannelSnowflake
  var channel: DiscordChannel?
  var messages: OrderedDictionary<MessageSnowflake, DiscordChannel.Message> =
    [:]
  var typingUsers: [UserSnowflake: Date] = [:]

  // MARK: - State Properties
  var isLoadingHistory = false
  var hasMoreHistory = true
  var lastReadMessageId: MessageSnowflake?

  init(
    id: ChannelSnowflake,
    from channel: DiscordChannel? = nil,
    guildStore: GuildStore? = nil
  ) {
    self.channelId = id
    self.channel = channel
    self.guildStore = guildStore
  }

  // MARK: - Protocol Methods
  func setGateway(_ gateway: GatewayStore?) {
    cancelEventHandling()
    self.gateway = gateway
    if gateway != nil {
      setupEventHandling()
    }
  }

  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }
    Task { @MainActor in
      // ig also fetch latest messages too
      do {
        try await self.fetchMessages()
      } catch {
        PaicordAppState.shared.error = error
      }
    }
    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        // Channel updates
        case .channelUpdate(let updatedChannel):
          if updatedChannel.id == channelId {
            handleChannelUpdate(updatedChannel)
          }
        case .channelDelete(let deletedChannel):
          if deletedChannel.id == channelId {
            handleChannelDelete(deletedChannel)
          }
        // messages
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
        case .channelPinsUpdate(let pinsUpdate):
          if pinsUpdate.channel_id == channelId {
            handleChannelPinsUpdate(pinsUpdate)
          }
        //				case .messageReactionAdd(let reactionAdd):
        //					if reactionAdd.channel_id == channelId {
        //						handleMessageReactionAdd(reactionAdd)
        //					}
        //				case .messageReactionRemove(let reactionRemove):
        //					if reactionRemove.channel_id == channelId {
        //						handleMessageReactionRemove(reactionRemove)
        //					}
        //				case .messageReactionRemoveAll(let removeAll):
        //					if removeAll.channel_id == channelId {
        //						handleMessageReactionRemoveAll(removeAll)
        //					}
        // typing
        case .typingStart(let typing):
          if typing.channel_id == channelId {
            handleTypingStart(typing)
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
    typingUsers.removeAll()
    channel = nil
  }

  private func handleMessageCreate(_ messageData: Gateway.MessageCreate) {
    let message = messageData.toMessage()
    // Insert the new message at the end of the ordered dictionary
    messages.updateValue(
      message,
      forKey: message.id,
      insertingAt: messages.count
    )

    // Remove typing indicator for this user
    if let userId = message.author?.id {
      typingUsers.removeValue(forKey: userId)
    }

    // Update channel's last message id if we have the channel
    guard var currentChannel = channel else { return }
    currentChannel.last_message_id = message.id
    channel = currentChannel

    // Update guild member info if we have a guild store
    if let guildStore, let authorId = message.author?.id,
      let msgMember = message.member
    {
      if var member = guildStore.members[authorId] {
        member.update(with: msgMember)
        guildStore.members[authorId] = member
      } else {
        guildStore.members[authorId] = msgMember
      }
    }
  }

  private func handleMessageUpdate(
    _ partialMessage: DiscordChannel.PartialMessage
  ) {
    guard var msg = messages[partialMessage.id] else { return }
    msg.update(with: partialMessage)
    messages.updateValue(msg, forKey: msg.id)
  }

  private func handleMessageDelete(_ messageDelete: Gateway.MessageDelete) {
    messages.removeValue(forKey: messageDelete.id)
  }

  private func handleMessageDeleteBulk(_ bulkDelete: Gateway.MessageDeleteBulk)
  {
    for messageId in bulkDelete.ids {
      messages.removeValue(forKey: messageId)
    }
  }

  //	private func handleMessageReactionAdd(_ reactionAdd: Gateway.MessageReactionAdd) {
  //	}

  //	private func handleMessageReactionRemove(_ reactionRemove: Gateway.MessageReactionRemove) {
  //	}

  //	private func handleMessageReactionRemoveAll(_ removeAll: Gateway.MessageReactionRemoveAll) {
  //	}

  private func handleTypingStart(_ typing: Gateway.TypingStart) {
    typingUsers[typing.user_id] = Date.now
  }

  private func handleChannelPinsUpdate(_ pinsUpdate: Gateway.ChannelPinsUpdate)
  {
    // Update channel's last pin timestamp if we have the channel
    guard var currentChannel = channel else { return }
    currentChannel.last_pin_timestamp = pinsUpdate.last_pin_timestamp
    channel = currentChannel
  }

  // MARK: - Helpers

  // NOTE: `around`, `before` and `after` are mutually exclusive.
  func fetchMessages(
    around: MessageSnowflake? = nil,
    before: MessageSnowflake? = nil,
    after: MessageSnowflake? = nil,
    limit: Int? = nil
  ) async throws {
    #warning("make this handle pagination etc maybe?")
    guard let gateway = gateway?.gateway else { return }
    let res = try await gateway.client.listMessages(channelId: channelId)
    do {
      // ensure request was successful
      try res.guardSuccess()
      let messages = try res.decode()
      for message in messages.reversed() {
        self.messages[message.id] = message
      }
      // lastly request members if member data for any author is missing
      if let guildStore {
        let unknownMembers = Array(
          messages.compactMap(\.author?.id).filter({
            guildStore.members[$0] == nil
          }).uniqued()
        )
        if !unknownMembers.isEmpty {
          print(
            "Requesting \(unknownMembers.count) unknown members in guild \(guildStore.guildId)"
          )
          await guildStore.requestMembers(for: unknownMembers)
        }
      }
    } catch {
      if let error = res.asError() {
        PaicordAppState.shared.error = error
      } else {
        PaicordAppState.shared.error = error
      }
    }
  }

  func getMessage(
    before message: DiscordChannel.Message
  ) -> DiscordChannel.Message? {
    guard let index = messages.index(forKey: message.id), index > 0 else {
      return nil
    }
    return messages.elements[safe: index - 1]?.value
  }
}
