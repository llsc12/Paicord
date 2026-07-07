import SwiftUI

/// Properties that control how Textual renders custom emoji.
///
/// Use `EmojiProperties` to control the emoji’s size and baseline alignment relative to the
/// surrounding text.
///
/// Values are font-relative, so they scale with the current font size.
///
/// You can set these properties using the ``TextualNamespace/emojiProperties(_:)`` modifier.
public struct EmojiProperties: Sendable, Hashable {
  /// The emoji size, expressed as a font-relative value.
  public var size: FontScaled<CGSize>

  /// The emoji baseline offset, expressed as a font-relative value.
  public var baselineOffset: FontScaled<CGFloat>

  /// A floor on the resolved (post font-scaling) emoji size, in points. `size` still scales with
  /// the environment font as usual; this only raises the result up to `minimumSize` when the
  /// scaled value would otherwise fall short of it — it never shrinks anything down.
  public var minimumSize: CGSize?

  /// Creates emoji properties with a custom size and baseline offset.
  public init(
    size: FontScaled<CGSize> = .fontScaled(width: 1, height: 1),
    baselineOffset: FontScaled<CGFloat> = .fontScaled(-0.1),
    minimumSize: CGSize? = nil
  ) {
    self.size = size
    self.baselineOffset = baselineOffset
    self.minimumSize = minimumSize
  }
}

extension EmojiProperties {
  /// Resolves `size` against `environment`, then raises it up to `minimumSize` if set.
  func resolvedSize(in environment: TextEnvironmentValues) -> CGSize {
    var resolved = size.resolve(in: environment)
    if let minimumSize {
      resolved.width = max(resolved.width, minimumSize.width)
      resolved.height = max(resolved.height, minimumSize.height)
    }
    return resolved
  }
}

private struct EmojiPropertiesKey: EnvironmentKey {
  static let defaultValue = EmojiProperties()
}

extension EnvironmentValues {
  var emojiProperties: EmojiProperties {
    get { self[EmojiPropertiesKey.self] }
    set { self[EmojiPropertiesKey.self] = newValue }
  }
}
