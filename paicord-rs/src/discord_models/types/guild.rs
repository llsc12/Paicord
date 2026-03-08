use std::sync::Arc;

use crate::{
    discord_models::types::{channel::DiscordChannel, permission::Role, shared::DiscordTimestamp, snowflake::Snowflake, user::{AvatarDecoration, DiscordUser, PartialUser}},
    ffi,
};

#[derive(Clone, Debug)]
pub struct Guild {
    pub id: Snowflake,
    pub name: String,
    pub icon: Option<String>,
    pub banner: Option<String>,
    pub channels: Vec<DiscordChannel>,

    guild: Arc<ffi::BridgedGuild>,
}

impl std::fmt::Debug for ffi::BridgedGuild {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_tuple("BridgedGuild").finish()
    }
}

impl Guild {
    pub fn new(inner: ffi::BridgedGuild) -> Self {
        Self {
            id: Snowflake::from(inner.get_id()),
            name: inner.get_name(),
            icon: inner.get_icon(),
            banner: inner.get_banner(),
            channels: (0..inner.get_channel_count())
                .map(|i| inner.get_channel(i))
                .map(DiscordChannel::new)
                .collect(),
            guild: Arc::new(inner),
        }
    }

    pub fn get_roles(&self) -> Vec<Role> {
        (0..self.guild.role_count()).map(|i| self.guild.get_role(i)).collect()
    }

    pub fn get_members(&self) -> Vec<PartialMember> {
        (0..self.guild.member_count()).map(|i| self.guild.get_member(i)).map(PartialMember::new).collect()
    }
}

#[derive(Clone, Debug)]
pub struct PartialMember {
    pub user: Option<PartialUser>,
    pub nick: Option<String>,
    pub avatar: Option<String>,
    pub banner: Option<String>,
    pub pronouns: Option<String>,
    pub roles: Vec<Snowflake>,
    pub joined_at: Option<DiscordTimestamp>,
    pub premium_since: Option<DiscordTimestamp>,
    pub deaf: bool,
    pub mute: bool,
    pub pending: bool,
    pub avatar_decoration: Option<AvatarDecoration>,
}

impl PartialMember {
    pub fn new(inner: ffi::BridgedPartialMember) -> Self {
        Self {
            user: if inner.has_user() {
                Some(PartialUser::from(inner.get_user()))
            } else {
                None
            },
            nick: inner.get_nick(),
            avatar: inner.get_avatar(),
            banner: inner.get_banner(),
            pronouns: inner.get_pronouns(),
            roles: (0..inner.role_count()).map(|i| inner.get_role(i)).map(Snowflake::from).collect(),
            joined_at: if inner.has_joined_at() {
                Some(DiscordTimestamp::from(inner.get_joined_at()))
            } else {
                None
            },
            premium_since: if inner.has_premium_since() {
                Some(DiscordTimestamp::from(inner.get_premium_since()))
            } else {
                None
            },
            deaf: inner.get_deaf(),
            mute: inner.get_mute(),
            pending: inner.get_pending(),
            avatar_decoration: if inner.has_avatar_decoration() {
                Some(inner.get_avatar_decoration())
            } else {
                None
            },
        }
    }

    pub fn get_display_name(&self) -> Option<String> {
        if let Some(nick) = &self.nick {
            Some(nick.clone())
        } else if let Some(user) = &self.user {
            user.username.clone()
        } else {
            None
        }
    }
}

unsafe impl Send for ffi::BridgedGuild {}
unsafe impl Sync for ffi::BridgedGuild {}