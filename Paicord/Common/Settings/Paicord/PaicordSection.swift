//
//  PaicordSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUIX

extension SettingsView {
  var paicordSection: some SettingsContent {
    CustomSettingsGroup("Paicord", systemImage: "leaf") {
      VStack(alignment: .leading) {
        HStack {
          VStack(alignment: .leading) {
            Text("Paicord")
              .font(.title)
              .bold()
            Text(
              "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"))"
            )
            Text("Made with ❤️ by llsc12")
          }
          Spacer()

          NukeImage(
            url: .init(
              string:
                "https://media.discordapp.net/stickers/1039992459209490513.png?size=240&passthrough=true"
            )
          )
          .resizable()
          .scaledToFit()
          .maxHeight(120)
        }
        .maxWidth(.infinity)
        .minHeight(120)
        .padding()
        .background(LoginView.MeshGradientBackground())
        .clipShape(.rounded)

        VStack(alignment: .leading, spacing: 10) {
          Text(
            "If you like Paicord and would like to support its development, consider donating! You'll receive a Donator role in the Discord server and you'll receive custom badges!"
          )
          Button {
            openURL(
              .init(
                string: "https://github.com/sponsors/llsc12"
              )!
            )
          } label: {
            Label("Donate", systemImage: "heart.circle.fill")
              .foregroundStyle(.white)
              .tint(.pink)
          }
          .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.secondary.opacity(0.08))
        .clipShape(.rounded)
      }
    }
  }
}
