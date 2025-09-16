//
//  GradientText.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 02/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

// TODO: set up modifiers for text gradients (gradient role colors)

struct Test: View {
  @State private var offset: CGFloat = 0

  let gradientColors: [Color] = [.purple, .yellow, .blue, .purple]
  let animationDuration: Double = 1.8

  var body: some View {
    GeometryReader { geo in
      let width = geo.size.width
      HStack(spacing: 0) {
        LinearGradient(
          gradient: Gradient(colors: gradientColors),
          startPoint: .leading,
          endPoint: .trailing
        )
        .frame(width: width)
        .scaleEffect(1.01)

        LinearGradient(
          gradient: Gradient(colors: gradientColors),
          startPoint: .leading,
          endPoint: .trailing
        )
        .frame(width: width)
        .scaleEffect(1.01)
      }
      .offset(x: -offset)
      .animation(
        .linear(duration: animationDuration)
          .repeatForever(autoreverses: false),
        value: offset
      )
      .onAppear { offset = width }
      .ignoresSafeArea()
    }
  }
}

#Preview {
  Test()
    .frame(width: 200, height: 200)
}
