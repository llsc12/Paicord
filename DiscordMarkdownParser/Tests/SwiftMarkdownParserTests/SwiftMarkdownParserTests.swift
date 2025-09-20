import XCTest

@testable import DiscordMarkdownParser

/// Test suite for the DiscordMarkdownParser functionality.
///
/// This test suite covers the AST-focused parsing functionality,
/// including parsing various markdown elements and error handling.
final class DiscordMarkdownParserTests: XCTestCase {
	var parser: DiscordMarkdownParser!

	override func setUp() {
		super.setUp()
		parser = DiscordMarkdownParser()
	}

	override func tearDown() {
		parser = nil
		super.tearDown()
	}

	// MARK: - Parser Tests

	func testParseEmptySringReturnsEmptyDocument() async throws {
		let document = try await parser.parseToAST("")
		XCTAssertEqual(document.children.count, 0)
	}
	
	

	func testUserMentionParsing() async throws {
		let document = try await parser.parseToAST("<@1016895892055396484>")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph
		else {
			XCTFail("No paragraph node found")
			return
		}
		guard let mentionNode = paragraphNode.children.first else {
			XCTFail("No AST node userMention found in paragraph node")
			return
		}
		XCTAssertEqual(mentionNode.nodeType, .userMention)
	}

	func testRoleMentionParsing() async throws {
		let document = try await parser.parseToAST("<@&1417977289706176713>")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph
		else {
			XCTFail("No paragraph node found")
			return
		}
		guard let mentionNode = paragraphNode.children.first else {
			XCTFail("No AST node roleMention found in paragraph node")
			return
		}
		XCTAssertEqual(mentionNode.nodeType, .roleMention)
	}

	func testChannelMentionParsing() async throws {
		let document = try await parser.parseToAST("<#1418492655872249978>")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph
		else {
			XCTFail("No paragraph node found")
			return
		}
		guard let mentionNode = paragraphNode.children.first else {
			XCTFail("No AST node channelMention found in paragraph node")
			return
		}
		XCTAssertEqual(mentionNode.nodeType, .channelMention)
	}

	func testCustomEmojiParsing() async throws {
		let document = try await parser.parseToAST(
			"<:evilLightbulbJuice:1234108089511186442>s"
		)
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph
		else {
			XCTFail("No paragraph node found")
			return
		}
		guard let emojiNode = paragraphNode.children.first else {
			XCTFail("No AST node customEmoji found in paragraph node")
			return
		}
		XCTAssertEqual(emojiNode.nodeType, .customEmoji)
	}

	func testSpoilerParsing() async throws {
		let document = try await parser.parseToAST("||spoiler||")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph
		else {
			XCTFail("No paragraph node found")
			return
		}
		guard let spoilerNode = paragraphNode.children.first else {
			XCTFail("No AST node spoiler found in paragraph node")
			return
		}
		XCTAssertEqual(spoilerNode.nodeType, .spoiler)
	}

	func testTimestampParsing() async throws {
		let document = try await parser.parseToAST("<t:1757847540:R>")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph
		else {
			XCTFail("No paragraph node found")
			return
		}
		guard let timestampNode = paragraphNode.children.first else {
			XCTFail("No AST node timestamp found in paragraph node")
			return
		}
		XCTAssertEqual(timestampNode.nodeType, .timestamp)
	}

	func testUserMentionNodeProperties() async throws {
		let userId = "1016895892055396484"
		let document = try await parser.parseToAST("<@\(userId)>")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let mentionNode = paragraphNode.children.first as? AST.UserMentionNode
		else {
			XCTFail("UserMentionNode not found or wrong type")
			return
		}
		XCTAssertEqual(mentionNode.id.rawValue, userId)
	}

	func testRoleMentionNodeProperties() async throws {
		let roleId = "1417977289706176713"
		let document = try await parser.parseToAST("<@&\(roleId)>")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let mentionNode = paragraphNode.children.first as? AST.RoleMentionNode
		else {
			XCTFail("RoleMentionNode not found or wrong type")
			return
		}
		XCTAssertEqual(mentionNode.id.rawValue, roleId)
	}

	func testChannelMentionNodeProperties() async throws {
		let channelId = "1418492655872249978"
		let document = try await parser.parseToAST("<#\(channelId)>")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let mentionNode = paragraphNode.children.first as? AST.ChannelMentionNode
		else {
			XCTFail("ChannelMentionNode not found or wrong type")
			return
		}
		XCTAssertEqual(mentionNode.id.rawValue, channelId)
	}

	func testCustomEmojiNodeProperties() async throws {
		let emojiName = "evilLightbulbJuice"
		let emojiId = "1234108089511186442"
		let document = try await parser.parseToAST(
			"<:evilLightbulbJuice:1234108089511186442>"
		)
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let emojiNode = paragraphNode.children.first as? AST.CustomEmojiNode
		else {
			XCTFail("CustomEmojiNode not found or wrong type")
			return
		}
		XCTAssertEqual(emojiNode.name, emojiName)
		XCTAssertEqual(emojiNode.identifier.rawValue, emojiId)
		XCTAssertFalse(emojiNode.isAnimated)
	}

	func testAnimatedCustomEmojiNodeProperties() async throws {
		let emojiName = "partyParrot"
		let emojiId = "987654321012345678"
		let document = try await parser.parseToAST(
			"<a:partyParrot:987654321012345678>"
		)
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let emojiNode = paragraphNode.children.first as? AST.CustomEmojiNode
		else {
			XCTFail("Animated CustomEmojiNode not found or wrong type")
			return
		}
		XCTAssertEqual(emojiNode.name, emojiName)
		XCTAssertEqual(emojiNode.identifier.rawValue, emojiId)
		XCTAssertTrue(emojiNode.isAnimated)
	}

	func testTimestampNodeProperties() async throws {
		let timestamp = "1757847540"
		let style = AST.TimestampNode.TimestampStyle.relative
		let document = try await parser.parseToAST("<t:\(timestamp):R>")
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let timestampNode = paragraphNode.children.first as? AST.TimestampNode
		else {
			XCTFail("TimestampNode not found or wrong type")
			return
		}
		XCTAssertEqual(timestampNode.style, style)
		XCTAssertEqual(
			Int(timestampNode.date.timeIntervalSince1970),
			Int(timestamp)!
		)
	}

	func testTimestampAllStyles() async throws {
		let timestamp = "1757847540"
		let styles: [(String, AST.TimestampNode.TimestampStyle)] = [
			("R", .relative), ("t", .shortTime), ("T", .longTime), ("d", .shortDate),
			("D", .longDate), ("f", .longDateShortTime),
			("F", .longDateWeekDayShortTime),
		]
		for (styleStr, styleEnum) in styles {
			let document = try await parser.parseToAST("<t:\(timestamp):\(styleStr)>")
			guard let paragraphNode = document.children.first,
				paragraphNode.nodeType == .paragraph,
				let timestampNode = paragraphNode.children.first as? AST.TimestampNode
			else {
				XCTFail("TimestampNode not found for style \(styleStr)")
				continue
			}
			XCTAssertEqual(timestampNode.style, styleEnum)
			XCTAssertEqual(
				Int(timestampNode.date.timeIntervalSince1970),
				Int(timestamp)!
			)
		}
	}

	func testInvalidMentionEdgeCases() async throws {
		let invalids = ["<@>", "<@&>", "<#>", "<:name:>", "<a:name:>"]
		for invalid in invalids {
			let document = try await parser.parseToAST(invalid)
			guard let paragraphNode = document.children.first,
				paragraphNode.nodeType == .paragraph,
				paragraphNode.children.first is AST.TextNode
			else {
				XCTFail("Invalid mention did not produce TextNode for \(invalid)")
				continue
			}
		}
	}

	func testMixedMentionAndFormatting() async throws {
		let markdown = "**<@1016895892055396484>** is __*cool*__!"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph
		else {
			XCTFail("No paragraph node found")
			return
		}
		// Should contain a bold node with a user mention inside
		let boldNode = paragraphNode.children.first {
			$0.nodeType == .strongEmphasis
		}
		XCTAssertNotNil(boldNode)
		if let boldNode = boldNode {
			let mentionNode = boldNode.children.first { $0.nodeType == .userMention }
			XCTAssertNotNil(mentionNode)
		}
		// Should also contain underline and italic nodes
		let underlineNode = paragraphNode.children.first {
			$0.nodeType == .underline
		}
		XCTAssertNotNil(underlineNode)
		if let underlineNode = underlineNode {
			let italicNode = underlineNode.children.first { $0.nodeType == .emphasis }
			XCTAssertNotNil(italicNode)
		}
	}

	func testSpoilerWithMentionAndEmoji() async throws {
		let markdown =
			"||<@1016895892055396484> <a:partyParrot:987654321012345678>||"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let spoilerNode = paragraphNode.children.first as? AST.SpoilerNode
		else {
			XCTFail("No spoiler node found")
			return
		}
		let mentionNode = spoilerNode.children.first { $0.nodeType == .userMention }
		let emojiNode = spoilerNode.children.first { $0.nodeType == .customEmoji }
		XCTAssertNotNil(mentionNode)
		XCTAssertNotNil(emojiNode)
	}

	func testLinkWithFormattingAndEmoji() async throws {
		let markdown = "[**bold** <:smile:123456>](https://example.com)"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let linkNode = paragraphNode.children.first as? AST.LinkNode
		else {
			XCTFail("No link node found")
			return
		}
		let boldNode = linkNode.children.first { $0.nodeType == .strongEmphasis }
		let emojiNode = linkNode.children.first { $0.nodeType == .customEmoji }
		XCTAssertNotNil(boldNode)
		XCTAssertNotNil(emojiNode)
		XCTAssertEqual(linkNode.url, "https://example.com")
	}

	func testCodeSpanWithMentionAndEmoji() async throws {
		let markdown = "`<@1016895892055396484> <:smile:123456>`"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph,
			let codeNode = paragraphNode.children.first as? AST.CodeSpanNode
		else {
			XCTFail("No code span node found")
			return
		}
		XCTAssertTrue(codeNode.content.contains("<@1016895892055396484>"))
		XCTAssertTrue(codeNode.content.contains("<:smile:123456>"))
	}

	func testBlockQuoteWithSpoilerAndMention() async throws {
		let markdown = "> ||<@1016895892055396484>||"
		let document = try await parser.parseToAST(markdown)
		guard let blockQuoteNode = document.children.first,
			blockQuoteNode.nodeType == .blockQuote,
			let paragraphNode = blockQuoteNode.children.first as? AST.ParagraphNode,
			let spoilerNode = paragraphNode.children.first as? AST.SpoilerNode
		else {
			XCTFail("No block quote with spoiler node found")
			return
		}
		let mentionNode = spoilerNode.children.first { $0.nodeType == .userMention }
		XCTAssertNotNil(mentionNode)
	}

	func testListWithMentionsAndEmojis() async throws {
		let markdown = "- <@1016895892055396484>\n- <:smile:123456>"
		let document = try await parser.parseToAST(markdown)
		guard let listNode = document.children.first,
			listNode.nodeType == .list
		else {
			XCTFail("No list node found")
			return
		}
		XCTAssertGreaterThan(listNode.children.count, 1)
		let firstItem = listNode.children[0] as? AST.ListItemNode
		let secondItem = listNode.children[1] as? AST.ListItemNode
		XCTAssertNotNil(firstItem)
		XCTAssertNotNil(secondItem)
		// Each list item contains a paragraph node, which contains the mention/emoji
		if let firstParagraph = firstItem?.children.first as? AST.ParagraphNode {
			let mentionNode = firstParagraph.children.first {
				$0.nodeType == .userMention
			}
			XCTAssertNotNil(mentionNode)
		}
		if let secondParagraph = secondItem?.children.first as? AST.ParagraphNode {
			let emojiNode = secondParagraph.children.first {
				$0.nodeType == .customEmoji
			}
			XCTAssertNotNil(emojiNode)
		}
	}

	func testTripleUnderscoreUnderlineAndItalic() async throws {
		let markdown = "___triple___"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first,
			paragraphNode.nodeType == .paragraph
		else {
			XCTFail("No paragraph node found")
			return
		}
		let underlineNode = paragraphNode.children.first {
			$0.nodeType == .underline
		}
		XCTAssertNotNil(underlineNode)
		if let underlineNode = underlineNode as? AST.UnderlineNode {
			let italicNode = underlineNode.children.first { $0.nodeType == .emphasis }
			XCTAssertNotNil(italicNode)
			if let italicNode = italicNode as? AST.ItalicNode {
				let textNode =
					italicNode.children.first { $0.nodeType == .text } as? AST.TextNode
				XCTAssertNotNil(textNode)
				XCTAssertEqual(textNode?.content, "triple")
			}
		}
	}

	func testInlineStylingInHeaders() async throws {
		let markdowns: [(String, Int?, ASTNodeType, String?, Any.Type?)] = [
			("# **bold**", 1, .strongEmphasis, "bold", AST.HeadingNode.self),
			("## *italic*", 2, .emphasis, "italic", AST.HeadingNode.self),
			("### __underline__", 3, .underline, "underline", AST.HeadingNode.self),
			("# ~~strike~~", 1, .strikethrough, "strike", AST.HeadingNode.self),
			("## <:smile:123456>", 2, .customEmoji, nil, AST.HeadingNode.self),
			(
				"### <@1016895892055396484>", 3, .userMention, nil, AST.HeadingNode.self
			),
			// Footnote/subtext styling test case
			("-# hi", nil, .text, "hi", AST.FootnoteNode.self),
		]
		for (markdown, level, expectedType, expectedText, expectedNodeType)
			in markdowns
		{
			let document = try await parser.parseToAST(markdown)
			guard let node = document.children.first else {
				XCTFail("No node found for: \(markdown)")
				continue
			}
			XCTAssertTrue(
				type(of: node) == expectedNodeType,
				"Expected node type \(expectedNodeType!) for: \(markdown)"
			)
			if let level = level, let headingNode = node as? AST.HeadingNode {
				XCTAssertEqual(headingNode.level, level)
				let styledNode = headingNode.children.first {
					$0.nodeType == expectedType
				}
				XCTAssertNotNil(
					styledNode,
					"Expected \(expectedType) in header for: \(markdown)"
				)
				if let expectedText = expectedText, let styledNode = styledNode {
					if let textNode = styledNode.children.first(where: {
						$0.nodeType == .text
					}) as? AST.TextNode {
						XCTAssertEqual(textNode.content, expectedText)
					}
				}
			} else if expectedNodeType == AST.FootnoteNode.self,
				let footnoteNode = node as? AST.FootnoteNode
			{
				let textNode = footnoteNode.children.first {
					$0.nodeType == expectedType
				}
				XCTAssertNotNil(
					textNode,
					"Expected \(expectedType) in footnote for: \(markdown)"
				)
				if let expectedText = expectedText,
					let textNode = textNode as? AST.TextNode
				{
					XCTAssertEqual(textNode.content, expectedText)
				}
			}
		}
	}

	func testInlineCodeSpanParsing() async throws {
		let document = try await parser.parseToAST(
			"This is `inline code` in a sentence."
		)
		guard let paragraphNode = document.children.first as? AST.ParagraphNode
		else {
			XCTFail("No paragraph node found")
			return
		}
		let codeSpanNode =
			paragraphNode.children.first(where: { $0.nodeType == .codeSpan })
			as? AST.CodeSpanNode
		XCTAssertNotNil(codeSpanNode)
		XCTAssertEqual(codeSpanNode?.content, "inline code")
	}

	func testInlineCodeSpanEdgeCases() async throws {
		// Empty code span (should be treated as literal backticks, not a code span)
		let document = try await parser.parseToAST(
			"This is an empty code span: ``."
		)
		guard let paragraphNode = document.children.first as? AST.ParagraphNode
		else {
			XCTFail("No paragraph node found")
			return
		}
		let textNode =
			paragraphNode.children.first(where: {
				($0 as? AST.TextNode)?.content.contains("``") == true
			}) as? AST.TextNode
		XCTAssertNotNil(textNode)
		XCTAssertEqual(textNode?.content, "``")

		// Nested backticks (should parse correctly)
		let doc2 = try await parser.parseToAST(
			"Use ``code with `backticks` inside`` here."
		)
		guard let para2 = doc2.children.first as? AST.ParagraphNode else {
			XCTFail("No paragraph node found")
			return
		}
		let codeSpanNode2 =
			para2.children.first(where: { $0.nodeType == .codeSpan })
			as? AST.CodeSpanNode
		XCTAssertNotNil(codeSpanNode2)
		XCTAssertEqual(codeSpanNode2?.content, "code with `backticks` inside")
	}

	func testCodeBlockParsingWithoutLanguage() async throws {
		let markdown = """
			```
			let x = 42
			print(x)
			```
			"""
		let document = try await parser.parseToAST(markdown)
		guard let codeBlockNode = document.children.first as? AST.CodeBlockNode
		else {
			XCTFail("No code block node found")
			return
		}
		XCTAssertEqual(codeBlockNode.content, "let x = 42\nprint(x)\n")
		XCTAssertNil(codeBlockNode.language)
		XCTAssertTrue(codeBlockNode.isFenced)
	}

	func testCodeBlockParsingWithLanguage() async throws {
		let markdown = """
			```swift
			let x = 42
			print(x)
			```
			"""
		let document = try await parser.parseToAST(markdown)
		guard let codeBlockNode = document.children.first as? AST.CodeBlockNode
		else {
			XCTFail("No code block node found")
			return
		}
		XCTAssertEqual(codeBlockNode.content, "let x = 42\nprint(x)\n")
		XCTAssertEqual(codeBlockNode.language, "swift")
		XCTAssertTrue(codeBlockNode.isFenced)
	}

	func testCodeBlockEdgeCases() async throws {
		// Empty code block
		let markdown = """
```
```
"""
		let document = try await parser.parseToAST(markdown)
		guard let codeBlockNode = document.children.first as? AST.CodeBlockNode else {
			XCTFail("No code block node found")
			return
		}
		XCTAssertEqual(codeBlockNode.content, "")
		XCTAssertNil(codeBlockNode.language)
		XCTAssertTrue(codeBlockNode.isFenced)

		// Code block with trailing newlines
		let markdownWithTrailingNewlines = """
```
line 1

line 3

```
"""
		let document2 = try await parser.parseToAST(markdownWithTrailingNewlines)
		guard let codeBlockNode2 = document2.children.first as? AST.CodeBlockNode else {
			XCTFail("No code block node found for trailing newlines")
			return
		}
		XCTAssertEqual(codeBlockNode2.content, "line 1\n\nline 3\n\n")
		XCTAssertNil(codeBlockNode2.language)
		XCTAssertTrue(codeBlockNode2.isFenced)
	}

	// MARK: - Additional Discord Markdown Tests

	func testBlockQuoteWithNestedElements() async throws {
		let markdown = "> # Header\n> ||spoiler||\n> ```swift\n> code\n> ```\n> <@1016895892055396484>"
		let document = try await parser.parseToAST(markdown)
		guard let blockQuoteNode = document.children.first as? AST.BlockQuoteNode else {
			XCTFail("No block quote node found")
			return
		}
		// Should contain a heading, spoiler, code block, and mention
		let headingNode = blockQuoteNode.children.first { $0.nodeType == .heading }
		let spoilerNode = blockQuoteNode.children.first { $0.nodeType == .spoiler }
		let codeBlockNode = blockQuoteNode.children.first { $0.nodeType == .codeBlock }
		let mentionNode = blockQuoteNode.children.first { $0.nodeType == .userMention }
		XCTAssertNotNil(headingNode)
		XCTAssertNotNil(spoilerNode)
		XCTAssertNotNil(codeBlockNode)
		XCTAssertNotNil(mentionNode)
	}

	func testMaskedLinksWithTooltipAndNoEmbed() async throws {
		let markdown = "[tooltip link](https://example.org \"tooltips?\")\n[no embed tooltip link](<https://example.org> \"tooltip and no embed\")"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first as? AST.ParagraphNode else {
			XCTFail("No paragraph node found")
			return
		}
		let linkNode1 = paragraphNode.children.first(where: { ($0 as? AST.LinkNode)?.url == "https://example.org" }) as? AST.LinkNode
		let linkNode2 = paragraphNode.children.first(where: { ($0 as? AST.LinkNode)?.url == "https://example.org" }) as? AST.LinkNode
		XCTAssertNotNil(linkNode1)
		XCTAssertNotNil(linkNode2)
		XCTAssertEqual(linkNode1?.title, "tooltips?")
		XCTAssertEqual(linkNode2?.title, "tooltip and no embed")
	}

	func testAutolinkedUrlsEmailsPhones() async throws {
		let markdown = "<https://google.com> <email@email.com> <tel:+999123456789>"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first as? AST.ParagraphNode else {
			XCTFail("No paragraph node found")
			return
		}
		let urlNode = paragraphNode.children.first(where: { ($0 as? AST.TextNode)?.content == "https://google.com" }) as? AST.TextNode
		let emailNode = paragraphNode.children.first(where: { ($0 as? AST.TextNode)?.content == "email@email.com" }) as? AST.TextNode
		let phoneNode = paragraphNode.children.first(where: { ($0 as? AST.TextNode)?.content == "tel:+999123456789" }) as? AST.TextNode
		XCTAssertNotNil(urlNode)
		XCTAssertNotNil(emailNode)
		XCTAssertNotNil(phoneNode)
	}

	func testMultilineBlockQuote() async throws {
		let markdown = ">>> This is a\nmultiline block quote\nwith **bold** and `code`"
		let document = try await parser.parseToAST(markdown)
		guard let blockQuoteNode = document.children.first as? AST.BlockQuoteNode else {
			XCTFail("No multiline block quote node found")
			return
		}
		let hasBold = blockQuoteNode.children.contains { $0.nodeType == .strongEmphasis }
		let hasCodeSpan = blockQuoteNode.children.contains { $0.nodeType == .codeSpan }
		XCTAssertTrue(hasBold)
		XCTAssertTrue(hasCodeSpan)
	}

	func testListWithNestedFormatting() async throws {
		let markdown = "- <@1016895892055396484>\n- **bold**\n- <:smile:123456>"
		let document = try await parser.parseToAST(markdown)
		guard let listNode = document.children.first as? AST.ListNode else {
			XCTFail("No list node found")
			return
		}
		let hasMention = listNode.children.flatMap { $0.children }.contains { $0.nodeType == .userMention }
		let hasBold = listNode.children.flatMap { $0.children }.contains { $0.nodeType == .strongEmphasis }
		let hasEmoji = listNode.children.flatMap { $0.children }.contains { $0.nodeType == .customEmoji }
		XCTAssertTrue(hasMention)
		XCTAssertTrue(hasBold)
		XCTAssertTrue(hasEmoji)
	}

	func testInlineStylingCombinations() async throws {
		let markdown = "__***bold underlined italics***__"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first as? AST.ParagraphNode else {
			XCTFail("No paragraph node found")
			return
		}
		let underlineNode = paragraphNode.children.first { $0.nodeType == .underline }
		XCTAssertNotNil(underlineNode)
		if let underlineNode = underlineNode {
			let boldNode = underlineNode.children.first { $0.nodeType == .strongEmphasis }
			XCTAssertNotNil(boldNode)
			if let boldNode = boldNode {
				let italicNode = boldNode.children.first { $0.nodeType == .emphasis }
				XCTAssertNotNil(italicNode)
				if let italicNode = italicNode {
					let textNode = italicNode.children.first { $0.nodeType == .text } as? AST.TextNode
					XCTAssertNotNil(textNode)
					XCTAssertEqual(textNode?.content, "bold underlined italics")
				}
			}
		}
	}

	func testSpoilerWithNestedElements() async throws {
		let markdown = "||<@1016895892055396484> **bold**||"
		let document = try await parser.parseToAST(markdown)
		guard let paragraphNode = document.children.first as? AST.ParagraphNode else {
			XCTFail("No paragraph node found")
			return
		}
		let spoilerNode = paragraphNode.children.first(where: { $0.nodeType == .spoiler }) as? AST.SpoilerNode
		XCTAssertNotNil(spoilerNode)
		let hasMention = spoilerNode?.children.contains { $0.nodeType == .userMention } ?? false
		let hasBold = spoilerNode?.children.contains { $0.nodeType == .strongEmphasis } ?? false
		XCTAssertTrue(hasMention)
		XCTAssertTrue(hasBold)
	}

	func testCodeBlockInsideBlockQuote() async throws {
		let markdown = "> ```\n> code\n> ```"
		let document = try await parser.parseToAST(markdown)
		guard let blockQuoteNode = document.children.first as? AST.BlockQuoteNode else {
			XCTFail("No block quote node found")
			return
		}
		let codeBlockNode = blockQuoteNode.children.first(where: { $0.nodeType == .codeBlock }) as? AST.CodeBlockNode
		XCTAssertNotNil(codeBlockNode)
		XCTAssertEqual(codeBlockNode?.content, "code\n")
	}

	func testFootnoteSubtextStyling() async throws {
		let markdown = "-# subtext or footnote or whatever!"
		let document = try await parser.parseToAST(markdown)
		guard let footnoteNode = document.children.first(where: { $0.nodeType.rawValue == "footnote" }) else {
			XCTFail("No footnote node found")
			return
		}
		let textNode = footnoteNode.children.first(where: { $0.nodeType == .text }) as? AST.TextNode
		XCTAssertNotNil(textNode)
		XCTAssertEqual(textNode?.content, "subtext") // first word in content only
	}
}
