import Foundation

/// An Emoji with all fields marked as optional.
/// The same as a `Partial Emoji`.
/// https://discord.com/developers/docs/resources/emoji#emoji-object
public struct Emoji: Sendable, Codable {
    public var id: EmojiSnowflake?
    public var name: String?
    public var roles: [RoleSnowflake]?
    public var user: DiscordUser?
    public var require_colons: Bool?
    public var managed: Bool?
    public var animated: Bool?
    public var available: Bool?
    public var version: Int?

    public init(
        id: EmojiSnowflake? = nil,
        name: String? = nil,
        roles: [RoleSnowflake]? = nil,
        user: DiscordUser? = nil,
        require_colons: Bool? = nil,
        managed: Bool? = nil,
        animated: Bool? = nil,
        available: Bool? = nil,
        version: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.roles = roles
        self.user = user
        self.require_colons = require_colons
        self.managed = managed
        self.animated = animated
        self.available = available
        self.version = version
    }
}

/// A reaction emoji.
public struct Reaction: Sendable, Codable, Hashable {

    private enum Base: Sendable, Codable, Hashable {
        case unicodeEmoji(String)
        case guildEmoji(name: String?, id: EmojiSnowflake)
    }

    private let base: Base

    public var urlPathDescription: String {
        switch self.base {
        case let .unicodeEmoji(emoji): return emoji
        case let .guildEmoji(name, id): return "\(name ?? ""):\(id.rawValue)"
        }
    }

    private init(base: Base) {
        self.base = base
    }

    public init(from decoder: any Decoder) throws {
        self.base = try .init(from: decoder)
    }

    public func encode(to encoder: any Encoder) throws {
        try self.base.encode(to: encoder)
    }

    public enum Error: Swift.Error, CustomStringConvertible {
        /// Expected only 1 emoji in the input '\(input)' but recognized '\(count)' emojis.
        case moreThan1Emoji(String, count: Int)
        /// The input '\(input)' does not seem like an emoji.
        case notEmoji(String)
        /// Can't convert a partial emoji to a Reaction.
        case cantConvertEmoji(Emoji)

        public var description: String {
            switch self {
            case let .moreThan1Emoji(input, count):
                return "Reaction.Error.moreThan1Emoji(\(input), count: \(count))"
            case let .notEmoji(input):
                return "Reaction.Error.notEmoji(\(input))"
            case let .cantConvertEmoji(emoji):
                return "Reaction.Error.cantConvertEmoji(\(emoji))"
            }
        }
    }

    /// Unicode emoji. The function verifies that your input is an emoji or not.
    public static func unicodeEmoji(_ emoji: String) throws -> Reaction {
        guard emoji.count == 1 else {
            throw Error.moreThan1Emoji(emoji, count: emoji.unicodeScalars.count)
        }
        guard emoji.unicodeScalars.contains(where: \.properties.isEmoji) else {
            throw Error.notEmoji(emoji)
        }
        return Reaction(base: .unicodeEmoji(emoji))
    }

    /// Custom discord guild emoji.
    public static func guildEmoji(name: String?, id: EmojiSnowflake) -> Reaction {
        Reaction(base: .guildEmoji(name: name, id: id))
    }

    public init(emoji: Emoji) throws {
        if let id = emoji.id {
            self = .guildEmoji(name: emoji.name, id: id)
        } else if let name = emoji.name {
            self = try .unicodeEmoji(name)
        } else {
            throw Error.cantConvertEmoji(emoji)
        }
    }

    /// Is the same as the partial emoji?
    public func `is`(_ emoji: Emoji) -> Bool {
        switch self.base {
        case let .unicodeEmoji(unicode): return unicode == emoji.name
        case let .guildEmoji(_, id): return id == emoji.id
        }
    }
}
