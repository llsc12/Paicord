//
//  Username.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

extension MessageCell {
  enum MessageAuthor {
    struct Avatar: View {
      var message: DiscordChannel.Message
      var guildStore: GuildStore?
      @Binding var profileOpen: Bool
      var animated: Bool
      var body: some View {
        Button {
          guard message.author != nil else { return }
          profileOpen = true
        } label: {
          AnimatedImage(
            url: avatarURL(animated: animated)
          )
          .resizable()
          .scaledToFill()
          .frame(width: avatarSize, height: avatarSize)
          .clipShape(.circle)
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $profileOpen) {
          if let userId = message.author?.id, let user = message.author {
            ProfilePopoutView(
              member: guildStore?.members[userId] ?? message.member,
              user: user
            )
          }
        }
        .frame(maxHeight: .infinity, alignment: .top)  // align pfp to top of cell
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

    struct Username: View {
      var message: DiscordChannel.Message
      var guildStore: GuildStore?
      @Binding var profileOpen: Bool

      var body: some View {
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
        #if os(iOS)
          .font(.callout)
        #elseif os(macOS)
          .font(.body)
        #endif
        .fontWeight(.semibold)
      }
    }
  }
}
