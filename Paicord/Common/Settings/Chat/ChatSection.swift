//
//  ChatSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var chatSection: some SettingsContent {
    SettingsGroup("Chat", systemImage: "message") {
      ChatSettingsRows()
    }
  }
}

private struct ChatSettingsRows: View {
  @AppStorage("Paicord.Chat.CompactMode") var compactMode: Bool = false
  @AppStorage("Paicord.Chat.ShowTimestamps") var showTimestamps: Bool = true
  @AppStorage("Paicord.Chat.InlineMedia") var inlineMedia: Bool = true
  @AppStorage("Paicord.Chat.LinkPreviews") var linkPreviews: Bool = true
  @AppStorage("Paicord.Chat.SpellCheck") var spellCheck: Bool = true

  var body: some View {
    SettingsItem("Compact Message Mode") { Toggle("", isOn: $compactMode) }
    SettingsItem("Always Show Timestamps") { Toggle("", isOn: $showTimestamps) }
    SettingsItem("Show Inline Media") { Toggle("", isOn: $inlineMedia) }
    SettingsItem("Show Link Previews") { Toggle("", isOn: $linkPreviews) }
    SettingsItem("Spell Check") { Toggle("", isOn: $spellCheck) }
  }
}
