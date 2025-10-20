//
//  GuildView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 22/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

struct GuildView: View {
  var guild: GuildStore

  var body: some View {
    ScrollView {
      if let bannerURL = bannerURL(animated: true) {  // maybe add animation control?
        AnimatedImage(url: bannerURL)
          .resizable()
          .aspectRatio(16 / 9, contentMode: .fill)
      }
      #if os(iOS)
        HStack {
          Text(guild.guild?.name ?? "Unknown Guild")
            .font(.title2)
        }
      #endif

      let uncategorizedChannels = guild.channels.values
        .filter { $0.parent_id == nil }
        .sorted { ($0.position ?? 0) < ($1.position ?? 0) }

      ForEach(uncategorizedChannels) { channel in
        ChannelButton(channels: guild.channels, channel: channel)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .frame(maxWidth: .infinity)
    .background(.tableBackground.opacity(0.5))
    .roundedCorners(radius: 10, corners: .topLeft)
  }

  func bannerURL(animated: Bool) -> URL? {
    guard let banner = guild.guild?.banner else { return nil }
    if banner.starts(with: "a_"), animated {
      return URL(
        string: CDNEndpoint.guildBanner(guildId: guild.guildId, banner: banner)
          .url
          + ".\(animated ? "gif" : "png")?size=600&animated=true"
      )
    } else {
      return URL(
        string: CDNEndpoint.guildBanner(guildId: guild.guildId, banner: banner)
          .url
          + ".png?size=600&animated=false"
      )
    }
  }
}
