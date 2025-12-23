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
import PhotosUI

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
          if let nonce = message.nonce?.asString,
            let messageNonceSnowflake = Optional(MessageSnowflake(nonce))
          {
            // remove from pending as its been sent successfully
            pendingMessages[message.channel_id, default: [:]].removeValue(
              forKey: messageNonceSnowflake
            )
            // also remove from failed messages if it was there
            failedMessages.removeValue(forKey: messageNonceSnowflake)
            // also remove from message tasks if it was there
            messageTasks.removeValue(forKey: messageNonceSnowflake)
          }
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
  // when a message send does fail, the messageTasks queue is halted, and all remaining messages stay in limbo until the failed message is retried.
  // If a message is retried, the error is removed from failedMessages and the send task is re-executed.

  var pendingMessages = [
    ChannelSnowflake: OrderedDictionary<
      MessageSnowflake, Payloads.CreateMessage
    >
  ]()
  var failedMessages: [MessageSnowflake: Error?] = [:]

  var messageSendQueueTask: Task<Void, Never>?
  var messageTasks: [MessageSnowflake: @Sendable () async throws -> Void] = [:]

  func startQueueIfNeeded() {
    guard messageSendQueueTask == nil else { return }
    setupQueueTask()
  }

  func setupQueueTask() {
    messageSendQueueTask?.cancel()
    messageSendQueueTask = Task { @MainActor [weak self] in
      guard let self else { return }
      defer { self.messageSendQueueTask = nil }
      guard !self.messageTasks.isEmpty else { return }
      let (id, task) = self.messageTasks.first!
      do {
        try await task()
        self.messageTasks.removeValue(forKey: id)
        self.failedMessages.removeValue(forKey: id)

        // continue to next message
        self.setupQueueTask()
      } catch {
        // halt the queue on first failure.
        print(
          "[MessageDrainStore Queue] Halting queue due to failure on nonce:",
          id
        )
        return
      }
    }
  }

  // key methods

  func send(_ vm: ChatView.InputBar.InputVM, in channel: ChannelSnowflake) {
    // the message instance will die inside the task
    guard let gateway = gateway?.gateway else { return }
    // the swiftui side inits the message with a nonce already btw
    // set our message up
    let nonce: MessageSnowflake = try! .makeFake(date: .now)
    let message = Payloads.CreateMessage(
      content: vm.content,
      nonce: .string(nonce.rawValue)
    )
    let task: @Sendable () async throws -> Void = { [weak self] in
      guard let self else { return }
      do {
        print("[SendTask] Starting send for nonce:", nonce)
        print("[SendTask] Channel:", channel)

        var message = self.pendingMessages[channel, default: [:]][nonce]!
        message.attachments = []  // nil by default, allows appends

        print("[SendTask] Initial content:", message.content ?? "<nil>")
        print("[SendTask] Upload item count:", vm.uploadItems.count)

        if !vm.uploadItems.isEmpty {
          print("[SendTask Attachments] Preparing upload attachment metadata")

          let uploadAttachments = try await withThrowingTaskGroup(
            of: Payloads.CreateAttachments.UploadAttachment.self,
            returning: [Payloads.CreateAttachments.UploadAttachment].self
          ) { group in
            for (index, item) in vm.uploadItems.enumerated() {
              group.addTask {
                let idString = String(index)

                switch item {
                case .pickerItem(_, let pickerItem):
                  let fileExt =
                    pickerItem.supportedContentTypes.first?
                    .preferredFilenameExtension ?? "png"
                  let filename =
                    "\(pickerItem.itemIdentifier ?? UUID().uuidString).\(fileExt)"
                  let filesize = await item.filesize() ?? 0

                  return .init(
                    id: .init(idString),
                    filename: filename,
                    file_size: filesize
                  )

                case .file(_, let url, let size):
                  return .init(
                    id: .init(idString),
                    filename: url.lastPathComponent,
                    file_size: Int(size)
                  )

                case .cameraPhoto:
                  let filesize = await item.filesize() ?? 0
                  return .init(
                    id: .init(idString),
                    filename: "\(UUID().uuidString).png",
                    file_size: filesize
                  )

                case .cameraVideo(_, let url):
                  let filesize = await item.filesize() ?? 0
                  return .init(
                    id: .init(idString),
                    filename: url.lastPathComponent,
                    file_size: filesize
                  )
                }
              }
            }

            var results: [Payloads.CreateAttachments.UploadAttachment] = []
            for try await attachment in group {
              results.append(attachment)
            }

            print(
              "[SendTask Attachments] Prepared \(results.count) upload attachment descriptors"
            )
            return results
          }

          print("[SendTask Attachments] Creating attachments via Discord API")

          let createdAttachmentsReq = try await self
            .gateway!.client
            .createAttachments(
              channelID: channel,
              payload: .init(files: uploadAttachments)
            )

          try createdAttachmentsReq.guardSuccess()

          let createdAttachments: [Int: Gateway.CloudAttachment] =
            try createdAttachmentsReq.decode()
            .attachments
            .reduce(into: [:]) { partialResult, attachment in
              let index = Int(attachment.id!.rawValue)!
              partialResult[index] = attachment
            }

          print(
            "[SendTask Attachments] Discord returned \(createdAttachments.count) upload URLs"
          )

          await withThrowingTaskGroup { group in
            for (index, attachment) in createdAttachments {
              let item = vm.uploadItems[index]

              group.addTask {
                print(
                  "[SendTask Upload] Uploading attachment id=\(index) to:",
                  attachment.upload_url
                )

                switch item {
                case .pickerItem(_, let pickerItem):
                  let data = try await pickerItem.loadTransferable(
                    type: Data.self
                  )
                  guard let data else {
                    throw "Failed to load picker item data."
                  }

                  var req = URLRequest(url: URL(string: attachment.upload_url)!)
                  req.httpMethod = "PUT"
                  let (_, res) = try await URLSession.shared.upload(
                    for: req,
                    from: data
                  )
                  print(
                    "[SendTask Upload] pickerItem status:",
                    (res as? HTTPURLResponse)?.statusCode ?? -1
                  )

                case .file(_, let fileURL, _):
                  let access = fileURL.startAccessingSecurityScopedResource()
                  var req = URLRequest(url: URL(string: attachment.upload_url)!)
                  req.httpMethod = "PUT"
                  let (_, res) = try await URLSession.shared.upload(
                    for: req,
                    fromFile: fileURL
                  )
                  print(
                    "[SendTask Upload] file status:",
                    (res as? HTTPURLResponse)?.statusCode ?? -1
                  )
                  if access {
                    fileURL.stopAccessingSecurityScopedResource()
                  }
                case .cameraPhoto(_, let image):
                  let data = image.pngData()!
                  var req = URLRequest(url: URL(string: attachment.upload_url)!)
                  req.httpMethod = "PUT"
                  let (_, res) = try await URLSession.shared.upload(
                    for: req,
                    from: data
                  )
                  print(
                    "[SendTask Upload] cameraPhoto status:",
                    (res as? HTTPURLResponse)?.statusCode ?? -1
                  )

                case .cameraVideo(_, let videoURL):
                  var req = URLRequest(url: URL(string: attachment.upload_url)!)
                  req.httpMethod = "PUT"
                  let (_, res) = try await URLSession.shared.upload(
                    for: req,
                    fromFile: videoURL
                  )
                  print(
                    "[SendTask Upload] cameraVideo status:",
                    (res as? HTTPURLResponse)?.statusCode ?? -1
                  )
                }

                message.attachments?.append(
                  .init(
                    index: index,
                    filename: URL(string: attachment.upload_url)!
                      .lastPathComponent,
                    uploaded_filename: attachment.upload_filename
                  )
                )

                print(
                  "[SendTask Attachments] Added attachment to payload index=\(index)"
                )
              }
            }
          }

          print(
            "[SendTask Attachments] Final attachment payload count:",
            message.attachments?.count ?? 0
          )
        }

        print("[SendTask] Sending message payload")
        print("[SendTask] Attachments:", message.attachments ?? [])

        try await gateway.client.createMessage(
          channelId: channel,
          payload: message
        ).guardSuccess()

        print("[SendTask] Message send SUCCESS nonce:", nonce)

      } catch {
        print("[SendTask] Message send FAILED nonce:", nonce)
        print("[SendTask] Error:", error)
        self.failedMessages[nonce] = error
        throw error
      }
      // remove from pending and failed
      self.pendingMessages[channel, default: [:]].removeValue(forKey: nonce)
      self.failedMessages.removeValue(forKey: nonce)
      self.messageTasks.removeValue(forKey: nonce)
    }

    // store in pending
    pendingMessages[channel, default: [:]].updateValueAndMoveToFront(
      message,
      forKey: nonce
    )
    // store task
    messageTasks[nonce] = task

    startQueueIfNeeded()
  }

  /// Removes an enqueued message from all tracking dictionaries, usually used to give up on a message.
  /// - Parameters:
  ///   - nonce: The nonce of the message to remove.
  ///   - channel: The channel the message is in.
  func removeEnqueuedMessage(
    nonce: MessageSnowflake,
    in channel: ChannelSnowflake
  ) {
    // remove from all dicts
    pendingMessages[channel]?.removeValue(forKey: nonce)
    failedMessages.removeValue(forKey: nonce)
    messageTasks.removeValue(forKey: nonce)
  }
}
