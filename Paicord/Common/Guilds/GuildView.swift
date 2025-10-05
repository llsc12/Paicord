//
//  GuildView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 22/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

struct GuildView: View {
	@Environment(PaicordAppState.self) var appState
	var guild: GuildStore
	
	var body: some View {
		ZStack(alignment: .top) {
			ScrollView {
				if let bannerURL = bannerURL(animated: true) {  // maybe add animation control?
					AnimatedImage(url: bannerURL)
						.resizable()
						.aspectRatio(16 / 9, contentMode: .fill)
				} else {
					// acts as a spacer for title
					HStack {
						Text(guild.guild?.name ?? "Unknown Guild")
							.font(.title3)
							.bold()
					}
					.padding(10)
					.frame(maxWidth: .infinity, alignment: .leading)
					.hidden()
				}

				ForEach(guild.channels.map({$0.value})) { channel in
					Button {
						appState.selectedChannel = channel.id
					} label: {
						Text(channel.name ?? "unknown-channel")
					}
				}
			}
			
			// header text
			HStack {
				Text(guild.guild?.name ?? "Unknown Guild")
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

	func bannerURL(animated: Bool) -> URL? {
		guard let banner = guild.guild?.banner else { return nil }
		return URL(
			string: CDNEndpoint.guildBanner(guildId: guild.guildId, banner: banner).url
				+ ".\(animated ? "gif" : "png")?size=600&animated=\(animated.description)"
		)
	}
}
