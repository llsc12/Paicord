import SwiftUI

/// Styling for a rounded background drawn behind any inline run that has a `backgroundColor`
/// attribute — inline code spans (`` `code` ``) and custom entities from a `SyntaxExtension`
/// (mentions, tags, etc.) alike.
///
/// A plain `.backgroundColor(_:)` bakes its color straight into the `AttributedString`, which
/// `Text` paints as a flat rectangle following each line's glyph bounds — there's no way to round
/// that. When this style is set, Textual instead strips that flat attribute before building
/// `Text` and redraws it as a separate shape positioned using the resolved `Text.Layout` — the
/// same technique ``TextSelectionBackground`` and the emoji attachment overlay use — so it can
/// have rounded corners. Each run keeps its own color (e.g. a role-colored mention next to a
/// plain code span), only the corner radius is shared.
///
/// Apply it with ``TextualNamespace/roundedBackgroundStyle(_:)``:
///
/// ```swift
/// InlineText(markdown: "Use `git status` to check changes")
///   .textual.inlineStyle(InlineStyle().code(.backgroundColor(DynamicColor(.gray.opacity(0.2)))))
///   .textual.roundedBackgroundStyle(RoundedBackgroundStyle())
/// ```
public struct RoundedBackgroundStyle: Sendable, Hashable {
  /// The background's corner radius, in points.
  public var cornerRadius: CGFloat

  /// Extra breathing room between the run's glyph bounds and the background's edge, in points.
  public var padding: CGFloat

  /// Creates a rounded background style.
  public init(cornerRadius: CGFloat = 4, padding: CGFloat = 2) {
    self.cornerRadius = cornerRadius
    self.padding = padding
  }
}

private struct RoundedBackgroundStyleKey: EnvironmentKey {
  static let defaultValue: RoundedBackgroundStyle? = nil
}

extension EnvironmentValues {
  var roundedBackgroundStyle: RoundedBackgroundStyle? {
    get { self[RoundedBackgroundStyleKey.self] }
    set { self[RoundedBackgroundStyleKey.self] = newValue }
  }
}
