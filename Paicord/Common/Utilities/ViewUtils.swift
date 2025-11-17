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
    guard let id = member?.user?.id ?? user?.id else { return nil }
    if member?.avatar ?? user?.avatar != nil {
      if let guildId, let avatar = member?.avatar {
        return URL(
          string: CDNEndpoint.guildMemberAvatar(
            guildId: guildId,
            userId: id,
            avatar: avatar
          ).url
            + ".\(animated && avatar.starts(with: "a_") ? "gif" : "png")?size=128&animated=\(animated.description)"
        )
      } else if let avatar = user?.avatar {
        return URL(
          string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
            + ".\(animated && avatar.starts(with: "a_") ? "gif" : "png")?size=128&animated=\(animated.description)"
        )
      }
    } else {
      return URL(
        string: CDNEndpoint.defaultUserAvatar(userId: id).url + ".png"
      )
    }
    return nil
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
    guard let userId = user?.id ?? profile?.user.id else { return nil }
    if let guildProfile = profile?.guild_member_profile,
      let guildId = profile?.guild_member_profile?.guild_id,
      let banner = guildProfile.banner, mainProfileBanner == false
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
    guard let guildId = guild?.guildId, let banner = guild?.guild?.banner else {
      return nil
    }
    if banner.starts(with: "a_"), animated {
      return URL(
        string: CDNEndpoint.guildBanner(guildId: guildId, banner: banner)
          .url
          + ".\(animated ? "gif" : "png")?size=600&animated=true"
      )
    } else {
      return URL(
        string: CDNEndpoint.guildBanner(guildId: guildId, banner: banner)
          .url
          + ".png?size=600&animated=false"
      )
    }
  }
}
