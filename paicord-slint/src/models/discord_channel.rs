use paicord_rs::discord_models::types::{
    channel::{DiscordChannel, DiscordChannelKind},
    snowflake::Snowflake,
};

use crate::{
    app::{DiscordChannelKindSlint, DiscordChannelSlint},
    models::slint_tree::SlintTreeItem,
};

impl SlintTreeItem for DiscordChannelSlint {
    fn get_id(&self) -> paicord_rs::discord_models::types::snowflake::Snowflake {
        Snowflake::from(self.id.to_string())
    }

    fn is_expanded(&self) -> bool {
        self.expanded && self.kind == DiscordChannelKindSlint::GuildCategory
    }

    fn has_children(&self) -> bool {
        self.kind == DiscordChannelKindSlint::GuildCategory
    }
}

impl From<&DiscordChannel> for DiscordChannelSlint {
    fn from(value: &DiscordChannel) -> Self {
        Self {
            id: value.id.get_description().into(),
            name: value.name.clone().unwrap_or("Unknown Channel".to_string()).into(),
            topic: value.topic.clone().unwrap_or_default().into(),
            kind: value.kind.clone().unwrap_or(DiscordChannelKind::GuildText).into(),
            expanded: false,
            ..Default::default()
        }
    }
}

impl From<&DiscordChannelKind> for DiscordChannelKindSlint {
    fn from(value: &DiscordChannelKind) -> Self {
        match value {
            DiscordChannelKind::GuildText => DiscordChannelKindSlint::GuildText,
            DiscordChannelKind::Dm => DiscordChannelKindSlint::Dm,
            DiscordChannelKind::GuildVoice => DiscordChannelKindSlint::GuildVoice,
            DiscordChannelKind::GroupDm => DiscordChannelKindSlint::GroupDm,
            DiscordChannelKind::GuildCategory => DiscordChannelKindSlint::GuildCategory,
            DiscordChannelKind::GuildAnnouncement => DiscordChannelKindSlint::GuildAnnouncement,
            DiscordChannelKind::GuildStore => DiscordChannelKindSlint::GuildStore,
            DiscordChannelKind::AnnouncementThread => DiscordChannelKindSlint::AnnouncementThread,
            DiscordChannelKind::PublicThread => DiscordChannelKindSlint::PublicThread,
            DiscordChannelKind::PrivateThread => DiscordChannelKindSlint::PrivateThread,
            DiscordChannelKind::GuildStageVoice => DiscordChannelKindSlint::GuildStageVoice,
            DiscordChannelKind::GuildDirectory => DiscordChannelKindSlint::GuildDirectory,
            DiscordChannelKind::GuildForum => DiscordChannelKindSlint::GuildForum,
            DiscordChannelKind::GuildMedia => DiscordChannelKindSlint::GuildMedia,
            DiscordChannelKind::Undocumented => DiscordChannelKindSlint::GuildText,
        }
    }
}

impl From<DiscordChannelKind> for DiscordChannelKindSlint {
    fn from(value: DiscordChannelKind) -> Self {
        Self::from(&value)
    }
}