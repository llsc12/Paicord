//
//  DMProfilePanel.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 03/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import ColorCube
import Nuke
import PaicordLib
import SwiftUIX

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
      // macos 26/27 bug workaround
      .padding(.top, 1)
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
        Color.clear
          .aspectRatio(3, contentMode: .fit)
          .overlay {
            let color =
              profile?.user_profile?.accent_color ?? user.accent_color
            NukeImage(url: bannerURL) {
              Rectangle()
                .foregroundStyle((color?.asColor() ?? accentColor))
            }
            .resizable()
            .scaledToFill()
          }
          .frame(maxWidth: .infinity)
          .clipped()
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
      // shares the pipeline with every image on screen, avatar probably cached.
      guard
        let avatarURL = Utils.fetchUserAvatarURL(
          user: user,
          animated: false
        ),
        let image = try? await ImagePipeline.shared.image(for: avatarURL)
      else {
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
        await MainActor.run { self.accentColor = Color(firstColor) }
      } else {
        print("[Profile] No colors extracted from avatar.")
      }
    }
  }
}
