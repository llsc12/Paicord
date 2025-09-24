//
//  Sidebar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//  

import SwiftUIX
import SDWebImageSwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct SidebarView: View {
	@Environment(GatewayStore.self) var gw
	@Environment(PaicordAppState.self) var appState
	
	var body: some View {
		HStack(spacing: 0) {
			guildScroller
				.frame(width: 65)
			
			if appState.selectedGuild == nil {
				DMsView()
			} else {
				if let guild = gw.currentUser.guilds.first(where: { $0.id == appState.selectedGuild }) {
					GuildView(guild: guild)
				} else {
					ActivityIndicator()
				}
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

fileprivate extension View {
	func scrollviewForceDisableScrollBars() -> some View {
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
