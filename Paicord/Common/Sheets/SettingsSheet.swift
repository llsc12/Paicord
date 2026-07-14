//
//  SettingsSheet.swift
//  Paicord
//
//  Created by tiramisu on 2026.05.04.
//

import SwiftUIX

extension View {
  func settingsSheet() -> some View {
    self
      .modifier(SettingsSheetModifier())
  }
}

extension NSNotification.Name {
  static let presentSettingsSheet =
    NSNotification.Name("Paicord.Settings.PresentSheet")
}

private struct SettingsSheetModifier: ViewModifier {
  @State private var isPresented: Bool = false

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $isPresented) {
        SettingsView()
      }
      .onReceive(
        NotificationCenter.default.publisher(
          for: .presentSettingsSheet
        )
      ) { _ in
        isPresented = true
      }
  }
}
