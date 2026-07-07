import SwiftUI

extension StructuredText {
  /// A heading style inspired by Discord's rendering.
  public struct DiscordHeadingStyle: HeadingStyle {
    private static let fontScales: [CGFloat] = [1.5, 1.25, 1.1]

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
      let headingLevel = min(configuration.headingLevel, Self.fontScales.count)
      let fontScale = Self.fontScales[headingLevel - 1]

      configuration.label
        .textual.fontScale(fontScale)
        .fontWeight(.bold)
        .textual.blockSpacing(.init(top: 16, bottom: 8))
    }
  }
}

extension StructuredText.HeadingStyle where Self == StructuredText.DiscordHeadingStyle {
  /// A Discord-like heading style.
  public static var discord: Self {
    .init()
  }
}

#Preview {
  StructuredText(
    markdown: """
      # big header
      ## smaller header
      ### small header
      """
  )
  .padding()
  .textual.headingStyle(.discord)
}
