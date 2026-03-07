use std::sync::Arc;

use crate::discord_models::protobuf::preloaded_user_settings::PreloadedUserSettings;
use crate::discord_models::types::channel::{Attachment, DiscordMessageKind};
use crate::discord_models::types::guild::{Guild, PartialMember};
use crate::discord_models::types::shared::DiscordTimestamp;
use crate::discord_models::types::snowflake::Snowflake;
use crate::discord_models::types::user::DiscordUser;
use crate::ffi;

#[derive(Clone, Debug)]
pub enum GatewayPayload {
    Ready(ReadyPayload),
    MessageCreate(MessageCreatePayload),
    GuildMembersChunk(GuildMembersChunkPayload),
    Unknown,
}

impl From<&ffi::BridgedGatewayEvent> for GatewayPayload {
    fn from(event: &ffi::BridgedGatewayEvent) -> Self {
        if !event.has_payload() {
            return GatewayPayload::Unknown;
        }

        let Some(r#type) = event.get_type() else {
            return GatewayPayload::Unknown;
        };

        match r#type.as_str() {
            "READY" => {
                let payload = event.get_payload();
                let ready_payload = payload.as_ready_payload();
                GatewayPayload::Ready(ReadyPayload::new(ready_payload))
            }

            "MESSAGE_CREATE" => {
                // Handle MESSAGE_CREATE payload if needed
                let payload = event.get_payload();
                let message_create_payload = payload.as_message_create_payload();
                GatewayPayload::MessageCreate(MessageCreatePayload::new(message_create_payload))
            }

            "GUILD_MEMBERS_CHUNK" => {
                let payload = event.get_payload();
                let chunk_payload = payload.as_guild_members_chunk_payload();
                GatewayPayload::GuildMembersChunk(GuildMembersChunkPayload::new(chunk_payload))
            }
            _ => GatewayPayload::Unknown,
        }
    }
}

#[derive(Clone, Debug)]
pub struct GuildMembersChunkPayload {
    //inner: Arc<ffi::BridgedGuildMembersChunkPayload>,
    pub guild_id: Snowflake,
    pub members: Vec<PartialMember>,
}

impl GuildMembersChunkPayload {
    pub(crate) fn new(inner: ffi::BridgedGuildMembersChunkPayload) -> Self {
        Self {
            guild_id: inner.get_guild_id(),
            members: (0..inner.member_count())
                .map(|i| inner.get_member(i))
                .map(PartialMember::new)
                .collect(),
        }
    }
}

#[derive(Clone, Debug)]
pub struct GatewayEvent {
    pub r#type: Option<String>,
    pub data: Option<GatewayPayload>,
}

impl GatewayEvent {
    pub(crate) fn new(inner: ffi::BridgedGatewayEvent) -> Self {
        Self {
            r#type: inner.get_type(),
            data: match GatewayPayload::from(&inner) {
                GatewayPayload::Unknown => None,
                payload => Some(payload),
            },
        }
    }
}

#[derive(Clone, Debug)]
pub struct PartialMessage {
    pub id: Snowflake,
    pub kind: DiscordMessageKind,
    pub channel_id: Snowflake,
    pub guild_id: Option<Snowflake>,
    pub author: Option<DiscordUser>,
    pub content: Option<String>,
    pub timestamp: Option<DiscordTimestamp>,
    pub edited_timestamp: Option<DiscordTimestamp>,
    pub attachments: Vec<Attachment>,
    pub referenced_message: Option<Box<PartialMessage>>,
    pub member: Option<PartialMember>,
}

impl PartialMessage {
    pub(crate) fn new(inner: ffi::BridgedPartialMessage) -> Self {
        Self {
            id: inner.get_id(),
            kind: inner.get_kind(),
            channel_id: inner.get_channel_id(),
            guild_id: if inner.has_guild_id() {
                Some(inner.get_guild_id())
            } else {
                None
            },
            author: if inner.has_author() {
                Some(inner.get_author())
            } else {
                None
            },
            content: inner.get_content(),
            timestamp: if inner.has_timestamp() {
                Some(inner.get_timestamp())
            } else {
                None
            },
            edited_timestamp: if inner.has_edited_timestamp() {
                Some(inner.get_edited_timestamp())
            } else {
                None
            },
            attachments: if let Some(attachment_count) = inner.attachment_count() {
                (0..attachment_count).map(|i| inner.get_attachment(i)).collect()
            } else {
                Vec::new()
            },
            referenced_message: if inner.has_referenced_message() {
                Some(Box::new(PartialMessage::new(
                    inner.get_referenced_message(),
                )))
            } else {
                None
            },
            member: if inner.has_member() {
                Some(PartialMember::new(inner.get_member()))
            } else {
                None
            },
        }
    }
}

#[derive(Clone, Debug)]
pub struct MessageCreatePayload {
    inner: Arc<ffi::BridgedMessageCreatePayload>,
}

impl MessageCreatePayload {
    pub(crate) fn new(inner: ffi::BridgedMessageCreatePayload) -> Self {
        Self {
            inner: Arc::new(inner),
        }
    }

    pub fn to_partial_message(&self) -> PartialMessage {
        let inner = self.inner.to_partial_message();

        PartialMessage::new(inner)
    }
}

#[derive(Clone, Debug)]
pub struct ReadyPayload {
    pub user: DiscordUser,
    pub user_settings_proto: Option<PreloadedUserSettings>,
    pub guilds: Vec<Guild>,
}

impl ReadyPayload {
    pub(crate) fn new(inner: ffi::BridgedReadyPayload) -> Self {
        Self {
            user: inner.get_user(),
            user_settings_proto: if inner.has_preloaded_user_settings() {
                Some(PreloadedUserSettings::new(
                    inner.get_preloaded_user_settings(),
                ))
            } else {
                None
            },
            guilds: (0..inner.get_guild_count())
                .map(|i| inner.get_guild(i))
                .map(Guild::new)
                .collect(),
        }
    }
}

unsafe impl Send for ffi::BridgedGatewayEvent {}
unsafe impl Sync for ffi::BridgedGatewayEvent {}

unsafe impl Send for ffi::BridgedReadyPayload {}
unsafe impl Sync for ffi::BridgedReadyPayload {}

unsafe impl Send for ffi::BridgedMessageCreatePayload {}
unsafe impl Sync for ffi::BridgedMessageCreatePayload {}

impl std::fmt::Debug for ffi::BridgedMessageCreatePayload {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_tuple("BridgedMessageCreatePayload").finish()
    }
}
