//
//  DebugSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Logging
import SettingsKit
import SwiftUIX

#if canImport(FLEX)
  import FLEX
#endif

extension SettingsView {
  var debugSection: some SettingsContent {
    CustomSettingsGroup("Debug", systemImage: "ladybug") {
      Section("Tools") {
        NavigationLink {
          ShellView().eraseToAnyView()
        } label: {
          Label("View Logs", systemImage: "apple.terminal")
        }
        #if canImport(FLEX)
          Button {
            FLEXManager.shared.showExplorer()
          } label: {
            Label("Show FLEX", systemImage: "scope")
          }
        #endif
      }
      
      Section("Playgrounds") {
        NavigationLink {
          TestMessageView().eraseToAnyView()
        } label: {
          Label("Message Attachments Playground", systemImage: "app.dashed")
        }
      }
      
      Section("Sketchy shit") {
        AsyncButton("Force fallback account switcher") {
          gw.accounts.currentAccountID = nil
          await gw.disconnectIfNeeded()
          gw.resetStores()
        } catch: { _ in }
      }
    }
  }
}
