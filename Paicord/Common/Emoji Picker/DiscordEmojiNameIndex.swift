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
  }
}
