//
//  LargeBaseplate.swift
//  Paicord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import DiscordModels
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

// if on macos or ipad
struct LargeBaseplate: View {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  @AppStorage("Paicord.ShowingMembersSidebar") var showingInspector = true
  @Environment(\.theme) var theme

  @State var currentGuildStore: GuildStore? = nil
  @State var currentChannelStore: ChannelStore? = nil

  @State private var columnVisibility: NavigationSplitViewVisibility =
    .doubleColumn

  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      SidebarView(currentGuildStore: $currentGuildStore)
        .environment(\.guildStore, currentGuildStore)
        .environment(\.channelStore, currentChannelStore)
        .safeAreaInset(edge: .bottom, spacing: 0) {
          ProfileBar()
        }
        .toolbar(removing: .sidebarToggle)
        .toolbar {
          Group {
            if columnVisibility != .detailOnly {
              if let currentGuildStore {
                Text(currentGuildStore.guild?.name ?? "Direct Messages")
                  .font(.title2)
                  .bold()
              } else {
                Text("Direct Messages")
                  .font(.title2)
                  .bold()
              }
            }
          }
          .minimumScaleFactor(0.5)
        }
        .navigationSplitViewColumnWidth(min: 280, ideal: 310, max: 360)

    } detail: {
      Group {
        if let currentChannelStore {
          switch appState.selectedChannel {
          case .textChannel, .thread:
            textChannelLayout(currentChannelStore)
          case .voiceChannel:
            voiceChannelLayout(currentChannelStore)
          case .dashboard:
            Text(":3")
              .font(.largeTitle)
              .foregroundStyle(.secondary)
          case .friends:
            Text(":3c")
              .font(.largeTitle)
              .foregroundStyle(.secondary)
          }
        } else {
          // placeholder
          VStack {
            Text(":3")
              .font(.largeTitle)
              .foregroundStyle(.secondary)

            Text("Select a channel to start chatting")
              .foregroundStyle(.secondary)
              .font(.title2)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigation) {
          Button {
            withAnimation {
              columnVisibility =
                (columnVisibility != .detailOnly) ? .detailOnly : .doubleColumn
            }
          } label: {
            Label("Toggle Sidebar", systemImage: "sidebar.left")
          }
          .tint(theme.common.tertiaryButton)
        }
      }
    }
    .toolbar {
      if let vm = currentChannelStore,
        vm.channel?.type == .dm || vm.channel?.type == .groupDm,
        gw.voiceChannels.voiceStates[nil]?[vm.channelId] == nil
          && gw.voiceChannels.calls[vm.channelId] == nil
      {
        Button {
          Task {
            await gw.voice.updateVoiceConnection(
              .join(
                channelId: vm.channelId,
                guildId: nil,
              )
            )
          }
        } label: {
          Label("Start Call", systemImage: "phone.fill")
        }
      }

      Button {
        showingInspector.toggle()
      } label: {
        Label("Toggle Member List", systemImage: "sidebar.right")
      }
    }
    .task(id: appState.selectedGuild) {
      if let selected = appState.selectedGuild.guildID {
        self.currentGuildStore = gw.getGuildStore(for: selected)
      } else {
        self.currentGuildStore = nil
      }
    }
    .task(id: appState.selectedChannel) {
      if let selected = appState.selectedChannel.channelID {
        // there is a likelihood that currentGuildStore is wrong when this runs
        // but i dont think it will be a problem maybe.
        self.currentChannelStore = gw.getChannelStore(
          for: selected,
          from: self.currentGuildStore
        )
      } else {
        self.currentChannelStore = nil
      }
    }
  }

  @State var panelSize: CGSize = .zero
  @ViewBuilder
  func textChannelLayout(_ channelStore: ChannelStore) -> some View {
    VStack(spacing: 0) {
      CallView(panelSize: panelSize)
        .zIndex(1)
      ChatView(vm: channelStore)
        .inspector(isPresented: $showingInspector) {
          MemberSidebarView(
            guildStore: currentGuildStore,
            channelStore: currentChannelStore
          )
          .inspectorColumnWidth(min: 250, ideal: 250, max: 360)
        }
        .zIndex(0)
    }
    .id(channelStore.channelId)  // force view update
    .environment(\.guildStore, currentGuildStore)
    .environment(\.channelStore, currentChannelStore)
    .onGeometryChange(
      for: CGSize.self,
      of: { $0.size },
      action: { self.panelSize = $0 }
    )
  }

  @ViewBuilder
  func voiceChannelLayout(_ channelStore: ChannelStore) -> some View {
    VoiceView(vm: channelStore)
      .inspector(isPresented: $showingInspector) {
        ChatView(vm: channelStore)
          .inspectorColumnWidth(min: 400, ideal: 450, max: 750)
      }
      .id(channelStore.channelId)  // force view update
      .environment(\.guildStore, currentGuildStore)
      .environment(\.channelStore, currentChannelStore)
  }
}

#Preview {
  LargeBaseplate()
}
