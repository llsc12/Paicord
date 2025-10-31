//
//  SettingsStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
class SettingsStore: DiscordDataStore {
  var gateway: GatewayStore?
  var eventTask: Task<Void, Never>?

  // MARK: - Settings State
  var userSettings: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings =
    .init()
  var frecencySettings: DiscordProtos_DiscordUsers_V1_FrecencyUserSettings =
    .init()

  // MARK: - Batching State
  private var userSettingsTimer: Timer?
  private var frecencySettingsTimer: Timer?
  private var hasPendingUserSettings = false
  private var hasPendingFrecencySettings = false

  // MARK: - Update Types for Timing
  enum UpdateType {
    case infrequent  // No delay - immediate
    case frequent  // 10 seconds
    case automated  // 30 seconds
    case daily  // 1 day (24 hours)
  }

  // MARK: - Protocol Methods
  func setGateway(_ gateway: GatewayStore?) {
    cancelEventHandling()
    self.gateway = gateway
    if gateway != nil {
      setupEventHandling()
    }
  }

  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }

    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        case .ready(let readyData):
          handleReady(readyData)

        case .userSettingsUpdate(let update):
          handleUserSettingsUpdate(update)

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

    // Cancel any pending timers
    userSettingsTimer?.invalidate()
    frecencySettingsTimer?.invalidate()
    userSettingsTimer = nil
    frecencySettingsTimer = nil
  }

  // MARK: - Event Handlers
  private func handleReady(_ readyData: Gateway.Ready) {
    if let settings = readyData.user_settings_proto {
      userSettings = settings
    }
  }

  private func handleUserSettingsUpdate(
    _ update: Gateway.UserSettingsProtoUpdate
  ) {
    switch update.settings {
    case .preloaded(let proto):
      if update.partial {
        // Merge with existing settings
        mergeUserSettings(with: proto)
      } else {
        // Replace entire settings
        userSettings = proto
      }

    case .frecency(let proto):
      if update.partial {
        // Merge with existing frecency settings
        mergeFrecencySettings(with: proto)
      } else {
        // Replace entire frecency settings
        frecencySettings = proto
      }

    default:
      break
    }
  }

  // MARK: - Settings Merging
  private func mergeUserSettings(
    with newSettings: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings
  ) {

  }

  private func mergeFrecencySettings(
    with newSettings: DiscordProtos_DiscordUsers_V1_FrecencyUserSettings
  ) {

  }

  // MARK: - Public Settings Update Methods

  /// Request user settings modification with appropriate batching delay
  /// - Parameters:
  ///   - updateType: The type of update to determine delay timing
  ///   - immediate: If true, bypasses batching and sends immediately (for infrequent updates)
  func requestUserSettingsModify(
    updateType: UpdateType = .frequent,
    immediate: Bool = false
  ) {
    hasPendingUserSettings = true

    if immediate || updateType == .infrequent {
      performUserSettingsUpdate()
      return
    }

    // Cancel existing timer and start new one
    userSettingsTimer?.invalidate()

    let delay = delayInterval(for: updateType)
    userSettingsTimer = Timer.scheduledTimer(
      withTimeInterval: delay,
      repeats: false
    ) { [weak self] _ in
      Task { @MainActor in
        self?.performUserSettingsUpdate()
      }
    }
  }

  /// Request frecency settings modification with appropriate batching delay
  /// - Parameters:
  ///   - updateType: The type of update to determine delay timing
  ///   - immediate: If true, bypasses batching and sends immediately
  func requestFrecencySettingsModify(
    updateType: UpdateType = .daily,
    immediate: Bool = false
  ) {
    hasPendingFrecencySettings = true

    if immediate || updateType == .infrequent {
      performFrecencySettingsUpdate()
      return
    }

    // Cancel existing timer and start new one
    frecencySettingsTimer?.invalidate()

    let delay = delayInterval(for: updateType)
    frecencySettingsTimer = Timer.scheduledTimer(
      withTimeInterval: delay,
      repeats: false
    ) { [weak self] _ in
      Task { @MainActor in
        self?.performFrecencySettingsUpdate()
      }
    }
  }

  // MARK: - Helper Methods

  private func delayInterval(for updateType: UpdateType) -> TimeInterval {
    switch updateType {
    case .infrequent:
      return 0  // Should not be called
    case .frequent:
      return 10  // 10 seconds
    case .automated:
      return 30  // 30 seconds
    case .daily:
      return 24 * 60 * 60  // 1 day (24 hours)
    }
  }

  private func performUserSettingsUpdate() {
    guard hasPendingUserSettings else { return }

    userSettingsTimer?.invalidate()
    userSettingsTimer = nil
    hasPendingUserSettings = false

    Task {
      await sendUserSettingsUpdate()
    }
  }

  private func performFrecencySettingsUpdate() {
    guard hasPendingFrecencySettings else { return }

    frecencySettingsTimer?.invalidate()
    frecencySettingsTimer = nil
    hasPendingFrecencySettings = false

    Task {
      await sendFrecencySettingsUpdate()
    }
  }

  /// Sends the user settings update to the REST API
  private func sendUserSettingsUpdate() async {
    fatalError("Not implemented")
  }

  /// Sends the frecency settings update to the REST API
  private func sendFrecencySettingsUpdate() async {
    fatalError("Not implemented")
  }

  // MARK: - Convenience Methods for Common Settings Changes

  /// Updates a specific user setting and requests modification
  func updateUserSetting<T>(
    _ keyPath: WritableKeyPath<
      DiscordProtos_DiscordUsers_V1_PreloadedUserSettings, T
    >,
    to value: T,
    updateType: UpdateType = .frequent
  ) {
    userSettings[keyPath: keyPath] = value
    requestUserSettingsModify(updateType: updateType)
  }

  /// Updates a specific frecency setting and requests modification
  func updateFrecencySetting<T>(
    _ keyPath: WritableKeyPath<
      DiscordProtos_DiscordUsers_V1_FrecencyUserSettings, T
    >,
    to value: T,
    updateType: UpdateType = .daily
  ) {
    frecencySettings[keyPath: keyPath] = value
    requestFrecencySettingsModify(updateType: updateType)
  }

  /// Forces immediate send of any pending settings updates
  func flushPendingUpdates() {
    if hasPendingUserSettings {
      performUserSettingsUpdate()
    }
    if hasPendingFrecencySettings {
      performFrecencySettingsUpdate()
    }
  }

  /// Cancels any pending settings updates
  func cancelPendingUpdates() {
    userSettingsTimer?.invalidate()
    frecencySettingsTimer?.invalidate()
    userSettingsTimer = nil
    frecencySettingsTimer = nil
    hasPendingUserSettings = false
    hasPendingFrecencySettings = false
  }
}
