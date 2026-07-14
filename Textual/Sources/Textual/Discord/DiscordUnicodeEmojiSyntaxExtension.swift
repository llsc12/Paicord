import RegexBuilder
import SwiftUI

private struct EmojiCharacterMatcher: CustomConsumingRegexComponent {
  typealias RegexOutput = Substring

  func consuming(
    _ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) throws -> (upperBound: String.Index, output: Substring)? {
    guard index < bounds.upperBound, input[index].isEmojiLike else {
      return nil
    }
    let upperBound = input.index(after: index)
    return (upperBound, input[index..<upperBound])
  }
}

extension AttributedStringMarkdownParser.SyntaxExtension {
  public static var discordUnicodeEmoji: Self {
    .init(
      patterns: [
        .init(
          regex: Regex { Capture { EmojiCharacterMatcher() } },
          tokenType: "discordUnicodeEmoji"
        )
      ]
    ) { token, attributes in
      guard let character = token.capturedContent else {
        return nil
      }

      var linkComponents = URLComponents()
      linkComponents.scheme = "textual-discord"
      linkComponents.host = "emoji"
      linkComponents.path = "/unicode"
      linkComponents.queryItems = [URLQueryItem(name: "char", value: character)]

      var attributes = attributes.attachment(.init(UnicodeEmojiAttachment(character: character)))
      attributes.link = linkComponents.url

      return AttributedString(character, attributes: attributes)
    }
  }
}
