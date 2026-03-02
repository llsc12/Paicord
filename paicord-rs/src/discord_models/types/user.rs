use crate::{
    discord_gateway::remote_auth_gateway_manager::UserPayload,
    discord_models::types::{shared::DiscordColor, snowflake::Snowflake},
};

use crate::ffi;

pub use ffi::AvatarDecorationRust as AvatarDecoration;
pub use ffi::CollectiblesRust as Collectibles;
pub use ffi::ColorPaletteRust as ColorPalette;
pub use ffi::DiscordUserRust as DiscordUser;
pub use ffi::NameplateRust as Nameplate;
pub use ffi::PremiumKindRust as PremiumKind;
pub use ffi::PrimaryGuildRust as PrimaryGuild;

#[derive(Clone, Debug)]
pub struct PartialUser {
    pub id: Snowflake,
    pub username: Option<String>,
    pub discriminator: Option<String>,
    pub global_name: Option<String>,
    pub avatar: Option<String>,
    pub banner: Option<String>,
    pub pronouns: Option<String>,
    //TODO: pub avatar_decoration_data: DiscordUser.AvatarDecoration?
    //TODO: pub collectibles: DiscordUser.Collectibles?
    //TODO: pub primary_guild: DiscordUser.PrimaryGuild?
    pub bot: Option<bool>,
    pub system: Option<bool>,
    pub accent_color: Option<DiscordColor>,
    //TODO: pub public_flags: IntBitField<DiscordUser.Flag>?
}

impl PartialUser {
    pub fn new(
        id: Snowflake,
        username: Option<String>,
        discriminator: Option<String>,
        global_name: Option<String>,
        avatar: Option<String>,
        banner: Option<String>,
        pronouns: Option<String>,
        bot: Option<bool>,
        system: Option<bool>,
        accent_color: Option<DiscordColor>,
    ) -> Self {
        Self {
            id,
            username,
            discriminator,
            global_name,
            avatar,
            banner,
            pronouns,
            bot,
            system,
            accent_color,
        }
    }
}

impl From<UserPayload> for PartialUser {
    fn from(value: UserPayload) -> Self {
        Self::new(
            Snowflake::from(value.id),
            Some(value.username),
            Some(value.discriminator),
            None,
            value.avatar,
            None,
            None,
            None,
            None,
            None,
        )
    }
}

impl From<&DiscordUser> for PartialUser {
    fn from(value: &DiscordUser) -> Self {
        Self::new(
            value.id,
            Some(value.username.clone()),
            Some(value.discriminator.clone()),
            value.global_name.clone(),
            value.avatar.clone(),
            value.banner.clone(),
            value.pronouns.clone(),
            value.bot,
            value.system,
            value.accent_color,
        )
    }
}

impl From<DiscordUser> for PartialUser {
    fn from(value: DiscordUser) -> Self {
        Self::from(&value)
    }
}

impl std::fmt::Debug for DiscordUser {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("DiscordUserRust")
            .field("id", &self.id)
            .field("username", &self.username)
            .field("discriminator", &self.discriminator)
            .field("global_name", &self.global_name)
            .field("avatar", &self.avatar)
            .field("banner", &self.banner)
            .field("bot", &self.bot)
            .field("system", &self.system)
            .field("mfa_enabled", &self.mfa_enabled)
            .field("pronouns", &self.pronouns)
            .field("accent_color", &self.accent_color)
            .field("locale", &self.locale)
            .field("verified", &self.verified)
            .field("email", &self.email)
            .field("premium_type", &self.premium_type)
            .field("avatar_decoration", &self.avatar_decoration)
            .field("collectibles", &self.collectibles)
            .field("avatar_decoration_data", &self.avatar_decoration_data)
            .field("primary_guild", &self.primary_guild)
            .finish()
    }
}

impl std::fmt::Debug for PremiumKind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::None => write!(f, "None"),
            Self::NitroClassic => write!(f, "NitroClassic"),
            Self::Nitro => write!(f, "Nitro"),
            Self::NitroBasic => write!(f, "NitroBasic"),
            Self::Undocumented(arg0) => f.debug_tuple("Undocumented").field(arg0).finish(),
        }
    }
}

impl std::fmt::Debug for Collectibles {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("CollectiblesRust")
            .field("nameplate", &self.nameplate)
            .finish()
    }
}

impl std::fmt::Debug for Nameplate {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("NameplateRust")
            .field("asset", &self.asset)
            .field("sku_id", &self.sku_id)
            .field("label", &self.label)
            .field("palette", &self.palette)
            .field("expires_at", &self.expires_at)
            .finish()
    }
}

impl std::fmt::Debug for ColorPalette {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::None => write!(f, "None"),
            Self::Crimson => write!(f, "Crimson"),
            Self::Berry => write!(f, "Berry"),
            Self::Sky => write!(f, "Sky"),
            Self::Teal => write!(f, "Teal"),
            Self::Forest => write!(f, "Forest"),
            Self::BubbleGum => write!(f, "BubbleGum"),
            Self::Violet => write!(f, "Violet"),
            Self::Cobalt => write!(f, "Cobalt"),
            Self::Clover => write!(f, "Clover"),
            Self::Lemon => write!(f, "Lemon"),
            Self::White => write!(f, "White"),
            Self::Undocumented(arg0) => f.debug_tuple("Undocumented").field(arg0).finish(),
        }
    }
}

impl std::fmt::Debug for AvatarDecoration {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AvatarDecorationRust")
            .field("asset", &self.asset)
            .field("sku_id", &self.sku_id)
            .finish()
    }
}

impl std::fmt::Debug for PrimaryGuild {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("PrimaryGuildRust")
            .field("identity_enabled", &self.identity_enabled)
            .field("identity_guild_id", &self.identity_guild_id)
            .field("tag", &self.tag)
            .field("badge", &self.badge)
            .finish()
    }
}
