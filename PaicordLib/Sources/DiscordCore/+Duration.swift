//
//  +Duration.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 18/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation

extension Duration {
  public static func minutes<T>(_ minutes: T) -> Duration
  where T: BinaryInteger {
    .seconds(minutes * 60)
  }

  public static func minutes(_ minutes: Double) -> Duration {
    .seconds(minutes * 60)
  }
}
