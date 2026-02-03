//
//  DMProfilePanel.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 03/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//  

import SwiftUIX
import SDWebImageSwiftUI
import PaicordLib
import ColorCube

extension MemberSidebarView {
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
