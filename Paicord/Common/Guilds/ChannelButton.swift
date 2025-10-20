//
//  ChannelButton.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 24/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

struct ChannelButton: View {
  @Environment(PaicordAppState.self) var appState
  var channels: [ChannelSnowflake: DiscordChannel]
  var channel: DiscordChannel

  var body: some View {
    switch channel.type {
    case .guildText:
      textChannelButton { _ in
        Text("# \(channel.name ?? "unknown")")
      }
    case .dm:
      textChannelButton { hovered in
        HStack {
          if let user = channel.recipients?.first {
            Profile.Avatar(member: nil, user: user)
              .padding(2)
          }
          Text(
            channel.name ?? channel.recipients?.map({
              $0.global_name ?? $0.username
            }).joined(separator: ", ") ?? "Unknown Channel"
          )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 38)
        .padding(4)
        .background {
          if hovered,
            let nameplate = channel.recipients?.first?.collectibles?.nameplate
          {
            Profile.NameplateView(nameplate: nameplate)
              .opacity(0.5)
              .transition(.opacity.animation(.default))
          }
        }
        .clipShape(.rounded)
      }
      .buttonStyle(.borderless)
    case .groupDm:
      textChannelButton { _ in
        HStack {
          if let icon = channel.icon {
            let url = URL(
              string: CDNEndpoint.channelIcon(channelId: channel.id, icon: icon)
                .url + ".png?size=80"
            )
            WebImage(url: url)
              .resizable()
              .scaledToFit()
              .clipShape(.circle)
              .padding(2)
          }
          Text(
            channel.name ?? channel.recipients?.map({
              $0.global_name ?? $0.username
            }).joined(separator: ", ") ?? "Unknown Group DM"
          )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 38)
        .padding(4)
      }
      .buttonStyle(.borderless)
    case .guildCategory:
      let expectedParentID = channel.id
      let childChannels = channels.values
        .filter { $0.parent_id ?? (try! .makeFake()) == expectedParentID }
        .sorted { ($0.position ?? 0) < ($1.position ?? 0) }
        .map { $0.id }

      category(channelIDs: childChannels)
    case .guildVoice:
      textChannelButton { _ in
        Text(Image(systemName: "speaker.wave.2.fill"))
          + Text(" \(channel.name ?? "unknown")")
      }
      .disabled(true)
    default:
      textChannelButton { _ in
        VStack(alignment: .leading) {
          Text(channel.name ?? "unknown")
          Text(String(describing: channel.type))
        }
      }
      .disabled(true)
    }
  }

  // Shim
  struct TextChannelButton<Content: View>: View {
    @Environment(PaicordAppState.self) var appState
    @State private var isHovered = false
    var channels: [ChannelSnowflake: DiscordChannel]
    var channel: DiscordChannel
    var content: (_ hovered: Bool) -> Content
    var body: some View {
      Button {
        appState.selectedChannel = channel.id
        #if os(iOS)
          withAnimation {
            appState.chatOpen.toggle()
          }
        #endif
      } label: {
        content(isHovered)
      }
      .onHover { isHovered = $0 }
    }
  }

  /// Button that switches the chat to the given channel when clicked
  @ViewBuilder
  func textChannelButton<Content: View>(
    @ViewBuilder label: @escaping (_ hovered: Bool) -> Content
  )
    -> some View
  {
    TextChannelButton(
      channels: channels,
      channel: channel
    ) { hovered in
      label(hovered)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          Group {
            if hovered {
              Color.gray.opacity(0.2)
            } else {
              Color.clear
            }
          }
          .clipShape(.rounded)
        )
        .padding(.horizontal, 4)
    }
  }

  /// A disclosure group for a category, showing its child channels when expanded
  @ViewBuilder
  func category(channelIDs: [ChannelSnowflake]) -> some View {
    DisclosureGroup {
      ForEach(channelIDs, id: \.self) { channelId in
        if let channel = channels[channelId] {
          ChannelButton(channels: channels, channel: channel)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    } label: {
      Text(channel.name ?? "Unknown Category")
        .font(.headline)
    }
  }
}
