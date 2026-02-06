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
import SDWebImageSwiftUI
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
        } else if let guildStore {
          GuildMemberList(guildStore: guildStore, channelStore: channelStore)
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
    @Environment(\.gateway) var gw
    @Environment(\.appState) var appState
    var user: PartialUser

    @State private var profile: DiscordUser.Profile?

    var body: some View {
      ScrollView {
        LazyVStack(alignment: .leading) {
          bannerView

          profileBody
            .padding()
        }
        .task(id: user, grabColor)
        .task(id: user) {
          if user.id != profile?.user.id {
            profile = nil
            await fetchProfile()
          }
        }
      }
      .background(
        Profile.ThemeColorsBackground(
          colors: profile?.user_profile?.theme_colors
        )
        .overlay(.ultraThinMaterial)
      )
    }

    @ViewBuilder
    var bannerView: some View {
      Utils.UserBannerURL(user: user, profile: profile, animated: true) {
        bannerURL in
        WebImage(url: bannerURL) { phase in
          switch phase {
          case .success(let image):
            image
              .resizable()
              .aspectRatio(3, contentMode: .fill)
          default:
            let color =
              profile?.user_profile?.accent_color ?? user.accent_color
            Rectangle()
              .aspectRatio(3, contentMode: .fit)
              .foregroundStyle((color?.asColor() ?? accentColor))
          }
        }
        .reverseMask(alignment: .bottomLeading) {
          Circle()
            .frame(width: 80, height: 80)
            .padding(.leading, 16)
            .scaleEffect(1.15)
            .offset(x: -1, y: 40)
        }
        .overlay(alignment: .bottomLeading) {
          Profile.AvatarWithPresence(user: user)
            .profileAnimated()
            .profileShowsAvatarDecoration()
            .frame(width: 80, height: 80)
            .padding(.leading, 16)
            .offset(y: 40)
        }
        .padding(.bottom, 30)
      }
    }

    @ViewBuilder
    var profileBody: some View {
      LazyVStack(alignment: .leading, spacing: 4) {
        let profileMeta: DiscordUser.Profile.Metadata? = profile?.user_profile
        Text(
          user.global_name ?? user.username ?? "Unknown User"
        )
        .font(.title2)
        .bold()
        .lineLimit(1)
        .minimumScaleFactor(0.5)

        FlowLayout(xSpacing: 8, ySpacing: 2) {
          Group {
            Text(verbatim: "@\(user.username ?? "unknown")")
            if let pronouns = profileMeta?.pronouns ?? user.pronouns,
              !pronouns.isEmpty
            {
              Text(verbatim: "•")
              Text(pronouns)
            }
          }
          .font(.subheadline)
          .foregroundStyle(.secondary)

          Profile.BadgesView(profile: profile, user: user)
        }

        if let bio = profileMeta?.bio ?? profile?.user_profile?.bio {
          MarkdownText(content: bio)
            .equatable()
        }
      }
    }

    @Sendable
    func fetchProfile() async {
      guard profile == nil else { return }
      let res = try? await gw.client.getUserProfile(
        userID: user.id,
        withMutualGuilds: true,
        withMutualFriends: true,
        withMutualFriendsCount: true
      )
      do {
        // ensure request was successful
        try res?.guardSuccess()
        let profile = try res?.decode()
        self.profile = profile
      } catch {
        if let error = res?.asError() {
          appState.error = error
        } else {
          appState.error = error
        }
      }
    }

    @State var accentColor = Color.clear

    @Sendable
    func grabColor() async {
      let cc = CCColorCube()
      // use sdwebimage's image manager, get the avatar image and extract colors using colorcube
      guard
        let avatarURL = Utils.fetchUserAvatarURL(
          user: user,
          animated: false
        )
      else {
        return
      }
      let imageManager: SDWebImageManager = .shared
      imageManager.loadImage(
        with: avatarURL,
        progress: nil
      ) { image, _, error, _, _, _ in
        guard let image else {
          return
        }
        let colors = cc.extractColors(
          from: image,
          flags: [.orderByBrightness, .avoidBlack, .avoidWhite]
        )
        if let firstColor = colors?.first {
          print(
            "[Profile] Extracted accent color: \(firstColor.debugDescription)"
          )
          DispatchQueue.main.async {
            self.accentColor = Color(firstColor)
          }
        } else {
          print("[Profile] No colors extracted from avatar.")
        }
      }
    }
  }
}
