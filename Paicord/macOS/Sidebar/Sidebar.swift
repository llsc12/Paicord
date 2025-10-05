//
//  Sidebar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SDWebImageSwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

struct SidebarView: View {
	@Environment(GatewayStore.self) var gw
	@Environment(PaicordAppState.self) var appState

	@Binding var currentGuildStore: GuildStore?

	var body: some View {
		HStack(spacing: 0) {
			guildScroller
				.frame(width: 65)
			if let guild = currentGuildStore {
				GuildView(guild: guild)
			} else if appState.selectedGuild == nil {
				DMsView()
			} else {
				Spacer()
			}

		}
		.navigationSplitViewColumnWidth(min: 280, ideal: 300, max: 360)
	}

	@ViewBuilder
	var guildScroller: some View {
		GuildScrollBar()
			.scrollIndicators(.hidden)
			.scrollviewForceDisableScrollBars()
	}
}

extension View {
	fileprivate func scrollviewForceDisableScrollBars() -> some View {
		#if os(macOS)
			self
				.introspect(.scrollView, on: .macOS(.v14...)) { scrollView in
					scrollView.hasVerticalScroller = false
					scrollView.hasHorizontalScroller = false
					scrollView.scrollerStyle = .overlay
					scrollView.autohidesScrollers = true
					scrollView.verticalScroller?.alphaValue = 0
					scrollView.horizontalScroller?.alphaValue = 0
				}
		#else
			self
		#endif
	}
}
