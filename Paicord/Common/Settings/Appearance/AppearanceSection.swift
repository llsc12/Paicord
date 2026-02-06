//
//  AppearanceSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUIX

extension SettingsView {
  @SettingsContentBuilder
  var appearanceSection: some SettingsContent {
    CustomSettingsGroup("Theming", systemImage: "paintbrush") {
      ThemingSection()
    }
    
    SettingsGroup("Appearance", systemImage: "display") {
      SettingsItem("Animate Chat Messages", icon: "circle.grid.2x1.right.filled") {
        Toggle(isOn: $chatMessagesAnimated) {
          Text(verbatim: "")
        }
      }
    }
  }
}

struct ThemingSection: View {
  let theming = Theming.shared
  @State private var showingImportTheme = false
  @State private var importError: Error?
  var body: some View {
    Section("Installed Themes") {
      ForEach(theming.themes) { theme in
        Button {
          theming.currentThemeID = theme.id
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print(theme.common)
          }
        } label: {
          themeRow(theme: theme)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          if !Theming.defaultThemes.map(\.id).contains(theme.id) {
            Button(role: .destructive) {
              theming.loadedThemes = theming.loadedThemes.filter {
                $0.id != theme.id
              }
            } label: {
              Label("Delete", systemImage: "trash")
            }
          }
        }
      }
    }
    Section {
      Button {
        showingImportTheme = true
      } label: {
        Text("Add Theme")
      }
      .fileImporter(
        isPresented: $showingImportTheme,
        allowedContentTypes: [.json],
        allowsMultipleSelection: false
      ) { result in
        switch result {
        case .success(let urls):
          guard let url = urls.first else { return }
          do {
            guard url.startAccessingSecurityScopedResource() else {
              throw NSError(
                domain: "com.example.Paicord",
                code: 1,
                userInfo: [
                  NSLocalizedDescriptionKey:
                    "Unable to access the selected file."
                ]
              )
            }

            defer { url.stopAccessingSecurityScopedResource() }
            let data = try Data(contentsOf: url)
            let theme = try JSONDecoder().decode(
              Theming.Theme.self,
              from: data
            )
            theming.loadedThemes = theming.loadedThemes + [theme]
          } catch {
            self.importError = error
          }
        case .failure(let error):
          print("Failed to import theme: \(error)")
        }
      }
    } footer: {
      Text("Swipe on a theme to delete it.")
    }
  }

  @ViewBuilder
  func themeRow(theme: Theming.Theme) -> some View {
    let theming = Theming.shared

    HStack {
      VStack(alignment: .leading) {
        Text(theme.metadata.name)
          .foregroundStyle(Color.primary)
        Text(verbatim: "\(theme.metadata.author) • v\(theme.metadata.version)")
          .font(.caption)
          .foregroundStyle(Color.secondary)
      }

      Spacer()

      if theming.currentThemeID == theme.id {
        Image(systemName: "checkmark")
          .foregroundStyle(theme.common.primaryButton)
      }
    }
  }
}
