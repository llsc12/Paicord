//
//  DiscordDataStoreProtocol.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib

protocol DiscordDataStore: AnyObject {
  var gateway: GatewayStore? { get set }
  var eventTask: Task<Void, Never>? { get set }

  func setGateway(_ gateway: GatewayStore?)
  func setupEventHandling()
  func cancelEventHandling()
}

extension DiscordDataStore {
  func setGateway(_ gateway: GatewayStore?) {
    cancelEventHandling()
    self.gateway = gateway
    if gateway != nil {
      setupEventHandling()
    }
  }
  
  func cancelEventHandling() {
    eventTask?.cancel()
    eventTask = nil
  }
}
