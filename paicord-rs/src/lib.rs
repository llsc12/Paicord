use crate::ffi::{DiscordLocaleRust, PremiumKindRust};

pub mod discord_gateway;
pub mod discord_http;
pub mod discord_models;
pub mod markdown;

// Stupid limitation of swift_bridge at the moment is that using them across multiple files isn't feasible, unless used for pure fntions
// So for now we have to put everything in this one module
#[swift_bridge::bridge]
pub(crate) mod ffi {
    enum DiscordMessageKindRust {
        Default,                                 // 0
        RecipientAdd,                            // 1
        RecipientRemove,                         // 2
        Call,                                    // 3
        ChannelNameChange,                       // 4
        ChannelIconChange,                       // 5
        ChannelPinnedMessage,                    // 6
        GuildMemberJoin,                         // 7
        UserPremiumGuildSubscription,            // 8
        UserPremiumGuildSubscriptionTier1,       // 9
        UserPremiumGuildSubscriptionTier2,       // 10
        UserPremiumGuildSubscriptionTier3,       // 11
        ChannelFollowAdd,                        // 12
        GuildDiscoveryDisqualified,              // 14
        GuildDiscoveryRequalified,               // 15
        GuildDiscoveryGracePeriodInitialWarning, // 16
        GuildDiscoveryGracePeriodFinalWarning,   // 17
        ThreadCreated,                           // 18
        Reply,                                   // 19
        ChatInputCommand,                        // 20
        ThreadStarterMessage,                    // 21
        GuildInviteReminder,                     // 22
        ContextMenuCommand,                      // 23
        AutoModerationAction,                    // 24
        RoleSubscriptionPurchase,                // 25
        InteractionPremiumUpsell,                // 26
        StageStart,                              // 27
        StageEnd,                                // 28
        StageSpeaker,                            // 29
        StageRaiseHand,                          // 30
        StageTopic,                              // 31
        GuildApplicationPremiumSubscription,     // 32
        PremiumReferral,                         // 35
        GuildIncidentAlertModeEnabled,           // 36
        GuildIncidentAlertModeDisabled,          // 37
        GuildIncidentReportRaid,                 // 38
        GuildIncidentReportFalseAlarm,           // 39
        GuildDeadchatRevivePrompt,               // 40
        CustomGift,                              // 41
        GuildGamingStatsPrompt,                  // 42
        PurchaseNotification,                    // 44
        PollResult,                              // 46
        Changelog,                               // 47
        NitroNotification,                       // 48
        ChannelLinkedToLobby,                    // 49
        GiftingPrompt,                           // 50
        InGameMessageNux,                        // 51
        GuildJoinRequestAcceptNotification,      // 52
        GuildJoinRequestRejectNotification,      // 53
        GuildJoinRequestWithdrawnNotification,   // 54
        HdStreamingUpgraded,                     // 55
        ReportToModDeletedMessage,               // 58
        ReportToModTimeoutUser,                  // 59
        ReportToModKickUser,                     // 60
        ReportToModBanUser,                      // 61
        ReportToModClosedReport,                 // 62
        EmojiAdded,                              // 63
    }

    enum BridgedRustError {
        UnhandledError(String),
    }
    // Snowflake
    #[swift_bridge(swift_repr = "struct")]
    #[derive(Clone, Copy)]
    struct SnowflakeRust {
        inner: u64,
    }

    // Shared
    #[swift_bridge(swift_repr = "struct")]
    #[derive(Clone, Copy)]
    struct DiscordColorRust {
        inner: i32,
    }

    #[swift_bridge(swift_repr = "struct")]
    #[derive(Debug, Clone)]
    struct DiscordTimestampRust {
        inner: f64,
    }

    enum DiscordLocaleRust {
        Danish,        // "da"
        German,        // "de"
        EnglishUK,     // "en-GB"
        EnglishUS,     // "en-US"
        Spanish,       // "es-ES"
        French,        // "fr"
        Croatian,      // "hr"
        Italian,       // "it"
        Lithuanian,    // "lt"
        Hungarian,     // "hu"
        Dutch,         // "nl"
        Norwegian,     // "no"
        Polish,        // "pl"
        Portuguese,    // "pt-BR"
        Romanian,      // "ro"
        Finnish,       // "fi"
        Swedish,       // "sv-SE"
        Vietnamese,    // "vi"
        Turkish,       // "tr"
        Czech,         // "cs"
        Greek,         // "el"
        Bulgarian,     // "bg"
        Russian,       // "ru"
        Ukrainian,     // "uk"
        Hindi,         // "hi"
        Thai,          // "th"
        ChineseChina,  // "zh-CN"
        Japanese,      // "ja"
        ChineseTaiwan, // "zh-TW"
        Korean,        // "ko"
        Undocumented(String),
    }

    #[swift_bridge(swift_repr = "struct")]
    #[derive(Clone)]
    struct GuildFolderRust {
        guild_ids: Vec<u64>,
        id: Option<i64>,
        name: Option<String>,
        color: Option<DiscordColorRust>,
    }

    //Permission
    #[swift_bridge(swift_repr = "struct")]
    #[derive(Clone)]
    struct RoleRust {
        id: SnowflakeRust,
        // name: String,
        // description: Option<String>,
        color: DiscordColorRust,
        // hoist: bool,
        // icon: Option<String>,
        // unicode_emoji: Option<String>,
        position: i32,
        // managed: bool,
        // mentionable: bool,
        // version: Option<i32>,
    }

    //Guild
    enum DiscordChannelKindRust {
        GuildText,
        Dm,
        GuildVoice,
        GroupDm,
        GuildCategory,
        GuildAnnouncement,
        GuildStore,
        AnnouncementThread,
        PublicThread,
        PrivateThread,
        GuildStageVoice,
        GuildDirectory,
        GuildForum,
        GuildMedia,
        Undocumented,
    }

    #[swift_bridge(swift_repr = "struct")]
    struct AttachmentRust {
        id: SnowflakeRust,
        filename: String,
        title: Option<String>,
        description: Option<String>,
        content_type: Option<String>,
        size: i32,
        url: String,
        proxy_url: String,
        placeholder: Option<String>,
        height: Option<i32>,
        width: Option<i32>,
        ephemeral: Option<bool>,
        duration_secs: Option<f64>,
        waveform: Option<String>,
    }

    #[swift_bridge(swift_repr = "struct")]
    struct SourceLocationRust {
        line: i32,
        column: i32,
        offset: i32,
    }

    //swift bridge doesn't support Vec<TransparentStruct> yet, nor having an opaque type as a field in a shared struct,
    //so unfortunately we have to wrap these protobufs in opaque classes..
    extern "Swift" {
        type BridgedDiscordChannel;
        fn get_id(self: &BridgedDiscordChannel) -> u64;
        fn has_guild_id(self: &BridgedDiscordChannel) -> bool;
        fn get_guild_id(self: &BridgedDiscordChannel) -> SnowflakeRust;
        fn get_name(self: &BridgedDiscordChannel) -> Option<String>;
        fn get_type(self: &BridgedDiscordChannel) -> DiscordChannelKindRust;
        fn get_topic(self: &BridgedDiscordChannel) -> Option<String>;
        fn get_parent_id(self: &BridgedDiscordChannel) -> Option<u64>;
        fn get_position(self: &BridgedDiscordChannel) -> Option<i32>;

        type BridgedGuild;
        fn get_id(self: &BridgedGuild) -> u64;
        fn get_name(self: &BridgedGuild) -> String;
        fn get_icon(self: &BridgedGuild) -> Option<String>;
        fn get_banner(self: &BridgedGuild) -> Option<String>;
        fn get_channel_count(self: &BridgedGuild) -> usize;
        fn get_channel(self: &BridgedGuild, index: usize) -> BridgedDiscordChannel;
        fn role_count(self: &BridgedGuild) -> usize;
        fn get_role(self: &BridgedGuild, index: usize) -> RoleRust;

        type BridgedGuildFolderVec;
        fn len(self: &BridgedGuildFolderVec) -> usize;
        fn get_unchecked(self: &BridgedGuildFolderVec, index: usize) -> GuildFolderRust;

        type BridgedGuildFolders;
        fn get_folders(self: &BridgedGuildFolders) -> BridgedGuildFolderVec;
        fn get_guild_positions(self: &BridgedGuildFolders) -> Vec<u64>;

        type BridgedPreloadedUserSettings;
        fn get_guild_folders(self: &BridgedPreloadedUserSettings) -> BridgedGuildFolders;

        type BridgedReadyPayload;
        fn get_user(self: &BridgedReadyPayload) -> DiscordUserRust;
        fn has_preloaded_user_settings(self: &BridgedReadyPayload) -> bool;
        fn get_preloaded_user_settings(self: &BridgedReadyPayload) -> BridgedPreloadedUserSettings;
        fn get_guild_count(self: &BridgedReadyPayload) -> usize;
        fn get_guild(self: &BridgedReadyPayload, index: usize) -> BridgedGuild;

        type BridgedPartialMember;
        fn has_user(self: &BridgedPartialMember) -> bool;
        fn get_user(self: &BridgedPartialMember) -> DiscordUserRust;
        fn get_nick(self: &BridgedPartialMember) -> Option<String>;
        fn get_avatar(self: &BridgedPartialMember) -> Option<String>;
        fn get_banner(self: &BridgedPartialMember) -> Option<String>;
        fn get_pronouns(self: &BridgedPartialMember) -> Option<String>;
        fn role_count(self: &BridgedPartialMember) -> usize;
        fn get_role(self: &BridgedPartialMember, index: usize) -> SnowflakeRust;
        fn has_joined_at(self: &BridgedPartialMember) -> bool;
        fn get_joined_at(self: &BridgedPartialMember) -> DiscordTimestampRust;
        fn has_premium_since(self: &BridgedPartialMember) -> bool;
        fn get_premium_since(self: &BridgedPartialMember) -> DiscordTimestampRust;
        fn get_deaf(self: &BridgedPartialMember) -> bool;
        fn get_mute(self: &BridgedPartialMember) -> bool;
        fn get_pending(self: &BridgedPartialMember) -> bool;
        fn has_avatar_decoration(self: &BridgedPartialMember) -> bool;
        fn get_avatar_decoration(self: &BridgedPartialMember) -> AvatarDecorationRust;

        type BridgedGuildMembersChunkPayload;
        fn get_guild_id(self: &BridgedGuildMembersChunkPayload) -> SnowflakeRust;
        fn member_count(self: &BridgedGuildMembersChunkPayload) -> usize;
        fn get_member(self: &BridgedGuildMembersChunkPayload, index: usize)
        -> BridgedPartialMember;

        type BridgedPartialMessage;
        fn get_id(self: &BridgedPartialMessage) -> SnowflakeRust;
        fn get_kind(self: &BridgedPartialMessage) -> DiscordMessageKindRust;
        fn get_channel_id(self: &BridgedPartialMessage) -> SnowflakeRust;
        fn has_guild_id(self: &BridgedPartialMessage) -> bool;
        fn get_guild_id(self: &BridgedPartialMessage) -> SnowflakeRust;
        fn has_author(self: &BridgedPartialMessage) -> bool;
        fn get_author(self: &BridgedPartialMessage) -> DiscordUserRust;
        fn get_content(self: &BridgedPartialMessage) -> Option<String>;
        fn has_timestamp(self: &BridgedPartialMessage) -> bool;
        fn get_timestamp(self: &BridgedPartialMessage) -> DiscordTimestampRust;
        fn has_edited_timestamp(self: &BridgedPartialMessage) -> bool;
        fn get_edited_timestamp(self: &BridgedPartialMessage) -> DiscordTimestampRust;
        fn attachment_count(self: &BridgedPartialMessage) -> Option<usize>;
        fn get_attachment(self: &BridgedPartialMessage, index: usize) -> AttachmentRust;
        fn has_referenced_message(self: &BridgedPartialMessage) -> bool;
        fn get_referenced_message(self: &BridgedPartialMessage) -> BridgedPartialMessage;
        fn has_member(self: &BridgedPartialMessage) -> bool;
        fn get_member(self: &BridgedPartialMessage) -> BridgedPartialMember;

        type BridgedMessageCreatePayload;
        fn to_partial_message(self: &BridgedMessageCreatePayload) -> BridgedPartialMessage;

        type BridgedGatewayPayload;
        fn as_ready_payload(self: &BridgedGatewayPayload) -> BridgedReadyPayload;
        fn as_message_create_payload(self: &BridgedGatewayPayload) -> BridgedMessageCreatePayload;
        fn as_guild_members_chunk_payload(
            self: &BridgedGatewayPayload,
        ) -> BridgedGuildMembersChunkPayload;

        type BridgedGatewayEvent;
        fn get_type(self: &BridgedGatewayEvent) -> Option<String>;
        fn has_payload(self: &BridgedGatewayEvent) -> bool;
        fn get_payload(self: &BridgedGatewayEvent) -> BridgedGatewayPayload;

        #[swift_bridge(Sendable)]
        type BridgedAstNode;
        fn get_node_type(self: &BridgedAstNode) -> String;
        fn get_source_location(self: &BridgedAstNode) -> SourceLocationRust;
        fn get_content(self: &BridgedAstNode) -> Option<String>;
        fn get_children_count(self: &BridgedAstNode) -> i32;
        fn get_child(self: &BridgedAstNode, index: i32) -> BridgedAstNode;

        #[swift_bridge(Sendable)]
        type BridgedAstDocumentNode;
        fn get_children_count(self: &BridgedAstDocumentNode) -> i32;
        fn get_child(self: &BridgedAstDocumentNode, index: i32) -> BridgedAstNode;

        #[swift_bridge(Sendable)]
        type DiscordMarkdownParser;
        fn discord_markdown_parser_new() -> DiscordMarkdownParser;
        async fn parse_ast_rust(
            self: &DiscordMarkdownParser,
            markdown: String,
        ) -> Result<BridgedAstDocumentNode, BridgedRustError>;
    }

    // User
    enum PremiumKindRust {
        None,
        NitroClassic,
        Nitro,
        NitroBasic,
        Undocumented(i32),
    }

    enum ColorPaletteRust {
        None,
        Crimson,
        Berry,
        Sky,
        Teal,
        Forest,
        BubbleGum,
        Violet,
        Cobalt,
        Clover,
        Lemon,
        White,
        Undocumented(String),
    }

    #[swift_bridge(swift_repr = "struct")]
    #[derive(Debug, Clone)]
    struct NameplateRust {
        asset: String,
        sku_id: SnowflakeRust,
        label: String,
        palette: ColorPaletteRust,
        expires_at: Option<DiscordTimestampRust>,
    }

    #[swift_bridge(swift_repr = "struct")]
    #[derive(Debug, Clone)]
    struct CollectiblesRust {
        nameplate: Option<NameplateRust>,
    }

    #[swift_bridge(swift_repr = "struct")]
    #[derive(Debug, Clone)]
    struct AvatarDecorationRust {
        asset: String,
        sku_id: SnowflakeRust,
    }

    #[swift_bridge(swift_repr = "struct")]
    #[derive(Debug, Clone)]
    struct PrimaryGuildRust {
        identity_enabled: Option<bool>,
        identity_guild_id: Option<SnowflakeRust>,
        tag: Option<String>,
        badge: Option<String>,
    }

    #[swift_bridge(swift_repr = "struct")]
    #[derive(Debug, Clone)]
    struct DiscordUserRust {
        id: SnowflakeRust,
        username: String,
        discriminator: String,
        global_name: Option<String>,
        avatar: Option<String>,
        banner: Option<String>,
        bot: Option<bool>,
        system: Option<bool>,
        mfa_enabled: Option<bool>,
        pronouns: Option<String>,
        accent_color: Option<DiscordColorRust>,
        locale: Option<DiscordLocaleRust>,
        verified: Option<bool>,
        email: Option<String>,
        premium_type: Option<PremiumKindRust>,
        avatar_decoration: Option<String>,
        collectibles: Option<CollectiblesRust>,
        avatar_decoration_data: Option<AvatarDecorationRust>,
        primary_guild: Option<PrimaryGuildRust>,
    }

    // Remote Auth Gateway Manager
    enum RemoteAuthGatewayError {
        BridgedError(String),
    }

    pub enum RemoteAuthOpcodeRust {
        Hello,
        Init,
        Heartbeat,
        HeartbeatAck,
        NonceProof,
        PendingRemoteInit,
        PendingTicket,
        PendingLogin,
        Cancel,
    }

    #[swift_bridge(swift_repr = "struct")]
    struct UserPayloadRust {
        id: String,
        discriminator: String,
        avatar: Option<String>,
        username: String,
    }

    #[swift_bridge(swift_repr = "struct")]
    struct RemoteAuthPayloadRust {
        op: RemoteAuthOpcodeRust,
        heartbeat_interval: Option<i32>,
        timeout_ms: Option<i32>,
        encoded_public_key: Option<String>,
        encrypted_nonce: Option<String>,
        nonce: Option<String>,
        fingerprint: Option<String>,
        encrypted_user_payload: Option<String>,
        user_payload: Option<UserPayloadRust>,
        ticket: Option<String>,
    }

    extern "Swift" {
        // Default Discord Client
        type BridgedDefaultDiscordClient;
        fn default_discord_client_new() -> BridgedDefaultDiscordClient;
        async fn get_fingerprint(self: &BridgedDefaultDiscordClient) -> Option<String>;

        // CDN Endpoints
        fn guild_member_avatar(guild_id: u64, user_id: u64, avatar: String) -> String;
        fn user_avatar(user_id: u64, avatar: String) -> String;
        fn default_user_avatar(user_id: u64) -> String;
        fn guild_icon(guild_id: u64, icon: String) -> String;
        fn guild_banner(guild_id: u64, banner: String) -> String;

        // User Gateway Manager
        type BridgedMessageVec;
        fn len(self: &BridgedMessageVec) -> usize;
        fn get(self: &BridgedMessageVec, index: usize) -> BridgedPartialMessage;

        type UserGatewayManager;
        async fn user_gateway_manager_new(token: String) -> UserGatewayManager;
        async fn connect(self: &UserGatewayManager);
        async fn disconnect(self: &UserGatewayManager);
        async fn next_event(self: &UserGatewayManager) -> BridgedGatewayEvent;
        async fn update_guild_subscriptions(
            self: &UserGatewayManager,
            id: SnowflakeRust,
            typing: bool,
            activities: bool,
            threads: bool,
            member_updates: bool,
        );
        async fn list_messages(
            self: &UserGatewayManager,
            channel: SnowflakeRust,
            limit: i32,
        ) -> Result<BridgedMessageVec, BridgedRustError>;
        async fn request_guild_members_chunk(
            self: &UserGatewayManager,
            guild_id: SnowflakeRust,
            user_ids: Vec<u64>,
        );

        async fn send_message(self: &UserGatewayManager, channel: SnowflakeRust, content: String);

        // Remote Auth Gateway Manager
        type RemoteAuthGatewayManager;
        fn remote_auth_gateway_manager_new() -> RemoteAuthGatewayManager;
        async fn connect(self: &RemoteAuthGatewayManager);
        async fn disconnect(self: &RemoteAuthGatewayManager);
        async fn next_event(self: &RemoteAuthGatewayManager) -> RemoteAuthPayloadRust;
        async fn exchange_default(
            self: &RemoteAuthGatewayManager,
            ticket: String,
        ) -> Result<String, RemoteAuthGatewayError>;
    }

    extern "Rust" {
        fn make_rust_vec_u64(initial: &[u64]) -> Vec<u64>;
    }
}

fn make_rust_vec_u64(initial: &[u64]) -> Vec<u64> {
    initial.to_vec()
}

//stupid clone impls while swift_bridge doesn't support derive(Clone) for enums for some reason
impl Clone for ffi::ColorPaletteRust {
    fn clone(&self) -> Self {
        match self {
            Self::None => Self::None,
            Self::Crimson => Self::Crimson,
            Self::Berry => Self::Berry,
            Self::Sky => Self::Sky,
            Self::Teal => Self::Teal,
            Self::Forest => Self::Forest,
            Self::BubbleGum => Self::BubbleGum,
            Self::Violet => Self::Violet,
            Self::Cobalt => Self::Cobalt,
            Self::Clover => Self::Clover,
            Self::Lemon => Self::Lemon,
            Self::White => Self::White,
            Self::Undocumented(arg0) => Self::Undocumented(arg0.clone()),
        }
    }
}

impl Clone for DiscordLocaleRust {
    fn clone(&self) -> Self {
        match self {
            Self::Danish => Self::Danish,
            Self::German => Self::German,
            Self::EnglishUK => Self::EnglishUK,
            Self::EnglishUS => Self::EnglishUS,
            Self::Spanish => Self::Spanish,
            Self::French => Self::French,
            Self::Croatian => Self::Croatian,
            Self::Italian => Self::Italian,
            Self::Lithuanian => Self::Lithuanian,
            Self::Hungarian => Self::Hungarian,
            Self::Dutch => Self::Dutch,
            Self::Norwegian => Self::Norwegian,
            Self::Polish => Self::Polish,
            Self::Portuguese => Self::Portuguese,
            Self::Romanian => Self::Romanian,
            Self::Finnish => Self::Finnish,
            Self::Swedish => Self::Swedish,
            Self::Vietnamese => Self::Vietnamese,
            Self::Turkish => Self::Turkish,
            Self::Czech => Self::Czech,
            Self::Greek => Self::Greek,
            Self::Bulgarian => Self::Bulgarian,
            Self::Russian => Self::Russian,
            Self::Ukrainian => Self::Ukrainian,
            Self::Hindi => Self::Hindi,
            Self::Thai => Self::Thai,
            Self::ChineseChina => Self::ChineseChina,
            Self::Japanese => Self::Japanese,
            Self::ChineseTaiwan => Self::ChineseTaiwan,
            Self::Korean => Self::Korean,
            Self::Undocumented(arg0) => Self::Undocumented(arg0.clone()),
        }
    }
}

impl Clone for PremiumKindRust {
    fn clone(&self) -> Self {
        match self {
            Self::None => Self::None,
            Self::NitroClassic => Self::NitroClassic,
            Self::Nitro => Self::Nitro,
            Self::NitroBasic => Self::NitroBasic,
            Self::Undocumented(arg0) => Self::Undocumented(arg0.clone()),
        }
    }
}
