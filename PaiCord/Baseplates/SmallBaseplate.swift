//
//  SmallBaseplate.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 31/08/2025.
//

import SwiftUI

struct SmallBaseplate: View {
	@SceneStorage("Baseplate.ChatVisibility") private var chatVisibility = false

	@State private var currentTab: CurrentTab = .home
	var disableSlideover: Bool {
		self.currentTab != .home
	}
	var body: some View {
		SlideoverDoubleView(swap: $chatVisibility) {
			TabView(selection: $currentTab) {
				HomeView()
					.tabItem {
						Label("Home", systemImage: "house")
					}
					.tag(CurrentTab.home)
				NotificationsView()
					.tabItem {
						Label("Notifications", systemImage: "bell")
					}
					.tag(CurrentTab.notifications)
				ProfileView()
					.tabItem {
						Label("Profile", systemImage: "person.circle")
					}
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

#Preview {
	ContentView()
}
