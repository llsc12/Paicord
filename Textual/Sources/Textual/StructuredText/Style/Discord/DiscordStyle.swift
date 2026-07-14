import SwiftUI

extension StructuredText {
  /// A Discord-like set of styles for structured text.
  ///
  /// Apply this style with ``TextualNamespace/structuredTextStyle(_:)``. Pass the message
  /// content through `DiscordMarkdown.preprocess(_:)` first, and add the Discord
  /// `SyntaxExtension`s (mentions, custom emoji, timestamps, no-embed links, spoilers, subtext)
  /// you need — this style only covers block-level appearance.
  public struct DiscordStyle: Style {
    public let inlineStyle: InlineStyle = .discord
    public let headingStyle: DiscordHeadingStyle = .discord
    public let paragraphStyle: DefaultParagraphStyle = .default
    public let blockQuoteStyle: DiscordBlockQuoteStyle = .discord
    public let codeBlockStyle: DiscordCodeBlockStyle = .discord
    public let listItemStyle: DefaultListItemStyle = .default
    public let unorderedListMarker: HierarchicalSymbolListMarker = .init(
      .disc, .circle, clamps: true)
    public let orderedListMarker: DecimalListMarker = .decimal
    public let tableStyle: DefaultTableStyle = .default
    public let tableCellStyle: DefaultTableCellStyle = .default
    public let thematicBreakStyle: DividerThematicBreakStyle = .divider

    public init() {}
  }
}

extension StructuredText.Style where Self == StructuredText.DiscordStyle {
  /// A Discord-like structured text style.
  public static var discord: Self {
    .init()
  }
}
