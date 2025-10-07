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

					content
				}
				.padding(.top, 5)
			} else {
				VStack {
					if let ref = message.referenced_message {
						HStack {
							// line thing
							//   ________  (pfp) <username> <content>
							//  /
							// |

							ReplyLine()
								.padding(.leading, avatarSize / 2)  // align with pfp

							Text("\(ref.author?.username ?? "Unknown") • \(ref.content)")
								.font(.caption)
								.foregroundStyle(.secondary)
								.lineLimit(1)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
					}
					HStack(alignment: .bottom) {
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
					.fixedSize(horizontal: false, vertical: true) 
				}
				.padding(.top)
				.onHover { self.avatarAnimated = $0 }
			}
		}
		#if os(iOS)
			.padding(.horizontal, 10)  // ios needs horizontal padding
		#endif
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
