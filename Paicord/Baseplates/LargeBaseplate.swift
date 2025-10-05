//
//  LargeBaseplate.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUIX

// if on macos or ipad
struct LargeBaseplate: View {
	@Environment(GatewayStore.self) var gw
	@Environment(PaicordAppState.self) var appState
	@State var showingInspector = true
	
	@State var currentGuildStore: GuildStore? = nil
	@State var currentChannelStore: ChannelStore? = nil
	
	var body: some View {
		NavigationSplitView {
			SidebarView(currentGuildStore: $currentGuildStore)
				.safeAreaInset(edge: .bottom) {
					ProfileBar()
				}
		} detail: {
			if let currentChannelStore {
				ChatView(vm: currentChannelStore)
			} else {
				Text(":3")
					.font(.largeTitle)
					.foregroundStyle(.secondary)
			}
		}
		.inspector(isPresented: $showingInspector) {
			Text("gm")
				.inspectorColumnWidth(min: 240, ideal: 260, max: 280)
		}
		.toolbar {
			Button {
				showingInspector.toggle()
			} label: {
				Label("Toggle Sidebar", systemImage: "sidebar.right")
			}
		}
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
				self.currentChannelStore = gw.getChannelStore(for: selected, from: self.currentGuildStore)
			} else {
				self.currentChannelStore = nil
			}
		}
	}
}

#Preview {
	LargeBaseplate()
}
