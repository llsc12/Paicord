//
//  ProfilePopoutView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

/// Sheet on iOS, else its the popover on macOS/ipadOS.
struct ProfilePopoutView: View {
  @Environment(\.userInterfaceIdiom) var idiom
  var guild: GuildStore?
  let member: Guild.PartialMember?
  let user: DiscordUser

  var body: some View {
    ScrollView {
      VStack {
        let _ = print(bannerURL(animated: true))
          WebImage(
            url: bannerURL(animated: true),
            options: []
          )
          .resizable()
          .scaledToFit()
        Profile.AvatarWithPresence(
          member: member,
          user: user
        )
        .animated(true)
        .showsAvatarDecoration()
        .frame(maxWidth: 80, maxHeight: 80)
      }
      .minWidth(idiom == .phone ? nil : 300)  // popover limits on larger devices
      .maxWidth(idiom == .phone ? nil : 300)  // popover limits on larger devices
      .minHeight(idiom == .phone ? nil : 400)  // popover limits on larger devices
    }
    .presentationDetents([.medium, .large])
  }

  func bannerURL(animated: Bool) -> URL? {
    let userId = user.id
    if let guildId = guild?.guildId,
      let banner = member?.banner
    {
      return URL(
        string: CDNEndpoint.guildMemberBanner(
          guildId: guildId,
          userId: userId,
          banner: banner
        ).url
          + ((banner.hasPrefix("a_") && animated)
            ? "gif" : "png") + "?size=600"
      )
    } else if let banner = user.banner {
      return URL(
        string: CDNEndpoint.userBanner(
          userId: userId,
          banner: banner
        ).url
          + ((banner.hasPrefix("a_") && animated)
            ? "gif" : "png") + "?size=600"
      )
    }
    return nil
  }
}
