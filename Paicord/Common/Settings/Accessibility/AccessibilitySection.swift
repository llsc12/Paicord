//
//  AccessibilitySection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var accessibilitySection: some SettingsContent {
    SettingsGroup("Accessibility", systemImage: "accessibility.fill") {
      AccessibilitySettingsRows()
    }
  }
}

private struct AccessibilitySettingsRows: View {
  @AppStorage("Paicord.Accessibility.ReduceMotion") var reduceMotion: Bool = false
  @AppStorage("Paicord.Accessibility.LargeText") var largeText: Bool = false
  @AppStorage("Paicord.Accessibility.HighContrast") var highContrast: Bool = false

  @Environment(\.openURL) var openURL

  var body: some View {
    Group {
      SettingsItem("Reduce Motion") {
        Toggle("", isOn: $reduceMotion)
          .onChange(of: reduceMotion) { _, newValue in
            if newValue {
              UserDefaults.standard.set(false, forKey: "Paicord.Appearance.ChatMessagesAnimated")
            }
          }
      }
      SettingsItem("Larger Text") { Toggle("", isOn: $largeText) }
      SettingsItem("Increase Contrast") { Toggle("", isOn: $highContrast) }
      Divider()
      SettingsItem("System Accessibility Settings") {
        Button("Open") {
          #if os(macOS)
          if let url = URL(string: "x-apple.systempreferences:com.apple.preference.universalaccess") {
            openURL(url)
          }
          #else
          if let url = URL(string: "App-Prefs:root=ACCESSIBILITY") {
            openURL(url)
          }
          #endif
        }
      }
    }
  }
}
