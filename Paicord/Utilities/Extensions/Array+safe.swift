//
//  Array+safe.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 05/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Collections

extension OrderedDictionary.Elements {
  subscript(safe index: Int) -> Element? {
    (startIndex..<endIndex).contains(index) ? self[index] : nil
  }
}
extension Array {
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

extension OrderedDictionary {
  /// Updates the value for the given key and moves that key–value pair to the front.
  /// If the key doesn’t exist, it’s inserted at the front.
  ///
  /// - Parameters:
  ///   - value: The new value to set.
  ///   - key: The key whose value should be updated and moved.
  mutating func updateValueAndMoveToFront(
    _ value: @autoclosure () -> Value,
    forKey key: Key
  ) {
    var pairs: [(Key, Value)] = []
    pairs.reserveCapacity(count + (self[key] == nil ? 1 : 0))

    // Add updated pair first
    pairs.append((key, value()))

    // Add all remaining pairs except the moved one
    for (k, v) in self where k != key {
      pairs.append((k, v))
    }

    self = OrderedDictionary(uniqueKeysWithValues: pairs)
  }
}
