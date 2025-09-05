/// https://discord.com/developers/docs/resources/audit-log#audit-log-object-audit-log-structure
public struct AuditLog: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-entry-structure
    public struct Entry: Sendable, Codable {

        public enum Mixed: Sendable, Codable, CustomStringConvertible {
            case string(String)
            case int(Int)
            case double(Double)
            case bool(Bool)
            case strings([String])
            case nameId(NameID)
            case nameIds([NameID])
            case permissionOverwrites([DiscordChannel.Overwrite])
            case permission(GuildApplicationCommandPermissions.Permission)
            case actions([AutoModerationRule.Action])
            case other(Other)

            public struct NameID: Sendable, Codable {
                public var name: String
                public var id: String?
            }

            public struct Other: @unchecked Sendable {
                let container: any SingleValueDecodingContainer

                public func decode<D: Decodable>(as: D.Type = D.self) throws -> D {
                    try container.decode(D.self)
                }
            }

            public var description: String {
                switch self {
                case let .string(string): return string
                case let .int(int): return "\(int)"
                case let .double(double): return "\(double)"
                case let .bool(bool): return "\(bool)"
                case let .strings(array): return "\(array)"
                case let .nameId(nameId): return "\(nameId)"
                case let .nameIds(nameIds): return "\(nameIds)"
                case let .permissionOverwrites(overwrites): return "\(overwrites)"
                case let .permission(permission): return "\(permission)"
                case let .actions(actions): return "\(actions)"
                case let .other(other): return "\(other.container)"
                }
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let string = try? container.decode(String.self) {
                    self = .string(string)
                } else if let int = try? container.decode(Int.self) {
                    self = .int(int)
                } else if let bool = try? container.decode(Bool.self) {
                    self = .bool(bool)
                } else if let double = try? container.decode(Double.self) {
                    self = .double(double)
                } else if let array = try? container.decode([String].self) {
                    self = .strings(array)
                } else if let nameId = try? container.decode(NameID.self) {
                    self = .nameId(nameId)
                } else if let nameIds = try? container.decode([NameID].self) {
                    self = .nameIds(nameIds)
                } else if let overwrites = try? container.decode([DiscordChannel.Overwrite].self) {
                    self = .permissionOverwrites(overwrites)
                } else if let permission =
                    try? container
                    .decode(GuildApplicationCommandPermissions.Permission.self)
                {
                    self = .permission(permission)
                } else if let actions = try? container.decode([AutoModerationRule.Action].self) {
                    self = .actions(actions)
                } else {
                    DiscordGlobalConfiguration
                        .makeDecodeLogger("DBM.AuditLog.Entry.Mixed")
                        .warning(
                            "Can't decode a value",
                            metadata: [
                                "codingPath": .stringConvertible(
                                    container.codingPath.map(\.stringValue)
                                ),
                                "container": "\(container)",
                            ]
                        )
                    self = .other(Other(container: container))
                }
            }

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case let .string(string):
                    try container.encode(string)
                case let .int(int):
                    try container.encode(int)
                case let .double(double):
                    try container.encode(double)
                case let .bool(bool):
                    try container.encode(bool)
                case let .strings(array):
                    try container.encode(array)
                case let .nameId(nameId):
                    try container.encode(nameId)
                case let .nameIds(nameIds):
                    try container.encode(nameIds)
                case let .permissionOverwrites(overwrites):
                    try container.encode(overwrites)
                case let .permission(permission):
                    try container.encode(permission)
                case let .actions(actions):
                    try container.encode(actions)
                case let .other(other):
                    DiscordGlobalConfiguration
                        .makeLogger("DBM.AuditLog.Entry.Mixed_EncodingError")
                        .error(
                            "'DiscordBM.AuditLog.Entry.Mixed' can't be encoded",
                            metadata: ["container": "\(other.container)"]
                        )
                }
            }
        }

        /// https://discord.com/developers/docs/resources/audit-log#audit-log-change-object-audit-log-change-structure
        public struct Change: Sendable, Codable {
            public var new_value: Mixed?
            public var old_value: Mixed?
            public var key: String
        }

        /// https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events
        @UnstableEnum<Int>
        public enum ActionKind: Sendable, Codable {
            case guildUpdate  // 1
            case channelCreate  // 10
            case channelUpdate  // 11
            case channelDelete  // 12
            case channelOverwriteCreate  // 13
            case channelOverwriteUpdate  // 14
            case channelOverwriteDelete  // 15
            case memberKick  // 20
            case memberPrune  // 21
            case memberBanAdd  // 22
            case memberBanRemove  // 23
            case memberUpdate  // 24
            case memberRoleUpdate  // 25
            case memberMove  // 26
            case memberDisconnect  // 27
            case botAdd  // 28
            case roleCreate  // 30
            case roleUpdate  // 31
            case roleDelete  // 32
            case inviteCreate  // 40
            case inviteUpdate  // 41
            case inviteDelete  // 42
            case webhookCreate  // 50
            case webhookUpdate  // 51
            case webhookDelete  // 52
            case emojiCreate  // 60
            case emojiUpdate  // 61
            case emojiDelete  // 62
            case messageDelete  // 72
            case messageBulkDelete  // 73
            case messagePin  // 74
            case messageUnpin  // 75
            case integrationCreate  // 80
            case integrationUpdate  // 81
            case integrationDelete  // 82
            case stageInstanceCreate  // 83
            case stageInstanceUpdate  // 84
            case stageInstanceDelete  // 85
            case stickerCreate  // 90
            case stickerUpdate  // 91
            case stickerDelete  // 92
            case guildScheduledEventCreate  // 100
            case guildScheduledEventUpdate  // 101
            case guildScheduledEventDelete  // 102
            case threadCreate  // 110
            case threadUpdate  // 111
            case threadDelete  // 112
            case applicationCommandPermissionUpdate  // 121
            case autoModerationRuleCreate  // 140
            case autoModerationRuleUpdate  // 141
            case autoModerationRuleDelete  // 142
            case autoModerationBlockMessage  // 143
            case autoModerationFlagToChannel  // 144
            case autoModerationUserCommunicationDisabled  // 145
            case creatorMonetizationRequestCreated  // 150
            case creatorMonetizationTermsAccepted  // 151
            case onboardingPromptCreate  // 163
            case onboardingPromptUpdate  // 164
            case onboardingPromptDelete  // 165
            case onboardingCreate  // 166
            case onboardingUpdate  // 167
            case homeSettingsCreate  // 190
            case homeSettingsUpdate  // 191
            case __undocumented(Int)
        }

        /// A mix of the below two types.
        /// https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events
        /// https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-optional-audit-entry-info
        public enum Action: Sendable, Codable {
            case guildUpdate
            case channelCreate
            case channelUpdate
            case channelDelete
            case channelOverwriteCreate(OverwriteInfo)
            case channelOverwriteUpdate(OverwriteInfo)
            case channelOverwriteDelete(OverwriteInfo)
            case memberKick(integration_type: Integration.Kind)
            case memberPrune(delete_member_days: String)
            case memberBanAdd
            case memberBanRemove
            case memberUpdate
            case memberRoleUpdate(integration_type: Integration.Kind?)
            case memberMove(channel_id: ChannelSnowflake, count: String)
            case memberDisconnect(count: String)
            case botAdd
            case roleCreate
            case roleUpdate
            case roleDelete
            case inviteCreate
            case inviteUpdate
            case inviteDelete
            case webhookCreate
            case webhookUpdate
            case webhookDelete
            case emojiCreate
            case emojiUpdate
            case emojiDelete
            case messageDelete(channel_id: ChannelSnowflake, count: String)
            case messageBulkDelete(count: String)
            case messagePin(channel_id: ChannelSnowflake)
            case messageUnpin(channel_id: ChannelSnowflake)
            case integrationCreate
            case integrationUpdate
            case integrationDelete
            case stageInstanceCreate(channel_id: ChannelSnowflake)
            case stageInstanceUpdate(channel_id: ChannelSnowflake)
            case stageInstanceDelete(channel_id: ChannelSnowflake)
            case stickerCreate
            case stickerUpdate
            case stickerDelete
            case guildScheduledEventCreate
            case guildScheduledEventUpdate
            case guildScheduledEventDelete
            case threadCreate
            case threadUpdate
            case threadDelete
            case applicationCommandPermissionUpdate(application_id: ApplicationSnowflake)
            case autoModerationRuleCreate
            case autoModerationRuleUpdate
            case autoModerationRuleDelete
            case autoModerationBlockMessage(AutoModerationInfo)
            case autoModerationFlagToChannel(AutoModerationInfo)
            case autoModerationUserCommunicationDisabled(AutoModerationInfo)
            case creatorMonetizationRequestCreated
            case creatorMonetizationTermsAccepted
            case onboardingPromptCreate
            case onboardingPromptUpdate
            case onboardingPromptDelete
            case onboardingCreate
            case onboardingUpdate
            case homeSettingsCreate
            case homeSettingsUpdate
            case __undocumented

            public struct OverwriteInfo: Sendable, Codable {

                public enum Kind: Sendable {
                    case role(name: String)
                    case member(permission: Bool?)
                }

                public var id: String
                public var type: Kind

                enum CodingKeys: CodingKey {
                    case id
                    case type
                    case permission
                    case role_name
                }

                public init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.id = try container.decode(String.self, forKey: .id)
                    let type = try container.decode(String.self, forKey: .type)
                    switch type {
                    case "0":
                        let roleName = try container.decode(String.self, forKey: .role_name)
                        self.type = .role(name: roleName)
                    case "1":
                        let permission = try container.decodeIfPresent(
                            Bool.self,
                            forKey: .permission
                        )
                        self.type = .member(permission: permission)
                    default:
                        throw DecodingError.keyNotFound(
                            CodingKeys.type,
                            .init(
                                codingPath: decoder.codingPath,
                                debugDescription: "Can't decode from value: '\(type)'"
                            )
                        )
                    }
                }

                public func encode(to encoder: any Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(self.id, forKey: .id)
                    switch type {
                    case .role(let name):
                        try container.encode(name, forKey: .role_name)
                        try container.encode("0", forKey: .type)
                    case .member:
                        try container.encode("1", forKey: .type)
                    }
                }
            }

            public struct AutoModerationInfo: Sendable, Codable {
                public var auto_moderation_rule_name: String
                public var auto_moderation_rule_trigger_type: AutoModerationRule.TriggerKind
                public var channel_id: ChannelSnowflake

                public init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.auto_moderation_rule_name = try container.decode(
                        String.self,
                        forKey: .auto_moderation_rule_name
                    )
                    let triggerType = try container.decode(
                        String.self,
                        forKey: .auto_moderation_rule_trigger_type
                    )
                    if let intTrigger = Int(triggerType),
                        let type = AutoModerationRule.TriggerKind(rawValue: intTrigger)
                    {
                        self.auto_moderation_rule_trigger_type = type
                    } else {
                        throw DecodingError.keyNotFound(
                            CodingKeys.auto_moderation_rule_trigger_type,
                            .init(
                                codingPath: decoder.codingPath,
                                debugDescription: "Can't decode from value: '\(triggerType)'"
                            )
                        )
                    }
                    self.channel_id = try container.decode(
                        ChannelSnowflake.self,
                        forKey: .channel_id
                    )
                }

                enum CodingKeys: CodingKey {
                    case auto_moderation_rule_name
                    case auto_moderation_rule_trigger_type
                    case channel_id
                }

                public func encode(to encoder: any Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(
                        self.auto_moderation_rule_name,
                        forKey: .auto_moderation_rule_name
                    )
                    try container.encode(
                        "\(self.auto_moderation_rule_trigger_type)",
                        forKey: .auto_moderation_rule_trigger_type
                    )
                    try container.encode(self.channel_id, forKey: .channel_id)
                }
            }

            enum CodingKeys: String, CodingKey {
                case action_type
                case options
            }

            enum OptionsCodingKeys: String, CodingKey {
                case delete_member_days
                case channel_id
                case count
                case application_id
                case integration_type
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let actionType = try container.decode(ActionKind.self, forKey: .action_type)
                func optionsNestedContainer() throws -> KeyedDecodingContainer<OptionsCodingKeys> {
                    try container.nestedContainer(
                        keyedBy: OptionsCodingKeys.self,
                        forKey: .options
                    )
                }
                switch actionType {
                case .guildUpdate: self = .guildUpdate
                case .channelCreate: self = .channelCreate
                case .channelUpdate: self = .channelUpdate
                case .channelDelete: self = .channelDelete
                case .channelOverwriteCreate:
                    let info = try container.decode(OverwriteInfo.self, forKey: .options)
                    self = .channelOverwriteCreate(info)
                case .channelOverwriteUpdate:
                    let info = try container.decode(OverwriteInfo.self, forKey: .options)
                    self = .channelOverwriteUpdate(info)
                case .channelOverwriteDelete:
                    let info = try container.decode(OverwriteInfo.self, forKey: .options)
                    self = .channelOverwriteDelete(info)
                case .memberKick:
                    let container = try optionsNestedContainer()
                    let integration_type = try container.decode(
                        Integration.Kind.self,
                        forKey: .integration_type
                    )
                    self = .memberKick(integration_type: integration_type)
                case .memberPrune:
                    let container = try optionsNestedContainer()
                    let delete_member_days = try container.decode(
                        String.self,
                        forKey: .delete_member_days
                    )
                    self = .memberPrune(delete_member_days: delete_member_days)
                case .memberBanAdd: self = .memberBanAdd
                case .memberBanRemove: self = .memberBanRemove
                case .memberUpdate: self = .memberUpdate
                case .memberRoleUpdate:
                    let container = try? optionsNestedContainer()
                    let integration_type = try container?.decodeIfPresent(
                        Integration.Kind.self,
                        forKey: .integration_type
                    )
                    self = .memberRoleUpdate(integration_type: integration_type)
                case .memberMove:
                    let container = try optionsNestedContainer()
                    let channel_id = try container.decode(
                        ChannelSnowflake.self,
                        forKey: .channel_id
                    )
                    let count = try container.decode(String.self, forKey: .count)
                    self = .memberMove(channel_id: channel_id, count: count)
                case .memberDisconnect:
                    let container = try optionsNestedContainer()
                    let count = try container.decode(String.self, forKey: .count)
                    self = .memberDisconnect(count: count)
                case .botAdd: self = .botAdd
                case .roleCreate: self = .roleCreate
                case .roleUpdate: self = .roleUpdate
                case .roleDelete: self = .roleDelete
                case .inviteCreate: self = .inviteCreate
                case .inviteUpdate: self = .inviteUpdate
                case .inviteDelete: self = .inviteDelete
                case .webhookCreate: self = .webhookCreate
                case .webhookUpdate: self = .webhookUpdate
                case .webhookDelete: self = .webhookDelete
                case .emojiCreate: self = .emojiCreate
                case .emojiUpdate: self = .emojiUpdate
                case .emojiDelete: self = .emojiDelete
                case .messageDelete:
                    let container = try optionsNestedContainer()
                    let channel_id = try container.decode(
                        ChannelSnowflake.self,
                        forKey: .channel_id
                    )
                    let count = try container.decode(String.self, forKey: .count)
                    self = .messageDelete(channel_id: channel_id, count: count)
                case .messageBulkDelete:
                    let container = try optionsNestedContainer()
                    let count = try container.decode(String.self, forKey: .count)
                    self = .messageBulkDelete(count: count)
                case .messagePin:
                    let container = try optionsNestedContainer()
                    let channel_id = try container.decode(
                        ChannelSnowflake.self,
                        forKey: .channel_id
                    )
                    self = .messagePin(channel_id: channel_id)
                case .messageUnpin:
                    let container = try optionsNestedContainer()
                    let channel_id = try container.decode(
                        ChannelSnowflake.self,
                        forKey: .channel_id
                    )
                    self = .messageUnpin(channel_id: channel_id)
                case .integrationCreate: self = .integrationCreate
                case .integrationUpdate: self = .integrationUpdate
                case .integrationDelete: self = .integrationDelete
                case .stageInstanceCreate:
                    let container = try optionsNestedContainer()
                    let channel_id = try container.decode(
                        ChannelSnowflake.self,
                        forKey: .channel_id
                    )
                    self = .stageInstanceCreate(channel_id: channel_id)
                case .stageInstanceUpdate:
                    let container = try optionsNestedContainer()
                    let channel_id = try container.decode(
                        ChannelSnowflake.self,
                        forKey: .channel_id
                    )
                    self = .stageInstanceUpdate(channel_id: channel_id)
                case .stageInstanceDelete:
                    let container = try optionsNestedContainer()
                    let channel_id = try container.decode(
                        ChannelSnowflake.self,
                        forKey: .channel_id
                    )
                    self = .stageInstanceDelete(channel_id: channel_id)
                case .stickerCreate: self = .stickerCreate
                case .stickerUpdate: self = .stickerUpdate
                case .stickerDelete: self = .stickerDelete
                case .guildScheduledEventCreate: self = .guildScheduledEventCreate
                case .guildScheduledEventUpdate: self = .guildScheduledEventUpdate
                case .guildScheduledEventDelete: self = .guildScheduledEventDelete
                case .threadCreate: self = .threadCreate
                case .threadUpdate: self = .threadUpdate
                case .threadDelete: self = .threadDelete
                case .applicationCommandPermissionUpdate:
                    let container = try optionsNestedContainer()
                    let application_id = try container.decode(
                        ApplicationSnowflake.self,
                        forKey: .application_id
                    )
                    self = .applicationCommandPermissionUpdate(application_id: application_id)
                case .autoModerationRuleCreate: self = .autoModerationRuleCreate
                case .autoModerationRuleUpdate: self = .autoModerationRuleUpdate
                case .autoModerationRuleDelete: self = .autoModerationRuleDelete
                case .autoModerationBlockMessage:
                    let moderationInfo = try container.decode(AutoModerationInfo.self, forKey: .options)
                    self = .autoModerationBlockMessage(moderationInfo)
                case .autoModerationFlagToChannel:
                    let moderationInfo = try container.decode(AutoModerationInfo.self, forKey: .options)
                    self = .autoModerationFlagToChannel(moderationInfo)
                case .autoModerationUserCommunicationDisabled:
                    let moderationInfo = try container.decode(AutoModerationInfo.self, forKey: .options)
                    self = .autoModerationUserCommunicationDisabled(moderationInfo)
                case .creatorMonetizationRequestCreated: self = .creatorMonetizationRequestCreated
                case .creatorMonetizationTermsAccepted: self = .creatorMonetizationTermsAccepted
                case .onboardingPromptCreate: self = .onboardingPromptCreate
                case .onboardingPromptUpdate: self = .onboardingPromptUpdate
                case .onboardingPromptDelete: self = .onboardingPromptDelete
                case .onboardingCreate: self = .onboardingCreate
                case .onboardingUpdate: self = .onboardingUpdate
                case .homeSettingsCreate: self = .homeSettingsCreate
                case .homeSettingsUpdate: self = .homeSettingsUpdate
                case .__undocumented:
                    self = .__undocumented
                }
            }

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                let type = ActionKind(action: self)
                try container.encode(type, forKey: .action_type)
                func optionsNestedContainer() throws -> KeyedEncodingContainer<OptionsCodingKeys> {
                    container.nestedContainer(keyedBy: OptionsCodingKeys.self, forKey: .options)
                }
                switch self {
                case .guildUpdate: break
                case .channelCreate: break
                case .channelUpdate: break
                case .channelDelete: break
                case let .channelOverwriteCreate(overwriteInfo):
                    try container.encode(overwriteInfo, forKey: .options)
                case let .channelOverwriteUpdate(overwriteInfo):
                    try container.encode(overwriteInfo, forKey: .options)
                case let .channelOverwriteDelete(overwriteInfo):
                    try container.encode(overwriteInfo, forKey: .options)
                case .memberKick: break
                case let .memberPrune(delete_member_days):
                    var container = try optionsNestedContainer()
                    try container.encode(delete_member_days, forKey: .delete_member_days)
                case .memberBanAdd: break
                case .memberBanRemove: break
                case .memberUpdate: break
                case .memberRoleUpdate: break
                case let .memberMove(channel_id, count):
                    var container = try optionsNestedContainer()
                    try container.encode(channel_id, forKey: .channel_id)
                    try container.encode(count, forKey: .count)
                case let .memberDisconnect(count):
                    var container = try optionsNestedContainer()
                    try container.encode(count, forKey: .count)
                case .botAdd: break
                case .roleCreate: break
                case .roleUpdate: break
                case .roleDelete: break
                case .inviteCreate: break
                case .inviteUpdate: break
                case .inviteDelete: break
                case .webhookCreate: break
                case .webhookUpdate: break
                case .webhookDelete: break
                case .emojiCreate: break
                case .emojiUpdate: break
                case .emojiDelete: break
                case let .messageDelete(channel_id, count):
                    var container = try optionsNestedContainer()
                    try container.encode(channel_id, forKey: .channel_id)
                    try container.encode(count, forKey: .count)
                case let .messageBulkDelete(count):
                    var container = try optionsNestedContainer()
                    try container.encode(count, forKey: .count)
                case let .messagePin(channel_id):
                    var container = try optionsNestedContainer()
                    try container.encode(channel_id, forKey: .channel_id)
                case let .messageUnpin(channel_id):
                    var container = try optionsNestedContainer()
                    try container.encode(channel_id, forKey: .channel_id)
                case .integrationCreate: break
                case .integrationUpdate: break
                case .integrationDelete: break
                case let .stageInstanceCreate(channel_id):
                    var container = try optionsNestedContainer()
                    try container.encode(channel_id, forKey: .channel_id)
                case let .stageInstanceUpdate(channel_id):
                    var container = try optionsNestedContainer()
                    try container.encode(channel_id, forKey: .channel_id)
                case let .stageInstanceDelete(channel_id):
                    var container = try optionsNestedContainer()
                    try container.encode(channel_id, forKey: .channel_id)
                case .stickerCreate: break
                case .stickerUpdate: break
                case .stickerDelete: break
                case .guildScheduledEventCreate: break
                case .guildScheduledEventUpdate: break
                case .guildScheduledEventDelete: break
                case .threadCreate: break
                case .threadUpdate: break
                case .threadDelete: break
                case let .applicationCommandPermissionUpdate(application_id):
                    var container = try optionsNestedContainer()
                    try container.encode(application_id, forKey: .application_id)
                case .autoModerationRuleCreate: break
                case .autoModerationRuleUpdate: break
                case .autoModerationRuleDelete: break
                case let .autoModerationBlockMessage(moderationInfo):
                    try container.encode(moderationInfo, forKey: .options)
                case let .autoModerationFlagToChannel(moderationInfo):
                    try container.encode(moderationInfo, forKey: .options)
                case let .autoModerationUserCommunicationDisabled(moderationInfo):
                    try container.encode(moderationInfo, forKey: .options)
                case .creatorMonetizationRequestCreated: break
                case .creatorMonetizationTermsAccepted: break
                case .onboardingPromptCreate: break
                case .onboardingPromptUpdate: break
                case .onboardingPromptDelete: break
                case .onboardingCreate: break
                case .onboardingUpdate: break
                case .homeSettingsCreate: break
                case .homeSettingsUpdate: break
                case .__undocumented: break
                }
            }
        }

        public var guild_id: GuildSnowflake?
        public var target_id: AnySnowflake?
        public var changes: [Change]?
        public var user_id: UserSnowflake?
        public var id: AuditLogEntrySnowflake
        public var action: Action
        public var reason: String?

        enum CodingKeys: String, CodingKey {
            case guild_id
            case target_id
            case changes
            case user_id
            case id
            case reason
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.guild_id = try container.decodeIfPresent(GuildSnowflake.self, forKey: .guild_id)
            self.target_id = try container.decodeIfPresent(AnySnowflake.self, forKey: .target_id)
            self.changes = try container.decodeIfPresent([Change].self, forKey: .changes)
            self.user_id = try container.decodeIfPresent(
                UserSnowflake.self,
                forKey: .user_id
            )
            self.id = try container.decode(AuditLogEntrySnowflake.self, forKey: .id)
            self.action = try Action(from: decoder)
            self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        }

        public func encode(to encoder: any Encoder) throws {
            if case .__undocumented = action { return }

            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.guild_id, forKey: .guild_id)
            try container.encodeIfPresent(self.target_id, forKey: .target_id)
            try container.encodeIfPresent(self.changes, forKey: .changes)
            try container.encodeIfPresent(self.user_id, forKey: .user_id)
            try container.encode(self.id, forKey: .id)
            try container.encodeIfPresent(self.reason, forKey: .reason)
            try action.encode(to: encoder)
        }
    }

    public var application_commands: [ApplicationCommand]
    public var audit_log_entries: [Entry]
    public var auto_moderation_rules: [AutoModerationRule]
    public var guild_scheduled_events: [GuildScheduledEvent]
    public var integrations: [PartialIntegration]
    public var threads: [DiscordChannel]
    public var users: [DiscordUser]
    public var webhooks: [Webhook]
}

// MARK: +AuditLog.Entry.ActionKind
extension AuditLog.Entry.ActionKind {
    init(action: AuditLog.Entry.Action) {
        switch action {
        case .guildUpdate: self = .guildUpdate
        case .channelCreate: self = .channelCreate
        case .channelUpdate: self = .channelUpdate
        case .channelDelete: self = .channelDelete
        case .channelOverwriteCreate: self = .channelOverwriteCreate
        case .channelOverwriteUpdate: self = .channelOverwriteUpdate
        case .channelOverwriteDelete: self = .channelOverwriteDelete
        case .memberKick: self = .memberKick
        case .memberPrune: self = .memberPrune
        case .memberBanAdd: self = .memberBanAdd
        case .memberBanRemove: self = .memberBanRemove
        case .memberUpdate: self = .memberUpdate
        case .memberRoleUpdate: self = .memberRoleUpdate
        case .memberMove: self = .memberMove
        case .memberDisconnect: self = .memberDisconnect
        case .botAdd: self = .botAdd
        case .roleCreate: self = .roleCreate
        case .roleUpdate: self = .roleUpdate
        case .roleDelete: self = .roleDelete
        case .inviteCreate: self = .inviteCreate
        case .inviteUpdate: self = .inviteUpdate
        case .inviteDelete: self = .inviteDelete
        case .webhookCreate: self = .webhookCreate
        case .webhookUpdate: self = .webhookUpdate
        case .webhookDelete: self = .webhookDelete
        case .emojiCreate: self = .emojiCreate
        case .emojiUpdate: self = .emojiUpdate
        case .emojiDelete: self = .emojiDelete
        case .messageDelete: self = .messageDelete
        case .messageBulkDelete: self = .messageBulkDelete
        case .messagePin: self = .messagePin
        case .messageUnpin: self = .messageUnpin
        case .integrationCreate: self = .integrationCreate
        case .integrationUpdate: self = .integrationUpdate
        case .integrationDelete: self = .integrationDelete
        case .stageInstanceCreate: self = .stageInstanceCreate
        case .stageInstanceUpdate: self = .stageInstanceUpdate
        case .stageInstanceDelete: self = .stageInstanceDelete
        case .stickerCreate: self = .stickerCreate
        case .stickerUpdate: self = .stickerUpdate
        case .stickerDelete: self = .stickerDelete
        case .guildScheduledEventCreate: self = .guildScheduledEventCreate
        case .guildScheduledEventUpdate: self = .guildScheduledEventUpdate
        case .guildScheduledEventDelete: self = .guildScheduledEventDelete
        case .threadCreate: self = .threadCreate
        case .threadUpdate: self = .threadUpdate
        case .threadDelete: self = .threadDelete
        case .applicationCommandPermissionUpdate: self = .applicationCommandPermissionUpdate
        case .autoModerationRuleCreate: self = .autoModerationRuleCreate
        case .autoModerationRuleUpdate: self = .autoModerationRuleUpdate
        case .autoModerationRuleDelete: self = .autoModerationRuleDelete
        case .autoModerationBlockMessage: self = .autoModerationBlockMessage
        case .autoModerationFlagToChannel: self = .autoModerationFlagToChannel
        case .autoModerationUserCommunicationDisabled: self = .autoModerationUserCommunicationDisabled
        case .creatorMonetizationTermsAccepted:
            self = .creatorMonetizationTermsAccepted
        case .creatorMonetizationRequestCreated:
            self = .creatorMonetizationRequestCreated
        case .onboardingPromptCreate:
            self = .onboardingPromptCreate
        case .onboardingPromptUpdate:
            self = .onboardingPromptUpdate
        case .onboardingPromptDelete:
            self = .onboardingPromptDelete
        case .onboardingCreate:
            self = .onboardingCreate
        case .onboardingUpdate:
            self = .onboardingUpdate
        case .homeSettingsCreate:
            self = .homeSettingsCreate
        case .homeSettingsUpdate:
            self = .homeSettingsUpdate
        case .__undocumented:
            self = .__undocumented(-1)
        }
    }
}
