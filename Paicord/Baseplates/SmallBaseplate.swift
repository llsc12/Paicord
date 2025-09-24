//
//  SmallBaseplate.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

@available(macOS, unavailable)
struct SmallBaseplate: View {
	@Bindable var appState: PaicordAppState

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
			ChatView()
		}
		.slideoverDisabled(disableSlideover)
	}

	enum CurrentTab {
		case home, notifications, profile
	}
}
