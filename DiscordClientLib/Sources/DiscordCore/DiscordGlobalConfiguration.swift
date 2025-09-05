import Foundation
import Logging
import MultipartKit

/// The point of this storage is to disable Sendable warnings when using
/// `-strict-concurrency=complete`
private class ConfigurationStorage: @unchecked Sendable {
    var decoder: any DiscordDecoder = JSONDecoder()
    var encoder: any DiscordEncoder = JSONEncoder()
    var makeLogger: @Sendable (String) -> Logger = { Logger(label: $0) }

    static let shared = ConfigurationStorage()
}

/// A container for **on-boot & one-time-only** configuration options.
public enum DiscordGlobalConfiguration {
    /// Currently only 10 is supported.
    public static let apiVersion = 10
    /// The global decoder to decode JSONs with.
    public static var decoder: any DiscordDecoder {
        get { ConfigurationStorage.shared.decoder }
        set { ConfigurationStorage.shared.decoder = newValue }
    }
    /// The global encoder to encode JSONs with.
    public static var encoder: any DiscordEncoder {
        get { ConfigurationStorage.shared.encoder }
        set { ConfigurationStorage.shared.encoder = newValue }
    }
    /// Function to make loggers with. You can override it with your own logger.
    /// The `String` argument represents the label of the logger.
    public static var makeLogger: @Sendable (String) -> Logger {
        get { ConfigurationStorage.shared.makeLogger }
        set { ConfigurationStorage.shared.makeLogger = newValue }
    }
}

//MARK: - DiscordDecoder
public protocol DiscordDecoder {
    func decode<D: Decodable>(_ type: D.Type, from: Data) throws -> D
}

extension JSONDecoder: DiscordDecoder {}

//MARK: - DiscordEncoder
public protocol DiscordEncoder {
    func encode<E: Encodable>(_ value: E) throws -> Data
}

extension JSONEncoder: DiscordEncoder {}
