//
//  ImpactGenerator.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 25/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

enum ImpactGenerator {
  #if os(iOS)
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy = UIImpactFeedbackGenerator(style: .heavy)
  #endif

  static func impact(style: FeedbackStyle) {
    #if os(iOS)
      switch style {
      case .light:
        light.impactOccurred()
      case .medium:
        medium.impactOccurred()
      case .heavy:
        heavy.impactOccurred()
      @unknown default:
        break
      }
    #endif
  }

  enum FeedbackStyle {
    case light
    case medium
    case heavy
  }
}
