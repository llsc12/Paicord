import Foundation

/// https://discord.com/developers/docs/resources/message#channel-object-channel-structure
/// The same as what the Discord API docs call "partial channel".
/// Also the same as a "thread object".
public struct DiscordChannel: Sendable, Codable, Equatable, Hashable {

  /// https://discord.com/developers/docs/resources/message#channel-object-channel-types
  /// https://docs.discord.food/resources/message#channel-type
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum Kind: Sendable, Codable {
    case guildText  // 0
    case dm  // 1
    case guildVoice  // 2
    case groupDm  // 3
    case guildCategory  // 4
    case guildAnnouncement  // 5
    case guildStore  // 6
    case announcementThread  // 10
    case publicThread  // 11
    case privateThread  // 12
    case guildStageVoice  // 13
    case guildDirectory  // 14
    case guildForum  // 15
    case guildMedia  // 16
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/message#overwrite-object
  public struct Overwrite: Sendable, Codable, Equatable, Hashable {

    /// https://discord.com/developers/docs/resources/message#overwrite-object
    #if Non64BitSystemsCompatibility
      @UnstableEnum<Int64>
    #else
      @UnstableEnum<Int>
    #endif
    public enum Kind: Sendable, Codable {
      case role  // 0
      case member  // 1
      #if Non64BitSystemsCompatibility
        case __undocumented(Int64)
      #else
        case __undocumented(Int)
      #endif
    }

    public var id: AnySnowflake
    public var type: Kind
    public var allow: StringBitField<Permission>
    public var deny: StringBitField<Permission>
  }

  /// https://discord.com/developers/docs/resources/message#channel-object-sort-order-types
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum SortOrder: Sendable, Codable {
    case latestActivity  // 0
    case creationDate  // 1
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/message#channel-object-forum-layout-types
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum ForumLayout: Sendable, Codable {
    case notSet  // 0
    case listView  // 1
    case galleryView  // 2
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/message#channel-object-channel-flags
  /// https://docs.discord.food/resources/message#channel-flags
  #if Non64BitSystemsCompatibility
    @UnstableEnum<UInt64>
  #else
    @UnstableEnum<UInt>
  #endif
  public enum Flag: Sendable {
    case guildFeedRemoved  // 0
    case pinned  // 1
    case activeChannelsRemoved  // 2
    case requireTag  // 4
    case spam  // 5
    case isGuildResourceChannel  // 7
    case clydeAI  // 8
    case scheduledForDeletion  // 9
    case summariesDisabled  // 11
    case isRoleSubscriptionTemplatePreviewChannel  // 13
    case isBroadcasting  // 14
    case hideMediaDownloadOptions  // 15
    case isJoinRequestInterviewChannel  // 16
    case obfuscated  // 17
    case isModeratorReportChannel  // 19

    #if Non64BitSystemsCompatibility
      case __undocumented(UInt64)
    #else
      case __undocumented(UInt)
    #endif
  }

  /// https://discord.com/developers/docs/resources/message#channel-object-video-quality-modes
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum VideoQualityMode: Sendable, Codable, Equatable {
    case auto  // 1
    case full  // 2
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// Not exactly documented, but they do mention these times in a few different places.
  /// Times are in minutes.
  /// https://discord.com/developers/docs/resources/message#channel-object-channel-structure
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum AutoArchiveDuration: Sendable, Codable {
    case oneHour  // 60
    case oneDay  // 1_440
    case threeDays  // 4_320
    case sevenDays  // 10_080
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/message#default-reaction-object-default-reaction-structure
  public struct DefaultReaction: Sendable, Codable, Equatable, Hashable {
    public var emoji_id: EmojiSnowflake?
    public var emoji_name: String?

    public init(emoji_id: EmojiSnowflake? = nil) {
      self.emoji_id = emoji_id
      self.emoji_name = nil
    }

    public init(emoji_name: String? = nil) {
      self.emoji_id = nil
      self.emoji_name = emoji_name
    }
  }

  /// https://discord.com/developers/docs/resources/message#forum-tag-object-forum-tag-structure
  public struct ForumTag: Sendable, Codable, Equatable, Hashable {
    public var id: ForumTagSnowflake
    public var name: String
    public var moderated: Bool
    public var emoji_id: EmojiSnowflake?
    public var emoji_name: String?
  }

  public var id: ChannelSnowflake
  /// Type is optional because there are some endpoints that return
  /// partial channel objects, and very few of them exclude the `type`.
  public var type: Kind?
  public var guild_id: GuildSnowflake?
  public var position: Int?
  public var permission_overwrites: [Overwrite]?
  public var name: String?
  public var topic: String?
  public var nsfw: Bool?
  public var last_message_id: MessageSnowflake?
  public var bitrate: Int?
  public var user_limit: Int?
  public var rate_limit_per_user: Int?
  public var recipients: [DiscordUser]?
  public var icon: String?
  public var owner_id: UserSnowflake?
  public var application_id: ApplicationSnowflake?
  public var manage: Bool?
  public var parent_id: AnySnowflake?
  public var last_pin_timestamp: DiscordTimestamp?
  public var rtc_region: String?
  public var video_quality_mode: VideoQualityMode?
  public var message_count: Int?
  public var total_message_sent: Int?
  public var member_count: Int?
  public var thread_metadata: ThreadMetadata?
  public var default_auto_archive_duration: AutoArchiveDuration?
  public var default_thread_rate_limit_per_user: Int?
  public var default_reaction_emoji: DefaultReaction?
  public var default_sort_order: Int?
  public var default_forum_layout: ForumLayout?
  public var permissions: StringBitField<Permission>?
  public var flags: IntBitField<Flag>?
  public var available_tags: [ForumTag]?
  public var template: String?
  public var member_ids_preview: [String]?
  public var version: Int?
  /// Thread-only:
  public var member: ThreadMember?
  public var newly_created: Bool?
  /// Only populated by thread-related Gateway events.
  public var threadMembers: [Gateway.ThreadMembersUpdate.ThreadMember]?
}

extension DiscordChannel {
  /// https://discord.com/developers/docs/resources/message#message-object
  public struct Message: Sendable, Codable, Equatable, Hashable {

    public init(
      id: MessageSnowflake,
      channel_id: ChannelSnowflake,
      author: DiscordUser? = nil,
      content: String,
      timestamp: DiscordTimestamp,
      edited_timestamp: DiscordTimestamp? = nil,
      tts: Bool,
      mention_everyone: Bool,
      mentions: [MentionUser],
      mention_roles: [RoleSnowflake],
      mention_channels: [ChannelMention]? = nil,
      attachments: [Attachment],
      embeds: [Embed],
      reactions: [Reaction]? = nil,
      nonce: StringOrInt? = nil,
      pinned: Bool,
      webhook_id: WebhookSnowflake? = nil,
      type: Kind,
      activity: Activity? = nil,
      application: PartialApplication? = nil,
      application_id: ApplicationSnowflake? = nil,
      message_reference: MessageReference? = nil,
      message_snapshots: [MessageSnapshot]? = nil,
      flags: IntBitField<Flag>? = nil,
      referenced_message: DereferenceBox<Message>? = nil,
      interaction: MessageInteraction? = nil,
      thread: DiscordChannel? = nil,
      components: Interaction.ComponentSwitch? = nil,
      sticker_items: [StickerItem]? = nil,
      stickers: [Sticker]? = nil,
      position: Int? = nil,
      role_subscription_data: RoleSubscriptionData? = nil,
      resolved: Interaction.ApplicationCommand.ResolvedData? = nil,
      poll: Poll? = nil,
      call: Call? = nil,
      guild_id: GuildSnowflake? = nil,
      member: Guild.PartialMember? = nil
    ) {
      self.id = id
      self.channel_id = channel_id
      self.author = author
      self.content = content
      self.timestamp = timestamp
      self.edited_timestamp = edited_timestamp
      self.tts = tts
      self.mention_everyone = mention_everyone
      self.mentions = mentions
      self.mention_roles = mention_roles
      self.mention_channels = mention_channels
      self.attachments = attachments
      self.embeds = embeds
      self.reactions = reactions
      self.nonce = nonce
      self.pinned = pinned
      self.webhook_id = webhook_id
      self.type = type
      self.activity = activity
      self.application = application
      self.application_id = application_id
      self.message_reference = message_reference
      self.message_snapshots = message_snapshots
      self.flags = flags
      self.referenced_message = referenced_message
      //			self.interaction_metadata = interaction_metadata
      self.interaction = interaction
      self.thread = thread
      self.components = components
      self.sticker_items = sticker_items
      self.stickers = stickers
      self.position = position
      self.role_subscription_data = role_subscription_data
      self.resolved = resolved
      self.poll = poll
      self.call = call
      self.guild_id = guild_id
      self.member = member
    }

    /// https://discord.com/developers/docs/resources/message#message-reference-object-message-reference-structure
    public struct MessageReference: Sendable, Codable, Equatable, Hashable {
      #if Non64BitSystemsCompatibility
        @UnstableEnum<Int64>
      #else
        @UnstableEnum<Int>
      #endif
      public enum Kind: Sendable, Codable {
        case reply  // 0
        case forward  // 1
        #if Non64BitSystemsCompatibility
          case __undocumented(Int64)
        #else
          case __undocumented(Int)
        #endif
      }

      public var type: Kind
      public var message_id: MessageSnowflake?
      public var channel_id: ChannelSnowflake?
      public var guild_id: GuildSnowflake?
      public var fail_if_not_exists: Bool?

      public init(
        type: Kind,
        message_id: MessageSnowflake? = nil,
        channel_id: ChannelSnowflake? = nil,
        guild_id: GuildSnowflake? = nil,
        fail_if_not_exists: Bool? = nil
      ) {
        self.type = type
        self.message_id = message_id
        self.channel_id = channel_id
        self.guild_id = guild_id
        self.fail_if_not_exists = fail_if_not_exists
      }
    }

    /// https://discord.com/developers/docs/resources/message#message-object-message-types
    /// https://docs.discord.food/resources/message#message-type
    #if Non64BitSystemsCompatibility
      @UnstableEnum<Int64>
    #else
      @UnstableEnum<Int>
    #endif
    public enum Kind: Sendable, Codable {
      case `default`  // 0
      case recipientAdd  // 1
      case recipientRemove  // 2
      case call  // 3
      case channelNameChange  // 4
      case channelIconChange  // 5
      case channelPinnedMessage  // 6
      case guildMemberJoin  // 7
      case userPremiumGuildSubscription  // 8
      case userPremiumGuildSubscriptionTier1  // 9
      case userPremiumGuildSubscriptionTier2  // 10
      case userPremiumGuildSubscriptionTier3  // 11
      case channelFollowAdd  // 12
      case guildDiscoveryDisqualified  // 14
      case guildDiscoveryRequalified  // 15
      case guildDiscoveryGracePeriodInitialWarning  // 16
      case guildDiscoveryGracePeriodFinalWarning  // 17
      case threadCreated  // 18
      case reply  // 19
      case chatInputCommand  // 20
      case threadStarterMessage  // 21
      case guildInviteReminder  // 22
      case contextMenuCommand  // 23
      case autoModerationAction  // 24
      case roleSubscriptionPurchase  // 25
      case interactionPremiumUpsell  // 26
      case stageStart  // 27
      case stageEnd  // 28
      case stageSpeaker  // 29
      case stageRaiseHand  // 30
      case stageTopic  // 31
      case guildApplicationPremiumSubscription  // 32
      case premiumReferral  // 35
      case guildIncidentAlertModeEnabled  // 36
      case guildIncidentAlertModeDisabled  // 37
      case guildIncidentReportRaid  // 38
      case guildIncidentReportFalseAlarm  // 39
      case guildDeadchatRevivePrompt  // 40
      case customGift  // 41
      case guildGamingStatsPrompt  // 42
      case purchaseNotification  // 44
      case pollResult  // 46
      case changelog  // 47
      case nitroNotification  // 48
      case channelLinkedToLobby  // 49
      case giftingPrompt  // 50
      case inGameMessageNux  // 51
      case guildJoinRequestAcceptNotification  // 52
      case guildJoinRequestRejectNotification  // 53
      case guildJoinRequestWithdrawnNotification  // 54
      case hdStreamingUpgraded  // 55
      case reportToModDeletedMessage  // 58
      case reportToModTimeoutUser  // 59
      case reportToModKickUser  // 60
      case reportToModBanUser  // 61
      case reportToModClosedReport  // 62
      case emojiAdded  // 63
      #if Non64BitSystemsCompatibility
        case __undocumented(Int64)
      #else
        case __undocumented(Int)
      #endif
    }

    /// https://discord.com/developers/docs/resources/message#message-object-message-flags
    #if Non64BitSystemsCompatibility
      @UnstableEnum<UInt64>
    #else
      @UnstableEnum<UInt>
    #endif
    public enum Flag: Sendable {
      case crossposted  // 0
      case isCrosspost  // 1
      case suppressEmbeds  // 2
      case sourceMessageDeleted  // 3
      case urgent  // 4
      case hasThread  // 5
      case ephemeral  // 6
      case loading  // 7
      case failedToMentionSomeRolesInThread  // 8
      case suppressNotifications  // 12
      case isVoiceMessage  // 13
      case hasSnapshot  // 14
      case isComponentsV2  // 15

      #if Non64BitSystemsCompatibility
        case __undocumented(UInt64)
      #else
        case __undocumented(UInt)
      #endif
    }

    /// https://discord.com/developers/docs/resources/message#channel-mention-object
    public struct ChannelMention: Sendable, Codable, Equatable, Hashable {
      public var id: ChannelSnowflake
      public var guild_id: GuildSnowflake
      public var type: DiscordChannel.Kind
      public var name: String
    }

    /// https://discord.com/developers/docs/resources/message#attachment-object
    public struct Attachment: Sendable, Codable, Identifiable, Equatable,
      Hashable
    {

      public init(
        id: AttachmentSnowflake,
        filename: String,
        title: String? = nil,
        description: String? = nil,
        content_type: String? = nil,
        size: Int,
        url: String,
        proxy_url: String,
        placeholder: String? = nil,
        height: Int? = nil,
        width: Int? = nil,
        ephemeral: Bool? = nil,
        duration_secs: Double? = nil,
        waveform: String? = nil,
        flags: IntBitField<Flag>? = nil
      ) {
        self.id = id
        self.filename = filename
        self.title = title
        self.description = description
        self.content_type = content_type
        self.size = size
        self.url = url
        self.proxy_url = proxy_url
        self.placeholder = placeholder
        self.height = height
        self.width = width
        self.ephemeral = ephemeral
        self.duration_secs = duration_secs
        self.waveform = waveform
        self.flags = flags
      }

      /// https://discord.com/developers/docs/resources/message#attachment-object-attachment-flags
      #if Non64BitSystemsCompatibility
        @UnstableEnum<UInt64>
      #else
        @UnstableEnum<UInt>
      #endif
      public enum Flag: Sendable {
        case isRemix  // 2

        #if Non64BitSystemsCompatibility
          case __undocumented(UInt64)
        #else
          case __undocumented(UInt)
        #endif
      }

      public var id: AttachmentSnowflake
      public var filename: String
      public var title: String?
      public var description: String?
      public var content_type: String?
      public var size: Int
      public var url: String
      public var proxy_url: String
      public var placeholder: String?
      public var height: Int?
      public var width: Int?
      public var ephemeral: Bool?
      public var duration_secs: Double?
      public var waveform: String?
      public var flags: IntBitField<Flag>?
    }

    /// https://discord.com/developers/docs/resources/message#reaction-object
    public struct Reaction: Sendable, Codable, Equatable, Hashable {

      /// https://discord.com/developers/docs/resources/message#reaction-object-reaction-count-details-structure
      public struct CountDetails: Sendable, Codable, Equatable, Hashable {
        public var burst: Int
        public var normal: Int

        public init(burst: Int, normal: Int) {
          self.burst = burst
          self.normal = normal
        }
      }

      public var count: Int
      public var count_details: CountDetails
      public var me: Bool
      public var me_burst: Bool
      public var emoji: Emoji
      public var burst_colors: [DiscordColor]?

      enum CodingKeys: String, CodingKey {
        case count
        case count_details
        case me
        case me_burst
        case emoji
        case burst_colors
      }

      @available(
        *,
        deprecated,
        renamed: "init(count:count_details:me:me_burst:emoji:burst_colors:)"
      )
      public init(count: Int, me: Bool, emoji: Emoji) {
        self.count = count
        self.count_details = .init(burst: 0, normal: 0)
        self.me = me
        self.me_burst = false
        self.emoji = emoji
        self.burst_colors = []
      }

      public init(
        count: Int,
        count_details: CountDetails,
        me: Bool,
        me_burst: Bool,
        emoji: Emoji,
        burst_colors: [DiscordColor]
      ) {
        self.count = count
        self.count_details = count_details
        self.me = me
        self.me_burst = me_burst
        self.emoji = emoji
        self.burst_colors = burst_colors
      }

      public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try container.decode(Int.self, forKey: .count)
        self.count_details = try container.decode(
          CountDetails.self,
          forKey: .count_details
        )
        self.me = try container.decode(Bool.self, forKey: .me)
        self.me_burst = try container.decode(Bool.self, forKey: .me_burst)
        self.emoji = try container.decode(Emoji.self, forKey: .emoji)
        self.burst_colors = try container.decodeIfPresent(
          [String].self,
          forKey: .burst_colors
        )?.compactMap {
          DiscordColor(hex: $0)
        }
      }

      public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.count, forKey: .count)
        try container.encode(self.count_details, forKey: .count_details)
        try container.encode(self.me, forKey: .me)
        try container.encode(self.me_burst, forKey: .me_burst)
        try container.encode(self.emoji, forKey: .emoji)
        try container.encode(
          self.burst_colors?.map { $0.asHex() },
          forKey: .burst_colors
        )
      }
    }

    /// https://discord.com/developers/docs/resources/message#message-object-message-activity-structure
    public struct Activity: Sendable, Codable, Equatable, Hashable {

      /// https://discord.com/developers/docs/resources/message#message-object-message-activity-types
      #if Non64BitSystemsCompatibility
        @UnstableEnum<Int64>
      #else
        @UnstableEnum<Int>
      #endif
      public enum Kind: Sendable, Codable {
        case join  // 1
        case spectate  // 2
        case listen  // 3
        case joinRequest  // 5
        #if Non64BitSystemsCompatibility
          case __undocumented(Int64)
        #else
          case __undocumented(Int)
        #endif
      }

      public var type: Kind
      /// Not a Snowflake. Example: `spotify:715622804258684938`.
      public var party_id: String?
    }

    /// https://discord.com/developers/docs/resources/message#message-interaction-metadata-object-application-command-interaction-metadata-structure
    public struct InteractionMetadata: Sendable, Codable, Equatable, Hashable {
      public var id: InteractionSnowflake
      public var type: Interaction.Kind
      public var user: DiscordUser
      public var authorizing_integration_owners: [DiscordApplication.IntegrationKind: AnySnowflake]
      public var original_response_message_id: MessageSnowflake?
      public var target_user: DiscordUser?
      public var target_message_id: MessageSnowflake?
    }

    public struct Call: Sendable, Codable, Equatable, Hashable {
      public var participants: [UserSnowflake]
      public var ended_timestamp: DiscordTimestamp?
    }

    public var id: MessageSnowflake
    public var channel_id: ChannelSnowflake
    public var author: DiscordUser?
    public var content: String
    public var timestamp: DiscordTimestamp
    public var edited_timestamp: DiscordTimestamp?
    public var tts: Bool
    public var mention_everyone: Bool
    public var mentions: [MentionUser]
    public var mention_roles: [RoleSnowflake]
    public var mention_channels: [ChannelMention]?
    public var attachments: [Attachment]
    public var embeds: [Embed]
    public var reactions: [Reaction]?
    public var nonce: StringOrInt?
    public var pinned: Bool
    public var webhook_id: WebhookSnowflake?
    public var type: Kind
    public var activity: Activity?
    public var application: PartialApplication?
    public var application_id: ApplicationSnowflake?
    public var message_reference: MessageReference?
    public var message_snapshots: [MessageSnapshot]?
    public var flags: IntBitField<Flag>?
    public var referenced_message: DereferenceBox<Message>?
    public var interaction_metadata: InteractionMetadata?
    public var interaction: MessageInteraction?
    public var thread: DiscordChannel?
    public var components: Interaction.ComponentSwitch?
    public var sticker_items: [StickerItem]?
    public var stickers: [Sticker]?
    public var position: Int?
    public var role_subscription_data: RoleSubscriptionData?
    public var resolved: Interaction.ApplicationCommand.ResolvedData?
    public var poll: Poll?
    public var call: Call?
    /// Extra fields, not sure why I've added them to this specific type:
    public var guild_id: GuildSnowflake?
    public var member: Guild.PartialMember?
  }

  public struct MessageSnapshot: Sendable, Codable, Equatable, Hashable {
    public var message: SnapshotMessage

    public struct SnapshotMessage: Sendable, Codable, Equatable, Hashable {
      public var content: String
      public var timestamp: DiscordTimestamp
      public var edited_timestamp: DiscordTimestamp?
      public var mentions: [MentionUser]
      public var mention_roles: [RoleSnowflake]?
      public var attachments: [DiscordChannel.Message.Attachment]
      public var embeds: [Embed]
      public var type: DiscordChannel.Message.Kind
      public var flags: IntBitField<DiscordChannel.Message.Flag>?
      public var components: Interaction.ComponentSwitch?
      public var resolved: Interaction.ApplicationCommand.ResolvedData?
      public var sticker_items: [StickerItem]?
      public var soundboard_sounds: [SoundboardSound]?
    }
  }
}

extension DiscordChannel {
  /// Partial ``DiscordChannel.Message`` object.
  public struct PartialMessage: Sendable, Codable, Equatable, Hashable {

    public init(
      id: MessageSnowflake,
      channel_id: ChannelSnowflake,
      author: DiscordUser? = nil,
      content: String? = nil,
      timestamp: DiscordTimestamp? = nil,
      edited_timestamp: DiscordTimestamp? = nil,
      tts: Bool? = nil,
      mention_everyone: Bool? = nil,
      mentions: [MentionUser]? = nil,
      mention_roles: [RoleSnowflake]? = nil,
      mention_channels: [DiscordChannel.Message.ChannelMention]? = nil,
      attachments: [DiscordChannel.Message.Attachment]? = nil,
      embeds: [Embed]? = nil,
      reactions: [DiscordChannel.Message.Reaction]? = nil,
      nonce: StringOrInt? = nil,
      pinned: Bool? = nil,
      webhook_id: WebhookSnowflake? = nil,
      type: DiscordChannel.Message.Kind? = nil,
      activity: DiscordChannel.Message.Activity? = nil,
      application: PartialApplication? = nil,
      application_id: ApplicationSnowflake? = nil,
      message_reference: DiscordChannel.Message.MessageReference? = nil,
      flags: IntBitField<DiscordChannel.Message.Flag>? = nil,
      referenced_message: DereferenceBox<PartialMessage>? = nil,
      message_snapshots: [DiscordChannel.MessageSnapshot]? = nil,
      interaction: MessageInteraction? = nil,
      thread: DiscordChannel? = nil,
      components: Interaction.ComponentSwitch? = nil,
      sticker_items: [StickerItem]? = nil,
      stickers: [Sticker]? = nil,
      position: Int? = nil,
      role_subscription_data: RoleSubscriptionData? = nil,
      resolved: Interaction.ApplicationCommand.ResolvedData? = nil,
      poll: Poll? = nil,
      call: DiscordChannel.Message.Call? = nil,
      member: Guild.PartialMember? = nil,
      guild_id: GuildSnowflake? = nil
    ) {
      self.id = id
      self.channel_id = channel_id
      self.author = author
      self.content = content
      self.timestamp = timestamp
      self.edited_timestamp = edited_timestamp
      self.tts = tts
      self.mention_everyone = mention_everyone
      self.mentions = mentions
      self.mention_roles = mention_roles
      self.mention_channels = mention_channels
      self.attachments = attachments
      self.embeds = embeds
      self.reactions = reactions
      self.nonce = nonce
      self.pinned = pinned
      self.webhook_id = webhook_id
      self.type = type
      self.activity = activity
      self.application = application
      self.application_id = application_id
      self.message_reference = message_reference
      self.flags = flags
      self.referenced_message = referenced_message
      self.message_snapshots = message_snapshots
      self.interaction = interaction
      self.thread = thread
      self.components = components
      self.sticker_items = sticker_items
      self.stickers = stickers
      self.position = position
      self.role_subscription_data = role_subscription_data
      self.resolved = resolved
      self.poll = poll
      self.call = call
      self.member = member
      self.guild_id = guild_id
    }

    public var id: MessageSnowflake
    public var channel_id: ChannelSnowflake
    public var author: DiscordUser?
    public var content: String?
    public var timestamp: DiscordTimestamp?
    public var edited_timestamp: DiscordTimestamp?
    public var tts: Bool?
    public var mention_everyone: Bool?
    public var mentions: [MentionUser]?
    public var mention_roles: [RoleSnowflake]?
    public var mention_channels: [DiscordChannel.Message.ChannelMention]?
    public var attachments: [DiscordChannel.Message.Attachment]?
    public var embeds: [Embed]?
    public var reactions: [DiscordChannel.Message.Reaction]?
    public var nonce: StringOrInt?
    public var pinned: Bool?
    public var webhook_id: WebhookSnowflake?
    public var type: DiscordChannel.Message.Kind?
    public var activity: DiscordChannel.Message.Activity?
    public var application: PartialApplication?
    public var application_id: ApplicationSnowflake?
    public var message_reference: DiscordChannel.Message.MessageReference?
    public var flags: IntBitField<DiscordChannel.Message.Flag>?
    public var referenced_message: DereferenceBox<PartialMessage>?
    public var message_snapshots: [DiscordChannel.MessageSnapshot]?
    public var interaction_metadata: DiscordChannel.Message.InteractionMetadata?
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
    public var member: Guild.PartialMember?
    public var guild_id: GuildSnowflake?
  }
}

/// https://discord.com/developers/docs/resources/message#thread-metadata-object-thread-metadata-structure
public struct ThreadMetadata: Sendable, Codable, Equatable, Hashable {
  public var archived: Bool
  public var auto_archive_duration: DiscordChannel.AutoArchiveDuration
  public var archive_timestamp: DiscordTimestamp
  public var locked: Bool
  public var invitable: Bool?
  public var create_timestamp: DiscordTimestamp?
}

/// https://discord.com/developers/docs/resources/message#thread-member-object-thread-member-structure
public struct ThreadMember: Sendable, Codable, Equatable, Hashable {
  public var id: ChannelSnowflake?
  public var user_id: UserSnowflake?
  public var join_timestamp: DiscordTimestamp
  public var flags: IntBitField<Flag>

  public init(threadMemberUpdate: Gateway.ThreadMemberUpdate) {
    self.id = threadMemberUpdate.id
    self.user_id = threadMemberUpdate.user_id
    self.join_timestamp = threadMemberUpdate.join_timestamp
    self.flags = threadMemberUpdate.flags
  }

  /// https://docs.discord.food/resources/message#thread-member-flags
  #if Non64BitSystemsCompatibility
    @UnstableEnum<UInt64>
  #else
    @UnstableEnum<UInt>
  #endif
  public enum Flag: Sendable {
    case hasInteracted  // 0
    case allMessages  // 1
    case onlyMentions  // 2
    case noMessages  // 3

    #if Non64BitSystemsCompatibility
      case __undocumented(UInt64)
    #else
      case __undocumented(UInt)
    #endif
  }
}

/// For a limited amount of endpoints which return the `member` object too.
/// https://discord.com/developers/docs/resources/message#thread-member-object-thread-member-structure
public struct ThreadMemberWithMember: Sendable, Codable {
  public var id: ChannelSnowflake?
  public var user_id: UserSnowflake?
  public var join_timestamp: DiscordTimestamp
  public var flags: IntBitField<ThreadMember.Flag>
  public var member: Guild.Member
}

/// Thread-related subset of `DiscordChannel.Kind`
/// https://discord.com/developers/docs/resources/message#channel-object-channel-types
#if Non64BitSystemsCompatibility
  @UnstableEnum<Int64>
#else
  @UnstableEnum<Int>
#endif
public enum ThreadKind: Sendable, Codable {
  case announcementThread  // 10
  case publicThread  // 11
  case privateThread  // 12
  #if Non64BitSystemsCompatibility
    case __undocumented(Int64)
  #else
    case __undocumented(Int)
  #endif
}

extension DiscordChannel {
  /// https://discord.com/developers/docs/resources/message#allowed-mentions-object
  public struct AllowedMentions: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/message#allowed-mentions-object-allowed-mention-types
    @UnstableEnum<String>
    public enum Kind: Sendable, Codable {
      case roles
      case users
      case everyone
      case __undocumented(String)
    }

    public var parse: [Kind]
    public var roles: [RoleSnowflake]
    public var users: [UserSnowflake]
    public var replied_user: Bool
  }
}

/// https://discord.com/developers/docs/resources/message#embed-object
public struct Embed: Sendable, Codable, Equatable, Hashable, ValidatablePayload {

  /// https://discord.com/developers/docs/resources/message#embed-object-embed-types
  @UnstableEnum<String>
  public enum Kind: Sendable, Codable {
    case rich  // "rich"
    case image  // "image"
    case video  // "video"
    case gifv  // "gifv"
    case article  // "article"
    case link  // "link"
    case pollResult  // "poll_result"
    case autoModerationMessage  // "auto_moderation_message"
    case __undocumented(String)
  }

  public enum DynamicURL: Sendable, Codable, ExpressibleByStringLiteral,
    Equatable, Hashable
  {
    public typealias StringLiteralType = String

    case exact(String)
    case attachment(name: String)

    public var asString: String {
      switch self {
      case .exact(let exact):
        return exact
      case .attachment(let name):
        return "attachment://\(name)"
      }
    }

    public init(stringLiteral string: String) {
      if string.hasPrefix("attachment://") {
        self = .attachment(name: String(string.dropFirst(13)))
      } else {
        self = .exact(string)
      }
    }

    public init(from string: String) {
      if string.hasPrefix("attachment://") {
        self = .attachment(name: String(string.dropFirst(13)))
      } else {
        self = .exact(string)
      }
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)
      self = .init(from: string)
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(self.asString)
    }
  }

  /// https://discord.com/developers/docs/resources/message#embed-object-embed-footer-structure
  public struct Footer: Sendable, Codable, Equatable, Hashable {
    public var text: String
    public var icon_url: DynamicURL?
    public var proxy_icon_url: String?

    public init(
      text: String,
      icon_url: DynamicURL? = nil,
      proxy_icon_url: String? = nil
    ) {
      self.text = text
      self.icon_url = icon_url
      self.proxy_icon_url = proxy_icon_url
    }
  }

  /// https://discord.com/developers/docs/resources/message#embed-object-embed-image-structure
  public struct Media: Sendable, Codable, Equatable, Hashable {
    public var url: DynamicURL
    public var proxy_url: String?
    public var height: Int?
    public var width: Int?
    public var placeholder: String?
    public var content_type: String?

    public init(
      url: DynamicURL,
      proxy_url: String? = nil,
      height: Int? = nil,
      width: Int? = nil
    ) {
      self.url = url
      self.proxy_url = proxy_url
      self.height = height
      self.width = width
    }
  }

  /// https://discord.com/developers/docs/resources/message#embed-object-embed-provider-structure
  public struct Provider: Sendable, Codable, Equatable, Hashable {
    public var name: String?
    public var url: String?

    public init(name: String? = nil, url: String? = nil) {
      self.name = name
      self.url = url
    }
  }

  /// https://discord.com/developers/docs/resources/message#embed-object-embed-author-structure
  public struct Author: Sendable, Codable, Equatable, Hashable {
    public var name: String
    public var url: String?
    public var icon_url: DynamicURL?
    public var proxy_icon_url: String?

    public init(
      name: String,
      url: String? = nil,
      icon_url: DynamicURL? = nil,
      proxy_icon_url: String? = nil
    ) {
      self.name = name
      self.url = url
      self.icon_url = icon_url
      self.proxy_icon_url = proxy_icon_url
    }
  }

  /// https://discord.com/developers/docs/resources/message#embed-object-embed-field-structure
  public struct Field: Sendable, Codable, Equatable, Hashable, Identifiable {
    public let id: UUID = UUID()

    public var name: String
    public var value: String
    public var inline: Bool?

    private enum CodingKeys: String, CodingKey {
      case id
      case name
      case value
      case inline
    }

    public init(name: String, value: String, inline: Bool? = nil) {
      self.name = name
      self.value = value
      self.inline = inline
    }
  }

  public var title: String?
  public var type: Kind?
  public var description: String?
  public var url: String?
  public var timestamp: DiscordTimestamp?
  public var color: DiscordColor?
  public var footer: Footer?
  public var image: Media?
  public var thumbnail: Media?
  public var video: Media?
  public var provider: Provider?
  public var author: Author?
  public var fields: [Field]?

  /// The length that matters towards the Discord limit (currently 6000 across all embeds).
  public var contentLength: Int {
    let fields =
      fields?.reduce(into: 0) {
        $0 += $1.name.unicodeScalars.count + $1.value.unicodeScalars.count
      } ?? 0
    return (title?.unicodeScalars.count ?? 0)
      + (description?.unicodeScalars.count ?? 0) + fields
      + (footer?.text.unicodeScalars.count ?? 0)
      + (author?.name.unicodeScalars.count ?? 0)
  }

  public init(
    title: String? = nil,
    type: Embed.Kind? = nil,
    description: String? = nil,
    url: String? = nil,
    timestamp: Date? = nil,
    color: DiscordColor? = nil,
    footer: Embed.Footer? = nil,
    image: Embed.Media? = nil,
    thumbnail: Embed.Media? = nil,
    video: Embed.Media? = nil,
    provider: Embed.Provider? = nil,
    author: Embed.Author? = nil,
    fields: [Embed.Field]? = nil
  ) {
    self.title = title
    self.type = type
    self.description = description
    self.url = url
    self.timestamp = timestamp.map { DiscordTimestamp(date: $0) }
    self.color = color
    self.footer = footer
    self.image = image
    self.thumbnail = thumbnail
    self.video = video
    self.provider = provider
    self.author = author
    self.fields = fields
  }

  public func validate() -> [ValidationFailure] {
    validateElementCountDoesNotExceed(fields, max: 25, name: "fields")
    validateCharacterCountDoesNotExceed(title, max: 256, name: "title")
    validateCharacterCountDoesNotExceed(
      description,
      max: 4_096,
      name: "description"
    )
    validateCharacterCountDoesNotExceed(
      footer?.text,
      max: 2_048,
      name: "footer.text"
    )
    validateCharacterCountDoesNotExceed(
      author?.name,
      max: 256,
      name: "author.name"
    )
    for field in fields ?? [] {
      validateCharacterCountDoesNotExceed(
        field.name,
        max: 256,
        name: "field.name"
      )
      validateCharacterCountDoesNotExceed(
        field.value,
        max: 1_024,
        name: "field.value"
      )
    }
  }
}

/// https://discord.com/developers/docs/resources/message#role-subscription-data-object-role-subscription-data-object-structure
public struct RoleSubscriptionData: Sendable, Codable, Equatable, Hashable {
  // FIXME: use `Snowflake<Type>` instead
  public var role_subscription_listing_id: AnySnowflake
  public var tier_name: String
  public var total_months_subscribed: Int
  public var is_renewal: Bool
}

// MARK: + DiscordChannel.Message.Kind
extension DiscordChannel.Message.Kind {
  /// https://docs.discord.food/resources/message#message-type
  public var isDeletable: Bool {
    switch self {
    case .`default`, .channelPinnedMessage, .guildMemberJoin,
      .userPremiumGuildSubscription,
      .userPremiumGuildSubscriptionTier1, .userPremiumGuildSubscriptionTier2,
      .userPremiumGuildSubscriptionTier3,
      .channelFollowAdd, .threadCreated, .reply, .chatInputCommand,
      .guildInviteReminder, .contextMenuCommand,
      .autoModerationAction, .roleSubscriptionPurchase,
      .interactionPremiumUpsell, .stageStart, .stageEnd,
      .stageSpeaker, .stageTopic, .guildDiscoveryDisqualified,
      .guildDiscoveryRequalified, .guildDiscoveryGracePeriodInitialWarning,
      .guildDiscoveryGracePeriodFinalWarning, .stageRaiseHand, .premiumReferral,
      .guildIncidentAlertModeEnabled, .guildIncidentAlertModeDisabled,
      .guildIncidentReportRaid, .guildIncidentReportFalseAlarm,
      .guildDeadchatRevivePrompt, .customGift, .guildGamingStatsPrompt,
      .purchaseNotification, .pollResult, .changelog, .nitroNotification,
      .channelLinkedToLobby, .giftingPrompt, .inGameMessageNux,
      .guildJoinRequestAcceptNotification, .guildJoinRequestRejectNotification,
      .guildJoinRequestWithdrawnNotification, .hdStreamingUpgraded,
      .reportToModDeletedMessage, .reportToModTimeoutUser, .reportToModKickUser,
      .reportToModBanUser, .reportToModClosedReport, .emojiAdded:
      return true
    case .recipientAdd, .recipientRemove, .call, .channelNameChange,
      .channelIconChange, .threadStarterMessage,
      .guildApplicationPremiumSubscription:
      return false
    case .__undocumented:
      return false
    }
  }
}

/// https://docs.discord.food/resources/message#conversation-summary-object
public struct ConversationSummary: Sendable, Codable {
  // FIXME: use `Snowflake<Type>` instead
  public var id: AnySnowflake
  public var topic: String
  public var summ_short: String
  public var message_ids: [MessageSnowflake]
  public var people: [UserSnowflake]
  public var unsafe: Bool
  public var start_id: MessageSnowflake
  public var end_id: MessageSnowflake
  public var count: Int
  public var source: Source
  public var type: Kind

  #if Non64BitSystemsCompatibility
    @UnstableEnum<UInt64>
  #else
    @UnstableEnum<UInt>
  #endif
  public enum Source: Sendable, Codable {
    case source0  // 0
    case source1  // 1
    case source2  // 2

    #if Non64BitSystemsCompatibility
      case __undocumented(UInt64)
    #else
      case __undocumented(UInt)
    #endif
  }

  #if Non64BitSystemsCompatibility
    @UnstableEnum<UInt64>
  #else
    @UnstableEnum<UInt>
  #endif
  public enum Kind: Sendable, Codable {
    case unset  // 0
    case source1  // 1
    case source2  // 2
    case unknown  // 3

    #if Non64BitSystemsCompatibility
      case __undocumented(UInt64)
    #else
      case __undocumented(UInt)
    #endif
  }
}
