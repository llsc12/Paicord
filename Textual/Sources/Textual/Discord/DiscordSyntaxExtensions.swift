import Foundation
import SwiftUI

// MARK: - Overview
//
// Discord's inline entity syntax (mentions, custom emoji, timestamps, no-embed links, spoilers,
// subtext) is expressed as `AttributedStringMarkdownParser.SyntaxExtension`s, the same mechanism
// Textual already uses for `:shortcode:` emoji and `$math$`. See `DiscordMarkdownPreprocessor.swift`
// for the block-level quirks that have to be handled before parsing instead.
//
// Interactive entities (mentions, channels, roles, spoilers) are represented as `.link`-attributed
// runs with a `textual-discord://` URL, so they go through Textual's existing tap hit-testing
// (`TextLinkInteraction`) and the `onEntityTap(_:)` hook — Textual itself never interprets these
// URLs. Custom emoji reuse the existing `.emojiURL` attribute/`AttachmentLoader` pipeline, since
// they're purely visual, non-interactive inline content, just like built-in emoji.

extension AttributedStringMarkdownParser.SyntaxExtension {
  /// Replaces user, channel, and role mention syntax (`<@id>`, `<#id>`, `<@&id>`) with tappable
  /// links.
  ///
  /// Mentions carry no display name in the raw markup, so the display text is resolved through
  /// the provided lookups — pull these from whatever local cache your client already has. Tapping
  /// a mention surfaces as a normal link tap; use ``TextualNamespace/onEntityTap(_:)`` to handle
  /// `textual-discord://mention/{user,channel,role}/{id}` and anchor your own UI near the tap.
  public static func discordMentions(
    userName: @escaping @Sendable (String) -> String? = { _ in nil },
    channelName: @escaping @Sendable (String) -> String? = { _ in nil },
    roleName: @escaping @Sendable (String) -> String? = { _ in nil }
  ) -> Self {
    .init(
      patterns: [.discordUserMention, .discordChannelMention, .discordRoleMention]
    ) { token, attributes in
      guard let id = token.capturedContent else {
        return nil
      }

      var attributes = attributes
      switch token.type {
      case .discordUserMention:
        attributes.link = URL(string: "textual-discord://mention/user/\(id)")
        attributes.textual.copyText = "<@\(id)>"
        return AttributedString("@\(userName(id) ?? id)", attributes: attributes)
      case .discordChannelMention:
        attributes.link = URL(string: "textual-discord://mention/channel/\(id)")
        attributes.textual.copyText = "<#\(id)>"
        return AttributedString("#\(channelName(id) ?? id)", attributes: attributes)
      case .discordRoleMention:
        attributes.link = URL(string: "textual-discord://mention/role/\(id)")
        attributes.textual.copyText = "<@&\(id)>"
        return AttributedString("@\(roleName(id) ?? id)", attributes: attributes)
      default:
        return nil
      }
    }
  }

  /// Replaces custom emoji syntax (`<name:id>`, animated `<a:name:id>`) with an emoji attachment,
  /// resolved through the same `AttachmentLoader` pipeline as built-in `:shortcode:` emoji.
  ///
  /// - Parameter cdnURL: Builds the emoji's image URL from its id and whether it's animated.
  ///   Defaults to Discord's CDN.
  /// - Note: Emoji are also tappable (`textual-discord://emoji/{id}?name={name}&animated={bool}`,
  ///   via ``TextualNamespace/onEntityTap(_:)``), even though they render as an attachment.
  ///   Attachments draw into a `Canvas` and can't host their own gesture, so the tappable surface
  ///   is actually the underlying `.link`-attributed placeholder text the attachment draws over —
  ///   the same technique `discordMentions`/`discordSpoilers` use, just combined with an
  ///   attachment here instead of used on its own.
  public static func discordEmoji(
    jumbo: Bool = false,
    cdnURL: @escaping @Sendable (_ id: String, _ animated: Bool, _ jumbo: Bool) -> URL = { id, animated, jumbo in
      URL(string: "https://cdn.discordapp.com/emojis/\(id).webp?size=\(jumbo ? 88 : 44)&animated=\(animated)")!
    }
  ) -> Self {
    .init(patterns: [.discordEmoji]) { token, attributes in
      guard let captured = token.capturedContent else {
        return nil
      }

      let components = captured.split(separator: ":")
      let animated = components.count == 3 && components[0] == "a"
      let nameIndex = animated ? 1 : 0
      guard let id = components.last, components.indices.contains(nameIndex) else {
        return nil
      }
      let name = components[nameIndex]

      var attributes = attributes.emojiURL(cdnURL(String(id), animated, jumbo))
      var linkComponents = URLComponents()
      linkComponents.scheme = "textual-discord"
      linkComponents.host = "emoji"
      linkComponents.path = "/\(id)"
      linkComponents.queryItems = [
        URLQueryItem(name: "name", value: String(name)),
        URLQueryItem(name: "animated", value: animated ? "true" : "false"),
      ]
      attributes.link = linkComponents.url

      // The backing text is just the emoji's name — this becomes `EmojiAttachment`'s `text`,
      // which its `description` (`:name:`) uses for copy/plain-text output. Discord's own copy
      // behavior for a custom emoji is the bare shortcode, with no id and no `a:` animated
      // prefix, so `captured` ("pepe:12345"/"a:partyparrot:5") or `token.content` (which still
      // has the private-use sentinel delimiters too) would both be wrong here.
      return AttributedString(String(name), attributes: attributes)
    }
  }

  /// Replaces timestamp syntax (`<t:unix>`, `<t:unix:FORMAT>`) with text formatted according to
  /// Discord's format flags (`t`, `T`, `d`, `D`, `f`, `F`, `R`).
  ///
  /// Rendered once at parse time — this does not live-update. If you need a `R`-format timestamp
  /// to keep ticking, wrap your own view in a `TimelineView`.
  public static var discordTimestamps: Self {
    .init(patterns: [.discordTimestamp]) { token, attributes in
      guard let captured = token.capturedContent else {
        return nil
      }

      let components = captured.split(separator: ":")
      guard let epoch = TimeInterval(components[0]) else {
        return nil
      }
      let format = components.count > 1 ? String(components[1]) : "f"
      let date = Date(timeIntervalSince1970: epoch)

      return AttributedString(DiscordTimestampFormatter.string(for: date, format: format), attributes: attributes)
    }
  }

  /// Tags links written as `<https://example.com>` (no title/embed) with `NoEmbedAttribute`, so
  /// the consuming app knows not to fetch or render a link-preview embed for that URL. The link
  /// still renders and is still tappable, exactly like a normal link.
  public static var discordNoEmbedLinks: Self {
    .init(patterns: [.discordNoEmbedLink]) { token, attributes in
      guard let urlString = token.capturedContent, let url = URL(string: urlString) else {
        return nil
      }

      var attributes = attributes
      attributes.link = url
      attributes.textual.noEmbed = true
      return AttributedString(urlString, attributes: attributes)
    }
  }

  public static func spoilerRevealKey(index: Int, text: String) -> String {
    "\(index)\u{1F}\(text)"
  }

  /// Replaces spoiler syntax (`||text||`) with a tappable, initially-obscured span.
  ///
  /// Spoiler content is rendered as plain text (no nested inline formatting is parsed inside a
  /// spoiler in this version). `revealed` identifies spoilers by ``spoilerRevealKey(index:text:)``
  /// (not by text alone — two spoilers with identical text in the same message are separate
  /// occurrences) — a consumer keeps a `Set` of revealed keys and re-applies this extension when
  /// it changes. Tapping a spoiler (revealed or not) surfaces as a link tap to
  /// `textual-discord://spoiler/{text}?index={n}` via ``TextualNamespace/onEntityTap(_:)``; build
  /// the reveal key from that URL with ``spoilerRevealKey(index:text:)``.
  public static func discordSpoilers(revealed: Set<String>) -> Self {
    var occurrenceCounts: [String: Int] = [:]

    return .init(patterns: [.discordSpoiler]) { token, attributes in
      guard let content = token.capturedContent else {
        return nil
      }

      let index = occurrenceCounts[content, default: 0]
      occurrenceCounts[content] = index + 1

      var attributes = attributes
      var linkComponents = URLComponents()
      linkComponents.scheme = "textual-discord"
      linkComponents.host = "spoiler"
      linkComponents.path = "/\(content.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")"
      linkComponents.queryItems = [URLQueryItem(name: "index", value: String(index))]
      attributes.link = linkComponents.url

      attributes.textual.preStyledLink = true

      guard revealed.contains(spoilerRevealKey(index: index, text: content)) else {
        attributes.backgroundColor = .gray
        attributes.foregroundColor = .gray
        return AttributedString(content, attributes: attributes)
      }

      // Revealed spoilers keep a faint tint of their original background instead of reverting to
      // plain text, matching Discord's own look. A `.link` attribute renders blue by default
      // regardless of `preStyledLink` (that only stops `InlineStyle` from applying its own link
      // color), so foregroundColor still needs an explicit adaptive value here.
      attributes.backgroundColor = Color.gray.opacity(0.1)
      attributes.foregroundColor = Color.primary
      return AttributedString(content, attributes: attributes)
    }
  }

  /// Detects `-# ` subtext content (already sentinel-wrapped by `DiscordMarkdown.preprocess(_:)`)
  /// and strips the sentinels, applying a smaller, muted style to the remaining text.
  public static var discordSubtext: Self {
    .init(patterns: [.discordSubtext]) { token, attributes in
      guard let content = token.capturedContent else {
        return nil
      }

      // Only marks the span; actual styling comes from `InlineStyle.discord`'s `subtext`
      // property (see `InlineStyle+Discord.swift`) so it can scale relative to the render-time
      // environment — this `replace` closure runs at parse time, before that environment exists.
      var attributes = attributes
      attributes.textual.subtext = true
      return AttributedString(content, attributes: attributes)
    }
  }
}

extension PatternTokenizer.Pattern {
  fileprivate static var discordUserMention: Self {
    .init(regex: /<@!?(\d+)>/, tokenType: .discordUserMention)
  }

  fileprivate static var discordChannelMention: Self {
    .init(regex: /<#(\d+)>/, tokenType: .discordChannelMention)
  }

  fileprivate static var discordRoleMention: Self {
    .init(regex: /<@&(\d+)>/, tokenType: .discordRoleMention)
  }

  // Emoji, timestamps, and no-embed links match a `<scheme:rest>` shape that Foundation's own
  // CommonMark parser already recognizes as an autolink, consuming it before any SyntaxExtension
  // gets a chance to run. `DiscordMarkdown.preprocess(_:)` rewrites their `<...>` delimiters into
  // these private-use sentinels beforehand, so these patterns match the sentinel form, not the
  // original angle brackets.

  fileprivate static var discordEmoji: Self {
    .init(
      // The static case's mandatory colon (`<:name:id>`) is consumed by the leading `:?` and
      // isn't part of the capture — matches `DiscordMarkdownPreprocessor`'s `emojiPattern`, which
      // wraps `<:name:id>`/`<a:name:id>` into this sentinel form before this ever runs.
      regex: /\u{E002}:?((?:a:)?[A-Za-z0-9_]{2,32}:\d+)\u{E003}/,
      tokenType: .discordEmoji
    )
  }

  fileprivate static var discordTimestamp: Self {
    .init(
      regex: /\u{E002}t:(-?\d+(?::[tTdDfFR])?)\u{E003}/,
      tokenType: .discordTimestamp
    )
  }

  fileprivate static var discordNoEmbedLink: Self {
    .init(
      regex: /\u{E002}(https?:\/\/[^\s<>]+)\u{E003}/,
      tokenType: .discordNoEmbedLink
    )
  }

  fileprivate static var discordSpoiler: Self {
    .init(regex: /\|\|(.+?)\|\|/, tokenType: .discordSpoiler)
  }

  fileprivate static var discordSubtext: Self {
    .init(
      regex: /\u{E000}(.*?)\u{E001}/,
      tokenType: .discordSubtext
    )
  }
}

extension PatternTokenizer.TokenType {
  fileprivate static let discordUserMention: Self = "discordUserMention"
  fileprivate static let discordChannelMention: Self = "discordChannelMention"
  fileprivate static let discordRoleMention: Self = "discordRoleMention"
  fileprivate static let discordEmoji: Self = "discordEmoji"
  fileprivate static let discordTimestamp: Self = "discordTimestamp"
  fileprivate static let discordNoEmbedLink: Self = "discordNoEmbedLink"
  fileprivate static let discordSpoiler: Self = "discordSpoiler"
  fileprivate static let discordSubtext: Self = "discordSubtext"
}

/// Formats a Discord timestamp according to its format flag.
enum DiscordTimestampFormatter {
  static func string(for date: Date, format: String) -> String {
    switch format {
    case "t":
      return date.formatted(date: .omitted, time: .shortened)
    case "T":
      return date.formatted(date: .omitted, time: .complete)
    case "d":
      return date.formatted(date: .numeric, time: .omitted)
    case "D":
      return date.formatted(date: .long, time: .omitted)
    case "f":
      return date.formatted(date: .long, time: .shortened)
    case "F":
      return date.formatted(.dateTime.weekday(.wide).day().month(.wide).year().hour().minute())
    case "R":
      return date.formatted(.relative(presentation: .named))
    default:
      return date.formatted()
    }
  }
}
