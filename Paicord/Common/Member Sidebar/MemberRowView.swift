//
//  MemberRowView.swift
//  Paicord
//
//  Created by plzdonthaxme on 23/10/2025.
//

import DiscordModels
import SwiftUI

extension MemberSidebarView {
  struct MemberRowView: View {
    @Environment(\.guildStore) var guildStore
    var member: Guild.PartialMember?
    var user: DiscordUser

    @State var isHovering: Bool = false
    @State var showPopover: Bool = false

    var body: some View {
      Button {
        showPopover = true
      } label: {
        HStack {
          Profile.AvatarWithPresence(
            member: member,
            user: member?.user ?? user,
          )
          .showsAvatarDecoration()
          .padding(2)
          Text(member?.nick ?? user.global_name ?? user.username)
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
        .background(
          Group {
            if isHovering {
              Color.gray.opacity(0.2)
            } else {
              Color.clear
            }
          }
        )
        .clipShape(.rounded)
      }
      .buttonStyle(.borderless)
      .onHover { self.isHovering = $0 }
      .popover(isPresented: $showPopover) {
        ProfilePopoutView(
          guild: guildStore,
          member: member,
          user: user.toPartialUser()
        )
      }
    }
  }
}
