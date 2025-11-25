//
//  AccountPicker.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUI

struct AccountPicker: View {
  let accounts: [TokenStore.AccountData]
  let onSelect: (UserSnowflake) -> Void
  let onAdd: () -> Void

  var body: some View {
    VStack {
      Text("Choose an account")
        .font(.largeTitle)
        .padding(.bottom, 4)
      Text("Select an account to continue or add a new one.")
        .padding(.bottom)

      VStack(spacing: 10) {
        ScrollView {
          VStack(spacing: 10) {
            ForEach(accounts) { account in
              Button {
                onSelect(account.user.id)
              } label: {
                HStack {
                  Text(account.user.username)
                    .font(.title3)
                  Spacer()
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(.theme.common.primaryButtonBackground)
                .clipShape(.rounded)
              }
              .buttonStyle(.borderless)
            }
          }
        }
        .frame(maxHeight: 200)

        Button(action: onAdd) {
          HStack {
            Image(systemName: "plus")
            Text("Add Account")
              .font(.title3)
          }
          .frame(maxWidth: .infinity)
          .padding(10)
          .background(Color.theme.common.primaryButton)
          .clipShape(.rounded)
        }
        .buttonStyle(.borderless)
        .padding(.top, 10)
      }
    }
  }
}
