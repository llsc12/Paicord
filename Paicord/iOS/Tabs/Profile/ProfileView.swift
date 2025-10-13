//
//  ProfileView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

struct ProfileView: View {
  @Environment(GatewayStore.self) var gs
  var body: some View {
    VStack {
      Text("Profile View")

      NavigationLink("Settings") {
        SettingsView()
      }
    }
  }
}
