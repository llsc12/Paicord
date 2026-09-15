//
//  DiscordEmojiNameIndex.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 14/07/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation

enum DiscordEmojiNameIndex {
  private struct Entry: Decodable {
    let n: [String]
    let s: String
  }

  @MainActor private static var byCharacter: [String: [String]]?
  @MainActor private static var byName: [String: String]?
  /// Discord's spelling of each emoji, keyed by the character with every
  /// variation selector removed.
  @MainActor private static var byBareCharacter: [String: String]?

  @MainActor
  static func names(for character: String) -> [String]? {
    loadIfNeeded()
    return byCharacter?[character]
  }

  @MainActor
  static func character(forName name: String) -> String? {
    loadIfNeeded()
    return byName?[name]
  }

  /// Maps a character onto Discord's spelling of it, or nil if Discord has no
  /// such emoji.
  ///
  /// Discord matches reaction emoji against its own table byte for byte, and
  /// the picker's grid comes from SwiftEmojiIndex, which spells some sequences
  /// differently - almost always a U+FE0F variation selector that one side
  /// includes and the other doesn't. Reacting with the unnormalised character
  /// fails with "Unknown Emoji" (10014).
  @MainActor
  static func discordCharacter(matching character: String) -> String? {
    loadIfNeeded()
    if byCharacter?[character] != nil { return character }
    return byBareCharacter?[bare(character)]
  }

  private static func bare(_ character: String) -> String {
    character.replacingOccurrences(of: "\u{FE0F}", with: "")
  }

  @MainActor
  private static func loadIfNeeded() {
    guard byCharacter == nil else { return }
    guard
      let url = Bundle.main.url(forResource: "DiscordEmojiNames", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let entries = try? JSONDecoder().decode([Entry].self, from: data)
    else {
      byCharacter = [:]
      byName = [:]
      byBareCharacter = [:]
      return
    }
    byCharacter = Dictionary(entries.map { ($0.s, $0.n) }, uniquingKeysWith: { first, _ in first })
    var nameLookup: [String: String] = [:]
    for entry in entries {
      for name in entry.n where nameLookup[name] == nil {
        nameLookup[name] = entry.s
      }
    }
    byName = nameLookup
    var bareLookup: [String: String] = [:]
    for entry in entries where bareLookup[bare(entry.s)] == nil {
      bareLookup[bare(entry.s)] = entry.s
    }
    byBareCharacter = bareLookup
  }
}
