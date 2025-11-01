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
import Playgrounds
import SwiftUIX

struct MarkdownText: View {
  var content: String
  @Environment(GatewayStore.self) var gw
  var channelStore: ChannelStore?

  var renderer: MarkdownRendererVM = .init()

  @State var userPopover: PartialUser?

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
    .task(id: content) {
      guard content != renderer.rawContent else { return }  // skip reparsing of same content.
      renderer.passRefs(
        gw: gw,
        channelStore: channelStore
      )  // it isnt expensive to call this, its just refs.
      await renderer.update(content)
    }
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
    default: return .discarded  // other paicord links not handled yet, todo.
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
      Group {
        if let language {
          CodeText(code)
            .highlightMode(.languageAlias(language))
        } else {
          Text(code)  // no highlighting
        }
      }
      .fontDesign(.monospaced)
      .containerRelativeFrame(.horizontal, alignment: .leading) { length, _ in
        max(length * 0.8, 250)
      }
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

  static let cache: NSCache<NSString, CachedDocument> = .init()

  class CachedDocument: NSObject {
    let document: AST.DocumentNode
    init(document: AST.DocumentNode) {
      self.document = document
    }
  }

  var blocks: [BlockElement] = []

  init() {}

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
        if let cached = Self.cache.object(forKey: rawContent as NSString) {
          return cached.document
        }
        let ast = try await Self.parser.parseToAST(rawContent)
        let cached = CachedDocument(document: ast)
        Self.cache.setObject(cached, forKey: rawContent as NSString)
        return ast
      }.value
      let blocks = await Task.detached {
        //        let emojisOnly = ast.isEmojisOnly()
        //        await MainActor.run {
        //          self.isEmojisOnly = emojisOnly
        //        }
        let blocks = self.buildBlocks(from: ast)
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
        for child in link.children {
          append(
            node: child,
            to: inner,
            baseAttributes: baseAttributes
          )
        }
        var newAttrs = baseAttributes
        if let url = URL(string: link.url) {
          newAttrs[.link] = url
        } else {
          newAttrs[.foregroundColor] = AppKitOrUIKitColor.systemBlue
        }
        newAttrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
        inner.addAttributes(
          newAttrs,
          range: NSRange(location: 0, length: inner.length)
        )
        container.append(inner)
      }

    case .autolink:
      if let a = node as? AST.AutolinkNode {
        let s = NSAttributedString(string: a.text, attributes: baseAttributes)
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
          Color(AppKitOrUIKitColor.labelCompatible).opacity(0.95)
        )
        attrs[.underlineStyle] = .none

        let s = NSAttributedString(string: "@\(name)", attributes: attrs)
        container.append(s)
      }

    case .roleMention:
      if let r = node as? AST.RoleMentionNode {
        if let role = guildStore?.roles[r.id] {
          var attrs = baseAttributes
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
              Color(AppKitOrUIKitColor.labelCompatible).opacity(0.95)
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
          #if os(macOS)
            attrs[.accessibilityCustomText] = "<#\(c.id.rawValue)>"
          #endif
          if let url = URL(string: "paicord://mention/channel/\(c.id.rawValue)")
          {
            attrs[.link] = url
          }
          // base mention background and text per spec:
          attrs[.backgroundColor] = AppKitOrUIKitColor(
            Color(hexadecimal6: 0x383c6f)
          )
          attrs[.foregroundColor] = AppKitOrUIKitColor(
            Color(AppKitOrUIKitColor.labelCompatible).opacity(0.95)
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
      attrs[.backgroundColor] = AppKitOrUIKitColor(
        Color(hexadecimal6: 0x383c6f)
      )
      attrs[.foregroundColor] = AppKitOrUIKitColor(
        Color(AppKitOrUIKitColor.labelCompatible).opacity(0.95)
      )
      if let url = URL(string: "paicord://mention/everyone") {
        attrs[.link] = url
      }
      container.append(
        NSAttributedString(string: "@everyone", attributes: attrs)
      )

    case .hereMention:
      var attrs = baseAttributes
      if let url = URL(string: "paicord://mention/here") {
        attrs[.link] = url
      }
      attrs[.backgroundColor] = AppKitOrUIKitColor(
        Color(hexadecimal6: 0x383c6f)
      )
      attrs[.foregroundColor] = AppKitOrUIKitColor(
        Color(AppKitOrUIKitColor.labelCompatible).opacity(0.95)
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
      let descriptor =
        font.fontDescriptor.withSymbolicTraits(traits) ?? font.fontDescriptor
      // size 0 keeps the same size; then scale for Dynamic Type
      let updated = UIFont(descriptor: descriptor, size: font.pointSize)
      return UIFontMetrics.default.scaledFont(for: updated)
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
}

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

#Preview {
  @Previewable @State var profileOpen: Bool = false
  @Previewable @State var avatarAnimated: Bool = false

  let message: DiscordChannel.Message = .init(
    id: try! .makeFake(),
    channel_id: try! .makeFake(),
    author: DiscordUser(
      id: .init("381538809180848128"),
      username: "llsc12",
      discriminator: "0",
      global_name: nil,
      avatar: "df71b3f223666fd8331c9940c6f7cbd9",
      banner: nil,
      bot: false,
      system: false,
      mfa_enabled: true,
      accent_color: nil,
      locale: nil,
      verified: true,
      email: nil,
      flags: .init(rawValue: 4_194_352),
      premium_type: DiscordUser.PremiumKind.none,
      public_flags: .init(rawValue: 4_194_304),
      collectibles: .init(
        nameplate: .init(
          asset: "nameplates/nameplates_v3/bonsai/",
          sku_id: .init("1382845914225442886"),
          label: "COLLECTIBLES_NAMEPLATES_VOL_3_BONSAI_A11Y",
          palette: .bubble_gum,
          expires_at: nil
        )
      ),
      avatar_decoration_data: nil
    ),
    content:
      """
      gn
      # Regular markdown
      ||spoiler||
      ~~strikethrough~~
      __underline__
      *italics* or _italics_
      **bold**
      ***bold & italics***
      ***~~strikethrough, bold & italics~~*** (you can mix them)
      `codeline`
      **`bold codeline`**
      ``codeline with ` in it``
      ``codeline that ends with ` ``
      and `` ` starts with`` or `` ` has on both sides ` ``
      > single line quote

      > multiple line
      > quote

      >>> (if you type \">>>\" at the beginning of any line, it will 
      expand them to the lines remaining\nuntil the end of the message
      -# doesn't save the \">>>\" if sent from desktop
      """,
    timestamp: .init(date: .now),
    edited_timestamp: nil,
    tts: false,
    mention_everyone: false,
    mentions: [],
    mention_roles: [],
    mention_channels: [],
    attachments: [],
    embeds: [],
    reactions: [],
    nonce: nil,
    pinned: false,
    webhook_id: nil,
    type: .default,
    activity: nil,
    application: nil,
    application_id: nil,
    message_reference: nil,
    flags: .init(rawValue: 0),
    referenced_message: nil,
    interaction: nil,
    thread: nil,
    components: nil,
    sticker_items: nil,
    stickers: nil,
    position: nil,
    role_subscription_data: nil,
    resolved: nil,
    poll: nil,
    call: nil,
    guild_id: nil,
    member: nil
  )
  ScrollView {
    //    LazyVStack {
    VStack {
      HStack(alignment: .bottom) {
        MessageCell.MessageAuthor.Avatar(
          message: message,
          profileOpen: $profileOpen,
          animated: false
        )
        #if os(macOS)
          .padding(.trailing, 4)  // balancing
        #endif
        VStack(spacing: 0) {
          HStack(alignment: .bottom) {
            MessageCell.MessageAuthor.Username(  // username line
              message: message,
              guildStore: nil,
              profileOpen: $profileOpen
            )
            //                        Date(for: message.timestamp.date)  // message date
            //          if let edit = message.edited_timestamp {  // edited notice
            //            MessageCell.DefaultMessage.EditStamp(edited: edit)
            //          }
          }
          .border(.green)
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottomLeading
          )
          .fixedSize(horizontal: false, vertical: true)
          .border(.red)

          MarkdownText(content: message.content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .border(.blue)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)  // align text to bottom of cell
      }
      .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, 4)
    //    .onHover { avatarAnimated = $0 }
  }
  //}
}

enum PaicordChatLink {
  case userMention(UserSnowflake)
  case roleMention(RoleSnowflake)
  case channelMention(ChannelSnowflake)

  case discordMessageLink(UserSnowflake)

  init?(url: URL) {
    guard
      url.scheme == "paicord"
        || (url.host() == "discord.com" && url.scheme == "https")
    else { return nil }
    switch url.host() {
    case "discord.com":
      return nil
      #warning("impl discord.com links")

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
      default:
        return nil
      }

    default:
      return nil
    }
  }
}
