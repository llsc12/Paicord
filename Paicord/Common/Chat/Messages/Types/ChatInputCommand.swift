//
//  ChatInputCommand.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

extension MessageCell {
	struct ChatInputCommandMessage: View {
		let message: DiscordChannel.Message
		let guildStore: GuildStore?

		@State var profileOpen = false
		@State var editedPopover = false
		@State var avatarAnimated = false

		var body: some View {
			VStack {
				reply
				HStack(alignment: .bottom) {
					avatar
						#if os(macOS)
							.padding(.trailing, 4)  // balancing
						#endif
					userAndMessage

				}
				.fixedSize(horizontal: false, vertical: true)
			}
			.onHover { self.avatarAnimated = $0 }
		}

		@ViewBuilder
		var reply: some View {
			if let ref = message.referenced_message {
				HStack {
					ReplyLine()
						.padding(.leading, avatarSize / 2)  // align with pfp

					Text("\(ref.author?.username ?? "Unknown") • \(ref.content)")
						.font(.caption)
						.foregroundStyle(.secondary)
						.lineLimit(1)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}

		@ViewBuilder
		var avatar: some View {
			Button {
				profileOpen = true
			} label: {
				AnimatedImage(
					url: avatarURL(animated: avatarAnimated)
				)
				.resizable()
				.scaledToFill()
				.frame(width: avatarSize, height: avatarSize)
				.clipShape(.circle)
			}
			.buttonStyle(.borderless)
			.popover(isPresented: $profileOpen) {
				Text("Profile for \(message.author?.username ?? "Unknown")")
					.padding()
			}
			.frame(maxHeight: .infinity, alignment: .top)  // align pfp to top of cell
		}

		@ViewBuilder
		var userAndMessage: some View {
			VStack {
				HStack(alignment: .bottom) {
					Button {
						profileOpen = true
					} label: {
						if let guildStore, let userID = message.author?.id {
							let member = guildStore.members[userID] ?? message.member
							let color = member?.roles?.compactMap { guildStore.roles[$0] }
								.sorted(by: { $0.position > $1.position })
								.compactMap { $0.color.value != 0 ? $0.color : nil }
								.first?.asColor()

							Text(
								member?.nick ?? message.author?.global_name ?? message.author?
									.username
									?? "Unknown"
							)
							.foregroundStyle(color != nil ? color! : .primary)
						} else {
							Text(
								message.author?.global_name ?? message.author?.username
									?? "Unknown"
							)
						}
					}
					.buttonStyle(.plain)
					.fontWeight(.semibold)
					Text(message.timestamp.date, style: .time)
						.font(.caption)
						.foregroundStyle(.secondary)
					if let edit = message.edited_timestamp {
						Text("(edited)")
							.font(.caption)
							.foregroundStyle(.secondary)
							.popover(isPresented: $editedPopover) {
								Text(
									"Edited at \(edit.date.formatted(date: .abbreviated, time: .standard))"
								)
								.padding()
							}
							.onHover { self.editedPopover = $0 }
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				MessageBody(message: message)
			}
			.frame(maxHeight: .infinity, alignment: .bottom)  // align text to bottom of cell
		}

		func avatarURL(animated: Bool) -> URL? {
			if let id = message.author?.id,
				let avatar = message.author?.avatar
			{
				if avatar.starts(with: "a_"), animated {
					return URL(
						string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
							+ ".gif?size=128&animated=true"
					)
				} else {
					return URL(
						string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
							+ ".png?size=128&animated=false"
					)
				}
			} else {
				let discrim = message.author?.discriminator ?? "0"
				return URL(
					string: CDNEndpoint.defaultUserAvatar(discriminator: discrim).url
						+ "?size=128"
				)
			}
		}
	}
}
