//
//  MarkdownText.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//

import DiscordMarkdownParser
import HighlightSwift
import Loupe
import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

struct MarkdownText: View, Equatable {
  let content: String
  let meta: DiscordChannel.PartialMessage?
  let channelStore: ChannelStore?
  let baseAttributesOverrides: [NSAttributedString.Key: Any]

  @Environment(\.dynamicTypeSize) var dynamicType
  @ViewStorage var dynamicTypeSizeStorage: DynamicTypeSize = .xSmall
  @Environment(\.theme) var theme
  @Environment(\.enableCrossBlockTextSelection)
  var enableCrossBlockTextSelection

  @State private var renderer: MarkdownRendererVM
  @State private var userPopover: PartialUser?

  // Track the last render signature to avoid redundant async work
  @ViewStorage private var lastRenderSignature: RenderSignature?

  init(
    content: String,
    meta: DiscordChannel.PartialMessage? = nil,
    channelStore: ChannelStore? = nil,
    baseAttributesOverrides: [NSAttributedString.Key: Any] = [:]
  ) {
    self.content = content
    self.meta = meta
    self.channelStore = channelStore
    self.baseAttributesOverrides = baseAttributesOverrides
    _renderer = State(
      initialValue: MarkdownRendererVM(
        baseAttributesOverrides: baseAttributesOverrides
      )
    )
  }

  func baseAttributes(_ attributes: [NSAttributedString.Key: Any])
    -> MarkdownText
  {
    MarkdownText(
      content: content,
      channelStore: channelStore,
      baseAttributesOverrides: attributes
    )
  }

  static func == (lhs: MarkdownText, rhs: MarkdownText) -> Bool {
    lhs.content == rhs.content
      && lhs.channelStore?.channelId == rhs.channelStore?.channelId
      && lhs.baseAttributesOverrides.count == rhs.baseAttributesOverrides.count
      && lhs.dynamicTypeSizeStorage == rhs.dynamicTypeSizeStorage
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if renderer.blocks.isEmpty {
        Text(markdown: content)  // Apple’s markdown fallback
          .opacity(0.6)
      } else {
        #if os(macOS)
          if enableCrossBlockTextSelection {
            SelectableMarkdownText(
              blocks: renderer.blocks.compactMap { block in
                guard let attr = block.attributedContent else { return nil }
                return SelectableMarkdownText.BlockInfo(
                  id: String(block.id),
                  attributedString: attr
                )
              }
            )
          } else {
            ForEach(renderer.blocks) { block in
              BlockView(block: block)
                .equatable()
                .debugRender()
                .debugCompute()
            }
          }
        #else
          ForEach(renderer.blocks) { block in
            BlockView(block: block)
              .equatable()
              .debugRender()
              .debugCompute()
          }
        #endif
      }
    }
    .environment(
      \.openURL,
      OpenURLAction { url in
        return handleURL(url)
      }
    )
    .popover(item: $userPopover) { user in
      ProfilePopoutView(
        guild: channelStore?.guildStore,
        member: channelStore?.guildStore?.members[user.id],
        user: user
      )
    }
    .equatable(by: renderSignature)
    .task(
      id: dynamicType,
      {
        dynamicTypeSizeStorage = dynamicType
        await renderIfNeeded()
      }
    )
    .task(id: renderSignature, renderIfNeeded)
  }

  private var renderSignature: RenderSignature {
    let gw = GatewayStore.shared
    //    print(
    //      content,
    //      renderer.blocks,
    //      gw.user.users.count,
    //      channelStore?.guildStore?.members.count as Any,
    //      channelStore?.guildStore?.roles.count as Any,
    //      channelStore?.guildStore?.channels.count as Any,
    //      dynamicType,
    //      theme.id
    //    )
    let sig: RenderSignature
    if let meta,
      meta.mentions?.isEmpty == false || meta.mention_roles?.isEmpty == false
    {
      sig = RenderSignature(
        content: content,
        blocks: renderer.blocks,
        userCount: gw.user.users.count,
        memberCount: channelStore?.guildStore?.members.count,
        roleCount: channelStore?.guildStore?.roles.count,
        channelCount: channelStore?.guildStore?.channels.count,
        dynamicType: dynamicTypeSizeStorage,
        themeID: theme.id
      )
    } else {
      sig = RenderSignature(
        content: content,
        blocks: renderer.blocks,
        userCount: nil,
        memberCount: nil,
        roleCount: nil,
        channelCount: nil,
        dynamicType: dynamicTypeSizeStorage,
        themeID: theme.id
      )
    }
    //    print(sig, "\n")
    return sig
  }

  @Sendable
  private func renderIfNeeded() async {
    let sig = renderSignature
    let gw = GatewayStore.shared
    guard lastRenderSignature != sig else { return }
    lastRenderSignature = sig
    renderer.passRefs(gw: gw, channelStore: channelStore)
    await renderer.update(
      content: content,
      signature: sig
    )
  }

  func handleURL(_ url: URL) -> OpenURLAction.Result {
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

  private struct BlockView: View, Equatable {
    var block: BlockElement

    static func == (lhs: BlockView, rhs: BlockView) -> Bool {
      lhs.block == rhs.block
    }

    var body: some View {
      switch block.nodeType {
      case .paragraph, .heading, .footnote, .thematicBreak:
        if let attr = block.attributedContent {
          AttributedText(attributedString: attr)
            .equatable(by: attr)
        } else {
          Text("")
        }

      case .codeBlock:
        if let code = block.codeContent {
          Codeblock(code: code, language: block.language)
        }

      case .blockQuote:
        VStack(alignment: .leading, spacing: 4) {
          if let children = block.children {
            ForEach(children) { nested in
              BlockView(block: nested)
                .equatable()
            }
          }
        }
        .padding(.leading, 12)
        .overlay(
          Rectangle()
            .frame(width: 3)
            .foregroundStyle(.quaternary)
            .clipShape(.capsule),
          alignment: .leading
        )

      case .list:
        if let children = block.children {
          VStack(alignment: .leading, spacing: 4) {
            ForEach(children) { child in
              HStack(alignment: .top, spacing: 8) {
                Text("•").font(.body)
                BlockView(block: child)
                  .equatable()
              }
            }
          }
        }

      case .listItem:
        if let attr = block.attributedContent {
          let converted = AttributedString(attr)
          Text(converted)
        } else if let children = block.children {
          VStack(alignment: .leading, spacing: 4) {
            ForEach(children) { nested in
              BlockView(block: nested)
                .equatable()
            }
          }
        } else {
          Text("")
        }

      default:
        if let attr = block.attributedContent {
          let converted = AttributedString(attr)
          Text(converted)
        } else {
          Text("Unsupported block: \(block.nodeType.rawValue)")
            .opacity(0.6)
        }
      }
    }
  }

  struct Codeblock: View {
    var code: String
    var language: String?
    @State private var isHovered: Bool = false
    @Environment(\.theme) var theme
    var body: some View {
      HStack {
        Group {
          if let language {
            CodeText(code)
              .highlightMode(.languageAlias(language))
              .codeTextColors(
                theme.markdown.codeBlockSyntaxTheme.highlightTheme
              )
              .font(.footnote.monospaced())
          } else {
            Text(code)
              .font(.footnote.monospaced())
          }
        }
        .environment(\.font, nil)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(theme.markdown.codeBlockBackground)
        .clipShape(.rounded)
        .overlay(
          RoundedRectangle(cornerSize: .init(10), style: .continuous)
            .stroke(theme.markdown.codeBlockBorder, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
          if isHovered {
            Button {
              #if os(macOS)
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(code, forType: .string)
              #else
                UIPasteboard.general.string = code
              #endif
            } label: {
              Image(systemName: "doc.on.doc")
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(6)
          }
        }
        .onHover { self.isHovered = $0 }

        Spacer()
          .containerRelativeFrame(.horizontal, alignment: .leading) {
            length,
            _ in
            #if os(iOS)
              let value = min(length * 0.2, 50) - 200
              return max(0, value)
            #else
              min(length * 0.2, 50)
            #endif
          }
      }
    }
  }
}

// MARK: - Models

private struct BlockElement: Identifiable, Equatable, Hashable {
  let id: Int
  let nodeType: ASTNodeType
  let attributedContent: NSAttributedString?
  let isOrdered: Bool?
  let startingNumber: Int?
  let codeContent: String?
  let language: String?
  let level: Int?
  let children: [BlockElement]?
  let sourceLocation: SourceLocation?
}

// Stable render signature used to avoid redundant parsing
private struct RenderSignature: Equatable {
  init(
    content: String,
    blocks: [BlockElement],
    userCount: Int?,
    memberCount: Int?,
    roleCount: Int?,
    channelCount: Int?,
    dynamicType: DynamicTypeSize,
    themeID: String?
  ) {
    var h = Hasher()
    h.combine(content)
    h.combine(blocks)
    if let userCount { h.combine(userCount) }
    if let memberCount { h.combine(memberCount) }
    if let roleCount { h.combine(roleCount) }
    if let channelCount { h.combine(channelCount) }
    h.combine(dynamicType)
    h.combine(themeID)
    self.hash = h.finalize()
  }

  let hash: Int
}

// MARK: - Renderer

@Observable
class MarkdownRendererVM {
  static var parser: DiscordMarkdownParser = { .init() }()

  // Shared cache (renderer instances)
  fileprivate static let cache: NSCache<NSString, CachedRender> = {
    let c = NSCache<NSString, CachedRender>()
    c.countLimit = 512
    return c
  }()
  fileprivate class CachedRender: NSObject {
    let blocks: [BlockElement]
    let emojiSize: EmojiSize

    init(blocks: [BlockElement], emojiSize: EmojiSize) {
      self.blocks = blocks
      self.emojiSize = emojiSize
    }
  }

  let theme = Theming.shared.currentTheme
  fileprivate var blocks: [BlockElement] = []
  var baseAttributesOverrides: [NSAttributedString.Key: Any] = [:]

  init(
    baseAttributesOverrides: [NSAttributedString.Key: Any] = [:]
  ) {
    self.baseAttributesOverrides = baseAttributesOverrides
  }

  var gw: GatewayStore!
  var guildStore: GuildStore? { channelStore?.guildStore }
  var channelStore: ChannelStore?

  func passRefs(
    gw: GatewayStore,
    channelStore: ChannelStore?
  ) {
    self.gw = gw
    self.channelStore = channelStore
  }

  var emojiSize: EmojiSize = .normal

  fileprivate func update(content: String, signature: RenderSignature) async {
    // If a cached renderer exists for this signature, adopt its blocks immediately.
    let cacheKey = Self.makeCacheKey(hash: signature.hash)

    if let cached = Self.cache.object(forKey: cacheKey as NSString) {
      await MainActor.run {
        self.blocks = cached.blocks
        self.emojiSize = cached.emojiSize
      }
      return
    }

    // Parse and then cache
    do {
      let blocks = try await Task.detached(priority: .low) {
        let ast = try await Self.parser.parseToAST(content)
        return self.buildBlocks(from: ast)
      }.value
      await MainActor.run {
        self.blocks = blocks
      }
      // store self (with current blocks) in cache
      Self.cache.setObject(
        CachedRender(blocks: self.blocks, emojiSize: self.emojiSize),
        forKey: cacheKey as NSString
      )

      // check if the ast only contains emojis, either unicode or custom.
      #warning("large emojis support not implemented yet")
    } catch {
      print("Markdown parse failed: \(error)")
    }
  }

  static func makeCacheKey(
    hash: Int
  ) -> String {
    String(hash)
  }

  private enum BaseInlineStyle { case body, footnote }

  enum EmojiSize: Int {
    case normal = 15
    case large = 44
    var size: CGFloat {
      switch self {
      case .normal: return 96
      case .large: return 192
      }
    }
  }

  // Walk top-level AST nodes and convert to BlockElement models.
  fileprivate func buildBlocks(from document: AST.DocumentNode)
    -> [BlockElement]
  {
    var result: [BlockElement] = []
    for child in document.children {
      if let block = makeBlock(from: child) {
        result.append(block)
      }
    }
    return result
  }

  // Create a BlockElement from an ASTNode if it is a block-level node.
  private func makeBlock(from node: ASTNode) -> BlockElement? {
    let baseIDSeed = sourceID(for: node)
    switch node.nodeType {
    case .paragraph:
      let attributed = renderInlinesToNSAttributedString(
        nodes: node.children,
        baseStyle: .body
      )
      return BlockElement(
        id: makeID(base: baseIDSeed, content: attributed.string),
        nodeType: .paragraph,
        attributedContent: attributed,
        isOrdered: nil,
        startingNumber: nil,
        codeContent: nil,
        language: nil,
        level: nil,
        children: nil,
        sourceLocation: node.sourceLocation
      )

    case .heading:
      if let heading = node as? AST.HeadingNode {
        let attributed = renderInlinesToNSAttributedString(
          nodes: heading.children,
          headingLevel: heading.level,
          baseStyle: .body
        )
        return BlockElement(
          id: makeID(base: baseIDSeed, content: attributed.string),
          nodeType: .heading,
          attributedContent: attributed,
          isOrdered: nil,
          startingNumber: nil,
          codeContent: nil,
          language: nil,
          level: heading.level,
          children: nil,
          sourceLocation: node.sourceLocation
        )
      }
      return nil

    case .footnote:
      let attributed = renderInlinesToNSAttributedString(
        nodes: node.children,
        baseStyle: .footnote
      )
      return BlockElement(
        id: makeID(base: baseIDSeed, content: attributed.string),
        nodeType: .footnote,
        attributedContent: attributed,
        isOrdered: nil,
        startingNumber: nil,
        codeContent: nil,
        language: nil,
        level: nil,
        children: nil,
        sourceLocation: node.sourceLocation
      )

    case .codeBlock:
      if let code = node as? AST.CodeBlockNode {
        return BlockElement(
          id: makeID(base: baseIDSeed, content: code.content),
          nodeType: .codeBlock,
          attributedContent: nil,
          isOrdered: nil,
          startingNumber: nil,
          codeContent: code.content,
          language: code.language,
          level: nil,
          children: nil,
          sourceLocation: node.sourceLocation
        )
      }
      return nil

    case .blockQuote:
      var nested: [BlockElement] = []
      for child in node.children {
        if let b = makeBlock(from: child) {
          nested.append(b)
        }
      }
      return BlockElement(
        id: makeID(base: baseIDSeed, content: nested.map(\.id).description),
        nodeType: .blockQuote,
        attributedContent: nil,
        isOrdered: nil,
        startingNumber: nil,
        codeContent: nil,
        language: nil,
        level: nil,
        children: nested,
        sourceLocation: node.sourceLocation
      )

    case .list:
      if let list = node as? AST.ListNode {
        var items: [BlockElement] = []
        for item in list.items {
          if let listItem = item as? AST.ListItemNode {
            var listItemChildren: [BlockElement] = []
            for c in listItem.children {
              if let blockChild = makeBlock(from: c) {
                listItemChildren.append(blockChild)
              }
            }
            let itemBlock = BlockElement(
              id: makeID(
                base: sourceID(for: listItem),
                content: listItemChildren.map(\.id).description
              ),
              nodeType: .listItem,
              attributedContent: nil,
              isOrdered: nil,
              startingNumber: nil,
              codeContent: nil,
              language: nil,
              level: nil,
              children: listItemChildren,
              sourceLocation: listItem.sourceLocation
            )
            items.append(itemBlock)
          } else {
            let attr = renderInlinesToNSAttributedString(
              nodes: item.children,
              baseStyle: .body
            )
            let itemBlock = BlockElement(
              id: makeID(base: sourceID(for: item), content: attr.string),
              nodeType: .listItem,
              attributedContent: attr,
              isOrdered: nil,
              startingNumber: nil,
              codeContent: nil,
              language: nil,
              level: nil,
              children: nil,
              sourceLocation: item.sourceLocation
            )
            items.append(itemBlock)
          }
        }
        return BlockElement(
          id: makeID(base: baseIDSeed, content: items.map(\.id).description),
          nodeType: .list,
          attributedContent: nil,
          isOrdered: nil,
          startingNumber: nil,
          codeContent: nil,
          language: nil,
          level: nil,
          children: items,
          sourceLocation: node.sourceLocation
        )
      }
      return nil

    case .thematicBreak:
      let attr = NSAttributedString(string: "—")
      return BlockElement(
        id: makeID(base: baseIDSeed, content: attr.string),
        nodeType: .thematicBreak,
        attributedContent: attr,
        isOrdered: nil,
        startingNumber: nil,
        codeContent: nil,
        language: nil,
        level: nil,
        children: nil,
        sourceLocation: node.sourceLocation
      )

    default:
      // For other block-like nodes, attempt to render their inline children.
      let attr = renderInlinesToNSAttributedString(
        nodes: node.children,
        baseStyle: .body
      )
      return BlockElement(
        id: makeID(base: baseIDSeed, content: attr.string),
        nodeType: node.nodeType,
        attributedContent: attr,
        isOrdered: nil,
        startingNumber: nil,
        codeContent: nil,
        language: nil,
        level: nil,
        children: nil,
        sourceLocation: node.sourceLocation
      )
    }
  }

  // for inline content
  private func makeID(base: Int, content: String?) -> Int {
    var h = Hasher()
    h.combine(base)
    if let content { h.combine(content) }
    return h.finalize()
  }

  private func sourceID(for node: ASTNode) -> Int {
    var h = Hasher()
    h.combine(node.nodeType)
    h.combine(node.sourceLocation)
    return h.finalize()
  }

  private func renderInlinesToNSAttributedString(
    nodes: [ASTNode],
    headingLevel: Int? = nil,
    baseStyle: BaseInlineStyle = .body
  ) -> NSAttributedString {
    let result = NSMutableAttributedString()
    let baseFont: Any
    let baseColor: AppKitOrUIKitColor
    switch baseStyle {
    case .body:
      baseFont = FontHelpers.preferredBodyFont()
      baseColor = AppKitOrUIKitColor(theme.markdown.text)
    case .footnote:
      baseFont = FontHelpers.preferredFootnoteFont()
      baseColor = AppKitOrUIKitColor(theme.markdown.secondaryText)
    }
    let baseAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: baseColor,
      .font: baseFont,
    ]
    for node in nodes {
      append(node: node, to: result, baseAttributes: baseAttributes)
    }
    if let level = headingLevel, result.length > 0 {
      FontHelpers.applyHeadingLevel(level, to: result)
    }
    return result
  }

  private func append(
    node: ASTNode,
    to container: NSMutableAttributedString,
    baseAttributes: [NSAttributedString.Key: Any]
  ) {
    switch node.nodeType {
    case .text:
      if let t = node as? AST.TextNode {
        let s = NSAttributedString(
          string: t.content,
          attributes: baseAttributes
        )
        container.append(s)
      }

    case .italic:
      let inner = NSMutableAttributedString()
      for child in node.children {
        append(
          node: child,
          to: inner,
          baseAttributes: baseAttributes
        )
      }
      FontHelpers.applyTrait(.italic, to: inner)
      container.append(inner)

    case .bold:
      let inner = NSMutableAttributedString()
      for child in node.children {
        append(
          node: child,
          to: inner,
          baseAttributes: baseAttributes
        )
      }
      FontHelpers.applyTrait(.bold, to: inner)
      container.append(inner)

    case .underline:
      let inner = NSMutableAttributedString()
      for child in node.children {
        append(
          node: child,
          to: inner,
          baseAttributes: baseAttributes
        )
      }
      var newAttrs = baseAttributes
      newAttrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
      inner.addAttributes(
        newAttrs,
        range: NSRange(location: 0, length: inner.length)
      )
      container.append(inner)

    case .strikethrough:
      let inner = NSMutableAttributedString()
      for child in node.children {
        append(
          node: child,
          to: inner,
          baseAttributes: baseAttributes
        )
      }
      var newAttrs = baseAttributes
      newAttrs[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
      inner.addAttributes(
        newAttrs,
        range: NSRange(location: 0, length: inner.length)
      )
      container.append(inner)

    case .codeSpan:
      if let code = node as? AST.CodeSpanNode {
        let attrs: [NSAttributedString.Key: Any] = [
          .font: FontHelpers.preferredMonospaceFont(),
          .backgroundColor: AppKitOrUIKitColor(
            theme.markdown.codeSpanBackground
          ),
          .foregroundColor: AppKitOrUIKitColor(theme.markdown.text),
        ]
        let s = NSAttributedString(string: code.content, attributes: attrs)
        container.append(s)
      } else {
        // fallback: render children
        for child in node.children {
          append(
            node: child,
            to: container,
            baseAttributes: baseAttributes
          )
        }
      }

    case .link:
      if let link = node as? AST.LinkNode {
        let inner = NSMutableAttributedString()
        var newAttrs = baseAttributes
        if let url = URL(string: link.url) {
          newAttrs[.link] = url
          newAttrs[.foregroundColor] = AppKitOrUIKitColor(
            theme.common.hyperlink
          )
        }
        inner.addAttributes(
          newAttrs,
          range: NSRange(location: 0, length: inner.length)
        )
        for child in link.children {
          append(
            node: child,
            to: inner,
            baseAttributes: newAttrs
          )
        }
        container.append(inner)
      }

    case .autolink:
      if let a = node as? AST.AutolinkNode {
        var attrs = baseAttributes
        attrs[.foregroundColor] = AppKitOrUIKitColor(
          theme.common.hyperlink
        )
        attrs[.link] = URL(string: a.url)
        let s = NSAttributedString(string: a.text, attributes: attrs)
        container.append(s)
      }

    case .lineBreak:
      container.append(
        NSAttributedString(string: "\n", attributes: baseAttributes)
      )

    case .thematicBreak:
      container.append(
        NSAttributedString(string: "\n", attributes: baseAttributes)
      )

    case .spoiler:
      // As a simple fallback, render spoiler text as dimmed (could be replaced with reveal-on-tap later).
      let inner = NSMutableAttributedString()
      for child in node.children {
        append(
          node: child,
          to: inner,
          baseAttributes: baseAttributes
        )
      }
      var newAttrs = baseAttributes
      newAttrs[.foregroundColor] = AppKitOrUIKitColor(
        theme.markdown.secondaryText
      )
      inner.addAttributes(
        newAttrs,
        range: NSRange(location: 0, length: inner.length)
      )
      container.append(inner)

    case .customEmoji:
      if let ce = node as? AST.CustomEmojiNode {
        var attributes = baseAttributes
        let copyText =
          "<\(ce.isAnimated ? "a" : ""):\(ce.name):\(ce.identifier.rawValue)>"
        attributes[.rawContent] = copyText
        guard
          let url = URL(
            string: CDNEndpoint.customEmoji(emojiId: ce.identifier).url
              + (ce.isAnimated ? ".gif" : ".png") + "?size=44"
          )
        else { return }
        let s = self.makeEmojiAttachment(
          emoji: .init(url: url, size: 18),
          attributes: attributes
        )
        container.append(s)
      }

    case .userMention:
      if let m = node as? AST.UserMentionNode {
        let name: String
        if let user = gw.user.users[m.id] {
          if let member = guildStore?.members[m.id] {
            name =
              member.nick ?? user.global_name ?? user.username ?? m.id.rawValue
          } else {
            name = user.global_name ?? user.username ?? m.id.rawValue
          }
        } else {
          name = m.id.rawValue
        }

        var attrs = baseAttributes
        if let font = attrs[.font] {
          attrs[.font] = FontHelpers.makeFontBold(font)
        }
        // add clickable paicord link for user mention (use rawValue!)
        if let url = URL(string: "paicord://mention/user/\(m.id.rawValue)") {
          attrs[.link] = url
        }
        attrs[.rawContent] = "<@\(m.id.rawValue)>"
        attrs[.backgroundColor] = AppKitOrUIKitColor(
          theme.markdown.mentionBackground
        )
        attrs[.foregroundColor] = AppKitOrUIKitColor(
          theme.markdown.mentionText
        )
        attrs[.underlineStyle] = .none

        let s = NSAttributedString(string: "@\(name)", attributes: attrs)
        container.append(s)
      }

    case .roleMention:
      if let r = node as? AST.RoleMentionNode {
        if let role = guildStore?.roles[r.id] {
          var attrs = baseAttributes
          if let font = attrs[.font] {
            attrs[.font] = FontHelpers.makeFontBold(font)
          }
          attrs[.rawContent] = "<@&\(r.id.rawValue)>"
          if let url = URL(string: "paicord://mention/role/\(r.id.rawValue)") {
            attrs[.link] = url
          }

          let discordColor = role.color
          if let color = discordColor.asColor() {
            attrs[.backgroundColor] = AppKitOrUIKitColor(color.opacity(0.08))
            attrs[.foregroundColor] = AppKitOrUIKitColor(color)
          } else {
            attrs[.backgroundColor] = AppKitOrUIKitColor(
              theme.markdown.mentionBackground
            )
            attrs[.foregroundColor] = AppKitOrUIKitColor(
              theme.markdown.mentionText
            )

          }

          attrs[.underlineStyle] = .none

          let s = NSAttributedString(
            string: "@\(role.name)",
            attributes: attrs
          )
          container.append(s)
        } else {
          var attrs = baseAttributes
          if let url = URL(string: "paicord://mention/role/\(r.id.rawValue)") {
            attrs[.link] = url
          }
          let s = NSAttributedString(
            string: "<@&\(r.id.rawValue)>",
            attributes: attrs
          )
          container.append(s)
        }
      }

    case .channelMention:
      if let c = node as? AST.ChannelMentionNode {
        if let channel = guildStore?.channels[c.id] {
          var attrs = baseAttributes
          if let font = attrs[.font] {
            attrs[.font] = FontHelpers.makeFontBold(font)
          }
          attrs[.rawContent] = "<#\(c.id.rawValue)>"
          if let url = URL(string: "paicord://mention/channel/\(c.id.rawValue)")
          {
            attrs[.link] = url
          }
          attrs[.backgroundColor] = AppKitOrUIKitColor(
            theme.markdown.mentionBackground
          )
          attrs[.foregroundColor] = AppKitOrUIKitColor(
            theme.markdown.mentionText
          )
          let name = channel.name ?? c.id.rawValue
          let s = NSAttributedString(
            string: "#\(name)",
            attributes: attrs
          )
          container.append(s)
        } else {
          var attrs = baseAttributes
          if let url = URL(string: "paicord://mention/channel/\(c.id.rawValue)")
          {
            attrs[.link] = url
          }
          let s = NSAttributedString(
            string: "<#\(c.id.rawValue)>",
            attributes: attrs
          )
          container.append(s)
        }
      }

    case .everyoneMention:
      // everyone/here should be clickable and follow the same visual style
      var attrs = baseAttributes
      if let font = attrs[.font] {
        attrs[.font] = FontHelpers.makeFontBold(font)
      }
      attrs[.backgroundColor] = AppKitOrUIKitColor(
        theme.markdown.mentionBackground
      )
      attrs[.foregroundColor] = AppKitOrUIKitColor(
        theme.markdown.mentionText
      )
      if let url = URL(string: "paicord://mention/everyone") {
        attrs[.link] = url
      }
      container.append(
        NSAttributedString(string: "@everyone", attributes: attrs)
      )

    case .hereMention:
      var attrs = baseAttributes
      if let font = attrs[.font] {
        attrs[.font] = FontHelpers.makeFontBold(font)
      }
      if let url = URL(string: "paicord://mention/here") {
        attrs[.link] = url
      }
      attrs[.backgroundColor] = AppKitOrUIKitColor(
        theme.markdown.mentionBackground
      )
      attrs[.foregroundColor] = AppKitOrUIKitColor(
        theme.markdown.mentionText
      )
      container.append(
        NSAttributedString(string: "@here", attributes: attrs)
      )

    case .timestamp:
      if let t = node as? AST.TimestampNode {
        let df = DateFormatter()
        //        all date stamp formats
        //        Relative 2 months ago
        //        Short time 11:59
        //        Long time 11:59:00
        //        Short date 14/09/2025
        //        Long date 14 September 2025
        //        Long date short time 14 September 2025 at 11:59
        //        Long date with day of week short time Sunday, 14 September 2025 at 11:59
        switch t.style ?? .relative {
        case .relative:
          df.dateFormat = "Relative"  // handled specially below
        case .shortTime:
          df.dateFormat = "HH:mm"
        case .longTime:
          df.dateFormat = "HH:mm:ss"
        case .shortDate:
          df.dateFormat = "dd/MM/yyyy"
        case .longDate:
          df.dateFormat = "dd MMMM yyyy"
        case .longDateShortTime:
          df.dateFormat = "dd MMMM yyyy 'at' HH:mm"
        case .longDateWeekDayShortTime:
          df.dateFormat = "EEEE, dd MMMM yyyy 'at' HH:mm"
        }

        // handle relative specially bc RelativeDateTimeFormatter does this
        let timestampString: String
        if t.style == .relative {
          let relativeFormatter = RelativeDateTimeFormatter()
          relativeFormatter.unitsStyle = .full
          timestampString = relativeFormatter.localizedString(
            for: t.date,
            relativeTo: Date.now
          )
        } else {
          timestampString = df.string(from: t.date)
        }

        var attrs = baseAttributes
        attrs[.backgroundColor] = AppKitOrUIKitColor(
          theme.markdown.codeSpanBackground
        )

        let s = NSAttributedString(
          string: timestampString,
          attributes: attrs
        )
        container.append(s)
      }
    default:
      for child in node.children {
        append(
          node: child,
          to: container,
          baseAttributes: baseAttributes
        )
      }
    }
  }
}

// MARK: - Helpers

private enum FontHelpers {
  // Preferred body font for platform (Dynamic Type on iOS)
  static func preferredBodyFont() -> Any {
    #if os(macOS)
      return NSFont.systemFont(ofSize: NSFont.systemFontSize)
    #else
      let pointSize = UIFontMetrics(forTextStyle: .caption1)
        .scaledValue(for: 15)
      let font = UIFont.systemFont(ofSize: pointSize)
      return font
    #endif
  }

  // Monospace font that respects dynamic type on iOS
  static func preferredMonospaceFont() -> Any {
    #if os(macOS)
      return NSFont.monospacedSystemFont(
        ofSize: NSFont.systemFontSize,
        weight: .regular
      )
    #else
      let pointSize = UIFontMetrics(forTextStyle: .caption1)
        .scaledValue(for: 15)
      let mono = UIFont.monospacedSystemFont(
        ofSize: pointSize,
        weight: .regular
      )
      return mono
    #endif
  }

  static func preferredFootnoteFont() -> Any {
    #if os(macOS)
      return NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
    #else
      let pointSize = UIFontMetrics(forTextStyle: .footnote)
        .scaledValue(for: 12)
      let font = UIFont.systemFont(ofSize: pointSize)
      return font
    #endif
  }

  enum Trait { case italic, bold }

  // Apply a font trait in-place to an attributed string, preserving existing traits and sizes.
  static func applyTrait(_ trait: Trait, to string: NSMutableAttributedString) {
    let full = NSRange(location: 0, length: string.length)
    string.enumerateAttribute(.font, in: full, options: []) { value, range, _ in
      #if os(macOS)
        let current: NSFont =
          (value as? NSFont) ?? (preferredBodyFont() as! NSFont)
        let updated = withTrait(trait, of: current)
        string.addAttribute(.font, value: updated, range: range)
      #else
        let current: UIFont =
          (value as? UIFont) ?? (preferredBodyFont() as! UIFont)
        let updated = withTrait(trait, of: current)
        string.addAttribute(.font, value: updated, range: range)
      #endif
    }
  }

  // Scale fonts for a heading level while preserving italic/bold traits in runs.
  static func applyHeadingLevel(
    _ level: Int,
    to string: NSMutableAttributedString
  ) {
    let full = NSRange(location: 0, length: string.length)
    string.enumerateAttribute(.font, in: full, options: []) { value, range, _ in
      #if os(macOS)
        let current: NSFont =
          (value as? NSFont) ?? (preferredBodyFont() as! NSFont)
        let updated = headingFont(from: current, level: level)
        string.addAttribute(.font, value: updated, range: range)
      #else
        let current: UIFont =
          (value as? UIFont) ?? (preferredBodyFont() as! UIFont)
        let updated = headingFont(from: current, level: level)
        string.addAttribute(.font, value: updated, range: range)
      #endif
    }
  }

  #if os(macOS)
    private static func withTrait(_ trait: Trait, of font: NSFont) -> NSFont {
      let manager = NSFontManager.shared
      switch trait {
      case .italic:
        return manager.convert(font, toHaveTrait: .italicFontMask)
      case .bold:
        return manager.convert(font, toHaveTrait: .boldFontMask)
      }
    }

    private static func headingFont(from font: NSFont, level: Int) -> NSFont {
      // Simple scaling factors for macOS
      let factor: CGFloat
      switch level {
      case 1: factor = 1.6
      case 2: factor = 1.4
      case 3: factor = 1.2
      default: factor = 1.1
      }
      let sized =
        NSFont(descriptor: font.fontDescriptor, size: font.pointSize * factor)
        ?? font
      // Headings are bold by default; preserve existing traits (e.g. italic) by adding bold on top
      return withTrait(.bold, of: sized)
    }
  #else
    private static func withTrait(_ trait: Trait, of font: UIFont) -> UIFont {
      var traits = font.fontDescriptor.symbolicTraits
      switch trait {
      case .italic:
        traits.insert(.traitItalic)
      case .bold:
        traits.insert(.traitBold)
      }
      guard let descriptor = font.fontDescriptor.withSymbolicTraits(traits)
      else {
        return font
      }

      let updated = UIFont(descriptor: descriptor, size: font.pointSize)

      return updated
    }

    private static func textStyle(forHeading level: Int) -> UIFont.TextStyle {
      switch level {
      case 1: return .title1
      case 2: return .title2
      case 3: return .title3
      default: return .headline
      }
    }

    private static func headingFont(from font: UIFont, level: Int) -> UIFont {
      let style = textStyle(forHeading: level)
      var base = UIFont.preferredFont(forTextStyle: style)
      // Preserve existing traits from the run and add .bold to make headings bold by default
      var traits = font.fontDescriptor.symbolicTraits
      traits.insert(.traitBold)
      if let desc = base.fontDescriptor.withSymbolicTraits(traits) {
        base = UIFont(descriptor: desc, size: base.pointSize)
      }
      return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
    }
  #endif

  static func makeFontBold(_ font: Any) -> Any {
    #if os(macOS)
      guard let f = font as? NSFont else { return font }

      if let semi = f.withWeight(weight: .semibold) {
        return semi
      }

      // Fallback: system semibold
      return NSFont.systemFont(ofSize: f.pointSize, weight: .semibold)

    #else
      guard let f = font as? UIFont else { return font }

      // If the font is already semibold or heavier, return as-is
      if let traits = f.fontDescriptor.fontAttributes[.traits]
        as? [UIFontDescriptor.TraitKey: Any],
        let weightValue = traits[.weight] as? CGFloat,
        weightValue >= UIFont.Weight.semibold.rawValue
      {
        return f
      }

      // Create a semibold descriptor
      //      let descriptor = f.fontDescriptor.addingAttributes([
      //        UIFontDescriptor.AttributeName.traits: [
      //          UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold
      //        ]
      //      ])
      return f.addingAttributes([
        .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
      ])

    //      let updated = UIFont(descriptor: descriptor, size: f.pointSize)
    //      let scaled = UIFontMetrics.default.scaledFont(for: updated)
    //
    //      // Fallback if the font didn’t actually change
    //      if scaled.fontName == f.fontName {
    //        return UIFont.systemFont(ofSize: f.pointSize, weight: .semibold)
    //      }
    //
    //      return scaled
    #endif
  }
}

#if os(macOS)
  // Source - https://stackoverflow.com/a/76143011
  // Posted by Sören Kuklau
  // Retrieved 2025-11-13, License - CC BY-SA 4.0
  extension NSFont {
    /// Rough mapping from behavior of `.systemFont(…weight:)`
    /// to `NSFontManager`'s `Int`-based weight,
    /// as of 13.4 Ventura
    func withWeight(weight: NSFont.Weight) -> NSFont? {
      let fontManager = NSFontManager.shared

      var intWeight: Int

      switch weight
      {
      case .ultraLight:
        intWeight = 0
      case .light:
        intWeight = 2  // treated as ultraLight
      case .thin:
        intWeight = 3
      case .medium:
        intWeight = 6
      case .semibold:
        intWeight = 8  // treated as bold
      case .bold:
        intWeight = 9
      case .heavy:
        intWeight = 10  // treated as bold
      case .black:
        intWeight = 15  // .systemFont does bold here; we do condensed black
      default:
        intWeight = 5  // treated as regular
      }

      return fontManager.font(
        withFamily: self.familyName ?? "",
        traits: .unboldFontMask,
        weight: intWeight,
        size: self.pointSize
      )
    }
  }
#endif

#if os(iOS)
  extension UIFont {
    /// Returns a rounded system font with the given size and weight.
    fileprivate static func roundedFont(
      ofSize size: CGFloat,
      weight: UIFont.Weight
    ) -> UIFont {
      let base = UIFont.systemFont(ofSize: size, weight: weight)
      if let descriptor = base.fontDescriptor.withDesign(.rounded) {
        return UIFont(descriptor: descriptor, size: size)
      } else {
        return base
      }
    }
  }
#endif

// used as fallback whilst parsing markdown (almost instant)
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

extension NSAttributedString.Key {
  static let rawContent =
    NSAttributedString.Key("PaicordRawTextContentKey")
}

private enum EmojiImageCache {
  static let cache = NSCache<NSString, AppKitOrUIKitImage>()

  static func key(_ url: URL, size: CGFloat) -> NSString {
    "\(url.absoluteString)#\(Int(size))" as NSString
  }

  static func get(_ url: URL, size: CGFloat) -> AppKitOrUIKitImage? {
    cache.object(forKey: key(url, size: size))
  }

  static func set(_ image: AppKitOrUIKitImage, url: URL, size: CGFloat) {
    cache.setObject(image, forKey: key(url, size: size))
  }
}

class EmojiData: NSObject, NSSecureCoding {
  var url: URL
  var size: CGFloat

  init(url: URL, size: CGFloat) {
    self.url = url
    self.size = size
  }

  required convenience init?(coder: NSCoder) {
    guard let url = coder.decodeObject(of: NSURL.self, forKey: "url") as URL?
    else { return nil }
    let size =
      coder.decodeObject(of: NSNumber.self, forKey: "size")?.doubleValue ?? 18.0
    self.init(url: url, size: CGFloat(size))
  }

  func encode(with coder: NSCoder) {
    coder.encode(url, forKey: "url")
    coder.encode(size, forKey: "size")
  }

  static var supportsSecureCoding: Bool { true }
}

final class EmojiTextAttachment: NSTextAttachment {
  let emojiURL: URL
  let emojiSize: CGFloat

  init(url: URL, size: CGFloat, font: AppKitOrUIKitFont) {
    self.emojiURL = url
    self.emojiSize = size
    super.init(data: nil, ofType: "public.item")

    let yOffset =
      (font.xHeight - size) / 2
      - font.pointSize * -0.05

    self.bounds = CGRect(
      x: 0,
      y: yOffset,
      width: size,
      height: size
    )
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

extension MarkdownRendererVM {
  func makeEmojiAttachment(
    emoji: EmojiData,
    attributes: [NSAttributedString.Key: Any]
  )
    -> NSAttributedString
  {
    let contextFont = attributes[.font] as! AppKitOrUIKitFont
    let attachment = EmojiTextAttachment(
      url: emoji.url,
      size: emoji.size,
      font: contextFont
    )
    let attachmentString = NSMutableAttributedString(attachment: attachment)
    // set attributes from context
    for (attrKey, attrValue) in attributes {
      attachmentString.addAttribute(
        attrKey,
        value: attrValue,
        range: NSRange(location: 0, length: attachmentString.length)
      )
    }
    return attachmentString
  }
}

final class EmojiAttachmentViewProvider: NSTextAttachmentViewProvider {
  private var animatedImageView: SDAnimatedImageView?
  private var container: AppKitOrUIKitView?
  private var didInvalidate = false

  private func invalidateDisplayForThisAttachment() {
    guard
      let lm = textLayoutManager?.textContainer?.layoutManager,
      let storage = textLayoutManager?.textContainer?.layoutManager?.textStorage
    else { return }

    let full = NSRange(location: 0, length: storage.length)
    storage.enumerateAttribute(.attachment, in: full) { value, range, stop in
      if (value as? NSTextAttachment) == self.textAttachment {
        lm.invalidateDisplay(forCharacterRange: range)
        stop.pointee = true
      }
    }
  }

  override init(
    textAttachment: NSTextAttachment,
    parentView: AppKitOrUIKitView?,
    textLayoutManager: NSTextLayoutManager?,
    location: NSTextLocation
  ) {
    super.init(
      textAttachment: textAttachment,
      parentView: parentView,
      textLayoutManager: textLayoutManager,
      location: location
    )
    self.tracksTextAttachmentViewBounds = false
  }

  override func loadView() {
    guard let attachment = textAttachment as? EmojiTextAttachment else {
      return
    }
    let size = attachment.emojiSize

    let host = AppKitOrUIKitView(frame: .zero)
    #if os(iOS)
      host.backgroundColor = .clear
    #else
      host.wantsLayer = false
    #endif

    let imageView = SDAnimatedImageView(frame: .zero)
    #if os(iOS)
      imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      imageView.contentMode = .scaleAspectFit
    #else
      imageView.autoresizingMask = [.width, .height]
      imageView.imageScaling = .scaleProportionallyUpOrDown
    #endif
    imageView.clipsToBounds = true

    let url = attachment.emojiURL
    if let cached = EmojiImageCache.get(url, size: size) {
      imageView.image = cached
      if !self.didInvalidate {
        self.didInvalidate = true
        self.invalidateDisplayForThisAttachment()
      }
    } else {
      SDWebImageManager.shared.loadImage(
        with: url,
        options: [.scaleDownLargeImages],
        progress: nil
      ) { image, _, _, _, _, _ in
        guard let img = image else { return }
        EmojiImageCache.set(img, url: url, size: size)
        DispatchQueue.main.async {
          imageView.image = img
          if !self.didInvalidate {
            self.didInvalidate = true
            self.invalidateDisplayForThisAttachment()
          }
        }
      }
    }

    host.addSubview(imageView)
    self.view = host
    self.container = host
    self.animatedImageView = imageView
  }

  deinit {
    animatedImageView = nil
    container = nil
  }
}

// MARK: - Environment Key for Cross-Block Text Selection

private struct CrossBlockTextSelectionKey: EnvironmentKey {
  static let defaultValue: Bool = false
}

extension EnvironmentValues {
  var enableCrossBlockTextSelection: Bool {
    get { self[CrossBlockTextSelectionKey.self] }
    set { self[CrossBlockTextSelectionKey.self] = newValue }
  }
}

extension View {
  /// Enables cross-block text selection for markdown text within this view
  /// - Note: Only works on macOS. On iOS, this does nothing and the original
  ///         per-block rendering is used.
  func enableCrossBlockTextSelection(_ enabled: Bool = true) -> some View {
    #if os(macOS)
      environment(\.enableCrossBlockTextSelection, enabled)
    #else
      self  // No-op on iOS
    #endif
  }
}
