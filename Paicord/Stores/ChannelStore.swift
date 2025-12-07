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

  var reactions: [MessageSnowflake: OrderedDictionary<Emoji, Reaction>] = [:]

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
    if let user = reactionAdd.member?.user?.toPartialUser(), let gateway {
      // Update user info
      gateway.user.users[user.id, default: user].update(with: user)
    }

    // get the reaction struct for this message and emoji, or create a new one
    guard let message = messages[reactionAdd.message_id] else { return }
    if reactions[reactionAdd.message_id, default: [:]][reactionAdd.emoji] == nil
    {
      // make new object
      let reaction = Reaction(
        message: message,
        messageReactionData: nil,
        gatewayReactionAdd: reactionAdd,
        gatewayReactionAddMany: nil
      )
      reactions[reactionAdd.message_id, default: [:]][reactionAdd.emoji] =
        reaction
    } else {
      // add data to existing object
      reactions[reactionAdd.message_id, default: [:]][reactionAdd.emoji]?
        .addReactionData(event: reactionAdd)
    }
  }

  private func handleMessageReactionAddMany(
    _ reactionAddMany: Gateway.MessageReactionAddMany
  ) {
    //     we may have to discard this if no matching reactions exist. we can't init new reactions with this data
    //    reactions[reactionAddMany.message_id, default: [:]].keys.forEach { emoji in
    //      if var reaction = reactions[reactionAddMany.message_id, default: [:]][
    //        emoji
    //      ] {
    //        reaction.addReactionData(
    //          event: reactionAddMany,
    //          reactions: reactionAddMany.reactions
    //        )
    //        reactions[reactionAddMany.message_id, default: [:]][emoji] = reaction
    //      }
    //    }
    // nvm so any incoming reaction data can be init'd bc debounced reactions are specifically for normal reactions only, not burst
    // init new reactions if they don't exist
    
    guard let message = messages[reactionAddMany.message_id] else { return }
    for debouncedReaction in reactionAddMany.reactions {
      if reactions[reactionAddMany.message_id, default: [:]][
        debouncedReaction.emoji
      ] == nil
      {
        // make new object
        let reaction = Reaction(
          message: message,
          messageReactionData: nil,
          gatewayReactionAdd: nil,
          gatewayReactionAddMany: debouncedReaction
        )
        reactions[reactionAddMany.message_id, default: [:]][
          debouncedReaction.emoji
        ] = reaction
      } else {
        // add data to existing object
        reactions[reactionAddMany.message_id, default: [:]][
          debouncedReaction.emoji
        ]?.addReactionData(
          event: reactionAddMany,
          reactions: [debouncedReaction]
        )
      }
    }
  }
  private func handleMessageReactionRemove(
    _ reactionRemove: Gateway.MessageReactionRemove
  ) {
    // get the reaction struct for this message and emoji, if it exists
    // also if the count is 0, and selfReacted is false, we can remove the reaction entirely
    if var reaction = reactions[reactionRemove.message_id, default: [:]][
      reactionRemove.emoji
    ] {
      reaction.removeReactionData(event: reactionRemove)
      // check if we should remove the reaction entirely
      if reaction.count == 0 && !reaction.selfReacted {
        reactions[reactionRemove.message_id, default: [:]].removeValue(
          forKey: reactionRemove.emoji
        )
      } else {
        reactions[reactionRemove.message_id, default: [:]][
          reactionRemove.emoji
        ] = reaction
      }
    }
  }
  private func handleMessageReactionRemoveEmoji(
    _ reactionRemoveEmoji: Gateway.MessageReactionRemoveEmoji
  ) {
    // remove the reaction entry for this emoji on this message
    reactions[reactionRemoveEmoji.message_id, default: [:]].removeValue(
      forKey: reactionRemoveEmoji.emoji
    )
  }
  private func handleMessageReactionRemoveAll(
    _ removeAll: Gateway.MessageReactionRemoveAll
  ) {
    // remove all reactions for this message
    reactions.removeValue(forKey: removeAll.message_id)
  }

  private func handleTypingStart(_ typing: Gateway.TypingStart) {
    let userId = typing.user_id
    guard !checkUserBlocked(userId) else { return }
    guard gateway?.user.currentUser?.id != userId else { return }

    let token = UUID()
    typingTimeoutTokens[userId] = token

    Task { [weak self] in
      try? await Task.sleep(nanoseconds: 10_000_000_000)
      guard let self else { return }
      await MainActor.run {
        if self.typingTimeoutTokens[userId] == token {
          self.typingTimeoutTokens.removeValue(forKey: userId)
        }
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

  /// Fetches messages.
  /// NOTE: `around`, `before` and `after` are mutually exclusive.
  func fetchMessages(
    around: MessageSnowflake? = nil,
    before: MessageSnowflake? = nil,
    after: MessageSnowflake? = nil,
    limit: Int? = nil,
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
        self.messages.updateValue(
          message,
          forKey: message.id,
          insertingAt: self.messages.count
        )
      }

      // populate reactions data
      for message in messages {
        guard let messageReactions = message.reactions else { continue }
        for messageReaction in messageReactions {
          let reaction = Reaction(
            message: message,
            messageReactionData: messageReaction,
            gatewayReactionAdd: nil,
            gatewayReactionAddMany: nil
          )
          self.reactions[message.id, default: [:]][messageReaction.emoji] =
            reaction
        }
      }

      // cache user data from mentions in user cache
      for message in messages {
        for mention in message.mentions {
          let user = mention.toPartialUser()
          self.gateway?.user.users[user.id, default: user].update(with: user)
        }
      }

      // lastly request members if member data for any author is missing, also mentions
      if let guildStore {
        let unknownMembers = Set(
          messages.map { message in
            ([message.author?.id] + message.mentions.map(\.id)).compactMap({
              $0
            })
          }.flatMap({ $0 }).filter({
            guildStore.members[$0] == nil
          })
        )
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

extension ChannelStore {
  /// This struct represents a reaction on a message, combining data from various sources.
  struct Reaction: Identifiable, Hashable {
    var id: String {
      emoji.id?.rawValue ?? emoji.name ?? "idk man"
    }

    // the data of the message this reaction is for
    private var message: DiscordChannel.Message
    // oneshot data from rest api message fetch, contains only counts and emoji data
    private var messageReactionData: DiscordChannel.Message.Reaction?
    // oneshot data from gateway reaction add event, contains only emoji and user id data for one person
    private var gatewayReactionAddData: Gateway.MessageReactionAdd?
    // oneshot data from gateway reaction add many event, contains only emoji and user id data for multiple people
    private var gatewayReactionAddManyData:
      Gateway.MessageReactionAddMany.DebouncedReactions?
    // array of known user ids to have reacted with this reaction by listing users via api or gateway events
    private var userIds: Set<UserSnowflake> = []

    /// The initialiser for when a new reaction was made on a message, or when constructing from rest api data.
    /// Note that either messageReactionData or gatewayReactionAdd or Gateway.MessageReactionAddMany must be provided and are mutually exclusive.
    /// - Parameters:
    ///   - message: Underlying message data for validating incoming reaction data.
    ///   - messageReactionData: Message reaction data if initialising from rest api data.
    ///   - gatewayReactionAdd: Gateway reaction add data if initialising from a gateway event.
    ///   - gatewayReactionAddMany: Gateway reaction add many data if initialising from a gateway event.
    init(
      message: DiscordChannel.Message,
      messageReactionData: DiscordChannel.Message.Reaction?,
      gatewayReactionAdd: Gateway.MessageReactionAdd?,
      gatewayReactionAddMany: Gateway.MessageReactionAddMany.DebouncedReactions?
    ) {
      self.message = message
      self.messageReactionData = messageReactionData
      self.gatewayReactionAddData = gatewayReactionAdd
      self.gatewayReactionAddManyData = gatewayReactionAddMany

      if let messageReactionData {
        // set up internal state
        self.emoji = messageReactionData.emoji
        if messageReactionData.count_details.burst != 0 {
          self.isBurst = true
        } else {
          self.isBurst = false
        }
        if messageReactionData.me == true
          || messageReactionData.me_burst == true
        {
          if let id = GatewayStore.shared.user.currentUser?.id {
            self.userIds.insert(id)
          }
          self.selfReacted = true
        } else {
          if let id = GatewayStore.shared.user.currentUser?.id {
            self.userIds.insert(id)
          }
          self.selfReacted = false
        }
        return
      } else if let gatewayReactionAddData {
        // set up internal state
        self.emoji = gatewayReactionAddData.emoji
        self.isBurst = gatewayReactionAddData.type == .burst
        self.selfReacted =
          gatewayReactionAddData.user_id
          == GatewayStore.shared.user.currentUser?.id
        // add the user id to known user ids
        self.userIds.insert(gatewayReactionAddData.user_id)
        return
      } else if let gatewayReactionAddManyData {
        // set up internal state
        // we can only init normal reactions from debounced reactions
        self.emoji = gatewayReactionAddManyData.emoji
        self.isBurst = false  // debounced reactions are always normal reactions
        self.selfReacted = gatewayReactionAddManyData.users.contains(
          GatewayStore.shared.user.currentUser?.id ?? UserSnowflake("0")
        )
        // add all user ids to known user ids
        for userId in gatewayReactionAddManyData.users {
          self.userIds.insert(userId)
        }
        return
      }
      fatalError(
        "[ChannelStore.Reaction] Must init with either messageReactionData or gatewayReactionAdd data. Neither was provided."
      )
    }

    /// The emoji associated with this reaction, note that you can only use one emoji per reaction, either burst or normal.
    /// You can't use the same emoji for burst and then react with normal as well. Discord won't allow it.
    var emoji: Emoji
    /// If this is a burst reaction
    var isBurst: Bool
    var burstColors: [DiscordColor] {
      messageReactionData?.burst_colors ?? gatewayReactionAddData?.burst_colors
        ?? []
    }
    /// If the current user has reacted
    var selfReacted: Bool

    /// This computes the total count of users who have reacted with this reaction, merging data from rest api and known user ids.
    var count: Int {
      var total = 0
      // count from rest api message list data needs to be merged with new counts appropriately.
      // if we fetch user ids via pagination, the count is the messagesReactionData count - userIds.count + userIds.count kinda,
      // basically we're merging the two sources of truth here. i separate own reacts to be added by ui later based on selfReacted.
      // if we get gateway data for reaction adding, its always additive.
      // if we get gateway data for reaction removing, its always subtractive.

      // we consider either burst counts or counts depending on the reaction type.

      if isBurst {
        total += messageReactionData?.count_details.burst ?? 0
        if messageReactionData?.me_burst == true {
          total -= 1
        }
      } else {
        total += messageReactionData?.count_details.normal ?? 0
        if messageReactionData?.me == true {
          total -= 1
        }
      }

      if selfReacted,
        !userIds.contains(
          GatewayStore.shared.user.currentUser?.id ?? .init("0")
        )
      {
        total -= 1  // let our ui handle showing self reacted separately
      }

      if let selfId = GatewayStore.shared.user.currentUser?.id,
        userIds.contains(selfId)
      {
        total += userIds.count - 1
      } else {
        total += userIds.count
      }

      return total
    }

    // the user to fetch after while paginating
    private var afterPoint: UserSnowflake?
    private var hasMoreUsers = true
    mutating func addReactionData(
      client: DefaultDiscordClient,
      after: UserSnowflake?,
      limit: Int = 50
    ) async -> [DiscordUser]? {
      let res = try? await client.listMessageReactionsByEmoji(
        channelId: message.channel_id,
        messageId: message.id,
        emoji: try! DiscordModels.Reaction.init(emoji: emoji),  // unlikely to crash when converting gateway data
        type: isBurst ? .burst : .normal,
        after: afterPoint,
        limit: limit
      )
      guard let reactors = try? res?.decode() else { return nil }
      self.userIds.formUnion(reactors.map(\.id))
      afterPoint = reactors.last?.id
      if reactors.count < limit {
        hasMoreUsers = false
      }

      return reactors
    }
    mutating func addReactionData(
      event: Gateway.MessageReactionAddMany,
      reactions: [Gateway.MessageReactionAddMany.DebouncedReactions]
    ) {
      // ensure the reaction data does belong to this reaction structure
      guard event.channel_id == message.channel_id,
        event.message_id == message.id
      else { return }

      for react in reactions {
        guard react.emoji == self.emoji else { continue }  // safety check, but shouldn't be needed as calling code will filter appropriately
        for userId in react.users {
          self.userIds.insert(userId)
        }
        if react.users.contains(
          GatewayStore.shared.user.currentUser?.id ?? UserSnowflake("0")
        ) {
          self.selfReacted = true
        }
      }
    }
    mutating func addReactionData(event: Gateway.MessageReactionAdd) {
      // ensure the reaction data does belong to this reaction structure
      guard event.channel_id == message.channel_id,
        event.message_id == message.id,
        event.emoji == self.emoji
      else { return }

      self.userIds.insert(event.user_id)
      if event.user_id
        == GatewayStore.shared.user.currentUser?.id
      {
        self.selfReacted = true
      }
    }
    mutating func removeReactionData(event: Gateway.MessageReactionRemove) {
      // ensure the reaction data does belong to this reaction structure
      guard event.channel_id == message.channel_id,
        event.message_id == message.id,
        event.emoji == self.emoji
      else { return }
      // check if we have this user id already, else just remove a count from rest api data as we have no record of this user reacting
      if self.userIds.contains(event.user_id) {
        self.userIds.remove(event.user_id)
      } else {
        // we have no record of this user reacting, so we just reduce the count from rest api data
        if isBurst {
          if let currentCount = messageReactionData?.count_details.burst,
            currentCount > 0
          {
            messageReactionData?.count_details.burst = currentCount - 1
          }
        } else {
          if let currentCount = messageReactionData?.count_details.normal,
            currentCount > 0
          {
            messageReactionData?.count_details.normal = currentCount - 1
          }
        }
      }

      if event.user_id
        == GatewayStore.shared.user.currentUser?.id
      {
        self.selfReacted = false
      }
    }
  }
}
