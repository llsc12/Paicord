//
//  Markdown.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import DiscordMarkdownParser
import PaicordLib
import SwiftUIX

// Block Elements:
// - paragraph
// - heading
// - blockQuote
// - list
// - listItem
// - codeBlock
// - thematicBreak

// Inline Elements:
// - text
// - emphasis
// - strongEmphasis
// - link
// - codeSpan
// - lineBreak
// - strikethrough
// - underline
// - spoiler
// - footnote
// - customEmoji
// - userMention
// - roleMention
// - channelMention
// - everyoneMention
// - hereMention
// - timestamp
// - autolink

struct TestMessageView: View {
	var content: String
	var renderer: MessageRendererVM = .init()

	var body: some View {
		VStack {
			if let ast = renderer.ast {
				let _ = print(ast.children)
				ForEach(ast.children, id: \.sourceLocation) { node in
					DecidingView(node: node)
				}
			} else {
				Text(markdown: content)
			}
		}
		.task(id: content) {
			await renderer.update(content)
		}
	}

	/// Pass any node to this view, and it will decide which view to use based on the node type.
	struct DecidingView: View {
		var node: ASTNode

		var body: some View {
			if node.nodeType.isBlock {
				BlockView(node: node)
			} else if node.nodeType.isInline {
				InlineView(node: node)
			} else {
				Text("Unknown node type: \(node.nodeType)")
			}
		}
	}

	/// Handles block elements.
	struct BlockView: View {
		var node: ASTNode

		var body: some View {
			switch node.nodeType {
			case .paragraph:
				ForEach(node.children, id: \.sourceLocation) { child in
					DecidingView(node: child)
				}
			default:
				Text("Unsupported block element: \(node.nodeType)")
			}
		}
	}

	/// Handles inline elements.
	struct InlineView: View {
		var node: ASTNode

		var body: some View {
			switch node.nodeType {
			case .text:
				if let textNode = node as? AST.TextNode {
					Text(textNode.content)
				}
			case .bold:
				if let boldNode = node as? AST.BoldNode {
					ForEach(boldNode.children, id: \.sourceLocation) { child in
						DecidingView(node: child)
					}
					.bold()
				}

			default:
				Text("Unsupported inline element: \(node.nodeType)")
			}
		}
	}
}

@Observable
class MessageRendererVM {
	static var parser: DiscordMarkdownParser = {
		.init()
	}()

	init() {}

	func update(_ rawContent: String) async {
		self.rawContent = rawContent
		let ast: AST.DocumentNode? = try? await createAST()
		self.ast = ast
	}

	func createAST() async throws -> AST.DocumentNode {
		try await Self.parser.parseToAST(self.rawContent)
	}

	private var rawContent: String = ""
	public var ast: AST.DocumentNode? = nil
}

#Preview {
	@Previewable @State var input = "hello **world**"
	@Previewable @State var content = "hello **world**"
	VStack {
		TextField("markdown", text: $input)
			.onSubmit {
				content = input
			}
		Divider()
		TestMessageView(content: content)
	}
	.frame(maxWidth: 550)
	.frame(maxHeight: 260)
}

// Goal of the renderer is to minimise the amount of fallback to swiftui views,
// handling as much as possible with NSAttributedString and TextAttachments, at worst use Text concatenation
// for custom elements like mentions, emojis, etc.
// this makes performance much better, especially for long messages with lots of elements.
