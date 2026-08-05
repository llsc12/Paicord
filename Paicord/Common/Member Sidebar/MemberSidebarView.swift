//
//  MemberSidebarView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 24/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import ColorCube
import DiscordModels
import PaicordLib
import SwiftUIX

struct MemberSidebarView: View {
  @Environment(\.gateway) var gw
  var guildStore: GuildStore?
  var channelStore: ChannelStore?
  var body: some View {
    Group {
      if let channelStore {
        if channelStore.channel?.type == .groupDm,
          let recipients = channelStore.channel?.recipients
        {
          GroupDMsMemberList(channelStore: channelStore, recipients: recipients)
        } else if let guildStore, let accumulator = channelStore.memberList {
          GuildMemberList(
            guildStore: guildStore, channelStore: channelStore, accumulator: accumulator)
        } else if channelStore.channel?.type == .dm,
          let user = channelStore.channel?.recipients?.first
        {
          DMProfilePanel(user: user.toPartialUser())
        } else {
          EmptyView()
        }
      } else {
        EmptyView()
      }
    }
  }
}
