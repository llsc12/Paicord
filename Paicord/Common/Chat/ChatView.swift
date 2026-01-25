//
//  ChatView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Collections
import PaicordLib
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

// TODO: reimplementing scrolling using platform native scrollviews for better control.

struct ChatView: View {
  var vm: ChannelStore
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion
  @Environment(\.userInterfaceIdiom) var idiom
  @Environment(\.theme) var theme
  var drain: MessageDrainStore { gw.messageDrain }

  @AppStorage("Paicord.Appearance.ChatMessagesAnimated")
  var chatAnimatesMessages: Bool = false

  @ViewStorage private var isNearBottom = true  // used to track if we are near the bottom, if so scroll.
  @ViewStorage private var pendingScrollWorkItem: DispatchWorkItem?

  init(vm: ChannelStore) { self.vm = vm }

  var body: some View {
    let orderedMessages = vm.messages.values
    let pendingMessages:
      OrderedDictionary<MessageSnowflake, Payloads.CreateMessage> =
        drain.pendingMessages[vm.channelId, default: [:]]

    let shouldAnimate =
      orderedMessages.last?.author?.id != gw.user.currentUser?.id
    VStack(spacing: 0) {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 0) {
            if !vm.messages.isEmpty {
              if vm.hasMoreHistory && vm.hasPermission(.readMessageHistory) {
                //                PlaceholderMessageSet()
                //                  .onAppear {
                //                    vm.tryFetchMoreMessageHistory()
                //                  }
              } else {
                if vm.hasPermission(.readMessageHistory) {
                  ChatHeaders.WelcomeStartOfChannelHeader()
                } else {
                  ChatHeaders.NoHistoryPermissionHeader()
                }
              }
            }

            ForEach(orderedMessages) { msg in
              let prior = vm.getMessage(before: msg)
              if messageAllowed(msg) {
                MessageCell(for: msg, prior: prior, channel: vm)
                  .onAppear {
                    // if the message is among the last 15 messages in the list, consider us near the bottom
                    if let index = vm.messages.index(forKey: msg.id) {
                      if index >= vm.messages.count - 15 {
                        self.isNearBottom = true
                      }
                    }
                  }
                  .onDisappear {
                    // if the message is among the last 15 messages in the list, consider us not near the bottom
                    // nvm this causes it to constantly set not near bottom when scrolling up or down as views
                    // instead we check if the 15th last message is gone only.
                    if let index = vm.messages.index(forKey: msg.id) {
                      if index == vm.messages.count - 15 {
                        self.isNearBottom = false
                      }
                    }
                  }
              }
            }

            //            if !vm.messages.isEmpty {
            //              if !vm.hasLatestMessages && vm.hasPermission(.readMessageHistory) {
            //                PlaceholderMessageSet()
            //                  .onAppear {
            //                    vm.tryFetchMoreMessageHistory()
            //                  }
            //              }
            //            } else {
            ForEach(pendingMessages.values) { message in
              // if there is only one message, there is no prior. use the latest message from channelstore
              if pendingMessages.count > 1,
                let messageIndex = pendingMessages.values.firstIndex(where: {
                  $0.nonce == message.nonce
                }),
                messageIndex > 0
              {
                let priorMessage = pendingMessages.values[messageIndex - 1]
                SendMessageCell(for: message, prior: priorMessage)
              } else if let latestMessage = vm.messages.values.last {
                // if there is a prior message from the channel store, use that
                SendMessageCell(for: message, prior: latestMessage)
              } else {
                // no prior message
                SendMessageCell(
                  for: message,
                  prior: Optional<DiscordChannel.Message>.none
                )
              }
            }
            //          }

            // message drain view, represents messages being sent etc
          }
          .scrollTargetLayout()
          Spacer()
            .frame(height: 15)
        }
        .maxHeight(.infinity)
        .bottomAnchored()
        .onAppear {
          NotificationCenter.default.post(
            name: .chatViewShouldScrollToBottom,
            object: ["channelId": self.vm.channelId, "immediate": true]
          )
        }
        .onChange(of: vm.channelId) {
          NotificationCenter.default.post(
            name: .chatViewShouldScrollToBottom,
            object: ["channelId": vm.channelId, "immediate": true]
          )
        }
        .onChange(of: vm.messages.count) { oldValue, newValue in
          if oldValue == 0 && newValue > 0 {
            // first load?
            // delay is to let messages render to full size properly before scrolling to bottom
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              NotificationCenter.default.post(
                name: .chatViewShouldScrollToBottom,
                object: ["channelId": vm.channelId, "immediate": true]
              )
            }
          }
        }
        #if os(macOS)
          // when new messages come in, try scroll to bottom
          .onChange(of: vm.messages) {
            NotificationCenter.default.post(
              name: .chatViewShouldScrollToBottom,
              object: ["channelId": vm.channelId]
            )
          }
          // when sending a message, try scroll to bottom
          .onChange(of: gw.messageDrain.pendingMessages) { _, newValue in
            let pending: MessageSnowflake? =
              newValue[vm.channelId, default: [:]].keys.first
            NotificationCenter.default.post(
              name: .chatViewShouldScrollToBottom,
              object: ["channelId": vm.channelId, "id": pending as Any]
            )
          }
        #endif
        .onReceive(
          NotificationCenter.default.publisher(
            for: .chatViewShouldScrollToBottom
          )
        ) { object in
          guard let info = object.object as? [String: Any],
            let channelId = info["channelId"] as? ChannelSnowflake,
            channelId == vm.channelId
          else { return }
          guard isNearBottom || (info["immediate"] as? Bool == true) else {
            return
          }
          let pending: MessageSnowflake? = info["id"] as? MessageSnowflake
          scheduleScrollToBottom(
            proxy: proxy,
            lastID: pending ?? vm.messages.values.last?.id
          )
        }
        .onReceive(
          NotificationCenter.default.publisher(for: .chatViewShouldScrollToID)
        ) { object in
          guard let info = object.object as? [String: Any],
            let channelId = info["channelId"] as? ChannelSnowflake,
            channelId == vm.channelId,
            let messageId = info["messageId"] as? MessageSnowflake,
            let unitPoint = info["alignment"] as? UnitPoint
          else { return }
          print(
            "Scrolling to message ID \(messageId) in channel \(channelId), unitPoint: \(unitPoint)"
          )
          DispatchQueue.main.async {
            proxy.scrollTo(messageId, anchor: unitPoint)
          }
        }
      }
    }
    .animation(
      shouldAnimate && chatAnimatesMessages ? .default : nil,
      value: orderedMessages
    )
    .animation(chatAnimatesMessages ? .default : nil, value: pendingMessages)
    .scrollDismissesKeyboard(.interactively)
    .safeAreaInset(edge: .bottom, spacing: 10) {
      if vm.hasPermission(.sendMessages) {
        InputBar(vm: vm)
          .id(vm.channelId)
      }
    }
    .background(theme.common.secondaryBackground)
    .ignoresSafeArea(.keyboard, edges: .all)
    .toolbar {
      ToolbarItem(placement: .navigation) {
        ChannelHeader(vm: vm)
      }
      //			if let topic = vm.channel?.topic, !topic.isEmpty {
      //				ToolbarItem(placement: .navigation) {
      //					HStack {
      //						ChannelTopic(topic: topic)
      //					}
      //				}
      //			}
    }
  }

  func messageAllowed(_ msg: DiscordChannel.Message) -> Bool {
    // Currently only filters out messages from blocked users
    guard let authorId = msg.author?.id else { return true }

    // check relationship
    if let relationship = gw.user.relationships[authorId] {
      if relationship.type == .blocked || relationship.user_ignored {
        return false
      }
    }

    return true
  }

  private func scheduleScrollToBottom(
    proxy: ScrollViewProxy,
    lastID: DiscordChannel.Message.ID? = nil,
  ) {
    pendingScrollWorkItem?.cancel()
    guard let lastID else { return }

    let workItem = DispatchWorkItem { [proxy] in
      //      withAnimation(accessibilityReduceMotion ? .none : .default) {
      proxy.scrollTo(lastID, anchor: .top)
      //      }
    }
    pendingScrollWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem)
  }

  @State var ackTask: Task<Void, Error>? = nil
  private func acknowledge() {
    ackTask?.cancel()
    ackTask = Task {
      try? await Task.sleep(for: .seconds(1.5))
      Task.detached {
        try await gw.client.triggerTypingIndicator(channelId: .makeFake())
      }
    }
  }
}

extension View {
  fileprivate func bottomAnchored() -> some View {
    if #available(iOS 18.0, macOS 15.0, *) {
      return
        self
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .defaultScrollAnchor(.bottom, for: .alignment)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
    } else {
      return
        self
        .defaultScrollAnchor(.bottom)
    }
  }
}

// add a new notification that channelstore can notify to scroll down in chat
extension Notification.Name {
  static let chatViewShouldScrollToBottom = Notification.Name(
    "chatViewShouldScrollToBottom"
  )

  static let chatViewShouldScrollToID = Notification.Name(
    "chatViewShouldScrollToID"
  )
}
