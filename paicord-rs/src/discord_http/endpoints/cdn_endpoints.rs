use crate::discord_models::types::snowflake::Snowflake;
use crate::ffi;

pub enum CDNEndpoint {
    GuildMemberAvatar {
        guild_id: Snowflake,
        user_id: Snowflake,
        avatar: String,
    },
    UserAvatar {
        user_id: Snowflake,
        avatar: String,
    },
    DefaultUserAvatar {
        user_id: Snowflake,
    },
    GuildIcon {
        guild_id: Snowflake,
        icon: String,
    },
    GuildBanner {
        guild_id: Snowflake,
        banner: String,
    }
}

pub fn get_cdn_url(endpoint: CDNEndpoint) -> String {
    match endpoint {
        CDNEndpoint::GuildMemberAvatar { guild_id, user_id, avatar } => {
            ffi::guild_member_avatar(guild_id.get_raw(), user_id.get_raw(), avatar)
        }
        CDNEndpoint::UserAvatar { user_id, avatar } => {
            ffi::user_avatar(user_id.get_raw(), avatar)
        }
        CDNEndpoint::DefaultUserAvatar { user_id } => {
            ffi::default_user_avatar(user_id.get_raw())
        }
        CDNEndpoint::GuildIcon { guild_id, icon } => {
            ffi::guild_icon(guild_id.get_raw(), icon)
        }
        CDNEndpoint::GuildBanner { guild_id, banner } => {
            ffi::guild_banner(guild_id.get_raw(), banner)
        }
    }
}