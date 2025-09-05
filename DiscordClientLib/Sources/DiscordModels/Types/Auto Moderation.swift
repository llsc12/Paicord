/// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object
public struct AutoModerationRule: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-event-types
    @UnstableEnum<Int>
    public enum EventKind: Sendable, Codable {
        case messageSend  // 1
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-trigger-types
    @UnstableEnum<Int>
    public enum TriggerKind: Sendable, Codable {
        case keyword  // 1
        case spam  // 3
        case keywordPreset  // 4
        case mentionSpam  // 5
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-trigger-metadata
    public struct TriggerMetadata: Sendable, Codable {

        /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-keyword-preset-types
        @UnstableEnum<Int>
        public enum KeywordPreset: Sendable, Codable {
            case profanity  // 1
            case sexualContent  // 2
            case slurs  // 3
            case __undocumented(Int)
        }

        public var keyword_filter: [String]?
        public var regex_patterns: [String]?
        public var presets: [KeywordPreset]?
        public var allow_list: [String]?
        public var mention_total_limit: Int?
        public var mention_raid_protection_enabled: Bool?

        public init(
            keyword_filter: [String]? = nil,
            regex_patterns: [String]? = nil,
            presets: [KeywordPreset]? = nil,
            allow_list: [String]? = nil,
            mention_total_limit: Int? = nil,
            mention_raid_protection_enabled: Bool? = nil
        ) {
            self.keyword_filter = keyword_filter
            self.regex_patterns = regex_patterns
            self.presets = presets
            self.allow_list = allow_list
            self.mention_total_limit = mention_total_limit
            self.mention_raid_protection_enabled = mention_raid_protection_enabled
        }
    }

    /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-action-object
    public enum Action: Sendable, Codable, ValidatablePayload {
        case blockMessage(customMessage: String?)
        case sendAlertMessage(channelId: ChannelSnowflake)
        case timeout(durationSeconds: Int)

        private enum CodingKeys: String, CodingKey {
            case type
            case metadata
        }

        private enum BlockMessageCodingKeys: String, CodingKey {
            case custom_message
        }

        private enum SendAlertMessageCodingKeys: String, CodingKey {
            case channel_id
        }

        private enum TimeoutCodingKeys: String, CodingKey {
            case duration_seconds
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(Int.self, forKey: .type)
            switch type {
            case 1:
                let customMessage = try container.nestedContainer(
                    keyedBy: BlockMessageCodingKeys.self,
                    forKey: .metadata
                ).decodeIfPresent(String.self, forKey: .custom_message)
                self = .blockMessage(customMessage: customMessage)
            case 2:
                let channelId = try container.nestedContainer(
                    keyedBy: SendAlertMessageCodingKeys.self,
                    forKey: .metadata
                ).decode(ChannelSnowflake.self, forKey: .channel_id)
                self = .sendAlertMessage(channelId: channelId)
            case 3:
                let durationSeconds = try container.nestedContainer(
                    keyedBy: TimeoutCodingKeys.self,
                    forKey: .metadata
                ).decode(Int.self, forKey: .duration_seconds)
                self = .timeout(durationSeconds: durationSeconds)
            default:
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: container.codingPath,
                        debugDescription: "Unexpected AutoModerationRule.Action 'type': \(type)"
                    )
                )
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .blockMessage(customMessage):
                try container.encode(1, forKey: .type)
                var metadataContainer = container.nestedContainer(
                    keyedBy: BlockMessageCodingKeys.self,
                    forKey: .metadata
                )
                try metadataContainer.encode(customMessage, forKey: .custom_message)
            case let .sendAlertMessage(channelId):
                try container.encode(2, forKey: .type)
                var metadataContainer = container.nestedContainer(
                    keyedBy: SendAlertMessageCodingKeys.self,
                    forKey: .metadata
                )
                try metadataContainer.encode(channelId, forKey: .channel_id)
            case let .timeout(durationSeconds):
                try container.encode(3, forKey: .type)
                var metadataContainer = container.nestedContainer(
                    keyedBy: TimeoutCodingKeys.self,
                    forKey: .metadata
                )
                try metadataContainer.encode(durationSeconds, forKey: .duration_seconds)
            }
        }

        public func validate() -> [ValidationFailure] {
            switch self {
            case .blockMessage(let customMessage):
                validateCharacterCountDoesNotExceed(
                    customMessage,
                    max: 150,
                    name: "customMessage"
                )
            case .timeout(let durationSeconds):
                validateNumberInRangeOrNil(
                    durationSeconds,
                    min: 0,
                    max: 2_419_200,
                    name: "durationSeconds"
                )
            case .sendAlertMessage(_):
                [ValidationFailure]()
            }
        }
    }

    public var id: RuleSnowflake
    public var guild_id: GuildSnowflake
    public var name: String
    public var creator_id: UserSnowflake
    public var event_type: EventKind
    public var trigger_type: TriggerKind
    public var trigger_metadata: TriggerMetadata
    public var actions: [Action]
    public var enabled: Bool
    public var exempt_roles: [String]
    public var exempt_channels: [String]
}

/// https://discord.com/developers/docs/topics/gateway-events#auto-moderation-action-execution-auto-moderation-action-execution-event-fields
public struct AutoModerationActionExecution: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var action: AutoModerationRule.Action
    public var rule_id: RuleSnowflake
    public var rule_trigger_type: AutoModerationRule.TriggerKind
    public var user_id: UserSnowflake
    public var channel_id: ChannelSnowflake?
    public var message_id: MessageSnowflake?
    public var alert_system_message_id: MessageSnowflake?
    public var content: String?
    public var matched_keyword: String?
    public var matched_content: String?
}
