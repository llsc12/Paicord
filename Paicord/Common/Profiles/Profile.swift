//
//  Profile.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//  

import PaicordLib
import SwiftUIX
import SDWebImageSwiftUI

/// Collection of ui components for profiles
enum Profile {
  struct Avatar: View {
    let member: Guild.PartialMember?
    let user: DiscordUser

    var body: some View {
      WebImage(url: avatarURL(animated: true)) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFit()
          default:
            Circle()
              .foregroundStyle(.gray.opacity(0.3))
        }
      }
      .clipShape(Circle())
    }
    
    func avatarURL(animated: Bool) -> URL? {
      let id = user.id
      if let avatar = member?.avatar ?? user.avatar
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
        let discrim = user.discriminator
        return URL(
          string: CDNEndpoint.defaultUserAvatar(discriminator: discrim).url
            + "?size=128"
        )
      }
    }
  }
}
