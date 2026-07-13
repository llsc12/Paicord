//
//  MemberRowView.swift
//  Paicord
//
//  Created by plzdonthaxme on 23/10/2025.
//

import PaicordLib
import SwiftUIX

extension MemberSidebarView {
  struct MemberRowView: View {
    @Environment(\.gateway) var gw
    @Environment(\.guildStore) var guildStore
    @Environment(\.memberListAccumulator) var accumulator: ChannelStore.MemberListAccumulator?
    @Environment(\.memberListItemIndex) var row: Int?
    
    var member: Guild.PartialMember?
    var user: DiscordUser

    @State var isHovering: Bool = false
    @State var showPopover: Bool = false
    
    var isOffline: Bool {
      let status: Gateway.Status? = {
        if user.id == gw.user.currentUser?.id {
          let status = gw.presence.currentClientStatus
          return (status)
        } else {
          let presence = gw.user.presence(user.id)
          return (presence?.status)
        }
      }()
      if let status {
        return status == .offline
      } else { return true }
    }
    
    var isOfflineGroupMember: Bool {
      if let accumulator, let row {
        return accumulator.group(of: row)?.rawValue == "offline"
      } else {
        return false // idk
      }
    }
    
    var body: some View {
      Button {
        showPopover = true
      } label: {
        HStack {
          Profile.AvatarWithPresence(
            member: member,
            user: member?.user ?? user,
          )
          .profileShowsAvatarDecoration()
          .profileHidesOfflinePresence(true)
          .padding(2)

          Group {
            let userID = user.id
            if let guildStore {
              let member = guildStore.member(userID) ?? member
              let color = member?.roles?.compactMap { guildStore.role($0) }
                .sorted(by: { $0.position > $1.position })
                .compactMap { $0.color.value != 0 ? $0.color : nil }
                .first?.asColor()

              Text(
                member?.nick ?? user.global_name ?? user.username
              )
              .foregroundStyle(color != nil ? color! : .secondary)
            } else {
              Text(user.global_name ?? user.username)
            }
          }
          .font(.title3)
          .fontWeight(.semibold)
          .lineLimit(1)
          .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(4)
        .background {
          if let nameplate = user.collectibles?.nameplate {
            Profile.NameplateView(nameplate: nameplate)
              .nameplateAnimated(isHovering)
              .opacity(isHovering ? 0.8 : 0.5)
              .transition(.opacity.animation(.default))
          }
        }
        .opacity(isOffline && !isHovering ? isOfflineGroupMember ? 0.3 : 1 : 1)
        .background(
          Group {
            if isHovering {
              Color.gray.opacity(0.2)
            } else {
              Color.almostClear
            }
          }
        )
        .clipShape(.rounded)
      }
      .buttonStyle(.plain)
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
