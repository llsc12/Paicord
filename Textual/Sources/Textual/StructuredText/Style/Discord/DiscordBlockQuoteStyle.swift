import SwiftUI

extension StructuredText {
  /// A block quote style inspired by Discord's rendering: a single vertical bar with no
  /// nesting indentation, matching Discord's actual behavior (blockquotes never nest — see
  /// `DiscordMarkdown.preprocess(_:)`).
  public struct DiscordBlockQuoteStyle: BlockQuoteStyle {
    /// Creates the Discord block quote style.
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
      HStack(spacing: 0) {
        RoundedRectangle(cornerRadius: 2)
          .fill(DynamicColor.discordBlockQuoteBar)
          .textual.frame(width: .fontScaled(0.28))
        configuration.label
          .textual.padding(.leading, .fontScaled(0.8))
      }
    }
  }
}

extension StructuredText.BlockQuoteStyle where Self == StructuredText.DiscordBlockQuoteStyle {
  /// A Discord-like block quote style.
  public static var discord: Self {
    .init()
  }
}

#Preview {
  StructuredText(
    markdown: """
      hello **world**
      > wagwan
      """
  )
  .padding()
  .textual.blockQuoteStyle(.discord)
}
