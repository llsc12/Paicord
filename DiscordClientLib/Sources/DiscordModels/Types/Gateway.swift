import Foundation

public struct Gateway: Sendable, Codable {

  /// https://discord.com/developers/docs/topics/opcodes-and-status-codes#opcodes-and-status-codes
  public enum Opcode: UInt8, Sendable, Codable, CustomStringConvertible {
    case dispatch = 0
    case heartbeat = 1
    case identify = 2
    case presenceUpdate = 3
    case voiceStateUpdate = 4
    case resume = 6
    case reconnect = 7
    case requestGuildMembers = 8
    case invalidSession = 9
    case hello = 10
    case heartbeatAccepted = 11
    case requestSoundboardSounds = 31

    // user only gateway opcodes ?
    case callConnect = 13
    case guildSubscriptions = 14
    case lobbyVoiceStates = 17
    case streamCreate = 18
    case streamDelete = 19
    case streamWatch = 20
    case streamPing = 21
    case streamSetPaused = 22
    case requestForumUnread = 28
    case remoteCommand = 29
    case requestDeletedEntityIds = 30
    case speedtestCreate = 32
    case speedtestDelete = 33
    case requestLastMessages = 34
    case searchRecentMembers = 35
    case requestChannelStatuses = 36
    case guildSubscriptionsBulk = 37
    case guildChannelsResync = 38
    case requestChannelMemberCounts = 39
    case qosHeartbeat = 40
    case updateTimeSpentSessionId = 41

    public var description: String {
      switch self {
      case .dispatch: return "dispatch"
      case .heartbeat: return "heartbeat"
      case .identify: return "identify"
      case .presenceUpdate: return "presenceUpdate"
      case .voiceStateUpdate: return "voiceStateUpdate"
      case .resume: return "resume"
      case .reconnect: return "reconnect"
      case .requestGuildMembers: return "requestGuildMembers"
      case .invalidSession: return "invalidSession"
      case .hello: return "hello"
      case .heartbeatAccepted: return "heartbeatAccepted"
      case .requestSoundboardSounds: return "requestSoundboardSounds"
      case .callConnect: return "callConnect"
      case .guildSubscriptions: return "guildSubscriptions"
      case .lobbyVoiceStates: return "lobbyVoiceStates"
      case .streamCreate: return "streamCreate"
      case .streamDelete: return "streamDelete"
      case .streamWatch: return "streamWatch"
      case .streamPing: return "streamPing"
      case .streamSetPaused: return "streamSetPaused"
      case .requestForumUnread: return "requestForumUnread"
      case .remoteCommand: return "remoteCommand"
      case .requestDeletedEntityIds: return "requestDeletedEntityIds"
      case .speedtestCreate: return "speedtestCreate"
      case .speedtestDelete: return "speedtestDelete"
      case .requestLastMessages: return "requestLastMessages"
      case .searchRecentMembers: return "searchRecentMembers"
      case .requestChannelStatuses: return "requestChannelStatuses"
      case .guildSubscriptionsBulk: return "guildSubscriptionsBulk"
      case .guildChannelsResync: return "guildChannelsResync"
      case .requestChannelMemberCounts: return "requestChannelMemberCounts"
      case .qosHeartbeat: return "qosHeartbeat"
      case .updateTimeSpentSessionId: return "updateTimeSpentSessionId"
      }
    }
  }

  /// The top-level gateway event.
  /// https://discord.com/developers/docs/topics/gateway#gateway-events
  public struct Event: Sendable, Codable {

    /// This enum is just for swiftly organizing Discord gateway event's `data`.
    /// You need to read each case's inner payload's documentation for more info.
    ///
    /// `indirect` is used to mitigate this issue: https://github.com/swiftlang/swift/issues/74303
    indirect
      public enum Payload: Sendable
    {
      /// https://discord.com/developers/docs/topics/gateway-events#heartbeat
      case heartbeat(lastSequenceNumber: Int?)
      case identify(Identify)
      case hello(Hello)
      case ready(Ready)
      /// Is sent when we want to send a resume request
      case resume(Resume)
      /// Is received when Discord has ended replying our lost events, after a resume
      /// https://discord.com/developers/docs/topics/gateway-events#resumed
      case resumed
      /// https://discord.com/developers/docs/topics/gateway-events#invalid-session
      case invalidSession(canResume: Bool)

      case channelCreate(DiscordChannel)
      case channelUpdate(DiscordChannel)
      case channelDelete(DiscordChannel)
      case channelPinsUpdate(ChannelPinsUpdate)

      case threadCreate(DiscordChannel)
      case threadUpdate(DiscordChannel)
      case threadDelete(ThreadDelete)

      case threadSyncList(ThreadListSync)
      case threadMemberUpdate(ThreadMemberUpdate)
      case threadMembersUpdate(ThreadMembersUpdate)

      case entitlementCreate(Entitlement)
      case entitlementUpdate(Entitlement)
      case entitlementDelete(Entitlement)

      case guildCreate(GuildCreate)
      case guildUpdate(Guild)
      case guildDelete(UnavailableGuild)

      case guildBanAdd(GuildBan)
      case guildBanRemove(GuildBan)

      case guildEmojisUpdate(GuildEmojisUpdate)
      case guildStickersUpdate(GuildStickersUpdate)
      case guildIntegrationsUpdate(GuildIntegrationsUpdate)

      case guildMemberAdd(GuildMemberAdd)
      case guildMemberRemove(GuildMemberRemove)
      case guildMemberUpdate(GuildMemberAdd)

      case guildMembersChunk(GuildMembersChunk)
      case requestGuildMembers(RequestGuildMembers)

      case guildRoleCreate(GuildRole)
      case guildRoleUpdate(GuildRole)
      case guildRoleDelete(GuildRoleDelete)

      case guildScheduledEventCreate(GuildScheduledEvent)
      case guildScheduledEventUpdate(GuildScheduledEvent)
      case guildScheduledEventDelete(GuildScheduledEvent)

      case guildScheduledEventUserAdd(GuildScheduledEventUser)
      case guildScheduledEventUserRemove(GuildScheduledEventUser)

      case guildAuditLogEntryCreate(AuditLog.Entry)

      case integrationCreate(IntegrationCreate)
      case integrationUpdate(IntegrationCreate)
      case integrationDelete(IntegrationDelete)

      case interactionCreate(Interaction)

      case inviteCreate(InviteCreate)
      case inviteDelete(InviteDelete)

      case messageCreate(MessageCreate)
      case messageUpdate(DiscordChannel.PartialMessage)
      case messageDelete(MessageDelete)
      case messageDeleteBulk(MessageDeleteBulk)

      case messageReactionAdd(MessageReactionAdd)
      case messageReactionRemove(MessageReactionRemove)
      case messageReactionRemoveAll(MessageReactionRemoveAll)
      case messageReactionRemoveEmoji(MessageReactionRemoveEmoji)

      case presenceUpdate(PresenceUpdate)
      case requestPresenceUpdate(Identify.Presence)

      case stageInstanceCreate(StageInstance)
      case stageInstanceDelete(StageInstance)
      case stageInstanceUpdate(StageInstance)

      case typingStart(TypingStart)

      case userUpdate(DiscordUser)

      case voiceStateUpdate(VoiceState)
      case requestVoiceStateUpdate(VoiceStateUpdate)

      case voiceServerUpdate(VoiceServerUpdate)

      case webhooksUpdate(WebhooksUpdate)

      case applicationCommandPermissionsUpdate(
        GuildApplicationCommandPermissions
      )

      case autoModerationRuleCreate(AutoModerationRule)
      case autoModerationRuleUpdate(AutoModerationRule)
      case autoModerationRuleDelete(AutoModerationRule)

      case autoModerationActionExecution(AutoModerationActionExecution)

      case messagePollVoteAdd(MessagePollVote)
      case messagePollVoteRemove(MessagePollVote)

      case __undocumented

      public var correspondingIntents: [Intent] {
        switch self {
        case .heartbeat, .identify, .hello, .ready, .resume, .resumed,
          .invalidSession, .requestGuildMembers,
          .requestPresenceUpdate, .requestVoiceStateUpdate, .interactionCreate,
          .entitlementCreate,
          .entitlementUpdate, .entitlementDelete,
          .applicationCommandPermissionsUpdate, .userUpdate,
          .voiceServerUpdate:
          return []
        case .guildCreate, .guildUpdate, .guildDelete, .guildMembersChunk,
          .guildRoleCreate, .guildRoleUpdate,
          .guildRoleDelete, .channelCreate, .channelUpdate, .channelDelete,
          .threadCreate, .threadUpdate,
          .threadDelete, .threadSyncList, .threadMemberUpdate,
          .stageInstanceCreate, .stageInstanceDelete,
          .stageInstanceUpdate:
          return [.guilds]
        case .channelPinsUpdate:
          return [.guilds, .directMessages]
        case .threadMembersUpdate, .guildMemberAdd, .guildMemberRemove,
          .guildMemberUpdate:
          return [.guilds, .guildMembers]
        case .guildAuditLogEntryCreate, .guildBanAdd, .guildBanRemove:
          return [.guildModeration]
        case .guildEmojisUpdate, .guildStickersUpdate:
          return [.guildEmojisAndStickers]
        case .guildIntegrationsUpdate, .integrationCreate, .integrationUpdate,
          .integrationDelete:
          return [.guildIntegrations]
        case .webhooksUpdate:
          return [.guildWebhooks]
        case .inviteCreate, .inviteDelete:
          return [.guildInvites]
        case .voiceStateUpdate:
          return [.guildVoiceStates]
        case .presenceUpdate:
          return [.guildPresences]
        case .messageCreate, .messageUpdate, .messageDelete:
          return [.guildMessages, .directMessages]
        case .messageDeleteBulk:
          return [.guildMessages]
        case .messageReactionAdd, .messageReactionRemove,
          .messageReactionRemoveAll,
          .messageReactionRemoveEmoji:
          return [.guildMessageReactions]
        case .typingStart:
          return [.guildMessageTyping]
        case .guildScheduledEventCreate, .guildScheduledEventUpdate,
          .guildScheduledEventDelete,
          .guildScheduledEventUserAdd, .guildScheduledEventUserRemove:
          return [.guildScheduledEvents]
        case .autoModerationRuleCreate, .autoModerationRuleUpdate,
          .autoModerationRuleDelete:
          return [.autoModerationConfiguration]
        case .autoModerationActionExecution:
          return [.autoModerationExecution]
        case .messagePollVoteAdd:
          return [.guildMessagePolls, .directMessagePolls]
        case .messagePollVoteRemove:
          return [.guildMessagePolls, .directMessagePolls]
        case .__undocumented:
          return []
        }
      }
    }

    public enum GatewayDecodingError: Error, CustomStringConvertible {
      /// The dispatch event type '\(type ?? "nil")' is unhandled. This is probably a new Discord event which is not yet officially documented. I actively look for new events, and check Discord docs, so there is nothing to worry about. The library will support this event when it should.
      case unhandledDispatchEvent(type: String?)

      public var description: String {
        switch self {
        case let .unhandledDispatchEvent(type):
          return
            "Gateway.Event.GatewayDecodingError.unhandledDispatchEvent(type: \(type ?? "nil"))"
        }
      }
    }

    enum CodingKeys: String, CodingKey {
      case opcode = "op"
      case data = "d"
      case sequenceNumber = "s"
      case type = "t"
    }

    public var opcode: Opcode
    public var data: Payload?
    public var sequenceNumber: Int?
    public var type: String?

    public init(
      opcode: Opcode,
      data: Payload? = nil,
      sequenceNumber: Int? = nil,
      type: String? = nil
    ) {
      self.opcode = opcode
      self.data = data
      self.sequenceNumber = sequenceNumber
      self.type = type
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.opcode = try container.decode(Opcode.self, forKey: .opcode)
      self.sequenceNumber = try container.decodeIfPresent(
        Int.self,
        forKey: .sequenceNumber
      )
      self.type = try container.decodeIfPresent(String.self, forKey: .type)

      func decodeData<D: Decodable>(as type: D.Type = D.self) throws -> D {
        try container.decode(D.self, forKey: .data)
      }

      switch opcode {
      case .heartbeat, .heartbeatAccepted, .reconnect:
        guard try container.decodeNil(forKey: .data) else {
          throw DecodingError.typeMismatch(
            Optional<Never>.self,
            .init(
              codingPath: container.codingPath,
              debugDescription:
                "`\(opcode)` opcode is supposed to have no data."
            )
          )
        }
        self.data = nil
      case .identify, .presenceUpdate, .voiceStateUpdate, .resume,
        .requestGuildMembers, .requestSoundboardSounds, .callConnect,
        .guildSubscriptions, .lobbyVoiceStates, .streamCreate, .streamDelete,
        .streamWatch, .streamPing, .streamSetPaused, .requestForumUnread,
        .remoteCommand, .requestDeletedEntityIds, .speedtestCreate,
        .speedtestDelete, .requestLastMessages, .searchRecentMembers,
        .requestChannelStatuses, .guildSubscriptionsBulk, .guildChannelsResync,
        .requestChannelMemberCounts, .qosHeartbeat, .updateTimeSpentSessionId:
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: container.codingPath,
            debugDescription:
              "'\(opcode)' opcode is supposed to never be received."
          )
        )
      case .invalidSession:
        self.data = try .invalidSession(canResume: decodeData())
      case .hello:
        self.data = try .hello(decodeData())
      case .dispatch:
        switch self.type {
        case "READY":
          self.data = try .ready(decodeData())
        case "RESUMED":
          self.data = .resumed
        case "CHANNEL_CREATE":
          self.data = try .channelCreate(decodeData())
        case "CHANNEL_UPDATE":
          self.data = try .channelUpdate(decodeData())
        case "CHANNEL_DELETE":
          self.data = try .channelDelete(decodeData())
        case "CHANNEL_PINS_UPDATE":
          self.data = try .channelPinsUpdate(decodeData())
        case "THREAD_CREATE":
          self.data = try .threadCreate(decodeData())
        case "THREAD_UPDATE":
          self.data = try .threadUpdate(decodeData())
        case "THREAD_DELETE":
          self.data = try .threadDelete(decodeData())
        case "THREAD_LIST_SYNC":
          self.data = try .threadSyncList(decodeData())
        case "THREAD_MEMBER_UPDATE":
          self.data = try .threadMemberUpdate(decodeData())
        case "THREAD_MEMBERS_UPDATE":
          self.data = try .threadMembersUpdate(decodeData())
        case "ENTITLEMENT_CREATE":
          self.data = try .entitlementCreate(decodeData())
        case "ENTITLEMENT_UPDATE":
          self.data = try .entitlementUpdate(decodeData())
        case "ENTITLEMENT_DELETE":
          self.data = try .entitlementDelete(decodeData())
        case "GUILD_CREATE":
          self.data = try .guildCreate(decodeData())
        case "GUILD_UPDATE":
          self.data = try .guildUpdate(decodeData())
        case "GUILD_DELETE":
          self.data = try .guildDelete(decodeData())
        case "GUILD_BAN_ADD":
          self.data = try .guildBanAdd(decodeData())
        case "GUILD_BAN_REMOVE":
          self.data = try .guildBanRemove(decodeData())
        case "GUILD_EMOJIS_UPDATE":
          self.data = try .guildEmojisUpdate(decodeData())
        case "GUILD_STICKERS_UPDATE":
          self.data = try .guildStickersUpdate(decodeData())
        case "GUILD_INTEGRATIONS_UPDATE":
          self.data = try .guildIntegrationsUpdate(decodeData())
        case "GUILD_MEMBER_ADD":
          self.data = try .guildMemberAdd(decodeData())
        case "GUILD_MEMBER_REMOVE":
          self.data = try .guildMemberRemove(decodeData())
        case "GUILD_MEMBER_UPDATE":
          self.data = try .guildMemberUpdate(decodeData())
        case "GUILD_MEMBERS_CHUNK":
          self.data = try .guildMembersChunk(decodeData())
        case "GUILD_ROLE_CREATE":
          self.data = try .guildRoleCreate(decodeData())
        case "GUILD_ROLE_UPDATE":
          self.data = try .guildRoleUpdate(decodeData())
        case "GUILD_ROLE_DELETE":
          self.data = try .guildRoleDelete(decodeData())
        case "GUILD_SCHEDULED_EVENT_CREATE":
          self.data = try .guildScheduledEventCreate(decodeData())
        case "GUILD_SCHEDULED_EVENT_UPDATE":
          self.data = try .guildScheduledEventUpdate(decodeData())
        case "GUILD_SCHEDULED_EVENT_DELETE":
          self.data = try .guildScheduledEventDelete(decodeData())
        case "GUILD_SCHEDULED_EVENT_USER_ADD":
          self.data = try .guildScheduledEventUserAdd(decodeData())
        case "GUILD_SCHEDULED_EVENT_USER_REMOVE":
          self.data = try .guildScheduledEventUserRemove(decodeData())
        case "GUILD_AUDIT_LOG_ENTRY_CREATE":
          self.data = try .guildAuditLogEntryCreate(decodeData())
        case "INTEGRATION_CREATE":
          self.data = try .integrationCreate(decodeData())
        case "INTEGRATION_UPDATE":
          self.data = try .integrationUpdate(decodeData())
        case "INTEGRATION_DELETE":
          self.data = try .integrationDelete(decodeData())
        case "INTERACTION_CREATE":
          self.data = try .interactionCreate(decodeData())
        case "INVITE_CREATE":
          self.data = try .inviteCreate(decodeData())
        case "INVITE_DELETE":
          self.data = try .inviteDelete(decodeData())
        case "MESSAGE_CREATE":
          self.data = try .messageCreate(decodeData())
        case "MESSAGE_UPDATE":
          self.data = try .messageUpdate(decodeData())
        case "MESSAGE_DELETE":
          self.data = try .messageDelete(decodeData())
        case "MESSAGE_DELETE_BULK":
          self.data = try .messageDeleteBulk(decodeData())
        case "MESSAGE_REACTION_ADD":
          self.data = try .messageReactionAdd(decodeData())
        case "MESSAGE_REACTION_REMOVE":
          self.data = try .messageReactionRemove(decodeData())
        case "MESSAGE_REACTION_REMOVE_ALL":
          self.data = try .messageReactionRemoveAll(decodeData())
        case "MESSAGE_REACTION_REMOVE_EMOJI":
          self.data = try .messageReactionRemoveEmoji(decodeData())
        case "PRESENCE_UPDATE":
          self.data = try .presenceUpdate(decodeData())
        case "STAGE_INSTANCE_CREATE":
          self.data = try .stageInstanceCreate(decodeData())
        case "STAGE_INSTANCE_DELETE":
          self.data = try .stageInstanceDelete(decodeData())
        case "STAGE_INSTANCE_UPDATE":
          self.data = try .stageInstanceUpdate(decodeData())
        case "TYPING_START":
          self.data = try .typingStart(decodeData())
        case "USER_UPDATE":
          self.data = try .userUpdate(decodeData())
        case "VOICE_STATE_UPDATE":
          self.data = try .voiceStateUpdate(decodeData())
        case "VOICE_SERVER_UPDATE":
          self.data = try .voiceServerUpdate(decodeData())
        case "WEBHOOKS_UPDATE":
          self.data = try .webhooksUpdate(decodeData())
        case "APPLICATION_COMMAND_PERMISSIONS_UPDATE":
          self.data = try .applicationCommandPermissionsUpdate(decodeData())
        case "AUTO_MODERATION_RULE_CREATE":
          self.data = try .autoModerationRuleCreate(decodeData())
        case "AUTO_MODERATION_RULE_UPDATE":
          self.data = try .autoModerationRuleUpdate(decodeData())
        case "AUTO_MODERATION_RULE_DELETE":
          self.data = try .autoModerationRuleDelete(decodeData())
        case "AUTO_MODERATION_ACTION_EXECUTION":
          self.data = try .autoModerationActionExecution(decodeData())
        case "MESSAGE_POLL_VOTE_ADD":
          self.data = try .messagePollVoteAdd(decodeData())
        case "MESSAGE_POLL_VOTE_REMOVE":
          self.data = try .messagePollVoteRemove(decodeData())
        default:
          throw GatewayDecodingError.unhandledDispatchEvent(type: self.type)
        }
      }
    }

    public enum EncodingError: Error, CustomStringConvertible {
      /// This event is not supposed to be sent at all. This could be a library issue, please report at https://github.com/DiscordBM/DiscordBM/issues.
      case notSupposedToBeSent(message: String)

      public var description: String {
        switch self {
        case let .notSupposedToBeSent(message):
          return "Gateway.Event.EncodingError.notSupposedToBeSent(\(message))"
        }
      }
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      switch self.opcode {
      case .dispatch, .reconnect, .invalidSession, .heartbeatAccepted, .hello:
        throw EncodingError.notSupposedToBeSent(
          message:
            "`\(self.opcode.rawValue)` opcode is supposed to never be sent."
        )
      default: break
      }
      try container.encode(self.opcode, forKey: .opcode)

      if self.sequenceNumber != nil {
        throw EncodingError.notSupposedToBeSent(
          message:
            "'sequenceNumber' is supposed to never be sent but wasn't nil (\(String(describing: sequenceNumber))."
        )
      }
      if self.type != nil {
        throw EncodingError.notSupposedToBeSent(
          message:
            "'type' is supposed to never be sent but wasn't nil (\(String(describing: type))."
        )
      }

      switch self.data {
      case .none:
        try container.encodeNil(forKey: .data)
      case let .heartbeat(lastSequenceNumber):
        try container.encode(lastSequenceNumber, forKey: .data)
      case let .identify(payload):
        try container.encode(payload, forKey: .data)
      case let .resume(payload):
        try container.encode(payload, forKey: .data)
      case let .requestGuildMembers(payload):
        try container.encode(payload, forKey: .data)
      case let .requestPresenceUpdate(payload):
        try container.encode(payload, forKey: .data)
      case let .requestVoiceStateUpdate(payload):
        try container.encode(payload, forKey: .data)
      default:
        throw EncodingError.notSupposedToBeSent(
          message: "'\(self)' data is supposed to never be sent."
        )
      }
    }
  }

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
	  public var app_arch: String? // set this to os_arch for simplicity (also bc its true)
	  public var system_locale: String?
      public var has_client_mods: String?
      public var client_launch_id: String?
      public var browser_user_agent: String?
	  public var browser_version: String?
	  public var os_sdk_version: String? // first segment of os_version
	  public var client_build_number: String?
	  
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
    }

    /// https://discord.com/developers/docs/topics/gateway-events#update-presence-gateway-presence-update-structure
    public struct Presence: Sendable, Codable {
      public var since: Int?
      public var activities: [Activity]
      public var status: Status
      public var afk: Bool

      // FIXME: remove this init? or make it not be ambiguous compared to the init below,
      // when the init below is changed to `since: Date? = nil`.
      public init(
        since: Int? = nil,
        activities: [Activity],
        status: Status,
        afk: Bool
      ) {
        self.since = since
        self.activities = activities
        self.status = status
        self.afk = afk
      }

      public init(
        since: Date,
        activities: [Activity],
        status: Status,
        afk: Bool
      ) {
        self.since = Int(since.timeIntervalSince1970)
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
    public var guilds: [UnavailableGuild]
    public var session_id: String
    public var resume_gateway_url: String?
    public var shard: IntPair?

    // bot only
    public var application: PartialApplication?

    // user only
    public var user_settings_proto:
      DiscordProtos_DiscordUsers_V1_PreloadedUserSettings?
    //		public var connected_accounts
    //		public var user_guild_settings
    //		public var guild_join_requests
    //		public var broadcaster_user_ids
    //		public var session_type: String? // maybe this can become an unstable enum
    public var users: [PartialUser]?
    //		public var read_state: ReadState?
    //		public var notification_settings
    //		public relationships
    //		public var friend_suggestion_count
    //		public var private_channels
    //		public var guilds
    public var geo_ordered_rtc_regions: [String]?

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
    /// FIXME:
    /// The field is documented but doesn't say what exactly it is.
    /// Discord says: "any user-thread settings, currently only used for notifications".
    /// I think currently it's set to `1` or `0` depending on if you have notifications
    /// enabled for the thread?
    public var flags: Int
    public var guild_id: GuildSnowflake
  }

  /// https://discord.com/developers/docs/topics/gateway-events#thread-members-update-thread-members-update-event-fields
  public struct ThreadMembersUpdate: Sendable, Codable {

    /// A ``ThreadMember`` with some extra fields.
    /// https://discord.com/developers/docs/resources/channel#thread-member-object-thread-member-structure
    /// https://discord.com/developers/docs/topics/gateway-events#thread-members-update-thread-members-update-event-fields
    public struct ThreadMember: Sendable, Codable {

      /// A ``PresenceUpdate`` with nullable `guild_id`.
      /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
      public struct ThreadMemberPresenceUpdate: Sendable, Codable {
        public var user: PartialUser
        public var guild_id: GuildSnowflake?
        public var status: Status
        public var activities: [Activity]
        public var client_status: ClientStatus
      }

      public var id: ChannelSnowflake
      public var user_id: UserSnowflake?
      public var join_timestamp: DiscordTimestamp
      /// FIXME:
      /// The field is documented but doesn't say what exactly it is.
      /// Discord says: "any user-thread settings, currently only used for notifications".
      /// I think currently it's set to `1` or `0` depending on if you have notifications
      /// enabled for the thread?
      public var flags: Int
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
    public var hub_type: String?
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
      self.hub_type = new.hub_type
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
    public var query: String = ""
    public var limit: Int = 0
    public var presences: Bool?
    /// FIXME: change to `UserSnowflake`.
    public var user_ids: [String]?
    public var nonce: String?

    public init(
      guild_id: GuildSnowflake,
      query: String = "",
      limit: Int = 0,
      presences: Bool? = nil,
      /// FIXME: change to `UserSnowflake`.
      user_ids: [String]? = nil,
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
    @_spi(UserInstallableApps) @DecodeOrNil
    public var interaction_metadata: DiscordChannel.Message.InteractionMetadata?
    public var interaction: MessageInteraction?
    public var thread: DiscordChannel?
    public var components: [Interaction.ActionRow]?
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
    /// FIXME: Discord calls this 'burst'. Can't change it to not break API
    case `super`  // 1
    case __undocumented(Int)

    /// The same as ``.super``.
    public static var burst: Self {
      .super
    }
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

  /// https://discord.com/developers/docs/topics/gateway-events#client-status-object
  public struct ClientStatus: Sendable, Codable {
    public var desktop: Status?
    public var mobile: Status?
    public var web: Status?
    public var embedded: Status?
  }

  /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
  public struct PresenceUpdate: Sendable, Codable {
    public var user: PartialUser
    public var guild_id: GuildSnowflake
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
  public struct Activity: Sendable, Codable {

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
    public struct Timestamps: Sendable, Codable {
      public var start: Int?
      public var end: Int?

      public init(start: Int? = nil, end: Int? = nil) {
        self.start = start
        self.end = end
      }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-emoji
    public struct ActivityEmoji: Sendable, Codable {
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
    public struct Party: Sendable, Codable {
      public var id: String?
      public var size: IntPair?

      public init(id: String? = nil, size: IntPair? = nil) {
        self.id = id
        self.size = size
      }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-assets
    public struct Assets: Sendable, Codable {
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
    public struct Secrets: Sendable, Codable {
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
    public struct Button: Sendable, Codable {
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
}

// MARK: + Gateway.Intent
extension Gateway.Intent {
  /// All intents that require no privileges.
  /// https://discord.com/developers/docs/topics/gateway#privileged-intents
  public static var unprivileged: [Gateway.Intent] {
    Gateway.Intent.allCases.filter { !$0.isPrivileged }
  }

  /// https://discord.com/developers/docs/topics/gateway#privileged-intents
  public var isPrivileged: Bool {
    switch self {
    case .guilds: return false
    case .guildMembers: return true
    case .guildModeration: return false
    case .guildEmojisAndStickers: return false
    case .guildIntegrations: return false
    case .guildWebhooks: return false
    case .guildInvites: return false
    case .guildVoiceStates: return false
    case .guildPresences: return true
    case .guildMessages: return false
    case .guildMessageReactions: return false
    case .guildMessageTyping: return false
    case .directMessages: return false
    case .directMessageReactions: return false
    case .directMessageTyping: return false
    case .messageContent: return true
    case .guildScheduledEvents: return false
    case .autoModerationConfiguration: return false
    case .autoModerationExecution: return false
    case .guildMessagePolls: return false
    case .directMessagePolls: return false
    /// Undocumented cases are considered privileged just to be safe than sorry
    case .__undocumented: return true
    }
  }
}

extension DiscordProtos_DiscordUsers_V1_PreloadedUserSettings: Codable {
  public func encode(to encoder: any Encoder) throws {
    let data = try self.serializedData()
    let protoBase64String = data.base64EncodedString()
    var container = encoder.singleValueContainer()
    try container.encode(protoBase64String)
  }

  public init(from decoder: any Decoder) throws {
    let protoBase64String =
      try decoder
      .singleValueContainer()
      .decode(String.self)
    if let data = Data(base64Encoded: protoBase64String) {
      self = try DiscordProtos_DiscordUsers_V1_PreloadedUserSettings(
        serializedBytes: data
      )
    } else {
      self = .init()
      return
    }
  }
}
