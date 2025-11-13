//
//  ReactionsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 21/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

struct ReactionsView: View {
  let reactions: ChannelStore.Reactions
  let burstReactions: ChannelStore.Reactions
  let buffReactions: ChannelStore.BuffReactions
  let buffBurstReactions: ChannelStore.BuffReactions

  var body: some View {
    FlowLayout(spacing: 4) {
      let emojiReactions = reactions.keys
      let emojiBurstReactions = burstReactions.keys

      ForEach(emojiReactions, id: \.id) { emoji in
        Reaction(
          emoji: emoji,
          users: reactions[emoji] ?? [],
          countBuff: buffReactions[emoji]
        )
      }
      ForEach(emojiBurstReactions, id: \.id) { emoji in
        Reaction(
          emoji: emoji,
          users: burstReactions[emoji] ?? [],
          countBuff: buffBurstReactions[emoji]
        )
      }
    }
  }

  struct Reaction: View {
    let emoji: Emoji
    let users: Set<UserSnowflake>
    let countBuff: Int?
    @Environment(\.gateway) var gw

    var body: some View {
      let currentUser = gw.user.currentUser?.id
      let currentUserReacted = users.contains(currentUser ?? UserSnowflake("0"))
      HStack {
        if let emojiURL = emojiURL(emoji: emoji.id, animated: emoji.animated) {
          WebImage(url: emojiURL) { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
            default:
              Spacer()
                .frame(width: 18, height: 18)
            }
          }
          .padding(2)
        } else {
          Text(emoji.name ?? " ")
            .font(.system(size: 36))
            .minimumScaleFactor(0.001)
            .frame(width: 18, height: 18)
            .padding(2)
        }

        Text("\(users.count + (countBuff ?? 0))")
      }
      .padding(.horizontal, 5)
      .padding(.vertical, 2)
      .background(.primary.opacity(0.08))
      .background(.primaryButton.opacity(currentUserReacted ? 0.35 : 0))
      .clipShape(.rounded)
    }

    func emojiURL(emoji id: EmojiSnowflake?, animated: Bool?) -> URL? {
      if let id {
        return URL(
          string: CDNEndpoint.customEmoji(emojiId: id).url
            + ".\((animated ?? false) ? "gif" : "png")?size=64"
        )
      }
      return nil
    }
  }

  struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(
      proposal: ProposedViewSize,
      subviews: Subviews,
      cache: inout ()
    ) -> CGSize {
      let maxWidth = proposal.replacingUnspecifiedDimensions().width
      var x: CGFloat = 0
      var y: CGFloat = 0
      var rowHeight: CGFloat = 0

      for subview in subviews {
        let size = subview.sizeThatFits(.unspecified)
        if x + size.width > maxWidth && x > 0 {
          x = 0
          y += rowHeight + spacing
          rowHeight = 0
        }
        x += size.width + spacing
        rowHeight = max(rowHeight, size.height)
      }
      y += rowHeight
      return CGSize(width: maxWidth, height: y)
    }

    func placeSubviews(
      in bounds: CGRect,
      proposal: ProposedViewSize,
      subviews: Subviews,
      cache: inout ()
    ) {
      var x = bounds.minX
      var y = bounds.minY
      var rowHeight: CGFloat = 0

      for subview in subviews {
        let size = subview.sizeThatFits(.unspecified)
        if x + size.width > bounds.maxX && x > bounds.minX {
          x = bounds.minX
          y += rowHeight + spacing
          rowHeight = 0
        }
        subview.place(
          at: CGPoint(x: x, y: y),
          anchor: .topLeading,
          proposal: ProposedViewSize(size)
        )
        x += size.width + spacing
        rowHeight = max(rowHeight, size.height)
      }
    }
  }
}
