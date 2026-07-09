import Testing

@testable import Textual

struct DiscordMarkdownPreprocessorTests {
  // MARK: Code fences

  @Test func codeBlocksSeparatedByNewline() {
    let input = "```\ngm\n```\n\n```\ngn\n```"
    #expect(
      DiscordMarkdown.preprocess(input)
        == "\n```\ngm\n```\n\n\n\n```\ngn\n```\n"
    )
  }

  @Test func codeBlocksWithEndingAndStartingTokensSeparatedBySpace() {
    let input = "```\ngm\n``` ```\ngn\n```"
    #expect(
      DiscordMarkdown.preprocess(input)
        == "\n```\ngm\n```\n   \n```\ngn\n```\n"
    )
  }

  @Test func codeBlocksSeparatedBySpaceOnOneLine() {
    let input = "```gm``` ```gn```"
    #expect(
      DiscordMarkdown.preprocess(input)
        == "\n```\ngm\n```\n   \n```\ngn\n```\n"
    )
  }

  @Test func codeBlocksWithNoSeparation() {
    let input = "```gm``````gn```"
    #expect(
      DiscordMarkdown.preprocess(input)
        == "\n```\ngm\n```\n\n```\ngn\n```\n"
    )
  }

  @Test func codeBlockWithLanguageIsPreserved() {
    let input = "```swift\nlet x = 1\n```"
    #expect(
      DiscordMarkdown.preprocess(input)
        == "\n```swift\nlet x = 1\n```\n"
    )
  }

  @Test func unterminatedFenceIsLeftUntouched() {
    let input = "```gm"
    #expect(DiscordMarkdown.preprocess(input) == input)
  }

  // MARK: Blockquotes

  @Test func singleLineBlockQuoteIsUnaffected() {
    #expect(DiscordMarkdown.preprocess("> wagwan") == "> wagwan  ")
  }

  @Test func repeatedQuoteMarkerOnOneLineIsLiteral() {
    // `> > gm` must not be read as a nested blockquote: only the first `>` is a marker, the
    // second is escaped so it survives as literal text.
    #expect(DiscordMarkdown.preprocess("> > gm") == "> \\> gm  ")
  }

  @Test func multilineQuoteRunsToEndOfMessage() {
    // A blank line inside the quoted span must still get its own `>` marker, otherwise
    // CommonMark would read the blank line as ending the blockquote early.
    let input = "hello **world**\n>>> wagwan\n\nnidsng\nasdfsdfsdsf"
    #expect(
      DiscordMarkdown.preprocess(input)
        == "hello **world**  \n> wagwan  \n> \n> nidsng  \n> asdfsdfsdsf  "
    )
  }

  @Test func codeBlockInsideBlockQuoteStaysInsideAndKeepsMarkersOut() {
    // Every line of the quote (including the fence markers) is prefixed with `> `. The fence's
    // own `> ` markers must be stripped before fence detection runs, otherwise the code content
    // ends up with a literal `> ` baked in and the fence no longer looks like a fence line (so
    // it falls out of the blockquote entirely).
    let input = "> before\n> ```swift\n> // like code\n> ```\n> after"
    #expect(
      DiscordMarkdown.preprocess(input)
        == "> before  \n> \n> ```swift\n> // like code\n> ```\n> \n> after  "
    )
  }

  // MARK: Subtext

  @Test func subtextConsumesOnlyItsOwnMarker() {
    // `-# # a` must render as literal `# a`, not as a heading — the header marker is never
    // reinterpreted once the subtext marker has already claimed the line.
    let result = DiscordMarkdown.preprocess("-# # a")
    #expect(
      result
        == "\(DiscordMarkdown.subtextSentinelStart)# a\(DiscordMarkdown.subtextSentinelEnd)  "
    )
  }

  @Test func plainSubtext() {
    let result = DiscordMarkdown.preprocess("-# a footnote")
    #expect(
      result
        == "\(DiscordMarkdown.subtextSentinelStart)a footnote\(DiscordMarkdown.subtextSentinelEnd)  "
    )
  }

  // MARK: Underline

  @Test func plainUnderlineBecomesInlineHTML() {
    // CommonMark (and Foundation's parser) treats `__text__` identically to `**text**`; rewriting
    // it as `<u>text</u>` beforehand is the only way to keep the distinction, since Foundation
    // parses inline HTML tags as their own separately-tagged runs.
    #expect(DiscordMarkdown.preprocess("__underline__") == "<u>underline</u>  ")
  }

  @Test func underlineWrappingNestedFormattingIsPreserved() {
    #expect(
      DiscordMarkdown.preprocess("__*underlining my italics*__")
        == "<u>*underlining my italics*</u>  "
    )
  }

  @Test func boldIsNotAffectedByUnderlineConversion() {
    #expect(DiscordMarkdown.preprocess("**just bold**") == "**just bold**  ")
  }

  // MARK: Line breaks

  @Test func consecutiveLinesGetAHardBreak() {
    // Unlike CommonMark (where consecutive non-blank lines merge into one paragraph), every
    // Discord line break is visible. Each non-blank, non-fenced line needs a CommonMark
    // hard-break suffix (two trailing spaces) so Foundation preserves it as a real line break
    // instead of collapsing it into a space.
    let input = "line one\nline two\nline three"
    #expect(DiscordMarkdown.preprocess(input) == "line one  \nline two  \nline three  ")
  }

  @Test func leadingWhitespaceOnContinuationLinesIsPreserved() {
    // CommonMark strips leading spaces at the start of a line following a line break (hard or
    // soft) — but Discord preserves indentation exactly as typed, so it has to survive here as
    // non-breaking spaces instead of plain ones.
    let input = "first\n   second\n      third"
    #expect(
      DiscordMarkdown.preprocess(input)
        == "first  \n\u{00A0}\u{00A0}\u{00A0}second  \n\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}third  "
    )
  }

  @Test func whitespaceOnlyLineIsUnaffectedByIndentationPreservation() {
    let input = "before\n   \nafter"
    // The whitespace-only middle line is left as plain spaces (not converted to non-breaking
    // spaces), but still gets its own hard-break suffix like any other non-empty line.
    #expect(DiscordMarkdown.preprocess(input) == "before  \n     \nafter  ")
  }

  @Test func blankLineSeparatedParagraphsAreUnaffected() {
    let input = "paragraph one\n\nparagraph two"
    #expect(DiscordMarkdown.preprocess(input) == "paragraph one  \n\nparagraph two  ")
  }

  @Test func linesInsideAFenceDoNotGetAHardBreak() {
    let input = "```\nline one\nline two\n```"
    #expect(DiscordMarkdown.preprocess(input) == "\n```\nline one\nline two\n```\n")
  }

  // MARK: Sanity

  @Test func plainTextIsUnaffected() {
    let input = "just a regular paragraph with **bold** and _italics_"
    #expect(DiscordMarkdown.preprocess(input) == input + "  ")
  }

  // MARK: Emoji-only content

  @Test func customEmojiOnlyContentIsEmojiOnly() {
    #expect(DiscordMarkdown.isEmojiOnlyContent("<:pepe:4><a:party:5>"))
  }

  @Test func unicodeEmojiOnlyContentIsEmojiOnly() {
    #expect(DiscordMarkdown.isEmojiOnlyContent("🎉 🎊"))
  }

  @Test func mixedEmojiAndTextIsNotEmojiOnly() {
    #expect(!DiscordMarkdown.isEmojiOnlyContent("nice <:pepe:4>"))
  }

  @Test func plainTextIsNotEmojiOnly() {
    #expect(!DiscordMarkdown.isEmojiOnlyContent("just text"))
  }

  @Test func emptyContentIsNotEmojiOnly() {
    #expect(!DiscordMarkdown.isEmojiOnlyContent("   "))
  }
}
