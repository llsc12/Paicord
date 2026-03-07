use crate::{discord_models::types::snowflake::Snowflake, ffi};

pub type DiscordChannelKind = crate::ffi::DiscordChannelKindRust;
pub type Attachment = crate::ffi::AttachmentRust;
pub type DiscordMessageKind = crate::ffi::DiscordMessageKindRust;

#[derive(Clone, Debug)]
pub struct DiscordChannel {
    pub id: Snowflake,
    pub guild_id: Option<Snowflake>,
    pub name: Option<String>,
    pub topic: Option<String>,
    pub kind: Option<DiscordChannelKind>,
    pub parent_id: Option<Snowflake>,
    pub position: Option<i32>,
}

impl DiscordChannel {
    pub fn new(inner: crate::ffi::BridgedDiscordChannel) -> Self {
        Self {
            id: Snowflake::from(inner.get_id()),
            guild_id: if inner.has_guild_id() {
                Some(Snowflake::from(inner.get_guild_id()))
            } else {
                None
            },
            name: inner.get_name(),
            topic: inner.get_topic(),
            kind: if inner.get_type() == DiscordChannelKind::Undocumented {
                None
            } else {
                Some(inner.get_type())
            },
            parent_id: inner.get_parent_id().map(Snowflake::from),
            position: inner.get_position(),
        }
    }
}

impl std::fmt::Debug for DiscordChannelKind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::GuildText => write!(f, "GuildText"),
            Self::Dm => write!(f, "Dm"),
            Self::GuildVoice => write!(f, "GuildVoice"),
            Self::GroupDm => write!(f, "GroupDm"),
            Self::GuildCategory => write!(f, "GuildCategory"),
            Self::GuildAnnouncement => write!(f, "GuildAnnouncement"),
            Self::GuildStore => write!(f, "GuildStore"),
            Self::AnnouncementThread => write!(f, "AnnouncementThread"),
            Self::PublicThread => write!(f, "PublicThread"),
            Self::PrivateThread => write!(f, "PrivateThread"),
            Self::GuildStageVoice => write!(f, "GuildStageVoice"),
            Self::GuildDirectory => write!(f, "GuildDirectory"),
            Self::GuildForum => write!(f, "GuildForum"),
            Self::GuildMedia => write!(f, "GuildMedia"),
            Self::Undocumented => write!(f, "Undocumented"),
        }
    }
}

impl PartialEq for DiscordChannelKind {
    fn eq(&self, other: &Self) -> bool {
        matches!(
            (self, other),
            (Self::GuildText, Self::GuildText)
                | (Self::Dm, Self::Dm)
                | (Self::GuildVoice, Self::GuildVoice)
                | (Self::GroupDm, Self::GroupDm)
                | (Self::GuildCategory, Self::GuildCategory)
                | (Self::GuildAnnouncement, Self::GuildAnnouncement)
                | (Self::GuildStore, Self::GuildStore)
                | (Self::AnnouncementThread, Self::AnnouncementThread)
                | (Self::PublicThread, Self::PublicThread)
                | (Self::PrivateThread, Self::PrivateThread)
                | (Self::GuildStageVoice, Self::GuildStageVoice)
                | (Self::GuildDirectory, Self::GuildDirectory)
                | (Self::GuildForum, Self::GuildForum)
                | (Self::GuildMedia, Self::GuildMedia)
                | (Self::Undocumented, Self::Undocumented)
        )
    }
}

impl Clone for Attachment {
    fn clone(&self) -> Self {
        Self {
            id: self.id.clone(),
            filename: self.filename.clone(),
            title: self.title.clone(),
            description: self.description.clone(),
            content_type: self.content_type.clone(),
            size: self.size.clone(),
            url: self.url.clone(),
            proxy_url: self.proxy_url.clone(),
            placeholder: self.placeholder.clone(),
            height: self.height.clone(),
            width: self.width.clone(),
            ephemeral: self.ephemeral.clone(),
            duration_secs: self.duration_secs.clone(),
            waveform: self.waveform.clone(),
        }
    }
}

impl std::fmt::Debug for Attachment {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Attachment")
            .field("id", &self.id)
            .field("filename", &self.filename)
            .field("title", &self.title)
            .field("description", &self.description)
            .field("content_type", &self.content_type)
            .field("size", &self.size)
            .field("url", &self.url)
            .field("proxy_url", &self.proxy_url)
            .field("placeholder", &self.placeholder)
            .field("height", &self.height)
            .field("width", &self.width)
            .field("ephemeral", &self.ephemeral)
            .field("duration_secs", &self.duration_secs)
            .field("waveform", &self.waveform)
            .finish()
    }
}

impl std::fmt::Debug for DiscordMessageKind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Default => write!(f, "Default"),
            Self::RecipientAdd => write!(f, "RecipientAdd"),
            Self::RecipientRemove => write!(f, "RecipientRemove"),
            Self::Call => write!(f, "Call"),
            Self::ChannelNameChange => write!(f, "ChannelNameChange"),
            Self::ChannelIconChange => write!(f, "ChannelIconChange"),
            Self::ChannelPinnedMessage => write!(f, "ChannelPinnedMessage"),
            Self::GuildMemberJoin => write!(f, "GuildMemberJoin"),
            Self::UserPremiumGuildSubscription => write!(f, "UserPremiumGuildSubscription"),
            Self::UserPremiumGuildSubscriptionTier1 => write!(f, "UserPremiumGuildSubscriptionTier1"),
            Self::UserPremiumGuildSubscriptionTier2 => write!(f, "UserPremiumGuildSubscriptionTier2"),
            Self::UserPremiumGuildSubscriptionTier3 => write!(f, "UserPremiumGuildSubscriptionTier3"),
            Self::ChannelFollowAdd => write!(f, "ChannelFollowAdd"),
            Self::GuildDiscoveryDisqualified => write!(f, "GuildDiscoveryDisqualified"),
            Self::GuildDiscoveryRequalified => write!(f, "GuildDiscoveryRequalified"),
            Self::GuildDiscoveryGracePeriodInitialWarning => write!(f, "GuildDiscoveryGracePeriodInitialWarning"),
            Self::GuildDiscoveryGracePeriodFinalWarning => write!(f, "GuildDiscoveryGracePeriodFinalWarning"),
            Self::ThreadCreated => write!(f, "ThreadCreated"),
            Self::Reply => write!(f, "Reply"),
            Self::ChatInputCommand => write!(f, "ChatInputCommand"),
            Self::ThreadStarterMessage => write!(f, "ThreadStarterMessage"),
            Self::GuildInviteReminder => write!(f, "GuildInviteReminder"),
            Self::ContextMenuCommand => write!(f, "ContextMenuCommand"),
            Self::AutoModerationAction => write!(f, "AutoModerationAction"),
            Self::RoleSubscriptionPurchase => write!(f, "RoleSubscriptionPurchase"),
            Self::InteractionPremiumUpsell => write!(f, "InteractionPremiumUpsell"),
            Self::StageStart => write!(f, "StageStart"),
            Self::StageEnd => write!(f, "StageEnd"),
            Self::StageSpeaker => write!(f, "StageSpeaker"),
            Self::StageRaiseHand => write!(f, "StageRaiseHand"),
            Self::StageTopic => write!(f, "StageTopic"),
            Self::GuildApplicationPremiumSubscription => write!(f, "GuildApplicationPremiumSubscription"),
            Self::PremiumReferral => write!(f, "PremiumReferral"),
            Self::GuildIncidentAlertModeEnabled => write!(f, "GuildIncidentAlertModeEnabled"),
            Self::GuildIncidentAlertModeDisabled => write!(f, "GuildIncidentAlertModeDisabled"),
            Self::GuildIncidentReportRaid => write!(f, "GuildIncidentReportRaid"),
            Self::GuildIncidentReportFalseAlarm => write!(f, "GuildIncidentReportFalseAlarm"),
            Self::GuildDeadchatRevivePrompt => write!(f, "GuildDeadchatRevivePrompt"),
            Self::CustomGift => write!(f, "CustomGift"),
            Self::GuildGamingStatsPrompt => write!(f, "GuildGamingStatsPrompt"),
            Self::PurchaseNotification => write!(f, "PurchaseNotification"),
            Self::PollResult => write!(f, "PollResult"),
            Self::Changelog => write!(f, "Changelog"),
            Self::NitroNotification => write!(f, "NitroNotification"),
            Self::ChannelLinkedToLobby => write!(f, "ChannelLinkedToLobby"),
            Self::GiftingPrompt => write!(f, "GiftingPrompt"),
            Self::InGameMessageNux => write!(f, "InGameMessageNux"),
            Self::GuildJoinRequestAcceptNotification => write!(f, "GuildJoinRequestAcceptNotification"),
            Self::GuildJoinRequestRejectNotification => write!(f, "GuildJoinRequestRejectNotification"),
            Self::GuildJoinRequestWithdrawnNotification => write!(f, "GuildJoinRequestWithdrawnNotification"),
            Self::HdStreamingUpgraded => write!(f, "HdStreamingUpgraded"),
            Self::ReportToModDeletedMessage => write!(f, "ReportToModDeletedMessage"),
            Self::ReportToModTimeoutUser => write!(f, "ReportToModTimeoutUser"),
            Self::ReportToModKickUser => write!(f, "ReportToModKickUser"),
            Self::ReportToModBanUser => write!(f, "ReportToModBanUser"),
            Self::ReportToModClosedReport => write!(f, "ReportToModClosedReport"),
            Self::EmojiAdded => write!(f, "EmojiAdded"),
        }
    }
}

unsafe impl Send for ffi::BridgedMessageVec {}
unsafe impl Sync for ffi::BridgedMessageVec {}