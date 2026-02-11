//
//  SlideoverDoubleView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUIX

struct SlideoverDoubleView<Primary: View, Secondary: View>: View {
  @Binding var swap: Bool
  var primary: Primary
  var secondary: Secondary

  private let animation: Animation = .easeOut(duration: 0.2)
  @State private var dragOffset: CGFloat = 0
  @ViewStorage var width: CGFloat = 0

  @Environment(\.slideoverDisabled) var slideoverDisabled

  init(
    swap: Binding<Bool>,
    @ViewBuilder primary: () -> Primary,
    @ViewBuilder secondary: () -> Secondary
  ) {
    self._swap = swap
    self.primary = primary()
    self.secondary = secondary()
  }

  var body: some View {
    ZStack {
      primary
        .id("primary")

      // fixes some swift 6 warnings
      let swap = swap
      let dragOffset = dragOffset
      secondary
        .background(.background)
        .shadow(radius: 10)
        .visualEffect { vs, proxy in
          vs
            .offset(x: swap ? dragOffset : proxy.size.width + 10 + dragOffset)
        }
        .id("secondary")
    }
    .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) {
      self.width = $0
    }
    .addDragGesture(
      isEnabled: !slideoverDisabled,
      onChanged: handleChanged(horizontal:),
      onEnded: handleEnded(horizontal:velocity:)
    )
    .onChange(of: swap) {
      withAnimation(animation) {
        dragOffset = 0
      }
    }
    .onChange(of: slideoverDisabled) {
      if slideoverDisabled {
        withAnimation(animation) {
          swap = false
          dragOffset = 0
        }
      }
    }
  }

  private func handleChanged(horizontal: CGFloat) {
    guard !slideoverDisabled else { return }

    if swap {
      dragOffset = horizontal < 0 ? 0 : horizontal
    } else {
      dragOffset = horizontal
    }
  }

  private func handleEnded(horizontal: CGFloat, velocity: CGFloat) {
    guard !slideoverDisabled else {
      swap = false
      return
    }

    let shouldSwap: Bool = {
      if abs(velocity) > 600 { return velocity < 0 }
      if abs(horizontal) > width / 2 { return horizontal < 0 }
      return swap
    }()

    withAnimation(animation) {
      swap = shouldSwap
      dragOffset = 0
    }
  }
}

extension View {
  @ViewBuilder
  fileprivate func addDragGesture(
    isEnabled: Bool,
    onChanged: @escaping (CGFloat) -> Void,
    onEnded: @escaping (CGFloat, CGFloat) -> Void
  ) -> some View {
    if #available(iOS 18.0, *) {
      self.gesture(
        SlideoverUIKitGesture(
          isEnabled: isEnabled,
          onChanged: onChanged,
          onEnded: onEnded
        )
      )
    } else {
      self.gesture(
        DragGesture()
          .onChanged { drag in
            onChanged(drag.translation.width)
          }
          .onEnded { drag in
            onEnded(drag.translation.width, drag.velocity.width)
          }
      )
    }
  }
}

extension EnvironmentValues {
  @Entry var slideoverDisabled: Bool = false
}

extension View {
  func slideoverDisabled(_ disabled: Bool) -> some View {
    environment(\.slideoverDisabled, disabled)
  }
}

#if canImport(UIKit)
  final class SlideoverPanRecognizer: UIPanGestureRecognizer,
    UIGestureRecognizerDelegate
  {

    var onChanged: ((CGFloat) -> Void)?
    var onEnded: ((CGFloat, CGFloat) -> Void)?

    private var activated = false

    override init(target: Any?, action: Selector?) {
      super.init(target: target, action: action)
      delegate = self
      cancelsTouchesInView = false
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer)
      -> Bool
    {
      let v = velocity(in: view)
      return abs(v.x) > abs(v.y)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
      super.touchesMoved(touches, with: event)

      guard let view else { return }
      let t = translation(in: view)

      if !activated {
        guard abs(t.x) > 12 else { return }
        activated = true
      }

      onChanged?(t.x)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
      guard let view else { return }
      let v = velocity(in: view).x
      onEnded?(translation(in: view).x, v)
      activated = false
      super.touchesEnded(touches, with: event)
    }

    override func reset() {
      activated = false
      super.reset()
    }
  }

  struct SlideoverUIKitGesture: UIGestureRecognizerRepresentable {

    var isEnabled: Bool
    var onChanged: (CGFloat) -> Void
    var onEnded: (CGFloat, CGFloat) -> Void

    func makeUIGestureRecognizer(context: Context) -> some UIGestureRecognizer {
      let pan = SlideoverPanRecognizer()
      pan.onChanged = onChanged
      pan.onEnded = onEnded
      return pan
    }

    func updateUIGestureRecognizer(
      _ recognizer: UIGestureRecognizerType,
      context: Context
    ) {
      recognizer.isEnabled = isEnabled
    }

    func handleUIGestureRecognizerAction(
      _ recognizer: UIGestureRecognizerType,
      context: Context
    ) {}
  }
#endif

#Preview {
  struct PreviewWrapper: View {
    @Environment(\.theme) var theme
    @State var current: Bool = true
    var body: some View {
      SlideoverDoubleView(swap: $current) {
        Text("im 1")
          .font(.largeTitle)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(theme.common.primaryBackground)
      } secondary: {
        Text("im 2")
          .font(.largeTitle)
          .foregroundColor(.black)
      }
    }
  }
  return PreviewWrapper()
}
