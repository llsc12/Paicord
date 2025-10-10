//
//  MessageCell.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 07/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

struct MessageCell: View {
	var message: DiscordChannel.Message
	var inline: Bool
	@State var cellHighlighted = false
	@State var profileOpen = false
	@State var avatarAnimated = false

	init(for message: DiscordChannel.Message, inline: Bool) {
		self.message = message
		self.inline = inline
	}

	#if os(iOS)
		let avatarSize: CGFloat = 42
	#elseif os(macOS)
		let avatarSize: CGFloat = 35
	#endif

	var body: some View {
		Group {
			if inline {
				HStack(alignment: .top) {
					Button {
					} label: {
						Text("")
							.frame(width: avatarSize)
					}
					.buttonStyle(.borderless)
					.height(1)
					.disabled(true)  // btn used for spacing only
					#if os(macOS)
						.padding(.trailing, 4)  // balancing
					#endif

					content
				}
			} else {
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
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 2)
		#if os(macOS)
			.onHover { self.cellHighlighted = $0 }
			.background(
				cellHighlighted
					? Color(NSColor.secondaryLabelColor).opacity(0.1) : .clear
			)
		#endif
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
			HStack {
				Text(message.author?.username ?? "Unknown")
					.font(.headline)
				Text(message.timestamp.date, style: .time)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)

			content
		}
		.frame(maxHeight: .infinity, alignment: .bottom)  // align text to bottom of cell
	}

	@ViewBuilder
	var content: some View {
		#warning("make this show markdown")
		Text(markdown: message.content)
			.font(.body)
			.foregroundStyle(.primary)
			.frame(maxWidth: .infinity, alignment: .leading)
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

	struct ReplyLine: View {
		var body: some View {
			RoundedRectangle(cornerRadius: 5)
				.trim(from: 0.5, to: 0.75)
				.stroke(.gray.opacity(0.4), lineWidth: 2)
				.frame(width: 60, height: 20)
				.padding(.top, 8)
				.padding(.bottom, -12)
				.padding(.trailing, -30)
		}
	}
}

#Preview {
	let llsc12 = DiscordUser(
		id: .init("381538809180848128"),
		username: "llsc12",
		discriminator: "0",
		global_name: nil,
		avatar: "df71b3f223666fd8331c9940c6f7cbd9",
		bot: false,
		system: false,
		mfa_enabled: true,
		banner: nil,
		accent_color: nil,
		locale: .englishUS,
		verified: true,
		email: nil,
		flags: .init(rawValue: 4_194_352),
		premium_type: nil,
		public_flags: .init(rawValue: 4_194_304),
		avatar_decoration_data: nil,
	)
	MessageCell(
		for: .init(
			id: try! .makeFake(),
			channel_id: try! .makeFake(),
			author: llsc12,
			content: "gm",
			timestamp: .init(date: .now),
			edited_timestamp: nil,
			tts: false,
			mention_everyone: false,
			mentions: [],
			mention_roles: [],
			mention_channels: nil,
			attachments: [],
			embeds: [],
			reactions: nil,
			nonce: nil,
			pinned: false,
			webhook_id: nil,
			type: DiscordChannel.Message.Kind.default,
			activity: nil,
			application: nil,
			application_id: nil,
			message_reference: nil,
			flags: [],
			referenced_message: nil,
			interaction: nil,
			thread: nil,
			components: nil,
			sticker_items: nil,
			stickers: nil,
			position: nil,
			role_subscription_data: nil,
			resolved: nil,
			poll: nil,
			call: nil,
			guild_id: nil,
			member: nil
		),
		inline: false
	)
}
