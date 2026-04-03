//
//  SettingsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Collections
import SettingsKit
import SwiftUIX

struct SettingsView: SettingsContainer {
  @Environment(\.gateway) var gw

  @Environment(\.openURL) var openURL

  @AppStorage("Paicord.Appearance.ChatMessagesAnimated") var chatMessagesAnimated: Bool = false

  var settingsBody: some SettingsContent {
  SettingsGroup("Paicord", .inline) {
    paicordSection
  }

  SettingsGroup("User Settings", .inline) {
    accountSection
    profilesSection
    contentSocialSection
    dataPrivacySection
    familyCentreSection
    authorisedAppsSection
    devicesSection
    connectionsSection
    clipsSection
    scanQRSection
  }

  SettingsGroup("App Settings", .inline) {
    appearanceSection
    accessibilitySection
    voiceVideoSection
    chatSection
    notificationsSection
    keybindsSection
    languageSection
    advancedSection
  }

  debugSection
  }
}
