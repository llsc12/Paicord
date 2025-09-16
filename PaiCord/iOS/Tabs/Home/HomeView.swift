//
//  HomeView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

/// Discord iOS Home View, the left side is a list of servers, with the right being the selected server's channels etc.
/// The left side should be 1/5th of the width of both scroll views
struct HomeView: View {
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
			.containerRelativeFrame(.horizontal) { length, _ in
				length / 5
			}
			
			ScrollView {
				VStack {
					Image("banner")
						.resizable()
						.scaledToFill()
						
					ForEach(0..<100) { index in
						Text("\nStuff")
					}
				}
				.frame(maxWidth: .infinity)
			}
			.background {
				Color.tableBackground
					.roundedCorners(radius: 30, corners: .topLeft)
			}
		}
		.padding(.top, 4)
	}
}
