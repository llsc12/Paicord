import SwiftUI

extension StructuredText {
  /// A code block style inspired by Discord's rendering.
  ///
  /// Language-alias normalization (`cs` → `csharp`, `py` → `python`, ...) happens earlier, in
  /// `DiscordMarkdown.preprocess(_:)` — by the time a `CodeBlockStyle` sees a `languageHint`, the
  /// fenced block has already been tokenized, so aliasing can't happen at this layer. This style
  /// otherwise reuses `DefaultCodeBlockStyle`'s rendering.
  public struct DiscordCodeBlockStyle: CodeBlockStyle {
    /// Creates the Discord code block style.
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
      DefaultCodeBlockStyle().makeBody(configuration: configuration)
    }
  }
}

extension StructuredText.CodeBlockStyle where Self == StructuredText.DiscordCodeBlockStyle {
  /// A Discord-like code block style.
  public static var discord: Self {
    .init()
  }
}

#Preview {
  StructuredText(
    markdown: DiscordMarkdown.preprocess(
      """
      ```cs
      Console.WriteLine("hi");
      ```
      """
    )
  )
  .padding()
  .textual.codeBlockStyle(.discord)
}
