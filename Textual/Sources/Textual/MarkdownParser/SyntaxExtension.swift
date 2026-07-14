import Foundation

extension AttributedStringMarkdownParser {
  /// A syntax extension that replaces matched tokens after Markdown parsing.
  public struct SyntaxExtension {
    let patterns: [PatternTokenizer.Pattern]
    let replace:
      (
        _ token: PatternTokenizer.Token,
        _ attributes: AttributeContainer
      ) -> AttributedString?

    init(
      patterns: [PatternTokenizer.Pattern],
      replace:
        @escaping (
          _ token: PatternTokenizer.Token,
          _ attributes: AttributeContainer
        ) -> AttributedString?
    ) {
      self.patterns = patterns
      self.replace = replace
    }

    /// Creates a syntax extension from a single regular expression.
    ///
    /// Use this when none of the built-in extensions (``emoji(_:)``, ``math``, or the `discord*`
    /// family in `DiscordSyntaxExtensions.swift`) match what you need — for example, a client's
    /// own mention syntax with app-specific lookups and colors.
    ///
    /// - Parameters:
    ///   - regex: A regex with exactly one capture group; `replace` receives that group's text
    ///     as `capturedContent`.
    ///   - tokenType: A unique name for this token kind. Only needs to be distinct from other
    ///     `SyntaxExtension`s used together in the same `syntaxExtensions` array.
    ///   - replace: Builds the replacement `AttributedString` for a match, given the captured
    ///     text and the base attributes at that point in the source. Return `nil` to leave the
    ///     original matched text untouched.
    public init(
      regex: Regex<(Substring, Substring)>,
      tokenType: String,
      replace:
        @escaping (_ capturedContent: String, _ attributes: AttributeContainer) ->
        AttributedString?
    ) {
      self.patterns = [.init(regex: regex, tokenType: .init(rawValue: tokenType))]
      self.replace = { token, attributes in
        guard let capturedContent = token.capturedContent else {
          return nil
        }
        return replace(capturedContent, attributes)
      }
    }
  }
}

extension AttributedStringMarkdownParser.SyntaxExtension {
  /// Replaces `:shortcode:` sequences using the provided custom emoji definitions.
  public static func emoji(_ emoji: Set<Emoji>) -> Self {
    guard !emoji.isEmpty else {
      return Self(patterns: [], replace: { _, _ in nil })
    }

    let emojiMap = Dictionary(
      uniqueKeysWithValues: emoji.map { emoji in
        (emoji.shortcode, emoji)
      }
    )

    return Self(patterns: [.emoji]) { token, attributes in
      guard let shortcode = token.capturedContent, let emoji = emojiMap[shortcode] else {
        return nil
      }

      return AttributedString(
        shortcode,
        attributes: attributes.emojiURL(emoji.url)
      )
    }
  }

  /// Replaces inline and block math expressions with attachments.
  public static var math: Self {
    .init(patterns: [.mathBlock, .mathInline]) { token, attributes in
      guard let latex = token.capturedContent else {
        return nil
      }

      let attachment = MathAttachment(
        latex: latex,
        style: token.type == .mathBlock ? .block : .inline
      )
      return AttributedString("\u{FFFC}", attributes: attributes.attachment(.init(attachment)))
    }
  }
}
