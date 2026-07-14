//
//  UserGuildSettingsStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib
import SwiftPrettyPrint

// https://docs.discord.food/topics/read-state#how-unreads-work

@Observable
class UserGuildSettingsStore: DiscordDataStore {
  var gateway: GatewayStore?

  var eventTask: Task<Void, Never>?

  var userGuildSettings: [GuildSnowflake?: Guild.UserGuildSettings] = [:]

  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }
    let events = gateway.events
    eventTask = Task { @MainActor in
      for await event in events {
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
