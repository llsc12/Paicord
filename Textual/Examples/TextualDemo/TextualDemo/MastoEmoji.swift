import SwiftUI
import Textual

extension Set where Element == Emoji {
  static let mastoEmoji = Bundle.main.mastoEmoji()
}

extension Bundle {
  fileprivate func mastoEmoji() -> Set<Emoji> {
    guard
      let asset = NSDataAsset(name: "masto.ai.emoji", bundle: self),
      let emoji = try? JSONDecoder().decode(Set<Emoji>.self, from: asset.data)
    else {
      return []
    }
    return emoji
  }
}
