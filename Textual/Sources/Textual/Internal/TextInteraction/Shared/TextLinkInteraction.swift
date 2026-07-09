import SwiftUI

// MARK: - Overview
//
// `TextLinkInteraction` adds lightweight link tapping to a `Text` fragment.
//
// SwiftUI resolves a `Text.Layout` for each fragment and publishes it through the `Text.LayoutKey`
// preference. This modifier reads the anchored layout, converts tap locations to layout-local
// coordinates, and looks for the first run whose typographic bounds contains the tap. When a run
// has a `url`, the modifier invokes the environment’s `openURL` action.
//
// It additionally surfaces the tapped run's bounds (in the `.global` coordinate space, so an
// ancestor view can convert it into its own local coordinates) through `textualEntityTapAction`,
// so consumers that need to anchor UI (e.g. a popover) near the tapped entity don't have to
// reimplement the hit-testing themselves. This is purely additive: `openURL` is always invoked
// first, exactly as before — consumers using a custom URL scheme for entity links should install
// their own `OpenURLAction` that returns `.handled` for that scheme, otherwise the system will try
// (and fail) to open it externally.

struct TextLinkInteraction: ViewModifier {
  @Environment(\.openURL) private var openURL
  @Environment(\.textualEntityTapAction) private var entityTapAction

  func body(content: Content) -> some View {
    #if TEXTUAL_ENABLE_LINKS
      if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
        content
          .overlayPreferenceValue(Text.LayoutKey.self) { value in
            if let anchoredLayout = value.first {
              GeometryReader { geometry in
                Color.clear
                  .contentShape(.rect)
                  .gesture(
                    tap(
                      origin: geometry[anchoredLayout.origin],
                      globalOrigin: geometry.frame(in: .global).origin,
                      layout: anchoredLayout.layout
                    )
                  )
              }
            }
          }
      } else {
        content
      }
    #else
      content
    #endif
  }

  #if TEXTUAL_ENABLE_LINKS
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private func tap(origin: CGPoint, globalOrigin: CGPoint, layout: Text.Layout) -> some Gesture {
      SpatialTapGesture()
        .onEnded { value in
          let localPoint = CGPoint(
            x: value.location.x - origin.x,
            y: value.location.y - origin.y
          )
          let runs = layout.flatMap(\.self)
          let run = runs.first { run in
            run.typographicBounds.rect.contains(localPoint)
          }
          guard let run, let url = run.url else {
            return
          }
          openURL(url)
          entityTapAction?(
            url,
            run.typographicBounds.rect.offsetBy(dx: globalOrigin.x, dy: globalOrigin.y)
          )
        }
    }
  #endif
}

private struct EntityTapActionKey: EnvironmentKey {
  static let defaultValue: (@MainActor (URL, CGRect) -> Void)? = nil
}

extension EnvironmentValues {
  var textualEntityTapAction: (@MainActor (URL, CGRect) -> Void)? {
    get { self[EntityTapActionKey.self] }
    set { self[EntityTapActionKey.self] = newValue }
  }
}
