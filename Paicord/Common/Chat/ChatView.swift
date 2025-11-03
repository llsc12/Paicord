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
  @Environment(\.userInterfaceIdiom) var idiom
  
  private let coordinateSpaceName = "chat_coordinate_space"
  
  @State var position: CGPoint = .zero
  @State var loadingInMessages = false
  @State var scrollToMessage: String? = nil

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
                  .id(msg.id.rawValue)
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
          .background(GeometryReader { geometry in
            Color.clear.preference(
              key: PreferenceKey.self,
              value: geometry.frame(in: .named(coordinateSpaceName)).origin
            )
          })
          .onPreferenceChange(PreferenceKey.self) { position in
            self.position = position
            if (abs(position.y) <= 0.01 && vm.messages.count > 0 && vm.hasMoreOlderMessages && !vm.isLoadingMessages && !loadingInMessages) {
              Task { @MainActor in
                if (vm.isLoadingMessages) {
                  return
                }
                loadingInMessages = true
                let beforeId = vm.messages.keys.min()!
                do {
                  try await self.vm.fetchMessages(before: beforeId)
                } catch {
                  PaicordAppState.shared.error = error
                }
                self.vm.updateMessages()
                scrollToMessage = beforeId.rawValue
                loadingInMessages = false
              }
            }
          }
        }
        .safeAreaPadding(.bottom, 22)
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
          if scrollToMessage != nil {
            proxy.scrollTo(scrollToMessage!, anchor: .top)
            scrollToMessage = nil
          }
        }
        .onChange(of: vm.channelId) {
          scheduleScrollToBottom(
            proxy: proxy,
            messages: orderedMessages
          )
        }
        .coordinateSpace(name: coordinateSpaceName)
      }
    }
    .overlay(alignment: .bottom) {
      TypingIndicatorBar(vm: vm)
    }
    .safeAreaInset(edge: .bottom, spacing: 0) {
      InputBar()
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

private extension ChatView {
  struct PreferenceKey: SwiftUI.PreferenceKey {
      static var defaultValue: CGPoint { .zero }

      static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
          
      }
  }
}
