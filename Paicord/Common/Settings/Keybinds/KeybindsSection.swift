//
//  KeybindsSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  @SettingsContentBuilder
  var keybindsSection: some SettingsContent {
    #if os(macOS)
    SettingsGroup("Keybinds", systemImage: "keyboard") {
      KeybindsSettingsView()
    }
    #endif
  }
}

#if os(macOS)
private struct KeybindsSettingsView: View {
  private let keybinds: [(String, String)] = [
    ("Send Message", "Return"),
    ("New Line", "Shift+Return"),
    ("Close Window", "⌘W"),
    ("Quick Switch", "⌘K"),
    ("Toggle Mute", "⌥⌘M"),
    ("Toggle Deafen", "⌥⌘D"),
    ("Mark Server Read", "⇧Esc"),
    ("Mark All Read", "⌘⇧A"),
  ]

  var body: some View {
    Section {
      ForEach(keybinds, id: \.0) { (action, shortcut) in
        LabeledContent(action, value: shortcut)
      }
    } header: {
      Text("Default Shortcuts")
    } footer: {
      Text("These are the built-in keyboard shortcuts for Paicord. Custom keybind support is coming in a future update.")
    }
  }
}
#endif
