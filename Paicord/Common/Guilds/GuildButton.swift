//
//  GuildButton.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 02/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

/// Shows a guild folder or standalone guild
struct GuildButton: View {
	var guild: Guild?
	var guilds: [Guild]?
	var folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder?
	@Environment(PaicordAppState.self) var appState
	@Environment(GatewayStore.self) var gw

	init(guild: Guild?) {
		self.guild = guild
		self.guilds = nil
		self.folder = nil
	}

	init(
		folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder,
		guilds: [Guild]
	) {
		self.guilds = guilds
		self.folder = folder
	}

	var body: some View {
		if let folder, let guilds, folder.hasID {
			// must be a folder
			FolderButtons(id: folder.id.value, folder: folder, guilds: guilds)
		} else {
			// either a guild or DMs
			guildButton(from: guild)
		}
	}
	
	/// Contains its own list of buttons, expands and contracts.
	struct FolderButtons: View {
		@Environment(GatewayStore.self) var gw

		var id: Int64
		var folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder
		var guilds: [Guild]

		// key is GuildFolders.\(id).isExpanded
		@State var isExpanded: Bool {
			didSet {
				UserDefaults.standard.set(
					isExpanded,
					forKey: "GuildFolders.\(id).isExpanded"
				)
			}
		}

		init(
			id: Int64,
			folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder,
			guilds: [Guild]
		) {
			self.id = id
			self.folder = folder
			self.guilds = guilds
			self._isExpanded = .init(
				initialValue: UserDefaults.standard.bool(
					forKey: "GuildFolders.\(id).isExpanded"
				)
			)
		}

		var body: some View {
			VStack {
				Button {
					withAnimation {
						isExpanded.toggle()
					}
				} label: {
					if isExpanded {
						Rectangle()
							.fill(.primaryButtonBackground.opacity(0.5))
							.aspectRatio(1, contentMode: .fit)
							.overlay {
								Image(systemName: "folder.fill")
									.font(.title2)
									.foregroundStyle(.tertiaryButton)
									.contentTransition(.symbolEffect(.replace))
							}
					} else {
						// 2 x 2 grid of first 4 guilds. If less than 4, just show what we have with empty spaces
						Rectangle()
							.fill(.primaryButtonBackground.opacity(0.5))
							.aspectRatio(1, contentMode: .fit)
							.overlay {
								Text("GM")
							}
					}
				}
				.buttonStyle(.borderless)
				.clipShape(
					.rect(cornerRadius: isExpanded ? 10 : 32, style: .continuous)
				)

				if isExpanded {
					let guilds = folder.guildIds.compactMap { guildID in
						let guildID = GuildSnowflake(guildID.description)
						return gw.currentUser.guilds.first(where: { $0.id == guildID })
					}
					ForEach(guilds) { guild in
						GuildButton(guild: guild)  // imagine recursion lol (i joke)
					}
					.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
			.background {
				if folder.hasColor,
					let color = DiscordColor(value: Int(folder.color.value))
				{
					Rectangle()
						.fill(color.asColor().secondary)
				} else {
					Rectangle()
						.fill(.tableBackground.secondary)
				}
			}
			.clipShape(.rect(cornerRadius: isExpanded ? 10 : 32, style: .continuous))
		}
	}
	
	/// A button representing a guild or DMs
	func guildButton(from guild: Guild?) -> some View {
		Button {
			appState.selectedGuild = guild?.id
		} label: {
			let isSelected = appState.selectedGuild == guild?.id
			Group {
				if let id = guild?.id {
					Group {
						let shouldAnimate =
							appState.selectedGuild == id
							&& guild?.icon?.hasPrefix("a_") == true
						if let icon = guild?.icon,
							let url = iconURL(id: id, icon: icon, animated: shouldAnimate)
						{
							AnimatedImage(
								url: url,
								isAnimating: .constant(shouldAnimate)
							)
							.resizable()
							.scaledToFill()
						} else {
							Rectangle()
								.fill(.primaryButtonBackground)
								.aspectRatio(1, contentMode: .fit)
						}
					}
				} else {
					Rectangle()
						.fill(.primaryButtonBackground.opacity(0.5))
						.aspectRatio(1, contentMode: .fit)
						.overlay {
							Image(systemName: "bubble.left.and.bubble.right.fill")
								.font(.title2)
								.foregroundStyle(.tertiaryButton)
						}
				}
			}
			.clipShape(.rect(cornerRadius: isSelected ? 10 : 32, style: .continuous))
			.animation(.default, value: isSelected)
		}
		.buttonStyle(.borderless)
		.contextMenu {
			if let id = guild?.id {
				Button("Copy ID") {
					#if os(macOS)
						let pasteboard = NSPasteboard.general
						pasteboard.clearContents()
						pasteboard.setString(id.rawValue, forType: .string)
					#elseif os(iOS)
						UIPasteboard.general.string = id.rawValue
					#endif
				}
			}
		}
	}

	func iconURL(id: GuildSnowflake, icon: String, animated: Bool) -> URL? {
		return URL(
			string: CDNEndpoint.guildIcon(guildId: id, icon: icon).url
				+ "?size=128&animated=\(animated.description)"
		)
	}
}

#Preview {
	ScrollView {
		GuildButton(guild: nil)
	}
}
