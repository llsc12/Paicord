//
//  LargeBaseplate.swift
//  Paicord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX
import DiscordModels

// if on macos or ipad
struct LargeBaseplate: View {
  @Environment(GatewayStore.self) var gw
  @Environment(PaicordAppState.self) var appState
  @AppStorage("Paicord.ShowingMembersSidebar") var showingInspector = true

  @State var currentGuildStore: GuildStore? = nil
  @State var currentChannelStore: ChannelStore? = nil

  #if os(macOS)
    @Weak var splitViewController: NSSplitViewController?
  #endif

  var body: some View {
    NavigationSplitView {
      SidebarView(currentGuildStore: $currentGuildStore)
        .safeAreaInset(edge: .bottom, spacing: 0) {
          ProfileBar()
        }
        #if os(macOS)
          .introspect(
            .navigationSplitView,
            on: .macOS(.v14...),
            scope: .ancestor
          ) { (splitView: NSSplitView) -> Void in
            self.splitViewController =
              (splitView.delegate as? NSSplitViewController)
          }
        #endif
        .toolbar(removing: .sidebarToggle)
        .toolbar {
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
        .navigationSplitViewColumnWidth(min: 280, ideal: 300, max: 360)

    } detail: {
      Group {
        if let currentChannelStore {
          ChatView(vm: currentChannelStore)
            .environment(currentGuildStore)
            .environment(currentChannelStore)
        } else {
          // placeholder
          Text(":3")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
        }
      }
      #if os(macOS)
        .toolbar {
          ToolbarItem(placement: .navigation) {
            Button {
              splitViewController?.toggleSidebar(nil)
            } label: {
              Label("Toggle Sidebar", systemImage: "sidebar.left")
            }
          }
        }
      #endif
    }
    .inspector(isPresented: $showingInspector) {
      VStack(alignment: .leading) {
        if let store = currentChannelStore,
           let channel = store.channel,
           let recipients: [DiscordUser] = channel.recipients {
            ForEach(recipients, id: \.id) { recipient in
              MemberRowView(user: recipient)
            }
          if let currentUser = gw.accounts.currentAccount?.user {        MemberRowView(user: currentUser)
          }
        } else {
          Text("gm")
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .inspectorColumnWidth(min: 240, ideal: 260, max: 280)
      .padding([.top, .leading], 8)
      .ignoresSafeArea()
    }
    .toolbar {
      Button {
        showingInspector.toggle()
      } label: {
        Label("Toggle Member List", systemImage: "sidebar.right")
      }
    }
    .task(id: appState.selectedGuild) {
      if let selected = appState.selectedGuild {
        self.currentGuildStore = gw.getGuildStore(for: selected)
      } else {
        self.currentGuildStore = nil
      }
    }
    .task(id: appState.selectedChannel) {
      if let selected = appState.selectedChannel {
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
}

#Preview {
  LargeBaseplate()
}
