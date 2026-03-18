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

func max<T>(_ x: T?, _ y: T?) -> T? where T: Comparable {
  if let x, let y {
    return Swift.max(x, y)
  } else if let x {
    return x
  } else if let y {
    return y
  } else {
    return nil
  }
}

extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    min(max(self, limits.lowerBound), limits.upperBound)
  }
  
  func clamped(to limits: PartialRangeFrom<Self>) -> Self {
    max(self, limits.lowerBound)
  }
  
  func clamped(to limits: PartialRangeThrough<Self>) -> Self {
    min(self, limits.upperBound)
  }
  
  func clamped(to limits: PartialRangeUpTo<Self>) -> Self {
    min(self, limits.upperBound)
  }
  
  func clamped(to limits: Range<Self>) -> Self {
    min(max(self, limits.lowerBound), limits.upperBound)
  }
}
