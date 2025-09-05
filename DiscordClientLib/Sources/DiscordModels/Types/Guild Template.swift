/// https://discord.com/developers/docs/resources/guild-template#guild-template-object-guild-template-structure
public struct GuildTemplate: Codable, Sendable {

    /// `GuildTemplate` has a weird look.
    /// The `serialized_source_guild` doesn't have an id,
    /// and the guild roles have int ids instead of snowflakes.
    /// That's why you're seeing mostly-duplicate code below.

    /// https://discord.com/developers/docs/topics/permissions#role-object
    /// A role with integer id.
    public struct Role: Sendable, Codable {
        public var id: Int
        public var name: String
        public var description: String?
        public var color: DiscordColor
        public var hoist: Bool
        public var icon: String?
        public var unicode_emoji: String?
        public var position: Int?
        public var permissions: StringBitField<Permission>
        public var managed: Bool?
        public var mentionable: Bool
        public var tags: DiscordModels.Role.Tags?
        public var version: Int?
    }

    /// https://discord.com/developers/docs/resources/guild#guild-object-guild-structure
    /// A partial guild with probably no `id`.
    /// + `system_channel_id` of type integer.
    public struct PartialGuild: Sendable, Codable {
        public var id: GuildSnowflake?
        public var name: String?
        public var icon: String?
        public var icon_hash: String?
        public var splash: String?
        public var discovery_splash: String?
        public var owner: Bool?
        public var owner_id: UserSnowflake?
        public var permissions: StringBitField<Permission>?
        public var afk_channel_id: ChannelSnowflake?
        public var afk_timeout: Int?
        public var widget_enabled: Bool?
        public var widget_channel_id: ChannelSnowflake?
        public var verification_level: Guild.VerificationLevel?
        public var default_message_notifications: Guild.DefaultMessageNotificationLevel?
        public var explicit_content_filter: Guild.ExplicitContentFilterLevel?
        public var roles: [Role]?
        public var emojis: [Emoji]?
        public var features: [Guild.Feature]?
        public var mfa_level: Guild.MFALevel?
        public var application_id: ApplicationSnowflake?
        public var system_channel_id: Int?
        public var system_channel_flags: IntBitField<Guild.SystemChannelFlag>?
        public var rules_channel_id: ChannelSnowflake?
        public var safety_alerts_channel_id: ChannelSnowflake?
        public var max_presences: Int?
        public var max_members: Int?
        public var vanity_url_code: String?
        public var description: String?
        public var banner: String?
        public var premium_tier: Guild.PremiumTier?
        public var premium_subscription_count: Int?
        public var preferred_locale: DiscordLocale?
        public var public_updates_channel_id: ChannelSnowflake?
        public var max_video_channel_users: Int?
        public var max_stage_video_channel_users: Int?
        public var approximate_member_count: Int?
        public var approximate_presence_count: Int?
        public var welcome_screen: [Guild.WelcomeScreen]?
        public var nsfw_level: Guild.NSFWLevel?
        public var stickers: [Sticker]?
        public var premium_progress_bar_enabled: Bool?
        public var `lazy`: Bool?
        public var hub_type: String?
        public var nsfw: Bool?
        public var application_command_counts: [String: Int]?
        public var embedded_activities: [Gateway.Activity]?
        public var version: Int?
        public var guild_id: GuildSnowflake?
    }

    public var code: String
    public var name: String
    public var description: String?
    public var usage_count: Int
    public var creator_id: UserSnowflake
    public var creator: DiscordUser
    public var created_at: DiscordTimestamp
    public var updated_at: DiscordTimestamp
    public var source_guild_id: GuildSnowflake
    public var serialized_source_guild: PartialGuild
    public var is_dirty: Bool?
}
