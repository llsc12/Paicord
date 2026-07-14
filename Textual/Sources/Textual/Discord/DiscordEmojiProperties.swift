import SwiftUI

// MARK: - Overview
//
// Discord renders custom (and standard Unicode) emoji larger — "jumbo" size, 44x44 in its own
// Electron app — when a message consists of *only* emoji (and whitespace). Otherwise emoji render
// at their standard inline size, which then scales naturally with the surrounding text (including
// inside headings), since `EmojiProperties` is expressed as a `FontScaled` value resolved against
// the current environment font — no extra work needed for that part.
//
// Checking "is this message emoji-only" needs whole-message context a `SyntaxExtension` doesn't
// have, so it's a separate helper: call it once on the raw (pre-`preprocess`) source, then apply
// `.discordJumbo` or `.discordStandard` via `.textual.emojiProperties(_:)` accordingly.

extension EmojiProperties {
  /// The standard inline emoji size Discord uses inside ordinary text.
  public static var discordStandard: Self {
    .init()
  }

  /// Discord's larger "jumbo" emoji size, used when a message consists only of emoji.
  ///
  /// Scales relative to the current font (roughly double the standard inline size) so it stays
  /// proportionate across Dynamic Type sizes and custom fonts, but never resolves smaller than
  /// Discord's own fixed 44x44 — matching Discord's own app at typical/small text sizes, while
  /// still growing further at larger Dynamic Type sizes instead of staying pinned at 44x44.
  public static var discordJumbo: Self {
    .init(
      size: .fontScaled(width: 2, height: 2),
      baselineOffset: .fontScaled(-0.2),
      minimumSize: CGSize(width: 44, height: 44)
    )
  }
}

extension DiscordMarkdown {
  /// Returns whether `raw` (the un-preprocessed message source) consists only of emoji — custom
  /// Discord emoji (`<:name:id>`, `<a:name:id>`) and/or standard Unicode emoji — and whitespace.
  ///
  /// Call this before rendering to decide between `.discordJumbo` and `.discordStandard`:
  ///
  /// ```swift
  /// StructuredText(markdown: DiscordMarkdown.preprocess(source), syntaxExtensions: extensions)
  ///   .textual.emojiProperties(
  ///     DiscordMarkdown.isEmojiOnlyContent(source) ? .discordJumbo : .discordStandard
  ///   )
  /// ```
  public static func isEmojiOnlyContent(_ raw: String) -> Bool {
    let withoutCustomEmoji = raw.replacing(customEmojiPattern, with: "")

    let hasCustomEmoji = withoutCustomEmoji.count < raw.count
    let hasUnicodeEmoji = withoutCustomEmoji.contains(where: \.isEmojiLike)
    let hasOtherContent = withoutCustomEmoji.contains { !$0.isWhitespace && !$0.isEmojiLike }

    return (hasCustomEmoji || hasUnicodeEmoji) && !hasOtherContent
  }

  private static var customEmojiPattern: Regex<Substring> {
    /<:?(?:a:)?[A-Za-z0-9_]{2,32}:\d+>/
  }
}

extension Character {
  fileprivate var isEmojiLike: Bool {
    guard let firstScalar = unicodeScalars.first else {
      return false
    }
    return firstScalar.properties.isEmoji && (firstScalar.value > 0x238C || unicodeScalars.count > 1)
  }
}
