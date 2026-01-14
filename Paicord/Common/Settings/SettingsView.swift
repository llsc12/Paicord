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

//enum SettingsPages {
//  static let settingsPages: [SettingsPage] =
//    AccountSection + PaicordSection + DebugSection
//}
//
//struct SettingsView: View {
//  @Environment(\.gateway) var gw
//  @Environment(\.appState) var appState
//  @Environment(\.userInterfaceIdiom) var idiom
//
//  @State private var selectedPage: SettingsPage?  // <-- Add this state variable
//
//  var body: some View {
//    switch idiom {
//    case .mac, .pad:
//      settingsSidebarStyle
//    default:
//      settingsListStyle
//    }
//  }
//
//  @ViewBuilder
//  var settingsSidebarStyle: some View {
//    NavigationSplitView(columnVisibility: .constant(.all)) {
//      List(selection: $selectedPage) {  // <-- Bind selection here
//        let sections: OrderedDictionary<String, [SettingsPage]> = SettingsPages.settingsPages
//          .reduce(
//            into: [:]) { dict, page in
//              dict[page.section, default: []].append(page)
//            }
//
//        ForEach(sections.keys, id: \.self) { section in
//          Section(header: Text(section)) {
//            ForEach(sections[section] ?? [], id: \.title) { page in
//              if let action = page.action {
//                Button {
//                  action()
//                } label: {
//                  switch page.icon {
//                  case .system(let name):
//                    Label(page.title, systemImage: name)
//                  case .custom(let name):
//                    Label(page.title, image: name)
//                  }
//                }
//              } else {
//                NavigationLink(value: page) {
//                  switch page.icon {
//                  case .system(let name):
//                    Label(page.title, systemImage: name)
//                  case .custom(let name):
//                    Label(page.title, image: name)
//                  }
//                }
//              }
//            }
//          }
//        }
//      }
//      .navigationTitle("Paicord Settings")
//      .toolbar(removing: .sidebarToggle)
//
//    } detail: {
//      if let selectedPage = selectedPage {
//        selectedPage.view
//          .navigationTitle(selectedPage.title)
//          .toolbar(removing: .sidebarToggle)
//      } else {
//        Text("Paicord")
//          .font(.title2)
//          .fontWeight(.semibold)
//          .foregroundStyle(.secondary)
//          .toolbar(removing: .sidebarToggle)
//      }
//    }
//    .toolbar(removing: .sidebarToggle)
//  }
//
//  @ViewBuilder
//  var settingsListStyle: some View {
//    List {
//      let sections: OrderedDictionary<String, [SettingsPage]> = SettingsPages.settingsPages
//        .reduce(
//          into: [:]) { dict, page in
//            dict[page.section, default: []].append(page)
//          }
//
//      ForEach(sections.keys, id: \.self) { section in
//        Section(header: Text(section)) {
//          ForEach(sections[section] ?? [], id: \.title) { page in
//            if let action = page.action {
//              Button {
//                action()
//              } label: {
//                switch page.icon {
//                case .system(let name):
//                  Label(page.title, systemImage: name)
//                case .custom(let name):
//                  Label(page.title, image: name)
//                }
//              }
//            } else {
//              NavigationLink(destination: page.view) {
//                switch page.icon {
//                case .system(let name):
//                  Label(page.title, systemImage: name)
//                case .custom(let name):
//                  Label(page.title, image: name)
//                }
//              }
//            }
//          }
//        }
//      }
//    }
//    .navigationTitle("Settings")
//  }
//
//}
//
//struct SettingsPage: Hashable {
//  var title: String
//  var icon: Icon
//  var section: String
//
//  init(title: String, icon: Icon, section: String, view: () -> any View) {
//    self.title = title
//    self.icon = icon
//    self.section = section
//    self.view = view().eraseToAnyView()
//  }
//
//  init(title: String, icon: Icon, section: String, action: @escaping @Sendable () -> Void)
//  {
//    self.title = title
//    self.icon = icon
//    self.section = section
//    self.view = EmptyView().eraseToAnyView()
//    self.action = action
//  }
//
//  enum Icon: Hashable {
//    case system(String)
//    case custom(String)
//  }
//
//  func hash(into hasher: inout Hasher) {
//    hasher.combine(title)
//    hasher.combine(icon)
//    hasher.combine(section)
//  }
//
//  static func == (lhs: SettingsPage, rhs: SettingsPage) -> Bool {
//    return lhs.hashValue == rhs.hashValue
//  }
//
//  var view: AnyView
//  var action:  (@Sendable () -> Void)? = nil
//}
