import SwiftUI

// MARK: - Overview
//
// `RoundedInlineBackground` draws a rounded background behind runs that have a `backgroundColor`
// attribute — inline code spans and custom entities from a `SyntaxExtension` (mentions, tags,
// etc.) alike — instead of the flat rectangle that attribute would otherwise produce.
//
// `TextBuilder` strips `backgroundColor` from any such run before building `Text` (when
// `roundedBackgroundStyle` is set) and tags it with `InlineBackgroundAttribute` carrying that same
// color instead (`Text.Layout.Run` only exposes custom attributes, not raw Foundation ones, so
// this is the only way to find those runs and their color again from here). This modifier reads
// the fragment's anchored `Text.Layout` via the same `Text.LayoutKey` preference
// `AttachmentOverlay`/`TextSelectionBackground` use, walks each line's runs, and merges
// consecutive same-color runs into a single shape — so a multi-word span doesn't get a seam down
// the middle where the AttributedString happened to split it into more than one run.

@available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *)
struct InlineBackgroundAttribute: TextAttribute {
  var color: Color
}

@available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *)
extension Text.Layout.Run {
  fileprivate var inlineBackgroundColor: Color? {
    self[InlineBackgroundAttribute.self]?.color
  }
}

struct RoundedInlineBackground: ViewModifier {
  @Environment(\.roundedBackgroundStyle) private var style

  func body(content: Content) -> some View {
    if #available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *), let style {
      content
        .backgroundPreferenceValue(Text.LayoutKey.self) { value in
          if let anchoredLayout = value.first {
            GeometryReader { geometry in
              RoundedInlineBackgroundView(
                style: style,
                origin: geometry[anchoredLayout.origin],
                layout: anchoredLayout.layout
              )
            }
          }
        }
    } else {
      content
    }
  }
}

@available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *)
private struct RoundedInlineBackgroundView: View {
  let style: RoundedBackgroundStyle
  let origin: CGPoint
  let layout: Text.Layout

  var body: some View {
    ZStack(alignment: .topLeading) {
      ForEach(Array(backgroundRuns.enumerated()), id: \.offset) { _, run in
        Rectangle()
          .fill(.clear)
          .frame(width: run.rect.width, height: run.rect.height)
          .padding(style.padding)
          .background(RoundedRectangle(cornerRadius: style.cornerRadius).fill(run.color))
          .position(x: run.rect.midX, y: run.rect.midY)
      }
    }
    .offset(x: origin.x, y: origin.y)
  }

  /// One merged rect (plus its shared color) per maximal run of consecutive same-color
  /// background-tagged runs on a line.
  private var backgroundRuns: [(rect: CGRect, color: Color)] {
    var result: [(rect: CGRect, color: Color)] = []

    for line in layout {
      var pending: (rect: CGRect, color: Color)?
      for run in line {
        guard let color = run.inlineBackgroundColor else {
          if let value = pending {
            result.append(value)
            pending = nil
          }
          continue
        }

        let bounds = run.typographicBounds.rect
        if let value = pending, value.color == color {
          pending = (value.rect.union(bounds), color)
        } else {
          if let value = pending {
            result.append(value)
          }
          pending = (bounds, color)
        }
      }
      if let value = pending {
        result.append(value)
      }
    }

    return result
  }
}
