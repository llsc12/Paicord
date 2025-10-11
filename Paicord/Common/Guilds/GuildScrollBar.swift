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
	@Environment(GatewayStore.self) var gw

	var body: some View {
		ScrollView {
			LazyVStack {
				GuildButton(guild: nil)  // becomes dms "guild"

				Divider()
					.padding(.horizontal, 8)
				ForEach(0..<gw.settings.userSettings.guildFolders.folders.count, id: \.self) { folderIndex in
					let folder = gw.settings.userSettings.guildFolders.folders[folderIndex]
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
