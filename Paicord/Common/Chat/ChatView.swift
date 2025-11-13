//
//  ChatView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX
import Collections

struct ChatView: View {
  var vm: ChannelStore
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion
  @Environment(\.userInterfaceIdiom) var idiom

  @ViewStorage private var isNearBottom = true  // used to track if we are near the bottom, if so scroll.
  @ViewStorage private var pendingScrollWorkItem: DispatchWorkItem?

  init(vm: ChannelStore) { self.vm = vm }

  var body: some View {
    let orderedMessages = vm.messages.values
    VStack(spacing: 0) {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(orderedMessages) { msg in
              let prior = vm.getMessage(before: msg)
              if messageAllowed(msg) {
                MessageCell(for: msg, prior: prior, channel: vm)
                  .onAppear {
                    guard msg == vm.messages.values.last else { return }
                    self.isNearBottom = true
                  }
                  .onDisappear {
                    guard msg == vm.messages.values.last else { return }
                    self.isNearBottom = false
                  }
              }
            }
          }
          .scrollTargetLayout()
        }
        .maxHeight(.infinity)
        .safeAreaPadding(.bottom, 22)
        .bottomAnchored()
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
          NotificationCenter.default.post(
            name: .chatViewShouldScrollToBottom,
            object: ["channelId": self.vm.channelId]
          )
        }
        .onChange(of: vm.channelId) {
          NotificationCenter.default.post(
            name: .chatViewShouldScrollToBottom,
            object: ["channelId": vm.channelId]
          )
        }
        .onReceive(
          NotificationCenter.default.publisher(
            for: .chatViewShouldScrollToBottom
          )
        ) { object in
          guard let info = object.object as? [String: Any],
            let channelId = info["channelId"] as? ChannelSnowflake,
            channelId == vm.channelId
          else { return }
            
          scheduleScrollToBottom(
            proxy: proxy,
            messages: orderedMessages
          )
        }
      }
    }
    .safeAreaInset(edge: .bottom, spacing: 0) {
      VStack(spacing: 0) {
        InputBar(vm: vm)
      }
    }
    .background(.tableBackground)
    #if os(iOS)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            withAnimation {
              appState.chatOpen.toggle()
            }
          } label: {
            Image(systemName: "arrow.left")
          }
          .tint(.tertiaryButton)
        }
      }
    #endif
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
    messages: OrderedDictionary<MessageSnowflake, DiscordChannel.Message>.Values?
  ) {
    pendingScrollWorkItem?.cancel()
    guard let lastID = messages?.last?.id else { return }

    let workItem = DispatchWorkItem { [proxy] in
      // Use main queue to ensure layout is ready; small delay coalesces bursts
      DispatchQueue.main.async {
        withAnimation(accessibilityReduceMotion ? .none : .default) {
          proxy.scrollTo(lastID, anchor: .top)
        }
      }
    }
    pendingScrollWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.06, execute: workItem)
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
  static let chatViewShouldScrollToBottom = Notification.Name("chatViewShouldScrollToBottom")
}
