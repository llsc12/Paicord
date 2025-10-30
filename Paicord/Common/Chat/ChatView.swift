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

struct ChatView: View {
  var vm: ChannelStore
  @Environment(GatewayStore.self) var gw
  @Environment(PaicordAppState.self) var appState
  @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion

  @ViewStorage private var isNearBottom = true  // used to track if we are near the bottom, if so scroll.
  @ViewStorage private var pendingScrollWorkItem: DispatchWorkItem?

  init(vm: ChannelStore) { self.vm = vm }

  var body: some View {
    let orderedMessages = Array(vm.messages.values)
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
        .safeAreaPadding(.bottom, 18)
        .bottomAnchored()
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
          scheduleScrollToBottom(
            proxy: proxy,
            messages: orderedMessages
          )
        }
        .onChange(of: vm.messages.count) {
          if isNearBottom {
            scheduleScrollToBottom(
              proxy: proxy,
              messages: orderedMessages
            )
          }
        }
        .onChange(of: vm.channelId) {
          scheduleScrollToBottom(
            proxy: proxy,
            messages: orderedMessages
          )
        }
      }
    }
    .overlay(alignment: .bottom) {
      TypingIndicatorBar(vm: vm)
    }
    .safeAreaInset(edge: .bottom, spacing: 0) {
      InputBar(vm: vm)
    }
    .background(.tableBackground)
    #if os(iOS)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            appState.chatOpen.toggle()
          } label: {
            Image(systemName: "arrow.left")
          }
        }
      }
    #endif
    .toolbar {
      #warning("make channel headers nicer")
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
    messages: [DiscordChannel.Message]?
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

fileprivate extension View {
  func bottomAnchored() -> some View {
    if #available(iOS 18.0, macOS 15.0, *) {
      return self
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .defaultScrollAnchor(.bottom, for: .alignment)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
    } else {
      return self
        .defaultScrollAnchor(.bottom)
    }
  }
}
