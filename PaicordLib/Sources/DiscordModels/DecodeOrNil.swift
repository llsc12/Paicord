import Foundation

/// Decodes values, or `nil` if the decode fails.
@_spi(UserInstallableApps)
@propertyWrapper
public struct DecodeOrNil<C> where C: Codable {
    public var wrappedValue: C?

    public init(wrappedValue: C? = nil) {
        self.wrappedValue = wrappedValue
    }
}

@_spi(UserInstallableApps)
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

@_spi(UserInstallableApps)
extension KeyedDecodingContainer {
    public func decode<C>(
        _ type: DecodeOrNil<C>.Type,
        forKey key: Key
    ) throws -> DecodeOrNil<C> where C: Codable {
        (try? self.decodeIfPresent(type, forKey: key)) ?? .init(wrappedValue: nil)
    }
}

@_spi(UserInstallableApps)
extension DecodeOrNil: CustomStringConvertible {
    public var description: String {
        String(describing: self.wrappedValue)
    }
}

@_spi(UserInstallableApps)
extension DecodeOrNil: CustomDebugStringConvertible {
    public var debugDescription: String {
        String(reflecting: self.wrappedValue)
    }
}

@_spi(UserInstallableApps)
extension DecodeOrNil: Sendable where C: Sendable {}
