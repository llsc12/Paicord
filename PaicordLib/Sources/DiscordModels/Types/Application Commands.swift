import Foundation

/// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-structure
public struct ApplicationCommand: Sendable, Codable {

    /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-types
    @UnstableEnum<UInt>
    public enum Kind: Sendable, Codable {
        case chatInput  // 1
        case user  // 2
        case message  // 3
        case __undocumented(UInt)
    }

    /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-structure
    public struct Option: Sendable, Codable, ValidatablePayload {

        /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-type
        @UnstableEnum<UInt>
        public enum Kind: Sendable, Codable {
            case subCommand  // 1
            case subCommandGroup  // 2
            case string  // 3
            case integer  // 4
            case boolean  // 5
            case user  // 6
            case channel  // 7
            case role  // 8
            case mentionable  // 9
            case number  // 10
            case attachment  // 11
            case __undocumented(UInt)
        }

        /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-choice-structure
        public struct Choice: Sendable, Codable, ValidatablePayload {
            public var name: String
            public var name_localizations: DiscordLocaleDict<String>?
            public var value: StringIntDoubleBool

            public var name_localized: String?

            public init(name: String, name_localizations: [DiscordLocale: String]? = nil, value: StringIntDoubleBool) {
                self.name = name
                self.name_localizations = .init(name_localizations)
                self.value = value
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
                if case let .string(string) = value {
                    validateCharacterCountInRange(string, min: 1, max: 100, name: "value")
                }
                for (key, value) in name_localizations?.values ?? [:] {
                    validateCharacterCountInRange(
                        value,
                        min: 1,
                        max: 100,
                        name: "name_localizations.\(key.rawValue)"
                    )
                }
            }
        }

        public var type: Kind
        public var name: String
        public var name_localizations: DiscordLocaleDict<String>?
        public var description: String
        public var description_localizations: DiscordLocaleDict<String>?
        public var required: Bool?
        public var choices: [Choice]?
        public var options: [Option]?
        public var channel_types: [DiscordChannel.Kind]?
        public var min_value: IntOrDouble?
        public var max_value: IntOrDouble?
        public var min_length: Int?
        public var max_length: Int?
        public var autocomplete: Bool?

        public init(
            type: Kind,
            name: String,
            name_localizations: [DiscordLocale: String]? = nil,
            description: String,
            description_localizations: [DiscordLocale: String]? = nil,
            required: Bool? = nil,
            choices: [Choice]? = nil,
            options: [Option]? = nil,
            channel_types: [DiscordChannel.Kind]? = nil,
            min_value: IntOrDouble? = nil,
            max_value: IntOrDouble? = nil,
            min_length: Int? = nil,
            max_length: Int? = nil,
            autocomplete: Bool? = nil
        ) {
            self.type = type
            self.name = name
            self.name_localizations = .init(name_localizations)
            self.description = description
            self.description_localizations = .init(description_localizations)
            self.required = required
            self.choices = choices
            self.options = options
            self.channel_types = channel_types == nil ? nil : .init(channel_types!)
            self.min_value = min_value
            self.max_value = max_value
            self.min_length = min_length
            self.max_length = max_length
            self.autocomplete = autocomplete
        }

        public func validate() -> [ValidationFailure] {
            validateNumberInRangeOrNil(min_length, min: 0, max: 6_000, name: "min_length")
            validateNumberInRangeOrNil(max_length, min: 0, max: 6_000, name: "max_length")
            validateElementCountDoesNotExceed(choices, max: 25, name: "choices")
            validateCharacterCountInRange(name, min: 1, max: 32, name: "name")
            validateCharacterCountInRange(description, min: 1, max: 100, name: "description")
            validateHasPrecondition(
                condition: autocomplete == true,
                allowedIf: [.string, .integer, .number].contains(type),
                name: "autocomplete",
                reason: "'autocomplete' is only allowed if 'type' is 'string' or 'integer' or 'number'"
            )
            validateHasPrecondition(
                condition: autocomplete == true,
                allowedIf: choices?.isEmpty != false,
                name: "autocomplete",
                reason: "'autocomplete' is only allowed if 'choices' is not present"
            )
            validateHasPrecondition(
                condition: (min_value != nil) || (max_value != nil),
                allowedIf: [.integer, .number].contains(type),
                name: "min_value+max_value",
                reason: "'min_value' or 'max_value' are only allowed if 'type' is 'integer' or 'number'"
            )
            validateHasPrecondition(
                condition: (min_length != nil) || (max_length != nil),
                allowedIf: type == .string,
                name: "min_length+max_length",
                reason: "'min_length' or 'max_length' are only allowed if 'type' is 'string'"
            )
            validateHasPrecondition(
                condition: choices?.isEmpty == false,
                allowedIf: [.string, .integer, .number].contains(type),
                name: "choices",
                reason: "'choices' is only allowed if 'type' is 'string' or 'integer' or 'number'"
            )
            choices?.validate()
            validateElementCountDoesNotExceed(options, max: 25, name: "options")
            options?.validate()
        }
    }

    public var id: CommandSnowflake
    public var type: Kind?
    public var application_id: ApplicationSnowflake
    public var guild_id: GuildSnowflake?
    public var name: String
    public var name_localizations: DiscordLocaleDict<String>?
    /// Only for endpoints like get-application-commands
    public var name_localized: String?
    public var description: String
    public var description_localizations: DiscordLocaleDict<String>?
    /// Only for endpoints like get-application-commands
    public var description_localized: String?
    public var options: [Option]?
    public var default_member_permissions: StringBitField<Permission>?
    public var dm_permission: Bool?
    public var nsfw: Bool?
    @_spi(UserInstallableApps) @DecodeOrNil
    public var integration_types: [DiscordApplication.IntegrationKind]?
    @_spi(UserInstallableApps) @DecodeOrNil
    public var contexts: [Interaction.ContextKind]?
    public var version: String?
}

/// https://discord.com/developers/docs/interactions/application-commands#application-command-permissions-object-guild-application-command-permissions-structure
public struct GuildApplicationCommandPermissions: Sendable, Codable {

    /// https://discord.com/developers/docs/interactions/application-commands#application-command-permissions-object-application-command-permissions-structure
    public struct Permission: Sendable, Codable {

        /// https://discord.com/developers/docs/interactions/application-commands#application-command-permissions-object-application-command-permission-type
        @UnstableEnum<Int>
        public enum Kind: Sendable, Codable {
            case role  // 1
            case user  // 2
            case channel  // 3
            case __undocumented(Int)
        }

        public var type: Kind
        public var permission: Bool
        public var id: AnySnowflake

        public init(type: Kind, permission: Bool, id: AnySnowflake) {
            self.type = type
            self.permission = permission
            self.id = id
        }

        public enum ConversionError: Error, CustomStringConvertible {
            /// Couldn't convert \(id) to an integer
            case couldNotConvertToInteger(GuildSnowflake)

            public var description: String {
                switch self {
                case let .couldNotConvertToInteger(string):
                    return
                        "GuildApplicationCommandPermissions.Permission.ConversionError.couldNotConvertToInteger(\(string))"
                }
            }
        }

        public static func allChannels(
            inGuildWithId guildId: GuildSnowflake,
            permission: Bool
        ) throws -> Self {
            guard let guildNumber = Int(guildId.rawValue) else {
                throw ConversionError.couldNotConvertToInteger(guildId)
            }
            return self.init(
                type: .channel,
                permission: permission,
                id: AnySnowflake("\(guildNumber - 1)")
            )
        }

        public static func allMembers(
            inGuildWithId guildId: GuildSnowflake,
            permission: Bool
        ) throws -> Self {
            self.init(type: .user, permission: permission, id: AnySnowflake(guildId))
        }
    }

    public var permissions: [Permission]
    public var id: AnySnowflake
    public var guild_id: GuildSnowflake
    public var application_id: ApplicationSnowflake
}
