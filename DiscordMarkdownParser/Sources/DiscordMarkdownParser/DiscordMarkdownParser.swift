// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A Swift package for parsing Markdown text into AST (Abstract Syntax Tree).
///
/// This package provides a lightweight, Swift-native solution for parsing
/// Markdown documents into a structured AST that can be rendered to various
/// output formats including HTML, SwiftUI, and more.
import Foundation

// MARK: - Error Types

/// Errors that can occur during markdown parsing
public enum MarkdownParsingError: Error, Sendable {
  case invalidTableStructure(String)
  case invalidInput(String)
  case tokenizationFailed(String)
  case parsingFailed(String)
  case invalidASTConstruction(String)
}

/// The main entry point for the Swift Markdown Parser.
///
/// This class provides methods to parse Markdown text into an AST that can
/// be consumed by various renderers for different output formats.
public final class DiscordMarkdownParser: Sendable {

  /// Configuration options for the parser
  public struct Configuration: Sendable {

    /// Maximum nesting depth for recursive elements
    public let maxNestingDepth: Int

    /// Enable source location tracking for debugging
    public let trackSourceLocations: Bool

    /// Maximum parsing time in seconds (0 = no limit)
    public let maxParsingTime: TimeInterval

    public init(
      enableGFMExtensions: Bool = true,
      strictMode: Bool = false,
      maxNestingDepth: Int = 100,
      trackSourceLocations: Bool = false,
      maxParsingTime: TimeInterval = 30.0
    ) {
      self.maxNestingDepth = maxNestingDepth
      self.trackSourceLocations = trackSourceLocations
      self.maxParsingTime = maxParsingTime
    }

    public static let `default` = Configuration()
  }

  private let configuration: Configuration

  /// Creates a new instance of the markdown parser.
  /// - Parameter configuration: Parser configuration options
  public init(configuration: Configuration = .default) {
    self.configuration = configuration
  }

  /// Parses the given Markdown text and returns an AST representation.
  ///
  /// - Parameter markdown: The Markdown text to parse
  /// - Returns: A `DocumentNode` containing the parsed AST structure
  /// - Throws: `MarkdownParserError` if parsing fails
  public func parseToAST(_ markdown: String) async throws -> AST.DocumentNode {
    let tokenizer = MarkdownTokenizer(markdown)
    let tokenStream = TokenStream(tokenizer.tokenize())

    let blockParser = BlockParser(
      tokenStream: tokenStream,
      configuration: configuration
    )
    let document = try blockParser.parseDocument()

    let inlineParser = InlineParser(
      tokenStream: tokenStream,
      configuration: configuration
    )

    // Post-process AST to resolve inline content
    let processedDocument = try await processNodeForInlineContent(
      document,
      using: inlineParser
    )

    guard let finalDocument = processedDocument as? AST.DocumentNode else {
      throw MarkdownParsingError.invalidASTConstruction(
        "Root node must be a DocumentNode"
      )
    }

    return finalDocument
  }

  /// Process AST nodes to parse inline content and GFM extensions
  private func processNodesForInlineContent(
    _ nodes: [ASTNode],
    using inlineParser: InlineParser
  ) async throws -> [ASTNode] {
    var processedNodes: [ASTNode] = []

    for node in nodes {
      let processedNode = try await processNodeForInlineContent(
        node,
        using: inlineParser
      )
      processedNodes.append(processedNode)
    }

    return processedNodes
  }

  /// Process a single AST node for inline content and GFM extensions
  private func processNodeForInlineContent(
    _ node: ASTNode,
    using inlineParser: InlineParser
  ) async throws -> ASTNode {

    if let fragment = node as? AST.FragmentNode {
      let processedChildren = try await processNodesForInlineContent(
        fragment.children,
        using: inlineParser
      )
      return AST.FragmentNode(
        children: processedChildren,
        sourceLocation: fragment.sourceLocation
      )
    }

    switch node.nodeType {
    case .paragraph:
      if let paragraphNode = node as? AST.ParagraphNode {
        return try await processParagraphForInlineContent(
          paragraphNode,
          using: inlineParser
        )
      }

    case .heading:
      if let headingNode = node as? AST.HeadingNode {
        return try await processHeadingForInlineContent(
          headingNode,
          using: inlineParser
        )
      }

    case .blockQuote:
      if let blockQuoteNode = node as? AST.BlockQuoteNode {
        let processedChildren = try await processNodesForInlineContent(
          blockQuoteNode.children,
          using: inlineParser
        )
        return AST.BlockQuoteNode(
          children: processedChildren,
          sourceLocation: blockQuoteNode.sourceLocation
        )
      }

    case .list:
      if let listNode = node as? AST.ListNode {
        return try await processListForInlineContent(
          listNode,
          using: inlineParser
        )
      }

    case .listItem:
      if let listItemNode = node as? AST.ListItemNode {
        return try await processListItemForInlineContent(
          listItemNode,
          using: inlineParser
        )
      }

    //    case .taskListItem:
    //      if let taskListItemNode = node as? AST.GFMTaskListItemNode {
    //        return try await processTaskListItemForInlineContent(
    //          taskListItemNode, using: inlineParser)
    //      }

    default:
      // For other node types, process children if they exist
      if !node.children.isEmpty {
        let processedChildren = try await processNodesForInlineContent(
          node.children,
          using: inlineParser
        )
        return createNodeWithProcessedChildren(
          node,
          children: processedChildren
        )
      }
    }

    return node
  }

  /// Process paragraph for inline content and GFM extensions
  private func processParagraphForInlineContent(
    _ paragraph: AST.ParagraphNode,
    using inlineParser: InlineParser
  ) async throws -> ASTNode {
    // Parse inline content with GFM extensions
    let inlineNodes = try await parseInlineContentWithGFM(
      paragraph.children,
      using: inlineParser
    )

    return AST.ParagraphNode(
      children: inlineNodes,
      sourceLocation: paragraph.sourceLocation
    )
  }

  /// Process heading for inline content
  private func processHeadingForInlineContent(
    _ heading: AST.HeadingNode,
    using inlineParser: InlineParser
  ) async throws -> ASTNode {
    let inlineNodes = try await parseInlineContentWithGFM(
      heading.children,
      using: inlineParser
    )

    return AST.HeadingNode(
      level: heading.level,
      children: inlineNodes,
      sourceLocation: heading.sourceLocation
    )
  }

  /// Process list for GFM task lists and inline content
  private func processListForInlineContent(
    _ list: AST.ListNode,
    using inlineParser: InlineParser
  ) async throws -> ASTNode {
    var processedItems: [ASTNode] = []

    for item in list.items {
      // Check if this is a task list item
      if let listItemNode = item as? AST.ListItemNode,
        listItemNode.children.first as? AST.ParagraphNode != nil
      {
        // Regular list item - process normally
        let processedItem = try await processListItemForInlineContent(
          listItemNode,
          using: inlineParser
        )
        processedItems.append(processedItem)
      } else {
        // Regular list item (not containing a paragraph or different structure)
        let processedItem = try await processNodeForInlineContent(
          item,
          using: inlineParser
        )
        processedItems.append(processedItem)
      }
    }

    return AST.ListNode(
      isOrdered: list.isOrdered,
      startNumber: list.startNumber,
      level: list.level,
      items: processedItems,
      sourceLocation: list.sourceLocation
    )
  }

  /// Process list item for inline content
  private func processListItemForInlineContent(
    _ listItem: AST.ListItemNode,
    using inlineParser: InlineParser
  ) async throws -> ASTNode {
    let processedChildren = try await processNodesForInlineContent(
      listItem.children,
      using: inlineParser
    )

    return AST.ListItemNode(
      itemNumber: listItem.listNumber,
      children: processedChildren,
      sourceLocation: listItem.sourceLocation
    )
  }

  /// Extract task content from paragraph, preserving inline formatting but removing task list marker
  private func extractTaskContentFromParagraph(_ paragraph: AST.ParagraphNode)
    -> [ASTNode]
  {
    var result: [ASTNode] = []
    var foundTaskMarker = false

    for node in paragraph.children {
      if !foundTaskMarker {
        // Look for the task marker pattern: [x], [ ], etc.
        if let textNode = node as? AST.TextNode {
          let content = textNode.content
          // Check if this text node contains a task marker
          if content.contains("[") && (content.contains("]") || result.isEmpty) {
            // This might be the start of a task marker
            if content.hasPrefix("[") && content.count >= 3
              && content.hasSuffix("]")
            {
              // This is a complete task marker like "[x]"
              foundTaskMarker = true
              continue
            } else if content == "[" {
              // This might be the start of a split task marker
              foundTaskMarker = true
              continue
            }
          }

          // Skip the first whitespace after finding task marker
          if foundTaskMarker
            && content.trimmingCharacters(in: .whitespaces).isEmpty
            && result.isEmpty
          {
            continue
          }
        }

        // If we haven't found the task marker yet, skip this node
        if !foundTaskMarker {
          continue
        }
      }

      // Add all nodes after the task marker
      result.append(node)
    }

    return result
  }

  /// Parse inline content with GFM extensions (strikethrough, autolinks)
  private func parseInlineContentWithGFM(
    _ nodes: [ASTNode],
    using inlineParser: InlineParser
  ) async throws -> [ASTNode] {
    var result: [ASTNode] = []

    for node in nodes {
      if let textNode = node as? AST.TextNode {
        let enhancedNodes = try await parseGFMInlineExtensions(
          textNode.content,
          using: inlineParser
        )
        result.append(contentsOf: enhancedNodes)
      } else {
        // Process children if they exist
        if !node.children.isEmpty {
          let processedChildren = try await parseInlineContentWithGFM(
            node.children,
            using: inlineParser
          )
          let newNode = createNodeWithProcessedChildren(
            node,
            children: processedChildren
          )
          result.append(newNode)
        } else {
          result.append(node)
        }
      }
    }

    return result
  }

  /// Parse GFM inline extensions (strikethrough, autolinks) in text
  private func parseGFMInlineExtensions(
    _ text: String,
    using inlineParser: InlineParser
  ) async throws -> [ASTNode] {
    // First parse regular inline content
    var nodes = try inlineParser.parseInlineContent(text)

    // Then enhance with GFM extensions
    nodes = try await enhanceWithStrikethrough(nodes, using: inlineParser)
    nodes = try await enhanceWithAutolinks(nodes, using: inlineParser)

    return nodes
  }

  /// Enhance nodes with strikethrough parsing
  private func enhanceWithStrikethrough(
    _ nodes: [ASTNode],
    using inlineParser: InlineParser
  ) async throws -> [ASTNode] {
    var result: [ASTNode] = []

    for node in nodes {
      if let textNode = node as? AST.TextNode,
        GFMUtils.containsStrikethrough(textNode.content)
      {

        let strikethroughNodes = inlineParser.parseGFMStrikethrough(
          textNode.content
        )
        if !strikethroughNodes.isEmpty {
          result.append(contentsOf: strikethroughNodes)
        } else {
          result.append(node)
        }
      } else {
        result.append(node)
      }
    }

    return result
  }

  /// Enhance nodes with autolink parsing
  private func enhanceWithAutolinks(
    _ nodes: [ASTNode],
    using inlineParser: InlineParser
  ) async throws -> [ASTNode] {
    var result: [ASTNode] = []

    for node in nodes {
      if let textNode = node as? AST.TextNode,
        GFMUtils.containsAutolinks(textNode.content)
      {

        let autolinkNodes = inlineParser.parseGFMAutolinks(textNode.content)
        if !autolinkNodes.isEmpty {
          result.append(contentsOf: autolinkNodes)
        } else {
          result.append(node)
        }
      } else {
        result.append(node)
      }
    }

    return result
  }

  /// Create a new node with processed children
  private func createNodeWithProcessedChildren(
    _ originalNode: ASTNode,
    children: [ASTNode]
  ) -> ASTNode {
    switch originalNode.nodeType {
    case .document:
      if let documentNode = originalNode as? AST.DocumentNode {
        return AST.DocumentNode(
          children: children,
          sourceLocation: documentNode.sourceLocation
        )
      }

    case .paragraph:
      if let paragraphNode = originalNode as? AST.ParagraphNode {
        return AST.ParagraphNode(
          children: children,
          sourceLocation: paragraphNode.sourceLocation
        )
      }

    case .heading:
      if let headingNode = originalNode as? AST.HeadingNode {
        return AST.HeadingNode(
          level: headingNode.level,
          children: children,
          sourceLocation: headingNode.sourceLocation
        )
      }

    case .blockQuote:
      if let blockQuoteNode = originalNode as? AST.BlockQuoteNode {
        return AST.BlockQuoteNode(
          children: children,
          sourceLocation: blockQuoteNode.sourceLocation
        )
      }

    case .listItem:
      if let listItemNode = originalNode as? AST.ListItemNode {
        return AST.ListItemNode(
          itemNumber: listItemNode.listNumber,
          children: children,
          sourceLocation: listItemNode.sourceLocation
        )
      }

    case .italic:
      if let italicNode = originalNode as? AST.ItalicNode {
        return AST.ItalicNode(
          children: children,
          sourceLocation: italicNode.sourceLocation
        )
      }

    case .bold:
      if let boldNode = originalNode as? AST.BoldNode {
        return AST.BoldNode(
          children: children,
          sourceLocation: boldNode.sourceLocation
        )
      }

    case .link:
      if let linkNode = originalNode as? AST.LinkNode {
        return AST.LinkNode(
          url: linkNode.url,
          title: linkNode.title,
          children: children,
          sourceLocation: linkNode.sourceLocation
        )
      }

    default:
      // For unknown node types, return original
      return originalNode
    }

    return originalNode
  }
}

// MARK: - Parser Errors

/// Errors that can occur during markdown parsing
public enum MarkdownParserError: Error, LocalizedError, Sendable {
  case invalidInput(String)
  case nestingTooDeep(Int)
  case malformedMarkdown(String, SourceLocation?)
  case unsupportedFeature(String)
  case internalError(String)

  public var errorDescription: String? {
    switch self {
    case .invalidInput(let message):
      return "Invalid input: \(message)"
    case .nestingTooDeep(let depth):
      return "Nesting too deep: \(depth) levels"
    case .malformedMarkdown(let message, let location):
      if let location = location {
        return
          "Malformed markdown at line \(location.line), column \(location.column): \(message)"
      } else {
        return "Malformed markdown: \(message)"
      }
    case .unsupportedFeature(let feature):
      return "Unsupported feature: \(feature)"
    case .internalError(let message):
      return "Internal parser error: \(message)"
    }
  }
}

/// Link reference definition
public struct LinkReference: Sendable, Equatable {
  /// The URL of the link
  public let url: String

  /// Optional title for the link
  public let title: String?

  /// Source location where the reference was defined
  public let sourceLocation: SourceLocation?

  public init(
    url: String,
    title: String? = nil,
    sourceLocation: SourceLocation? = nil
  ) {
    self.url = url
    self.title = title
    self.sourceLocation = sourceLocation
  }
}

extension AST.DocumentNode {
  /// Tests for Discord emojis and normal emojis and spaces. If any other characters exist, this will return false.
  /// - Returns: True if the document contains only emojis and spaces, false otherwise.
  public func isEmojisOnly() -> Bool {
    for child in children {
      if let paragraph = child as? AST.ParagraphNode {
        for inline in paragraph.children {
          if let textNode = inline as? AST.TextNode {
            let content = textNode.content
            for scalar in content.unicodeScalars {
              if !scalar.properties.isEmoji
                && !CharacterSet.whitespacesAndNewlines.contains(scalar)
              {
                return false
              }
            }
          } else if inline is AST.CustomEmojiNode {
            // Valid custom emoji, continue
            continue
          } else {
            // Other inline node types are not allowed
            return false
          }
        }
      } else {
        // Other block node types are not allowed
        return false
      }
    }
    return true
  }
}
