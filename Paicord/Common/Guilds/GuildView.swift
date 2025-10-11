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
	var guild: GuildStore

	var body: some View {
		ScrollView {
			if let bannerURL = bannerURL(animated: true) {  // maybe add animation control?
				AnimatedImage(url: bannerURL)
					.resizable()
					.aspectRatio(16 / 9, contentMode: .fill)
			}

			let uncategorizedChannels = guild.channels.values
				.filter { $0.parent_id == nil }
				.sorted { ($0.position ?? 0) < ($1.position ?? 0) }

			ForEach(uncategorizedChannels) { channel in
				ChannelButton(channels: guild.channels, channel: channel)
					.padding(.horizontal, 10)
					.padding(.vertical, 5)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
		.frame(maxWidth: .infinity)
		.background(.tableBackground.opacity(0.5))
		.roundedCorners(radius: 10, corners: .topLeft)
	}

	func bannerURL(animated: Bool) -> URL? {
		guard let banner = guild.guild?.banner else { return nil }
		if banner.starts(with: "a_"), animated {
			return URL(
				string: CDNEndpoint.guildBanner(guildId: guild.guildId, banner: banner)
					.url
					+ ".\(animated ? "gif" : "png")?size=600&animated=true"
			)
		} else {
			return URL(
				string: CDNEndpoint.guildBanner(guildId: guild.guildId, banner: banner)
					.url
					+ ".png?size=600&animated=false"
			)
		}
	}

	struct ChannelButton: View {
		@Environment(PaicordAppState.self) var appState
		var channels: [ChannelSnowflake: DiscordChannel]
		var channel: DiscordChannel

		var body: some View {
			switch channel.type {
			case .guildText:
				textChannelButton {
					Text("# \(channel.name ?? "unknown")")
				}
			case .dm:
				textChannelButton {
					Text(
						channel.name ?? channel.recipients?.map({
							$0.global_name ?? $0.username
						}).joined(separator: ", ") ?? "Unknown Channel"
					)
				}
			case .guildCategory:
				let expectedParentID = channel.id
				let childChannels = channels.values
					.filter { $0.parent_id ?? (try! .makeFake()) == expectedParentID }
					.sorted { ($0.position ?? 0) < ($1.position ?? 0) }
					.map { $0.id }

				category(channelIDs: childChannels)
			case .guildVoice:
				textChannelButton {
					Text(Image(systemName: "speaker.wave.2.fill"))
						+ Text(" \(channel.name ?? "unknown")")
				}
				.disabled(true)
			default:
				textChannelButton {
					VStack(alignment: .leading) {
						Text(channel.name ?? "unknown")
						Text(String(describing: channel.type))
					}
				}
				.disabled(true)
			}
		}

		/// Button that switches the chat to the given channel when clicked
		@ViewBuilder
		func textChannelButton<Content: View>(@ViewBuilder label: () -> Content)
			-> some View
		{
			Button {
				appState.selectedChannel = channel.id
				#if os(iOS)
					withAnimation {
						appState.chatOpen.toggle()
					}
				#endif
			} label: {
				label()
			}
		}

		/// A disclosure group for a category, showing its child channels when expanded
		@ViewBuilder
		func category(channelIDs: [ChannelSnowflake]) -> some View {
			DisclosureGroup {
				ForEach(channelIDs, id: \.self) { channelId in
					if let channel = channels[channelId] {
						ChannelButton(channels: channels, channel: channel)
							.padding(.horizontal, 10)
							.padding(.vertical, 5)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			} label: {
				Text(channel.name ?? "Unknown Category")
					.font(.headline)
			}
		}
	}
}
