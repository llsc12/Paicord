import Foundation

/// Decodes values, or `nil` if the decode fails.
@propertyWrapper
package struct DecodeOrNil<C> where C: Codable {
  package var wrappedValue: C?

  package init(wrappedValue: C? = nil) {
    self.wrappedValue = wrappedValue
  }
}

extension DecodeOrNil: Codable {
  package init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.wrappedValue = try? container.decode(C.self)
  }

  package func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.wrappedValue)
  }
}

extension KeyedDecodingContainer {
  package func decode<C>(
    _ type: DecodeOrNil<C>.Type,
    forKey key: Key
  ) throws -> DecodeOrNil<C> where C: Codable {
    (try? self.decodeIfPresent(type, forKey: key)) ?? .init(wrappedValue: nil)
  }
}

extension DecodeOrNil: CustomStringConvertible {
  package var description: String {
    String(describing: self.wrappedValue)
  }
}

extension DecodeOrNil: CustomDebugStringConvertible {
  package var debugDescription: String {
    String(reflecting: self.wrappedValue)
  }
}

extension DecodeOrNil: Sendable where C: Sendable {}
