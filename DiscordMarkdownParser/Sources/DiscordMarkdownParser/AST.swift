/// Abstract Syntax Tree (AST) definitions for markdown parsing
///
/// This file defines the core AST node types and structures used throughout
/// the markdown parser. The AST provides a renderer-agnostic representation
/// of parsed markdown documents.

import DiscordModels
import Foundation

// MARK: - Core AST Protocol

/// Base protocol for all AST nodes
public protocol ASTNode: Sendable {
	/// The type of this AST node
	var nodeType: ASTNodeType { get }

	/// Child nodes (if any)
	var children: [ASTNode] { get }

	/// Source location information
	var sourceLocation: SourceLocation? { get }
}

/// Types of AST nodes
public struct ASTNodeType: RawRepresentable, Hashable, Sendable {
	public let rawValue: String

	public init(rawValue: String) {
		self.rawValue = rawValue
	}

	// Document structure
	public static let document = ASTNodeType(rawValue: "document")

	// Block elements
	public static let paragraph = ASTNodeType(rawValue: "paragraph")
	public static let heading = ASTNodeType(rawValue: "heading")
	public static let blockQuote = ASTNodeType(rawValue: "blockQuote")
	public static let list = ASTNodeType(rawValue: "list")
	public static let listItem = ASTNodeType(rawValue: "listItem")
	public static let codeBlock = ASTNodeType(rawValue: "codeBlock")
	public static let thematicBreak = ASTNodeType(rawValue: "thematicBreak")

	// Inline elements
	public static let text = ASTNodeType(rawValue: "text")
	public static let italic = ASTNodeType(rawValue: "italic")
	public static let bold = ASTNodeType(rawValue: "bold")
	public static let link = ASTNodeType(rawValue: "link")
	public static let codeSpan = ASTNodeType(rawValue: "codeSpan")
	public static let lineBreak = ASTNodeType(rawValue: "lineBreak")
	public static let strikethrough = ASTNodeType(rawValue: "strikethrough")
	// Inline elements Discord specific
	public static let underline = ASTNodeType(rawValue: "underline")
	public static let spoiler = ASTNodeType(rawValue: "spoiler")
	public static let footnote = ASTNodeType(rawValue: "footnote")
	public static let customEmoji = ASTNodeType(rawValue: "customEmoji")
	public static let userMention = ASTNodeType(rawValue: "userMention")
	public static let roleMention = ASTNodeType(rawValue: "roleMention")
	public static let channelMention = ASTNodeType(rawValue: "channelMention")
	public static let everyoneMention = ASTNodeType(rawValue: "everyoneMention")
	public static let hereMention = ASTNodeType(rawValue: "hereMention")
	public static let timestamp = ASTNodeType(rawValue: "timestamp")

	// GFM Extensions
	public static let autolink = ASTNodeType(rawValue: "autolink")
}

extension ASTNodeType {
	public var isBlock: Bool {
		switch self {
		case .document, .paragraph, .heading, .blockQuote, .list, .listItem,
			.codeBlock, .thematicBreak:
			return true
		default:
			return false
		}
	}

	public var isInline: Bool {
		!isBlock
	}
}

// MARK: - Source Location

/// Represents a location in the source markdown text
public struct SourceLocation: Sendable, Equatable, Hashable {
	/// Line number (1-based)
	public let line: Int

	/// Column number (1-based)
	public let column: Int

	/// Character offset from start of document (0-based)
	public let offset: Int

	public init(line: Int, column: Int, offset: Int) {
		self.line = line
		self.column = column
		self.offset = offset
	}
}

// MARK: - AST Namespace

/// Namespace for AST node implementations
public enum AST {

	// MARK: - Document Structure

	/// Root document node
	public struct DocumentNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .document
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	// MARK: - Block Elements

	/// Paragraph node
	public struct ParagraphNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .paragraph
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Heading node (ATX or Setext)
	public struct HeadingNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .heading
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		/// Heading level (1-6)
		public let level: Int

		public init(
			level: Int,
			children: [ASTNode],
			sourceLocation: SourceLocation? = nil
		) {
			self.level = level
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Block quote node
	public struct BlockQuoteNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .blockQuote
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// List container node
	public struct ListNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .list
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		/// Whether this is an ordered list
		public let isOrdered: Bool

		/// Starting number for ordered lists
		public let startNumber: Int?

		/// List items
		public let items: [ASTNode]

		public init(
			isOrdered: Bool,
			startNumber: Int? = nil,
			items: [ASTNode],
			sourceLocation: SourceLocation? = nil
		) {
			self.isOrdered = isOrdered
			self.startNumber = startNumber
			self.items = items
			self.sourceLocation = sourceLocation
			self.children = items
		}
	}

	/// List item node
	public struct ListItemNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .listItem
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Code block node (fenced or indented)
	public struct CodeBlockNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .codeBlock
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// Code content
		public let content: String

		/// Programming language (for fenced blocks)
		public let language: String?

		/// Info string (for fenced blocks)
		public let info: String?

		/// Whether this is a fenced code block
		public let isFenced: Bool

		public init(
			content: String,
			language: String? = nil,
			info: String? = nil,
			isFenced: Bool = false,
			sourceLocation: SourceLocation? = nil
		) {
			self.content = content
			self.language = language
			self.info = info
			self.isFenced = isFenced
			self.sourceLocation = sourceLocation
		}
	}

	// MARK: - Inline Elements

	/// Plain text node
	public struct TextNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .text
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// Text content
		public let content: String

		public init(content: String, sourceLocation: SourceLocation? = nil) {
			self.content = content
			self.sourceLocation = sourceLocation
		}
	}

	/// italic node
	public struct ItalicNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .italic
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Bold node
	public struct BoldNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .bold
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Link node
	public struct LinkNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .link
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		/// Link URL
		public let url: String

		/// Link title (optional)
		public let title: String?

		public init(
			url: String,
			title: String? = nil,
			children: [ASTNode],
			sourceLocation: SourceLocation? = nil
		) {
			self.url = url
			self.title = title
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Image node
	//  public struct ImageNode: ASTNode, Sendable {
	//    public let nodeType: ASTNodeType = .image
	//    public let children: [ASTNode] = []
	//    public let sourceLocation: SourceLocation?
	//
	//    /// Image URL
	//    public let url: String
	//
	//    /// Alt text
	//    public let altText: String
	//
	//    /// Image title (optional)
	//    public let title: String?
	//
	//    public init(
	//      url: String, altText: String, title: String? = nil,
	//      sourceLocation: SourceLocation? = nil
	//    ) {
	//      self.url = url
	//      self.altText = altText
	//      self.title = title
	//      self.sourceLocation = sourceLocation
	//    }
	//  }

	/// Inline code span node
	public struct CodeSpanNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .codeSpan
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// Code content
		public let content: String

		public init(content: String, sourceLocation: SourceLocation? = nil) {
			self.content = content
			self.sourceLocation = sourceLocation
		}
	}

	/// Line break node
	public struct LineBreakNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .lineBreak
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// Whether this is a hard break (two spaces + newline)
		public let isHard: Bool

		public init(isHard: Bool = false, sourceLocation: SourceLocation? = nil) {
			self.isHard = isHard
			self.sourceLocation = sourceLocation
		}
	}

	/// Strikethrough node (GFM extension)
	public struct StrikethroughNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .strikethrough
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		/// Content to be struck through
		public let content: [ASTNode]

		public init(content: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.content = content
			self.children = content
			self.sourceLocation = sourceLocation
		}
	}

	/// Autolink node (GFM extension)
	public struct AutolinkNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .autolink
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// The URL
		public let url: String

		/// Display text
		public let text: String

		public init(
			url: String,
			text: String,
			sourceLocation: SourceLocation? = nil
		) {
			self.url = url
			self.text = text
			self.sourceLocation = sourceLocation
		}
	}

	/// Underline node (Discord specific)
	public struct UnderlineNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .underline
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Spoiler node (Discord specific)
	public struct SpoilerNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .spoiler
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Custom emoji node (Discord specific)
	public struct CustomEmojiNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .customEmoji
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// Emoji name
		public let name: String

		/// Emoji identifier
		public let identifier: EmojiSnowflake

		/// Whether the emoji is animated
		public let isAnimated: Bool

		public init(
			name: String,
			identifier: EmojiSnowflake,
			isAnimated: Bool = false,
			sourceLocation: SourceLocation? = nil
		) {
			self.name = name
			self.identifier = identifier
			self.isAnimated = isAnimated
			self.sourceLocation = sourceLocation
		}
	}

	/// User mention node (Discord specific)
	public struct UserMentionNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .userMention
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// User identifier
		public let id: UserSnowflake

		init(id: UserSnowflake, sourceLocation: SourceLocation? = nil) {
			self.id = id
			self.sourceLocation = sourceLocation
		}
	}

	/// Role mention node (Discord specific)
	public struct RoleMentionNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .roleMention
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// Role identifier
		public let id: RoleSnowflake

		public init(id: RoleSnowflake, sourceLocation: SourceLocation? = nil) {
			self.id = id
			self.sourceLocation = sourceLocation
		}
	}

	/// Channel mention node (Discord specific)
	public struct ChannelMentionNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .channelMention
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		public let id: ChannelSnowflake

		public init(id: ChannelSnowflake, sourceLocation: SourceLocation? = nil) {
			self.id = id
			self.sourceLocation = sourceLocation
		}
	}

	/// Everyone mention node (Discord specific)
	public struct EveryoneMentionNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .everyoneMention
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		public init(sourceLocation: SourceLocation? = nil) {
			self.sourceLocation = sourceLocation
		}
	}

	/// Here mention node (Discord specific)
	public struct HereMentionNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .hereMention
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		public init(sourceLocation: SourceLocation? = nil) {
			self.sourceLocation = sourceLocation
		}
	}

	/// Timestamp node (Discord specific)
	public struct TimestampNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .timestamp
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		/// The date to display
		public let date: Date

		/// The style to use for displaying the timestamp
		public let style: TimestampStyle?

		public init(
			date: Date,
			style: TimestampStyle? = nil,
			sourceLocation: SourceLocation? = nil
		) {
			self.date = date
			self.style = style
			self.sourceLocation = sourceLocation
		}

		public enum TimestampStyle: String, Sendable {
			// Relative <t:1757847540:R>
			// Short time <t:1757847540:t>
			// Long time <t:1757847540:T>
			// Short date <t:1757847540:d>
			// Long date <t:1757847540:D>
			// Long date short time <t:1757847540:f>
			// Long date with day of week short time <t:1757847540:F>

			case relative = "R"
			case shortTime = "t"
			case longTime = "T"
			case shortDate = "d"
			case longDate = "D"
			case longDateShortTime = "f"
			case longDateWeekDayShortTime = "F"
		}
	}

	/// HTML block node
	//  public struct HTMLBlockNode: ASTNode, Sendable {
	//    public let nodeType: ASTNodeType = .htmlBlock
	//    public let children: [ASTNode] = []
	//    public let sourceLocation: SourceLocation?
	//
	//    /// HTML content
	//    public let content: String
	//
	//    public init(content: String, sourceLocation: SourceLocation? = nil) {
	//      self.content = content
	//      self.sourceLocation = sourceLocation
	//    }
	//  }

	/// Inline HTML node
	//  public struct HTMLInlineNode: ASTNode, Sendable {
	//    public let nodeType: ASTNodeType = .htmlInline
	//    public let children: [ASTNode] = []
	//    public let sourceLocation: SourceLocation?
	//
	//    /// HTML content
	//    public let content: String
	//
	//    public init(content: String, sourceLocation: SourceLocation? = nil) {
	//      self.content = content
	//      self.sourceLocation = sourceLocation
	//    }
	//  }

	/// Soft line break node
	public struct SoftBreakNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .lineBreak
		public let children: [ASTNode] = []
		public let sourceLocation: SourceLocation?

		public init(sourceLocation: SourceLocation? = nil) {
			self.sourceLocation = sourceLocation
		}
	}

	/// A temporary node to hold a fragment of other nodes during parsing.
	/// This should be flattened and removed from the final AST.
	public struct FragmentNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .text  // Behaves like text for most purposes
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}

	/// Footnote header node (Discord '-# ...' syntax)
	public struct FootnoteNode: ASTNode, Sendable {
		public let nodeType: ASTNodeType = .footnote
		public let children: [ASTNode]
		public let sourceLocation: SourceLocation?

		public init(children: [ASTNode], sourceLocation: SourceLocation? = nil) {
			self.children = children
			self.sourceLocation = sourceLocation
		}
	}
}
