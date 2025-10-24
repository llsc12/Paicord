//
//  View+ScrollContainerEdgeMask.swift
//  Meret
//
//  Created by Lakhan Lothiyi on 20/03/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

// Used to be a view modifier using the ios 18 scroll geometry modfier.
// Rewritten as a view because ios 17 support is needed which requires
// a geometry proxy on content to get the scroll offset.

import SwiftUI
import SwiftUIX

public struct ScrollFadeMask<Content: View>: View {
  var leading: CGFloat = 20
  var trailing: CGFloat = 20
  var top: CGFloat = 20
  var bottom: CGFloat = 20

  @ViewBuilder public var content: () -> Content

  private let spaceName = "ScrollFadeMask.space"

  @State private var contentFrame: CGRect = .zero
  @State private var containerSize: CGSize = .zero

  private var scrollOffset: CGPoint {
    .init(x: max(0, -contentFrame.minX), y: max(0, -contentFrame.minY))
  }

  private var topFadeThickness: CGFloat {
    let y = scrollOffset.y
    if y <= 0 { return 0 }
    if y >= top { return top }
    return y
  }

  private var bottomFadeThickness: CGFloat {
    if contentFrame.size.height <= containerSize.height { return 0 }
    let maxScroll = contentFrame.size.height - containerSize.height
    let distanceFromBottom = maxScroll - scrollOffset.y
    if distanceFromBottom <= 0 { return 0 }
    if distanceFromBottom >= bottom { return bottom }
    return distanceFromBottom
  }

  private var leadingFadeThickness: CGFloat {
    let x = scrollOffset.x
    if x <= 0 { return 0 }
    if x >= leading { return leading }
    return x
  }

  private var trailingFadeThickness: CGFloat {
    if contentFrame.size.width <= containerSize.width { return 0 }
    let maxScroll = contentFrame.size.width - containerSize.width
    let distanceFromTrailing = maxScroll - scrollOffset.x
    if distanceFromTrailing <= 0 { return 0 }
    if distanceFromTrailing >= trailing { return trailing }
    return distanceFromTrailing
  }
  
  // match scrollview init
  var axes: Axis.Set = .vertical
  public init(_ axes: Axis.Set = .vertical, @ViewBuilder content: @escaping () -> Content) {
    self.axes = axes
    self.content = content
  }

  public func scrollFadeInsets(
    leading: CGFloat = 20,
    trailing: CGFloat = 20,
    top: CGFloat = 20,
    bottom: CGFloat = 20
  ) -> ScrollFadeMask {
    var copy = self
    copy.leading = leading
    copy.trailing = trailing
    copy.top = top
    copy.bottom = bottom
    return copy
  }

  public var body: some View {
    ScrollView(axes) {
      ZStack(alignment: .topLeading) {
        content()
          .background(
            GeometryReader { gp -> Color in
              // report via preference
              let frame = gp.frame(in: .named(spaceName))
              DispatchQueue.main.async {
                // We update state on main thread to ensure smooth UI updates
                self.contentFrame = frame
              }
              return Color.clear
            }
          )
      }
      .padding(.zero)
    }
    .coordinateSpace(name: spaceName)
    .background(
      GeometryReader { gp -> Color in
        DispatchQueue.main.async {
          self.containerSize = gp.size
        }
        return Color.clear
      }
    )
    .reverseMask {
      ZStack {
        if topFadeThickness > 0 || bottomFadeThickness > 0 {
          VStack(spacing: 0) {
            if topFadeThickness > 0 {
              LinearGradient(
                colors: [.white, .clear],
                startPoint: .top,
                endPoint: .bottom
              )
              .frame(height: topFadeThickness)
            }

            Spacer(minLength: 0)

            if bottomFadeThickness > 0 {
              LinearGradient(
                colors: [.clear, .white],
                startPoint: .top,
                endPoint: .bottom
              )
              .frame(height: bottomFadeThickness)
            }
          }
        }

        if leadingFadeThickness > 0 || trailingFadeThickness > 0 {
          HStack(spacing: 0) {
            if leadingFadeThickness > 0 {
              LinearGradient(
                colors: [.white, .clear],
                startPoint: .leading,
                endPoint: .trailing
              )
              .frame(width: leadingFadeThickness)
            }

            Spacer(minLength: 0)

            if trailingFadeThickness > 0 {
              LinearGradient(
                colors: [.clear, .white],
                startPoint: .leading,
                endPoint: .trailing
              )
              .frame(width: trailingFadeThickness)
            }
          }
        }

        Group {
          if topFadeThickness > 0 && leadingFadeThickness > 0 {
            LinearGradient(
              colors: [.white, .clear],
              startPoint: .topLeading,
              endPoint: UnitPoint(x: 0.3, y: 0.3)
            )
            .frame(
              width: min(leadingFadeThickness * 1.5, containerSize.width / 4),
              height: min(topFadeThickness * 1.5, containerSize.height / 4)
            )
            .position(
              x: leadingFadeThickness / 2,
              y: topFadeThickness / 2
            )
          }

          if topFadeThickness > 0 && trailingFadeThickness > 0 {
            LinearGradient(
              colors: [.white, .clear],
              startPoint: .topTrailing,
              endPoint: UnitPoint(x: 0.7, y: 0.3)
            )
            .frame(
              width: min(trailingFadeThickness * 1.5, containerSize.width / 4),
              height: min(topFadeThickness * 1.5, containerSize.height / 4)
            )
            .position(
              x: containerSize.width - trailingFadeThickness / 2,
              y: topFadeThickness / 2
            )
          }

          if bottomFadeThickness > 0 && leadingFadeThickness > 0 {
            LinearGradient(
              colors: [.white, .clear],
              startPoint: .bottomLeading,
              endPoint: UnitPoint(x: 0.3, y: 0.7)
            )
            .frame(
              width: min(leadingFadeThickness * 1.5, containerSize.width / 4),
              height: min(bottomFadeThickness * 1.5, containerSize.height / 4)
            )
            .position(
              x: leadingFadeThickness / 2,
              y: containerSize.height - bottomFadeThickness / 2
            )
          }

          if bottomFadeThickness > 0 && trailingFadeThickness > 0 {
            LinearGradient(
              colors: [.white, .clear],
              startPoint: .bottomTrailing,
              endPoint: UnitPoint(x: 0.7, y: 0.7)
            )
            .frame(
              width: min(trailingFadeThickness * 1.5, containerSize.width / 4),
              height: min(bottomFadeThickness * 1.5, containerSize.height / 4)
            )
            .position(
              x: containerSize.width - trailingFadeThickness / 2,
              y: containerSize.height - bottomFadeThickness / 2
            )
          }
        }
      }
    }
  }
}

#Preview {
  ScrollFadeMask {
    LazyVStack(spacing: 20) {
      ForEach(0..<99999) { i in
        Text("Item \(i)")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue.opacity(0.2))
          .cornerRadius(8)
      }
    }
  }
}
