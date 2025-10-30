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
import SDWebImage
import SwiftPrettyPrint
import SwiftUIX

/// Sheet on iOS, else its the popover on macOS/ipadOS.
struct ProfilePopoutView: View {
  @Environment(GatewayStore.self) var gw
  @Environment(PaicordAppState.self) var appState
  @Environment(\.userInterfaceIdiom) var idiom
  var guild: GuildStore?
  let member: Guild.PartialMember?
  let user: PartialUser

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

  var body: some View {
    ScrollView {
      VStack {
        WebImage(url: bannerURL(animated: true)) { phase in
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
            .padding(.leading, 8)
            .scaleEffect(1.15)
            .offset(x: -0.5, y: 40)
        }
        .overlay(alignment: .bottomLeading) {
          Profile.AvatarWithPresence(
            member: member,
            user: user
          )
          .animated(true)
          .showsAvatarDecoration()
          .frame(width: 80, height: 80)
          .padding(.leading, 8)
          .offset(y: 40)
        }

        Text(
          member?.nick ?? user.global_name ?? user.username ?? "Unknown User"
        )
        .font(.title2)
        .bold()
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        Text("@\(user.username ?? "unknown")")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .minWidth(idiom == .phone ? nil : 300)  // popover limits on larger devices
      .maxWidth(idiom == .phone ? nil : 300)  // popover limits on larger devices
      .task(fetchProfile)
      .task(grabColor)
    }
    .minHeight(idiom == .phone ? nil : 400)  // popover limits on larger devices
    .presentationDetents([.medium, .large])
    .scrollClipDisabled()
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
    guard let avatarURL = self.avatarURL(animated: false) else {
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
        print("[Profile] Extracted accent color: \(firstColor.debugDescription)")
        DispatchQueue.main.async {
          self.accentColor = Color(firstColor)
        }
      } else {
        print("[Profile] No colors extracted from avatar.")
      }
    }
  }

  func avatarURL(animated: Bool) -> URL? {
    if member?.avatar ?? user.avatar != nil {
      let id = user.id
      if let guildId = guild?.guildId, let avatar = member?.avatar {
        return URL(
          string: CDNEndpoint.guildMemberAvatar(
            guildId: guildId,
            userId: id,
            avatar: avatar
          ).url
            + ".\(animated && avatar.starts(with: "a_") ? "gif" : "png")?size=128&animated=\(animated.description)"
        )
      } else if let avatar = user.avatar {
        return URL(
          string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
            + ".\(animated && avatar.starts(with: "a_") ? "gif" : "png")?size=128&animated=\(animated.description)"
        )
      }
    } else {
      return URL(
        string: CDNEndpoint.defaultUserAvatar(userId: user.id).url + ".png"
      )
    }
    return nil
  }

  func bannerURL(animated: Bool) -> URL? {
    let userId = user.id
    if let guildProfile = profile?.guild_member_profile,
      let guildId = profile?.guild_member_profile?.guild_id,
      let banner = guildProfile.banner, self.showMainProfile == false
    {
      return URL(
        string: CDNEndpoint.guildMemberBanner(
          guildId: guildId,
          userId: userId,
          banner: banner
        ).url
          + ((banner.hasPrefix("a_") && animated)
            ? ".gif" : ".png") + "?size=600"
      )
    } else if let banner = profile?.user_profile?.banner {
      return URL(
        string: CDNEndpoint.userBanner(
          userId: userId,
          banner: banner
        ).url
          + ((banner.hasPrefix("a_") && animated)
            ? ".gif" : ".png") + "?size=600"
      )
    }
    return nil
  }
}
