import SkipFoundation

/// Decodes values, or `nil` if the decode fails.
// SKIP @nobridge
@propertyWrapper
package struct DecodeOrNil<C> where C: Codable {
  public var wrappedValue: C?

  public init(wrappedValue: C? = nil) {
    self.wrappedValue = wrappedValue
  }
}

// SKIP @nobridge
extension DecodeOrNil: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.wrappedValue = try? container.decode(C.self)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.wrappedValue)
  }
}
// SKIP @nobridge
extension DecodeOrNil: Equatable where C: Equatable {}
// SKIP @nobridge
extension DecodeOrNil: Hashable where C: Hashable {
  package func hash(into hasher: inout Hasher) {
    hasher.combine(self.wrappedValue)
  }
}
// SKIP @nobridge
extension KeyedDecodingContainer {
  package func decode<C>(
    _ type: DecodeOrNil<C>.Type,
    forKey key: Key
  ) throws -> DecodeOrNil<C> where C: Codable {
    (try? self.decodeIfPresent(type, forKey: key)) ?? .init(wrappedValue: nil)
  }
}
// SKIP @nobridge
extension DecodeOrNil: CustomStringConvertible {
  public var description: String {
    String(describing: self.wrappedValue)
  }
}
// SKIP @nobridge
extension DecodeOrNil: CustomDebugStringConvertible {
  public var debugDescription: String {
    String(reflecting: self.wrappedValue)
  }
}
// SKIP @nobridge
extension DecodeOrNil: Sendable where C: Sendable {}
