//
//  Extensions.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUI

extension DiscordColor {
  func asColor() -> Color {
    let (red, green, blue) = self.asRGB()
    // values are between 0 and 255, divide by 255
    return Color(
      red: Double(red) / 255.0,
      green: Double(green) / 255.0,
      blue: Double(blue) / 255.0
    )
  }
}
