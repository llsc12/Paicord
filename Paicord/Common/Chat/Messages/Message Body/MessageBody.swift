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
    let message: DiscordChannel.PartialMessage  // to allow both message types

    init(
      message: DiscordChannel.Message,
      channelStore: ChannelStore
    ) {
      self.message = message.toPartialMessage()
      self.channelStore = channelStore
    }

    init(
      message: DiscordChannel.PartialMessage,
      channelStore: ChannelStore
    ) {
      self.message = message
      self.channelStore = channelStore
    }

    let channelStore: ChannelStore

    var body: some View {
      VStack(alignment: .leading, spacing: 4) {
        // Content
        Group {
          if !messageContentHidden {
            let content = message.content ?? ""
            if message.flags?.contains(.isComponentsV2) == true {
              ComponentsV2View( /*components: message.components*/)
                .equatable(by: message.components)
            } else if !content.isEmpty {
              MarkdownText(content: content, channelStore: channelStore)
                .equatable(by: message.content)
            }
          }
        }

        // Attachments
        let attachments = message.attachments ?? []
        if !attachments.isEmpty {
          AttachmentsView(attachments: attachments)
        }

        // Embeds
        let embeds = message.embeds ?? []
        if !embeds.isEmpty {
          EmbedsView(embeds: embeds)
        }

        // Stickers
        if let stickers = message.sticker_items, !stickers.isEmpty {
          StickersView(stickers: stickers)
        }

        // Reactions
        let reactions = channelStore.reactions[message.id, default: [:]]
        let burstReactions = channelStore.burstReactions[
          message.id,
          default: [:]
        ]
        let buffReactions = channelStore.buffReactions[message.id, default: [:]]
        let buffBurstReactions = channelStore.buffBurstReactions[
          message.id,
          default: [:]
        ]

        if !reactions.isEmpty || !burstReactions.isEmpty
          || !buffReactions.isEmpty || !buffBurstReactions.isEmpty
        {
          ReactionsView(
            reactions: reactions,
            burstReactions: burstReactions,
            buffReactions: buffReactions,
            buffBurstReactions: buffBurstReactions
          )
        }

        if let msgSnapshot = message.partialMessageForSnapshot() {
          VStack(alignment: .leading, spacing: 4) {
            Group {
              Text(Image(systemName: "arrowshape.turn.up.right.fill"))
                + Text(" Forwarded")
            }
            .font(.caption.italic())
            .foregroundStyle(.tertiary)

            MessageBody(
              message: msgSnapshot,
              channelStore: channelStore
            )
          }
          .padding(.leading, 8)
          .overlay(
            Rectangle()
              .frame(width: 3)
              .foregroundStyle(.tertiary)
              .cornerRadius(1),
            alignment: .leading
          )
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Determines if the message content should be hidden based on things like if the embed is a gif.
    var messageContentHidden: Bool {
      if message.embeds?.count == 1,  // only one embed
        let embed = message.embeds?.first,  // get that first embed
        [Embed.Kind.image, .gifv, .video].contains(embed.type),  // is of type image, gifv or video
        let url = embed.url,
        message.content?.trimmingCharacters(in: .whitespacesAndNewlines) == url  // ensure content is just the url
      {
        return true  // then hide the content
      }
      return false
    }
  }
}
