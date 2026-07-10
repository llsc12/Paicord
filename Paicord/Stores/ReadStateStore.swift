//
//  ReadStateStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
class ReadStateStore: DiscordDataStore {
  var gateway: GatewayStore?

  var eventTask: Task<Void, Never>?

  func setGateway(_ gateway: GatewayStore?) {
    self.gateway = gateway
    setupEventHandling()
  }

  var readStates: [AnySnowflake: Gateway.ReadState] = [:]

  func setupEventHandling() {
    eventTask?.cancel()
    guard let gateway = gateway?.gateway else { return }
    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        case .ready(let readyData):
          handleReady(readyData)
        case .messageAcknowledge(let ackData):
          handleMessageAcknowledge(ackData)
        case .messageCreate(let messageData):
          handleMessageCreate(messageData)
        default:
          break
        }
      }
    }
  }

  private func handleReady(_ readyData: Gateway.Ready) {
    readStates = (readyData.read_state ?? []).reduce(into: [:]) {
      $0[$1.id] = $1
    }
  }

  private func handleMessageAcknowledge(_ ackData: Gateway.MessageAcknowledge) {
    applyAck(
      channelId: ackData.channel_id,
      messageId: ackData.message_id,
      mentionCount: ackData.mention_count ?? 0
    )
  }

  /// Marks a channel as read up to a given message. Called after we send an ack
  /// ourselves, and when a `MESSAGE_ACK` event arrives from another client.
  func applyAck(channelId: ChannelSnowflake, messageId: MessageSnowflake, mentionCount: Int = 0) {
    let key = AnySnowflake(channelId)
    if readStates[key] != nil {
      readStates[key]?.last_message_id = messageId
      readStates[key]?.mention_count = mentionCount
    } else {
      readStates[key] = Gateway.ReadState(
        id: key,
        last_message_id: messageId,
        mention_count: mentionCount
      )
    }
  }

  func isUnread(channelId: ChannelSnowflake, lastMessageId: MessageSnowflake?) -> Bool {
    guard let lastMessageId else { return false }
    guard let acked = readStates[AnySnowflake(channelId)]?.last_message_id else { return true }
    return lastMessageId > acked
  }

  func mentionCount(channelId: ChannelSnowflake) -> Int {
    readStates[AnySnowflake(channelId)]?.mention_count ?? 0
  }

  func incrementMentionCount(channelId: ChannelSnowflake) {
    let key = AnySnowflake(channelId)
    let newCount = (readStates[key]?.mention_count ?? 0) + 1
    if readStates[key] != nil {
      readStates[key]?.mention_count = newCount
    } else {
      readStates[key] = Gateway.ReadState(id: key, mention_count: newCount)
    }
  }

  private func handleMessageCreate(_ messageData: Gateway.MessageCreate) {
    guard let guildId = messageData.guild_id else { return }
    guard let currentUserId = gateway?.user.currentUser?.id else { return }
    guard messageData.author?.id != currentUserId else { return }
    let guildStore = gateway?.existingGuildStore(for: guildId)
    guard isMentioned(in: messageData, currentUserId: currentUserId, guildStore: guildStore)
    else { return }
    incrementMentionCount(channelId: messageData.channel_id)
  }

  private func isMentioned(
    in messageData: Gateway.MessageCreate,
    currentUserId: UserSnowflake,
    guildStore: GuildStore?
  ) -> Bool {
    if messageData.mention_everyone { return true }
    if messageData.mentions.contains(where: { $0.id == currentUserId }) { return true }
    if !messageData.mention_roles.isEmpty, let guildStore {
      let myRoles = guildStore.member(currentUserId)?.roles ?? []
      if myRoles.contains(where: { messageData.mention_roles.contains($0) }) { return true }
    }
    return false
  }
}
