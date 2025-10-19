//
//  AccountCommands.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

// TODO: Make more account related commands etc

struct AccountCommands: Commands {
  let gatewayStore: GatewayStore

  var body: some Commands {
    CommandMenu("Account") {
      Button("Log Out") {
        Task {
          if let current = gatewayStore.accounts.currentAccount {
            gatewayStore.accounts.removeAccount(current)
            await gatewayStore.logOut()
          }
        }
      }
    }
  }
}
