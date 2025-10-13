//
//  Markdown.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import DiscordMarkdownParser
import Foundation
import HighlightSwift
import PaicordLib
import SwiftUIX

struct MarkdownText: View {
	var content: String
	var renderer: MarkdownRendererVM = .init()

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
			await renderer.update(content)
		}
	}

	struct BlockView: View {
		var block: BlockElement
		var body: some View {
			switch block.nodeType {
			case .paragraph:
				if let attr = block.attributedContent {
					let attrConverted = AttributedString(attr)
					Text(attrConverted)
				} else {
					Text("")
				}

			case .heading:
				if let attr = block.attributedContent {
					let converted = AttributedString(attr)
					Text(converted)
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

			default:
				// Fallback: attempt to render attributed content
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

		var body: some View {
			ScrollView(.horizontal) {
				Group {
					if let language {
						CodeText(code)
							.highlightMode(.languageAlias(language))
					} else {
						CodeText(code)
					}
				}
				.padding(2)
			}
			.background(Color(hexadecimal: "#1f202f"))
			.cornerRadius(6)
		}
	}
}

// A simple block model representing each top-level block parsed from the AST.
// Inline content is provided as an NSAttributedString in `attributedContent` when applicable.
struct BlockElement: Identifiable {
	let id = UUID()
	let nodeType: ASTNodeType
	let attributedContent: NSAttributedString?
	// For code blocks and other block-level metadata:
	let codeContent: String?
	let language: String?
	let level: Int?  // heading level
	let children: [BlockElement]?  // for nested blocks (blockquotes, lists)
	let sourceLocation: SourceLocation?
}

@Observable
class MarkdownRendererVM {
	static var parser: DiscordMarkdownParser = {
		.init()
	}()

	var blocks: [BlockElement] = []

	init() {}

	func update(_ rawContent: String) async {
		self.rawContent = rawContent
		do {
			let ast: AST.DocumentNode = try await Self.parser.parseToAST(
				self.rawContent
			)
			self.blocks = await self.buildBlocks(from: ast)
		} catch {
			// parsing failed — keep previous content but log
			print("Markdown parse failed: \(error)")
		}
	}

	private var rawContent: String = ""

	// Walk top-level AST nodes and convert to BlockElement models.
	func buildBlocks(from document: AST.DocumentNode) async -> [BlockElement] {
		var result: [BlockElement] = []
		for child in document.children {
			if let block = await makeBlock(from: child) {
				result.append(block)
			}
		}
		return result
	}

	// Create a BlockElement from an ASTNode if it is a block-level node.
	private func makeBlock(from node: ASTNode) async -> BlockElement? {
		switch node.nodeType {
		case .paragraph:
			let attributed = renderInlinesToNSAttributedString(nodes: node.children)
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
					headingLevel: heading.level
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
				if let b = await makeBlock(from: child) {
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
							if let blockChild = await makeBlock(from: c) {
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
						let attr = renderInlinesToNSAttributedString(nodes: item.children)
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
			let attr = renderInlinesToNSAttributedString(nodes: node.children)
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
		headingLevel: Int? = nil
	)
		-> NSAttributedString
	{
		let result = NSMutableAttributedString()

		let baseFontSize: CGFloat = 14.0
		let baseAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: AppKitOrUIKitColor.labelCompatible,
			.font: FontHelpers.systemFont(size: baseFontSize),
		]

		for node in nodes {
			append(
				node: node,
				to: result,
				baseAttributes: baseAttributes,
				baseFontSize: baseFontSize
			)
		}

		// If this is a heading, apply heading font to the whole attributed string.
		if let level = headingLevel, result.length > 0 {
			var headingFont: Any = FontHelpers.boldFont(base: baseFontSize)
			switch level {
			case 1: headingFont = FontHelpers.systemFont(size: 24)
			case 2: headingFont = FontHelpers.systemFont(size: 20)
			case 3: headingFont = FontHelpers.systemFont(size: 18)
			default: headingFont = FontHelpers.boldFont(base: baseFontSize)
			}
			result.addAttribute(
				.font,
				value: headingFont,
				range: NSRange(location: 0, length: result.length)
			)
		}

		return result
	}

	private func append(
		node: ASTNode,
		to container: NSMutableAttributedString,
		baseAttributes: [NSAttributedString.Key: Any],
		baseFontSize: CGFloat
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
					baseAttributes: baseAttributes,
					baseFontSize: baseFontSize
				)
			}
			var newAttrs = baseAttributes
			newAttrs[.font] = FontHelpers.italicFont(base: baseFontSize)
			inner.addAttributes(
				newAttrs,
				range: NSRange(location: 0, length: inner.length)
			)
			container.append(inner)

		case .bold:
			let inner = NSMutableAttributedString()
			for child in node.children {
				append(
					node: child,
					to: inner,
					baseAttributes: baseAttributes,
					baseFontSize: baseFontSize
				)
			}
			var newAttrs = baseAttributes
			newAttrs[.font] = FontHelpers.boldFont(base: baseFontSize)
			inner.addAttributes(
				newAttrs,
				range: NSRange(location: 0, length: inner.length)
			)
			container.append(inner)

		case .underline:
			let inner = NSMutableAttributedString()
			for child in node.children {
				append(
					node: child,
					to: inner,
					baseAttributes: baseAttributes,
					baseFontSize: baseFontSize
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
					baseAttributes: baseAttributes,
					baseFontSize: baseFontSize
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
					.font: FontHelpers.monospaceFont(base: baseFontSize),
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
						baseAttributes: baseAttributes,
						baseFontSize: baseFontSize
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
						baseAttributes: baseAttributes,
						baseFontSize: baseFontSize
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
				let attrs: [NSAttributedString.Key: Any] = [
					.font: FontHelpers.systemFont(size: baseFontSize),
					.foregroundColor: AppKitOrUIKitColor.systemBlue,
					.link: URL(string: a.url) as Any,
				]
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
					baseAttributes: baseAttributes,
					baseFontSize: baseFontSize
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
				let s = NSAttributedString(
					string: ":\(ce.name):",
					attributes: baseAttributes
				)
				container.append(s)
			}

		case .userMention:
			if let m = node as? AST.UserMentionNode {
				let s = NSAttributedString(
					string: "<@\(m.id)>",
					attributes: baseAttributes
				)
				container.append(s)
			}

		case .roleMention:
			if let r = node as? AST.RoleMentionNode {
				let s = NSAttributedString(
					string: "<@&\(r.id)>",
					attributes: baseAttributes
				)
				container.append(s)
			}

		case .channelMention:
			if let c = node as? AST.ChannelMentionNode {
				let s = NSAttributedString(
					string: "<#\(c.id)>",
					attributes: baseAttributes
				)
				container.append(s)
			}

		case .everyoneMention:
			container.append(
				NSAttributedString(string: "@everyone", attributes: baseAttributes)
			)

		case .hereMention:
			container.append(
				NSAttributedString(string: "@here", attributes: baseAttributes)
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
					baseAttributes: baseAttributes,
					baseFontSize: baseFontSize
				)
			}
		}
	}
}

// MARK: - Helpers

private enum FontHelpers {
	static func systemFont(size: CGFloat) -> Any {
		#if os(macOS)
			return NSFont.systemFont(ofSize: size)
		#else
			return UIFont.systemFont(ofSize: size)
		#endif
	}

	static func boldFont(base: CGFloat) -> Any {
		#if os(macOS)
			return NSFont.boldSystemFont(ofSize: base)
		#else
			return UIFont.boldSystemFont(ofSize: base)
		#endif
	}

	static func italicFont(base: CGFloat) -> Any {
		#if os(macOS)
			// try to get an italic variant; fallback to system font
			if let italic = NSFontManager.shared.convert(
				NSFont.systemFont(ofSize: base),
				toHaveTrait: .italicFontMask
			) as NSFont? {
				return italic
			}
			return NSFont.systemFont(ofSize: base)
		#else
			if let descriptor = UIFont.systemFont(ofSize: base).fontDescriptor
				.withSymbolicTraits(.traitItalic)
			{
				return UIFont(descriptor: descriptor, size: base)
			}
			return UIFont.systemFont(ofSize: base)
		#endif
	}

	static func monospaceFont(base: CGFloat) -> Any {
		#if os(macOS)
			return NSFont.monospacedSystemFont(ofSize: base, weight: .regular)
		#else
			return UIFont.monospacedSystemFont(ofSize: base, weight: .regular)
		#endif
	}
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
	fileprivate init(
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
	@Previewable @State var input = "hello **world**"
	@Previewable @State var content = "hello **world**"
	VStack {
		TextEditor(text: $input)
			.containerRelativeFrame(.vertical) { length, _ in
				length / 2
			}
			.onChange(of: input) {
				content = input
			}
		Divider()
		ScrollView {
			VStack(alignment: .leading) {
				MarkdownText(content: content)
			}
		}
	}
	.frame(maxWidth: 550)
	.frame(maxHeight: 260)
	.background(.appBackground)
}
