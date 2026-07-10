import Foundation
import Testing

@testable import Textual

@MainActor
struct DiscordEmojiSyntaxExtensionTests {
  private func parse(_ markdown: String) throws -> AttributedString {
    let parser = AttributedStringMarkdownParser(baseURL: nil, syntaxExtensions: [.discordEmoji()])
    return try parser.attributedString(for: DiscordMarkdown.preprocess(markdown))
  }

  @Test func staticEmojiBackingTextIsJustTheName() throws {
    // The run's literal text becomes `EmojiAttachment`'s `text`, which its `description`
    // (":name:") uses for copy/plain-text output — it must not include the id or any `a:`
    // prefix, matching Discord's own copy behavior for a custom emoji.
    let result = try parse("<:pepe:12345>")
    let emojiRun = try #require(result.runs.first { $0.textual.emojiURL != nil })
    #expect(String(result[emojiRun.range].characters[...]) == "pepe")
  }

  @Test func animatedEmojiBackingTextIsJustTheName() throws {
    let result = try parse("<a:partyparrot:5>")
    let emojiRun = try #require(result.runs.first { $0.textual.emojiURL != nil })
    #expect(String(result[emojiRun.range].characters[...]) == "partyparrot")
  }

  @Test func staticEmojiIsTappable() throws {
    let result = try parse("<:pepe:12345>")
    let emojiRun = try #require(result.runs.first { $0.textual.emojiURL != nil })
    #expect(emojiRun.link?.host == "emoji")
    #expect(emojiRun.link?.lastPathComponent == "12345")
  }

  @Test func animatedEmojiIsTappable() throws {
    let result = try parse("<a:partyparrot:5>")
    let emojiRun = try #require(result.runs.first { $0.textual.emojiURL != nil })
    #expect(emojiRun.link?.host == "emoji")
    #expect(emojiRun.link?.lastPathComponent == "5")

    let query = URLComponents(url: try #require(emojiRun.link), resolvingAgainstBaseURL: false)?
      .queryItems
    #expect(query?.first { $0.name == "animated" }?.value == "true")
  }

  @Test func emojiURLPointsAtDiscordCDNByDefault() throws {
    let result = try parse("<:pepe:12345>")
    let emojiRun = try #require(result.runs.first { $0.textual.emojiURL != nil })
    #expect(emojiRun.textual.emojiURL == URL(string: "https://cdn.discordapp.com/emojis/12345.png"))
  }

  @Test func adjacentIdenticalEmojiStayAsSeparateRuns() throws {
    // Three back-to-back, otherwise attribute-identical emoji runs would silently coalesce into
    // one via AttributedString's attribute-equality-based run grouping, leaving only one
    // attachment resolved for all three — see `RunDiscriminatorAttribute`.
    let result = try parse("<:pepe:12345><:pepe:12345><:pepe:12345>")
    let emojiRuns = result.runs.filter { $0.textual.emojiURL != nil }
    #expect(emojiRuns.count == 3)
  }
}

@MainActor
struct DiscordMentionSyntaxExtensionTests {
  private func parse(_ markdown: String) throws -> AttributedString {
    let parser = AttributedStringMarkdownParser(
      baseURL: nil,
      syntaxExtensions: [
        .discordMentions(
          userName: { _ in "user" },
          channelName: { _ in "channel" },
          roleName: { _ in "role" }
        )
      ]
    )
    return try parser.attributedString(for: DiscordMarkdown.preprocess(markdown))
  }

  @Test func userMentionCopiesTheRawEntity() throws {
    let result = try parse("<@123>")
    let mentionRun = try #require(result.runs.first { $0.link != nil })
    #expect(String(result[mentionRun.range].characters[...]) == "@user")
    #expect(mentionRun.textual.copyText == "<@123>")
  }

  @Test func channelMentionCopiesTheRawEntity() throws {
    let result = try parse("<#456>")
    let mentionRun = try #require(result.runs.first { $0.link != nil })
    #expect(mentionRun.textual.copyText == "<#456>")
  }

  @Test func roleMentionCopiesTheRawEntity() throws {
    let result = try parse("<@&789>")
    let mentionRun = try #require(result.runs.first { $0.link != nil })
    #expect(mentionRun.textual.copyText == "<@&789>")
  }

  @Test func plainTextExportUsesTheRawEntity() throws {
    let result = try parse("ping <@123> please")
    let formatter = Formatter(result)
    #expect(formatter.plainText() == "ping <@123> please")
  }
}

@MainActor
struct DiscordSpoilerSyntaxExtensionTests {
  private func parse(_ markdown: String, revealed: Set<String> = []) throws -> AttributedString {
    let parser = AttributedStringMarkdownParser(
      baseURL: nil,
      syntaxExtensions: [.discordSpoilers(revealed: revealed)]
    )
    return try parser.attributedString(for: DiscordMarkdown.preprocess(markdown))
  }

  @Test func hiddenSpoilerMatchesForegroundToBackground() throws {
    let result = try parse("||secret||")
    let spoilerRun = try #require(result.runs.first { $0.link != nil })
    #expect(spoilerRun.foregroundColor == spoilerRun.backgroundColor)
  }

  @Test func revealedSpoilerUsesItsOwnKey() throws {
    let key = AttributedStringMarkdownParser.SyntaxExtension.spoilerRevealKey(
      index: 0, text: "secret")
    let result = try parse("||secret||", revealed: [key])
    let spoilerRun = try #require(result.runs.first { $0.link != nil })
    #expect(spoilerRun.foregroundColor != spoilerRun.backgroundColor)
  }

  @Test func duplicateSpoilerTextGetsDistinctIndices() throws {
    let result = try parse("||same|| ||same||")
    let spoilerRuns = result.runs.filter { $0.link != nil }
    #expect(spoilerRuns.count == 2)

    let indices = spoilerRuns.map { run in
      URLComponents(url: run.link!, resolvingAgainstBaseURL: false)?
        .queryItems?.first { $0.name == "index" }?.value
    }
    #expect(indices == ["0", "1"])
  }

  @Test func revealingOneOccurrenceLeavesTheDuplicateHidden() throws {
    let firstKey = AttributedStringMarkdownParser.SyntaxExtension.spoilerRevealKey(
      index: 0, text: "same")
    let result = try parse("||same|| ||same||", revealed: [firstKey])
    let spoilerRuns = result.runs.filter { $0.link != nil }
    #expect(spoilerRuns.count == 2)

    let first = spoilerRuns[0]
    let second = spoilerRuns[1]
    #expect(first.foregroundColor != first.backgroundColor)
    #expect(second.foregroundColor == second.backgroundColor)
  }
}
