import SwiftUI

extension AttributeScopes {
  /// Attributes used by Textual when parsing and rendering markup.
  public struct TextualAttributes: AttributeScope {
    /// Stores an attachment value in attributed content.
    public enum AttachmentAttribute: AttributedStringKey {
      public typealias Value = AnyAttachment
      public static let name = "Textual.Attachment"
    }

    /// Stores a URL for a custom emoji placeholder.
    ///
    /// Textual uses this attribute as an intermediate representation before resolving emoji into
    /// an attachment.
    public enum EmojiURLAttribute: AttributedStringKey {
      public typealias Value = URL
      public static let name = "Textual.EmojiURL"
    }

    /// Marks a link as having no preview embed (for example, Discord's `<https://url>` syntax).
    public enum NoEmbedAttribute: AttributedStringKey {
      public typealias Value = Bool
      public static let name = "Textual.NoEmbed"
    }

    /// Marks a span as subtext (for example, Discord's `-# ` syntax).
    ///
    /// This only marks the span — actual styling (size, color) is applied by ``InlineStyle``'s
    /// `subtext` property, which has access to the render-time environment (parse-time
    /// `SyntaxExtension`s don't), so it responds correctly to things like ``TextualNamespace/fontScale(_:)``.
    public enum SubtextAttribute: AttributedStringKey {
      public typealias Value = Bool
      public static let name = "Textual.Subtext"
    }

    /// Marks a `.link`-attributed span (for example, a Discord mention or a revealed spoiler)
    /// whose foreground/background colors were already set at parse time and shouldn't be
    /// recolored by ``InlineStyle``'s `link` property at render time.
    public enum PreStyledLinkAttribute: AttributedStringKey {
      public typealias Value = Bool
      public static let name = "Textual.PreStyledLink"
    }

    /// Overrides a run's plain-text export (copy, share, drag) with different text than what's
    /// actually rendered.
    public enum CopyTextAttribute: AttributedStringKey {
      public typealias Value = String
      public static let name = "Textual.CopyText"
    }

    /// A property for accessing an attachment attribute.
    public let attachment: AttachmentAttribute

    /// A property for accessing an emoji URL attribute.
    public let emojiURL: EmojiURLAttribute

    /// A property for accessing the no-embed attribute.
    public let noEmbed: NoEmbedAttribute

    /// A property for accessing the subtext attribute.
    public let subtext: SubtextAttribute

    /// A property for accessing the pre-styled-link attribute.
    public let preStyledLink: PreStyledLinkAttribute

    /// A property for accessing the copy-text attribute.
    public let copyText: CopyTextAttribute

    public let foundation: AttributeScopes.FoundationAttributes
  }

  /// The Textual attribute scope.
  public var textual: TextualAttributes.Type {
    TextualAttributes.self
  }
}

extension AttributeDynamicLookup {
  /// Provides dynamic member lookup for Textual attributes.
  public subscript<T: AttributedStringKey>(
    dynamicMember keyPath: KeyPath<AttributeScopes.TextualAttributes, T>
  ) -> T {
    return self[T.self]
  }
}
