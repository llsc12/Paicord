/// Block parser for converting tokens into block-level AST nodes
///
/// This parser handles container blocks (block quotes, lists) and leaf blocks
/// (headings, paragraphs, code blocks) according to the CommonMark specification.
import Foundation

// MARK: - Block Parser

/// Parser for block-level markdown elements
public final class BlockParser {

	private let tokenStream: TokenStream
	private let configuration: DiscordMarkdownParser.Configuration
	private var linkReferences: [String: LinkReference] = [:]

	/// Initialize with token stream and configuration
	public init(
		tokenStream: TokenStream,
		configuration: DiscordMarkdownParser.Configuration
	) {
		self.tokenStream = tokenStream
		self.configuration = configuration
	}

	/// Parse the entire document into an AST
	public func parseDocument() throws -> AST.DocumentNode {
		var children: [ASTNode] = []

		// Protection mechanisms
		var consecutiveNilBlocks = 0
		let maxConsecutiveNilBlocks = 50  // Prevent infinite loops from nil blocks

		var lastTokenPosition = -1
		var stuckPositionCount = 0
		let maxStuckPositions = 10  // Prevent infinite loops from position not advancing

		let startTime = Date()
		let maxParsingTime = configuration.maxParsingTime

		while !tokenStream.isAtEnd {
			// Time-based protection
			if maxParsingTime > 0
				&& Date().timeIntervalSince(startTime) > maxParsingTime
			{
				throw MarkdownParsingError.parsingFailed(
					"Parsing timeout: document too complex or infinite loop detected"
				)
			}

			// Position-based protection (detect if parser is stuck)
			let currentPosition = tokenStream.currentPosition
			if currentPosition == lastTokenPosition {
				stuckPositionCount += 1
				if stuckPositionCount >= maxStuckPositions {
					throw MarkdownParsingError.parsingFailed(
						"Parser stuck: infinite loop detected at token position \(currentPosition)"
					)
				}
			} else {
				stuckPositionCount = 0
				lastTokenPosition = currentPosition
			}

			if let block = try parseBlock() {
				children.append(block)
				consecutiveNilBlocks = 0  // Reset counter when we get a valid block
			} else {
				consecutiveNilBlocks += 1

				// Consecutive nil blocks protection
				if consecutiveNilBlocks >= maxConsecutiveNilBlocks {
					throw MarkdownParsingError.parsingFailed(
						"Too many consecutive nil blocks: possible infinite loop in parser"
					)
				}
			}
		}

		return AST.DocumentNode(children: children)
	}

	/// Parse a single block element
	private func parseBlock() throws -> ASTNode? {
		// Skip whitespace at start of line
		skipWhitespace()

		guard !tokenStream.isAtEnd else {
			return nil
		}

		let token = tokenStream.current

		// Discord footnote header: -# ...
		if token.type == .footnoteHeaderMarker {
			return try parseFootnoteHeader()
		}

		switch token.type {
		case .atxHeaderStart:
			return try parseATXHeading()

		case .multilineBlockQuoteMarker:
			return try parseMultilineBlockQuote()

		case .blockQuoteMarker:
			return try parseBlockQuote()

		case .listMarker:
			return try parseList()

		case .backtick, .tildeCodeFence:
			if token.content.count >= 3 {
				return try parseFencedCodeBlock()
			}
			// Single backticks should be treated as part of a paragraph, not as code blocks
			return try parseParagraph()

		case .indentedCodeBlock:
			return try parseIndentedCodeBlock()

		case .newline:
			// Empty line - skip
			tokenStream.advance()
			return nil

		default:
			// Check for setext heading
			if let setextHeading = try parseSetextHeading() {
				return setextHeading
			}

			// Default to paragraph
			return try parseParagraph()
		}
	}

	private func parseFootnoteHeader() throws -> AST.FootnoteNode {
		let startLocation = tokenStream.current.location
		// Consume '-' and '#' tokens
		_ = tokenStream.consume()  // '-'
		_ = tokenStream.consume()  // '#'
		skipWhitespace()
		let inlineParser = InlineParser(
			tokenStream: tokenStream,
			configuration: configuration
		)
		let children = try inlineParser.parseInlines(until: [.newline, .eof])
		return AST.FootnoteNode(children: children, sourceLocation: startLocation)
	}

	// MARK: - Heading Parsers

	private func parseATXHeading() throws -> AST.HeadingNode {
		let startLocation = tokenStream.current.location
		let headerToken = tokenStream.consume()
		let level = headerToken.content.count

		// Skip whitespace after #
		skipWhitespace()

		// Use the inline parser to properly handle the heading content
		let inlineParser = InlineParser(
			tokenStream: tokenStream,
			configuration: configuration
		)
		let children = try inlineParser.parseInlines(until: [.newline, .eof])

		return AST.HeadingNode(
			level: level,
			children: children,
			sourceLocation: startLocation
		)
	}

	private func parseSetextHeading() throws -> AST.HeadingNode? {
		// Look ahead to see if next line is setext underline
		let startPosition = tokenStream.currentPosition

		// Parse potential heading text
		var textTokens: [Token] = []
		while !tokenStream.isAtEnd && !tokenStream.check(.newline) {
			textTokens.append(tokenStream.consume())
		}

		// Must have newline
		guard tokenStream.match(.newline) else {
			// Backtrack
			tokenStream.setPosition(startPosition)
			return nil
		}

		// Check for underline

		guard !tokenStream.isAtEnd else {
			tokenStream.setPosition(startPosition)
			return nil
		}

		let underlineToken = tokenStream.current

		// A valid setext underline must be at least 3 consecutive '=' or '-' characters
		// and must not include other characters.
		let trimmedContent = underlineToken.content.trimmingCharacters(
			in: .whitespaces
		)
		let isLevel1 =
			trimmedContent.allSatisfy { $0 == "=" } && trimmedContent.count >= 3
		let isLevel2 =
			trimmedContent.allSatisfy { $0 == "-" } && trimmedContent.count >= 3

		guard isLevel1 || isLevel2 else {
			tokenStream.setPosition(startPosition)
			return nil
		}

		// Consume underline token and any trailing newline
		tokenStream.advance()

		// Create heading
		let textContent = textTokens.map { $0.content }.joined()
		let children = [
			AST.TextNode(
				content: textContent.trimmingCharacters(in: .whitespacesAndNewlines)
			)
		]

		return AST.HeadingNode(
			level: isLevel1 ? 1 : 2,
			children: children,
			sourceLocation: textTokens.first?.location
		)
	}

	// MARK: - Block Quote Parser

	private func parseBlockQuote() throws -> AST.BlockQuoteNode {
		let startLocation = tokenStream.current.location

		// Collect all lines of the block quote instead
		var blockQuoteLines: [String] = []

		while !tokenStream.isAtEnd && tokenStream.check(.blockQuoteMarker) {
			tokenStream.advance()  // consume >
			skipWhitespace()

			// Collect all tokens on this line
			var lineContent = ""
			while !tokenStream.isAtEnd && !tokenStream.check(.newline) {
				lineContent += tokenStream.current.content
				tokenStream.advance()
			}

			blockQuoteLines.append(lineContent)

			// Consume newline if present
			_ = tokenStream.match(.newline)
			// Repeat
		}

		let blockQuoteContent = blockQuoteLines.joined(separator: "\n")

		// Create new tokenizer and parser for block quote content
		let contentTokenizer = MarkdownTokenizer(blockQuoteContent)
		var contentTokens = contentTokenizer.tokenize()
		
		// Filter out blockquote markers to prevent nested blockquotes
		// Convert any blockquote tokens to text tokens (literal > characters)
		contentTokens = contentTokens.map { token in
			if token.type == .blockQuoteMarker || token.type == .multilineBlockQuoteMarker {
				return Token(type: .text, content: token.content, location: token.location)
			}
			return token
		}
		
		let contentTokenStream = TokenStream(contentTokens)
		let contentParser = BlockParser(
			tokenStream: contentTokenStream,
			configuration: configuration
		)

		// Parse the content as a sub doc
		let contentDocument = try contentParser.parseDocument()

		// This prevents the block quote children blocks from having blockquote tokens incorrectly.
		// Fixes testBlockQuoteWithNestedElements

		return AST.BlockQuoteNode(
			children: contentDocument.children,
			sourceLocation: startLocation
		)
	}

	private func parseMultilineBlockQuote() throws -> AST.BlockQuoteNode {
		let startLocation = tokenStream.current.location
		
		// Consume the >>> token
		tokenStream.advance()
		skipWhitespace()
		
		// Collect all remaining content until end of input
		var allContent = ""
		
		// First, collect the rest of the current line
		while !tokenStream.isAtEnd && !tokenStream.check(.newline) {
			allContent += tokenStream.current.content
			tokenStream.advance()
		}
		
		// Then collect all remaining lines
		while !tokenStream.isAtEnd {
			if tokenStream.check(.newline) {
				allContent += "\n"
				tokenStream.advance()
			} else {
				allContent += tokenStream.current.content
				tokenStream.advance()
			}
		}
		
		// Create a new tokenizer and parser for the multiline block quote content
		let contentTokenizer = MarkdownTokenizer(allContent)
		let contentTokens = contentTokenizer.tokenize()
		let contentTokenStream = TokenStream(contentTokens)
		let contentParser = BlockParser(tokenStream: contentTokenStream, configuration: configuration)
		
		// Parse the content as a mini-document
		let contentDocument = try contentParser.parseDocument()
		
		return AST.BlockQuoteNode(children: contentDocument.children, sourceLocation: startLocation)
	}

	// MARK: - List Parsers

	private func parseList() throws -> AST.ListNode {
		let startLocation = tokenStream.current.location
		let firstMarker = tokenStream.current.content

		let isOrdered = firstMarker.last == "." || firstMarker.last == ")"
		let startNumber = isOrdered ? Int(firstMarker.dropLast()) : nil
		let delimiter = isOrdered ? firstMarker.last : nil
		let bulletChar = isOrdered ? nil : firstMarker.first

		var items: [ASTNode] = []

		while !tokenStream.isAtEnd && tokenStream.check(.listMarker) {
			let marker = tokenStream.current.content

			// Check if this marker matches the list type
			let markerIsOrdered = marker.last == "." || marker.last == ")"
			if markerIsOrdered != isOrdered {
				break
			}

			if isOrdered {
				if marker.last != delimiter {
					break
				}
			} else {
				if marker.first != bulletChar {
					break
				}
			}

			// Parse list item
			let item = try parseListItem()
			items.append(item)

			skipWhitespaceAndNewlines()
		}

		return AST.ListNode(
			isOrdered: isOrdered,
			startNumber: startNumber,
			items: items,
			sourceLocation: startLocation
		)
	}

	private func parseListItem() throws -> AST.ListItemNode {
		let startLocation = tokenStream.current.location

		// Consume list marker
		tokenStream.advance()
		skipWhitespace()

		var children: [ASTNode] = []

		// Parse inline content for the first line
		let inlineParser = InlineParser(
			tokenStream: tokenStream,
			configuration: configuration
		)
		let inlineNodes = try inlineParser.parseInlines(until: [.newline, .eof])

		// Create paragraph for first line if not empty
		if !inlineNodes.isEmpty {
			children.append(
				AST.ParagraphNode(children: inlineNodes, sourceLocation: startLocation)
			)
		}

		// Skip the newline if present
		_ = tokenStream.match(.newline)

		// Check if there's continuation content (indented blocks)
		while !tokenStream.isAtEnd {
			// Check if next line starts a new list item
			if isAtStartOfListItem() {
				break
			}

			// Check for blank line followed by non-indented content (ends list)
			if isBlankLineThenNonIndented() {
				break
			}

			// Special check: if we encounter a list marker at the start of a line
			// without proper indentation, it should end this list item
			if isListMarkerAtStartOfLine() {
				break
			}

			// Parse any continuation blocks
			if let block = try parseBlock() {
				children.append(block)
			} else {
				break
			}
		}

		return AST.ListItemNode(children: children, sourceLocation: startLocation)
	}

	private func isNextListItem() -> Bool {
		// Look ahead to see if we have a list marker at start of line
		let currentPos = tokenStream.currentPosition

		// Skip newlines and whitespace
		while !tokenStream.isAtEnd
			&& (tokenStream.check(.newline) || tokenStream.check(.whitespace))
		{
			tokenStream.advance()
		}

		let isListItem = tokenStream.check(.listMarker)

		// Restore position
		tokenStream.setPosition(currentPos)

		return isListItem
	}

	private func isAtStartOfListItem() -> Bool {
		// Check if we're at the start of a line with a list marker
		let currentPos = tokenStream.currentPosition

		// Skip to start of content (skip newlines first, then whitespace)
		while tokenStream.check(.newline) {
			tokenStream.advance()
		}

		// Track indentation level
		var indentLevel = 0
		while tokenStream.check(.whitespace) && indentLevel < 4 {
			indentLevel += 1
			tokenStream.advance()
		}

		let result = tokenStream.check(.listMarker)

		// Restore position
		tokenStream.setPosition(currentPos)

		return result
	}

	private func isListMarkerAtStartOfLine() -> Bool {
		let currentPos = tokenStream.currentPosition

		// Skip newlines to get to next line
		while tokenStream.check(.newline) {
			tokenStream.advance()
		}

		// Check for minimal indentation (0-3 spaces is acceptable for a new list)
		var spaceCount = 0
		while tokenStream.check(.whitespace) && spaceCount < 4 {
			spaceCount += 1
			tokenStream.advance()
		}

		// Check if there's a list marker here
		let hasListMarker = tokenStream.check(.listMarker)

		// Restore position
		tokenStream.setPosition(currentPos)

		return hasListMarker
	}

	private func isBlankLineThenNonIndented() -> Bool {
		let currentPos = tokenStream.currentPosition

		// Check for blank line
		if !tokenStream.check(.newline) {
			return false
		}

		tokenStream.advance()

		// Skip any additional blank lines
		while tokenStream.check(.newline) {
			tokenStream.advance()
		}

		// Check if next content is non-indented
		var spaceCount = 0
		while tokenStream.check(.whitespace) && spaceCount < 4 {
			spaceCount += tokenStream.current.content.count
			tokenStream.advance()
		}

		let result = spaceCount < 4 && !tokenStream.isAtEnd

		// Restore position
		tokenStream.setPosition(currentPos)

		return result
	}

	// MARK: - Code Block Parsers

	private func parseFencedCodeBlock() throws -> AST.CodeBlockNode {
		let startLocation = tokenStream.current.location
		let fenceToken = tokenStream.consume()
		let fenceChar = fenceToken.content.first!
		let fenceLength = fenceToken.content.count

		// Parse language info
		var language: String?
		var infoString = ""

		while !tokenStream.isAtEnd && !tokenStream.check(.newline) {
			infoString += tokenStream.consume().content
		}

		if !infoString.isEmpty {
			language =
				infoString.trimmingCharacters(in: .whitespacesAndNewlines).components(
					separatedBy: .whitespaces
				).first
		}

		// Skip newline after opening fence
		_ = tokenStream.match(.newline)

		// Collect code content
		var content = ""

		while !tokenStream.isAtEnd {
			// Check for closing fence
			if tokenStream.check(.backtick) || tokenStream.check(.tildeCodeFence) {
				let closingToken = tokenStream.current
				if closingToken.content.first == fenceChar
					&& closingToken.content.count >= fenceLength
				{
					tokenStream.advance()
					break
				}
			}

			if tokenStream.check(.newline) {
				content += "\n"
			} else {
				content += tokenStream.current.content
			}
			tokenStream.advance()
		}

		return AST.CodeBlockNode(
			content: content,
			language: language,
			isFenced: true,
			sourceLocation: startLocation
		)
	}

	private func parseIndentedCodeBlock() throws -> AST.CodeBlockNode {
		let startLocation = tokenStream.current.location
		var content = ""

		while !tokenStream.isAtEnd && tokenStream.check(.indentedCodeBlock) {
			_ = tokenStream.consume()

			// Collect rest of line
			var lineContent = ""
			while !tokenStream.isAtEnd && !tokenStream.check(.newline) {
				lineContent += tokenStream.consume().content
			}

			content += lineContent

			if tokenStream.match(.newline) {
				content += "\n"
			}
		}

		return AST.CodeBlockNode(
			content: content,
			language: nil,
			isFenced: false,
			sourceLocation: startLocation
		)
	}

	// MARK: - Other Block Parsers

	private func collectCurrentLine() -> (
		content: String, location: SourceLocation
	)? {
		guard !tokenStream.isAtEnd && !tokenStream.check(.newline) else {
			return nil
		}

		let startLocation = tokenStream.current.location
		var lineContent = ""

		// Collect all tokens until newline
		while !tokenStream.isAtEnd && !tokenStream.check(.newline) {
			lineContent += tokenStream.consume().content
		}

		return (
			content: lineContent.trimmingCharacters(in: .whitespacesAndNewlines),
			location: startLocation
		)
	}

	private func parseParagraph() throws -> AST.ParagraphNode {
		let startLocation = tokenStream.current.location

		// Use inline parser to properly handle inline elements like code spans, italic, etc.
		let inlineParser = InlineParser(
			tokenStream: tokenStream,
			configuration: configuration
		)
		let inlineNodes = try inlineParser.parseInlines(until: [.newline, .eof])

		return AST.ParagraphNode(
			children: inlineNodes,
			sourceLocation: startLocation
		)
	}

	private func isBlockBoundary() -> Bool {
		let token = tokenStream.current

		switch token.type {
		case .newline:
			// Check if followed by another newline (blank line)
			return tokenStream.peek().type == .newline
		case .atxHeaderStart, .blockQuoteMarker, .listMarker:
			return true
		case .backtick, .tildeCodeFence:
			return token.content.count >= 3
		case .indentedCodeBlock:
			return true
		case .eof:
			return true
		default:
			return false
		}
	}

	// MARK: - Utility Methods

	private func skipWhitespace() {
		while tokenStream.check(.whitespace) {
			tokenStream.advance()
		}
	}

	private func skipWhitespaceAndNewlines() {
		while tokenStream.check(.whitespace) || tokenStream.check(.newline) {
			tokenStream.advance()
		}
	}
}
