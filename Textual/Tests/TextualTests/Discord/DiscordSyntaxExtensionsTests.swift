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
