//
//  ContentSocialSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var contentSocialSection: some SettingsContent {
    SettingsGroup("Content & Social", systemImage: "bubble.left.and.bubble.right") {
      ContentSocialSettingsView()
    }
  }
}

private struct ContentSocialSettingsView: View {
  @AppStorage("Paicord.ContentSocial.ShowSensitiveMedia") var showSensitiveMedia: Bool = false
  @AppStorage("Paicord.ContentSocial.ShowServerBoostNotifications") var showServerBoostNotifications: Bool = true
  @AppStorage("Paicord.ContentSocial.AnimateEmoji") var animateEmoji: Bool = true
  @AppStorage("Paicord.ContentSocial.AnimateStickers") var animateStickers: Bool = true
  @AppStorage("Paicord.ContentSocial.ShowGuildBadges") var showGuildBadges: Bool = true

  var body: some View {
    Section {
      Toggle("Show Age-Restricted Content", isOn: $showSensitiveMedia)
    } header: {
      Text("Content")
    } footer: {
      Text("Allows viewing channels and content marked as age-restricted.")
    }

    Section("Emoji & Stickers") {
      Toggle("Animate Emoji", isOn: $animateEmoji)
      Toggle("Animate Stickers", isOn: $animateStickers)
    }

    Section("Social") {
      Toggle("Show Server Boost Notifications", isOn: $showServerBoostNotifications)
      Toggle("Show Server Badges", isOn: $showGuildBadges)
    }
  }
}
