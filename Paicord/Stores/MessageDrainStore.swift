//
//  MessageDrainStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 31/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Collections
import Foundation
import PaicordLib

@Observable
class MessageDrainStore: DiscordDataStore {
  var gateway: GatewayStore?
  var eventTask: Task<Void, Never>?

  init() {}

  // MARK: - Protocol Methods

  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }

    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        case .messageCreate(let message):
          // when a message is created, we check if its in pendingMessages, and its nonce matches.
          // the nonce of the message received will match a key of pendingMessages if its one we sent.
          break
        default:
          break
        }
      }
    }
  }

  // Messages get sent innit, but heres how it works.
  // If a message is in the pendingMessages dict, it wil lexist in all of the dictionaries below.
  // When a message is sent, it has a temporary snowflake assigned to it which is a generated nonce with the current timestamp.
  // When the message is successfully sent, it is removed from all dictionaries.
  // If a failure occurs, it is kept in pendingMessages and an error is added to failedMessages.
  // If a message is retried, the error is removed from failedMessages and the send task is re-executed.

  var pendingMessages = [
    ChannelSnowflake: OrderedDictionary<
      MessageSnowflake, Payloads.CreateMessage
    >
  ]()
  var failedMessages: [MessageSnowflake: Error?] = [:]

  var messageSendQueueTask: Task<Void, Never>?
  var messageTasks: [MessageSnowflake: @Sendable () async throws -> Void] = [:] {
    didSet {
      guard messageSendQueueTask == nil else { return }
      messageSendQueueTask = Task.detached { [weak self] in
        guard let self else { return }
        defer { self.messageSendQueueTask = nil }
        for (_, task) in self.messageTasks {
          do {
            try await task()
          } catch {
            // break on error and mark all remaining as failed
            for (nonce, _) in self.messageTasks {
              self.failedMessages[nonce] = error
            }
            break
          }
        }
      }
    }
  }

  // key methods

  func send(_ message: Payloads.CreateMessage, in channel: ChannelSnowflake) {
    guard let gateway = gateway?.gateway else { return }
    // the swiftui side inits the message with a nonce already btw
    let nonce: MessageSnowflake = .init(message.nonce!.asString)
    // set our message up
    let task: @Sendable () async throws -> Void = { [weak self] in
      guard let self else { return }
      do {
        try await gateway.client.createMessage(
          channelId: channel,
          payload: message
        )
        .guardSuccess()
      } catch {
        // mark as failed
        self.failedMessages[nonce] = error
        throw error
      }
      // remove from pending and failed
      self.pendingMessages[channel]?.removeValue(forKey: nonce)
      self.failedMessages.removeValue(forKey: nonce)
      self.messageTasks.removeValue(forKey: nonce)
    }

    // store task
    messageTasks[nonce] = task
    // store in pending
    pendingMessages[channel, default: .init()].updateValueAndMoveToFront(
      message,
      forKey: nonce
    )
  }

  func retry() {

  }
}
