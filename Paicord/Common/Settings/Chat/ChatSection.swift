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
      ChatSettingsView()
    }
  }
}

private struct ChatSettingsView: View {
  @AppStorage("Paicord.Chat.CompactMode") var compactMode: Bool = false
  @AppStorage("Paicord.Chat.ShowLinkPreviews") var showLinkPreviews: Bool = true
  @AppStorage("Paicord.Chat.ShowEmbeds") var showEmbeds: Bool = true
  @AppStorage("Paicord.Chat.ShowAttachments") var showAttachments: Bool = true
  @AppStorage("Paicord.Chat.AutoPlayGIFs") var autoPlayGIFs: Bool = true
  @AppStorage("Paicord.Chat.ShowReactions") var showReactions: Bool = true
  @AppStorage("Paicord.Chat.SendOnEnter") var sendOnEnter: Bool = true

  var body: some View {
    Section("Display") {
      Toggle("Compact Mode", isOn: $compactMode)
      Toggle("Show Reactions", isOn: $showReactions)
    }

    Section("Media & Embeds") {
      Toggle("Show Link Previews", isOn: $showLinkPreviews)
      Toggle("Show Embeds", isOn: $showEmbeds)
      Toggle("Show Attachments", isOn: $showAttachments)
      Toggle("Auto-play GIFs", isOn: $autoPlayGIFs)
    }

    Section {
      Toggle("Send Message on Return", isOn: $sendOnEnter)
    } footer: {
      Text("When enabled, pressing Return sends the message. Use Shift+Return to add a new line.")
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
