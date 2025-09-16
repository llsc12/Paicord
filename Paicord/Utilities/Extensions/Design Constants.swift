//
//  Design Constants.swift
//  Paicord
//
// Created by Lakhan Lothiyi on 06/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

extension Shape where Self == RoundedRectangle {
  /// Standard 10 point continuous rounding
  public static var rounded: Self {
    .rect(cornerSize: .init(10), style: .continuous)
  }
}
extension RoundedRectangle {
  public init() {
    self = .init(cornerSize: .init(10), style: .continuous)
  }
}
