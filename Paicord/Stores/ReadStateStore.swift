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
    applyAck(channelId: ackData.channel_id, messageId: ackData.message_id)
  }

  /// Marks a channel as read up to a given message. Called after we send an ack
  /// ourselves, and when a `MESSAGE_ACK` event arrives from another client.
  func applyAck(channelId: ChannelSnowflake, messageId: MessageSnowflake) {
    let key = AnySnowflake(channelId)
    if readStates[key] != nil {
      readStates[key]?.last_message_id = messageId
    } else {
      readStates[key] = Gateway.ReadState(id: key, last_message_id: messageId)
    }
  }

  func isUnread(channelId: ChannelSnowflake, lastMessageId: MessageSnowflake?) -> Bool {
    guard let lastMessageId else { return false }
    guard let acked = readStates[AnySnowflake(channelId)]?.last_message_id else { return true }
    return lastMessageId > acked
  }
}
