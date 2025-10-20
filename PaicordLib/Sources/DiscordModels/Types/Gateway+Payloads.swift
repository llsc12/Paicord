//
//  Gateway+Payloads.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 09/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Foundation

extension Gateway {

  /// https://discord.com/developers/docs/topics/gateway-events#identify
  public struct Identify: Sendable, Codable {

    /// https://discord.com/developers/docs/topics/gateway-events#identify-identify-connection-properties
    /// https://docs.discord.food/reference#client-properties
    public struct ConnectionProperties: Sendable, Codable {
      // all super-properties related stuff for user accounts is in a different
      // file to keep this definition small

      public var os: String
      public var browser: String
      public var device: String

      public var release_channel: String?
      public var client_version: String?
      public var os_version: String?
      public var os_arch: String?
      public var app_arch: String?  // set this to os_arch for simplicity (also bc its true)
      public var system_locale: String?
      public var has_client_mods: Bool?
      public var client_launch_id: String?
      public var device_vendor_id: String?
      public var browser_user_agent: String?
      public var browser_version: String?
      public var os_sdk_version: String?  // first segment of os_version
      public var client_build_number: Int?
      public var client_app_state: String?
      public var native_build_number: Int?
      public var design_id: Int?  // ui on mobile

      public var client_event_source: String? = nil

      public init(
        os: String = Self.__defaultOS,
        browser: String = "DiscordBM",
        device: String = "DiscordBM"
      ) {
        self.os = os
        self.browser = browser
        self.device = device
      }

      enum CodingKeys: String, CodingKey {
        case os, browser, device, release_channel, client_version, os_version,
          os_arch, app_arch, system_locale, has_client_mods, client_launch_id,
          device_vendor_id,
          browser_user_agent, browser_version, os_sdk_version,
          client_build_number, client_app_state, native_build_number,
          client_event_source, design_id
      }

      public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.os = try container.decode(String.self, forKey: .os)
        self.browser = try container.decode(String.self, forKey: .browser)
        self.device = try container.decode(String.self, forKey: .device)
        self.release_channel = try container.decodeIfPresent(
          String.self,
          forKey: .release_channel
        )
        self.client_version = try container.decodeIfPresent(
          String.self,
          forKey: .client_version
        )
        self.os_version = try container.decodeIfPresent(
          String.self,
          forKey: .os_version
        )
        self.os_arch = try container.decodeIfPresent(
          String.self,
          forKey: .os_arch
        )
        self.app_arch = try container.decodeIfPresent(
          String.self,
          forKey: .app_arch
        )
        self.system_locale = try container.decodeIfPresent(
          String.self,
          forKey: .system_locale
        )
        self.has_client_mods = try container.decodeIfPresent(
          Bool.self,
          forKey: .has_client_mods
        )
        self.client_launch_id = try container.decodeIfPresent(
          String.self,
          forKey: .client_launch_id
        )
        self.device_vendor_id = try container.decodeIfPresent(
          String.self,
          forKey: .device_vendor_id
        )
        self.browser_user_agent = try container.decodeIfPresent(
          String.self,
          forKey: .browser_user_agent
        )
        self.browser_version = try container.decodeIfPresent(
          String.self,
          forKey: .browser_version
        )
        self.os_sdk_version = try container.decodeIfPresent(
          String.self,
          forKey: .os_sdk_version
        )
        self.client_build_number = try container.decodeIfPresent(
          Int.self,
          forKey: .client_build_number
        )
        self.client_app_state = try container.decodeIfPresent(
          String.self,
          forKey: .client_app_state
        )
        self.native_build_number = try container.decodeIfPresent(
          Int.self,
          forKey: .client_build_number
        )
        self.client_event_source = try container.decodeIfPresent(
          String.self,
          forKey: .client_event_source
        )
        self.design_id = try container.decodeIfPresent(
          Int.self,
          forKey: .design_id
        )
      }

      // encode manually to ensure null values are encoded as null
      public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.os, forKey: .os)
        try container.encode(self.browser, forKey: .browser)
        try container.encode(self.device, forKey: .device)
        try container.encode(self.release_channel, forKey: .release_channel)
        try container.encode(self.client_version, forKey: .client_version)
        try container.encode(self.os_version, forKey: .os_version)
        try container.encode(self.os_arch, forKey: .os_arch)
        try container.encode(self.app_arch, forKey: .app_arch)
        try container.encode(self.system_locale, forKey: .system_locale)
        try container.encode(self.has_client_mods, forKey: .has_client_mods)
        try container.encode(self.client_launch_id, forKey: .client_launch_id)
        try container.encodeIfPresent(
          self.device_vendor_id,
          forKey: .device_vendor_id
        )
        try container.encodeIfPresent(self.design_id, forKey: .design_id)
        try container.encode(
          self.browser_user_agent,
          forKey: .browser_user_agent
        )
        try container.encode(self.browser_version, forKey: .browser_version)
        try container.encode(self.os_sdk_version, forKey: .os_sdk_version)
        try container.encode(
          self.client_build_number,
          forKey: .client_build_number
        )
        try container.encode(self.client_app_state, forKey: .client_app_state)
        try container.encode(
          self.native_build_number,
          forKey: .client_build_number
        )
        try container.encode(
          self.client_event_source,
          forKey: .client_event_source
        )
      }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#update-presence-gateway-presence-update-structure
    public struct Presence: Sendable, Codable {
      public var since: Int?
      public var activities: [Activity]
      public var status: Status
      public var afk: Bool

      public init(
        since: Date? = nil,
        activities: [Activity],
        status: Status,
        afk: Bool
      ) {
        self.since = since == nil ? nil : Int(since!.timeIntervalSince1970)
        self.activities = activities
        self.status = status
        self.afk = afk
      }

      public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        /// Need to encode `null` if `nil`, considering a Discord bug.
        /// So don't use `encodeIfPresent`.
        try container.encode(self.since, forKey: .since)
        try container.encode(self.activities, forKey: .activities)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.afk, forKey: .afk)
      }
    }

    public var token: Secret
    public var properties: ConnectionProperties
    /// DiscordBM supports the better "Transport Compression", but not "Payload Compression".
    /// Setting this to `true` will only cause problems.
    /// "Transport Compression" is enabled by default with no options to disable it.
    var compress: Bool?
    public var large_threshold: Int?
    public var shard: IntPair?
    public var presence: Presence?
    /// Bots require intents, users do not.
    public var intents: IntBitField<Intent>?
    public var capabilities: IntBitField<Capability>?

    // Bot identify initializers

    public init(
      token: Secret,
      properties: ConnectionProperties = ConnectionProperties(),
      large_threshold: Int? = nil,
      shard: IntPair? = nil,
      presence: Presence? = nil,
      intents: [Intent]
    ) {
      self.token = token
      self.properties = properties
      self.large_threshold = large_threshold
      self.shard = shard
      self.presence = presence
      self.intents = .init(intents)
    }

    public init(
      token: String,
      properties: ConnectionProperties = ConnectionProperties(),
      large_threshold: Int? = nil,
      shard: IntPair? = nil,
      presence: Presence? = nil,
      intents: [Intent]
    ) {
      self.token = Secret(token)
      self.properties = properties
      self.large_threshold = large_threshold
      self.shard = shard
      self.presence = presence
      self.intents = .init(intents)
    }

    // User identify initializers
    public init(
      token: Secret,
      properties: ConnectionProperties,
      large_threshold: Int? = nil,
      presence: Presence? = nil,
      capabilities: [Capability]
    ) {
      self.token = token
      self.properties = properties
      self.large_threshold = large_threshold
      self.presence = presence
      self.capabilities = .init(capabilities)
    }

    public init(
      token: String,
      properties: ConnectionProperties,
      large_threshold: Int? = nil,
      presence: Presence? = nil,
      capabilities: [Capability]
    ) {
      self.token = Secret(token)
      self.properties = properties
      self.large_threshold = large_threshold
      self.presence = presence
      self.capabilities = .init(capabilities)
    }
  }

  /// https://discord.com/developers/docs/topics/gateway#gateway-intents
  @UnstableEnum<UInt>
  public enum Intent: Sendable, Codable, CaseIterable {
    case guilds  // 0
    case guildMembers  // 1
    case guildModeration  // 2
    case guildEmojisAndStickers  // 3
    case guildIntegrations  // 4
    case guildWebhooks  // 5
    case guildInvites  // 6
    case guildVoiceStates  // 7
    case guildPresences  // 8
    case guildMessages  // 9
    case guildMessageReactions  // 10
    case guildMessageTyping  // 11
    case directMessages  // 12
    case directMessageReactions  // 13
    case directMessageTyping  // 14
    case messageContent  // 15
    case guildScheduledEvents  // 16
    case autoModerationConfiguration  // 20
    case autoModerationExecution  // 21
    case guildMessagePolls  // 24
    case directMessagePolls  // 25
    case __undocumented(UInt)
  }

  /// https://docs.discord.food/topics/gateway#list-of-capabilities
  @UnstableEnum<UInt>
  public enum Capability: Sendable, Codable, CaseIterable {
    case lazyUserNotes  // 0
    case noAffineUserIDs  // 1
    case versionedReadStates  // 2
    case versionedUserGuildSettings  // 3
    case dedupeUserObjects  // 4
    case prioritizedReadyPayload  // 5
    case multipleGuildExperimentPopulations  // 6
    case nonChannelReadStates  // 7
    case authTokenRefresh  // 8
    case userSettingsProto  // 9
    case clientStateV2  // 10
    case passiveGuildUpdate  // 11
    case autoCallConnect  // 12
    case debounceMessageReactions  // 13
    case passiveGuildUpdateV2  // 14
    case autoLobbyConnect  // 16
    case __undocumented(UInt)
  }

  /// https://discord.com/developers/docs/topics/gateway-events#resume-resume-structure
  public struct Resume: Sendable, Codable {
    public var token: Secret
    public var session_id: String
    public var seq: Int

    public init(token: Secret, session_id: String, sequence: Int) {
      self.token = token
      self.session_id = session_id
      self.seq = sequence
    }
  }

  /// https://discord.com/developers/docs/topics/gateway-events#update-presence-status-types
  @UnstableEnum<String>
  public enum Status: Sendable, Codable {
    case online  // "online"
    case doNotDisturb  // "dnd"
    case afk  // "idle"
    case offline  // "offline"
    case invisible  // "invisible"
    case __undocumented(String)
  }

  /// https://discord.com/developers/docs/topics/gateway-events#hello-hello-structure
  public struct Hello: Sendable, Codable {
    public var heartbeat_interval: Int
  }

  /// https://discord.com/developers/docs/topics/gateway-events#ready-ready-event-fields
  public struct Ready: Sendable, Codable {
    // shared fields
    public var v: Int
    public var user: DiscordUser
    public var session_id: String
    public var resume_gateway_url: String?
    public var shard: IntPair?

    // bot only
    //		public var application: PartialApplication?
    //		public var guilds: [UnavailableGuild]

    // user only
    public var sessions: [Session]
    public var user_settings_proto:
      DiscordProtos_DiscordUsers_V1_PreloadedUserSettings?
    //		public var connected_accounts
    //		public var user_guild_settings
    //		public var guild_join_requests
    //		public var broadcaster_user_ids
    //		public var session_type: String? // maybe this can become an unstable enum
    //		public var read_state: ReadState?
    public var presences: [Gateway.PresenceUpdate]
    //		public var notification_settings
    public var relationships: [DiscordRelationship]
    //		public var friend_suggestion_count
    public var private_channels: [DiscordChannel]
    public var guilds: [Guild]
    public var geo_ordered_rtc_regions: [String]?
    public var auth_token: Secret?
  }

  /// https://docs.discord.food/topics/gateway-events#ready-supplemental
  public struct ReadySupplemental: Sendable, Codable {

  }

  /// https://docs.discord.food/topics/gateway-events#auth-session-change
  public struct AuthSessionChange: Sendable, Codable {

  }

  /// https://discord.com/developers/docs/topics/gateway-events#thread-delete
  public struct ThreadDelete: Sendable, Codable {
    public var id: ChannelSnowflake
    public var type: DiscordChannel.Kind
    public var guild_id: GuildSnowflake?
    public var parent_id: AnySnowflake?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#thread-list-sync-thread-list-sync-event-fields
  public struct ThreadListSync: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channel_ids: [ChannelSnowflake]?
    public var threads: [DiscordChannel]
    public var members: [ThreadMember]
  }

  /// A ``ThreadMember`` with a `guild_id` field.
  /// https://discord.com/developers/docs/topics/gateway-events#thread-member-update
  public struct ThreadMemberUpdate: Sendable, Codable {
    public var id: ChannelSnowflake
    public var user_id: UserSnowflake?
    public var join_timestamp: DiscordTimestamp
    public var flags: IntBitField<ThreadMember.Flag>
    public var guild_id: GuildSnowflake
  }

  /// https://discord.com/developers/docs/topics/gateway-events#thread-members-update-thread-members-update-event-fields
  public struct ThreadMembersUpdate: Sendable, Codable {

    /// A ``ThreadMember`` with some extra fields.
    /// https://discord.com/developers/docs/resources/channel#thread-member-object-thread-member-structure
    /// https://discord.com/developers/docs/topics/gateway-events#thread-members-update-thread-members-update-event-fields
    public struct ThreadMember: Sendable, Codable, Equatable, Hashable {

      /// A ``PresenceUpdate`` with nullable `guild_id`.
      /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
      public struct ThreadMemberPresenceUpdate: Sendable, Codable, Equatable,
        Hashable
      {
        public var user: PartialUser
        public var guild_id: GuildSnowflake?
        public var status: Status
        public var activities: [Activity]
        public var client_status: ClientStatus
      }

      public var id: ChannelSnowflake
      public var user_id: UserSnowflake?
      public var join_timestamp: DiscordTimestamp
      public var flags: IntBitField<DiscordModels.ThreadMember.Flag>
      public var member: Guild.Member
      public var presence: ThreadMemberPresenceUpdate?
    }

    public var id: ChannelSnowflake
    public var guild_id: GuildSnowflake
    public var member_count: Int
    public var added_members: [ThreadMember]?
    public var removed_member_ids: [UserSnowflake]?
  }

  /// A `Guild` object with extra fields.
  /// https://discord.com/developers/docs/resources/guild#guild-object-guild-structure
  /// https://discord.com/developers/docs/topics/gateway-events#guild-create-guild-create-extra-fields
  public struct GuildCreate: Sendable, Codable {
    public var id: GuildSnowflake
    public var name: String
    public var icon: String?
    public var icon_hash: String?
    public var splash: String?
    public var discovery_splash: String?
    public var owner: Bool?
    public var owner_id: UserSnowflake
    public var permissions: StringBitField<Permission>?
    public var afk_channel_id: ChannelSnowflake?
    public var afk_timeout: Guild.AFKTimeout
    public var widget_enabled: Bool?
    public var widget_channel_id: ChannelSnowflake?
    public var verification_level: Guild.VerificationLevel
    public var default_message_notifications:
      Guild.DefaultMessageNotificationLevel
    public var explicit_content_filter: Guild.ExplicitContentFilterLevel
    public var roles: [Role]
    public var emojis: [Emoji]
    public var features: [Guild.Feature]
    public var mfa_level: Guild.MFALevel
    public var application_id: ApplicationSnowflake?
    public var system_channel_id: ChannelSnowflake?
    public var system_channel_flags: IntBitField<Guild.SystemChannelFlag>
    public var rules_channel_id: ChannelSnowflake?
    public var safety_alerts_channel_id: ChannelSnowflake?
    public var max_presences: Int?
    public var max_members: Int?
    public var vanity_url_code: String?
    public var description: String?
    public var banner: String?
    public var premium_tier: Guild.PremiumTier
    public var premium_subscription_count: Int?
    public var preferred_locale: DiscordLocale
    public var public_updates_channel_id: ChannelSnowflake?
    public var max_video_channel_users: Int?
    public var max_stage_video_channel_users: Int?
    public var approximate_member_count: Int?
    public var approximate_presence_count: Int?
    public var welcome_screen: [Guild.WelcomeScreen]?
    public var nsfw_level: Guild.NSFWLevel
    public var stickers: [Sticker]?
    public var premium_progress_bar_enabled: Bool
    public var `lazy`: Bool?
    //		public var hub_type: String?
    public var nsfw: Bool
    public var application_command_counts: [String: Int]?
    public var embedded_activities: [Gateway.Activity]?
    public var version: Int?
    public var guild_id: GuildSnowflake?
    /// Extra fields:
    public var joined_at: DiscordTimestamp
    public var large: Bool
    public var unavailable: Bool?
    public var member_count: Int
    public var voice_states: [PartialVoiceState]
    public var members: [Guild.Member]
    public var channels: [DiscordChannel]
    public var threads: [DiscordChannel]
    public var presences: [Gateway.PartialPresenceUpdate]
    public var stage_instances: [StageInstance]
    public var guild_scheduled_events: [GuildScheduledEvent]

    public mutating func update(with new: Guild) {
      self.id = new.id
      self.name = new.name
      self.icon = new.icon
      self.icon_hash = new.icon_hash
      self.splash = new.splash
      self.discovery_splash = new.discovery_splash
      self.owner = new.owner
      self.owner_id = new.owner_id
      self.permissions = new.permissions
      self.afk_channel_id = new.afk_channel_id
      self.afk_timeout = new.afk_timeout
      self.widget_enabled = new.widget_enabled
      self.widget_channel_id = new.widget_channel_id
      self.verification_level = new.verification_level
      self.default_message_notifications = new.default_message_notifications
      self.explicit_content_filter = new.explicit_content_filter
      self.roles = new.roles
      self.emojis = new.emojis
      self.features = new.features
      self.mfa_level = new.mfa_level
      self.application_id = new.application_id
      self.system_channel_id = new.system_channel_id
      self.system_channel_flags = new.system_channel_flags
      self.rules_channel_id = new.rules_channel_id
      self.max_presences = new.max_presences
      self.max_members = new.max_members
      self.vanity_url_code = new.vanity_url_code
      self.description = new.description
      self.banner = new.banner
      self.premium_tier = new.premium_tier
      self.premium_subscription_count = new.premium_subscription_count
      self.preferred_locale = new.preferred_locale
      self.public_updates_channel_id = new.public_updates_channel_id
      self.max_video_channel_users = new.max_video_channel_users
      self.max_stage_video_channel_users = new.max_stage_video_channel_users
      self.approximate_member_count = new.approximate_member_count
      self.approximate_presence_count = new.approximate_presence_count
      self.welcome_screen = new.welcome_screen
      self.nsfw_level = new.nsfw_level
      self.stickers = new.stickers
      self.premium_progress_bar_enabled = new.premium_progress_bar_enabled
      self.`lazy` = new.`lazy`
      //			self.hub_type = new.hub_type
      self.nsfw = new.nsfw
      self.application_command_counts = new.application_command_counts
      self.embedded_activities = new.embedded_activities
      self.version = new.version
      self.guild_id = new.guild_id
    }
  }

  /// https://discord.com/developers/docs/topics/gateway-events#channel-pins-update-channel-pins-update-event-fields
  public struct ChannelPinsUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake?
    public var channel_id: ChannelSnowflake
    public var last_pin_timestamp: DiscordTimestamp?
  }

  /// https://docs.discord.food/topics/gateway-events#channel-recipient-add
  public struct ChannelRecipientAdd: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var user: PartialUser
    public var nick: String?
  }

  /// https://docs.discord.food/topics/gateway-events#channel-recipient-remove
  public struct ChannelRecipientRemove: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var user: PartialUser
  }

  /// https://discord.com/developers/docs/topics/gateway-events#guild-ban-add-guild-ban-add-event-fields
  public struct GuildBan: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var user: DiscordUser
  }

  /// https://discord.com/developers/docs/topics/gateway-events#guild-emojis-update-guild-emojis-update-event-fields
  public struct GuildEmojisUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var emojis: [Emoji]
  }

  /// https://discord.com/developers/docs/topics/gateway-events#guild-stickers-update-guild-stickers-update-event-fields
  public struct GuildStickersUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var stickers: [Sticker]
  }

  /// https://discord.com/developers/docs/topics/gateway-events#guild-integrations-update-guild-integrations-update-event-fields
  public struct GuildIntegrationsUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake
  }

  /// A ``Guild.Member`` with an extra `guild_id` field.
  /// https://discord.com/developers/docs/resources/guild#guild-member-object
  public struct GuildMemberAdd: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var roles: [RoleSnowflake]
    public var user: DiscordUser
    public var nick: String?
    public var avatar: String?
    public var joined_at: DiscordTimestamp
    public var premium_since: DiscordTimestamp?
    public var deaf: Bool?
    public var mute: Bool?
    public var flags: IntBitField<Guild.Member.Flag>?
    public var pending: Bool?
    public var communication_disabled_until: DiscordTimestamp?
    public var avatar_decoration_data: DiscordUser.AvatarDecoration?

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.guild_id = try container.decode(
        GuildSnowflake.self,
        forKey: .guild_id
      )
      self.roles = try container.decode([RoleSnowflake].self, forKey: .roles)
      self.user = try container.decode(DiscordUser.self, forKey: .user)
      self.nick = try container.decodeIfPresent(String.self, forKey: .nick)
      self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
      self.joined_at =
        try container.decodeIfPresent(
          DiscordTimestamp.self,
          forKey: .joined_at
        ) ?? .init(date: .distantFuture)
      self.premium_since = try container.decodeIfPresent(
        DiscordTimestamp.self,
        forKey: .premium_since
      )
      self.deaf = try container.decodeIfPresent(Bool.self, forKey: .deaf)
      self.mute = try container.decodeIfPresent(Bool.self, forKey: .mute)
      self.flags = try container.decodeIfPresent(
        IntBitField<Guild.Member.Flag>.self,
        forKey: .flags
      )
      self.pending = try container.decodeIfPresent(Bool.self, forKey: .pending)
      self.communication_disabled_until = try container.decodeIfPresent(
        DiscordTimestamp.self,
        forKey: .communication_disabled_until
      )
      self.avatar_decoration_data = try container.decodeIfPresent(
        DiscordUser.AvatarDecoration.self,
        forKey: .avatar_decoration_data
      )
    }
  }

  /// https://discord.com/developers/docs/topics/gateway-events#guild-member-remove-guild-member-remove-event-fields
  public struct GuildMemberRemove: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var user: DiscordUser
  }

  /// https://discord.com/developers/docs/topics/gateway-events#guild-members-chunk
  public struct GuildMembersChunk: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var members: [Guild.Member]
    public var chunk_index: Int
    public var chunk_count: Int
    public var not_found: [String]?
    public var presences: [PartialPresenceUpdate]?
    public var nonce: String?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#request-guild-members
  public struct RequestGuildMembers: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var query: String?
    public var limit: Int = 0
    public var presences: Bool?
    public var user_ids: [UserSnowflake]?
    public var nonce: String?

    public init(
      guild_id: GuildSnowflake,
      query: String? = nil,
      limit: Int = 0,
      presences: Bool? = nil,
      user_ids: [UserSnowflake]? = nil,
      nonce: String? = nil
    ) {
      self.guild_id = guild_id
      self.query = query
      self.limit = limit
      self.presences = presences
      self.user_ids = user_ids
      self.nonce = nonce
    }
  }

  /// https://discord.com/developers/docs/topics/gateway-events#guild-role-create-guild-role-create-event-fields
  public struct GuildRole: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var role: Role
  }

  /// https://discord.com/developers/docs/topics/gateway-events#guild-role-delete
  public struct GuildRoleDelete: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var role_id: RoleSnowflake
    public var version: Int?
  }

  /// Not the same as what Discord calls `Guild Scheduled Event User`.
  /// This is used for guild-scheduled-event-user add and remove events.
  /// https://discord.com/developers/docs/topics/gateway-events#guild-scheduled-event-user-add-guild-scheduled-event-user-add-event-fields
  public struct GuildScheduledEventUser: Sendable, Codable {
    public var guild_scheduled_event_id: GuildScheduledEventSnowflake
    public var user_id: UserSnowflake
    public var guild_id: GuildSnowflake
  }

  /// An ``Integration`` with an extra `guild_id` field.
  /// https://discord.com/developers/docs/topics/gateway-events#integration-create
  /// https://discord.com/developers/docs/resources/guild#integration-object
  public struct IntegrationCreate: Sendable, Codable {
    public var id: IntegrationSnowflake
    public var name: String
    public var type: Integration.Kind
    public var enabled: Bool
    public var syncing: Bool?
    public var role_id: RoleSnowflake?
    public var enable_emoticons: Bool?
    public var expire_behavior: Integration.ExpireBehavior?
    public var expire_grace_period: Int?
    public var user: DiscordUser?
    public var account: IntegrationAccount
    public var synced_at: DiscordTimestamp?
    public var subscriber_count: Int?
    public var revoked: Bool?
    public var application: IntegrationApplication?
    public var guild_id: GuildSnowflake
    public var scopes: [OAuth2Scope]?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#integration-delete-integration-delete-event-fields
  public struct IntegrationDelete: Sendable, Codable {
    public var id: IntegrationSnowflake
    public var guild_id: GuildSnowflake
    public var application_id: ApplicationSnowflake?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#invite-create-invite-create-event-fields
  public struct InviteCreate: Sendable, Codable {

    /// FIXME: Type-alias to avoid code breakage
    public typealias TargetKind = Invite.TargetKind

    public var type: Invite.Kind
    public var channel_id: ChannelSnowflake
    public var code: String
    public var created_at: DiscordTimestamp
    public var guild_id: GuildSnowflake?
    public var inviter: DiscordUser?
    public var max_age: Int
    public var max_uses: Int
    public var target_type: Invite.TargetKind?
    public var target_user: DiscordUser?
    public var target_application: PartialApplication?
    public var temporary: Bool
    public var uses: Int
  }

  /// https://discord.com/developers/docs/topics/gateway-events#invite-delete
  public struct InviteDelete: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var guild_id: GuildSnowflake?
    public var code: String
  }

  /// A ``Message`` object with a few extra fields.
  /// https://discord.com/developers/docs/topics/gateway-events#message-create
  /// https://discord.com/developers/docs/resources/channel#message-object
  public struct MessageCreate: Sendable, Codable {
    public var id: MessageSnowflake
    public var channel_id: ChannelSnowflake
    public var author: DiscordUser?
    public var content: String
    public var timestamp: DiscordTimestamp
    public var edited_timestamp: DiscordTimestamp?
    public var tts: Bool
    public var mention_everyone: Bool
    public var mention_roles: [RoleSnowflake]
    public var mention_channels: [DiscordChannel.Message.ChannelMention]?
    public var mentions: [MentionUser]
    public var attachments: [DiscordChannel.Message.Attachment]
    public var embeds: [Embed]
    public var reactions: [DiscordChannel.Message.Reaction]?
    public var nonce: StringOrInt?
    public var pinned: Bool
    public var webhook_id: WebhookSnowflake?
    public var type: DiscordChannel.Message.Kind
    public var activity: DiscordChannel.Message.Activity?
    public var application: PartialApplication?
    public var application_id: ApplicationSnowflake?
    public var message_reference: DiscordChannel.Message.MessageReference?
    public var flags: IntBitField<DiscordChannel.Message.Flag>?
    public var referenced_message: DereferenceBox<MessageCreate>?
    //		@_spi(UserInstallableApps) @DecodeOrNil
    //		public var interaction_metadata: DiscordChannel.Message.InteractionMetadata?
    public var interaction: MessageInteraction?
    public var thread: DiscordChannel?
    public var components: Interaction.ComponentSwitch?
    public var sticker_items: [StickerItem]?
    public var stickers: [Sticker]?
    public var position: Int?
    public var role_subscription_data: RoleSubscriptionData?
    public var resolved: Interaction.ApplicationCommand.ResolvedData?
    public var poll: Poll?
    public var call: DiscordChannel.Message.Call?
    /// Extra fields:
    public var guild_id: GuildSnowflake?
    public var member: Guild.PartialMember?

    public mutating func update(
      with partialMessage: DiscordChannel.PartialMessage
    ) {
      self.id = partialMessage.id
      self.channel_id = partialMessage.channel_id
      if let author = partialMessage.author {
        self.author = author
      }
      if let content = partialMessage.content {
        self.content = content
      }
      if let timestamp = partialMessage.timestamp {
        self.timestamp = timestamp
      }
      self.edited_timestamp = partialMessage.edited_timestamp
      if let tts = partialMessage.tts {
        self.tts = tts
      }
      if let mention_everyone = partialMessage.mention_everyone {
        self.mention_everyone = mention_everyone
      }
      if let mentions = partialMessage.mentions {
        self.mentions = mentions
      }
      if let mention_roles = partialMessage.mention_roles {
        self.mention_roles = mention_roles
      }
      self.mention_channels = partialMessage.mention_channels
      if let attachments = partialMessage.attachments {
        self.attachments = attachments
      }
      if let embeds = partialMessage.embeds {
        self.embeds = embeds
      }
      self.reactions = partialMessage.reactions
      self.nonce = partialMessage.nonce
      if let pinned = partialMessage.pinned {
        self.pinned = pinned
      }
      self.webhook_id = partialMessage.webhook_id
      if let type = partialMessage.type {
        self.type = type
      }
      if let activity = partialMessage.activity {
        self.activity = activity
      }
      self.application = partialMessage.application
      self.application_id = partialMessage.application_id
      self.message_reference = partialMessage.message_reference
      self.flags = partialMessage.flags
      if let referenced_message = partialMessage.referenced_message,
        var value = self.referenced_message?.value
      {
        value.update(with: referenced_message.value)
        self.referenced_message = .init(value: value)
      }
      self.interaction = partialMessage.interaction
      self.thread = partialMessage.thread
      self.components = partialMessage.components
      self.sticker_items = partialMessage.sticker_items
      self.stickers = partialMessage.stickers
      self.position = partialMessage.position
      self.role_subscription_data = partialMessage.role_subscription_data
      if let poll = partialMessage.poll {
        self.poll = poll
      }
      if let member = partialMessage.member {
        self.member = member
      }
      if let guildId = partialMessage.guild_id {
        self.guild_id = guildId
      }
      if let resolved = partialMessage.resolved {
        self.resolved = resolved
      }
    }
  }

  /// https://discord.com/developers/docs/topics/gateway-events#message-delete
  public struct MessageDelete: Sendable, Codable {
    public var id: MessageSnowflake
    public var channel_id: ChannelSnowflake
    public var guild_id: GuildSnowflake?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#message-delete-bulk-message-delete-bulk-event-fields
  public struct MessageDeleteBulk: Sendable, Codable {
    public var ids: [MessageSnowflake]
    public var channel_id: ChannelSnowflake
    public var guild_id: GuildSnowflake?
  }

  @UnstableEnum<Int>
  public enum ReactionKind: Sendable, Codable {
    case normal  // 0
    case burst  // 1
    case __undocumented(Int)
  }

  /// https://discord.com/developers/docs/topics/gateway-events#message-reaction-add-message-reaction-add-event-fields
  public struct MessageReactionAdd: Sendable, Codable {
    public var type: ReactionKind
    public var user_id: UserSnowflake
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
    public var guild_id: GuildSnowflake?
    public var burst: Bool?
    public var burst_colors: [DiscordColor]?
    public var member: Guild.Member?
    public var emoji: Emoji
    public var message_author_id: UserSnowflake?

    enum CodingKeys: String, CodingKey {
      case type
      case user_id
      case channel_id
      case message_id
      case guild_id
      case burst
      case burst_colors
      case member
      case emoji
      case message_author_id
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      self.type = try container.decode(ReactionKind.self, forKey: .type)
      self.user_id = try container.decode(UserSnowflake.self, forKey: .user_id)
      self.channel_id = try container.decode(
        ChannelSnowflake.self,
        forKey: .channel_id
      )
      self.message_id = try container.decode(
        MessageSnowflake.self,
        forKey: .message_id
      )
      self.guild_id = try container.decodeIfPresent(
        GuildSnowflake.self,
        forKey: .guild_id
      )
      self.burst = try container.decodeIfPresent(Bool.self, forKey: .burst)
      self.burst_colors = try container.decodeIfPresent(
        [String].self,
        forKey: .burst_colors
      )?.compactMap {
        DiscordColor(hex: $0)
      }
      self.member = try container.decode(Guild.Member.self, forKey: .member)
      self.emoji = try container.decode(Emoji.self, forKey: .emoji)
      self.message_author_id = try container.decodeIfPresent(
        UserSnowflake.self,
        forKey: .message_author_id
      )
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      try container.encode(self.type, forKey: .type)
      try container.encode(self.user_id, forKey: .user_id)
      try container.encode(self.channel_id, forKey: .channel_id)
      try container.encode(self.message_id, forKey: .message_id)
      try container.encodeIfPresent(self.guild_id, forKey: .guild_id)
      try container.encodeIfPresent(self.burst, forKey: .burst)
      try container.encodeIfPresent(
        self.burst_colors?.map { $0.asHex() },
        forKey: .burst_colors
      )
      try container.encodeIfPresent(self.member, forKey: .member)
      try container.encode(self.emoji, forKey: .emoji)
      try container.encodeIfPresent(
        self.message_author_id,
        forKey: .message_author_id
      )
    }

  }

  /// https://docs.discord.food/topics/gateway-events#message-reaction-add-many
  public struct MessageReactionAddMany: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
    public var guild_id: GuildSnowflake?
    public var reactions: [DebouncedReactions]

    public struct DebouncedReactions: Sendable, Codable {
      public var emoji: Emoji
      public var users: [UserSnowflake]
    }
  }

  /// https://discord.com/developers/docs/topics/gateway-events#message-reaction-remove
  public struct MessageReactionRemove: Sendable, Codable {
    public var type: ReactionKind
    public var user_id: UserSnowflake
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
    public var guild_id: GuildSnowflake?
    /// FIXME: make non-optional
    public var burst: Bool?
    public var emoji: Emoji
  }

  /// https://discord.com/developers/docs/topics/gateway-events#message-reaction-remove-all
  public struct MessageReactionRemoveAll: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
    public var guild_id: GuildSnowflake?
    public var burst: Bool?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#message-reaction-remove-emoji
  public struct MessageReactionRemoveEmoji: Sendable, Codable {
    public var type: ReactionKind
    public var channel_id: ChannelSnowflake
    public var guild_id: GuildSnowflake?
    public var message_id: MessageSnowflake
    public var burst: Bool?
    public var emoji: Emoji
  }

  /// https://docs.discord.food/topics/gateway-events#request-last-messages-structure
  public struct RequestLastMessages: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channel_ids: [ChannelSnowflake]
  }

  /// https://discord.com/developers/docs/topics/gateway-events#client-status-object
  public struct ClientStatus: Sendable, Codable, Equatable, Hashable {
    public init(
      desktop: Status? = nil,
      mobile: Status? = nil,
      web: Status? = nil,
      embedded: Status? = nil
    ) {
      self.desktop = desktop
      self.mobile = mobile
      self.web = web
      self.embedded = embedded
    }
    
    public var desktop: Status?
    public var mobile: Status?
    public var web: Status?
    public var embedded: Status?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
  public struct PresenceUpdate: Sendable, Codable {
    public init(
      user: PartialUser,
      guild_id: GuildSnowflake? = nil,
      status: Status,
      activities: [Activity],
      client_status: ClientStatus
    ) {
      self.user = user
      self.guild_id = guild_id
      self.status = status
      self.activities = activities
      self.client_status = client_status
    }

    public var user: PartialUser
    public var guild_id: GuildSnowflake?
    public var status: Status
    public var activities: [Activity]
    public var client_status: ClientStatus
  }

  /// Partial ``PresenceUpdate`` object.
  /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
  public struct PartialPresenceUpdate: Sendable, Codable {
    public var user: PartialUser?
    public var guild_id: GuildSnowflake?
    public var status: Status?
    public var activities: [Activity]?
    public var client_status: ClientStatus

    public mutating func update(with presenceUpdate: Gateway.PresenceUpdate) {
      self.guild_id = presenceUpdate.guild_id
      self.status = presenceUpdate.status
      self.activities = presenceUpdate.activities
      self.client_status = presenceUpdate.client_status
    }

    public init(presenceUpdate: Gateway.PresenceUpdate) {
      self.user = presenceUpdate.user
      self.guild_id = presenceUpdate.guild_id
      self.status = presenceUpdate.status
      self.activities = presenceUpdate.activities
      self.client_status = presenceUpdate.client_status
    }
  }

  /// https://discord.com/developers/docs/topics/gateway-events#activity-object
  public struct Activity: Sendable, Codable, Equatable, Hashable {

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-types
    @UnstableEnum<Int>
    public enum Kind: Sendable, Codable {
      case game  // 0
      case streaming  // 1
      case listening  // 2
      case watching  // 3
      case custom  // 4
      case competing  // 5
      case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-timestamps
    public struct Timestamps: Sendable, Codable, Equatable, Hashable {
      public var start: Int?
      public var end: Int?

      public init(start: Int? = nil, end: Int? = nil) {
        self.start = start
        self.end = end
      }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-emoji
    public struct ActivityEmoji: Sendable, Codable, Equatable, Hashable {
      public var name: String
      public var id: EmojiSnowflake?
      public var animated: Bool?

      public init(
        name: String,
        id: EmojiSnowflake? = nil,
        animated: Bool? = nil
      ) {
        self.name = name
        self.id = id
        self.animated = animated
      }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-party
    public struct Party: Sendable, Codable, Equatable, Hashable {
      public var id: String?
      public var size: IntPair?

      public init(id: String? = nil, size: IntPair? = nil) {
        self.id = id
        self.size = size
      }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-assets
    public struct Assets: Sendable, Codable, Equatable, Hashable {
      public var large_image: String?
      public var large_text: String?
      public var small_image: String?
      public var small_text: String?

      public init(
        large_image: String? = nil,
        large_text: String? = nil,
        small_image: String? = nil,
        small_text: String? = nil
      ) {
        self.large_image = large_image
        self.large_text = large_text
        self.small_image = small_image
        self.small_text = small_text
      }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-secrets
    public struct Secrets: Sendable, Codable, Equatable, Hashable {
      public var join: String?
      public var spectate: String?
      public var match: String?

      public init(
        join: String? = nil,
        spectate: String? = nil,
        match: String? = nil
      ) {
        self.join = join
        self.spectate = spectate
        self.match = match
      }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-flags
    @UnstableEnum<UInt>
    public enum Flag: Sendable {
      case instance  // 0
      case join  // 1
      case spectate  // 2
      case joinRequest  // 3
      case sync  // 4
      case play  // 5
      case partyPrivacyFriends  // 6
      case partyPrivacyVoiceChannel  // 7
      case embedded  // 8
      case __undocumented(UInt)
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-buttons
    public struct Button: Sendable, Codable, Equatable, Hashable {
      public var label: String
      public var url: String

      public init(label: String, url: String) {
        self.label = label
        self.url = url
      }

      public init(from decoder: any Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
          self.label = try container.decode(String.self, forKey: .label)
          self.url = try container.decode(String.self, forKey: .url)
        } else {
          self.label = try decoder.singleValueContainer().decode(String.self)
          self.url = ""
        }
      }
    }

    public var name: String?
    public var type: Kind?
    public var url: String?
    public var created_at: Int?
    public var timestamps: Timestamps?
    public var application_id: ApplicationSnowflake?
    public var details: String?
    public var state: String?
    public var emoji: ActivityEmoji?
    public var party: Party?
    public var assets: Assets?
    public var secrets: Secrets?
    public var instance: Bool?
    public var flags: IntBitField<Flag>?
    public var buttons: [Button]?

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decodeIfPresent(String.self, forKey: .name)
      self.type = try container.decodeIfPresent(Kind.self, forKey: .type)
      self.url = try container.decodeIfPresent(String.self, forKey: .url)
      self.created_at = try container.decodeIfPresent(
        Int.self,
        forKey: .created_at
      )
      self.timestamps = try container.decodeIfPresent(
        Timestamps.self,
        forKey: .timestamps
      )
      self.details = try container.decodeIfPresent(
        String.self,
        forKey: .details
      )
      self.state = try container.decodeIfPresent(String.self, forKey: .state)
      self.emoji = try container.decodeIfPresent(
        ActivityEmoji.self,
        forKey: .emoji
      )
      self.party = try container.decodeIfPresent(Party.self, forKey: .party)
      self.assets = try container.decodeIfPresent(Assets.self, forKey: .assets)
      self.secrets = try container.decodeIfPresent(
        Secrets.self,
        forKey: .secrets
      )
      self.instance = try container.decodeIfPresent(
        Bool.self,
        forKey: .instance
      )
      self.flags = try container.decodeIfPresent(
        IntBitField<Flag>.self,
        forKey: .flags
      )
      self.buttons = try container.decodeIfPresent(
        [Button].self,
        forKey: .buttons
      )

      /// Discord sometimes sends a number instead of a valid Snowflake `String`.
      do {
        self.application_id = try container.decodeIfPresent(
          ApplicationSnowflake.self,
          forKey: .application_id
        )
      } catch let error as DecodingError {
        if case .typeMismatch = error {
          let number = try container.decode(Int.self, forKey: .application_id)
          self.application_id = .init("\(number)")
        } else {
          throw error
        }
      }
    }

    /// Bot users are only able to set `name`, `state`, `type`, and `url`.
    public init(
      name: String,
      type: Kind,
      url: String? = nil,
      state: String? = nil
    ) {
      self.name = name
      self.type = type
      self.url = url
      self.state = state
    }
  }

  /// https://discord.com/developers/docs/topics/gateway-events#message-poll-vote-add-message-poll-vote-add-fields
  /// https://discord.com/developers/docs/topics/gateway-events#message-poll-vote-remove-message-poll-vote-remove-fields
  public struct MessagePollVote: Sendable, Codable {
    public var user_id: UserSnowflake
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
    public var guild_id: GuildSnowflake?
    public var answer_id: Int
  }

  /// https://discord.com/developers/docs/topics/gateway-events#typing-start-typing-start-event-fields
  public struct TypingStart: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var guild_id: GuildSnowflake?
    public var user_id: UserSnowflake
    public var timestamp: Int
    public var member: Guild.Member?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#voice-server-update-voice-server-update-event-fields
  public struct VoiceServerUpdate: Sendable, Codable {
    public var token: String
    public var guild_id: GuildSnowflake
    public var endpoint: String?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#webhooks-update-webhooks-update-event-fields
  public struct WebhooksUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake
  }

  /// https://discord.com/developers/docs/topics/gateway#get-gateway
  public struct URL: Sendable, Codable {
    public var url: String
  }

  /// https://discord.com/developers/docs/topics/gateway#get-gateway-bot-json-response
  public struct BotConnectionInfo: Sendable, Codable {

    /// https://discord.com/developers/docs/topics/gateway#session-start-limit-object-session-start-limit-structure
    public struct SessionStartLimit: Sendable, Codable {
      public var total: Int
      public var remaining: Int
      public var reset_after: Int
      public var max_concurrency: Int
    }

    public var url: String
    public var shards: Int
    public var session_start_limit: SessionStartLimit
  }

  /// https://docs.discord.food/topics/gateway-events#channel-statuses
  public struct VoiceChannelStatuses: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channels: [Status]

    public struct Status: Sendable, Codable {
      public var id: ChannelSnowflake
      public var status: String
    }
  }

  /// https://docs.discord.food/topics/gateway-events#voice-channel-status-update
  public struct VoiceChannelStatusUpdate: Sendable, Codable {
    public var id: ChannelSnowflake
    public var guild_id: GuildSnowflake
    public var status: String
  }

  /// https://docs.discord.food/topics/gateway-events#call-create
  public struct CallCreate: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
    public var region: String
    public var ringing: [UserSnowflake]
  }

  /// https://docs.discord.food/topics/gateway-events#call-update
  public struct CallUpdate: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
    public var region: String
    public var ringing: [UserSnowflake]
    public var voice_states: [VoiceState]
  }

  /// https://docs.discord.food/topics/gateway-events#call-delete
  public struct CallDelete: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var unavailable: Bool?
  }

  /// https://docs.discord.food/topics/gateway-events#channel-member-count-update
  public struct ChannelMemberCountUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake
    public var member_count: Int
    public var presence_count: Int
  }

  /// https://docs.discord.food/topics/gateway-events#request-channel-member-count
  public struct RequestChannelMemberCount: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake
  }

  /// https://docs.discord.food/topics/gateway-events#console-command-update
  public struct ConsoleCommandUpdate: Sendable, Codable {}

  /// https://docs.discord.food/topics/gateway-events#conversation-summary-update
  public struct ConversationSummaryUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake
  }

  /// https://docs.discord.food/topics/gateway-events#dm-settings-upsell-show
  public struct DMSettingsShow: Sendable, Codable {
    public var guild_id: GuildSnowflake
  }

  /// https://docs.discord.food/topics/gateway-events#friend-suggestion-create
  public typealias FriendSuggestionCreate = FriendSuggestion

  /// https://docs.discord.food/topics/gateway-events#friend-suggestion-delete
  public struct FriendSuggestionDelete: Sendable, Codable {
    public var suggested_user_id: UserSnowflake
  }

  /// https://docs.discord.food/topics/gateway-events#guild-application-command-index-update
  public struct GuildApplicationCommandIndexUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake
  }

  //	{
  //		"op": 37,
  //		"d": {
  //			"subscriptions": {
  //				"1214679871964450836": { // server id
  //					"typing": true, // get typing events
  //					"activities": true, // get activity events
  //					"threads": true, // get thread events
  //					"channels": { // channels to get member list chunks for
  //						"1223399680101191792": [ // channel id
  //							// arrays below contain 2 ints, for lower and upper bound chunks of member data from the channel
  //							[
  //								0,
  //								99
  //							],
  //							[
  //								100,
  //								199
  //							], // etc
  //						]
  //					},
  //	      	"thread_member_lists": [ // member list chunks for threads?
  //						"1295541912010362932"
  //					]
  //				}
  //			}
  //		}
  //	}
  /// Sadly there is no documentation for this payload, but I have made it as user friendly as I could
  /// According to dolfies this is a very annoying and complex gateway op :c
  public struct UpdateGuildSubscriptions: Sendable, Codable {
    public var subscriptions: [GuildSnowflake: GuildSubscription]

    public init(subscriptions: [GuildSnowflake: GuildSubscription]) {
      self.subscriptions = subscriptions
    }

    public struct GuildSubscription: Sendable, Codable {
      // events you can choose to receive
      public var typing: Bool
      public var activities: Bool
      public var threads: Bool

      public var channels: [ChannelSnowflake: [IntPair]]
      public var thread_member_lists: [ChannelSnowflake]?

      public init(
        typing: Bool,
        activities: Bool,
        threads: Bool,
        channels: [ChannelSnowflake: [IntPair]],
        thread_member_lists: [ChannelSnowflake]? = nil
      ) {
        self.typing = typing
        self.activities = activities
        self.threads = threads
        self.channels = channels
        self.thread_member_lists = thread_member_lists
      }
    }
  }

  /// https://docs.discord.food/topics/gateway-events#guild-scheduled-event-exceptions-delete
  public struct GuildScheduledEventExceptionsDelete: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var event_id: GuildScheduledEventSnowflake
  }

  /// https://docs.discord.food/topics/gateway-events#interaction-create
  public struct InteractionCreate: Sendable, Codable {
    public var id: InteractionSnowflake
    public var nonce: String?
  }

  /// https://docs.discord.food/topics/gateway-events#interaction-failure
  public struct InteractionFailure: Sendable, Codable {
    public var id: InteractionSnowflake
    public var nonce: String?
    public var reason_code: Reason

    @UnstableEnum<UInt>
    public enum Reason: Sendable, Codable {
      case unknown  // 1
      case timeout  // 2
      case activityLaunchUnknownApplication  // 3
      case activityLaunchUnknownChannel  // 4
      case activityLaunchUnknownGuild  // 5
      case activityLaunchInvalidPlatform  // 6
      case activityLaunchNotInExperiment  // 7
      case activityLaunchInvalidChannelType  // 8
      case activityLaunchInvalidChannelNoAFK  // 9
      case activityLaunchInvalidDevPreviewGuildSize  // 10
      case activityLaunchInvalidUserAgeGate  // 11
      case activityLaunchInvalidUserVerificationLevel  // 12
      case activityLaunchInvalidUserPermissions  // 13
      case activityLaunchInvalidConfigurationNotEmbedded  // 14
      case activityLaunchInvalidConfigurationPlatformNotSupported  // 15
      case activityLaunchInvalidConfigurationPlatformNotReleased  // 16
      case activityLaunchFailedToLaunch  // 17
      case activityLaunchInvalidUserNoAccessToActivity  // 18
      case activityLaunchInvalidLocationType  // 19
      case activityLaunchInvalidUserRegionForApplication  // 20

      case __undocumented(UInt)
    }
  }

  /// https://docs.discord.food/topics/gateway-events#interaction-success
  public struct InteractionSuccess: Sendable, Codable {
    public var id: InteractionSnowflake
    public var nonce: String?
  }

  /// https://docs.discord.food/topics/gateway-events#application-command-autocomplete-response
  public struct ApplicationCommandAutocomplete: Sendable, Codable {
    public var choices: [ApplicationCommand.Option.Choice]
    public var nonce: String?
  }

  /// https://docs.discord.food/topics/gateway-events#interaction-modal-create
  public struct InteractionModalCreate: Sendable, Codable {
    public var id: InteractionSnowflake
    public var channel_id: ChannelSnowflake
    public var custom_id: String
    public var application: PartialApplication
    public var title: String
    public var nonce: String?
    public var components: [Interaction.MessageComponent]  // FIXME: might not be correct
  }

  /// https://docs.discord.food/topics/gateway-events#interaction-iframe-modal-create
  public struct InteractionIFrameModalCreate: Sendable, Codable {
    public var id: InteractionSnowflake
    public var channel_id: ChannelSnowflake
    public var custom_id: String
    public var application: PartialApplication
    public var title: String
    public var nonce: String?
    public var iframe_path: String
    public var modal_size: ModalSize

    @UnstableEnum<UInt>
    public enum ModalSize: Sendable, Codable {
      case small  // 1
      case normal  // 2
      case big  // 3
      case __undocumented(UInt)
    }
  }

  /// https://docs.discord.food/topics/gateway-events#recent-mention-delete
  public struct RecentMentionDelete: Sendable, Codable {
    public var message_id: MessageSnowflake
  }

  /// https://docs.discord.food/topics/gateway-events#last-messages
  public struct LastMessages: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var messages: [MessageCreate]
  }

  // https://docs.discord.food/resources/user-settings#notification-settings-object
  public struct NotificationSettings: Sendable, Codable {
    public var flags: IntBitField<Flag>?

    @UnstableEnum<UInt>
    public enum Flag: Sendable {
      case useNewNotifications  // 4
      case mentionOnAllMessages  // 5
      case __undocumented(UInt)
    }
  }

  ///	https://docs.discord.food/topics/gateway-events#partial-relationship-structure
  public struct PartialRelationship: Sendable, Codable {
    public var id: UserSnowflake
    public var type: DiscordRelationship.Kind
    public var nickname: String?
    public var stranger_request: Bool?
    public var user_ignored: Bool?
    public var since: DiscordTimestamp?
  }

  /// https://docs.discord.food/topics/gateway-events#saved-message-create
  public typealias SavedMessageCreate = SavedMessage

  /// https://docs.discord.food/topics/gateway-events#saved-message-delete
  public struct SavedMessageDelete: Sendable, Codable {
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
  }

  /// https://docs.discord.food/resources/presence#session-object
  public struct Session: Sendable, Codable {
    public var session_id: String
    public var client_info: ClientInfo
    public var status: String
    public var activities: [Activity]
    public var hidden_activities: [Activity]
    public var active: Bool?

    public var isHeadless: Bool {
      session_id.hasSuffix("h:")
    }

    public struct ClientInfo: Sendable, Codable {
      // TODO: Make enums
      public var client: ClientType
      public var os: String
      public var version: Int

      @UnstableEnum<String>
      public enum ClientType: Sendable, Codable {
        case desktop  // desktop
        case web  // web
        case mobile  // mobile
        case __undocumented(String)
      }

      @UnstableEnum<String>
      public enum OperatingSystemType: Sendable, Codable {
        case windows  // windows
        case osx  // osx
        case linux  // linux
        case android  // android
        case ios  // ios
        case playstation  // playstation
        case xbox  // xbox
        case __undocumented(String)
      }
    }
  }

  /// https://docs.discord.food/topics/gateway-events#sessions-replace
  public typealias SessionReplace = [Session]

  /// https://docs.discord.food/topics/gateway-events#user-application-update
  public struct UserApplicationUpdate: Sendable, Codable {
    public var application_id: ApplicationSnowflake
  }

  /// https://docs.discord.food/topics/gateway-events#user-application-remove
  public typealias UserApplicationRemove = UserApplicationUpdate

  /// https://docs.discord.food/topics/gateway-events#user-connections-update
  public enum UserConnectionsUpdate: Sendable, Codable {
    case id(UserSnowflake)
    case connection(DiscordUser.Connection)

    public init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()

      // Try decoding as a full connection first
      if let connection = try? container.decode(DiscordUser.Connection.self) {
        self = .connection(connection)
        return
      }

      // Then try decoding as {"user_id": <UserSnowflake>}
      if let object = try? container.decode([String: UserSnowflake].self),
        let userId = object["user_id"]
      {
        self = .id(userId)
        return
      }

      // If neither worked, throw
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Expected either a User Connection or Snowflake"
      )
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .connection(let connection):
        try container.encode(connection)
      case .id(let userId):
        try container.encode(["user_id": userId])
      }
    }
  }

  /// https://docs.discord.food/topics/gateway-events#user-note-update
  public struct UserNote: Sendable, Codable {
    public var id: UserSnowflake
    public var note: String
  }

  /// https://docs.discord.food/topics/gateway-events#user-settings-proto-update
  public struct UserSettingsProtoUpdate: Sendable, Codable {
    public var settings: UserSettingsProto
    public var partial: Bool
  }

  /// https://docs.discord.food/topics/gateway-events#user-settings-proto-structure
  public enum UserSettingsProto: Sendable, Codable {
    case preloaded(DiscordProtos_DiscordUsers_V1_PreloadedUserSettings)
    case frecency(DiscordProtos_DiscordUsers_V1_FrecencyUserSettings)
    case unknown(String)

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let kind = try container.decode(Kind.self, forKey: .type)
      switch kind {
      case .preloaded:
        let preloaded = try container.decode(
          DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.self,
          forKey: .settings
        )
        self = .preloaded(preloaded)
      case .frecency:
        let frecency = try container.decode(
          DiscordProtos_DiscordUsers_V1_FrecencyUserSettings.self,
          forKey: .settings
        )
        self = .frecency(frecency)
      default:
        let str = try container.decode(String.self, forKey: .settings)
        self = .unknown(str)
      }
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let kind = {
        return switch self {
        case .preloaded: 1
        case .frecency: 2
        default: 3  // bad but idc man its been 3 days
        }
      }()
      switch self {
      case .preloaded(let data):
        try container.encode(data, forKey: .settings)
      case .frecency(let data):
        try container.encode(data, forKey: .settings)
      case .unknown(let string):
        try container.encode(string, forKey: .settings)
      }
      try container.encode(kind, forKey: .type)
    }

    private enum CodingKeys: String, CodingKey {
      case settings  // the string b64 value
      case type  // the type hint
    }

    @UnstableEnum<UInt>
    public enum Kind: Sendable, Codable {
      case preloaded  // 1
      case frecency  // 2
      case __undocumented(UInt)
    }
  }

  /// https://docs.discord.food/topics/gateway-events#guild-soundboard-sound-create
  /// https://docs.discord.food/topics/gateway-events#guild-soundboard-sound-update
  public typealias SoundboardSounds = [SoundboardSound]

  /// https://docs.discord.food/topics/gateway-events#guild-soundboard-sound-delete
  public struct SoundboardSoundDelete: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var soundboard_sounds: SoundboardSounds
  }

  /// I cannot find any details on `CHANNEL_UNREAD_UPDATE`, so here's an example.
  /// {
  /// 	"guild_id": "1248793573",
  /// 	"channel_unread_updates": [
  /// 		{
  ///				"last_pin_timestamp": "2021-06-10T14:21:21+00:00", // ?
  ///				"last_message_id": "852791689365028884",
  ///				"id": "772442439402127371"
  ///			}
  ///		]
  /// }
  ///
  /// I believe Accord probably has stuff on the topic
  /// dolfies says its complicated, be sure to ask him later if he finishes docs
  ///
  /// from guessing, guild id might be nil for dms?
  public struct ChannelUnreadUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake?
    public var channel_unread_updates: [UnreadUpdate]

    public struct UnreadUpdate: Sendable, Codable {
      public var last_pin_timestamp: DiscordTimestamp?
      public var last_message_id: MessageSnowflake
      public var id: ChannelSnowflake
    }
  }
}
