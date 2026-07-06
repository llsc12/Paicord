//
//  MarkdownText.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//

import PaicordLib
import SwiftUI
import Textual

struct MarkdownText: View {
  let content: String
  let channelStore: ChannelStore?
  var foregroundColorOverride: Color?

  var allowsJumboEmoji: Bool

  @Environment(\.theme) var theme
  @State private var revealedSpoilers: Set<String> = []
  @State private var userPopover: PartialUser?

  init(
    content: String,
    channelStore: ChannelStore? = nil,
    allowsJumboEmoji: Bool = false
  ) {
    self.content = content
    self.channelStore = channelStore
    self.allowsJumboEmoji = allowsJumboEmoji
  }

  /// Overrides the text color, e.g. to indicate a failed-to-send message.
  func errorColor(_ color: Color?) -> MarkdownText {
    var copy = self
    copy.foregroundColorOverride = color
    return copy
  }

  private var guildStore: GuildStore? { channelStore?.guildStore }

  var body: some View {
    StructuredText(
      content,
      parser: .discordMarkdown(syntaxExtensions: syntaxExtensions),
      revision: revision
    )
    .textual.structuredTextStyle(.discord)
    .textual.inlineStyle(inlineStyle)
    .textual.highlighterTheme(highlighterTheme)
    .textual.codeBlockStyle(PaicordCodeBlockStyle())
    .textual.emojiProperties(
      allowsJumboEmoji && DiscordMarkdown.isEmojiOnlyContent(content)
        ? .discordJumbo : .discordStandard
    )
    .textual.textSelection(.enabled)
    .foregroundStyle(foregroundColorOverride ?? theme.markdown.text)
    .environment(\.openURL, OpenURLAction { handleURL($0) })
    .popover(item: $userPopover) { user in
      ProfilePopoutView(
        guild: channelStore?.guildStore,
        member: channelStore?.guildStore?.members[user.id],
        user: user
      )
    }
  }

  // MARK: - Styling

  private var inlineStyle: InlineStyle {
    InlineStyle()
      .code(.monospaced, .fontScale(0.94), .backgroundColor(DynamicColor(theme.markdown.codeSpanBackground)))
      .strong(.fontWeight(.semibold))
      .link(.foregroundColor(DynamicColor(theme.common.hyperlink)))
      .subtext(.fontScale(0.75), .foregroundColor(DynamicColor(theme.markdown.secondaryText)))
  }

  private var highlighterTheme: StructuredText.HighlighterTheme {
    .init(
      foregroundColor: .init(theme.markdown.text),
      backgroundColor: .init(theme.markdown.codeBlockBackground),
      tokenProperties: StructuredText.HighlighterTheme.default.tokenProperties
    )
  }

  // MARK: - Re-parsing

  /// Custom syntax extensions bake resolved names/colors into the parsed `AttributedString`, so
  /// changing data they depend on (a nickname, a role's color, the theme, revealed spoilers)
  /// needs a re-parse, which `revision` triggers without resetting the view's identity.
  private struct RevisionSignature: Hashable {
    let userCount: Int
    let memberCount: Int?
    let roleCount: Int?
    let channelCount: Int?
    let themeID: String
    let revealedSpoilers: Set<String>
  }

  private var revision: RevisionSignature {
    RevisionSignature(
      userCount: GatewayStore.shared.user.users.count,
      memberCount: guildStore?.members.count,
      roleCount: guildStore?.roles.count,
      channelCount: guildStore?.channels.count,
      themeID: theme.id,
      revealedSpoilers: revealedSpoilers
    )
  }

  private var syntaxExtensions: [AttributedStringMarkdownParser.SyntaxExtension] {
    var extensions = AttributedStringMarkdownParser.SyntaxExtension.paicordMentions(
      guildStore: guildStore,
      theme: theme
    )
    extensions.append(
      .discordEmoji { id, animated in
        let base = CDNEndpoint.customEmoji(emojiId: EmojiSnowflake(id)).url
        return URL(string: base + (animated ? ".gif" : ".png") + "?size=44")!
      }
    )
    extensions.append(.discordTimestamps)
    extensions.append(.discordNoEmbedLinks)
    extensions.append(.discordSpoilers(revealed: revealedSpoilers))
    extensions.append(.discordSubtext)
    return extensions
  }

  // MARK: - Link handling

  private func handleURL(_ url: URL) -> OpenURLAction.Result {
    if url.scheme == "textual-discord" {
      if url.host == "spoiler",
        let encoded = url.pathComponents.last,
        let text = encoded.removingPercentEncoding
      {
        revealedSpoilers.insert(text)
      }
      return .handled
    }

    guard let cmd = PaicordChatLink(url: url) else {
      return .systemAction
    }
    let gw = GatewayStore.shared

    switch cmd {
    case .userMention(let userID):
      if let user = gw.user.users[userID] {
        ImpactGenerator.impact(style: .light)
        userPopover = user
      }
    default:
      print("[MarkdownText] Unhandled special link: \(cmd)")
      return .discarded
    }

    return .handled
  }

  private struct PaicordCodeBlockStyle: StructuredText.CodeBlockStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
      StructuredText.DefaultCodeBlockStyle().makeBody(configuration: configuration)
        .overlay(alignment: .topTrailing) {
          #if os(macOS)
            if isHovered {
              Button {
                configuration.codeBlock.copyToPasteboard()
              } label: {
                Image(systemName: "doc.on.doc")
                  .padding(6)
                  .background(.ultraThinMaterial)
                  .clipShape(Circle())
              }
              .buttonStyle(.plain)
              .padding(6)
            }
          #endif
        }
        .onHover { isHovered = $0 }
    }
  }
}

// MARK: - Paicord mention syntax extensions

extension AttributedStringMarkdownParser.SyntaxExtension {
  /// User (`<@id>`), channel (`<#id>`), role (`<@&id>`), `@everyone`, and `@here` mentions,
  /// resolved against live gateway/guild state and styled with the current theme.
  fileprivate static func paicordMentions(
    guildStore: GuildStore?,
    theme: Theming.Theme
  ) -> [Self] {
    let gw = GatewayStore.shared

    func mention(
      text: String,
      link: String,
      foreground: Color,
      background: Color,
      base: AttributeContainer
    ) -> AttributedString {
      var attributes = base
      attributes.link = URL(string: link)
      attributes.textual.mention = true
      attributes.foregroundColor = foreground
      attributes.backgroundColor = background
      attributes.inlinePresentationIntent = .stronglyEmphasized
      return AttributedString(text, attributes: attributes)
    }

    let defaultForeground = theme.markdown.mentionText
    let defaultBackground = theme.markdown.mentionBackground

    let userMention = Self(regex: /<@!?(\d+)>/, tokenType: "paicordUserMention") { id, base in
      let userID = UserSnowflake(id)
      let name: String
      if let user = gw.user.users[userID] {
        name = guildStore?.members[userID]?.nick ?? user.global_name ?? user.username ?? id
      } else {
        name = id
      }
      return mention(
        text: "@\(name)",
        link: "paicord://mention/user/\(id)",
        foreground: defaultForeground,
        background: defaultBackground,
        base: base
      )
    }

    let channelMention = Self(regex: /<#(\d+)>/, tokenType: "paicordChannelMention") { id, base in
      let channelID = ChannelSnowflake(id)
      let name = guildStore?.channels[channelID]?.name ?? id
      return mention(
        text: "#\(name)",
        link: "paicord://mention/channel/\(id)",
        foreground: defaultForeground,
        background: defaultBackground,
        base: base
      )
    }

    let roleMention = Self(regex: /<@&(\d+)>/, tokenType: "paicordRoleMention") { id, base in
      let roleID = RoleSnowflake(id)
      guard let role = guildStore?.roles[roleID] else {
        return mention(
          text: "@\(id)",
          link: "paicord://mention/role/\(id)",
          foreground: defaultForeground,
          background: defaultBackground,
          base: base
        )
      }
      let color = role.color.asColor()
      return mention(
        text: "@\(role.name)",
        link: "paicord://mention/role/\(id)",
        foreground: color ?? defaultForeground,
        background: color.map { $0.opacity(0.08) } ?? defaultBackground,
        base: base
      )
    }

    let everyoneMention = Self(regex: /@(everyone)/, tokenType: "paicordEveryoneMention") { _, base in
      mention(
        text: "@everyone",
        link: "paicord://mention/everyone",
        foreground: defaultForeground,
        background: defaultBackground,
        base: base
      )
    }

    let hereMention = Self(regex: /@(here)/, tokenType: "paicordHereMention") { _, base in
      mention(
        text: "@here",
        link: "paicord://mention/here",
        foreground: defaultForeground,
        background: defaultBackground,
        base: base
      )
    }

    return [userMention, channelMention, roleMention, everyoneMention, hereMention]
  }
}

// MARK: - Lightweight fallback

/// A cheap, non-interactive rendering of Discord markdown for contexts (like reply previews)
/// where full `MarkdownText` parsing would be wasted work.
extension Text {
  init(
    markdown: String,
    fallback: AttributedString = "",
    syntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax =
      .inlineOnlyPreservingWhitespace
  ) {
    self.init(
      (try? AttributedString(
        markdown: markdown,
        options: AttributedString.MarkdownParsingOptions(
          interpretedSyntax: syntax
        )
      )) ?? fallback
    )
  }
}

// MARK: - Link parsing

enum PaicordChatLink {
  case userMention(UserSnowflake)
  case roleMention(RoleSnowflake)
  case channelMention(ChannelSnowflake)
  case emoji(EmojiSnowflake)
  case invite(String)  // invite code
  case everyoneMention
  case hereMention

  // if guild id is nil, channel should probably exist
  // if guild id is nil, it's a DM channel, possibly with message
  // if guild id is not nil, it could be a guild only, or a guild and channel, or even a guild and channel and message
  case discordNavigationLink(
    GuildSnowflake?,
    ChannelSnowflake?,
    MessageSnowflake?
  )

  init?(url: URL) {
    guard
      url.scheme == "paicord"
        || ((url.host() == "discord.com" || url.host() == "discord.gg"
          || url.host() == "discordapp.com")
          && url.scheme == "https")
    else { return nil }
    switch url.host() {
    case "discord.gg":
      // invite link
      let pathComponents = url.pathComponents.filter { $0 != "/" }
      guard let first = pathComponents.first else { return nil }
      let inviteCode = first
      self = .invite(inviteCode)
    case "discord.com", "discordapp.com":
      let pathComponents = url.pathComponents.filter { $0 != "/" }
      guard let first = pathComponents.first else { return nil }
      switch first {
      case "channels":
        guard pathComponents.count >= 4,
          let guildId = pathComponents[safe: 1],
          let channelId = pathComponents[safe: 2],
          let messageId = pathComponents[safe: 3]
        else { return nil }
        let guildSnowflake = guildId == "@me" ? nil : GuildSnowflake(guildId)
        let channelSnowflake = ChannelSnowflake(channelId)
        let messageSnowflake = MessageSnowflake(messageId)

        self = .discordNavigationLink(
          guildSnowflake,
          channelSnowflake,
          messageSnowflake
        )
      case "invite":
        guard pathComponents.count >= 2,
          let inviteCode = pathComponents[safe: 1]
        else { return nil }
        self = .invite(inviteCode)
      default:
        return nil
      }
    // put more discord links here if needed

    case "mention":
      let pathComponents = url.pathComponents.filter { $0 != "/" }
      guard let first = pathComponents.first else { return nil }
      switch first {
      case "user":
        guard pathComponents.count >= 2,
          let userId = pathComponents[safe: 1]
        else { return nil }
        self = .userMention(.init(userId))
      case "role":
        guard pathComponents.count >= 2,
          let roleId = pathComponents[safe: 1]
        else { return nil }
        self = .roleMention(.init(roleId))
      case "channel":
        guard pathComponents.count >= 2,
          let channelId = pathComponents[safe: 1]
        else { return nil }
        self = .channelMention(.init(channelId))
      case "everyone":
        self = .everyoneMention
      case "here":
        self = .hereMention
      default:
        return nil
      }

    default:
      return nil
    }
  }
}
