//
//  ReactionsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 21/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Collections
import PaicordLib
import Playgrounds
import SDWebImageSwiftUI
import SwiftUIX

struct ReactionsView: View {
  @Environment(\.gateway) var gw
  @Environment(\.channelStore) var channelStore
  let reactions: OrderedDictionary<Emoji, ChannelStore.Reaction>

  var body: some View {
    FlowLayout(spacing: 4) {
      ForEach(reactions.values.elements) { reaction in
        AsyncButton {
          ImpactGenerator.impact(style: .light)
          let channelID = reaction.channelID
          let messageID = reaction.messageID
          if reaction.selfReacted {
            try await gw.client.deleteOwnMessageReaction(
              channelId: channelID,
              messageId: messageID,
              emoji: .init(emoji: reaction.emoji),
              type: reaction.isBurst ? .burst : .normal
            )
            .guardSuccess()
          } else {
            try await gw.client.addMessageReaction(
              channelId: channelID,
              messageId: messageID,
              emoji: .init(emoji: reaction.emoji),
              type: reaction.isBurst ? .burst : .normal
            )
            .guardSuccess()
          }
        } catch: { _ in
        } label: {
          Reaction(reaction: reaction)
        }
        .buttonStyle(.plain)
      }
    }
  }

  struct Reaction: View {
    let reaction: ChannelStore.Reaction
    @Environment(\.gateway) var gw
    @Environment(\.theme) var theme

    var body: some View {
      let emoji = reaction.emoji
      let currentUserReacted = reaction.selfReacted
      let burstColorShadow = {
        let burstcolor = reaction.burstColors.compactMap({
          $0.asColor(ignoringZero: true)
        }).first
        if let burstcolor {
          return burstcolor.opacity(0.8)
        } else {
          return .clear
        }
      }()
      let burstColorStroke = {
        let burstcolor = reaction.burstColors.compactMap({
          $0.asColor(ignoringZero: true)
        }).first
        if currentUserReacted {
          return burstcolor?.opacity(0.4) ?? .primary.opacity(0.08)
        } else {
          return burstcolor?.opacity(0.25) ?? .primary.opacity(0.08)
        }
      }()
      let burstColorBody = {
        let burstcolor = reaction.burstColors.compactMap({
          $0.asColor(ignoringZero: true)
        }).first
        if currentUserReacted {
          return burstcolor ?? theme.common.primaryButton.opacity(0.2)
        } else {
          return burstcolor?.opacity(0.35) ?? .primary.opacity(0.08)
        }
      }()
      HStack(spacing: 2) {
        if let emojiURL = emojiURL(emoji: emoji.id, animated: emoji.animated) {
          VStack {
            AnimatedImage(url: emojiURL)
              .resizable()
              .scaledToFit()
          }
          .frame(width: 18, height: 18)
          .padding(2)
        } else {
          Text(emoji.name ?? " ")
            .font(.title2)
            .minimumScaleFactor(0.1)
            .maxWidth(22)
            .maxHeight(18)
            .padding(2)
            .padding(.horizontal, -2)
        }
        
        let count = reaction.count + (currentUserReacted ? 1 : 0)
        Text(verbatim: "\(count)")
          .contentTransition(.numericText(value: .init(count)))
          .padding(.horizontal, 2)
          .animation(.default, value: count)
      }
      .padding(.horizontal, 5)
      .padding(.vertical, 2)
      .background(burstColorBody)
      .background(
        theme.common.primaryButton.opacity(currentUserReacted ? 0.35 : 0)
      )
      .clipShape(.rounded)
      .border(.rounded, stroke: .init(burstColorStroke, lineWidth: 1.5))
      .shadow(color: burstColorShadow, radius: 8, x: 0, y: 0)
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
