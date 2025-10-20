//
//  SettingsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUIX

struct SettingsView: View {
  @Environment(GatewayStore.self) var gw
  @Environment(PaicordAppState.self) var appState
  @Environment(\.userInterfaceIdiom) var idiom
  var body: some View {
    switch idiom {
    case .mac, .pad:
      settingsSidebarStyle
    default:
      settingsListStyle
    }
  }

  // MARK: - macOS Layout
  private var settingsSidebarStyle: some View {
    NavigationSplitView {
      List {
        Section("General") {
          NavigationLink("Appearance", value: "appearance")
          NavigationLink("Notifications", value: "notifications")
        }
      }
      .navigationSplitViewColumnWidth(min: 150, ideal: 200)
    } detail: {
      SettingsDetailView()
    }
  }

  // MARK: - iOS / iPadOS Layout
  private var settingsListStyle: some View {
    NavigationStack {
      Form {
        Section("Profile") {
          TextField("Username", text: .constant("gm"))
        }

        Section("Preferences") {
          Picker("Theme", selection: .constant("System")) {
            Text("Light").tag("Light")
            Text("Dark").tag("Dark")
            Text("System").tag("System")
          }
          .pickerStyle(.segmented)

          Toggle("Enable Notifications", isOn: .constant(true))
        }
      }
      .navigationTitle("Settings")
    }
  }
  
  struct SettingsDetailView: View {
      var body: some View {
          VStack(alignment: .leading, spacing: 12) {
              Text("Appearance")
                  .font(.title2)
              Text("Customize how your app looks and feels.")
          }
          .padding()
      }
  }
}
