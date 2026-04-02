//
//  ConnectionsSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var connectionsSection: some SettingsContent {
    SettingsGroup("Connections", systemImage: "link") {
      ConnectionsSettingsView()
    }
  }
}

private struct ConnectionsSettingsView: View {
  @Environment(\.openURL) var openURL

  var body: some View {
    Section {
      Button("Manage Connections") {
        if let url = URL(string: "https://discord.com/settings/connections") {
          openURL(url)
        }
      }
    } footer: {
      Text("Link your accounts from services like Steam, Spotify, and YouTube on discord.com.")
    }
  }
}
