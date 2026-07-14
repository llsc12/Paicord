//
//  ObservableBox.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 07/07/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation

/// Funny box to store values in, to scope view updates for dictionary-stored values.
@Observable
final class ObservableBox<Value> {
  var value: Value

  init(_ value: Value) {
    self.value = value
  }
}
