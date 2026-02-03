//
//  GroupDMsMemberList.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 03/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import SwiftUIX
import PaicordLib

extension MemberSidebarView {
  
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
}
