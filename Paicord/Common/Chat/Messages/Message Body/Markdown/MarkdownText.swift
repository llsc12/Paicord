//
//  MarkdownText.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftEmojiIndex
import SwiftUI
import SwiftUIX
import Textual

struct MarkdownText: View {
  let content: String
  let channelStore: ChannelStore?
  var foregroundColorOverride: Color?

  var allowsJumboEmoji: Bool

  @Environment(\.theme) var theme
  @State private var revealedSpoilers: Set<String> = []
  @State private var userPopover: PartialUser?
  @State private var emojiPopover: DiscordModels.Emoji?
  @State private var unicodeEmojiPopover: String?

  @ViewStorage private var documentFrame: CGRect = .zero
  @State private var tapLocalPoint: (point: CGPoint, size: CGSize) = (.zero, .zero)

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

  private var isJumboEmoji: Bool {
    allowsJumboEmoji && DiscordMarkdown.isEmojiOnlyContent(content)
  }

  private var handleInteractions: Bool = true

  func handlesInteractions(_ bool: Bool = true) -> Self {
    var copy = self
    copy.handleInteractions = bool
    return copy
  }

  var body: some View {
    StructuredText(
      content,
      parser: .discordMarkdown(syntaxExtensions: syntaxExtensions),
      revision: revision
    )
    .textual.inlineStyle(inlineStyle)
    .textual.structuredTextStyle(.discord)
    .textual.highlighterTheme(highlighterTheme)
    .textual.codeBlockStyle(PaicordCodeBlockStyle())
    .textual.emojiProperties(isJumboEmoji ? .discordJumbo : .discordStandard)
    .textual.roundedBackgroundStyle(RoundedBackgroundStyle(cornerRadius: 4, padding: 1))
    .textual.textSelection(.enabled)
    .textual.overflowMode(.wrap)
    .foregroundStyle(foregroundColorOverride ?? theme.markdown.text)
    .background(
      GeometryReader { geometry in
        documentFrame = geometry.frame(in: .global)
        return Color.clear
      }
    )
    .popover(
      isPresented: isPopoverPresented,
      attachmentAnchor: .rect(.rect(CGRect(origin: tapLocalPoint.point, size: tapLocalPoint.size))),
      arrowEdge: popoverEdgePreference
    ) {
      if let userPopover {
        ProfilePopoutView(
          guild: channelStore?.guildStore,
          member: channelStore?.guildStore?.member(userPopover.id),
          user: userPopover
        )
      } else if let emojiPopover {
        EmojiDetailsView(emoji: emojiPopover)
      } else if let unicodeEmojiPopover {
        UnicodeEmojiDetailsView(character: unicodeEmojiPopover)
      }
    }
    .textual.onEntityTap { url, bounds in
      if !handleInteractions { return }
      handleTap(url: url, bounds: bounds)
    }
    .environment(
      \.openURL,
      OpenURLAction { url in
        if !handleInteractions { return .handled }
        return url.scheme == "textual-discord" || PaicordChatLink(url: url) != nil
          ? .handled : .systemAction
      }
    )
  }

  private var isPopoverPresented: Binding<Bool> {
    Binding(
      get: { userPopover != nil || emojiPopover != nil || unicodeEmojiPopover != nil },
      set: {
        if !$0 {
          userPopover = nil
          emojiPopover = nil
          unicodeEmojiPopover = nil
        }
      }
    )
  }

  private var popoverEdgePreference: Edge? {
    if userPopover != nil {
      return nil
    } else if emojiPopover != nil || unicodeEmojiPopover != nil {
      return .trailing
    } else {
      return nil
    }
  }

  // MARK: - Supplementary Views

  struct EmojiDetailsView: View {
    var emoji: DiscordModels.Emoji
    @Environment(\.gateway) var gw
    @Environment(\.appState) var appState

    @State private var source: SourceState = .loading

    private enum SourceState {
      case loading
      case ownGuild(id: GuildSnowflake, name: String, icon: String?)
      case currentGuild(id: GuildSnowflake, name: String, icon: String?)
      case foreignGuild(EmojiSource.GuildSource)
      case application(EmojiSource.ApplicationSource)
      case unavailable
    }

    var body: some View {
      if let id = emoji.id, let name = emoji.name {
        let animated = emoji.animated ?? false
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            let url = URL(
              string: CDNEndpoint.customEmoji(emojiId: id).url
                + ".\(animated ? "gif" : "png")?size=96&animated=\(animated)")
            WebImage(url: url)
              .resizable()
              .scaledToFit()
              .frame(width: 44, height: 44)

            VStack(alignment: .leading) {
              Text(":\(name):")
                .bold()
              sourceDetail
                .fixedSize(horizontal: false, vertical: true)
            }
          }
          .padding(12)

          sourceRow
        }
        #if os(macOS)
        .frame(minWidth: 290, maxWidth: 290, alignment: .leading)
        #else
        .presentationDetents([.height(150)])
        #endif
        .task(id: id) {
          await loadSource(id: id)
        }
      }
    }

    @ViewBuilder
    private var sourceDetail: some View {
      switch source {
      case .loading:
        ProgressView()
      case .ownGuild:
        Text("This emoji is from one of your servers. Type its name in the chat bar to use it.")
          .font(.caption)
          .foregroundStyle(.secondary)
      case .currentGuild:
        Text("This emoji is from this server. You can use it everywhere.")
          .font(.caption)
          .foregroundStyle(.secondary)
      case .foreignGuild:
        Text("Want to use this emoji everywhere? Join the server.")
          .font(.caption)
          .foregroundStyle(.secondary)
      case .application(let app):
        Text("This emoji is from the \(app.name) app")
          .font(.caption)
          .foregroundStyle(.secondary)
      case .unavailable:
        Text("This emoji is from a server that is either invite-only or unavailable.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }

    @ViewBuilder
    private var sourceRow: some View {
      switch source {
      case .loading, .application(_), .unavailable:
        EmptyView()
      case .currentGuild(let id, let name, let icon), .ownGuild(let id, let name, let icon):
        let guild = gw.user.guilds[id]
        guildRow(
          name: name, icon: icon, guildId: id,
          hasDiscovery: guild?.features.contains(.discoverable) ?? false)
      case .foreignGuild(let guild):
        guildRow(
          name: guild.name, icon: guild.icon, guildId: guild.id,
          hasDiscovery: guild.features.contains(.discoverable))
      }
    }

    @ViewBuilder
    private func guildRow(name: String, icon: String?, guildId: GuildSnowflake?, hasDiscovery: Bool)
      -> some View
    {
      VStack(alignment: .leading) {
        Text("This emoji is from")
          .font(.callout.bold())
          .foregroundStyle(.secondary)

        HStack(spacing: 4) {
          if let icon, let guildId {
            let url = URL(
              string: CDNEndpoint.guildIcon(guildId: guildId, icon: icon).url
                + ".webp?size=128&animated=true")
            WebImage(url: url)
              .resizable()
              .scaledToFit()
              .frame(width: 36, height: 36)
              .clipShape(.rounded)
              .padding(.trailing, 6)
          }
          VStack(alignment: .leading) {
            Text(name)
              .font(.headline.bold())
            HStack {
              if hasDiscovery {
                Text("Discoverable")
              } else {
                Text("Invite-Only Server")
              }
            }
            .font(.caption)
          }
        }
      }
      .padding(12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(.black.tertiary)
    }

    private func loadSource(id: EmojiSnowflake) async {
      // check locally first
      if let guild = GatewayStore.shared.user.guilds.values.first(where: {
        $0.emojis.contains(where: { $0.id == id })
      }) {
        if appState.selectedGuild == guild.id {
          source = .currentGuild(id: guild.id, name: guild.name, icon: guild.icon)
        } else {
          source = .ownGuild(id: guild.id, name: guild.name, icon: guild.icon)
        }
        return
      }

      // load source
      do {
        let req = try await gw.client.getEmojiSource(emojiID: id)
        if let error = req.asError() { throw error }
        let data = try req.decode()
        switch data.type {
        case .guild:
          if let guild = data.guild {
            source = .foreignGuild(guild)
          } else {
            source = .unavailable
          }
        case .application:
          if let application = data.application {
            source = .application(application)
          } else {
            source = .unavailable
          }
        default:
          source = .unavailable
        }
      } catch {
        source = .unavailable
      }
    }
  }

  struct UnicodeEmojiDetailsView: View {
    var character: String
    @State private var fallbackEmoji: SwiftEmojiIndex.Emoji?
    @State private var loadedFallback = false

    private var discordName: String? {
      DiscordEmojiNameIndex.names(for: character)?.first
    }

    var body: some View {
      HStack {
        Text(character)
          .font(.system(size: 44))

        VStack(alignment: .leading) {
          if let discordName {
            Text(":\(discordName):")
              .bold()
          } else if let fallbackEmoji {
            Text(":\(fallbackEmoji.shortcodes.first ?? character):")
              .bold()
            Text(fallbackEmoji.name.capitalized)
              .font(.caption)
              .foregroundStyle(.secondary)
          } else if loadedFallback {
            Text(character)
              .bold()
          } else {
            ProgressView()
          }

          Text("A default emoji. You can use this emoji everywhere on Discord.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .padding(12)
      .frame(minWidth: 220, maxWidth: 290, alignment: .leading)
      .task(id: character) {
        guard discordName == nil else { return }
        fallbackEmoji = await SwiftEmojiIndex.Emoji.lookup(character)
        loadedFallback = true
      }
    }
  }

  // MARK: - Styling

  private var inlineStyle: InlineStyle {
    InlineStyle()
      .code(
        .monospaced, .fontScale(0.94),
        .backgroundColor(DynamicColor(theme.markdown.codeSpanBackground))
      )
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
      memberCount: guildStore?.memberCount,
      roleCount: guildStore?.roleCount,
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
      .discordEmoji(jumbo: isJumboEmoji) { id, animated, jumbo in
        // apparently using gif files is unreliable now. discord cdn amazing fr
        let base = CDNEndpoint.customEmoji(emojiId: EmojiSnowflake(id)).url
        let size = jumbo ? 96 : 44
        return URL(string: base + ".webp?size=\(size)&animated=\(animated)")!
      }
    )
    extensions.append(.discordUnicodeEmoji)
    extensions.append(.discordTimestamps)
    extensions.append(.discordNoEmbedLinks)
    extensions.append(.discordSpoilers(revealed: revealedSpoilers))
    extensions.append(.discordSubtext)
    return extensions
  }

  // MARK: - Link handling

  private func handleTap(url: URL, bounds: CGRect) {
    if url.scheme == "textual-discord" {
      if url.host == "spoiler",
        let encoded = url.pathComponents.last,
        let text = encoded.removingPercentEncoding,
        let indexString = URLComponents(url: url, resolvingAgainstBaseURL: false)?
          .queryItems?.first(where: { $0.name == "index" })?.value,
        let index = Int(indexString)
      {
        revealedSpoilers.insert(
          AttributedStringMarkdownParser.SyntaxExtension.spoilerRevealKey(index: index, text: text)
        )
      } else if url.host == "emoji",
        url.pathComponents.last == "unicode",
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
        let character = query.first(where: { $0.name == "char" })?.value
      {
        ImpactGenerator.impact(style: .light)
        unicodeEmojiPopover = character
        tapLocalPoint = (
          CGPoint(
            x: bounds.minX - documentFrame.minX,
            y: bounds.minY - documentFrame.minY
          ),
          CGSize(
            width: bounds.width,
            height: bounds.height
          )
        )
      } else if url.host == "emoji",
        let encoded = url.pathComponents.last,
        let text = encoded.removingPercentEncoding,
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
        let name = query.first(where: { $0.name == "name" })?.value,
        let animatedString = query.first(where: { $0.name == "animated" })?.value,
        let animated: Bool = Bool(animatedString)
      {
        let emoji = Emoji(id: .init(text), name: name, animated: animated)
        ImpactGenerator.impact(style: .light)
        emojiPopover = emoji
        tapLocalPoint = (
          CGPoint(
            x: bounds.minX - documentFrame.minX,
            y: bounds.minY - documentFrame.minY
          ),
          CGSize(
            width: bounds.width,
            height: bounds.height
          )
        )
      }
    }

    guard let cmd = PaicordChatLink(url: url) else {
      return
    }
    let gw = GatewayStore.shared

    switch cmd {
    case .userMention(let userID):
      if let user = gw.user.users[userID] {
        ImpactGenerator.impact(style: .light)
        userPopover = user
        tapLocalPoint = (
          CGPoint(
            x: bounds.minX - documentFrame.minX,
            y: bounds.minY - documentFrame.minY
          ),
          CGSize(
            width: bounds.width,
            height: bounds.height
          )
        )
      }
    default:
      print("[MarkdownText] Unhandled special link: \(cmd)")
    }
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
      copyText: String,
      foreground: Color,
      background: Color,
      base: AttributeContainer
    ) -> AttributedString {
      var attributes = base
      attributes.link = URL(string: link)
      attributes.textual.preStyledLink = true
      attributes.textual.copyText = copyText
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
        name = guildStore?.member(userID)?.nick ?? user.global_name ?? user.username ?? id
      } else {
        name = id
      }
      return mention(
        text: "@\(name)",
        link: "paicord://mention/user/\(id)",
        copyText: "<@\(id)>",
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
        copyText: "<#\(id)>",
        foreground: defaultForeground,
        background: defaultBackground,
        base: base
      )
    }

    let roleMention = Self(regex: /<@&(\d+)>/, tokenType: "paicordRoleMention") { id, base in
      let roleID = RoleSnowflake(id)
      guard let role = guildStore?.role(roleID) else {
        return mention(
          text: "@\(id)",
          link: "paicord://mention/role/\(id)",
          copyText: "<@&\(id)>",
          foreground: defaultForeground,
          background: defaultBackground,
          base: base
        )
      }
      let color = role.color.asColor()
      return mention(
        text: "@\(role.name)",
        link: "paicord://mention/role/\(id)",
        copyText: "<@&\(id)>",
        foreground: color ?? defaultForeground,
        background: color.map { $0.opacity(0.08) } ?? defaultBackground,
        base: base
      )
    }

    let everyoneMention = Self(regex: /@(everyone)/, tokenType: "paicordEveryoneMention") {
      _, base in
      mention(
        text: "@everyone",
        link: "paicord://mention/everyone",
        copyText: "@everyone",
        foreground: defaultForeground,
        background: defaultBackground,
        base: base
      )
    }

    let hereMention = Self(regex: /@(here)/, tokenType: "paicordHereMention") { _, base in
      mention(
        text: "@here",
        link: "paicord://mention/here",
        copyText: "@here",
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
