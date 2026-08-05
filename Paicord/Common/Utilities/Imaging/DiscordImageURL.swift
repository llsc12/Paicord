//
//  DiscordImageURL.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 05/08/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

// middleman cdn url builder helper
enum DiscordImageURL {

  // MARK: Emoji

  static func customEmoji(
    id: EmojiSnowflake,
    animated: Bool,
    size: Int = 64
  ) -> URL? {
    URL(
      string: CDNEndpoint.customEmoji(emojiId: id).url
        + ".webp?size=\(size)&animated=\(animated.description)"
    )
  }

  // MARK: Avatars

  static func userAvatar(
    member: Guild.PartialMember? = nil,
    guildId: GuildSnowflake? = nil,
    user: PartialUser?,
    animated: Bool,
    size: Int = 128
  ) -> URL? {
    guard let id = member?.user?.id ?? user?.id else { return nil }

    guard member?.avatar ?? user?.avatar != nil else {
      return URL(string: CDNEndpoint.defaultUserAvatar(userId: id).url + ".png")
    }

    if let guildId, let avatar = member?.avatar {
      return animatableURL(
        base: CDNEndpoint.guildMemberAvatar(
          guildId: guildId,
          userId: id,
          avatar: avatar
        ).url,
        hash: avatar,
        animated: animated,
        size: size
      )
    } else if let avatar = user?.avatar {
      return animatableURL(
        base: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url,
        hash: avatar,
        animated: animated,
        size: size
      )
    }
    return nil
  }

  // MARK: Guild icons

  static func guildIcon(
    id: GuildSnowflake,
    icon: String,
    animated: Bool,
    size: Int = 128
  ) -> URL? {
    // discord asks for lossless on animated guild icons specifically
    let wantsAnimation = animated && icon.starts(with: "a_")
    let quality = wantsAnimation ? "&quality=lossless" : ""
    return URL(
      string: CDNEndpoint.guildIcon(guildId: id, icon: icon).url
        + ".webp?size=\(size)\(quality)&animated=\(wantsAnimation.description)"
    )
  }

  // MARK: Channel icons

  static func channelIcon(
    id: ChannelSnowflake,
    icon: String,
    size: Int = 80
  ) -> URL? {
    URL(
      string: CDNEndpoint.channelIcon(channelId: id, icon: icon).url
        + ".webp?size=\(size)"
    )
  }

  // MARK: Banners

  private static func bannerURL(
    base: String,
    hash: String,
    animated: Bool,
    size: Int
  ) -> URL? {
    let wantsAnimation = animated && hash.starts(with: "a_")
    if wantsAnimation {
      return URL(string: base + ".gif?size=\(size)&animated=true")
    }
    return URL(string: base + ".webp?size=\(size)")
  }

  static func userBanner(
    user: PartialUser?,
    profile: DiscordUser.Profile?,
    mainProfileBanner: Bool,
    animated: Bool,
    size: Int = 600
  ) -> URL? {
    guard let userId = user?.id ?? profile?.user.id else { return nil }
    if let guildProfile = profile?.guild_member_profile,
      let guildId = guildProfile.guild_id,
      let banner = guildProfile.banner, mainProfileBanner == false
    {
      return bannerURL(
        base: CDNEndpoint.guildMemberBanner(
          guildId: guildId,
          userId: userId,
          banner: banner
        ).url,
        hash: banner,
        animated: animated,
        size: size
      )
    } else if let banner = profile?.user_profile?.banner {
      return bannerURL(
        base: CDNEndpoint.userBanner(userId: userId, banner: banner).url,
        hash: banner,
        animated: animated,
        size: size
      )
    }
    return nil
  }

  static func guildBanner(
    guildId: GuildSnowflake?,
    banner: String?,
    animated: Bool,
    size: Int = 600
  ) -> URL? {
    guard let guildId, let banner else { return nil }
    return bannerURL(
      base: CDNEndpoint.guildBanner(guildId: guildId, banner: banner).url,
      hash: banner,
      animated: animated,
      size: size
    )
  }

  // MARK: Profile extras

  /// Decorations only animate as apng, via `passthrough`. asking for webp gets a still.
  static func avatarDecoration(
    asset: String,
    animated: Bool,
    size: Int = 128
  ) -> URL? {
    if animated {
      return URL(
        string: CDNEndpoint.avatarDecoration(asset: asset).url
          + ".png?size=\(size)&passthrough=true"
      )
    }
    return URL(
      string: CDNEndpoint.avatarDecoration(asset: asset).url
        + ".webp?size=\(size)"
    )
  }

  static func profileBadge(icon: String) -> URL? {
    // some badges come through as absolute urls already
    if icon.starts(with: "http") { return URL(string: icon) }
    return URL(string: CDNEndpoint.profileBadge(icon: icon).url + ".webp")
  }

  // MARK: Helpers

  private static func animatableURL(
    base: String,
    hash: String,
    animated: Bool,
    size: Int
  ) -> URL? {
    let wantsAnimation = animated && hash.starts(with: "a_")
    return URL(
      string: base
        + ".webp?size=\(size)&animated=\(wantsAnimation.description)"
    )
  }
}
