//
//  Sidebar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//  

import SwiftUI
import SDWebImageSwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct SidebarView: View {
	var body: some View {
		HStack(spacing: 0) {
			ScrollView {
				LazyVStack {
					ServerButton()
						.padding(2)

					Divider()
						.padding(.horizontal, 8)

					ForEach(0..<20) { index in
						ServerButton()
							.padding(2)
					}
				}
				.safeAreaPadding(.all, 10)
			}
			.scrollIndicators(.hidden)
			.frame(width: 60)
			.introspect(.scrollView, on: .macOS(.v14...)) { scrollView in
				scrollView.hasVerticalScroller = false
				scrollView.hasHorizontalScroller = false
				scrollView.scrollerStyle = .overlay
				scrollView.autohidesScrollers = true
				scrollView.verticalScroller?.alphaValue = 0
				scrollView.horizontalScroller?.alphaValue = 0
			}

			ScrollView {
				VStack {
					AnimatedImage(url: .init(string: "https://cdn.discordapp.com/banners/1015060230222131221/a_a42646da37160e4053f1823649177f0a.webp?size=300&animated=true"))
						.resizable()
						.scaledToFill()

					ForEach(0..<100) { index in
						Text("\nStuff")
					}
				}
				.frame(maxWidth: .infinity)
			}
			.background {
				Color.tableBackground.opacity(0.25)
			}
			.roundedCorners(radius: 10, corners: .topLeft)
		}
		.navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 350)
	}
}
