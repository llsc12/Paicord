import SwiftUI

extension InlineStyle {
  /// An inline style inspired by Discord's rendering: Discord's "blurple" link color, and a
  /// slightly smaller monospaced font for inline code, matching ``InlineStyle/default``.
  public static var discord: InlineStyle {
    InlineStyle()
      .code(.monospaced, .fontScale(0.94))
      .strong(.fontWeight(.semibold))
      .link(.foregroundColor(.discordBlurple))
      .subtext(.fontScale(0.75), .foregroundColor(.secondary))
  }
}

extension DynamicColor {
  static let discordBlurple = DynamicColor(
    Color(red: 88 / 255, green: 101 / 255, blue: 242 / 255)
  )
}
