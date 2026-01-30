//
//  ProfilePopoutView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import ColorCube
import PaicordLib
import SDWebImageSwiftUI
import SwiftPrettyPrint
import SwiftUIX

/// Sheet on iOS, else its the popover on macOS/ipadOS.
struct ProfilePopoutView: View {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  @Environment(\.userInterfaceIdiom) var idiom
  @Environment(\.channelStore) var channel
  var guild: GuildStore?
  let member: Guild.PartialMember?
  let user: PartialUser

  @Environment(\.colorScheme) var systemColorScheme
  @State private var profile: DiscordUser.Profile?
  @State private var showMainProfile: Bool = false

  public init(
    guild: GuildStore? = nil,
    member: Guild.PartialMember? = nil,
    user: PartialUser,
    profile: DiscordUser.Profile? = nil
  ) {
    self.guild = guild
    self.member = member
    self.user = user
    self._profile = State(initialValue: profile)
  }

  var colorScheme: ColorScheme? {
    // if there is a first theme color, get it
    guard
      let firstColor =
        showMainProfile
        ? profile?.user_profile?.theme_colors?.first
        : profile?.guild_member_profile?.theme_colors?.first
          ?? profile?.user_profile?.theme_colors?.first
    else {
      return nil
    }
    return firstColor.asColor()?.suggestedColorScheme()
  }

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        bannerView

        profileBody
          .padding()
      }
      .minWidth(idiom == .phone ? nil : 300)  // popover limits on larger devices
      .maxWidth(idiom == .phone ? nil : 300)  // popover limits on larger devices
      .task(fetchProfile)
      .task(grabColor)  // way faster than profile fetch
      .scenePadding(.bottom)
    }
    .minHeight(idiom == .phone ? nil : 400)  // popover limits on larger devices
    .presentationDetents([.medium, .large])
    .scrollClipDisabled()
    .background(
      Profile.ThemeColorsBackground(
        colors: showMainProfile
          ? profile?.user_profile?.theme_colors
          : profile?.guild_member_profile?.theme_colors
            ?? profile?.user_profile?.theme_colors
      )
      .overlay(.ultraThinMaterial)
    )
    .ignoresSafeArea(.container, edges: .bottom)
    .environment(\.colorScheme, colorScheme ?? systemColorScheme)
    #if os(iOS)
      .presentationBackground(.ultraThinMaterial)
    #endif
  }

  @ViewBuilder
  var bannerView: some View {
    Utils.UserBannerURL(
      user: user,
      profile: profile,
      mainProfileBanner: showMainProfile,
      animated: true
    ) { bannerURL in
      WebImage(url: bannerURL) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .aspectRatio(3, contentMode: .fill)
        default:
          let color =
            showMainProfile
            ? profile?.user_profile?.theme_colors?.first
              ?? profile?.user_profile?.accent_color
            : profile?.guild_member_profile?.theme_colors?.first ?? profile?
              .user_profile?.theme_colors?.first ?? profile?
              .guild_member_profile?.accent_color
              ?? profile?.user_profile?.accent_color
          Rectangle()
            .aspectRatio(3, contentMode: .fit)
            .foregroundStyle(color?.asColor() ?? accentColor)
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
        Profile.AvatarWithPresence(
          member: member,
          user: user
        )
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
      let profileMeta: DiscordUser.Profile.Metadata? = {
        if showMainProfile {
          return profile?.user_profile
        } else {
          return profile?.guild_member_profile ?? profile?.user_profile
        }
      }()
      Text(
        member?.nick ?? user.global_name ?? user.username ?? "Unknown User"
      )
      .font(.title2)
      .bold()
      .lineLimit(1)
      .minimumScaleFactor(0.5)

      FlowLayout(xSpacing: 8, ySpacing: 2) {
        Group {
          Text("@\(user.username ?? "unknown")")
          if let pronouns = profileMeta?.pronouns
            ?? (showMainProfile
              ? user.pronouns : member?.pronouns ?? user.pronouns),
            !pronouns.isEmpty
          {
            Text("•")
            Text(pronouns)
          }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)

        Profile.BadgesView(
          profile: profile,
          member: member,
          user: user
        )
      }

      if let bio =
        (profileMeta?.bio ?? profile?.user_profile?.bio)?.isEmpty ?? true
        ? profile?.user_profile?.bio
        : profileMeta?.bio ?? profile?.user_profile?.bio
      {
        MarkdownText(content: bio, channelStore: channel)
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
      withMutualFriendsCount: true,
      guildID: guild?.guildId
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
    let m: Guild.PartialMember? = showMainProfile ? nil : member
    guard
      let avatarURL = Utils.fetchUserAvatarURL(
        member: m,
        guildId: guild?.guildId,
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
        DispatchQueue.main.async {
          self.accentColor = Color(firstColor)
        }
      } else {
      }
    }
  }
}
