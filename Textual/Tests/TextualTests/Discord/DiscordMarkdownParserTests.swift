import Foundation
import Testing

@testable import Textual

@MainActor
struct DiscordMarkdownParserTests {
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
