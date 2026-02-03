//
//  ProfileView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import ColorCube
import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

struct ProfileView: View {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  @Environment(\.colorScheme) var systemColorScheme
  @State var colorScheme: ColorScheme? = nil

  var user: PartialUser? {
    gw.user.currentUser?.toPartialUser()
  }

  @State var settingsSheetPresented = false

  @State var profile: DiscordUser.Profile? = nil
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(alignment: .leading) {
          bannerView
            .overlay(alignment: .topTrailing) {
              HStack {
                Button {
                  settingsSheetPresented = true
                } label: {
                  Image(systemName: "gearshape.fill")
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.borderless)
                .tint(.primary)
                .sheet(isPresented: $settingsSheetPresented) {
                  SettingsView()
                }
              }
              .padding(8)
            }

          profileBody
            .padding()
        }
        .task(fetchProfile)
        .task(grabColor)  // way faster than profile fetch
      }
      .scrollClipDisabled()
      .background(
        Profile.ThemeColorsBackground(
          colors: profile?.user_profile?.theme_colors
        )
      )
      .environment(\.colorScheme, colorScheme ?? systemColorScheme)
    }
  }

  @ViewBuilder
  var bannerView: some View {
    Utils.UserBannerURL(
      user: user,
      profile: profile,
      mainProfileBanner: true,
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
            profile?.user_profile?.theme_colors?.first
            ?? profile?.user_profile?.accent_color
            ?? user?.accent_color
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
      let profileMeta: DiscordUser.Profile.Metadata? = profile?.user_profile
      Text(
        user?.global_name ?? user?.username ?? "Unknown User"
      )
      .font(.title2)
      .bold()
      .lineLimit(1)
      .minimumScaleFactor(0.5)

      FlowLayout(xSpacing: 8, ySpacing: 2) {
        Group {
          Text(verbatim: "@\(user?.username ?? "unknown")")
          if let pronouns = profileMeta?.pronouns
            ?? user?.pronouns,
            !pronouns.isEmpty
          {
            Text(verbatim: "•")
            Text(pronouns)
          }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)

        HStack(spacing: 4) {
          let badges = profile?.badges ?? []
          ForEach(badges) { badge in
            Profile.Badge(badge: badge)
          }
        }
        .maxHeight(16)
      }

      if let bio =
        (profileMeta?.bio ?? profile?.user_profile?.bio)?.isEmpty ?? true
        ? profile?.user_profile?.bio
        : profileMeta?.bio ?? profile?.user_profile?.bio
      {
        MarkdownText(content: bio)
          .equatable()
      }
    }
  }

  @Sendable
  func fetchProfile() async {
    guard profile == nil else { return }
    guard let user else { return }
    let res = try? await gw.client.getUserProfile(
      userID: user.id,
      withMutualGuilds: false,
      withMutualFriends: false,
      withMutualFriendsCount: false
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
        DispatchQueue.main.async {
          self.accentColor = Color(firstColor)
        }
      } else {
      }
    }
  }
}
