//
//  VoiceConnectionStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//  

import PaicordLib

final class VoiceConnectionStore: DiscordDataStore {
  var gateway: GatewayStore?
  var voiceGateway: VoiceGatewayManager?

  var eventTask: Task<Void, Never>?
  
  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }

    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        // capture and store voice events
        default:
          break
        }
      }
    }
  }
  

  func cancelEventHandling() {
    // overrides default impl of protocol
    eventTask?.cancel()
    eventTask = nil

    // end networking session etc.
  }
}
