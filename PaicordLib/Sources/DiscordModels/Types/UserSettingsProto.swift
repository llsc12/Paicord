//
//  UserSettingsProto.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 10/03/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation

public enum UserSettingsProto: Sendable, Codable {
  case preloaded(DiscordProtos_DiscordUsers_V1_PreloadedUserSettings)
  case frecency(DiscordProtos_DiscordUsers_V1_FrecencyUserSettings)
  case unknown(String)

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    // this payload has no type hints.
    // try each type and see if it works.
    if let preloaded = try? container.decode(
      DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.self
    ) {
      self = .preloaded(preloaded)
    } else if let frecency = try? container.decode(
      DiscordProtos_DiscordUsers_V1_FrecencyUserSettings.self
    ) {
      self = .frecency(frecency)
    } else {
      let str = try container.decode(String.self)
      self = .unknown(str)
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .preloaded(let preloaded):
      try container.encode(preloaded)
    case .frecency(let frecency):
      try container.encode(frecency)
    case .unknown(let str):
      try container.encode(str)
    }
  }
}

/// https://docs.discord.food/resources/user-settings-proto#response-body
public struct UserSettingsProtoResponse: Sendable, Codable {
  public var settings: UserSettingsProto
  public var out_of_date: Bool?
}
