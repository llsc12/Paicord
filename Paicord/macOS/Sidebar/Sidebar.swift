//
//  Sidebar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

struct SidebarView: View {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState

  @Binding var currentGuildStore: GuildStore?

  var body: some View {
    HStack(spacing: 0) {
      guildScroller
        .frame(width: 65)
      if let guild = currentGuildStore {
        GuildView(guild: guild)
      } else {
        DMsView()
      }
    }
  }

  @ViewBuilder
  var guildScroller: some View {
    GuildScrollBar()
      .scrollIndicators(.never)
  }
}
