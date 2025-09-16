/// https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags
@UnstableEnum<UInt>
public enum Permission: Sendable, Codable {
    case createInstantInvite  // 0
    case kickMembers  // 1
    case banMembers  // 2
    case administrator  // 3
    case manageChannels  // 4
    case manageGuild  // 5
    case addReactions  // 6
    case viewAuditLog  // 7
    case prioritySpeaker  // 8
    case stream  // 9
    case viewChannel  // 10
    case sendMessages  // 11
    case sendTtsMessages  // 12
    case manageMessages  // 13
    case embedLinks  // 14
    case attachFiles  // 15
    case readMessageHistory  // 16
    case mentionEveryone  // 17
    case useExternalEmojis  // 18
    case viewGuildInsights  // 19
    case connect  // 20
    case speak  // 21
    case muteMembers  // 22
    case deafenMembers  // 23
    case moveMembers  // 24
    case useVAD  // 25
    case changeNickname  // 26
    case manageNicknames  // 27
    case manageRoles  // 28
    case manageWebhooks  // 29
    case manageGuildExpressions  // 30
    case useApplicationCommands  // 31
    case requestToSpeak  // 32
    case manageEvents  // 33
    case manageThreads  // 34
    case createPublicThreads  // 35
    case createPrivateThreads  // 36
    case useExternalStickers  // 37
    case sendMessagesInThreads  // 38
    case useEmbeddedActivities  // 39
    case moderateMembers  // 40
    case viewCreatorMonetizationAnalytics  // 41
    case useSoundboard  // 42
    case createGuildExpressions  // 43
    case createEvents  // 44
    case useExternalSounds  // 45
    case sendVoiceMessages  // 46
    case sendPolls  // 49
    case __undocumented(UInt)
}

/// https://discord.com/developers/docs/topics/permissions#role-object
public struct Role: Sendable, Codable {

    /// https://discord.com/developers/docs/topics/permissions#role-object-role-tags-structure
    public struct Tags: Sendable, Codable {
        public var bot_id: UserSnowflake?
        public var integration_id: IntegrationSnowflake?
        public var premium_subscriber: Bool?
        // FXIME: use `Snowflake<Type>` instead
        public var subscription_listing_id: AnySnowflake?
        /// These two fields have a weird null-or-not-present value
        /// which `Decodable` can't easily decode.
        //        public var available_for_purchase: Null
        //        public var guild_connections: Null
    }

    /// https://discord.com/developers/docs/topics/permissions#role-object-role-flags
    @UnstableEnum<UInt>
    public enum Flag: Sendable {
        case inPrompt  // 0
        case __undocumented(UInt)
    }

    public var id: RoleSnowflake
    public var name: String
    public var description: String?
    public var color: DiscordColor
    public var hoist: Bool
    public var icon: String?
    public var unicode_emoji: String?
    public var position: Int
    public var permissions: StringBitField<Permission>
    public var managed: Bool
    public var mentionable: Bool
    public var tags: Tags?
    public var version: Int?
    public var flags: IntBitField<Flag>
}
