#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
  import SwiftUI

  // MARK: - Overview
  //
  // `UIKitTextInteractionOverlay` bridges the shared `TextSelectionModel` into a `UIView`.
  //
  // The overlay reads exclusion rectangles for hit-testing. This allows embedded scrollable regions (like
  // code blocks) to receive touch events while the parent handles text selection. The view hosts
  // a `UITextInteraction` configured for selection and implements the `UITextInput` surface that
  // UIKit uses for selection behavior.

  @available(iOS 18, *)
  struct UIKitTextInteractionOverlay: UIViewRepresentable {
    private let model: TextSelectionModel
    private let overflowFrames: [CGRect]
    private let globalOrigin: CGPoint

    init(model: TextSelectionModel, overflowFrames: [CGRect], globalOrigin: CGPoint) {
      self.model = model
      self.overflowFrames = overflowFrames
      self.globalOrigin = globalOrigin
    }

    func makeUIView(context: Context) -> UITextInteractionView {
      UITextInteractionView(
        model: model,
        exclusionRects: overflowFrames,
        openURL: context.environment.openURL,
        entityTapAction: context.environment.textualEntityTapAction,
        globalOrigin: globalOrigin
      )
    }

    func updateUIView(_ uiView: UITextInteractionView, context: Context) {
      uiView.model = model
      uiView.exclusionRects = overflowFrames
      uiView.openURL = context.environment.openURL
      uiView.entityTapAction = context.environment.textualEntityTapAction
      uiView.globalOrigin = globalOrigin
    }
  }
#endif
