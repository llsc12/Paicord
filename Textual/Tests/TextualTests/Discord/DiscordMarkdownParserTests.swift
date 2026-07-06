import Foundation
import Testing

@testable import Textual

@MainActor
struct DiscordMarkdownParserTests {
  @Test func dashLineIsNotASetextHeadingOrThematicBreak() throws {
    // Discord has no setext headings and no thematic breaks — "---" on its own line (and its
    // preceding line) should render as plain, literal text, not turn "test" into a heading and
    // swallow the dashes.
    let result = try DiscordMarkdownParser().attributedString(for: "test\n---\ntest")
    let runs = Array(result.runs)

    #expect(String(result.characters[...]) == "test\n---\ntest")
    #expect(
      runs.allSatisfy { run in
        !(run.presentationIntent?.components.contains { $0.kind == .header(level: 2) } ?? false)
      }
    )
  }

  @Test func plainUnderline() throws {
    let result = try DiscordMarkdownParser().attributedString(for: "__underline__")
    let runs = Array(result.runs)

    #expect(runs.count == 1)
    #expect(String(result.characters[...]) == "underline")
    #expect(runs[0].underlineStyle != nil)
  }

  @Test func underlineDoesNotSuppressNestedFormatting() throws {
    let result = try DiscordMarkdownParser().attributedString(
      for: "__*underlining my italics*__"
    )
    let runs = Array(result.runs)

    #expect(runs.count == 1)
    #expect(String(result.characters[...]) == "underlining my italics")
    #expect(runs[0].underlineStyle != nil)
    #expect(runs[0].inlinePresentationIntent?.contains(.emphasized) == true)
  }

  @Test func onlyTheUnderlinedSpanIsUnderlined() throws {
    let result = try DiscordMarkdownParser().attributedString(
      for: "***bold italics*** and __***bold underlined italics***__!"
    )
    let runs = Array(result.runs)

    #expect(runs.map { String(result[$0.range].characters[...]) } == [
      "bold italics", " and ", "bold underlined italics", "!",
    ])
    #expect(runs.map(\.underlineStyle).map { $0 != nil } == [false, false, true, false])
  }

  @Test func boldIsNotUnderlined() throws {
    let result = try DiscordMarkdownParser().attributedString(for: "**just bold**")
    let runs = Array(result.runs)

    #expect(runs.count == 1)
    #expect(runs[0].underlineStyle == nil)
    #expect(runs[0].inlinePresentationIntent?.contains(.stronglyEmphasized) == true)
  }

  @Test func plainTextWithoutUnderlineIsUnaffected() throws {
    let result = try DiscordMarkdownParser().attributedString(for: "just plain text")
    #expect(String(result.characters[...]) == "just plain text")
    #expect(result.runs.allSatisfy { $0.underlineStyle == nil })
  }
}
