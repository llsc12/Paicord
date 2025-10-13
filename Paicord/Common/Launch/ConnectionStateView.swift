//
//  ConnectionStateView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUI

struct ConnectionStateView: View {
  var state: GatewayState
  @Environment(GatewayStore.self) var gs
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack {
        Image(systemName: "questionmark.app.dashed")
          .resizable()
          .scaledToFit()
          .maxWidth(80)
          .maxHeight(80)
        Text("Paicord")
          .font(.title2)
          .fontWeight(.bold)

        Text(Self.loadingString)
          .foregroundStyle(.secondary)
          .padding(5)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.appBackground)

      VStack {
        Text(state.description.capitalized)
          .foregroundStyle(.tertiary)
          .padding(2)
        switch state {
        case .stopped:
          Text(
            "Something really bad has happened, gateway connections disabled.\nPlease report this."
          )
          AsyncButton("Log Out") {
            if let account = gs.accounts.currentAccount {
              gs.accounts.removeAccount(account)
              await gs.logOut()
            }
          } catch: { _ in
          }
        case .configured:
          Text("Awaiting READY")
        default: EmptyView()
        }
      }
      .multilineTextAlignment(.center)
      .font(.footnote)
      .padding(5)
    }
  }

  static let loadingString: AttributedString = [
    "X-Super-Properties!",
    "Constructing ViewModels...",
    "Locating closest Genius Bar...",
    "Theoretically supports Linux!",
  ].randomElement()!
}

#Preview {
  ConnectionStateView(state: .configured)
}
