import Foundation

// MARK: - Overview
//
// Discord's own Markdown parser disagrees with CommonMark (and therefore with Foundation's
// `AttributedString(markdown:)`, which `StructuredText` uses) on several block-level rules. Those
// differences can't be fixed by a `SyntaxExtension` — extensions only rewrite inline runs *after*
// Foundation has already parsed block structure. `DiscordMarkdown.preprocess(_:)` rewrites the raw
// message string beforehand so Foundation's parser produces the block structure Discord intends.
//
// Handled here:
// - Every line break is a visible line break — unlike CommonMark, where consecutive non-blank
//   lines merge into one paragraph (a "soft break" collapses to a space). Discord has no such
//   merging, so non-blank, non-fenced lines get a CommonMark hard-break suffix (two trailing
//   spaces) to force this.
// - Code fences are block-level regardless of adjacency/whitespace around the ``` tokens, unlike
//   CommonMark, which only recognizes a fence that's alone on its own line.
// - Blockquotes never nest: only the first leading `>` (or `>>>`) on a line is a marker; any
//   further `>` characters are literal content.
// - `>>>` starts a blockquote that runs to the end of the message.
// - `-# ` subtext has no CommonMark equivalent, so its content is wrapped in private-use-area
//   sentinels a later `SyntaxExtension` can detect post-parse (see `SyntaxExtension.discordSubtext`).
// - Custom emoji (`<name:id>`, `<a:name:id>`), timestamps (`<t:unix>`, `<t:unix:FORMAT>`), and
//   no-embed links (`<https://url>`) are all shaped like `<scheme:rest>`, which is exactly
//   CommonMark's autolink grammar — Foundation parses them into a plain link *before* any
//   `SyntaxExtension` runs (extensions only see already-parsed runs), silently discarding the
//   distinction. Their spans are rewritten into private-use-area sentinels here so Foundation
//   never recognizes them as autolinks, leaving the corresponding `SyntaxExtension` as the only
//   thing that can match them. Mentions (`<@id>`, `<#id>`, `<@&id>`) don't need this: `@`/`#`/`&`
//   aren't valid scheme-start characters, so Foundation never treats them as autolinks.
//
// Blockquote handling has to happen *before* code-fence normalization and every other per-line
// rule below, and each maximal run of quoted/non-quoted lines has to be processed as its own
// self-contained unit. Otherwise a quoted code fence's `> ` markers end up baked into the fence's
// content (as literal text) instead of being stripped, and the fence's own opening/closing lines
// no longer look like fence lines once they've been rewritten — breaking both the code block and
// its containment inside the blockquote.

/// Namespace for Discord-flavored Markdown utilities.
public enum DiscordMarkdown {
  /// The private-use-area characters used to bracket subtext (`-# `) paragraph content so it
  /// survives Foundation's Markdown parser as ordinary text, ready for `SyntaxExtension` to detect
  /// and restyle.
  static let subtextSentinelStart: Character = "\u{E000}"
  static let subtextSentinelEnd: Character = "\u{E001}"

  /// The private-use-area characters used in place of `<`/`>` around emoji, timestamp, and
  /// no-embed-link spans, so Foundation's Markdown parser can't mistake them for a CommonMark
  /// autolink. `SyntaxExtension.discordEmoji`/`.discordTimestamps`/`.discordNoEmbedLinks` match on
  /// these sentinels instead of the original angle brackets.
  static let protectedTokenStart: Character = "\u{E002}"
  static let protectedTokenEnd: Character = "\u{E003}"

  /// Rewrites raw Discord message content so it parses correctly through
  /// `StructuredText`/`AttributedStringMarkdownParser`.
  public static func preprocess(_ raw: String) -> String {
    quoteGroups(in: raw)
      .map { group in
        let processed = applyNonQuoteLineRules(normalizeCodeFences(group.lines.joined(separator: "\n")))
        guard group.isQuoted else {
          return processed
        }
        return processed.components(separatedBy: "\n").map { "> " + $0 }.joined(separator: "\n")
      }
      .joined(separator: "\n")
  }

  // MARK: Blockquotes

  private struct QuoteGroup {
    let isQuoted: Bool
    let lines: [String]
  }

  /// Splits the message into maximal runs of consecutively quoted / non-quoted lines, stripping
  /// each quoted line's leading `>` marker (Discord blockquotes never nest — only the first `>`
  /// on a line is a marker; any further `>` is literal content, so it's backslash-escaped to stop
  /// CommonMark from reading it as another nesting level).
  private static func quoteGroups(in raw: String) -> [QuoteGroup] {
    var groups: [QuoteGroup] = []
    var currentLines: [String] = []
    var currentIsQuoted = false
    var insideMultilineQuote = false

    func flush() {
      guard !currentLines.isEmpty else { return }
      groups.append(QuoteGroup(isQuoted: currentIsQuoted, lines: currentLines))
      currentLines = []
    }

    for rawLine in raw.components(separatedBy: "\n") {
      let isQuoted: Bool
      let content: String

      if insideMultilineQuote {
        isQuoted = true
        content = escapingLeadingQuoteMarker(in: rawLine)
      } else if let stripped = stripMultilineQuoteMarker(rawLine) {
        insideMultilineQuote = true
        isQuoted = true
        content = escapingLeadingQuoteMarker(in: stripped)
      } else if let stripped = stripSingleQuoteMarker(rawLine) {
        isQuoted = true
        content = escapingLeadingQuoteMarker(in: stripped)
      } else {
        isQuoted = false
        content = rawLine
      }

      if isQuoted != currentIsQuoted {
        flush()
        currentIsQuoted = isQuoted
      }
      currentLines.append(content)
    }
    flush()

    return groups
  }

  private static func escapingLeadingQuoteMarker(in content: String) -> String {
    guard content.hasPrefix(">") else {
      return content
    }
    return "\\" + content
  }

  private static func stripMultilineQuoteMarker(_ line: String) -> String? {
    if line.hasPrefix(">>> ") {
      return String(line.dropFirst(4))
    }
    if line == ">>>" {
      return ""
    }
    return nil
  }

  private static func stripSingleQuoteMarker(_ line: String) -> String? {
    if line.hasPrefix("> ") {
      return String(line.dropFirst(2))
    }
    if line == ">" {
      return ""
    }
    return nil
  }

  // MARK: Code fences

  private static func normalizeCodeFences(_ input: String) -> String {
    let marker = "```"
    var segments: [Substring] = []
    var remainder = input[...]
    while let range = remainder.range(of: marker) {
      segments.append(remainder[..<range.lowerBound])
      remainder = remainder[range.upperBound...]
    }
    segments.append(remainder)

    let markerCount = segments.count - 1
    guard markerCount >= 2, markerCount.isMultiple(of: 2) else {
      // No fences, or an unterminated fence — leave the input untouched rather than guess.
      return input
    }

    var result = String(segments[0])
    var index = 1
    while index + 1 < segments.count {
      result += renderCodeFence(segments[index])
      result += segments[index + 1]
      index += 2
    }
    return result
  }

  /// Discord's fenced-code-block language tags don't always match the names Textual's bundled
  /// Prism-based highlighter recognizes. This has to happen here, before the fence is parsed —
  /// by the time a `CodeBlockStyle` sees a `languageHint`, the block has already been tokenized
  /// using whatever language string was in the raw markdown.
  private static let languageAliases: [String: String] = [
    "cs": "csharp",
    "ps": "powershell",
    "py": "python",
    "ml": "ocaml",
    "md": "markdown",
    "xl": "excel-formula",
  ]

  private static func renderCodeFence(_ inner: Substring) -> String {
    let (language, code) = splitLanguageAndCode(inner)
    let mappedLanguage = languageAliases[language] ?? language
    return "\n```\(mappedLanguage)\n\(code)\n```\n"
  }

  private static func splitLanguageAndCode(_ rawInner: Substring) -> (
    language: String, code: String
  ) {
    var inner = rawInner
    if inner.hasSuffix("\n") {
      inner = inner.dropLast()
    }

    guard let newlineIndex = inner.firstIndex(of: "\n") else {
      // No newline at all: a single-line squashed block (` ```gm``` `) has no language, per
      // Discord's own grammar (a language token is only recognized when immediately followed by
      // a line break).
      return ("", String(inner))
    }

    let firstLine = inner[inner.startIndex..<newlineIndex]
    let rest = inner[inner.index(after: newlineIndex)...]

    if firstLine.isEmpty {
      // An explicit blank first line ("```\ncontent") means no language was specified.
      return ("", String(rest))
    }
    if firstLine.wholeMatch(of: /[A-Za-z0-9_+-]{1,20}/) != nil {
      return (String(firstLine), String(rest))
    }
    // The first line isn't a bare token (contains spaces/punctuation), so it's code, not a
    // language — keep it as part of the content instead of discarding it.
    return ("", String(inner))
  }

  // MARK: Line-level rules (hard breaks, subtext, ambiguous tokens)

  /// Applies every remaining per-line rule to a single quote group's (already fence-normalized)
  /// text: preserving line breaks, extracting subtext, and protecting emoji/timestamp/no-embed
  /// links from being misread as CommonMark autolinks. Skips lines inside a fenced code block,
  /// which should be left untouched.
  private static func applyNonQuoteLineRules(_ input: String) -> String {
    let lines = input.components(separatedBy: "\n")
    var output: [String] = []
    output.reserveCapacity(lines.count)

    var insideCodeFence = false

    for line in lines {
      if line.hasPrefix("```") {
        insideCodeFence.toggle()
        output.append(line)
        continue
      }

      if insideCodeFence {
        output.append(line)
        continue
      }

      let line = preservingLeadingWhitespace(in: escapingThematicBreakLikeLines(line))

      var processed: String
      if let content = stripSubtextMarker(line) {
        processed = "\(subtextSentinelStart)\(content)\(subtextSentinelEnd)"
      } else {
        processed = protectingAmbiguousAngleBracketTokens(in: line)
      }

      processed = convertingUnderlineMarkers(in: processed)

      if !processed.isEmpty {
        // A CommonMark hard-break: forces this line break to survive as a real line break
        // instead of collapsing into a space when merged with the next line's paragraph.
        processed += "  "
      }

      output.append(processed)
    }

    return output.joined(separator: "\n")
  }

  /// Rewrites a line's leading run of ASCII spaces into non-breaking spaces (visually identical,
  /// same width) so CommonMark's line-start whitespace stripping doesn't eat it.
  ///
  /// Every line here gets a hard-break suffix (two trailing spaces) — and per the CommonMark
  /// spec, "leading spaces at the beginning of the next line are ignored" after a line break,
  /// hard or soft. Discord has no such rule and preserves indentation exactly as typed, so plain
  /// ASCII spaces at a line's start would silently vanish once Foundation's parser gets to them.
  /// U+00A0 isn't touched by that stripping rule, so it survives parsing intact.
  private static func preservingLeadingWhitespace(in line: String) -> String {
    let leadingSpaceCount = line.prefix { $0 == " " }.count
    let rest = line.dropFirst(leadingSpaceCount)
    // A line that's nothing but spaces has no content whose indentation needs preserving.
    guard leadingSpaceCount > 0, !rest.isEmpty else {
      return line
    }
    return String(repeating: "\u{00A0}", count: leadingSpaceCount) + rest
  }

  private static func escapingThematicBreakLikeLines(_ line: String) -> String {
    let leadingSpaces = line.prefix(while: { $0 == " " })
    let rest = line.dropFirst(leadingSpaces.count)
    guard leadingSpaces.count <= 3, let marker = rest.first, "-_*=".contains(marker),
      rest.allSatisfy({ $0 == marker })
    else {
      return line
    }
    return String(leadingSpaces) + "\\" + String(rest)
  }

  private static func stripSubtextMarker(_ line: String) -> String? {
    guard line.hasPrefix("-# ") else {
      return nil
    }
    return String(line.dropFirst(3))
  }

  // MARK: Underline

  /// CommonMark (and therefore Foundation's parser) treats `__text__` identically to `**text**`
  /// — both become "strongly emphasized" (bold), with nothing left afterward to tell which
  /// marker the source actually used. Discord instead uses `__text__` for underline, a distinct
  /// style bold doesn't have. Rewriting it as `<u>text</u>` sidesteps the collapse entirely:
  /// Foundation parses inline HTML tags as their own literal, separately-tagged runs (verified
  /// empirically) while still parsing any markdown *between* them normally — so nested bold/italic
  /// inside an underlined span keeps working. `DiscordMarkdownParser` looks for these `<u>`/`</u>`
  /// marker runs after parsing, applies real underline styling to everything between them, and
  /// removes the markers themselves from the visible text.
  private static func convertingUnderlineMarkers(in line: String) -> String {
    line.replacing(underlinePattern) { match in
      "<u>\(match.1)</u>"
    }
  }

  private static var underlinePattern: Regex<(Substring, Substring)> {
    /__([^_]+?)__/
  }

  // MARK: Autolink-ambiguous tokens

  private static func protectingAmbiguousAngleBracketTokens(in line: String) -> String {
    var line = line
    // Order matters only in that each pass only ever touches genuine `<...>` spans it created
    // sentinels for; once replaced, later passes can't re-match the same span.
    line.replace(timestampPattern) { match in
      "\(protectedTokenStart)t:\(match.1)\(protectedTokenEnd)"
    }
    line.replace(emojiPattern) { match in
      "\(protectedTokenStart)\(match.1)\(protectedTokenEnd)"
    }
    line.replace(noEmbedLinkPattern) { match in
      "\(protectedTokenStart)\(match.1)\(protectedTokenEnd)"
    }
    return line
  }

  /// Discord emoji names are 2-32 characters; requiring that length avoids ambiguity with the
  /// single-letter `t:` timestamp scheme.
  ///
  /// A static custom emoji's raw markup always has a colon immediately after `<` (`<:name:id>`);
  /// an animated one has `a:` there instead (`<a:name:id>`) — the leading `:?` consumes that
  /// static-case colon (it isn't part of the capture, matching `discordEmoji`'s expectations in
  /// `DiscordSyntaxExtensions.swift`).
  private static var emojiPattern: Regex<(Substring, Substring)> {
    /<:?((?:a:)?[A-Za-z0-9_]{2,32}:\d+)>/
  }
  private static var timestampPattern: Regex<(Substring, Substring)> {
    /<t:(-?\d+(?::[tTdDfFR])?)>/
  }
  private static var noEmbedLinkPattern: Regex<(Substring, Substring)> {
    /<(https?:\/\/[^\s<>]+)>/
  }
}
