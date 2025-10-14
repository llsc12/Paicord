//
//  SettingsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

struct SettingsView: View {
  @Environment(GatewayStore.self) var gs
  var body: some View {
    AsyncButton("Log out") {
      if let current = gs.accounts.currentAccount {
        gs.accounts.removeAccount(current)
        await gs.logOut()
      }
    } catch: {
      print("[SettingsView] Failed to logout: \(String(describing: $0))")
    }
  }
}
