//
//  AuthorisedAppsSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var authorisedAppsSection: some SettingsContent {
    SettingsGroup("Authorised Apps", systemImage: "app") {
      AuthorisedAppsSettingsView()
    }
  }
}

private struct AuthorisedAppsSettingsView: View {
  @Environment(\.openURL) var openURL

  var body: some View {
    Section {
      Button("Manage Authorised Apps") {
        if let url = URL(string: "https://discord.com/settings/authorized-apps") {
          openURL(url)
        }
      }
    } footer: {
      Text("View and revoke access for third-party apps connected to your Discord account at discord.com.")
    }
  }
}
