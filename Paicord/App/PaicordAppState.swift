//
//  PaicordAppState.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

@Observable
final class PaicordAppState {
  static let shared = PaicordAppState()

  // MARK: - iOS Specific
  var chatOpen: Bool = true 

  // MARK: - Selected Guild & Channel Persistence

  private let storageKey = "AppState.PrevSelectedChannels"
  private var suppressChannelSave = false

  private var _selectedGuild: GuildSnowflake? = nil {
    didSet {
      UserDefaults.standard.set(
        _selectedGuild?.rawValue,
        forKey: "AppState.PrevSelectedGuild"
      )
    }
  }
  var selectedGuild: GuildSnowflake? {
    get { _selectedGuild }
    set {
      let newGuildKey = newValue?.rawValue ?? "nil"

      suppressChannelSave = true
      defer { suppressChannelSave = false }

      let lastChannel = rawPrevSelectedChannels[newGuildKey]
      if let lastChannel {
        selectedChannel = ChannelSnowflake(lastChannel)
      } else {
        selectedChannel = nil
      }

      _selectedGuild = newValue
    }
  }

  var selectedChannel: ChannelSnowflake? {
    didSet {
      guard !suppressChannelSave else { return }
      let key = selectedGuild?.rawValue ?? "nil"
      if let channel = selectedChannel {
        rawPrevSelectedChannels[key] = channel.rawValue
      } else {
        rawPrevSelectedChannels.removeValue(forKey: key)
      }
      savePrevSelectedChannels()
    }
  }

  // persistent mapping as [String: String] where key == guild.rawValue or "nil"
  @ObservationIgnored
  private var rawPrevSelectedChannels: [String: String] = [:]

  private init() {
    loadPrevSelectedChannels()
    if let lastDM = self.rawPrevSelectedChannels[
      self.selectedGuild?.rawValue ?? "nil"
    ] {
      self.selectedChannel = ChannelSnowflake(lastDM)
    } else {
      self.selectedChannel = nil
    }
  }

  func resetStore() {
    selectedGuild = nil
    selectedChannel = nil
    rawPrevSelectedChannels = [:]
    savePrevSelectedChannels()
  }

  // MARK: - Persistence Helpers

  func loadPrevGuild() {
    let guildIdString = UserDefaults.standard.string(
      forKey: "AppState.PrevSelectedGuild"
    )
    guard let guildIdString else { return }
    let guildId = GuildSnowflake(guildIdString)
    guard GatewayStore.shared.user.guilds.keys.contains(guildId) else { return }
    self.selectedGuild = GuildSnowflake(guildId)
  }

  private func loadPrevSelectedChannels() {
    let defaults = UserDefaults.standard

    if let data = defaults.data(forKey: storageKey) {
      if let obj = try? JSONSerialization.jsonObject(with: data),
        let dict = obj as? [String: String]
      {
        rawPrevSelectedChannels = dict
        return
      }
    }

    rawPrevSelectedChannels = [:]
  }

  private func savePrevSelectedChannels() {
    let json = rawPrevSelectedChannels
    if let data = try? JSONSerialization.data(withJSONObject: json) {
      UserDefaults.standard.set(data, forKey: storageKey)
    } else {
      // fallback: write dictionary directly
      UserDefaults.standard.set(json, forKey: storageKey)
    }
  }

  // MARK: - Error state
  var showingError = false
  var showingErrorSheet = false
  var error: Error? = nil {
    didSet {
      showingError = error != nil
    }
  }
}
