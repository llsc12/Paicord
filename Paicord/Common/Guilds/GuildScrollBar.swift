//
//  GuildScrollBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

struct GuildScrollBar: View {
  @Environment(\.gateway) var gw

  var body: some View {
    ScrollFadeMask {
      LazyVStack {
        GuildButton(guild: nil)  // becomes dms "guild"

        Divider()
          .padding(.horizontal, 8)
        
        // the usersettings guild folders can sometimes not cover all guilds
        // in this case, we need to find the unlisted guilds, and order by join date, newest first
        // this code covers the case where the user never reordered their guilds.
        // reordering would trigger usage of the guild folders method of organisation.
        if let userID = gw.user.currentUser?.id {
          let unlistedGuilds = gw.user.guilds.values.filter { guild in
            !gw.settings.userSettings.guildFolders.folders.contains { folder in
              folder.guildIds.contains(where: {
                $0.description == guild.id.rawValue
              })
            }
          }.sorted(by: { a, b in
            let aMember = gw.user.guilds[a.id]?.members?.first(where: { $0.user?.id == userID })
            let bMember = gw.user.guilds[b.id]?.members?.first(where: { $0.user?.id == userID })
            return (bMember?.joined_at ?? .init(date: .now)) < (aMember?.joined_at ?? .init(date: .now))
          })
          
          ForEach(unlistedGuilds, id: \.id) { guild in
            GuildButton(guild: guild)
          }
        }
        ForEach(
          0..<gw.settings.userSettings.guildFolders.folders.count,
          id: \.self
        ) { folderIndex in
          let folder = gw.settings.userSettings.guildFolders.folders[
            folderIndex
          ]
          Group {
            if folder.hasID == false {
              // anon folder, should have only one guild id
              if let guildIDString = folder.guildIds.first?.description,
                let guild = gw.user.guilds[GuildSnowflake(guildIDString)]
              {
                GuildButton(guild: guild)
              }
            } else {
              let guilds = folder.guildIds.compactMap { guildID in
                let guildID = GuildSnowflake(guildID.description)
                return gw.user.guilds[guildID]
              }
              GuildButton(folder: folder, guilds: guilds)
            }
          }
        }
      }
      .safeAreaPadding(.all, 10)
    }
  }
}
