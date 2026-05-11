//
//  BorderlessHoverEffectButtonStyle.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/03/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//  

import SwiftUI

// button style thats borderless, and has configurable hover effects
extension ButtonStyle where Self == BorderlessHoverEffectButtonStyle {
  static func borderlessHoverEffect(
    hoverColor: Color = .gray,
    pressedColor: Color = .gray,
    persistentBackground: AnyShapeStyle? = nil,
    isSelected: Bool = false,
    selectionShape: AnyShape = .init(.rect(cornerRadius: 8)),
  ) -> some ButtonStyle {
    BorderlessHoverEffectButtonStyle(
      hoverColor: hoverColor,
      pressedColor: pressedColor,
      persistentBackground: persistentBackground,
      isSelected: isSelected,
      selectionShape: selectionShape
    )
  }
}

struct BorderlessHoverEffectButtonStyle: ButtonStyle {
  var hoverColor: Color
  var pressedColor: Color
  var persistentBackground: AnyShapeStyle?
  var isSelected = false
  var selectionShape: AnyShape
  @State private var isHovered = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background {
        ZStack {
          if let persistentBackground {
            Rectangle()
              .fill(persistentBackground)
          }
          if configuration.isPressed {
            pressedColor
              .opacity(0.12)
          }
          if isHovered {
            hoverColor.opacity(0.2)
          }
          if isSelected {
            pressedColor
              .opacity(0.2)
              .opacity(0.8)
          }
        }
        .clipShape(selectionShape)
      }
      .foregroundColor(isSelected ? pressedColor : nil)
      .onHover { isHovered = $0 }
  }
}

#Preview("button test") {
  @Previewable @State var selected = false
  Button {
    selected.toggle()
  } label: {
    Image(systemName: "checkmark")
      .padding(10)
  }
  .buttonStyle(
    .borderlessHoverEffect(
      hoverColor: .blue,
      pressedColor: .blue,
      persistentBackground: .init(.ultraThinMaterial),
      isSelected: selected,
      selectionShape: .init(.rect),
    )
  )
  .padding()
}
