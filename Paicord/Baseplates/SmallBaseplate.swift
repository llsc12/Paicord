//
//  SmallBaseplate.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUIX
import PaicordLib

@available(macOS, unavailable)
struct SmallBaseplate: View {
	@Bindable var appState: PaicordAppState
	@Environment(GatewayStore.self) var gw
	@State private var store: ChannelStore?
	@State private var currentTab: CurrentTab = .home
	var disableSlideover: Bool {
		self.currentTab != .home
	}
	
	var body: some View {
		SlideoverDoubleView(swap: $appState.chatOpen) {
			TabView(selection: $currentTab) {
				HomeView()
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
		} secondary: {
			if let store {
				ChatView(vm: store)
			} else {
				ActivityIndicator()
			}
		}
		.slideoverDisabled(disableSlideover)
		.task(id: appState.selectedChannel) {
			if let selected = appState.selectedChannel {
				self.store = gw.getChannelStore(for: selected)
			} else {
				self.store = nil
			}
		}
	}

	enum CurrentTab {
		case home, notifications, profile
	}
}
