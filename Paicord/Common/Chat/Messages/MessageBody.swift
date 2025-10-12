//
//  MessageBody.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

extension MessageCell {
	struct MessageBody: View {
		var message: DiscordChannel.Message
		var body: some View {
			VStack(spacing: 4) {
				// Content
				if !message.content.isEmpty {
					Text(markdown: message.content)
						.font(.body)
						.foregroundStyle(.primary)
						.frame(maxWidth: .infinity, alignment: .leading)
				}

				// Attachments
				if !message.attachments.isEmpty {
					AttachmentsView(attachments: message.attachments).frame(
						maxWidth: .infinity,
						alignment: .leading
					)

				}

				// Embeds
				// TODO: Embeds

				// Stickers
				if let stickers = message.sticker_items, !stickers.isEmpty {
					StickersView(stickers: stickers)
						.frame(maxWidth: .infinity, alignment: .leading)
				}

				// Reactions
				// TODO: Reactions
			}
		}
	}
}
