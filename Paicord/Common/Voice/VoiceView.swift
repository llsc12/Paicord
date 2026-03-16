//
//  VoiceView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/03/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//  

import PaicordLib
import SwiftUIX

struct VoiceView: View {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  var vm: ChannelStore

  var body: some View {
    Text("Voice Channel")
      .font(.largeTitle)
      .foregroundStyle(.secondary)
  }
}
