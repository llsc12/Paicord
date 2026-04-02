//
//  VoiceVideoSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 02/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SettingsKit
import SwiftUI

extension SettingsView {
  var voiceVideoSection: some SettingsContent {
    SettingsGroup("Voice & Video", systemImage: "mic.fill") {
      VoiceVideoSettingsView()
    }
  }
}

private struct VoiceVideoSettingsView: View {
  @AppStorage("Paicord.VoiceVideo.NoiseSuppression") var noiseSuppression: Bool = true
  @AppStorage("Paicord.VoiceVideo.EchoCancellation") var echoCancellation: Bool = true
  @AppStorage("Paicord.VoiceVideo.AutoGainControl") var autoGainControl: Bool = true
  @AppStorage("Paicord.VoiceVideo.InputVolume") var inputVolume: Double = 100.0
  @AppStorage("Paicord.VoiceVideo.VideoMirror") var mirrorVideo: Bool = true

  @Environment(\.openURL) var openURL

  var body: some View {
    Section("Input Processing") {
      Toggle("Noise Suppression", isOn: $noiseSuppression)
      Toggle("Echo Cancellation", isOn: $echoCancellation)
      Toggle("Automatic Gain Control", isOn: $autoGainControl)
    }

    Section {
      VStack(alignment: .leading, spacing: 6) {
        Text("Input Volume: \(Int(inputVolume))%")
          .font(.subheadline)
        Slider(value: $inputVolume, in: 0...200, step: 5)
      }
      .padding(.vertical, 4)
    } header: {
      Text("Volume")
    }

    Section {
      Toggle("Mirror My Video", isOn: $mirrorVideo)
    } header: {
      Text("Video")
    } footer: {
      Text("Mirrors the local camera preview so it feels more natural when talking.")
    }

    Section {
      Button("Open System Microphone Settings") {
        #if os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
          openURL(url)
        }
        #else
        if let url = URL(string: "App-Prefs:root=Privacy&path=MICROPHONE") {
          openURL(url)
        }
        #endif
      }
      Button("Open System Camera Settings") {
        #if os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
          openURL(url)
        }
        #else
        if let url = URL(string: "App-Prefs:root=Privacy&path=CAMERA") {
          openURL(url)
        }
        #endif
      }
    } footer: {
      Text("Microphone and camera permissions are managed in System Settings.")
    }
  }
}
