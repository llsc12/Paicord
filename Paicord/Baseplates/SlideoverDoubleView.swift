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
          return
            vs
            .offset(x: swap ? dragOffset : proxy.size.width + 10 + dragOffset)
        }
        .id("secondary")
    }
    .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) {
      self.width = $0
    }
    .gesture(gesture)  // allow dragging over child views like buttons etc
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

  var gesture: some Gesture {
    DragGesture()
      .onChanged { drag in
        guard !slideoverDisabled else { return }

        let translation = drag.translation
        let horizontal = translation.width

        if swap {
          dragOffset = horizontal < 0 ? 0 : horizontal
        } else {
          dragOffset = horizontal
        }
      }
      .onEnded { drag in
        guard !slideoverDisabled else {
          swap = false
          return
        }

        let translation = drag.translation.width
        let velocity = drag.velocity.width

        let shouldSwap: Bool = {
          if abs(velocity) > 600 { return velocity < 0 }
          if abs(translation) > width / 2 { return translation < 0 }
          return swap
        }()

        withAnimation(animation) {
          swap = shouldSwap
          dragOffset = 0
        }
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

#Preview {
  struct PreviewWrapper: View {
    @State var current: Bool = true
    var body: some View {
      SlideoverDoubleView(swap: $current) {
        Text("im 1")
          .font(.largeTitle)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.appBackground)
      } secondary: {
        Text("im 2")
          .font(.largeTitle)
          .foregroundColor(.white)
      }
    }
  }
  return PreviewWrapper()
}
