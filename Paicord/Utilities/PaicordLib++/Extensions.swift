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
  
  /// Converts the `DiscordColor` to a SwiftUI `Color`.
  /// - Parameter ignoringZero: If `true`, a color value of zero will return `nil`.
  /// - Returns: A `Color` representation of the `DiscordColor`, or `nil` if the value is zero and `ignoringZero` is `true`.
  func asColor(ignoringZero: Bool = true) -> Color? {
    if ignoringZero, self.value == 0 { return nil }  // no color?
    let (red, green, blue) = self.asRGB()
    // values are between 0 and 255, divide by 255
    return Color(
      red: Double(red) / 255.0,
      green: Double(green) / 255.0,
      blue: Double(blue) / 255.0
    )
  }
}
