//
//  LargeBaseplate.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

// if on macos or ipad
struct LargeBaseplate: View {
	@State var showingInspector = true
	var body: some View {
		NavigationSplitView {
			SidebarView()
				.safeAreaInset(edge: .bottom) {
					ProfileBar()
				}
		} detail: {
			ChatView()
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
	}
}

#Preview {
	LargeBaseplate()
}
