//
//  PaicordCommands.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

struct PaicordCommands: Commands {
  @Environment(\.gateway) var gatewayStore
  @Environment(\.openWindow) var openWindow
  @FocusedValue(\.appState) var appState

  var body: some Commands {
    CommandGroup(replacing: .appSettings) {
      Button("Settings") {
        openWindow(id: "settings")
      }
      .keyboardShortcut(",", modifiers: .command)
      .disabled(gatewayStore.state != .connected)
    }

    CommandMenu("Account") {
      Menu("Switch Account") {
        ForEach(gatewayStore.accounts.accounts, id: \.id) { account in
          Button(account.user.username) {
            Task {
              appState?.showingQuickSwitcher = false
              gatewayStore.accounts.currentAccountID = nil
              await gatewayStore.disconnectIfNeeded()
              gatewayStore.resetStores()
              PaicordAppState.instances.values.forEach { $0.resetStore() }
              gatewayStore.accounts.currentAccountID = account.id
            }
          }
          .disabled(
            gatewayStore.accounts.currentAccountID == account.id
          )
        }
      }
      .disabled(
        gatewayStore.accounts.accounts.count <= 1
          || gatewayStore.state != .connected
      )

      Button("Log Out") {
        Task {
          if let current = gatewayStore.accounts.currentAccount {
            gatewayStore.accounts.removeAccount(current)
            await gatewayStore.logOut()
          }
        }
      }
      .disabled(
        gatewayStore.accounts.currentAccountID != nil 
      )
    }
    // add reload button to the system's View menu
    CommandGroup(after: .toolbar) {
      Button("Reload") {
        appState?.showingQuickSwitcher = false
        Task {
          await gatewayStore.disconnectIfNeeded()
          gatewayStore.resetStores()
          //          PaicordAppState.instances.values.forEach { $0.resetStore() }
          await gatewayStore.connectIfNeeded()
        }
      }
      .keyboardShortcut("r", modifiers: [.command, .shift])
      .disabled(gatewayStore.state != .connected)

      Button("Quick Switcher") {
        appState?.showingQuickSwitcher.toggle()
      }
      .keyboardShortcut("k", modifiers: [.command])
      .disabled(gatewayStore.state != .connected)
    }
  }
}
