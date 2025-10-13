//
//  Maths.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 12/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation

extension Int {
  var toCGFloat: CGFloat {
    CGFloat(self)
  }
}

func min<T>(_ x: T?, _ y: T?) -> T? where T: Comparable {
  if let x, let y {
    return Swift.min(x, y)
  } else if let x {
    return x
  } else if let y {
    return y
  } else {
    return nil
  }
}
