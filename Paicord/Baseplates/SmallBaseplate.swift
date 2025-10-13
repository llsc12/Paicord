//
//  SmallBaseplate.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

@available(macOS, unavailable)
struct SmallBaseplate: View {
  @Bindable var appState: PaicordAppState
  @Environment(GatewayStore.self) var gw

  @State var currentGuildStore: GuildStore? = nil
  @State var currentChannelStore: ChannelStore? = nil

  @State private var currentTab: CurrentTab = .home
  var disableSlideover: Bool {
    self.currentTab != .home
  }

  var body: some View {
    SlideoverDoubleView(swap: $appState.chatOpen) {
      NavigationStack {
        TabView(selection: $currentTab) {
          HomeView(guild: currentGuildStore)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .toolbarBackground(.tabBarBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Home", systemImage: "house") }
            .tag(CurrentTab.home)
          NotificationsView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .toolbarBackground(.tabBarBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Notifications", systemImage: "bell") }
            .tag(CurrentTab.notifications)
          ProfileView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .toolbarBackground(.tabBarBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Profile", systemImage: "person.circle") }
            .tag(CurrentTab.profile)
        }
      }

    } secondary: {
      NavigationStack {
        if let currentChannelStore {
          ChatView(vm: currentChannelStore)
            .environment(currentGuildStore)
            .environment(currentChannelStore)
        } else {
          Text(":3")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
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
}
