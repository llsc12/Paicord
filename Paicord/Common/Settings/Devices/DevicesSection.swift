//
//  DevicesSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var devicesSection: some SettingsContent {
    SettingsGroup("Devices", systemImage: "pc") {
      DevicesSettingsView()
    }
  }
}

private struct DevicesSettingsView: View {
  @Environment(\.openURL) var openURL

  var body: some View {
    Section {
      Button("Manage Active Sessions") {
        if let url = URL(string: "https://discord.com/settings/sessions") {
          openURL(url)
        }
      }
    } footer: {
      Text("View and log out of your active sessions on other devices at discord.com.")
    }
  }
}
