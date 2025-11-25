//
//  ReadStateStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
class ReadStateStore: DiscordDataStore {
  var gateway: GatewayStore?

  var eventTask: Task<Void, Never>?

  func setGateway(_ gateway: GatewayStore?) {
    self.gateway = gateway
    setupEventHandling()
  }

  var readStates: [AnySnowflake: Gateway.ReadState] = [:]
  
  func setupEventHandling() {
    eventTask?.cancel()
    guard let gateway = gateway?.gateway else { return }
    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        case .ready(let readyData):
          handleReady(readyData)
        case .messageAcknowledge(let ackData):
          handleMessageAcknowledge(ackData)
        default:
          break
        }
      }
    }
  }

  private func handleReady(_ readyData: Gateway.Ready) {
    readStates = (readyData.read_state ?? []).reduce(into: [:]) {
      $0[$1.id] = $1
    }
  }
  
  
  
  private func handleMessageAcknowledge(_ ackData: Gateway.MessageAcknowledge) {
    // Currently no-op
  }
}
