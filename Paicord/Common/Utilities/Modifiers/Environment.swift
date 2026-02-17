//
//  Environment.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 06/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

// Some new environment values for storing things like the gateway, app state, and optional values like the current guild or channel stores.

import PaicordLib
import SwiftUI

extension EnvironmentValues {
  @Entry var appState: PaicordAppState = .init()
  @Entry var gateway: GatewayStore = .shared

  @Entry var guildStore: GuildStore?
  @Entry var channelStore: ChannelStore?

  @Entry var challenges: Challenges?
}

extension FocusedValues {
  @Entry var appState: PaicordAppState?
}
