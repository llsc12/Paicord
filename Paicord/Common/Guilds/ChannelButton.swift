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
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  var channels: [ChannelSnowflake: DiscordChannel]
  var channel: DiscordChannel

  var body: some View {
    // switch channel type
    switch channel.type {
    case .dm:
      textChannelButton { hovered in
        let selected = appState.selectedChannel == channel.id
        HStack {
          if let user = channel.recipients?.first {
            Profile.AvatarWithPresence(
              member: nil,
              user: user
            )
            .profileAnimated(hovered)
            .profileShowsAvatarDecoration()
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
          if hovered || selected,
            let nameplate = channel.recipients?.first?.collectibles?.nameplate
          {
            Profile.NameplateView(nameplate: nameplate)
              .opacity(0.5)
              .transition(.opacity.animation(.default))
              .nameplateAnimated(hovered)
          }
        }
        .clipShape(.rounded)
      }
      .tint(.primary)
      .padding(.horizontal, 4)
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
          } else {
            VStack {
              if let firstUser = channel.recipients?.first(where: {
                $0.id != gw.user.currentUser?.id
              }),
                let lastUser = channel.recipients?.last(where: {
                  $0.id != gw.user.currentUser?.id && $0.id != firstUser.id
                })
              {
                Group {
                  Profile.Avatar(
                    member: nil,
                    user: firstUser.toPartialUser()
                  )
                  .profileShowsAvatarDecoration()
                  .scaleEffect(0.75, anchor: .topLeading)
                  .overlay(
                    Profile.Avatar(
                      member: nil,
                      user: lastUser.toPartialUser()
                    )
                    .profileShowsAvatarDecoration()
                    .scaleEffect(0.75, anchor: .bottomTrailing)
                  )
                }
                .padding(2)
              } else if let user = channel.recipients?.first {
                Profile.Avatar(
                  member: nil,
                  user: user.toPartialUser()
                )
                .profileShowsAvatarDecoration()
                .padding(2)
              } else {
                Circle()
                  .fill(Color.gray)
                  .padding(2)
              }
            }
            .aspectRatio(1, contentMode: .fit)
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
      .tint(.primary)
      .padding(.horizontal, 4)

    case .guildCategory:
      let expectedParentID = channel.id
      let childChannels = channels.values
        .filter { $0.parent_id ?? (try! .makeFake()) == expectedParentID }
        .sorted { ($0.position ?? 0) < ($1.position ?? 0) }
        .map { $0.id }

      category(channelIDs: childChannels)
        .tint(.primary)
    case .guildText:
      textChannelButton { _ in
        HStack {
          Image(systemName: "number")
            .imageScale(.medium)
          Text(channel.name ?? "unknown")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .minHeight(35)
        .padding(.horizontal, 12)
      }
      .tint(.primary)
    case .guildAnnouncement:
      textChannelButton { _ in
        HStack {
          Image(systemName: "megaphone.fill")
            .imageScale(.medium)
          Text(channel.name ?? "unknown")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .minHeight(35)
        .padding(.horizontal, 12)
      }
      .tint(.primary)
    case .guildVoice:
      textChannelButton { _ in
        HStack {
          Image(systemName: "speaker.wave.2.fill")
            .imageScale(.medium)
          Text(channel.name ?? "unknown")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .minHeight(35)
        .padding(.horizontal, 12)
      }
      .tint(.primary)
      .disabled(true)
    default:
      textChannelButton { _ in
        HStack {
          Image(systemName: "number")
            .imageScale(.medium)
          VStack(alignment: .leading) {
            Text(channel.name ?? "unknown")
            Text(verbatim: "\(channel.type!)")
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .minHeight(35)
        .padding(.horizontal, 12)
      }
      .tint(.primary)
      .disabled(true)
    }
  }

  // Shim
  struct TextChannelButton<Content: View>: View {
    @Environment(\.appState) var appState
    @Environment(\.guildStore) var guild
    @State private var isHovered = false
    var channels: [ChannelSnowflake: DiscordChannel]
    var channel: DiscordChannel
    var content: (_ hovered: Bool) -> Content

    var shouldHide: Bool {
      guard let guild else { return false }
      return guild.hasPermission(
        channel: channel,
        .viewChannel
      ) == false
    }
    var body: some View {
      if !shouldHide {
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
        .buttonStyle(.borderless)
      }
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
        .lineLimit(1)
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
        .background(
          Group {
            if appState.selectedChannel == channel.id {
              Color.gray.opacity(0.13)
            } else {
              Color.clear
            }
          }
          .clipShape(.rounded)
        )
    }
  }

  struct CategoryButton: View {
    @Environment(\.userInterfaceIdiom) var idiom
    @Environment(\.guildStore) var guild
    var channelIDs: [ChannelSnowflake]
    var channels: [ChannelSnowflake: DiscordChannel]
    var channel: DiscordChannel

    @State private var isExpanded: Bool {
      didSet {
        UserDefaults.standard.set(
          isExpanded,
          forKey: "GuildCategory.\(channel.id).Expanded"
        )
      }
    }

    /// Set by initialiser, hides the category if there are no visible channels inside it.
    var shouldHide: Bool {
      // reduce channels by bool
      let channels = channelIDs.compactMap { self.channels[$0] }
      let allHidden = channels.reduce(true) { partialResult, channel in
        partialResult
          && guild?.hasPermission(channel: channel, .viewChannel)
            == false
      }
      return allHidden
    }

    init(
      channelIDs: [ChannelSnowflake],
      channels: [ChannelSnowflake: DiscordChannel],
      channel: DiscordChannel
    ) {
      self.channelIDs = channelIDs
      self.channels = channels
      self.channel = channel
      self._isExpanded = .init(
        initialValue: UserDefaults.standard.bool(
          forKey: "GuildCategory.\(channel.id).Expanded"
        )
      )
    }

    var body: some View {
      if !shouldHide {
        VStack(spacing: 1) {
          Button {
            withAnimation(.smooth(duration: 0.2)) {
              isExpanded.toggle()
            }
          } label: {
            HStack {
              if idiom == .phone || idiom == .pad {
                Image(systemName: "chevron.down")
                  .imageScale(.small)
                  .rotationEffect(.degrees(isExpanded ? 0 : -90))
              }
              Text(channel.name ?? "Unknown Category")
                .font(.subheadline)
                .semibold()

              Spacer()

              if idiom == .mac {
                Image(systemName: "chevron.down")
                  .imageScale(.small)
                  .fontWeight(.semibold)
                  .rotationEffect(.degrees(isExpanded ? 0 : -90))
              }

            }
            .foregroundStyle(.secondary)
            .lineLimit(1)
          }
          .padding(.horizontal, 4)
          .buttonStyle(.borderless)

          if isExpanded {
            ForEach(channelIDs, id: \.self) { channelId in
              if let channel = channels[channelId] {
                ChannelButton(channels: channels, channel: channel)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            }
          }
        }.clipped()
      }
    }
  }

  /// A disclosure group for a category, showing its child channels when expanded
  @ViewBuilder
  func category(channelIDs: [ChannelSnowflake]) -> some View {
    CategoryButton(
      channelIDs: channelIDs,
      channels: channels,
      channel: channel
    )
    .padding(.top, 10)
  }
}
