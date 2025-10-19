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
  var chatOpen: Bool = false

  // MARK: - Selected Guild & Channel Persistence

  private let storageKey = "AppState.PrevSelectedChannels"
  private var suppressChannelSave = false

  private var _selectedGuild: GuildSnowflake? = nil
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

  // MARK: - Persistence Helpers

  private func loadPrevSelectedChannels() {
    let defaults = UserDefaults.standard

    // 1) Try JSON Data (if older code wrote Data)
    if let data = defaults.data(forKey: storageKey) {
      if let obj = try? JSONSerialization.jsonObject(with: data),
        let dict = obj as? [String: String]
      {
        rawPrevSelectedChannels = dict
        return
      }
    }

    // 2) Fall back to a directly-stored dictionary
    if let dict = defaults.dictionary(forKey: storageKey) as? [String: String] {
      rawPrevSelectedChannels = dict
      return
    }

    // 3) Nothing found
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
