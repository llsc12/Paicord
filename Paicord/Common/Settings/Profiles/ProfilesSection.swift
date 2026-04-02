//
//  ProfilesSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var profilesSection: some SettingsContent {
    SettingsGroup("Profiles", systemImage: "person.3.fill") {
      ProfilesSettingsView()
        .environment(\.gateway, gw)
    }
  }
}

private struct ProfilesSettingsView: View {
  @Environment(\.gateway) var gw
  @Environment(\.openURL) var openURL

  @AppStorage("Paicord.Profiles.ShowCustomStatus") var showCustomStatus: Bool = true
  @AppStorage("Paicord.Profiles.ShowActivityStatus") var showActivityStatus: Bool = true

  var body: some View {
    Section("Status") {
      Toggle("Show Custom Status", isOn: $showCustomStatus)
      Toggle("Show Activity Status", isOn: $showActivityStatus)
    }

    Section {
      Button("Edit Profile on Discord") {
        if let url = URL(string: "https://discord.com/channels/@me") {
          openURL(url)
        }
      }
    } footer: {
      Text("Profile details like your avatar, banner, and about me can be edited on discord.com or in the official Discord app.")
    }
  }
}
