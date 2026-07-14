import Foundation

// MARK: - Overview
//
// Discord's `__text__` underline can't be represented by a `SyntaxExtension`: those only rewrite
// individual runs *after* Foundation has already parsed markdown, and Foundation's parser doesn't
// distinguish `__text__` from `**text**` in its output — both become the same "strongly
// emphasized" (bold) presentation intent, with nothing left to tell which marker the source used.
//
// `DiscordMarkdown.preprocess(_:)` rewrites `__text__` into `<u>text</u>` before parsing (see
// `DiscordMarkdownPreprocessor.swift`). Foundation parses `<u>`/`</u>` as their own literal,
// separately-tagged inline-HTML runs while still parsing markdown *between* them normally — so
// nested bold/italic inside an underlined span keeps working. `DiscordMarkdownParser` is the
// second half of that fix: a post-parse pass that walks the resulting runs, applies real
// underline styling to everything between a `<u>`/`</u>` pair, and removes the marker runs
// themselves so they don't show up as visible text.

/// A ``MarkupParser`` for Discord-flavored Markdown.
///
/// Combines `DiscordMarkdown.preprocess(_:)`, Foundation's Markdown parser (with the given
/// `syntaxExtensions`), and post-parse underline handling into one parser, so you don't need to
/// call `DiscordMarkdown.preprocess(_:)` yourself:
///
/// ```swift
/// StructuredText(source, parser: .discordMarkdown(syntaxExtensions: extensions))
/// ```
public struct DiscordMarkdownParser: MarkupParser {
  private let base: AttributedStringMarkdownParser

  /// Creates a Discord-flavored Markdown parser.
  public init(
    baseURL: URL? = nil,
    syntaxExtensions: [AttributedStringMarkdownParser.SyntaxExtension] = []
  ) {
    self.base = AttributedStringMarkdownParser(baseURL: baseURL, syntaxExtensions: syntaxExtensions)
  }

  public func attributedString(for input: String) throws -> AttributedString {
    let parsed = try base.attributedString(for: DiscordMarkdown.preprocess(input))
    return applyingUnderline(to: parsed)
  }

  private func applyingUnderline(to attributedString: AttributedString) -> AttributedString {
    guard attributedString.runs.contains(where: { $0.inlinePresentationIntent?.contains(.inlineHTML) == true })
    else {
      return attributedString
    }

    var output = AttributedString()
    var insideUnderline = false

    for run in attributedString.runs {
      let isUnderlineMarker = run.inlinePresentationIntent?.contains(.inlineHTML) == true
      let text = String(attributedString[run.range].characters[...])

      if isUnderlineMarker, text == "<u>" {
        insideUnderline = true
        continue
      }
      if isUnderlineMarker, text == "</u>" {
        insideUnderline = false
        continue
      }

      guard insideUnderline else {
        output.append(attributedString[run.range])
        continue
      }

      var substring = AttributedString(attributedString[run.range])
      substring.underlineStyle = .single
      output.append(substring)
    }

    return output
  }
}

extension MarkupParser where Self == DiscordMarkdownParser {
  /// Creates a Discord-flavored Markdown parser.
  public static func discordMarkdown(
    baseURL: URL? = nil,
    syntaxExtensions: [AttributedStringMarkdownParser.SyntaxExtension] = []
  ) -> Self {
    .init(baseURL: baseURL, syntaxExtensions: syntaxExtensions)
  }
}
