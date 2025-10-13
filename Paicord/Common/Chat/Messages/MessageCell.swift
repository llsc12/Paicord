//
//  MessageCell.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 07/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

struct MessageCell: View {
	
	/// Controls the size of the avatar in the message cell.
	#if os(iOS)
		static let avatarSize: CGFloat = 40
	#elseif os(macOS)
	static let avatarSize: CGFloat = 35
	#endif

	var message: DiscordChannel.Message
	var priorMessage: DiscordChannel.Message?
	let guild: GuildStore?
	@State var cellHighlighted = false

	init(
		for message: DiscordChannel.Message,
		prior: DiscordChannel.Message? = nil,
		guild: GuildStore? = nil
	) {
		self.message = message
		self.priorMessage = prior
		self.guild = guild
	}

	var body: some View {
		let inline =
			priorMessage?.author?.id == message.author?.id
			&& message.timestamp.date.timeIntervalSince(
				priorMessage?.timestamp.date ?? .distantPast
			) < 300 && message.referenced_message == nil && message.type == .default

		// adding them together can cause arithmetic overflow, so hash instead
		let cellHash: Int = {
			var hasher = Hasher()
			hasher.combine(message)
			if let priorMessage = priorMessage {
				hasher.combine(priorMessage)
			}
			return hasher.finalize()
		}()

		Group {
			// Content
			switch message.type {
			case .default, .reply:
				DefaultMessage(
					message: message,
					priorMessage: priorMessage,
					guildStore: guild,
					inline: inline,
				)
			case .chatInputCommand:
				ChatInputCommandMessage(message: message, guildStore: guild)
			default:
				HStack {
					AvatarBalancing()
					(Text(Image(systemName: "xmark.circle.fill"))
						+ Text(" Unsupported message type \(message.type)"))
						.foregroundStyle(.red)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}
		.equatable(by: cellHash)
		/// stop updates to messages unless messages change.
		/// prevent updates to messages unless they change
		/// avoid re-render on message cell highlight
		.padding(.horizontal, 10)
		.padding(.vertical, 2)
		#if os(macOS)
			.onHover { self.cellHighlighted = $0 }
			.background(
				cellHighlighted
					? Color(NSColor.secondaryLabelColor).opacity(0.1) : .clear
			)
		#endif
		.padding(.top, inline ? 0 : 10)  // adds space between message groups
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
		prior: nil
	)
}
