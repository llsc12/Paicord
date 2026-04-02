//
//  FamilyCentre.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var familyCentreSection: some SettingsContent {
    SettingsGroup("Family Centre", systemImage: "house") {
      FamilyCentreSettingsView()
    }
  }
}

private struct FamilyCentreSettingsView: View {
  @Environment(\.openURL) var openURL

  var body: some View {
    Section {
      Button("Open Family Centre") {
        if let url = URL(string: "https://discord.com/settings/family-center") {
          openURL(url)
        }
      }
    } footer: {
      Text("Discord's Family Centre lets parents and teens stay connected and informed about each other's activity. Manage Family Centre settings at discord.com.")
    }
  }
}
