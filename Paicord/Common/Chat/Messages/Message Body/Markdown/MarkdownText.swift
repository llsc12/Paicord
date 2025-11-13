//
//  MarkdownText.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//

import DiscordMarkdownParser
import Foundation
import HighlightSwift
import PaicordLib
import SwiftUIX

struct MarkdownText: View {
  var content: String
  @Environment(\.gateway) var gw
  var channelStore: ChannelStore?

  var renderer: MarkdownRendererVM

  init(
    content: String,
    channelStore: ChannelStore? = nil
  ) {
    self.content = content
    self.channelStore = channelStore
    self.renderer = MarkdownRendererVM(content)
  }

  @State var userPopover: PartialUser?

  @State var lastGuildMemberCount: Int = -1

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      ForEach(renderer.blocks) { block in
        BlockView(block: block)
      }

      // simple fallback while parsing
      if renderer.blocks.isEmpty {
        Text(markdown: content)  // apple's markdown
          .opacity(0.6)
      }
    }
    .task(id: content, render)
    .task(id: channelStore?.guildStore?.members.count, render)
    .environment(
      \.openURL,
      OpenURLAction { url in
        return handleURL(url)
      }
    )
    .popover(item: $userPopover) {
      user in
      ProfilePopoutView(
        guild: channelStore?.guildStore,
        member: channelStore?.guildStore?.members[user.id],
        user: user
      )
    }
  }

  @Sendable
  func render() async {
    if let count = channelStore?.guildStore?.members.count {
      // re-render if member count changed (for mentions resolving), ignoring content similarity.
      // but if count is same as last time, do the normal content check.
      if count != lastGuildMemberCount {
        lastGuildMemberCount = count  // resolved mentions, render
      } else {
        guard content != renderer.rawContent else { return }  // avoid redundant renders
      }
    } else {
      guard content != renderer.rawContent else { return }  // avoid redundant renders
    }
    renderer.passRefs(
      gw: gw,
      channelStore: channelStore
    )  // it isnt expensive to call this, its just refs.
    await renderer.update(content)
  }

  func handleURL(_ url: URL) -> OpenURLAction.Result {
    // Handle paicord mention links
    guard let cmd = PaicordChatLink(url: url) else {
      return .systemAction
    }

    switch cmd {
    case .userMention(let userID):
      if let user = gw.user.users[userID] {
        userPopover = user
      }
    default:
      print("[MarkdownText] Unhandled special link: \(cmd)")
      return .discarded  // other paicord links not handled yet, todo.
    }

    return .handled
  }

  struct BlockView: View {
    var block: BlockElement
    var body: some View {
      switch block.nodeType {
      case .paragraph, .heading, .footnote:
        if let attr = block.attributedContent {
          AttributedText(attributedString: attr)
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
            }
          }
        }
        .padding(.leading, 8)
        .overlay(
          Rectangle()
            .frame(width: 3)
            .foregroundStyle(.tertiary)
            .cornerRadius(1),
          alignment: .leading
        )

      case .list:
        if let children = block.children {
          VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(children.enumerated()), id: \.element.id) {
              (index, child) in
              HStack(alignment: .top, spacing: 8) {
                Text("•").font(.body)
                BlockView(block: child)
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
    var body: some View {
      HStack {
        Group {
          if let language {
            CodeText(code)
              .highlightMode(.languageAlias(language))
          } else {
            Text(code)  // no highlighting
          }
        }
        .fontDesign(.monospaced)
        .padding(8)
        .background(Color(hexadecimal: "#1f202f"))
        .clipShape(.rounded)
        .overlay(
          RoundedRectangle(cornerSize: .init(10), style: .continuous)
            .stroke(Color(hexadecimal: "#373745"), lineWidth: 1)
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

        // instead of resizing the codeblock, we use a spacer that fills the smaller area.
        // fixes codeblocks leaving blockquotes, and fixes codeblocks inside embeds.
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

struct BlockElement: Identifiable {
  let id = UUID()
  let nodeType: ASTNodeType
  let attributedContent: NSAttributedString?
  // For code blocks and other block-level metadata:
  let codeContent: String?
  let language: String?
  let level: Int?  // heading level
  let children: [BlockElement]?  // for nested blocks (lists, codeblocks etc, but not blockquotes.)
  let sourceLocation: SourceLocation?
}

@Observable
class MarkdownRendererVM {
  static var parser: DiscordMarkdownParser = {
    .init()
  }()

  // document cache is redundant if we have block cache
  //  static let documentCache: NSCache<NSString, CachedDocument> = .init()
  static let blockCache: NSCache<NSString, CachedDocumentBlocks> = .init()

  //  class CachedDocument: NSObject {
  //    let document: AST.DocumentNode
  //    init(document: AST.DocumentNode) {
  //      self.document = document
  //    }
  //  }
  class CachedDocumentBlocks: NSObject {
    let blocks: [BlockElement]
    init(blocks: [BlockElement]) {
      self.blocks = blocks
    }
  }

  var blocks: [BlockElement] = []

  init(_ content: String? = nil) {
    guard let content else { return }
    // try cache check. do not parse if cache fail.
    if let cached = Self.blockCache.object(forKey: content as NSString) {
      self.rawContent = content
      self.blocks = cached.blocks
    }
  }

  var gw: GatewayStore!
  var guildStore: GuildStore?
  var channelStore: ChannelStore?

  func passRefs(
    gw: GatewayStore,
    channelStore: ChannelStore?
  ) {
    self.gw = gw
    self.guildStore = channelStore?.guildStore
    self.channelStore = channelStore
  }

  func update(_ rawContent: String) async {
    self.rawContent = rawContent
    do {
      let ast: AST.DocumentNode = try await Task.detached {
        let ast = try await Self.parser.parseToAST(rawContent)
        return ast
      }.value
      let blocks = await Task.detached {
        if let cached = Self.blockCache.object(forKey: rawContent as NSString) {
          return cached.blocks
        }
        //        let emojisOnly = ast.isEmojisOnly()
        //        await MainActor.run {
        //          self.isEmojisOnly = emojisOnly
        //        }
        let blocks = self.buildBlocks(from: ast)
        let cached = CachedDocumentBlocks(blocks: blocks)
        Self.blockCache.setObject(cached, forKey: rawContent as NSString)
        return blocks
      }.value
      await MainActor.run {
        self.blocks = blocks
      }
    } catch {
      // parsing failed, keep previous content but log
      print("Markdown parse failed: \(error)")
    }
  }

  var rawContent: String = ""

  private enum BaseInlineStyle { case body, footnote }

  // Walk top-level AST nodes and convert to BlockElement models.
  func buildBlocks(from document: AST.DocumentNode) -> [BlockElement] {
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
    switch node.nodeType {
    case .paragraph:
      let attributed = renderInlinesToNSAttributedString(
        nodes: node.children,
        baseStyle: .body
      )
      return BlockElement(
        nodeType: .paragraph,
        attributedContent: attributed,
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
          nodeType: .heading,
          attributedContent: attributed,
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
        nodeType: .footnote,
        attributedContent: attributed,
        codeContent: nil,
        language: nil,
        level: nil,
        children: nil,
        sourceLocation: node.sourceLocation
      )
    case .codeBlock:
      if let code = node as? AST.CodeBlockNode {
        return BlockElement(
          nodeType: .codeBlock,
          attributedContent: nil,
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
        nodeType: .blockQuote,
        attributedContent: nil,
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
          // List items contain block children themselves. We'll turn each item into a block (with children).
          if let listItem = item as? AST.ListItemNode {
            var listItemChildren: [BlockElement] = []
            for c in listItem.children {
              if let blockChild = makeBlock(from: c) {
                listItemChildren.append(blockChild)
              }
            }
            let itemBlock = BlockElement(
              nodeType: .listItem,
              attributedContent: nil,
              codeContent: nil,
              language: nil,
              level: nil,
              children: listItemChildren,
              sourceLocation: listItem.sourceLocation
            )
            items.append(itemBlock)
          } else {
            // fallback: try to convert inline children to a paragraph inside list item
            let attr = renderInlinesToNSAttributedString(
              nodes: item.children,
              baseStyle: .body
            )
            let itemBlock = BlockElement(
              nodeType: .listItem,
              attributedContent: attr,
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
          nodeType: .list,
          attributedContent: nil,
          codeContent: nil,
          language: nil,
          level: nil,
          children: items,
          sourceLocation: node.sourceLocation
        )
      }
      return nil

    case .thematicBreak:
      // Not much to render; give a thin line fallback handled in view
      let attr = NSAttributedString(string: "—")
      return BlockElement(
        nodeType: .thematicBreak,
        attributedContent: attr,
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
        nodeType: node.nodeType,
        attributedContent: attr,
        codeContent: nil,
        language: nil,
        level: nil,
        children: nil,
        sourceLocation: node.sourceLocation
      )
    }
  }

  // Render inline AST nodes to an NSAttributedString by walking the inline subtree.
  // This is the core of the inline renderer. It produces an attributed string applying basic
  // typographic styles for bold/italic/underline/strikethrough/monospace & links.
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
      baseColor = AppKitOrUIKitColor.labelCompatible
    case .footnote:
      baseFont = FontHelpers.preferredFootnoteFont()
      baseColor = AppKitOrUIKitColor.secondaryLabelCompatible
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
          .backgroundColor: AppKitOrUIKitColor
            .tertiarySystemBackgroundCompatible,
          .foregroundColor: AppKitOrUIKitColor.labelCompatible,
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
        } else {
          newAttrs[.foregroundColor] = AppKitOrUIKitColor(
            Color(hexadecimal6: 0x00aafc)
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
          Color(hexadecimal6: 0x00aafc)
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
      newAttrs[.foregroundColor] = AppKitOrUIKitColor.secondaryLabelCompatible
      inner.addAttributes(
        newAttrs,
        range: NSRange(location: 0, length: inner.length)
      )
      container.append(inner)

    case .customEmoji:
      if let ce = node as? AST.CustomEmojiNode {
        let copyText =
          "<\(ce.isAnimated ? "a" : ""):\(ce.name):\(ce.identifier.rawValue)>"
        guard
          let url = URL(
            string: CDNEndpoint.customEmoji(emojiId: ce.identifier).url
              + (ce.isAnimated ? ".gif" : ".png") + "?size=44"
          )
        else { return }
        let s = self.makeEmojiAttachment(url: url, copyText: copyText)
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
        #if os(macOS)
          attrs[.accessibilityCustomText] = "<@\(m.id.rawValue)>"
        #endif
        attrs[.backgroundColor] = AppKitOrUIKitColor(
          Color(hexadecimal6: 0x383c6f).opacity(0.8)
        )
        attrs[.foregroundColor] = AppKitOrUIKitColor(
          Color(AppKitOrUIKitColor.white).opacity(0.8)
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
          #if os(macOS)
            attrs[.accessibilityCustomText] = "<@&\(r.id.rawValue)>"
          #endif
          if let url = URL(string: "paicord://mention/role/\(r.id.rawValue)") {
            attrs[.link] = url
          }

          let discordColor = role.color
          if let color = discordColor.asColor() {
            attrs[.backgroundColor] = AppKitOrUIKitColor(color.opacity(0.08))
            attrs[.foregroundColor] = AppKitOrUIKitColor(color)
          } else {
            attrs[.backgroundColor] = AppKitOrUIKitColor(
              Color(hexadecimal6: 0x383c6f).opacity(0.8)
            )
            attrs[.foregroundColor] = AppKitOrUIKitColor(
              Color(AppKitOrUIKitColor.white).opacity(0.8)
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
          #if os(macOS)
            attrs[.accessibilityCustomText] = "<#\(c.id.rawValue)>"
          #endif
          if let url = URL(string: "paicord://mention/channel/\(c.id.rawValue)")
          {
            attrs[.link] = url
          }
          attrs[.backgroundColor] = AppKitOrUIKitColor(
            Color(hexadecimal6: 0x383c6f).opacity(0.8)
          )
          attrs[.foregroundColor] = AppKitOrUIKitColor(
            Color(AppKitOrUIKitColor.white).opacity(0.8)
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
        Color(hexadecimal6: 0x383c6f)
      )
      attrs[.foregroundColor] = AppKitOrUIKitColor(
        Color(AppKitOrUIKitColor.white).opacity(0.8)
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
        Color(hexadecimal6: 0x383c6f)
      )
      attrs[.foregroundColor] = AppKitOrUIKitColor(
        Color(AppKitOrUIKitColor.white).opacity(0.8)
      )
      container.append(
        NSAttributedString(string: "@here", attributes: attrs)
      )

    case .timestamp:
      if let t = node as? AST.TimestampNode {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        let s = NSAttributedString(
          string: df.string(from: t.date),
          attributes: baseAttributes
        )
        container.append(s)
      }

    default:
      // Generic recursion for unknown inline nodes
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
      let font = UIFont.preferredFont(forTextStyle: .body)
      return UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
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
      let base = UIFont.preferredFont(forTextStyle: .body)
      let mono = UIFont.monospacedSystemFont(
        ofSize: base.pointSize,
        weight: .regular
      )
      return UIFontMetrics(forTextStyle: .body).scaledFont(for: mono)
    #endif
  }

  static func preferredFootnoteFont() -> Any {
    #if os(macOS)
      return NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
    #else
      let font = UIFont.preferredFont(forTextStyle: .footnote)
      return UIFontMetrics(forTextStyle: .footnote).scaledFont(for: font)
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

// UIColor wrappers for cross-platform compatibility
extension AppKitOrUIKitColor {
  fileprivate static var labelCompatible: AppKitOrUIKitColor {
    #if os(macOS)
      return NSColor.label
    #else
      return UIColor.label
    #endif
  }

  fileprivate static var secondaryLabelCompatible: AppKitOrUIKitColor {
    #if os(macOS)
      return NSColor.secondaryLabelColor
    #else
      return UIColor.secondaryLabel
    #endif
  }

  fileprivate static var tertiarySystemBackgroundCompatible: AppKitOrUIKitColor
  {
    #if os(macOS)
      return NSColor.windowBackgroundColor
    #else
      return UIColor.tertiarySystemBackground
    #endif
  }
}

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
  case everyoneMention
  case hereMention

  case discordMessageLink(GuildSnowflake?, ChannelSnowflake, MessageSnowflake)

  init?(url: URL) {
    guard
      url.scheme == "paicord"
        || (url.host() == "discord.com" && url.scheme == "https")
    else { return nil }
    switch url.host() {
    case "discord.com":
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

        self = .discordMessageLink(
          guildSnowflake,
          channelSnowflake,
          messageSnowflake
        )
      default:
        return nil
      }
      #warning("impl any other discord.com links")

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
