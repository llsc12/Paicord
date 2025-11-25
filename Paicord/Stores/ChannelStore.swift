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
  var reactions: [MessageSnowflake: Reactions] = [:]
  var burstReactions: [MessageSnowflake: Reactions] = [:]
  // number of reactions per emoji per message, since message fetch wont return users
  // as there could be thousands.
  var buffReactions: [MessageSnowflake: BuffReactions] = [:]
  var buffBurstReactions: [MessageSnowflake: BuffReactions] = [:]
  
  typealias Reactions = OrderedDictionary<Emoji, Set<UserSnowflake>>
  typealias BuffReactions = OrderedDictionary<Emoji, Int>
  
  var typingTimeoutTokens: [UserSnowflake: UUID] = [:]

  // MARK: - State Properties
  var isLoadingMessages = false
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

  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }
    Task { @MainActor in
      // ig also fetch latest messages too

      defer {
        NotificationCenter.default.post(
          name: .chatViewShouldScrollToBottom,
          object: ["channelId": channelId]
        )
      }
      
      do {
        try await self.fetchMessages()
      } catch {
        PaicordAppState.instances.first?.value.error = error
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
        // reactions
        case .messageReactionAdd(let reactionAdd):
          guard guildStore?.guildId == reactionAdd.guild_id else { continue }
          if reactionAdd.channel_id == channelId {
            handleMessageReactionAdd(reactionAdd)
          }
        case .messageReactionAddMany(let reactionAddMany):
          guard guildStore?.guildId == reactionAddMany.guild_id else {
            continue
          }
          if reactionAddMany.channel_id == channelId {
            handleMessageReactionAddMany(reactionAddMany)
          }
        case .messageReactionRemove(let reactionRemove):
          guard guildStore?.guildId == reactionRemove.guild_id else { continue }
          if reactionRemove.channel_id == channelId {
            handleMessageReactionRemove(reactionRemove)
          }
        case .messageReactionRemoveAll(let removeAll):
          guard guildStore?.guildId == removeAll.guild_id else { continue }
          if removeAll.channel_id == channelId {
            handleMessageReactionRemoveAll(removeAll)
          }
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

  // MARK: - Event Handlers
  private func handleChannelUpdate(_ updatedChannel: DiscordChannel) {
    channel = updatedChannel
  }

  private func handleChannelDelete(_ deletedChannel: DiscordChannel) {
    // Channel was deleted, clear all data
    messages.removeAll()
    typingTimeoutTokens.removeAll()
    channel = nil
  }

  private func handleMessageCreate(_ messageData: Gateway.MessageCreate) {
    defer {
      NotificationCenter.default.post(
        name: .chatViewShouldScrollToBottom,
        object: ["channelId": channelId]
      )
    }
    
    let message = messageData.toMessage()
    // Insert the new message at the end of the ordered dictionary
    messages.updateValue(
      message,
      forKey: message.id,
      insertingAt: messages.count
    )

    // Remove typing indicator for this user
    if let userId = message.author?.id {
      typingTimeoutTokens.removeValue(forKey: userId)
    }
    
    // store user data in user cache
    for mention in messageData.mentions {
      let user = mention.toPartialUser()
      gateway?.user.users[user.id, default: user].update(with: user)
    }

    // Update channel's last message id if we have the channel
    guard var currentChannel = channel else { return }
    currentChannel.last_message_id = message.id
    channel = currentChannel

    // Update guild member info if we have a guild store
    if let guildStore, let authorId = message.author?.id,
      let member = message.member
    {
      guildStore.members[authorId, default: member].update(with: member)
    }
    
    // Get unknown member data from mentions if we have a guild store
    if let guildStore {
      var unknownMemberIds: Set<UserSnowflake> = []
      for mention in messageData.mentions {
        if guildStore.members[mention.id] == nil {
          unknownMemberIds.insert(mention.id)
        }
      }
      if !unknownMemberIds.isEmpty {
        print(
          "[ChannelStore] Requesting \(unknownMemberIds.count) unknown members in guild \(guildStore.guildId.rawValue)"
        )
        Task { @MainActor in
          await guildStore.requestMembers(for: unknownMemberIds)
        }
      }
    }
  }

  private func handleMessageUpdate(
    _ partialMessage: DiscordChannel.PartialMessage
  ) {
    defer {
      NotificationCenter.default.post(
        name: .chatViewShouldScrollToBottom,
        object: ["channelId": channelId]
      )
    }
    
    guard var msg = messages[partialMessage.id] else { return }
    msg.update(with: partialMessage)
    messages.updateValue(msg, forKey: msg.id)
    
    // store user data in user cache
    for mention in partialMessage.mentions ?? [] {
      let user = mention.toPartialUser()
      gateway?.user.users[user.id, default: user].update(with: user)
    }
    
    // check for unknown member data from mentions if we have a guild store
    if let guildStore {
      var unknownMemberIds: Set<UserSnowflake> = []
      for mention in partialMessage.mentions ?? [] {
        if guildStore.members[mention.id] == nil {
          unknownMemberIds.insert(mention.id)
        }
      }
      if !unknownMemberIds.isEmpty {
        print(
          "[ChannelStore] Requesting \(unknownMemberIds.count) unknown members in guild \(guildStore.guildId.rawValue)"
        )
        Task { @MainActor in
          await guildStore.requestMembers(for: unknownMemberIds)
        }
      }
    }
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

  private func handleMessageReactionAdd(
    _ reactionAdd: Gateway.MessageReactionAdd
  ) {
    defer {
      NotificationCenter.default.post(
        name: .chatViewShouldScrollToBottom,
        object: ["channelId": channelId]
      )
    }
    
    if let member = reactionAdd.member?.toPartialMember(), let guildStore,
      let userId = member.user?.id
    {
      // Update guild member info
      guildStore.members[userId, default: member].update(with: member)
    }
    func addToReactionsList(
      reactions: inout [MessageSnowflake: Reactions]
    ) {
      // reactions for message id, creating dict if needed, then set of users for emoji, creating set if needed, inserting user id.
      reactions[reactionAdd.message_id, default: [:]][
        reactionAdd.emoji,
        default: []
      ].insert(reactionAdd.user_id)
    }
    if reactionAdd.burst == true {
      addToReactionsList(reactions: &burstReactions)
    } else {
      addToReactionsList(reactions: &reactions)
    }
  }
  private func handleMessageReactionAddMany(
    _ reactionAddMany: Gateway.MessageReactionAddMany
  ) {
    // reactions for message id, creating dict if needed, then set of users for emoji, creating set if needed, inserting user ids.
    for reaction in reactionAddMany.reactions {
      for user in reaction.users {
        reactions[reactionAddMany.message_id, default: [:]][
          reaction.emoji,
          default: []
        ].insert(user)
      }
    }
  }
  private func handleMessageReactionRemove(
    _ reactionRemove: Gateway.MessageReactionRemove
  ) {
    reactions[reactionRemove.message_id]?[reactionRemove.emoji]?.remove(
      reactionRemove.user_id
    )
    pruneReactions()
  }
  private func handleMessageReactionRemoveEmoji(
    _ reactionRemoveEmoji: Gateway.MessageReactionRemoveEmoji
  ) {
    reactions[reactionRemoveEmoji.message_id]?.removeValue(
      forKey: reactionRemoveEmoji.emoji
    )
    pruneReactions()
  }
  private func handleMessageReactionRemoveAll(
    _ removeAll: Gateway.MessageReactionRemoveAll
  ) {
    reactions.removeValue(forKey: removeAll.message_id)
    pruneReactions()
  }

  private func handleTypingStart(_ typing: Gateway.TypingStart) {
    let userId = typing.user_id
    guard !checkUserBlocked(userId) else { return }
    guard gateway?.user.currentUser?.id != userId else { return }

    let token = UUID()
    typingTimeoutTokens[userId] = token

    Task { [weak self] in
      try? await Task.sleep(nanoseconds: 10_000_000_000)

      if self?.typingTimeoutTokens[userId] == token {
        self?.typingTimeoutTokens.removeValue(forKey: userId)
      }
    }
  }

  private func handleChannelPinsUpdate(_ pinsUpdate: Gateway.ChannelPinsUpdate)
  {
    // Update channel's last pin timestamp if we have the channel
    guard var currentChannel = channel else { return }
    currentChannel.last_pin_timestamp = pinsUpdate.last_pin_timestamp
    channel = currentChannel
  }

  // MARK: - Helpers
  
  func checkUserBlocked(_ userId: UserSnowflake) -> Bool {
    if let relationship = gateway?.user.relationships[userId] {
      if relationship.type == .blocked || relationship.user_ignored {
        return true
      }
    }
    return false
  }
  
  /// Look at reactions and remove any with zero users.
  func pruneReactions() {
    func prune(reactions: inout [MessageSnowflake: Reactions]) {
      for (messageId, emojiDict) in reactions {
        var prunedEmojiDict = emojiDict
        for (emoji, userSet) in emojiDict {
          if userSet.isEmpty {
            prunedEmojiDict.removeValue(forKey: emoji)
          }
        }
        if prunedEmojiDict.isEmpty {
          reactions.removeValue(forKey: messageId)
        } else {
          reactions[messageId] = prunedEmojiDict
        }
      }
    }
    
    prune(reactions: &reactions)
    prune(reactions: &burstReactions)
  }

  /// Fetches messages.
  /// NOTE: `around`, `before` and `after` are mutually exclusive.
  func fetchMessages(
    around: MessageSnowflake? = nil,
    before: MessageSnowflake? = nil,
    after: MessageSnowflake? = nil,
    limit: Int? = nil
  ) async throws {
    #warning("make this handle pagination etc maybe?")
    guard let gateway = gateway?.gateway else { return }
    self.isLoadingMessages = true
    defer { self.isLoadingMessages = false }
    let res = try await gateway.client.listMessages(channelId: channelId)
    do {
      // ensure request was successful
      try res.guardSuccess()
      let messages = try res.decode()
      for message in messages.reversed() {
        self.messages[message.id] = message
      }
      
      // populate buffreactions etc
//      for message in messages {
//        if let reactionList = message.reactions {
//          for reaction in reactionList {
//            if reaction
//            self.buffReactions[message.id, default: [:]][
//              reaction.emoji
//            ] = reaction.count
//          }
//        }
//      }
      
      // cache user data from mentions in user cache
      for message in messages {
        for mention in message.mentions {
          let user = mention.toPartialUser()
          self.gateway?.user.users[user.id, default: user].update(with: user)
        }
      }
      
      // lastly request members if member data for any author is missing, also mentions
      if let guildStore {
        let unknownMembers = Set(messages.map { message in
          ([message.author?.id] + message.mentions.map(\.id)).compactMap({ $0 })
        }.flatMap({ $0 }).filter({
          guildStore.members[$0] == nil
        }))
        if !unknownMembers.isEmpty {
          print(
            "[ChannelStore] Requesting \(unknownMembers.count) unknown members in guild \(guildStore.guildId.rawValue)"
          )
          await guildStore.requestMembers(for: unknownMembers)
        }
      }
    } catch {
      if let error = res.asError() {
        PaicordAppState.instances.first?.value.error = error
      } else {
        PaicordAppState.instances.first?.value.error = error
      }
    }
  }

  /// Checks message storage for a message before the provided message.
  func getMessage(
    before message: DiscordChannel.Message
  ) -> DiscordChannel.Message? {
    guard let index = messages.index(forKey: message.id), index > 0 else {
      return nil
    }
    return messages.elements[safe: index - 1]?.value
  }
}
