//
//  PaicordAppState.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

enum PaicordGuildNavigation: RawRepresentable, Hashable {
  init?(rawValue: String) {
    let components = rawValue.split(separator: ":", maxSplits: 1)
    guard components.count == 2 else { return nil }
    let type = components[0]
    let value = components[1]

    switch type {
    case "guild":
      self = .guild(GuildSnowflake(String(value)))
    case "directMessages":
      self = .directMessages
    default:
      return nil
    }
  }

  var rawValue: String {
    switch self {
    case .guild(let guildId):
      return "guild:\(guildId.rawValue)"
    case .directMessages:
      return "directMessages: "
    }
  }

  case guild(GuildSnowflake)
  case directMessages

  static func make(from dict: [String: String]) -> [PaicordGuildNavigation:
    PaicordChannelNavigation]?
  {
    var result: [PaicordGuildNavigation: PaicordChannelNavigation] = [:]
    for (key, value) in dict {
      if let guildNav = PaicordGuildNavigation(rawValue: key),
        let channelNav = PaicordChannelNavigation(rawValue: value)
      {
        result[guildNav] = channelNav
      }
    }
    return result
  }
  
  static func make(from: [PaicordGuildNavigation: PaicordChannelNavigation]) -> [String: String] {
    var result: [String: String] = [:]
    for (key, value) in from {
      result[key.rawValue] = value.rawValue
    }
    return result
  }
}

enum PaicordChannelNavigation: RawRepresentable, Hashable {
  init?(rawValue: String) {
    let components = rawValue.split(separator: ":", maxSplits: 1)
    guard components.count == 2 else { return nil }
    let type = components[0]
    let value = components[1]

    switch type {
    case "textChannel":
      self = .textChannel(ChannelSnowflake(String(value)))
    case "voiceChannel":
      self = .voiceChannel(ChannelSnowflake(String(value)))
    case "thread":
      self = .thread(ChannelSnowflake(String(value)))
    case "dashboard":
      self = .dashboard
    case "friends":
      self = .friends
    default:
      return nil
    }
  }

  var rawValue: String {
    switch self {
    case .textChannel(let channelId):
      return "textChannel:\(channelId.rawValue)"
    case .voiceChannel(let channelId):
      return "voiceChannel:\(channelId.rawValue)"
    case .thread(let channelId):
      return "thread:\(channelId.rawValue)"
    case .dashboard:
      return "dashboard: "
    case .friends:
      return "friends: "
    }
  }

  case dashboard

  case textChannel(ChannelSnowflake)
  case voiceChannel(ChannelSnowflake)
  case thread(ChannelSnowflake)

  // special dms navigation destinations
  case friends
}

@Observable
final class PaicordAppState {
  // each window gets its own app state
  static var instances: [UUID: PaicordAppState] = [:]

  init() {
    Self.instances[id] = self

    loadPrevSelectedChannels()
    if let lastKnownChannel = self.rawPrevSelectedChannels[self.selectedGuild] {
      self.selectedChannel = lastKnownChannel
    } else {
      self.selectedChannel = .dashboard
    }
  }
  deinit {
    Self.instances.removeValue(forKey: id)
  }

  let id = UUID()

  // MARK: - iOS Specific
  var chatOpen: Bool = true

  // MARK: - General
  var showingQuickSwitcher: Bool = false

  // MARK: - Selected Guild & Channel Persistence

  private let storageKey = "AppState.PrevSelectedChannels"
  var suppressChannelSave = false

  private var _selectedGuild: PaicordGuildNavigation = .directMessages {
    didSet {
      UserDefaults.standard.set(
        _selectedGuild.rawValue,
        forKey: "AppState.PrevSelectedGuild"
      )
    }
  }
  var selectedGuild: PaicordGuildNavigation {
    get { _selectedGuild }
    set {
      suppressChannelSave = true
      defer { suppressChannelSave = false }

      let lastChannel = rawPrevSelectedChannels[newValue]
      if let lastChannel {
        selectedChannel = lastChannel
      } else {
        selectedChannel = .dashboard
      }

      _selectedGuild = newValue
    }
  }

  var selectedChannel: PaicordChannelNavigation = .dashboard {
    didSet {
      guard !suppressChannelSave else { return }
      let key = selectedGuild
      rawPrevSelectedChannels[key] = selectedChannel
      savePrevSelectedChannels()
    }
  }

  // persistent mapping as [String: String] where key == guild.rawValue or "nil"
  @ObservationIgnored
  private var rawPrevSelectedChannels:
    [PaicordGuildNavigation: PaicordChannelNavigation] = [:]

  func resetStore() {
    selectedGuild = .directMessages
    selectedChannel = .dashboard
    rawPrevSelectedChannels = [:]
    UserDefaults.standard.removeObject(
      forKey: "AppState.PrevSelectedGuild"
    )
    savePrevSelectedChannels()
  }

  // MARK: - Persistence Helpers

  func loadPrevGuild() {
    let guildValue = UserDefaults.standard.string(
      forKey: "AppState.PrevSelectedGuild"
    )
    guard let guildValue else { return }
    if case .guild(let guildId) = PaicordGuildNavigation(rawValue: guildValue) {
      guard GatewayStore.shared.user.guilds.keys.contains(guildId) else {
        return
      }
      self.selectedGuild = .guild(guildId)
    }
  }

  private func loadPrevSelectedChannels() {
    let defaults = UserDefaults.standard

    if let data = defaults.data(forKey: storageKey) {
      if let obj = try? JSONSerialization.jsonObject(with: data),
        let dict = PaicordGuildNavigation.make(
          from: obj as? [String: String] ?? [:]
        )
      {
        rawPrevSelectedChannels = dict
        return
      }
    }

    rawPrevSelectedChannels = [:]
  }

  private func savePrevSelectedChannels() {
    let json = PaicordGuildNavigation.make(from: rawPrevSelectedChannels)
    if let data = try? JSONSerialization.data(withJSONObject: json) { // Thread 1: Swift runtime failure: unhandled C++ / Objective-C exception
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

extension PaicordGuildNavigation {
  var guildID: GuildSnowflake? {
    switch self {
    case .guild(let guildId):
      return guildId
    case .directMessages:
      return nil
    }
  }
}

extension PaicordChannelNavigation {
  var channelID: ChannelSnowflake? {
    switch self {
    case .textChannel(let channelId),
      .voiceChannel(let channelId),
      .thread(let channelId):
      return channelId
    case .dashboard, .friends:
      return nil
    }
  }
}
