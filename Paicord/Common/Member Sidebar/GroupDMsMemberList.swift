//
//  GroupDMsMemberList.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 03/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

extension MemberSidebarView {

  struct GroupDMsMemberList: View {
    var channelStore: ChannelStore
    var recipients: [DiscordUser]
    var body: some View {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 2) {
          ForEach(recipients) { recipient in
            MemberRowView(user: recipient)
              .frame(height: 45)
          }
        }
        .padding(.horizontal, 2)
      }
    }
  }
}
