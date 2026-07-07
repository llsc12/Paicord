#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(AppKit) && !targetEnvironment(macCatalyst)
  import SwiftUI

  // MARK: - Overview
  //
  // `AppKitTextInteractionOverlay` bridges the shared `TextSelectionModel` into an `NSView`.
  //
  // The overlay reads exclusion rectangles for hit-testing. This allows embedded scrollable regions (like
  // code blocks) to receive touch events while the parent handles text selection. The view also
  // manages selection gestures, keyboard-driven updates, and context menus while SwiftUI renders
  // the text.

  @available(macOS 15, *)
  struct AppKitTextInteractionOverlay: NSViewRepresentable {
    private let model: TextSelectionModel
    private let overflowFrames: [CGRect]
    private let globalOrigin: CGPoint

    init(model: TextSelectionModel, overflowFrames: [CGRect], globalOrigin: CGPoint) {
      self.model = model
      self.overflowFrames = overflowFrames
      self.globalOrigin = globalOrigin
    }

    func makeNSView(context: Context) -> NSTextInteractionView {
      NSTextInteractionView(
        model: model,
        exclusionRects: overflowFrames,
        openURL: context.environment.openURL,
        entityTapAction: context.environment.textualEntityTapAction,
        globalOrigin: globalOrigin
      )
    }

    func updateNSView(_ nsView: NSTextInteractionView, context: Context) {
      nsView.model = model
      nsView.exclusionRects = overflowFrames
      nsView.openURL = context.environment.openURL
      nsView.entityTapAction = context.environment.textualEntityTapAction
      nsView.globalOrigin = globalOrigin
    }
  }
#endif
