//
//  QuickSwitcherProviderStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 12/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//  

import Foundation
import PaicordLib
import SwiftPrettyPrint
import SwiftUIX

@Observable
class QuickSwitcherProviderStore: DiscordDataStore {
  var gateway: GatewayStore?

  var eventTask: Task<Void, Never>?

  func setupEventHandling() {
    eventTask = Task { @MainActor in
      guard let gateway = gateway?.gateway else { return }
      for await event in await gateway.events {
        switch event.data {
        default: break
        }
      }
    }
  }
  
  enum SearchResult {
    case user(UserSnowflake)
    case textChannel(ChannelSnowflake)
    case voiceChannel(ChannelSnowflake)
    case guild(GuildSnowflake)
  }
  
//  func search(_ query: String)
}
