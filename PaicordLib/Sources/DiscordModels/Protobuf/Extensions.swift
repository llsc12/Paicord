//
//  Extensions.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 08/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Foundation

// MARK: - Presence helpers
extension DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.StatusSettings {
  public var gatewayStatus: Gateway.Status? {
    guard hasStatus else { return nil }
    guard !statusIsExpired() else { return nil }

    switch status.value {
    case "online":
      return .online
    case "idle":
      return .afk
    case "dnd":
      return .doNotDisturb
    case "invisible":
      return .invisible
    case "offline":
      return .offline
    default:
      return .online
    }
  }

  public func gatewayCustomStatusActivity(now: Date = Date()) -> Gateway.Activity? {
    guard hasCustomStatus else { return nil }
    guard !customStatusIsExpired(now: now) else { return nil }

    let status = customStatus
    let emoji =
      status.emojiName.isEmpty && status.emojiID == 0
      ? nil
      : Gateway.Activity.ActivityEmoji(
        name: status.emojiName,
        id: status.emojiID == 0 ? nil : EmojiSnowflake(status.emojiID)
      )

    guard !status.text.isEmpty || emoji != nil else { return nil }

    var activity = Gateway.Activity(
      name: "Custom Status",
      type: .custom,
      state: status.text
    )
    activity.emoji = emoji
    return activity
  }

  private func customStatusIsExpired(now: Date) -> Bool {
    let expiresAtMs = customStatus.expiresAtMs
    guard expiresAtMs != 0 else { return false }
    let nowMs = UInt64(now.timeIntervalSince1970 * 1_000)
    return expiresAtMs <= nowMs
  }

  private func statusIsExpired(now: Date = Date()) -> Bool {
    guard statusExpiresAtMs != 0 else { return false }
    let nowMs = UInt64(now.timeIntervalSince1970 * 1_000)
    return statusExpiresAtMs <= nowMs
  }
}

// MARK: - Protos for encode decode from base64 strings
extension DiscordProtos_DiscordUsers_V1_PreloadedUserSettings: Codable {
  public func encode(to encoder: any Encoder) throws {
    let data = try self.serializedData()
    let protoBase64String = data.base64EncodedString()
    var container = encoder.singleValueContainer()
    try container.encode(protoBase64String)
  }

  public init(from decoder: any Decoder) throws {
    let protoBase64String =
      try decoder
      .singleValueContainer()
      .decode(String.self)
    if let data = Data(base64Encoded: protoBase64String) {
      self = try Self(
        serializedBytes: data
      )
    } else {
      self = .init()
      return
    }
  }
}
extension DiscordProtos_DiscordUsers_V1_FrecencyUserSettings: Codable {
  public func encode(to encoder: any Encoder) throws {
    let data = try self.serializedData()
    let protoBase64String = data.base64EncodedString()
    var container = encoder.singleValueContainer()
    try container.encode(protoBase64String)
  }

  public init(from decoder: any Decoder) throws {
    let protoBase64String =
      try decoder
      .singleValueContainer()
      .decode(String.self)
    if let data = Data(base64Encoded: protoBase64String) {
      self = try Self(
        serializedBytes: data
      )
    } else {
      self = .init()
      return
    }
  }
}
