//
//  Storage.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 06/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//  
//  https://gist.github.com/IanKeen/4d29b48519dca125b21675eeb7623d60

import SwiftUI

@propertyWrapper
struct Storage<T: AppStorageConvertible>: RawRepresentable {
  var rawValue: String { wrappedValue.storedValue }
  var wrappedValue: T

  init?(rawValue: String) {
    guard let value = T.init(rawValue) else { return nil }
    self.wrappedValue = value
  }
  init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
  }
}

// also handle optionals
extension Storage where T: ExpressibleByNilLiteral {
  init?(rawValue: String) {
    if let value = T.init(rawValue) {
      self.wrappedValue = value
    } else {
      self.wrappedValue = nil
    }
  }
}

extension Binding {
  // TODO: this should ideally be exposed via `projectedValue
  func binding<T>() -> Binding<T> where Value == Storage<T> {
    return .init(
      get: { wrappedValue.wrappedValue },
      set: { value, transaction in
        self.transaction(transaction).wrappedValue.wrappedValue = value
      }
    )
  }
}

protocol AppStorageConvertible {
  init?(_ storedValue: String)
  var storedValue: String { get }
}

extension RawRepresentable where RawValue: LosslessStringConvertible, Self: AppStorageConvertible {
  init?(_ storedValue: String) {
    guard let value = RawValue(storedValue) else { return nil }
    self.init(rawValue: value)
  }
  var storedValue: String {
    String(describing: rawValue)
  }
}

extension Array: AppStorageConvertible where Element: LosslessStringConvertible {
  public init?(_ storedValue: String) {
    let values = storedValue.components(separatedBy: ",")
    self = values.compactMap(Element.init)
  }
  var storedValue: String {
    return map(\.description).joined(separator: ",")
  }
}
