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
  @Environment(\.guildStore) var guild
  var channels: [ChannelSnowflake: DiscordChannel]
  var channel: DiscordChannel

  var body: some View {
    // switch channel type
    switch channel.type {
    case .dm:
      textChannelButton { hovered in
        let selected = appState.selectedChannel.channelID == channel.id
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
          VStack(alignment: .leading, spacing: 2){
            Text(
              channel.name ?? channel.recipients?.map({
                $0.global_name ?? $0.username
              }).joined(separator: ", ") ?? "Unknown Group DM"
            )
            .lineLimit(1)

            Text("\(channel.recipients?.count ?? 0) members")
              .font(.caption)
          }
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
      // sort by type and position
//        .sorted { ($0.position ?? 0) < ($1.position ?? 0) }
        .sorted { lhs, rhs in
          let lhsType = [DiscordChannel.Kind.guildVoice, .guildStageVoice].contains(lhs.type ?? .guildText)
          let rhsType = [DiscordChannel.Kind.guildVoice, .guildStageVoice].contains(rhs.type ?? .guildText)
          if lhsType == rhsType {
            return (lhs.position ?? 0) < (rhs.position ?? 0)
          } else {
            return (lhsType && !rhsType)
          }
        }
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
      voiceChannelButton { hovered in
        HStack {
          if guild?.hasPermission(channel: channel, .connect) == false {
            Image(systemName: "lock.fill")
              .imageScale(.medium)
          } else {
            Image(systemName: "speaker.wave.2.fill")
              .imageScale(.medium)
          }
          Text(channel.name ?? "unknown")
          Spacer()
          
          if hovered {
            Button {
              appState.selectedChannel = .voiceChannel(channel.id)
            } label: {
              Image(systemName: "bubble.fill")
                .imageScale(.small)
            }
            .buttonStyle(.borderless)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .minHeight(35)
        .padding(.horizontal, 12)
      }
      .tint(.primary)
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
          appState.selectedChannel = .textChannel(channel.id)
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
            if appState.selectedChannel.channelID == channel.id {
              Color.gray.opacity(0.13)
            } else {
              Color.clear
            }
          }
          .clipShape(.rounded)
        )
    }
  }

  struct VoiceChannelButton<Content: View>: View {
    @Environment(\.appState) var appState
    @Environment(\.gateway) var gw
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
    var canConnect: Bool {
      guard let guild else { return false }
      return guild.hasPermission(
        channel: channel,
        .connect
      )
    }
    var body: some View {
      if !shouldHide {
        Button {
          Task {
            appState.selectedChannel = .voiceChannel(channel.id)
            guard let guildID = appState.selectedGuild.guildID, canConnect else { return }
            await gw.voice.updateVoiceConnection(
              .join(
                channelId: channel.id,
                guildId: guildID,
              )
            )
          }
        } label: {
          content(isHovered)
        }
        .onHover { isHovered = $0 }
        .buttonStyle(.borderless)
        .disabled(!canConnect)
      }
    }
  }

  struct VoiceChannelUsers: View {
    @Environment(\.gateway) var gw
    @Environment(\.appState) var appState
    var channel: DiscordChannel

    var body: some View {
      let voiceChannels = gw.voiceChannels
      if let guildID = appState.selectedGuild.guildID, let voiceStates = voiceChannels.voiceStates[guildID]?[
        channel.id
      ], !voiceStates.isEmpty {
        LazyVStack(spacing: 2) {
          ForEach(voiceStates.values) { state in
            UserButton(state: state)
          }
        }
        .padding(.leading, 32)
        .padding(.bottom, 4)
      }
    }

    struct UserButton: View {
      var state: VoiceState
      @Environment(\.guildStore) var guildStore
      @Environment(\.gateway) var gw
      var vgw: VoiceConnectionStore { gw.voice }
      @State var showPopover = false
      
      var isDeafened: Bool {
        state.self_deaf || state.deaf
      }
      
      var isServerDeafened: Bool {
        state.deaf
      }
      
      var isMuted: Bool {
        state.self_mute || state.mute
      }
      
      var isServerMuted: Bool {
        state.mute
      }
      
      var isSpeaking: Bool {
        if let state = vgw.usersSpeakingState[state.user_id] {
          return state.isEmpty == false
        }
        return false
      }
      
      var member: Guild.PartialMember? {
        state.member ?? guildStore?.members[state.user_id]
      }
      
      var user: PartialUser? {
        state.member?.user?.toPartialUser() ?? gw.user.users[state.user_id]
      }
      
      var body: some View {
        Button {
          if user != nil {
            showPopover.toggle()
          }
        } label: {
          HStack {
            Profile.Avatar(
              member: member,
              user: user
            )
            .frame(maxWidth: 20, maxHeight: 20)
            .overlay(
              Circle()
                .fill(Color.clear)
                .stroke(isSpeaking ? Color.green : Color.clear, lineWidth: 2)
            )

            Text(
              state.member?.nick ?? user?.global_name ?? user?.username
                ?? "Unknown User"
            )
            .lineLimit(1)
            .foregroundStyle(isSpeaking ? .primary : .secondary)
            
            Spacer()
            
            if isMuted {
              Image(systemName: "mic.slash.fill")
                .imageScale(.small)
                .foregroundStyle(isServerMuted ? .red : .secondary)
            }
            
            if isDeafened {
              Image(systemName: "headphones.slash")
                .imageScale(.small)
                .foregroundStyle(isServerDeafened ? .red : .secondary)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 6)
          .padding(.horizontal, 8)
        }
        .buttonStyle(.borderlessHoverEffect(isSelected: showPopover, selectionShape: .init(.rounded)))
        .popover(isPresented: $showPopover) {
          if let user {
            ProfilePopoutView(
              guild: guildStore,
              member: member,
              user: user
            )
          }
        }
      }
    }
  }

  /// Button that triggers voice channel actions.
  @ViewBuilder
  func voiceChannelButton<Content: View>(
    @ViewBuilder label: @escaping (_ hovered: Bool) -> Content
  )
    -> some View
  {
    LazyVStack(spacing: 2) {
      VoiceChannelButton(
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
              if appState.selectedChannel.channelID == channel.id {
                Color.gray.opacity(0.13)
              } else {
                Color.clear
              }
            }
            .clipShape(.rounded)
          )
      }

      VoiceChannelUsers(channel: channel)
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
