//
//  MemberSidebarView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 24/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

struct MemberSidebarView: View {
  @Environment(GatewayStore.self) var gw
  var guildStore: GuildStore?
  var channelStore: ChannelStore?
  var body: some View {
    Group {
      if let channelStore {
        if let recipients = channelStore.channel?.recipients, recipients.count > 1 {
          GroupDMsMemberList(channelStore: channelStore, recipients: recipients)
        } else if let guildStore {
          GuildMemberList(guildStore: guildStore, channelStore: channelStore)
        } else {
          DMProfilePanel(channelStore: channelStore)
        }
      } else {
        EmptyView()
      }
    }
    .ignoresSafeArea()
  }

  struct GuildMemberList: View {
    var guildStore: GuildStore
    var channelStore: ChannelStore

    var body: some View {
      Text("Unimplemented")
    }
  }

  struct GroupDMsMemberList: View {
    var channelStore: ChannelStore
    var recipients: [DiscordUser]
    var body: some View {
      ScrollView {
        LazyVStack {
          ForEach(recipients) { recipient in
            MemberRowView(user: recipient)
          }
        }
      }
      .scrollClipDisabled()
      .padding(4)
    }
  }

  struct DMProfilePanel: View {
    var channelStore: ChannelStore

    var body: some View {
      Text("Unimplemented")
    }
  }
}
