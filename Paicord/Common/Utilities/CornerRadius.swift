//
//  CornerRadius.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 02/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//
// https://stackoverflow.com/questions/71248005/round-specific-corners-in-a-swiftui-mac-app

import SwiftUI

// defines OptionSet, which corners to be rounded – same as UIRectCorner
struct RectCorner: OptionSet {

  let rawValue: Int

  static let topLeft = RectCorner(rawValue: 1 << 0)
  static let topRight = RectCorner(rawValue: 1 << 1)
  static let bottomRight = RectCorner(rawValue: 1 << 2)
  static let bottomLeft = RectCorner(rawValue: 1 << 3)

  static let allCorners: RectCorner = [
    .topLeft, topRight, .bottomLeft, .bottomRight,
  ]
}

// draws shape with specified rounded corners applying corner radius
struct RoundedCornersShape: Shape {

  var radius: CGFloat = .zero
  var corners: RectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    var path = Path()

    let p1 = CGPoint(
      x: rect.minX,
      y: corners.contains(.topLeft) ? rect.minY + radius : rect.minY
    )
    let p2 = CGPoint(
      x: corners.contains(.topLeft) ? rect.minX + radius : rect.minX,
      y: rect.minY
    )

    let p3 = CGPoint(
      x: corners.contains(.topRight) ? rect.maxX - radius : rect.maxX,
      y: rect.minY
    )
    let p4 = CGPoint(
      x: rect.maxX,
      y: corners.contains(.topRight) ? rect.minY + radius : rect.minY
    )

    let p5 = CGPoint(
      x: rect.maxX,
      y: corners.contains(.bottomRight) ? rect.maxY - radius : rect.maxY
    )
    let p6 = CGPoint(
      x: corners.contains(.bottomRight) ? rect.maxX - radius : rect.maxX,
      y: rect.maxY
    )

    let p7 = CGPoint(
      x: corners.contains(.bottomLeft) ? rect.minX + radius : rect.minX,
      y: rect.maxY
    )
    let p8 = CGPoint(
      x: rect.minX,
      y: corners.contains(.bottomLeft) ? rect.maxY - radius : rect.maxY
    )

    path.move(to: p1)
    path.addArc(
      tangent1End: CGPoint(x: rect.minX, y: rect.minY),
      tangent2End: p2,
      radius: radius
    )
    path.addLine(to: p3)
    path.addArc(
      tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
      tangent2End: p4,
      radius: radius
    )
    path.addLine(to: p5)
    path.addArc(
      tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
      tangent2End: p6,
      radius: radius
    )
    path.addLine(to: p7)
    path.addArc(
      tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
      tangent2End: p8,
      radius: radius
    )
    path.closeSubpath()

    return path
  }
}

// View extension, to be used like modifier:
// SomeView().roundedCorners(radius: 20, corners: [.topLeft, .bottomRight])
extension View {
  func roundedCorners(radius: CGFloat, corners: RectCorner) -> some View {
    clipShape(RoundedCornersShape(radius: radius, corners: corners))
  }
}
