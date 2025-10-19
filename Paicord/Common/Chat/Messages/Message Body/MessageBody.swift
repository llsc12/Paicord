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
      VStack(alignment: .leading, spacing: 4) {
        // Content
        if message.flags?.contains(.isComponentsV2) == true {
          ComponentsV2View( /*components: message.components*/)
        } else if !message.content.isEmpty {
          MarkdownText(content: message.content)
        }

        // Attachments
        if !message.attachments.isEmpty {
          AttachmentsView(attachments: message.attachments)
        }

        // Embeds
        // TODO: Embeds

        // Stickers
        if let stickers = message.sticker_items, !stickers.isEmpty {
          StickersView(stickers: stickers)
        }

        // Reactions
        // TODO: Reactions
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
