/// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object
public struct GuildScheduledEvent: Sendable, Codable, ValidatablePayload {

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-privacy-level
    @UnstableEnum<Int>
    public enum PrivacyLevel: Sendable, Codable {
        case guildOnly  // 2
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-status
    @UnstableEnum<Int>
    public enum Status: Sendable, Codable {
        case scheduled  // 1
        case active  // 2
        case completed  // 3
        case canceled  // 4
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-entity-types
    @UnstableEnum<Int>
    public enum EntityKind: Sendable, Codable {
        case stageInstance  // 1
        case voice  // 2
        case external  // 3
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-entity-metadata
    public struct EntityMetadata: Sendable, Codable, ValidatablePayload {
        public var location: String?

        public init(location: String? = nil) {
            self.location = location
        }

        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRange(location, min: 1, max: 100, name: "location")
        }
    }

    public var id: GuildScheduledEventSnowflake
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake?
    public var creator_id: UserSnowflake?
    public var name: String
    public var description: String?
    public var scheduled_start_time: DiscordTimestamp
    public var scheduled_end_time: DiscordTimestamp?
    public var privacy_level: PrivacyLevel
    public var status: Status
    public var entity_type: EntityKind
    // FIXME: use `Snowflake<Type>` instead
    public var entity_id: AnySnowflake?
    public var entity_metadata: EntityMetadata?
    public var creator: DiscordUser?
    public var user_count: Int?
    public var image: String?
    /// Only for Gateway `guildScheduledEventUserAdd` events.
    public var user_ids: [UserSnowflake]?

    public func validate() -> [ValidationFailure] {
        validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
        validateCharacterCountInRange(description, min: 1, max: 100, name: "description")
        entity_metadata?.validate()
    }
}

extension GuildScheduledEvent {
    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-user-object-guild-scheduled-event-user-structure
    public struct User: Sendable, Codable {
        public var guild_scheduled_event_id: GuildScheduledEventSnowflake
        public var user: DiscordUser
        public var member: Guild.Member?
    }
}
