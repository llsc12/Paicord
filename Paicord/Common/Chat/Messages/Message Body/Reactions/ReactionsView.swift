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
      let emojiReactions = Array(reactions.keys)
      let emojiBurstReactions = Array(burstReactions.keys)

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
      .background(.theme.common.primaryButton.opacity(currentUserReacted ? 0.35 : 0))
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
}
