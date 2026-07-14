import SwiftUI

@usableFromInline
struct UnicodeEmojiAttachment: Attachment {
  @usableFromInline
  var description: String {
    character
  }

  @usableFromInline
  var selectionStyle: AttachmentSelectionStyle {
    .text
  }

  private let character: String

  init(character: String) {
    self.character = character
  }

  @usableFromInline
  var body: some View {
    Self.renderedImage(for: character)
      .resizable()
      .aspectRatio(contentMode: .fit)
  }

  @usableFromInline
  func baselineOffset(in environment: TextEnvironmentValues) -> CGFloat {
    environment.emojiProperties.baselineOffset.resolve(in: environment)
  }

  @usableFromInline
  func sizeThatFits(_: ProposedViewSize, in environment: TextEnvironmentValues)
    -> CGSize
  {
    environment.emojiProperties.resolvedSize(in: environment)
  }

  @MainActor
  private static var renderCache: [String: SwiftUI.Image] = [:]

  @MainActor
  private static func renderedImage(for character: String) -> SwiftUI.Image {
    if let cached = renderCache[character] {
      return cached
    }
    let squareSide: CGFloat = 128
    let renderer = ImageRenderer(
      content: Text(character)
        .font(.system(size: squareSide * 0.78))
        .frame(width: squareSide, height: squareSide, alignment: .center)
    )
    renderer.scale = 3

    let image: SwiftUI.Image
    #if canImport(UIKit)
      if let uiImage = renderer.uiImage {
        image = SwiftUI.Image(uiImage: uiImage)
      } else {
        image = SwiftUI.Image(systemName: "questionmark.square.dashed")
      }
    #elseif canImport(AppKit)
      if let nsImage = renderer.nsImage {
        image = SwiftUI.Image(nsImage: nsImage)
      } else {
        image = SwiftUI.Image(systemName: "questionmark.square.dashed")
      }
    #endif

    renderCache[character] = image
    return image
  }
}
