use crate::ffi::{DiscordLocaleRust, PremiumKindRust};

pub mod discord_gateway;
pub mod discord_http;
pub mod discord_models;

// Stupid limitation of swift_bridge at the moment is that using them across multiple files isn't feasible, unless used for pure functions
// So for now we have to put everything in this one module
#[swift_bridge::bridge]
pub(crate) mod ffi {
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
    // Snowflake
    #[swift_bridge(swift_repr = "struct")]
    #[derive(Clone, Copy)]
    struct SnowflakeRust {
        inner: u64
    }

    // User
    enum PremiumKindRust {
        None,
        NitroClassic,
        Nitro,
        NitroBasic,
        Undocumented(i32)
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
        Undocumented(String)
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

    // Gateway
    #[swift_bridge(swift_repr = "struct")]
    #[derive(Debug, Clone)]
    struct ReadyPayloadRust {
        v: i32,
        user: DiscordUserRust,
        session_id: String,
        resume_gateway_url: Option<String>,
        //TODO: Sessions (need to support Vec<TransparentStruct> first)
        
    }
    
    #[derive(Debug)]
    enum GatewayPayloadRust {
        Ready(ReadyPayloadRust),
    }

    #[swift_bridge(swift_repr = "struct")]
    #[derive(Debug, Clone)]
    struct GatewayEventRust {
        data: Option<GatewayPayloadRust>,
    }

    // Remote Auth Gateway Manager
    enum RemoteAuthGatewayError {
        BridgedError(String)
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
        ticket: Option<String>
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

        // User Gateway Manager
        type UserGatewayManager;
        async fn user_gateway_manager_new(token: String) -> UserGatewayManager;
        async fn connect(self: &UserGatewayManager);
        async fn disconnect(self: &UserGatewayManager);
        async fn next_event(self: &UserGatewayManager) -> GatewayEventRust;

        // Remote Auth Gateway Manager
        type RemoteAuthGatewayManager;
        fn remote_auth_gateway_manager_new() -> RemoteAuthGatewayManager;
        async fn connect(self: &RemoteAuthGatewayManager);
        async fn disconnect(self: &RemoteAuthGatewayManager);
        async fn next_event(self: &RemoteAuthGatewayManager) -> RemoteAuthPayloadRust;
        async fn exchange_default(self: &RemoteAuthGatewayManager, ticket: String) -> Result<String, RemoteAuthGatewayError>;
    }
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

impl Clone for ffi::GatewayPayloadRust {
    fn clone(&self) -> Self {
        match self {
            Self::Ready(arg0) => Self::Ready(arg0.clone()),
        }
    }
}