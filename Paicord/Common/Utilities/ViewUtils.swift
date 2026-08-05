//
//  ViewUtils.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

// big fuckoff collection of tools for use in views

import PaicordLib
import SwiftUIX

enum Utils {
  /// Passes the avatar URL to the content closure, ensure the guild in environment is correct for the member.
  struct UserAvatarURL<Content: View>: View {
    @Environment(\.guildStore) var guild
    var member: Guild.PartialMember?
    var user: PartialUser?
    var animated: Bool = false

    @ViewBuilder var content: (URL?) -> Content

    var body: some View {
      content(
        Utils.fetchUserAvatarURL(
          member: member,
          guildId: guild?.guildId,
          user: user,
          animated: animated
        )
      )
    }
  }

  static func fetchUserAvatarURL(
    member: Guild.PartialMember? = nil,
    guildId: GuildSnowflake? = nil,
    user: PartialUser?,
    animated: Bool
  ) -> URL? {
    DiscordImageURL.userAvatar(
      member: member,
      guildId: guildId,
      user: user,
      animated: animated
    )
  }

  struct UserBannerURL<Content: View>: View {
    var user: PartialUser?
    var profile: DiscordUser.Profile?
    var mainProfileBanner: Bool = false
    var animated: Bool = false
    @ViewBuilder var content: (URL?) -> Content

    var body: some View {
      content(
        Utils.fetchUserBannerURL(
          user: user,
          profile: profile,
          mainProfileBanner: mainProfileBanner,
          animated: animated
        )
      )
    }
  }

  static func fetchUserBannerURL(
    user: PartialUser?,
    profile: DiscordUser.Profile?,
    mainProfileBanner: Bool,
    animated: Bool
  ) -> URL? {
    DiscordImageURL.userBanner(
      user: user,
      profile: profile,
      mainProfileBanner: mainProfileBanner,
      animated: animated
    )
  }

  struct GuildBannerURL<Content: View>: View {
    var guild: GuildStore?
    var animated: Bool = false
    @ViewBuilder var content: (URL?) -> Content

    var body: some View {
      content(
        Utils.fetchGuildBannerURL(
          guild: guild,
          animated: animated
        )
      )
    }
  }

  static func fetchGuildBannerURL(guild: GuildStore?, animated: Bool) -> URL? {
    DiscordImageURL.guildBanner(
      guildId: guild?.guildId,
      banner: guild?.guild?.banner,
      animated: animated
    )
  }
}
