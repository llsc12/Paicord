//
//  DMsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 22/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

struct DMsView: View {
	@Environment(GatewayStore.self) var gw
	@Environment(PaicordAppState.self) var appState
	var body: some View {
		ZStack(alignment: .top) {
			ScrollView {
				// acts as a spacer for title
				HStack {
					Text("Direct Messages")
						.font(.title3)
						.bold()
				}
				.padding(10)
				.frame(maxWidth: .infinity, alignment: .leading)
				.hidden()

				ForEach(gw.currentUser.privateChannels.map({ $0.value}), id: \.id) { channel in
					Button(channel.name ?? channel.recipients?.map({
							$0.global_name ?? $0.username
						}).joined(separator: ", ") ?? "Unknown Channel") {
						appState.selectedChannel = channel.id
					}
				}
			}

			// header text
			HStack {
				Text("Direct Messages")
					.font(.title3)
					.bold()
			}
			.padding(10)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background {
				Color.black
					.opacity(0.5)
					.scaleEffect(1.2)
					.blur(radius: 5)
			}
		}
		.frame(maxWidth: .infinity)
		.background(.tableBackground.opacity(0.5))
		.roundedCorners(radius: 10, corners: .topLeft)
	}
}
