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
  @Environment(\.gateway) var gw
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack {
        #if os(macOS)
          Image(nsImage: NSImage(named: "AppIcon")!)
            .resizable()
            .scaledToFit()
            .maxWidth(80)
            .maxHeight(80)
        #else
          Image(uiImage: UIImage(named: "AppIcon")!)
            .resizable()
            .scaledToFit()
            .maxWidth(80)
            .maxHeight(80)
        #endif
        Text("Paicord")
          .font(.title2)
          .fontWeight(.bold)

        Text(Self.loadingString)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
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
            if let account = gw.accounts.currentAccount {
              gw.accounts.removeAccount(account)
              await gw.logOut()
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
    "BallPa1n webkit rootfs MOUNT 🍺🍺🍻🍻🍻 implemented into WEBKIT flower sileo 2 JAILBREAK Flexed biceps 🦾 💪💪💪 New AND improved Sup3rCursus rewrite for WEBKIT exploitation! 🐟 🍻🍻🍻 fugu16 Code TRANSLATED into webkit access via explotation SoC Display Drivers, 🦾 NEW untethered WEBKIT 💪💪 GLITCHED powered by manticore pwnmy WITH new Sup3rCursus improved b00tstrap arm64_32-arm-os 💪💪💪💪",
    "🪅",
    "comes with cryptominer bundled",
    "shaw",
    "Dr. Pepper the best",
    "wha",
    "paiplosion",
    "oh I wasn't suggesting that for a splash thing but sure",
    "Also try Terraria!",
    "where's the also try minecraft!",
    "Δ",
    "swift!",
    "Loomly Loomly, I guess I'm Loomly",
    "green green / it's green, they say / on the far side of the hill",
    "green green / I'm going away / to where the grass is greener still",
  ].randomElement()!
}

#Preview {
  ConnectionStateView(state: .configured)
}
