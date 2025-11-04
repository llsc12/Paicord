import DiscordModels
/// Inline parser for converting tokens into inline AST nodes
///
/// This parser handles inline elements like italic, strong italic,
/// links, images, code spans, and other inline formatting.
import Foundation

// MARK: - Inline Parser

/// Parser for inline markdown elements
public final class InlineParser {

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

  /// Parse inline content from current position until specified boundary
  public func parseInlines(until boundary: Set<TokenType> = [.newline, .eof])
    throws -> [ASTNode]
  {
    var nodes: [ASTNode] = []

    // Protection mechanisms
    var lastTokenPosition = -1
    var stuckPositionCount = 0
    let maxStuckPositions = 50  // Prevent infinite loops from position not advancing (increased threshold)

    let startTime = Date()
    let maxParsingTime = configuration.maxParsingTime

    while !tokenStream.isAtEnd && !boundary.contains(tokenStream.current.type) {
      // Time-based protection
      if maxParsingTime > 0
        && Date().timeIntervalSince(startTime) > maxParsingTime
      {
        throw MarkdownParsingError.parsingFailed(
          "Inline parsing timeout: document too complex or infinite loop detected"
        )
      }

      // Position-based protection (detect if parser is stuck)
      let currentPosition = tokenStream.currentPosition
      if currentPosition == lastTokenPosition {
        stuckPositionCount += 1
        if stuckPositionCount >= maxStuckPositions {
          throw MarkdownParsingError.parsingFailed(
            "Inline parser stuck: infinite loop detected at token position \(currentPosition)"
          )
        }
      } else {
        stuckPositionCount = 0
        lastTokenPosition = currentPosition
      }

      let parsedNodes = try parseInline()
      nodes.append(contentsOf: parsedNodes)
    }

    return nodes
  }

  /// Parse inline content from a text string
  public func parseInlineContent(_ text: String) throws -> [ASTNode] {
    let inlineTokenizer = MarkdownTokenizer(text)
    let inlineTokenStream = TokenStream(inlineTokenizer.tokenize())

    // Create a single parser instance for the entire text
    let tempParser = InlineParser(
      tokenStream: inlineTokenStream,
      configuration: configuration
    )

    var nodes: [ASTNode] = []

    // Protection mechanisms
    var lastTokenPosition = -1
    var stuckPositionCount = 0
    let maxStuckPositions = 50  // Prevent infinite loops from position not advancing (increased threshold)

    let startTime = Date()
    let maxParsingTime = configuration.maxParsingTime

    while !inlineTokenStream.isAtEnd {
      // Time-based protection
      if maxParsingTime > 0
        && Date().timeIntervalSince(startTime) > maxParsingTime
      {
        throw MarkdownParsingError.parsingFailed(
          "Inline content parsing timeout: document too complex or infinite loop detected"
        )
      }

      // Position-based protection (detect if parser is stuck)
      let currentPosition = inlineTokenStream.currentPosition
      if currentPosition == lastTokenPosition {
        stuckPositionCount += 1
        if stuckPositionCount >= maxStuckPositions {
          throw MarkdownParsingError.parsingFailed(
            "Inline content parser stuck: infinite loop detected at token position \(currentPosition)"
          )
        }
      } else {
        stuckPositionCount = 0
        lastTokenPosition = currentPosition
      }

      let parsedNodes = try tempParser.parseInline()
      nodes.append(contentsOf: parsedNodes)
    }
    return nodes
  }

  /// Parse a single inline element
  private func parseInline() throws -> [ASTNode] {
    let token = tokenStream.current
    switch token.type {
    case .text, .whitespace, .blockQuoteMarker:
      var content = ""

      // Defensive: capture the first token (and its location) before consuming
      // so the resulting TextNode has the accurate start location even when
      // the tokenizer uses lookahead or stateful logic that may have altered
      // tokenStream.current.location semantics.
      guard !tokenStream.isAtEnd else {
        return [AST.TextNode(content: "", sourceLocation: nil)]
      }

      let firstToken = tokenStream.current
      let startLocation = firstToken.location

      // Merge consecutive text, whitespace, and any stray block quote markers as plain text
      while !tokenStream.isAtEnd
        && (tokenStream.current.type == .text
          || tokenStream.current.type == .whitespace
          || tokenStream.current.type == .blockQuoteMarker)
      {
        let t = tokenStream.consume()
        content += t.content
      }

      return [AST.TextNode(content: content, sourceLocation: startLocation)]
    case .asterisk:
      // Handle italic and strong italic with *
      if let italicNode = try parseItalicOrBold(delimiter: "*") {
        return [italicNode]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .underscore:
      // Discord: double underscore is underline, single is italics, triple is underline+italics
      // The tokenizer may split runs of '_' into multiple tokens ("_","_") or emit
      // combined tokens ("__", "___"). Count consecutive underscore characters by
      // peeking ahead so we can decide which parsing path to take.
      var underscoreCount = 0
      // count current token
      underscoreCount += tokenStream.current.content.count
      // look ahead for more underscore tokens
      var lookahead = 1
      while tokenStream.peek(lookahead).type == .underscore {
        underscoreCount += tokenStream.peek(lookahead).content.count
        lookahead += 1
      }

      // Triple underscore -> underline + italics
      if underscoreCount >= 3 {
        // Prefer the combined parser which can produce an Underline node wrapping
        // an Italic node when three underscores are used.
        if let combinedNode = try? parseItalicOrBold(delimiter: "_") {
          return [combinedNode]
        }

        // Fallback: attempt to parse as underline only
        if let underlineNode = try? parseUnderline() {
          return [underlineNode].compactMap { $0 }
        } else {
          // Fallback: consume a single token as text
          return [AST.TextNode(content: tokenStream.consume().content)]
        }
      }

      // Double underscore -> underline
      if underscoreCount >= 2 {
        if let underlineNode = try? parseUnderline() {
          return [underlineNode].compactMap { $0 }
        } else {
          return [AST.TextNode(content: tokenStream.consume().content)]
        }
      }

      // Single underscore -> italics
      if underscoreCount == 1 {
        if let italicNode = try parseItalicOrBold(delimiter: "_") {
          return [italicNode]
        } else {
          return [AST.TextNode(content: tokenStream.consume().content)]
        }
      }

      // Fallback
      return [AST.TextNode(content: tokenStream.consume().content)]
    case .backtick:
      // Handle code spans
      if let codeSpan = try parseCodeSpan() {
        return [codeSpan]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .leftBracket:
      // Handle links
      if let link = try parseLinkOrImage() {
        return [link]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .exclamation:
      // Handle images
      //      if let image = try parseImage() {
      //        return [image]
      //      } else {
      return [AST.TextNode(content: tokenStream.consume().content)]
    //      }
    case .tilde:
      // Handle strikethrough
      if let strikethrough = try parseStrikethrough() {
        return [strikethrough]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .doublePipe:
      // Handle Discord spoilers
      if let spoiler = try parseSpoiler() {
        return [spoiler]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .userMention:
      // Handle Discord user mentions
      if let userMention = parseUserMention() {
        return [userMention]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .roleMention:
      // Handle Discord role mentions
      if let roleMention = parseRoleMention() {
        return [roleMention]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .channelMention:
      // Handle Discord channel mentions
      if let channelMention = parseChannelMention() {
        return [channelMention]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .everyoneMention:
      // Handle Discord @everyone mentions
      return [parseEveryoneMention()]
    case .hereMention:
      // Handle Discord @here mentions
      return [parseHereMention()]
    case .timestamp:
      // Handle Discord timestamps
      if let timestamp = parseTimestamp() {
        return [timestamp]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .customEmoji:
      // Handle Discord custom emojis
      if let emoji = parseCustomEmoji() {
        return [emoji]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .autolink:
      // Handle autolinks
      if let autolink = parseAutolink() {
        return [autolink]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    case .backslash:
      // Handle escaped characters
      if let escaped = parseEscapedCharacter() {
        return [escaped]
      } else {
        return [AST.TextNode(content: tokenStream.consume().content)]
      }
    default:
      // For other tokens, treat as text
      return [AST.TextNode(content: tokenStream.consume().content)]
    }
  }

  // MARK: - Text and Whitespace

  private func parseText() -> AST.TextNode {
    let token = tokenStream.consume()
    return AST.TextNode(content: token.content, sourceLocation: token.location)
  }

  private func parseWhitespace() -> AST.TextNode {
    let token = tokenStream.consume()
    return AST.TextNode(content: token.content, sourceLocation: token.location)
  }

  // MARK: - Italic and Bold

  private func parseItalicOrBold(delimiter: String) throws -> ASTNode? {
    let startLocation = tokenStream.current.location
    let delimiterChar = Character(delimiter)

    // Count consecutive delimiters
    var delimiterCount = 0
    let startPosition = tokenStream.currentPosition

    while !tokenStream.isAtEnd
      && (tokenStream.current.type == .asterisk
        || tokenStream.current.type == .underscore)
      && tokenStream.current.content.first == delimiterChar
    {
      delimiterCount += tokenStream.current.content.count
      tokenStream.advance()
    }

    // Need at least 1 delimiter
    guard delimiterCount > 0 else {
      tokenStream.setPosition(startPosition)
      return parseText()
    }

    // Look for closing delimiters
    var content: [ASTNode] = []

    while !tokenStream.isAtEnd {
      // Check for closing delimiters
      if (tokenStream.current.type == .asterisk
        || tokenStream.current.type == .underscore)
        && tokenStream.current.content.first == delimiterChar
      {

        // Count closing delimiters
        var closingCount = 0
        let closingPosition = tokenStream.currentPosition

        while !tokenStream.isAtEnd
          && (tokenStream.current.type == .asterisk
            || tokenStream.current.type == .underscore)
          && tokenStream.current.content.first == delimiterChar
        {
          closingCount += tokenStream.current.content.count
          tokenStream.advance()
        }

        // Discord: double underscore is underline
        if delimiterChar == "_" && delimiterCount == 2 && closingCount == 2 {
          return AST.UnderlineNode(
            children: content,
            sourceLocation: startLocation
          )
        }
        // Discord: triple underscore is underline+italics
        if delimiterChar == "_" && delimiterCount == 3 && closingCount == 3 {
          return AST.UnderlineNode(
            children: [
              AST.ItalicNode(children: content, sourceLocation: startLocation)
            ],
            sourceLocation: startLocation
          )
        }
        if delimiterChar == "*" && delimiterCount == 3 && closingCount == 3 {
          return AST.BoldNode(
            children: [
              AST.ItalicNode(children: content, sourceLocation: startLocation)
            ],
            sourceLocation: startLocation
          )
        }
        // Standard Markdown: double asterisk is bold
        if delimiterChar == "*" && delimiterCount >= 2 && closingCount >= 2 {
          let extraDelimiters = closingCount - 2
          if extraDelimiters > 0 {
            tokenStream.setPosition(tokenStream.currentPosition - 1)
          }

          return AST.BoldNode(
            children: content,
            sourceLocation: startLocation
          )
        }

        // italic (1 delimiter)
        if delimiterCount >= 1 && closingCount >= 1 {
          let extraDelimiters = closingCount - 1
          if extraDelimiters > 0 {
            tokenStream.setPosition(tokenStream.currentPosition - 1)
          }

          // Before returning Italic, handle the case where tokenizer left
          // underline delimiters as text nodes inside `content` (e.g. "_", "_", "hi__").
          // If the collected `content` is all TextNodes and their concatenation is
          // wrapped in __...__, convert that into an UnderlineNode inside Italic.
          if delimiterChar == "*" || delimiterChar == "_" {
            // Only attempt this heuristic if content is non-empty and all text nodes
            let allText = content.compactMap { $0 as? AST.TextNode }
            if allText.count == content.count {
              let combined = allText.map { $0.content }.joined()
              if combined.hasPrefix("__") && combined.hasSuffix("__") && combined.count > 4 {
                let inner = String(combined.dropFirst(2).dropLast(2))
                // Re-parse inner as inline content to preserve nested formatting
                let parsedInner = try parseInlineContent(inner)
                let underlineNode = AST.UnderlineNode(children: parsedInner, sourceLocation: startLocation)
                return AST.ItalicNode(children: [underlineNode], sourceLocation: startLocation)
              }
            }
          }

          return AST.ItalicNode(
            children: content,
            sourceLocation: startLocation
          )
        }

        // Not enough closing delimiters, restore position and continue
        tokenStream.setPosition(closingPosition)
      }

      // Parse content
      let inlineNodes = try parseInline()
      for inline in inlineNodes {
        if let fragment = inline as? AST.FragmentNode {
          content.append(contentsOf: fragment.children)
        } else {
          content.append(inline)
        }
      }
    }

    // No closing delimiters found, treat as regular text
    tokenStream.setPosition(startPosition)
    return parseText()
  }

  // MARK: - Code Spans

  private func parseCodeSpan() throws -> AST.CodeSpanNode? {
    let startLocation = tokenStream.current.location
    let startPosition = tokenStream.currentPosition
    let openingToken = tokenStream.consume()
    let backtickCount = openingToken.content.count

    var content = ""
    var foundClosing = false

    // Add protection against infinite loops specifically in code span parsing
    var iterations = 0
    let maxIterations = 1000  // Reasonable limit for code span content

    while !tokenStream.isAtEnd && iterations < maxIterations {
      let token = tokenStream.current

      if token.type == .backtick && token.content.count == backtickCount {
        tokenStream.advance()
        foundClosing = true
        break
      }

      // Accept any token type inside code spans - they should all be treated as literal content
      content += token.content
      tokenStream.advance()
      iterations += 1
    }

    if iterations >= maxIterations {
      // Fallback: backtrack and treat as regular text
      tokenStream.setPosition(startPosition)
      return nil
    }

    guard foundClosing else {
      // No closing backticks, backtrack and treat as regular text
      tokenStream.setPosition(startPosition)
      return nil
    }

    // Trim one space from each end if present
    if content.hasPrefix(" ") && content.hasSuffix(" ") && content.count > 2 {
      content = String(content.dropFirst().dropLast())
    }

    return AST.CodeSpanNode(content: content, sourceLocation: startLocation)
  }

  // MARK: - Links and Images

  private func parseLinkOrImage() throws -> ASTNode? {
    let startLocation = tokenStream.current.location

    // Check if this is an image (preceded by !)
    let isImage =
      tokenStream.currentPosition > 0
      && tokenStream.peek(-1).type == .exclamation

    guard tokenStream.match(.leftBracket) else { return parseText() }

    // Parse link text/alt text
    var linkText: [ASTNode] = []

    while !tokenStream.isAtEnd && !tokenStream.check(.rightBracket) {
      let inlineNodes = try parseInline()
      for inline in inlineNodes {
        if let fragment = inline as? AST.FragmentNode {
          linkText.append(contentsOf: fragment.children)
        } else {
          linkText.append(inline)
        }
      }
    }

    guard tokenStream.match(.rightBracket) else {
      // No closing bracket, treat as text - reconstruct the original content
      let linkTextContent = linkText.compactMap { node in
        if let textNode = node as? AST.TextNode {
          return textNode.content
        }
        return nil
      }.joined()

      return AST.TextNode(
        content: "[\(linkTextContent)",
        sourceLocation: startLocation
      )
    }

    // Check for inline link: [text](url "title")
    if tokenStream.check(.leftParen) {
      return try parseInlineLink(
        linkText: linkText,
        isImage: isImage,
        startLocation: startLocation
      )
    }

    // Check for reference link: [text][ref] or [text][]
    if tokenStream.check(.leftBracket) {
      return try parseReferenceLink(
        linkText: linkText,
        isImage: isImage,
        startLocation: startLocation
      )
    }

    // Shortcut reference link: [ref]
    let refLabel = linkText.compactMap { node in
      if let textNode = node as? AST.TextNode {
        return textNode.content
      }
      return nil
    }.joined()

    if let reference = linkReferences[refLabel.lowercased()] {
      // Discord doesn't support images, this should end as a link with ! in text prefix
      return AST.LinkNode(
        url: reference.url,
        title: reference.title,
        children: linkText,
        sourceLocation: startLocation
      )
    }

    // Not a valid link, treat as text - reconstruct the original bracket content
    let linkTextContent = linkText.compactMap { node in
      if let textNode = node as? AST.TextNode {
        return textNode.content
      }
      return nil
    }.joined()

    return AST.TextNode(
      content: "[\(linkTextContent)]",
      sourceLocation: startLocation
    )
  }

  private func parseInlineLink(
    linkText: [ASTNode],
    isImage: Bool,
    startLocation: SourceLocation
  ) throws -> ASTNode? {
    guard tokenStream.match(.leftParen) else { return nil }

    // Skip whitespace
    while tokenStream.check(.whitespace) {
      tokenStream.advance()
    }

    // Parse URL
    var url = ""
    while !tokenStream.isAtEnd && !tokenStream.check(.rightParen)
      && !tokenStream.check(.whitespace) && tokenStream.current.content != "\""
    {
      url += tokenStream.consume().content
    }

    // Skip whitespace
    while tokenStream.check(.whitespace) {
      tokenStream.advance()
    }

    // Parse optional title
    var title: String?
    if tokenStream.current.content == "\"" {
      tokenStream.advance()  // consume opening quote
      var titleContent = ""

      while !tokenStream.isAtEnd && tokenStream.current.content != "\"" {
        titleContent += tokenStream.consume().content
      }

      if tokenStream.current.content == "\"" {
        tokenStream.advance()  // consume closing quote
        title = titleContent
      }
    }

    // Skip whitespace
    while tokenStream.check(.whitespace) {
      tokenStream.advance()
    }

    guard tokenStream.match(.rightParen) else {
      // Invalid link syntax
      return nil
    }

    //    if isImage {
    //      // For images, extract alt text from linkText
    //      let altText = linkText.compactMap { node in
    //        if let textNode = node as? AST.TextNode {
    //          return textNode.content
    //        }
    //        return nil
    //      }.joined()
    //
    //      return AST.ImageNode(
    //        url: url,
    //        altText: altText,
    //        title: title,
    //        sourceLocation: startLocation
    //      )
    //    } else {
    return AST.LinkNode(
      url: url,
      title: title,
      children: linkText,
      sourceLocation: startLocation
    )
    //    }
  }

  private func parseReferenceLink(
    linkText: [ASTNode],
    isImage: Bool,
    startLocation: SourceLocation
  ) throws -> ASTNode? {
    guard tokenStream.match(.leftBracket) else { return nil }

    var refLabel = ""

    // Parse reference label
    while !tokenStream.isAtEnd && !tokenStream.check(.rightBracket) {
      refLabel += tokenStream.consume().content
    }

    guard tokenStream.match(.rightBracket) else { return nil }

    // If empty reference, use link text as reference
    if refLabel.isEmpty {
      refLabel = linkText.compactMap { node in
        if let textNode = node as? AST.TextNode {
          return textNode.content
        }
        return nil
      }.joined()
    }

    guard let reference = linkReferences[refLabel.lowercased()] else {
      return nil
    }

    //    if isImage {
    //      // For images, extract alt text from linkText
    //      let altText = linkText.compactMap { node in
    //        if let textNode = node as? AST.TextNode {
    //          return textNode.content
    //        }
    //        return nil
    //      }.joined()
    //
    //      return AST.ImageNode(
    //        url: reference.url,
    //        altText: altText,
    //        title: reference.title,
    //        sourceLocation: startLocation
    //      )
    //    } else {
    return AST.LinkNode(
      url: reference.url,
      title: reference.title,
      children: linkText,
      sourceLocation: startLocation
    )
    //    }
  }

  // MARK: - Other Inline Elements

  private func parseEscapedCharacter() -> ASTNode? {
    let token = tokenStream.consume()

    // Remove the backslash and return the escaped character
    let escapedContent =
      token.content.count > 1 ? String(token.content.dropFirst()) : ""
    return AST.TextNode(content: escapedContent, sourceLocation: token.location)
  }

  private func parseEntity() throws -> ASTNode {
    let token = tokenStream.consume()
    // TODO: Implement proper entity decoding
    // For now, return the entity as-is
    return AST.TextNode(content: token.content, sourceLocation: token.location)
  }

  private func parseAutolink() -> AST.AutolinkNode? {
    let token = tokenStream.consume()
    let url = token.content

    // Discord mention patterns (should not be autolinks)
    let mentionPatterns = [
      "^<@>$", "^<@&>$", "^<#>$", "^<t:>$", "^<a:[^:]*:>$", "^<:[^:]*:>$",
    ]
    for pattern in mentionPatterns {
      if url.range(of: pattern, options: .regularExpression) != nil {
        // Incomplete Discord mention, treat as text
        return nil
      }
    }

    // If it looks like a valid Discord mention but is incomplete, treat as text
    if url.hasPrefix("<@") || url.hasPrefix("<@&") || url.hasPrefix("<#")
      || url.hasPrefix("<t:") || url.hasPrefix("<a:") || url.hasPrefix("<:")
    {
      // Check for missing required fields (e.g., no ID)
      let discordMentionRegex = "^<(?:@|@&|#|t:|a:[^:]+:|:[^:]+:)[0-9]+.*>$"
      if url.range(of: discordMentionRegex, options: .regularExpression) == nil
      {
        return nil
      }
    }

    // Otherwise, treat as autolink (URL/email)
    let displayText = url
    return AST.AutolinkNode(
      url: url,
      text: displayText,
      sourceLocation: token.location
    )
  }

  private func parseStrikethrough() throws -> ASTNode? {
    let startPosition = tokenStream.currentPosition
    let startLocation = tokenStream.current.location

    // Check if we have opening ~~
    guard tokenStream.check(.tilde) else { return nil }
    let openingTilde = tokenStream.current
    guard openingTilde.content == "~~" else {
      // Single tilde, not strikethrough
      return nil
    }

    // Consume the opening ~~
    tokenStream.advance()

    var content: [ASTNode] = []
    var foundClosing = false

    // Look for closing ~~
    while !tokenStream.isAtEnd {
      if tokenStream.check(.tilde) && tokenStream.current.content == "~~" {
        // Found closing ~~
        tokenStream.advance()
        foundClosing = true
        break
      }

      // Parse nested inline formatting inside strikethrough instead of raw text
      let inlineNodes = try parseInline()
      for inline in inlineNodes {
        if let fragment = inline as? AST.FragmentNode {
          content.append(contentsOf: fragment.children)
        } else {
          content.append(inline)
        }
      }
    }

    if foundClosing {
      return AST.StrikethroughNode(
        content: content,
        sourceLocation: startLocation
      )
    } else {
      // No closing delimiter found, backtrack and treat as text
      tokenStream.setPosition(startPosition)
      return nil
    }
  }

  private func parseHardBreak() -> AST.LineBreakNode {
    let token = tokenStream.consume()
    return AST.LineBreakNode(isHard: true, sourceLocation: token.location)
  }

  private func parseSoftBreak() -> AST.SoftBreakNode {
    let token = tokenStream.consume()
    return AST.SoftBreakNode(sourceLocation: token.location)
  }

  // MARK: - Discord-Specific Elements

  /// Parse Discord spoiler syntax ||text||
  private func parseSpoiler() throws -> ASTNode? {
    let startPosition = tokenStream.currentPosition
    let startLocation = tokenStream.current.location

    // Check if we have opening ||
    guard tokenStream.check(.doublePipe) else { return nil }

    // Consume the opening ||
    tokenStream.advance()

    var content: [ASTNode] = []
    var foundClosing = false

    // Look for closing ||
    while !tokenStream.isAtEnd {
      if tokenStream.check(.doublePipe) {
        // Found closing ||
        tokenStream.advance()
        foundClosing = true
        break
      }

      // Add content inside spoiler
      let inlineNodes = try parseInline()
      for inline in inlineNodes {
        if let fragment = inline as? AST.FragmentNode {
          content.append(contentsOf: fragment.children)
        } else {
          content.append(inline)
        }
      }
    }

    if foundClosing {
      return AST.SpoilerNode(
        children: content,
        sourceLocation: startLocation
      )
    } else {
      // No closing delimiter found, backtrack and treat as text
      tokenStream.setPosition(startPosition)
      return nil
    }
  }

  /// Parse Discord user mention <@123456789>
  private func parseUserMention() -> AST.UserMentionNode? {
    let token = tokenStream.consume()
    let content = token.content

    // Extract user ID from <@123456789>
    guard content.hasPrefix("<@") && content.hasSuffix(">") else {
      return nil
    }

    let idString = String(content.dropFirst(2).dropLast(1))
    let userId = UserSnowflake(idString)

    return AST.UserMentionNode(id: userId, sourceLocation: token.location)
  }

  /// Parse Discord role mention <@&123456789>
  private func parseRoleMention() -> AST.RoleMentionNode? {
    let token = tokenStream.consume()
    let content = token.content

    // Extract role ID from <@&123456789>
    guard content.hasPrefix("<@&") && content.hasSuffix(">") else {
      return nil
    }

    let idString = String(content.dropFirst(3).dropLast(1))
    let roleId = RoleSnowflake(idString)

    return AST.RoleMentionNode(id: roleId, sourceLocation: token.location)
  }

  /// Parse Discord channel mention <#123456789>
  private func parseChannelMention() -> AST.ChannelMentionNode? {
    let token = tokenStream.consume()
    let content = token.content

    // Extract channel ID from <#123456789>
    guard content.hasPrefix("<#") && content.hasSuffix(">") else {
      return nil
    }

    let idString = String(content.dropFirst(2).dropLast(1))
    let channelId = ChannelSnowflake(idString)

    return AST.ChannelMentionNode(id: channelId, sourceLocation: token.location)
  }

  /// Parse Discord @everyone mention
  private func parseEveryoneMention() -> AST.EveryoneMentionNode {
    let token = tokenStream.consume()
    return AST.EveryoneMentionNode(sourceLocation: token.location)
  }

  /// Parse Discord @here mention
  private func parseHereMention() -> AST.HereMentionNode {
    let token = tokenStream.consume()
    return AST.HereMentionNode(sourceLocation: token.location)
  }

  /// Parse Discord timestamp <t:1757847540:R>
  private func parseTimestamp() -> AST.TimestampNode? {
    let token = tokenStream.consume()
    let content = token.content

    // Extract timestamp from <t:1757847540:R>
    guard content.hasPrefix("<t:") && content.hasSuffix(">") else {
      return nil
    }

    let innerContent = String(content.dropFirst(3).dropLast(1))
    let components = innerContent.split(separator: ":")

    guard components.count == 2,
      let timestamp = Double(components[0])
    else {
      return nil
    }

    let date = Date(timeIntervalSince1970: timestamp)
    let style = AST.TimestampNode.TimestampStyle(
      rawValue: String(components[1])
    )

    return AST.TimestampNode(
      date: date,
      style: style,
      sourceLocation: token.location
    )
  }

  /// Parse Discord custom emoji <:name:123456789> or <a:name:123456789>
  private func parseCustomEmoji() -> AST.CustomEmojiNode? {
    let token = tokenStream.consume()
    let content = token.content

    // Check for animated emoji <a:name:123456789>
    var isAnimated = false
    var workingContent = content

    if content.hasPrefix("<a:") {
      isAnimated = true
      workingContent = String(content.dropFirst(3).dropLast(1))
    } else if content.hasPrefix("<:") {
      workingContent = String(content.dropFirst(2).dropLast(1))
    } else {
      return nil
    }

    // Split by : to get name and ID
    let components = workingContent.split(separator: ":")
    guard components.count == 2 else {
      return nil
    }
    let emojiId = EmojiSnowflake(String(components[1]))
    let emojiName = String(components[0])

    return AST.CustomEmojiNode(
      name: emojiName,
      identifier: emojiId,
      isAnimated: isAnimated,
      sourceLocation: token.location
    )
  }

  /// Parse Discord underline formatting __text__
  private func parseUnderline() throws -> ASTNode? {
    let startPosition = tokenStream.currentPosition
    let startLocation = tokenStream.current.location

    // Need at least two underscores to open an underline
    guard tokenStream.check(.underscore) else { return nil }

    // Consume underscores until we've consumed at least two characters (handles '__' or '_' '_')
    var openingCount = 0
    while !tokenStream.isAtEnd && tokenStream.check(.underscore) && openingCount < 3 {
      openingCount += tokenStream.current.content.count
      tokenStream.advance()
    }

    // If we didn't consume at least two underscores, it's not an underline opener
    guard openingCount >= 2 else {
      tokenStream.setPosition(startPosition)
      return nil
    }

    var content: [ASTNode] = []
    var foundClosing = false

    // Look for closing delimiter with at least the same count (2 or 3)
    while !tokenStream.isAtEnd {
      // If we see underscore tokens, check if there are enough to close
      if tokenStream.check(.underscore) {
        // Count consecutive underscores available
        var closingCount = 0
        var offset = 0
        while tokenStream.peek(offset).type == .underscore {
          closingCount += tokenStream.peek(offset).content.count
          offset += 1
        }

        if closingCount >= openingCount {
          // Consume as many tokens as needed to account for openingCount
          var remaining = openingCount
          while remaining > 0 {
            let c = tokenStream.consume()
            remaining -= c.content.count
          }
          foundClosing = true
          break
        }
      }

      // Parse content inside underline
      let inlineNodes = try parseInline()
      for inline in inlineNodes {
        if let fragment = inline as? AST.FragmentNode {
          content.append(contentsOf: fragment.children)
        } else {
          content.append(inline)
        }
      }
    }

    if foundClosing {
      return AST.UnderlineNode(children: content, sourceLocation: startLocation)
    }

    // No closing delimiter found, restore position and bail
    tokenStream.setPosition(startPosition)
    return nil
  }

  // MARK: - Text Consolidation

  /// Check if a token type should be consolidated as text
  private func shouldConsolidateAsText(_ tokenType: TokenType) -> Bool {
    switch tokenType {
    case .text, .whitespace:
      return true
    default:
      // Look ahead to see if this token will fail to parse as markdown
      // and should be consolidated with adjacent text
      return wouldFallbackToText(tokenType)
    }
  }

  /// Check if a token type would fall back to creating a text node
  private func wouldFallbackToText(_ tokenType: TokenType) -> Bool {
    switch tokenType {
    case .exclamation, .rightBracket, .leftParen, .rightParen:
      return true  // These typically become text
    default:
      return false  // Don't try to lookahead parse for other types to avoid side effects
    }
  }

  /// Parse and consolidate consecutive text-producing tokens
  private func parseConsolidatedText() throws -> AST.TextNode {
    var content = ""
    // Capture the start location from the first token we'll consume to ensure
    // the returned TextNode has an accurate SourceLocation.
    guard !tokenStream.isAtEnd else {
      return AST.TextNode(content: "", sourceLocation: nil)
    }
    let firstToken = tokenStream.current
    let startLocation = firstToken.location

    while !tokenStream.isAtEnd
      && shouldConsolidateAsText(tokenStream.current.type)
    {
      let token = tokenStream.consume()
      content += token.content
    }

    return AST.TextNode(content: content, sourceLocation: startLocation)
  }

}
