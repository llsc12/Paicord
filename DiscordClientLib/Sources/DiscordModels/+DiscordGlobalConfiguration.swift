import Logging

/// The point of this storage is to disable Sendable warnings when using
/// `-strict-concurrency=complete`
private class ConfigurationStorage: @unchecked Sendable {
    var globalRateLimit = 50

    static let shared = ConfigurationStorage()
}

extension DiscordGlobalConfiguration {
    /// Global rate-limit for requests per second.
    /// 50 by default, but you can ask Discord for a raise.
    public static var globalRateLimit: Int {
        get { ConfigurationStorage.shared.globalRateLimit }
        set { ConfigurationStorage.shared.globalRateLimit = newValue }
    }
    /// Log about sub-optimal situations during decode.
    /// For example if a type can't find a representation to decode a value to,
    /// and has to get rid of that value.
    /// Does not include decode errors.
    /// This is supposed to be only used by the library author.
    /// Enabling the logger is discouraged as it'll be too spammy.
    static func makeDecodeLogger(_ label: String) -> Logger {
        #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
        var logger = DiscordGlobalConfiguration.makeLogger(label)
        logger[metadataKey: "tag"] = "decode-logger"
        return logger
        #else
        return Logger(label: label, factory: SwiftLogNoOpLogHandler.init)
        #endif
    }
}
