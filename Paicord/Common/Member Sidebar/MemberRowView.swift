//
//  MemberRowView.swift
//  Paicord
//
//  Created by plzdonthaxme on 23/10/2025.
//

import SwiftUI
import DiscordModels

extension MemberSidebarView {
  struct MemberRowView: View {
    var member: Guild.PartialMember?
    var user: DiscordUser
    
    var body: some View {
      HStack {
        Profile.AvatarWithPresence(
          member: member,
          user: member?.user ?? user,
        )
        .showsAvatarDecoration()
        .padding(2)
        Text(user.global_name ?? user.username)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(height: 38)
      .padding(4)
      .background {
        if let nameplate = user.collectibles?.nameplate {
          Profile.NameplateView(nameplate: nameplate)
            .opacity(0.5)
            .transition(.opacity.animation(.default))
        }
      }
      .clipShape(.rounded)
    }
  }
}
