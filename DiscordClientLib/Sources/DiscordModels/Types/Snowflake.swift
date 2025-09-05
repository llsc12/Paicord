import Foundation

public protocol SnowflakeProtocol:
    Sendable,
    Codable,
    Hashable,
    CustomStringConvertible,
    ExpressibleByStringLiteral
{

    var rawValue: String { get }
    init(_ rawValue: String)
}

extension SnowflakeProtocol {
    /// Initializes a snowflake from another snowflake.
    public init(_ snowflake: any SnowflakeProtocol) {
        self.init(snowflake.rawValue)
    }

    public init(from decoder: any Decoder) throws {
        try self.init(.init(from: decoder))
        #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
        if self.parse() == nil {
            DiscordGlobalConfiguration.makeDecodeLogger("SnowflakeProtocol").warning(
                "Could not parse a snowflake",
                metadata: [
                    "codingPath": "\(decoder.codingPath.map(\.stringValue))",
                    "decoded": "\(self.rawValue)",
                ]
            )
        }
        #endif
    }

    public func encode(to encoder: any Encoder) throws {
        try self.rawValue.encode(to: encoder)
    }

    public init(stringLiteral rawValue: String) {
        self.init(rawValue)
    }

    /// Initializes a snowflake from a `SnowflakeInfo`.
    @inlinable
    public init(info: SnowflakeInfo) {
        self = info.toSnowflake(as: Self.self)
    }

    /// Parses the snowflake to `SnowflakeInfo`.
    @inlinable
    public func parse() -> SnowflakeInfo? {
        SnowflakeInfo(from: self.rawValue)
    }

    /// Makes a fake snowflake.
    /// - Parameter date: The date when this snowflake is supposed to have been created at.
    @inlinable
    public static func makeFake(date: Date = Date()) throws -> Self {
        try self.init(info: SnowflakeInfo.makeFake(date: date))
    }
}

/// Use the `Snowflake` type-aliases instead. e.g. `Snowflake<DiscordUser>` ❌, `UserSnowflake` ✅.
/// This type is expressible by string literal. This means the following code is valid:
/// ```
/// let snowflake: ChannelSnowflake = "192839184848484"
/// ```
/// If you really need to, you can convert snowflakes to each other:
/// ```
/// let appId: ApplicationSnowflake = "192839184848484"
/// let botId: UserSnowflake = Snowflake(appId)
/// ```
public struct Snowflake<Tag>: SnowflakeProtocol {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        #"Snowflake<\#(Swift._typeName(Tag.self, qualified: false))>("\#(rawValue)")"#
    }
}

extension Snowflake: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        self.rawValue.codingKey
    }

    public init?<CodingKeys>(codingKey: CodingKeys) where CodingKeys: CodingKey {
        self.rawValue = codingKey.stringValue
    }
}

/// Type-erased snowflake.
/// This type is expressible by string literal. This means the following code is valid:
/// ```
/// let snowflake: AnySnowflake = "192839184848484"
/// ```
/// If you really need to, you can convert snowflakes to each other:
/// ```
/// let appId: AnySnowflake = "192839184848484"
/// let botId: UserSnowflake = Snowflake(appId)
/// ```
public struct AnySnowflake: SnowflakeProtocol {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        #"AnySnowflake("\#(rawValue)")"#
    }
}

extension AnySnowflake: CodingKeyRepresentable {
    public var codingKey: any CodingKey {
        self.rawValue.codingKey
    }

    public init?<CodingKeys>(codingKey: CodingKeys) where CodingKeys: CodingKey {
        self.rawValue = codingKey.stringValue
    }
}

public func == (lhs: any SnowflakeProtocol, rhs: any SnowflakeProtocol) -> Bool {
    lhs.rawValue == rhs.rawValue
}

/// The parsed info of a snowflake.
public struct SnowflakeInfo: Sendable {

    public enum Error: Swift.Error, CustomStringConvertible {
        /// Entered field '\(name)' is bigger than expected. It has a value of '\(value)', but max accepted is '\(max)'
        case fieldTooBig(_ name: String, value: String, max: Int)
        /// Entered field '\(name)' is smaller than expected. It has a value of '\(value)', but min accepted is '\(min)'
        case fieldTooSmall(_ name: String, value: String, min: UInt64)

        public var description: String {
            switch self {
            case let .fieldTooBig(name, value, max):
                return "SnowflakeInfo.Error.fieldTooBig(\(name), value: \(value), max: \(max))"
            case let .fieldTooSmall(name, value, min):
                return "SnowflakeInfo.Error.fieldTooSmall(\(name), value: \(value), min: \(min))"
            }
        }
    }

    /// Time since epoch, in milli-seconds, when the snowflake was created.
    public var timestamp: UInt64
    /// The internal unique id of the worker that created the snowflake.
    public var workerId: UInt8
    /// The internal unique id of the process that created the snowflake.
    public var processId: UInt8
    /// The sequence number of the snowflake in the millisecond when it was created.
    public var sequenceNumber: UInt16

    /// The timestamp converted to `Date`.
    public var date: Date {
        Date(timeIntervalSince1970: Double(self.timestamp) / 1_000)
    }

    @usableFromInline
    static let discordEpochConstant: UInt64 = 1_420_070_400_000

    /// - Parameters:
    ///   - timestamp: Time since epoch, in milli-seconds, when the snowflake was created.
    ///   - workerId: The internal unique id of the worker that created the snowflake.
    ///   - processId: The internal unique id of the process that created the snowflake.
    ///   - sequenceNumber: The sequence number of the snowflake in the millisecond when it was created.
    ///
    ///   Throws `SnowflakeInfo.Error`
    public init(timestamp: UInt64, workerId: UInt8, processId: UInt8, sequenceNumber: UInt16) throws {
        guard timestamp <= (1 << 42) else {
            throw Error.fieldTooBig("timestamp", value: "\(timestamp)", max: 1 << 42)
        }
        guard workerId <= (1 << 5) else {
            throw Error.fieldTooBig("workerId", value: "\(workerId)", max: 1 << 5)
        }
        guard processId <= (1 << 5) else {
            throw Error.fieldTooBig("processId", value: "\(processId)", max: 1 << 5)
        }
        guard sequenceNumber <= (1 << 12) else {
            throw Error.fieldTooBig("sequenceNumber", value: "\(sequenceNumber)", max: 1 << 12)
        }

        self.timestamp = timestamp
        self.workerId = workerId
        self.processId = processId
        self.sequenceNumber = sequenceNumber
    }

    /// - Parameters:
    ///   - date: Time date when the snowflake was created.
    ///   - workerId: The internal unique id of the worker that created the snowflake.
    ///   - processId: The internal unique id of the process that created the snowflake.
    ///   - sequenceNumber: The sequence number of the snowflake in the millisecond when it was created.
    ///
    ///   Throws `SnowflakeInfo.Error`
    public init(date: Date, workerId: UInt8, processId: UInt8, sequenceNumber: UInt16) throws {
        guard date.timeIntervalSince1970 >= Double(SnowflakeInfo.discordEpochConstant / 1_000) else {
            throw Error.fieldTooSmall(
                "date",
                value: "\(date.timeIntervalSince1970)",
                min: SnowflakeInfo.discordEpochConstant / 1_000
            )
        }

        let timeSince1970 = UInt64(date.timeIntervalSince1970)
        guard timeSince1970 <= (1 << 42 / 1_000) else {
            throw Error.fieldTooBig("date", value: "\(timeSince1970)", max: (1 << 42 / 1_000))
        }

        self.timestamp = UInt64(date.timeIntervalSince1970 * 1_000)

        guard timestamp < (1 << 42) else {
            let max = (1 << 42 / 1_000) - 1
            throw Error.fieldTooBig("date", value: "\(timestamp)", max: max)
        }
        guard workerId <= (1 << 5) else {
            throw Error.fieldTooBig("workerId", value: "\(workerId)", max: 1 << 5)
        }
        guard processId <= (1 << 5) else {
            throw Error.fieldTooBig("processId", value: "\(processId)", max: 1 << 5)
        }
        guard sequenceNumber <= (1 << 12) else {
            throw Error.fieldTooBig("sequenceNumber", value: "\(sequenceNumber)", max: 1 << 12)
        }

        self.workerId = workerId
        self.processId = processId
        self.sequenceNumber = sequenceNumber
    }

    /// Makes a fake snowflake.
    /// - Parameter date: The date when this snowflake is supposed to have been created at.
    @inlinable
    internal static func makeFake(date: Date) throws -> SnowflakeInfo {
        try SnowflakeInfo(date: date, workerId: 0, processId: 0, sequenceNumber: 0)
    }

    @inlinable
    internal init?(from snowflake: String) {
        guard let value = UInt64(snowflake) else { return nil }
        self.timestamp = (value >> 22) + SnowflakeInfo.discordEpochConstant
        self.workerId = UInt8((value >> 17) & 0x1F)
        self.processId = UInt8((value >> 12) & 0x1F)
        self.sequenceNumber = UInt16(value & 0xFFF)
    }

    @inlinable
    internal init?(from snowflake: any SnowflakeProtocol) {
        self.init(from: snowflake.rawValue)
    }

    @inlinable
    internal func toSnowflake<S: SnowflakeProtocol>(as type: S.Type = S.self) -> S {
        let timestamp = (self.timestamp - SnowflakeInfo.discordEpochConstant) << 22
        let workerId = UInt64(self.workerId) << 17
        let processId = UInt64(self.processId) << 12
        let value = timestamp | workerId | processId | UInt64(self.sequenceNumber)
        return S("\(value)")
    }
}

//MARK: Convenience type-aliases

/// Convenience type-alias for `Snowflake<Guild>`
public typealias GuildSnowflake = Snowflake<Guild>

/// Convenience type-alias for `Snowflake<DiscordChannel>`
public typealias ChannelSnowflake = Snowflake<DiscordChannel>

/// Convenience type-alias for `Snowflake<DiscordChannel.Message>`
public typealias MessageSnowflake = Snowflake<DiscordChannel.Message>

/// Convenience type-alias for `Snowflake<DiscordUser>`
public typealias UserSnowflake = Snowflake<DiscordUser>

/// Convenience type-alias for `Snowflake<DiscordApplication>`
public typealias ApplicationSnowflake = Snowflake<DiscordApplication>

/// Convenience type-alias for `Snowflake<Emoji>`
public typealias EmojiSnowflake = Snowflake<Emoji>

/// Convenience type-alias for `Snowflake<Sticker>`
public typealias StickerSnowflake = Snowflake<Sticker>

/// Convenience type-alias for `Snowflake<Role>`
public typealias RoleSnowflake = Snowflake<Role>

/// Convenience type-alias for `Snowflake<AutoModerationRule>`
public typealias RuleSnowflake = Snowflake<AutoModerationRule>

/// Convenience type-alias for `Snowflake<StickerPack>`
public typealias StickerPackSnowflake = Snowflake<StickerPack>

/// Convenience type-alias for `Snowflake<Webhook>`
public typealias WebhookSnowflake = Snowflake<Webhook>

/// Convenience type-alias for `Snowflake<GuildScheduledEvent>`
public typealias GuildScheduledEventSnowflake = Snowflake<GuildScheduledEvent>

/// Convenience type-alias for `Snowflake<Guild.Onboarding.Prompt>`
public typealias OnboardingPromptSnowflake = Snowflake<Guild.Onboarding.Prompt>

/// Convenience type-alias for `Snowflake<Guild.Onboarding.Prompt.Option>`
public typealias OnboardingPromptOptionSnowflake = Snowflake<Guild.Onboarding.Prompt.Option>

/// Convenience type-alias for `Snowflake<ApplicationCommand>`
public typealias CommandSnowflake = Snowflake<ApplicationCommand>

/// Convenience type-alias for `Snowflake<Interaction>`
public typealias InteractionSnowflake = Snowflake<Interaction>

/// Convenience type-alias for `Snowflake<Integration>`
public typealias IntegrationSnowflake = Snowflake<Integration>

/// Convenience type-alias for `Snowflake<AuditLog.Entry>`
public typealias AuditLogEntrySnowflake = Snowflake<AuditLog.Entry>

/// Convenience type-alias for `Snowflake<DiscordChannel.Message.Attachment>`
public typealias AttachmentSnowflake = Snowflake<DiscordChannel.Message.Attachment>

/// Convenience type-alias for `Snowflake<DiscordChannel.ForumTag>`
public typealias ForumTagSnowflake = Snowflake<DiscordChannel.ForumTag>

/// Convenience type-alias for `Snowflake<Team>`
public typealias TeamSnowflake = Snowflake<Team>

/// Convenience type-alias for `Snowflake<StageInstance>`
public typealias StageInstanceSnowflake = Snowflake<StageInstance>

/// Convenience type-alias for `Snowflake<Gateway.Activity.Assets>`
public typealias AssetsSnowflake = Snowflake<Gateway.Activity.Assets>

/// Convenience type-alias for `Snowflake<Entitlement>`
public typealias EntitlementSnowflake = Snowflake<Entitlement>

/// Convenience type-alias for `Snowflake<SKU>`
public typealias SKUSnowflake = Snowflake<SKU>
