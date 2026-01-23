//
//  SmallBaseplate.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX
@_spi(Advanced) import SwiftUIIntrospect

@available(macOS, unavailable)
struct SmallBaseplate: View {
  @Bindable var appState: PaicordAppState
  @Environment(\.gateway) var gw
  @Environment(\.theme) var theme

  @State var currentGuildStore: GuildStore? = nil
  @State var currentChannelStore: ChannelStore? = nil

  @State private var currentTab: CurrentTab = .home
  var disableSlideover: Bool {
    self.currentTab != .home
  }

  @State private var showSheet = false

  var body: some View {
    SlideoverDoubleView(swap: $appState.chatOpen) {
      NavigationStack {
        TabView(selection: $currentTab) {
          HomeView(guild: currentGuildStore)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.common.primaryBackground)
            .toolbarBackground(theme.common.tertiaryBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Home", systemImage: "house") }
            .tag(CurrentTab.home)
          NotificationsView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.common.primaryBackground)
            .toolbarBackground(theme.common.tertiaryBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Notifications", systemImage: "bell") }
            .tag(CurrentTab.notifications)
            .tint(nil)
          ProfileView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.common.primaryBackground)
            .toolbarBackground(theme.common.tertiaryBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Profile", systemImage: "person.circle") }
            .tag(CurrentTab.profile)
            .tint(nil)
        }
        .tint(theme.common.tertiaryButton)
        #if os(iOS)
        .introspect(.tabView, on: .iOS(.v17...)) { tabBarController in
          addLongPress(to: tabBarController)
        }
        .onReceive(
          NotificationCenter.default.publisher(for: .tabBarLongPressed)
        ) { notification in
          if let index = notification.object as? Int {
            // Only profile tab
            if index == 2 {
              ImpactGenerator.impact(style: .light)
              showSheet = true
            }
          }
        }
        .sheet(isPresented: $showSheet) {
          ProfileBar.ProfileButtonPopout()
            .presentationDetents([.medium])
        }
        #endif
      }
      .environment(\.guildStore, currentGuildStore)
      .environment(\.channelStore, currentChannelStore)
    } secondary: {
      NavigationStack {
        if let currentChannelStore {
          ChatView(vm: currentChannelStore)
            .environment(\.guildStore, currentGuildStore)
            .environment(\.channelStore, currentChannelStore)
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
                  .tint(theme.common.tertiaryButton)
                }
              }
            #endif
        } else {
          VStack {
            Text(":3")
              .font(.largeTitle)
              .foregroundStyle(.secondary)

            Text("Select a channel to start chatting")
              .foregroundStyle(.secondary)
              .font(.title2)
          }
        }
      }
    }
    .slideoverDisabled(disableSlideover)
    .task(id: appState.selectedGuild) {
      if let selected = appState.selectedGuild {
        self.currentGuildStore = gw.getGuildStore(for: selected)
      } else {
        self.currentGuildStore = nil
      }
    }
    .task(id: appState.selectedChannel) {
      if let selected = appState.selectedChannel {
        // there is a likelihood that currentGuildStore is wrong when this runs
        // but i dont think it will be a problem maybe.
        self.currentChannelStore = gw.getChannelStore(
          for: selected,
          from: self.currentGuildStore
        )
      } else {
        self.currentChannelStore = nil
      }
    }
  }

  enum CurrentTab {
    case home, notifications, profile
  }

  #if os(iOS)
    func addLongPress(to tabBarController: UITabBarController) {
      let tabBar = tabBarController.tabBar
      tabBar.layoutIfNeeded()

      let buttons = tabBar.subviews
        .compactMap { $0 as? UIControl }
        .sorted { $0.frame.minX < $1.frame.minX }

      for (index, button) in buttons.enumerated() {
        guard
          button.gestureRecognizers?
            .contains(where: { $0 is TabBarLongPressGestureRecognizer }) != true
        else { continue }

        let recognizer = TabBarLongPressGestureRecognizer(
          target: LongPressHandler.shared,
          action: #selector(LongPressHandler.shared.handle(_:))
        )

        recognizer.minimumPressDuration = 0.2

        button.tag = index
        button.addGestureRecognizer(recognizer)
        
        for existing in button.gestureRecognizers ?? [] {
          if existing !== recognizer {
            existing.require(toFail: recognizer)
          }
        }
      }
    }

    final class TabBarLongPressGestureRecognizer: UILongPressGestureRecognizer {

      override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)

        delaysTouchesBegan = true
        cancelsTouchesInView = true
      }

      override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if state == .began || state == .changed {
          state = .ended
          return
        }

        super.touchesEnded(touches, with: event)
      }
    }

    final class LongPressHandler: NSObject {
      static let shared = LongPressHandler()

      @objc func handle(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
          let view = gesture.view
        else { return }

        NotificationCenter.default.post(
          name: .tabBarLongPressed,
          object: view.tag
        )
      }
    }

  #endif
}

#if os(iOS)
  extension Notification.Name {
    static let tabBarLongPressed = Notification.Name("tabBarLongPressed")
  }
#endif
