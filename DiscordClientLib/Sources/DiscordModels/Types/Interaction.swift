import Foundation

/// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-structure
public struct Interaction: Sendable, Codable {

    public enum Error: Swift.Error, CustomStringConvertible {
        case optionNotFoundInCommand(name: String, command: ApplicationCommand)
        case optionNotFoundInOption(name: String, parentOption: ApplicationCommand.Option)
        case optionNotFoundInOptions(name: String, options: [ApplicationCommand.Option]?)

        case componentNotFoundInComponents(customId: String, components: [ActionRow.Component])
        case componentNotFoundInActionRow(customId: String, actionRow: ActionRow)
        case componentNotFoundInActionRows(customId: String, actionRows: [ActionRow])

        case componentWasNotOfKind(kind: String, component: ActionRow.Component)

        case dataWasNotOfKind(kind: String, data: Interaction.Data)

        public var description: String {
            switch self {
            case let .optionNotFoundInCommand(name, command):
                return "Interaction.Error.optionNotFoundInCommand(name: \(name), command: \(command))"
            case let .optionNotFoundInOption(name, parentOption):
                return "Interaction.Error.optionNotFoundInOption(name: \(name), parentOption: \(parentOption))"
            case let .optionNotFoundInOptions(name, options):
                return
                    "Interaction.Error.optionNotFoundInOption(name: \(name), options: \(String(describing: options)))"
            case let .componentNotFoundInComponents(customId, components):
                return
                    "Interaction.Error.componentNotFoundInComponents(customId: \(customId), components: \(components))"
            case let .componentNotFoundInActionRow(customId, actionRow):
                return "Interaction.Error.componentNotFoundInActionRow(customId: \(customId), actionRow: \(actionRow))"
            case let .componentNotFoundInActionRows(customId, actionRows):
                return
                    "Interaction.Error.componentNotFoundInActionRows(customId: \(customId), actionRows: \(actionRows))"
            case let .componentWasNotOfKind(kind, component):
                return "Interaction.Error.componentWasNotOfKind(kind: \(kind), component: \(component))"
            case let .dataWasNotOfKind(kind, data):
                return "Interaction.Error.dataWasNotOfKind(kind: \(kind), data: \(data))"
            }
        }
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-type
    @UnstableEnum<Int>
    public enum Kind: Sendable, Codable {
        case ping  // 1
        case applicationCommand  // 2
        case messageComponent  // 3
        case applicationCommandAutocomplete  // 4
        case modalSubmit  // 5
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-context-types
    @_spi(UserInstallableApps)
    @UnstableEnum<Int>
    public enum ContextKind: Sendable, Codable {
        case guild  // 0
        case botDm  // 1
        case privateChannel  // 2
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-data-structure
    public struct ApplicationCommand: Sendable, Codable {

        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-resolved-data-structure
        public struct ResolvedData: Sendable, Codable {

            /// https://discord.com/developers/docs/resources/channel#channel-object-channel-structure
            /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-resolved-data-structure
            public struct PartialChannel: Sendable, Codable {
                public var id: ChannelSnowflake
                public var type: DiscordChannel.Kind
                public var name: String?
                public var permissions: StringBitField<Permission>?
                public var parent_id: AnySnowflake?
                public var thread_metadata: ThreadMetadata?
            }

            public var users: [UserSnowflake: DiscordUser]?
            public var members: [UserSnowflake: Guild.PartialMember]?
            public var roles: [RoleSnowflake: Role]?
            public var channels: [ChannelSnowflake: PartialChannel]?
            public var messages: [MessageSnowflake: DiscordChannel.PartialMessage]?
            public var attachments: [AttachmentSnowflake: DiscordChannel.Message.Attachment]?
        }

        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-interaction-data-option-structure
        public struct Option: Sendable, Codable {
            public var name: String
            public var type: DiscordModels.ApplicationCommand.Option.Kind
            public var value: StringIntDoubleBool?
            public var options: [Option]?
            public var focused: Bool?

            /// Requires a `String` value or throws `StringIntDoubleBool.Error`/`OptionalError`.
            @inlinable
            public func requireString(
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> String {
                try self.value
                    .requireValue(file: file, function: function, line: line)
                    .requireString()
            }

            /// Requires a `Int` value or throws `StringIntDoubleBool.Error`/`OptionalError`.
            @inlinable
            public func requireInt(
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> Int {
                try self.value
                    .requireValue(file: file, function: function, line: line)
                    .requireInt()
            }

            /// Requires a `Double` value or throws `StringIntDoubleBool.Error`/`OptionalError`.
            @inlinable
            public func requireDouble(
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> Double {
                try self.value
                    .requireValue(file: file, function: function, line: line)
                    .requireDouble()
            }

            /// Requires a `Bool` value or throws `StringIntDoubleBool.Error`/`OptionalError`.
            @inlinable
            public func requireBool(
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> Bool {
                try self.value
                    .requireValue(file: file, function: function, line: line)
                    .requireBool()
            }

            /// Returns the option with the `name`, or `nil`.
            @inlinable
            public func option(named name: String) -> Option? {
                self.options?.first(where: { $0.name == name })
            }

            /// Returns the option with the `name`, or throws `Interaction.Error`/`OptionalError`.
            @inlinable
            public func requireOption(
                named name: String,
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> Option {
                let options = try self.options.requireValue(
                    file: file,
                    function: function,
                    line: line
                )
                if let option = options.first(where: { $0.name == name }) {
                    return option
                } else {
                    throw Error.optionNotFoundInOption(name: name, parentOption: self)
                }
            }
        }

        public var id: CommandSnowflake
        public var name: String
        public var type: Kind
        public var resolved: ResolvedData?
        public var options: [Option]?
        public var guild_id: GuildSnowflake?
        public var target_id: AnySnowflake?

        /// Returns the option with the `name`, or `nil`.
        @inlinable
        public func option(named name: String) -> Option? {
            self.options?.first(where: { $0.name == name })
        }

        /// Returns the option with the `name`, or throws `Interaction.Error`/`OptionalError`.
        @inlinable
        public func requireOption(
            named name: String,
            file: String = #file,
            function: String = #function,
            line: UInt = #line
        ) throws -> Option {
            let options = try self.options.requireValue(
                file: file,
                function: function,
                line: line
            )
            if let option = options.first(where: { $0.name == name }) {
                return option
            } else {
                throw Error.optionNotFoundInCommand(name: name, command: self)
            }
        }
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-message-component-data-structure
    public struct MessageComponent: Sendable, Codable {
        public var custom_id: String
        public var component_type: ActionRow.Kind
        public var values: [String]?
        public var resolved: Interaction.ApplicationCommand.ResolvedData?
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-modal-submit-data-structure
    public struct ModalSubmit: Sendable, Codable {
        public var custom_id: String
        public var components: [ActionRow]
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-data
    public enum Data: Sendable {
        case applicationCommand(ApplicationCommand)
        case messageComponent(MessageComponent)
        case modalSubmit(ModalSubmit)

        /// Requires an `ApplicationCommand` value or throws `Interaction.Error`.
        public func requireApplicationCommand() throws -> ApplicationCommand {
            switch self {
            case let .applicationCommand(applicationCommand):
                return applicationCommand
            default:
                throw Error.dataWasNotOfKind(kind: "applicationCommand", data: self)
            }
        }

        /// Requires a `MessageComponent` value or throws `Interaction.Error`.
        public func requireMessageComponent() throws -> MessageComponent {
            switch self {
            case let .messageComponent(messageComponent):
                return messageComponent
            default:
                throw Error.dataWasNotOfKind(kind: "messageComponent", data: self)
            }
        }

        /// Requires a `ModalSubmit` value or throws `Interaction.Error`.
        public func requireModalSubmit() throws -> ModalSubmit {
            switch self {
            case let .modalSubmit(modalSubmit):
                return modalSubmit
            default:
                throw Error.dataWasNotOfKind(kind: "modalSubmit", data: self)
            }
        }
    }

    public var id: InteractionSnowflake
    public var application_id: ApplicationSnowflake
    public var type: Kind
    public var data: Data?
    public var guild: PartialGuild?
    public var guild_id: GuildSnowflake?
    public var channel_id: ChannelSnowflake?
    public var channel: DiscordChannel?
    public var member: Guild.Member?
    public var user: DiscordUser?
    public var token: String
    public var version: Int
    public var message: DiscordChannel.Message?
    public var locale: DiscordLocale?
    public var guild_locale: DiscordLocale?
    public var app_permissions: StringBitField<Permission>?
    public var entitlements: [Entitlement]
    @_spi(UserInstallableApps) /// No @DecodeOrNil because there is a manual init(from:)
    public var authorizing_integration_owners: [DiscordApplication.IntegrationKind: AnySnowflake]?
    @_spi(UserInstallableApps) /// No @DecodeOrNil because there is a manual init(from:)
    public var context: ContextKind?

    @available(
        *,
        deprecated,
        message:
            "This property is not documented and will be removed in a future version of DiscordBM, unless it becomes documented. Will always be nil for now"
    )
    public var entitlement_sku_ids: [String]? = nil

    enum CodingKeys: CodingKey {
        case id
        case application_id
        case type
        case data
        case guild
        case guild_id
        case channel_id
        case channel
        case member
        case user
        case token
        case version
        case message
        case locale
        case guild_locale
        case app_permissions
        case entitlements
        case authorizing_integration_owners
        case context
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(InteractionSnowflake.self, forKey: .id)
        self.application_id = try container.decode(
            ApplicationSnowflake.self,
            forKey: .application_id
        )
        self.type = try container.decode(Interaction.Kind.self, forKey: .type)
        switch self.type {
        case .applicationCommand, .applicationCommandAutocomplete:
            self.data = .applicationCommand(
                try container.decode(ApplicationCommand.self, forKey: .data)
            )
        case .messageComponent:
            self.data = .messageComponent(
                try container.decode(MessageComponent.self, forKey: .data)
            )
        case .modalSubmit:
            self.data = .modalSubmit(
                try container.decode(ModalSubmit.self, forKey: .data)
            )
        case .ping:
            self.data = nil
        case .__undocumented:
            self.data = nil
        }
        self.guild = try container.decodeIfPresent(PartialGuild.self, forKey: .guild)
        self.guild_id = try container.decodeIfPresent(GuildSnowflake.self, forKey: .guild_id)
        self.channel_id = try container.decodeIfPresent(
            ChannelSnowflake.self,
            forKey: .channel_id
        )
        self.channel = try container.decodeIfPresent(DiscordChannel.self, forKey: .channel)
        self.member = try container.decodeIfPresent(Guild.Member.self, forKey: .member)
        self.user = try container.decodeIfPresent(DiscordUser.self, forKey: .user)
        self.token = try container.decode(String.self, forKey: .token)
        self.version = try container.decode(Int.self, forKey: .version)
        self.message = try container.decodeIfPresent(DiscordChannel.Message.self, forKey: .message)
        self.locale = try container.decodeIfPresent(DiscordLocale.self, forKey: .locale)
        self.guild_locale = try container.decodeIfPresent(DiscordLocale.self, forKey: .guild_locale)
        self.app_permissions = try container.decodeIfPresent(
            StringBitField<Permission>.self,
            forKey: .app_permissions
        )
        self.entitlements = try container.decode(
            [Entitlement].self,
            forKey: .entitlements
        )
        self.authorizing_integration_owners = try? container.decode(
            [DiscordApplication.IntegrationKind: AnySnowflake].self,
            forKey: .authorizing_integration_owners
        )
        self.context = try? container.decodeIfPresent(
            ContextKind.self,
            forKey: .context
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.id, forKey: .id)
        try container.encode(self.application_id, forKey: .application_id)
        try container.encode(self.type, forKey: .type)
        switch self.data {
        case .applicationCommand(let command):
            try container.encode(command, forKey: .data)
        case .messageComponent(let component):
            try container.encode(component, forKey: .data)
        case .modalSubmit(let modal):
            try container.encode(modal, forKey: .data)
        case .none: break
        }
        try container.encodeIfPresent(self.guild, forKey: .guild)
        try container.encodeIfPresent(self.guild_id, forKey: .guild_id)
        try container.encodeIfPresent(self.channel_id, forKey: .channel_id)
        try container.encodeIfPresent(self.member, forKey: .member)
        try container.encodeIfPresent(self.user, forKey: .user)
        try container.encode(self.token, forKey: .token)
        try container.encode(self.version, forKey: .version)
        try container.encodeIfPresent(self.message, forKey: .message)
        try container.encodeIfPresent(self.locale, forKey: .locale)
        try container.encodeIfPresent(self.guild_locale, forKey: .guild_locale)
        try container.encodeIfPresent(self.app_permissions, forKey: .app_permissions)
        try container.encode(self.entitlements, forKey: .entitlements)
    }
}

extension [Interaction.ApplicationCommand.Option] {
    /// Returns the option with the `name`, or `nil`.
    @inlinable
    public func option(named name: String) -> Interaction.ApplicationCommand.Option? {
        self.first(where: { $0.name == name })
    }

    /// Returns the option with the `name`, or throws `Interaction.Error`.
    @inlinable
    public func requireOption(named name: String) throws -> Interaction.ApplicationCommand.Option {
        if let option = self.first(where: { $0.name == name }) {
            return option
        } else {
            throw Interaction.Error.optionNotFoundInOptions(name: name, options: self)
        }
    }
}

/// https://discord.com/developers/docs/interactions/receiving-and-responding#message-interaction-object-message-interaction-structure
public struct MessageInteraction: Sendable, Codable {
    /// FIXME: This is an `InteractionSnowflake`.
    public var id: String
    /// The same as `id`, but with the correct type of `InteractionSnowflake`.
    /// FIXME: Remove when the type of `id` is corrected.
    public var interaction_id: InteractionSnowflake {
        get {
            InteractionSnowflake(self.id)
        }
        set {
            self.id = newValue.rawValue
        }
    }
    public var type: Interaction.Kind
    public var name: String
    public var user: DiscordUser
    public var member: Guild.PartialMember?
}

extension Interaction {
    /// https://discord.com/developers/docs/interactions/message-components#action-rows
    /// `ActionRow` is an attempt to simplify/beautify Discord's messy components.
    /// Anything inside `ActionRow` must not be used on its own for decoding/encoding purposes.
    /// For example you always need to use `[ActionRow]` instead of `[ActionRow.Component]`.
    public struct ActionRow: Sendable, Codable, ExpressibleByArrayLiteral, ValidatablePayload {

        /// https://discord.com/developers/docs/interactions/message-components#component-object-component-types
        @UnstableEnum<Int>
        public enum Kind: Sendable, Codable {
            case actionRow  // 1
            case button  // 2
            case stringSelect  // 3
            case textInput  // 4
            case userSelect  // 5
            case roleSelect  // 6
            case mentionableSelect  // 7
            case channelSelect  // 8
            case __undocumented(Int)
        }

        /// https://discord.com/developers/docs/interactions/message-components#button-object-button-structure
        public struct Button: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/interactions/message-components#button-object-button-styles
            @UnstableEnum<Int>
            public enum Style: Sendable, Codable {
                case primary  // 1
                case secondary  // 2
                case success  // 3
                case danger  // 4
                case link  // 5
                case __undocumented(Int)
            }

            /// The same as ``Style``, but has no `link`.
            /// https://discord.com/developers/docs/interactions/message-components#button-object-button-styles
            public enum NonLinkStyle: Sendable {
                case primary
                case secondary
                case success
                case danger

                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE

                public func toStyle() -> Style {
                    switch self {
                    case .primary: return .primary
                    case .secondary: return .secondary
                    case .success: return .success
                    case .danger: return .danger
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError(
                            "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
                        )
                    }
                }

                public init?(style: Style) {
                    switch style {
                    case .primary: self = .primary
                    case .secondary: self = .secondary
                    case .success: self = .success
                    case .danger: self = .danger
                    case .link: return nil
                    case .__undocumented: return nil
                    }
                }
            }

            public var style: Style
            public var label: String?
            public var emoji: Emoji?
            public var custom_id: String?
            public var url: String?
            public var disabled: Bool?

            /// Makes a non-link button.
            public init(
                style: NonLinkStyle,
                label: String,
                custom_id: String,
                disabled: Bool? = nil
            ) {
                self.style = style.toStyle()
                self.label = label
                self.emoji = nil
                self.custom_id = custom_id
                self.disabled = disabled
            }

            /// Makes a non-link button.
            public init(
                style: NonLinkStyle,
                emoji: Emoji,
                custom_id: String,
                disabled: Bool? = nil
            ) {
                self.style = style.toStyle()
                self.label = nil
                self.emoji = emoji
                self.custom_id = custom_id
                self.disabled = disabled
            }

            /// Makes a non-link button.
            public init(
                style: NonLinkStyle,
                label: String,
                emoji: Emoji,
                custom_id: String,
                disabled: Bool? = nil
            ) {
                self.style = style.toStyle()
                self.label = label
                self.emoji = emoji
                self.custom_id = custom_id
                self.disabled = disabled
            }

            /// Makes a link button.
            public init(
                label: String,
                url: String,
                disabled: Bool? = nil
            ) {
                self.style = .link
                self.label = label
                self.emoji = nil
                self.url = url
                self.disabled = disabled
            }

            /// Makes a link button.
            public init(
                emoji: Emoji,
                url: String,
                disabled: Bool? = nil
            ) {
                self.style = .link
                self.label = nil
                self.emoji = emoji
                self.url = url
                self.disabled = disabled
            }

            /// Makes a link button.
            public init(
                label: String,
                emoji: Emoji,
                url: String,
                disabled: Bool? = nil
            ) {
                self.style = .link
                self.label = label
                self.emoji = emoji
                self.url = url
                self.disabled = disabled
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountDoesNotExceed(label, max: 80, name: "label")
                validateCharacterCountDoesNotExceed(custom_id, max: 100, name: "custom_id")
            }
        }

        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-menu-structure
        public struct StringSelectMenu: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-option-structure
            public struct Option: Sendable, Codable, ValidatablePayload {
                public var label: String
                public var value: String
                public var description: String?
                public var emoji: Emoji?
                public var `default`: Bool?

                public init(
                    label: String,
                    value: String,
                    description: String? = nil,
                    emoji: Emoji? = nil,
                    `default`: Bool? = nil
                ) {
                    self.label = label
                    self.value = value
                    self.description = description
                    self.emoji = emoji
                    self.`default` = `default`
                }

                public func validate() -> [ValidationFailure] {
                    validateCharacterCountDoesNotExceed(label, max: 100, name: "label")
                    validateCharacterCountDoesNotExceed(value, max: 100, name: "value")
                    validateCharacterCountDoesNotExceed(description, max: 100, name: "description")
                }
            }

            public var custom_id: String
            public var options: [Option]
            public var placeholder: String?
            public var min_values: Int?
            public var max_values: Int?
            public var disabled: Bool?

            public init(
                custom_id: String,
                options: [Option],
                placeholder: String? = nil,
                min_values: Int? = nil,
                max_values: Int? = nil,
                disabled: Bool? = nil
            ) {
                self.custom_id = custom_id
                self.options = options
                self.placeholder = placeholder
                self.min_values = min_values
                self.max_values = max_values
                self.disabled = disabled
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountDoesNotExceed(custom_id, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(placeholder, max: 150, name: "placeholder")
                validateNumberInRangeOrNil(min_values, min: 0, max: 25, name: "min_values")
                validateNumberInRangeOrNil(max_values, min: 1, max: 25, name: "max_values")
                validateElementCountDoesNotExceed(options, max: 25, name: "options")
                options.validate()
            }
        }

        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-default-value-structure
        public struct DefaultValue: Sendable, Codable {

            /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-default-value-structure
            public enum Kind: String, Sendable, Codable {
                case user
                case role
                case channel
            }

            public var id: AnySnowflake
            public var type: Kind

            public init(id: UserSnowflake) {
                self.id = AnySnowflake(id)
                self.type = .user
            }

            public init(id: RoleSnowflake) {
                self.id = AnySnowflake(id)
                self.type = .role
            }

            public init(id: ChannelSnowflake) {
                self.id = AnySnowflake(id)
                self.type = .channel
            }
        }

        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-menu-structure
        public struct ChannelSelectMenu: Sendable, Codable, ValidatablePayload {
            public var custom_id: String
            public var channel_types: [DiscordChannel.Kind]?
            public var placeholder: String?
            public var default_values: [DefaultValue]?
            public var min_values: Int?
            public var max_values: Int?
            public var disabled: Bool?

            public init(
                custom_id: String,
                channel_types: [DiscordChannel.Kind]? = nil,
                placeholder: String? = nil,
                default_values: [DefaultValue]? = nil,
                min_values: Int? = nil,
                max_values: Int? = nil,
                disabled: Bool? = nil
            ) {
                self.custom_id = custom_id
                self.channel_types = channel_types
                self.placeholder = placeholder
                self.default_values = default_values
                self.min_values = min_values
                self.max_values = max_values
                self.disabled = disabled
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountDoesNotExceed(custom_id, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(placeholder, max: 150, name: "placeholder")
                validateNumberInRangeOrNil(min_values, min: 0, max: 25, name: "min_values")
                validateNumberInRangeOrNil(max_values, min: 1, max: 25, name: "max_values")
            }
        }

        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-menu-structure
        public struct SelectMenu: Sendable, Codable, ValidatablePayload {
            public var custom_id: String
            public var placeholder: String?
            public var default_values: [DefaultValue]?
            public var min_values: Int?
            public var max_values: Int?
            public var disabled: Bool?

            public init(
                custom_id: String,
                placeholder: String? = nil,
                default_values: [DefaultValue]? = nil,
                min_values: Int? = nil,
                max_values: Int? = nil,
                disabled: Bool? = nil
            ) {
                self.custom_id = custom_id
                self.placeholder = placeholder
                self.default_values = default_values
                self.min_values = min_values
                self.max_values = max_values
                self.disabled = disabled
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountDoesNotExceed(custom_id, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(placeholder, max: 150, name: "placeholder")
                validateNumberInRangeOrNil(min_values, min: 0, max: 25, name: "min_values")
                validateNumberInRangeOrNil(max_values, min: 1, max: 25, name: "max_values")
                validateElementCountInRange(
                    default_values,
                    min: min_values ?? 0,
                    max: max_values ?? .max,
                    name: "default_values"
                )
            }
        }

        /// https://discord.com/developers/docs/interactions/message-components#text-inputs
        public struct TextInput: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/interactions/message-components#text-inputs-text-input-styles
            @UnstableEnum<Int>
            public enum Style: Sendable, Codable {
                case short  // 1
                case paragraph  // 2
                case __undocumented(Int)
            }

            public var custom_id: String
            public var style: Style?
            public var label: String?
            public var min_length: Int?
            public var max_length: Int?
            public var required: Bool?
            public var value: String?
            public var placeholder: String?

            public init(
                custom_id: String,
                style: Style? = nil,
                label: String? = nil,
                min_length: Int? = nil,
                max_length: Int? = nil,
                required: Bool? = nil,
                value: String? = nil,
                placeholder: String? = nil
            ) {
                self.custom_id = custom_id
                self.style = style
                self.label = label
                self.min_length = min_length
                self.max_length = max_length
                self.required = required
                self.value = value
                self.placeholder = placeholder
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountDoesNotExceed(custom_id, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(label, max: 45, name: "label")
                validateNumberInRangeOrNil(min_length, min: 0, max: 4_000, name: "min_length")
                validateNumberInRangeOrNil(max_length, min: 1, max: 4_000, name: "max_length")
                validateCharacterCountDoesNotExceed(value, max: 4_000, name: "value")
                validateCharacterCountDoesNotExceed(placeholder, max: 100, name: "value")
            }
        }

        public enum Component: Sendable, Codable, ValidatablePayload {
            case button(Button)
            case stringSelect(StringSelectMenu)
            case textInput(TextInput)
            case userSelect(SelectMenu)
            case roleSelect(SelectMenu)
            case mentionableSelect(SelectMenu)
            case channelSelect(ChannelSelectMenu)
            case __undocumented

            public var customId: String? {
                switch self {
                case let .button(value):
                    return value.custom_id
                case let .stringSelect(value):
                    return value.custom_id
                case let .textInput(value):
                    return value.custom_id
                case let .userSelect(value):
                    return value.custom_id
                case let .roleSelect(value):
                    return value.custom_id
                case let .mentionableSelect(value):
                    return value.custom_id
                case let .channelSelect(value):
                    return value.custom_id
                case .__undocumented:
                    return nil
                }
            }

            enum CodingKeys: String, CodingKey {
                case type
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(Kind.self, forKey: .type)
                switch type {
                case .actionRow:
                    throw CodingError.actionRowIsSupposedToOnlyAppearAtTopLevel
                case .button:
                    self = try .button(.init(from: decoder))
                case .stringSelect:
                    self = try .stringSelect(.init(from: decoder))
                case .userSelect:
                    self = try .userSelect(.init(from: decoder))
                case .roleSelect:
                    self = try .roleSelect(.init(from: decoder))
                case .mentionableSelect:
                    self = try .mentionableSelect(.init(from: decoder))
                case .channelSelect:
                    self = try .channelSelect(.init(from: decoder))
                case .textInput:
                    self = try .textInput(.init(from: decoder))
                case .__undocumented:
                    self = .__undocumented
                }
            }

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case let .button(button):
                    try container.encode(Kind.button, forKey: .type)
                    try button.encode(to: encoder)
                case let .stringSelect(selectMenu):
                    try container.encode(Kind.stringSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .textInput(textInput):
                    try container.encode(Kind.textInput, forKey: .type)
                    try textInput.encode(to: encoder)
                case let .userSelect(selectMenu):
                    try container.encode(Kind.userSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .roleSelect(selectMenu):
                    try container.encode(Kind.roleSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .mentionableSelect(selectMenu):
                    try container.encode(Kind.mentionableSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .channelSelect(selectMenu):
                    try container.encode(Kind.channelSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case .__undocumented: break
                }
            }

            /// Returns the associated value if the component case is `button`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireButton() throws -> Button {
                switch self {
                case let .button(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "button", component: self)
                }
            }

            /// Returns the associated value if the component case is `stringSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireStringSelect() throws -> StringSelectMenu {
                switch self {
                case let .stringSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "stringSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `textInput`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireTextInput() throws -> TextInput {
                switch self {
                case let .textInput(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "textInput", component: self)
                }
            }

            /// Returns the associated value if the component case is `userSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireUserSelect() throws -> SelectMenu {
                switch self {
                case let .userSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "userSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `roleSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireRoleSelect() throws -> SelectMenu {
                switch self {
                case let .roleSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "roleSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `mentionableSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireMentionableSelect() throws -> SelectMenu {
                switch self {
                case let .mentionableSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "mentionableSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `channelSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireChannelSelect() throws -> ChannelSelectMenu {
                switch self {
                case let .channelSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "channelSelect", component: self)
                }
            }

            public func validate() -> [ValidationFailure] {
                switch self {
                case .button(let button):
                    button.validate()
                case .stringSelect(let stringSelectMenu):
                    stringSelectMenu.validate()
                case .textInput(let textInput):
                    textInput.validate()
                case .userSelect(let selectMenu):
                    selectMenu.validate()
                case .roleSelect(let selectMenu):
                    selectMenu.validate()
                case .mentionableSelect(let selectMenu):
                    selectMenu.validate()
                case .channelSelect(let channelSelectMenu):
                    channelSelectMenu.validate()
                case .__undocumented:
                    Optional<ValidationFailure>.none
                }
            }
        }

        public var components: [Component]

        public enum CodingError: Swift.Error, CustomStringConvertible {
            /// This component kind was not expected here. This is a library decoding issue, please report at: https://github.com/DiscordBM/DiscordBM/issues.
            case unexpectedComponentKind(Kind)
            /// I thought action-row is supposed to only appear at top-level as a container for other components. This is a library decoding issue, please report at: https://github.com/DiscordBM/DiscordBM/issues.
            case actionRowIsSupposedToOnlyAppearAtTopLevel

            public var description: String {
                switch self {
                case let .unexpectedComponentKind(kind):
                    return "Interaction.ActionRow.CodingError.unexpectedComponentKind(\(kind))"
                case .actionRowIsSupposedToOnlyAppearAtTopLevel:
                    return "Interaction.ActionRow.CodingError.actionRowIsSupposedToOnlyAppearAtTopLevel"
                }
            }
        }

        enum CodingKeys: String, CodingKey {
            case type
            case components
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(Kind.self, forKey: .type)
            guard type == .actionRow else {
                throw CodingError.unexpectedComponentKind(type)
            }
            self.components = try container.decode([Component].self, forKey: .components)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(Kind.actionRow, forKey: .type)
            try container.encode(self.components, forKey: .components)
        }

        public init(components: [Component]) {
            self.components = components
        }

        public init(arrayLiteral elements: Component...) {
            self.components = elements
        }

        /// Returns the component with the `customId`, or `nil`.
        @inlinable
        public func component(customId: String) -> Component? {
            self.components.first(where: { $0.customId == customId })
        }

        /// Returns the component with the `customId`, or throws `Interaction.Error`.
        @inlinable
        public func requireComponent(customId: String) throws -> Component {
            if let component = self.components.first(where: { $0.customId == customId }) {
                return component
            } else {
                throw Error.componentNotFoundInActionRow(customId: customId, actionRow: self)
            }
        }

        public func validate() -> [ValidationFailure] {
            components.validate()
        }
    }
}

extension [Interaction.ActionRow] {
    /// Returns the component with the `customId`, or `nil`.
    @inlinable
    public func component(customId: String) -> Interaction.ActionRow.Component? {
        self.flatMap(\.components).first(where: { $0.customId == customId })
    }

    /// Returns the component with the `customId`, or throws `Interaction.Error`.
    @inlinable
    public func requireComponent(customId: String) throws -> Interaction.ActionRow.Component {
        if let component = self.flatMap(\.components).first(where: { $0.customId == customId }) {
            return component
        } else {
            throw Interaction.Error.componentNotFoundInActionRows(
                customId: customId,
                actionRows: self
            )
        }
    }
}

extension [Interaction.ActionRow.Component] {
    /// Returns the component with the `customId`, or `nil`.
    @inlinable
    public func component(customId: String) -> Interaction.ActionRow.Component? {
        self.first(where: { $0.customId == customId })
    }

    /// Returns the component with the `customId`, or throws `Interaction.Error`.
    @inlinable
    public func requireComponent(customId: String) throws -> Interaction.ActionRow.Component {
        if let component = self.first(where: { $0.customId == customId }) {
            return component
        } else {
            throw Interaction.Error.componentNotFoundInComponents(
                customId: customId,
                components: self
            )
        }
    }
}
