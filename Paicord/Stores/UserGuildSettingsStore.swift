//
//  UserGuildSettingsStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import Foundation
import SwiftPrettyPrint

// https://docs.discord.food/topics/read-state#how-unreads-work

@Observable
class UserGuildSettingsStore: DiscordDataStore {
  var gateway: GatewayStore?

  var eventTask: Task<Void, Never>?
  
  var userGuildSettings: [GuildSnowflake?: Guild.UserGuildSettings] = [:]

  func setupEventHandling() {
    eventTask = Task { @MainActor in
      guard let gateway = gateway?.gateway else { return }
      for await event in await gateway.events {
        switch event.data {
        case .ready(let readyData):
          handleReady(readyData)
        default: break
        }
      }
    }
  }

  private func handleReady(_ readyData: Gateway.Ready) {
    userGuildSettings = readyData.user_guild_settings.reduce(into: [:]) {
      $0[$1.guild_id] = $1
    }
  }
}
