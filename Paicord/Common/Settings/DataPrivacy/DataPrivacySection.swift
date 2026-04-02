//
//  DataPrivacySection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var dataPrivacySection: some SettingsContent {
    SettingsGroup("Data & Privacy", systemImage: "hand.raised.fill") {
      DataPrivacySettingsView()
    }
  }
}

private struct DataPrivacySettingsView: View {
  @AppStorage("Paicord.Privacy.AllowDMsFromServerMembers") var allowDMsFromServerMembers: Bool = true
  @AppStorage("Paicord.Privacy.AllowFriendRequestsFromEveryone") var allowFriendRequestsFromEveryone: Bool = true
  @AppStorage("Paicord.Privacy.FilterExplicitMessages") var filterExplicitMessages: Bool = true
  @AppStorage("Paicord.Privacy.AllowActivityStatus") var allowActivityStatus: Bool = true

  @Environment(\.openURL) var openURL

  var body: some View {
    Section("Direct Messages") {
      Toggle("Allow DMs from Server Members", isOn: $allowDMsFromServerMembers)
    }

    Section("Friend Requests") {
      Toggle("Allow Friend Requests from Everyone", isOn: $allowFriendRequestsFromEveryone)
    }

    Section {
      Toggle("Filter Explicit Content", isOn: $filterExplicitMessages)
    } header: {
      Text("Content Filtering")
    } footer: {
      Text("When enabled, explicit content in direct messages is filtered.")
    }

    Section {
      Toggle("Show Activity Status", isOn: $allowActivityStatus)
    } header: {
      Text("Activity")
    } footer: {
      Text("Controls whether your activity (like games you're playing) is shown to others.")
    }

    Section {
      Button("Privacy Policy") {
        if let url = URL(string: "https://discord.com/privacy") {
          openURL(url)
        }
      }
    }
  }
}
