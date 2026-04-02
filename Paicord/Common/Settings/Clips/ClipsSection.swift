//
//  ClipsSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var clipsSection: some SettingsContent {
    SettingsGroup("Clips", systemImage: "scissors") {
      ClipsSettingsView()
    }
  }
}

private struct ClipsSettingsView: View {
  @AppStorage("Paicord.Clips.AutoSaveToPhotos") var autoSaveToPhotos: Bool = false
  @AppStorage("Paicord.Clips.DefaultDuration") var defaultDuration: Int = 30

  var body: some View {
    Section {
      Toggle("Auto-save Clips to Photos", isOn: $autoSaveToPhotos)
    } footer: {
      Text("Automatically saves recorded clips to your Photos library.")
    }

    Section("Default Duration") {
      Picker("Clip Duration", selection: $defaultDuration) {
        Text("15 seconds").tag(15)
        Text("30 seconds").tag(30)
        Text("60 seconds").tag(60)
      }
      .pickerStyle(.menu)
    }
  }
}
