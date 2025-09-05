import DiscordModels
import Foundation

/// Utilities for writing Discord messages.
/// https://discord.com/developers/docs/reference#message-formatting-formats
public enum DiscordUtils {
    /// When used in a Discord message, shows up as mentioning a user.
    @inlinable
    public static func mention(id: UserSnowflake) -> String {
        "<@\(id.rawValue)>"
    }

    /// When used in a Discord message, shows up as mentioning a channel.
    @inlinable
    public static func mention(id: ChannelSnowflake) -> String {
        "<#\(id.rawValue)>"
    }

    /// When used in a Discord message, shows up as mentioning a role, if mentionable.
    @inlinable
    public static func mention(id: RoleSnowflake) -> String {
        "<@&\(id.rawValue)>"
    }

    /// When used in a Discord message, shows up as mentioning a slash command.
    @inlinable
    public static func slashCommand(
        name: String,
        id: CommandSnowflake,
        subcommand: String? = nil,
        subcommandGroup: String? = nil
    ) -> String {
        let subcommandGroup = subcommandGroup.map { " \($0)" } ?? ""
        let subcommand = subcommand.map { " \($0)" } ?? ""
        return "</\(name)\(subcommandGroup)\(subcommand):\(id.rawValue)>"
    }

    /// When used in a Discord message, shows up as an emoji.
    @inlinable
    public static func standardUnicodeEmoji(emoji: String) -> String {
        emoji
    }

    /// When used in a Discord message, shows up as a custom guild emoji.
    @inlinable
    public static func customEmoji(name: String, id: EmojiSnowflake) -> String {
        "<:\(name):\(id.rawValue)>"
    }

    /// When used in a Discord message, shows up as a custom animated guild emoji.
    @inlinable
    public static func customAnimatedEmoji(name: String, id: EmojiSnowflake) -> String {
        "<a:\(name):\(id.rawValue)>"
    }

    /// When used in a Discord message, shows up as a **localized** time.
    /// See ``TimestampStyle`` for examples.
    @inlinable
    public static func timestamp(date: Date, style: TimestampStyle? = nil) -> String {
        timestamp(unixTimestamp: Int(date.timeIntervalSince1970), style: style)
    }

    /// When used in a Discord message, shows up as a **localized** time.
    /// See ``TimestampStyle`` for examples.
    @inlinable
    public static func timestamp(unixTimestamp: Double, style: TimestampStyle? = nil) -> String {
        timestamp(unixTimestamp: Int(unixTimestamp), style: style)
    }

    /// When used in a Discord message, shows up as a **localized** time.
    /// See ``TimestampStyle`` for examples.
    @inlinable
    public static func timestamp(unixTimestamp: Int, style: TimestampStyle? = nil) -> String {
        let style = style.map { ":\($0.rawValue)" } ?? ""
        return "<t:\(unixTimestamp)\(style)>"
    }

    /// When used in a Discord message, shows up as a guild-navigation link.
    /// See ``TimestampStyle`` for examples.
    @available(*, unavailable, message: "Not sure what are the 'Navigation Type's")
    @inlinable
    public static func guildNavigation(type: Int) {
        fatalError("unavailable")
    }

    /// Escapes the special characters in the text, for the specified channel type.
    /// - Parameters:
    ///   - text: The text to be escaped.
    ///   - keepLinks: Whether or not to _try_ to keep any kind of protocol links.
    ///   The function will try to not escape protocol schemes such as `http://` and `https://`.
    /// - Returns: The text, but escaped.
    @inlinable
    public static func escapingSpecialCharacters(
        _ text: String,
        options: EscapeOption? = nil
    ) -> String {
        var text =
            text
            .replacingOccurrences(of: #"\"#, with: #"\\"#)
            .replacingOccurrences(of: #"|"#, with: #"\|"#)/// Makes invisible
            .replacingOccurrences(of: #">"#, with: #"\>"#)/// Quotes
            .replacingOccurrences(of: #"@"#, with: #"\@"#)/// `@everyone`. Not 100% effective
            .replacingOccurrences(of: #"<"#, with: #"\<"#)/// `<::>` ids like custom emojis
            .replacingOccurrences(of: #"["#, with: #"\["#)/// Markdown link syntax (`[]()`)
            .replacingOccurrences(of: ###"#"###, with: ###"\#"###)/// For titles, e.g. `### Title`
            .replacingOccurrences(of: #"`"#, with: #"\`"#)/// Code blocks
            .replacingOccurrences(of: #"~"#, with: #"\~"#)/// Crosses words
            .replacingOccurrences(of: #"_"#, with: #"\_"#)/// Italic
            .replacingOccurrences(of: #"*"#, with: #"\*"#)/// Bold
            .replacingOccurrences(of: #":"#, with: #"\:"#)
        /// Emojis, e.g. `:thumbsup:`
        if options?.contains(.keepLinks) == true {
            text = text.replacingOccurrences(of: #"\://"#, with: "://")
        }
        if options?.contains(.escapeNewLines) == true {
            text = text.replacingOccurrences(of: "\n", with: "\\n")
        }
        return text
    }
}

/// https://discord.com/developers/docs/reference#message-formatting-timestamp-styles
public enum TimestampStyle: String {
    /// `16:20`
    case shortTime = "t"
    /// `16:20:30`
    case longTime = "T"
    /// `20/04/2021`
    case shortDate = "d"
    /// `20 April 2021`
    case longDate = "D"
    /// Discord's default.
    /// `20 April 2021 16:20`
    case shortDateTime = "f"
    /// `Tuesday, 20 April 2021 16:20`
    case longDateTime = "F"
    /// `2 months ago` / `in 2 months`
    case relativeTime = "R"
}

/// Options for escaping special characters.
public struct EscapeOption: Sendable, OptionSet {
    public var rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: some BinaryInteger) {
        self.rawValue = .init(rawValue)
    }

    /// _Try_ to keep links and not escape them.
    public static let keepLinks = EscapeOption(rawValue: 1 << 0)

    /// Escape new lines.
    public static let escapeNewLines = EscapeOption(rawValue: 1 << 1)
}
