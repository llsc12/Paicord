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

  @MainActor
  static func names(for character: String) -> [String]? {
    if byCharacter == nil {
      byCharacter = load()
    }
    return byCharacter?[character]
  }

  private static func load() -> [String: [String]] {
    guard
      let url = Bundle.main.url(forResource: "DiscordEmojiNames", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let entries = try? JSONDecoder().decode([Entry].self, from: data)
    else {
      return [:]
    }
    return Dictionary(entries.map { ($0.s, $0.n) }, uniquingKeysWith: { first, _ in first })
  }
}
