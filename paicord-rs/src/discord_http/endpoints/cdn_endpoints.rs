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
    }
}