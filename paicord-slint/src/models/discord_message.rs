use anyhow::bail;
use chrono::Local;
use paicord_rs::{
    discord_models::types::{
        channel::DiscordMessageKind, gateway::PartialMessage, guild::PartialMember,
        snowflake::Snowflake, user::PartialUser,
    },
    markdown::DiscordMarkdownParser,
};
use slint::{ModelRc, VecModel};

use crate::{
    app::{
        DiscordMessageKindSlint, DiscordMessageSlint, LazyImage, MessageAuthorSlint,
        ReferencedMessageSlint,
    },
    utils,
};

impl MessageAuthorSlint {
    /// creates a Slint message struct from a PartialMessage's author and member info
    ///
    /// * `partial_message` - the message object received from the gateway
    /// * `guild_member` - guild member if available from guild manager
    pub fn from_partial_message(
        partial_message: &PartialMessage,
        guild_member: Option<&PartialMember>,
        guild_id: Option<&Snowflake>,
    ) -> anyhow::Result<Self> {
        let Some(author) = partial_message.author.as_ref() else {
            bail!("PartialMessage is missing author");
        };

        let s = Self {
            id: author.id.get_description().into(),
            name: get_message_author_display_name(partial_message, guild_member)?.into(),
            avatar: LazyImage::from_url(
                get_message_author_avatar_url(partial_message, guild_member, guild_id)
                    .unwrap_or_default(),
            ),
            ..Default::default()
        };

        Ok(s)
    }
}

fn get_message_author_display_name(
    partial_message: &PartialMessage,
    guild_member: Option<&PartialMember>,
) -> anyhow::Result<String> {
    let Some(author) = partial_message.author.as_ref() else {
        bail!("PartialMessage is missing author");
    };

    let mut name = None;

    if let Some(guild_member) = guild_member {
        name = guild_member.get_display_name();
    }

    if name.is_none()
        && let Some(member) = &partial_message.member
    {
        name = member.get_display_name();
    }

    if name.is_none() {
        name = PartialUser::from(author).get_display_name();
    }

    Ok(name.unwrap_or("Unknown User".to_string()))
}

fn get_message_author_avatar_url(
    partial_message: &PartialMessage,
    guild_member: Option<&PartialMember>,
    guild_id: Option<&Snowflake>,
) -> Option<String> {
    let Some(author) = partial_message.author.as_ref() else {
        return None;
    };

    let member = if let Some(guild_member) = guild_member {
        Some(guild_member.clone())
    } else if let Some(member) = &partial_message.member {
        Some(member.clone())
    } else {
        None
    };

    utils::fetch_user_avatar_url(member, guild_id.cloned(), Some(PartialUser::from(author)))
}

impl DiscordMessageSlint {
    pub async fn from_partial(
        partial_message: &PartialMessage,
        guild_member: Option<&PartialMember>,
        referenced_member: Option<&PartialMember>,
        guild_id: Option<&Snowflake>,
        markdown_parser: &DiscordMarkdownParser,
    ) -> anyhow::Result<Self> {
        let Some(author) = partial_message.author.as_ref() else {
            bail!("PartialMessage is missing author");
        };

        let mut image_attachments = Vec::new();

        let author =
            MessageAuthorSlint::from_partial_message(partial_message, guild_member, guild_id)?;

        let content = match partial_message.kind {
            DiscordMessageKind::GuildMemberJoin => utils::get_welcome_message(
                partial_message,
                &author.name,
                &partial_message.timestamp.clone().unwrap_or_default(),
            ),
            _ => partial_message
                .content
                .as_ref()
                .cloned()
                .unwrap_or_default(),
        };

        for attachment in &partial_message.attachments {
            if let Some(width) = &attachment.width
                && let Some(height) = &attachment.height
            {
                let mut lazy_image = LazyImage::from_url(attachment.proxy_url.clone());
                lazy_image.width = *width;
                lazy_image.height = *height;
                image_attachments.push(lazy_image);
            };
        }

        let s = Self {
            content: utils::parse_markdown_to_slint(
                content,
                markdown_parser,
            )
            .await?,
            empty: partial_message.content.is_none()
                || partial_message
                    .content
                    .as_ref()
                    .map(|c| c.is_empty())
                    .unwrap_or(true),
            kind: partial_message.kind.into(),
            author,
            channel_id: partial_message.channel_id.get_description().into(),
            guild_id: partial_message
                .guild_id
                .map(|id| id.get_description().into())
                .unwrap_or_default(),
            id: partial_message.id.get_description().into(),
            timestamp: partial_message
                .timestamp
                .as_ref()
                .map(|t| t.to_string(partial_message))
                .unwrap_or("INVALID TIMESTAMP".to_string())
                .into(),
            referenced_message: if let Some(referenced_message) =
                &partial_message.referenced_message
            {
                ReferencedMessageSlint::from_partial(
                    referenced_message,
                    guild_member,
                    referenced_member,
                    guild_id,
                    markdown_parser,
                )
                .await?
            } else {
                ReferencedMessageSlint::default()
            },
            edited_timestamp: partial_message
                .edited_timestamp
                .as_ref()
                .map(|t| t.to_string(partial_message))
                .unwrap_or_default()
                .into(),
            image_attachments: VecModel::from_slice(&image_attachments),
            ..Default::default()
        };
        Ok(s)
    }
}

impl ReferencedMessageSlint {
    pub async fn from_partial(
        partial_message: &PartialMessage,
        guild_member: Option<&PartialMember>,
        referenced_member: Option<&PartialMember>,
        guild_id: Option<&Snowflake>,
        markdown_parser: &DiscordMarkdownParser,
    ) -> anyhow::Result<Self> {
        let Some(author) = partial_message.author.as_ref() else {
            bail!("PartialMessage is missing author");
        };

        let content = partial_message
            .content
            .as_ref()
            .cloned()
            .unwrap_or_default().replace("\n", " ");

        let s = Self {
            content: utils::parse_markdown_to_slint(
                content,
                markdown_parser,
            )
            .await?,
            author: MessageAuthorSlint::from_partial_message(
                partial_message,
                referenced_member,
                guild_id,
            )?,
            channel_id: partial_message.channel_id.get_description().into(),
            guild_id: partial_message
                .guild_id
                .map(|id| id.get_description().into())
                .unwrap_or_default(),
            id: partial_message.id.get_description().into(),
            timestamp: partial_message
                .timestamp
                .as_ref()
                .map(|t| t.to_string(partial_message))
                .unwrap_or("INVALID TIMESTAMP".to_string())
                .into(),
            ..Default::default()
        };
        Ok(s)
    }
}

impl From<DiscordMessageKind> for DiscordMessageKindSlint {
    fn from(value: DiscordMessageKind) -> Self {
        unsafe { std::mem::transmute::<DiscordMessageKind, DiscordMessageKindSlint>(value) }
    }
    // match value {
    //     DiscordMessageKind::Default => {
    //         DiscordMessageKindSlint::Default
    //     },                                 // 0
    //     DiscordMessageKind::RecipientAdd => {
    //         DiscordMessageKindSlint::RecipientAdd
    //     },                            // 1
    //     DiscordMessageKind::RecipientRemove => {
    //         DiscordMessageKindSlint::RecipientRemove
    //     },                         // 2
    //     DiscordMessageKind::Call => {
    //         DiscordMessageKindSlint::Call
    //     },                                    // 3
    //     DiscordMessageKind::ChannelNameChange => {
    //         DiscordMessageKindSlint::ChannelNameChange
    //     },                       // 4
    //     DiscordMessageKind::ChannelIconChange => {
    //         DiscordMessageKindSlint::ChannelIconChange
    //     },                       // 5
    //     DiscordMessageKind::ChannelPinnedMessage => {
    //         DiscordMessageKindSlint::ChannelPinnedMessage
    //     },                    // 6
    //     DiscordMessageKind::GuildMemberJoin => {
    //         DiscordMessageKindSlint::GuildMemberJoin
    //     },                         // 7
    //     DiscordMessageKind::UserPremiumGuildSubscription => {
    //         DiscordMessageKindSlint::UserPremiumGuildSubscription
    //     },            // 8
    //     DiscordMessageKind::UserPremiumGuildSubscriptionTier1 => {
    //         DiscordMessageKindSlint::UserPremiumGuildSubscriptionTier1
    //     },       // 9
    //     DiscordMessageKind::UserPremiumGuildSubscriptionTier2 => {
    //         DiscordMessageKindSlint::UserPremiumGuildSubscriptionTier2
    //     },       // 10
    //     DiscordMessageKind::UserPremiumGuildSubscriptionTier3 => {
    //         DiscordMessageKindSlint::UserPremiumGuildSubscriptionTier3
    //     },       // 11
    //     DiscordMessageKind::ChannelFollowAdd => {
    //         DiscordMessageKindSlint::ChannelFollowAdd
    //     },                        // 12
    //     DiscordMessageKind::GuildDiscoveryDisqualified => {
    //         DiscordMessageKindSlint::GuildDiscoveryDisqualified
    //     },              // 14
    //     DiscordMessageKind::GuildDiscoveryRequalified => {
    //         DiscordMessageKindSlint::GuildDiscoveryRequalified
    //     },               // 15
    //     DiscordMessageKind::GuildDiscoveryGracePeriodInitialWarning => {
    //         DiscordMessageKindSlint::GuildDiscoveryGracePeriodInitialWarning
    //     }, // 16
    //     DiscordMessageKind::GuildDiscoveryGracePeriodFinalWarning => {
    //         DiscordMessageKindSlint::GuildDiscoveryGracePeriodFinalWarning
    //     },   // 17
    //     DiscordMessageKind::ThreadCreated => {
    //         DiscordMessageKindSlint::ThreadCreated
    //     },                           // 18
    //     DiscordMessageKind::Reply => {
    //         DiscordMessageKindSlint::Reply
    //     },                                   // 19
    //     DiscordMessageKind::ChatInputCommand => {
    //         DiscordMessageKindSlint::ChatInputCommand
    //     },                        // 20
    //     DiscordMessageKind::ThreadStarterMessage => {
    //         DiscordMessageKindSlint::ThreadStarterMessage
    //     },                    // 21
    //     DiscordMessageKind::GuildInviteReminder => {
    //         DiscordMessageKindSlint::GuildInviteReminder
    //     },                     // 22
    //     DiscordMessageKind::ContextMenuCommand => {
    //         DiscordMessageKindSlint::ContextMenuCommand
    //     },                      // 23
    //     DiscordMessageKind::AutoModerationAction => {
    //         DiscordMessageKindSlint::AutoModerationAction
    //     },                    // 24
    //     DiscordMessageKind::RoleSubscriptionPurchase => {
    //         DiscordMessageKindSlint::RoleSubscriptionPurchase
    //     },                // 25
    //     DiscordMessageKind::InteractionPremiumUpsell => {
    //         DiscordMessageKindSlint::InteractionPremiumUpsell
    //     },                // 26
    //     DiscordMessageKind::StageStart => {
    //         DiscordMessageKindSlint::StageStart
    //     },                              // 27
    //     DiscordMessageKind::StageEnd => {
    //         DiscordMessageKindSlint::StageEnd
    //     },                                // 28
    //     DiscordMessageKind::StageSpeaker => {
    //         DiscordMessageKindSlint::StageSpeaker
    //     },                            // 29
    //     DiscordMessageKind::StageRaiseHand => {
    //         DiscordMessageKindSlint::StageRaiseHand
    //     },                          // 30
    //     DiscordMessageKind::StageTopic => {
    //         DiscordMessageKindSlint::StageTopic
    //     },                              // 31
    //     DiscordMessageKind::GuildApplicationPremiumSubscription => {
    //         DiscordMessageKindSlint::GuildApplicationPremiumSubscription
    //     },     // 32
    //     DiscordMessageKind::PremiumReferral => {
    //         DiscordMessageKindSlint::PremiumReferral
    //     },                         // 35
    //     DiscordMessageKind::GuildIncidentAlertModeEnabled => {
    //         DiscordMessageKindSlint::GuildIncidentAlertModeEnabled
    //     },           // 36
    //     DiscordMessageKind::GuildIncidentAlertModeDisabled => {
    //         DiscordMessageKindSlint::GuildIncidentAlertModeDisabled
    //     },          // 37
    //     DiscordMessageKind::GuildIncidentReportRaid => {
    //         DiscordMessageKindSlint::GuildIncidentReportRaid
    //     },                 // 38
    //     DiscordMessageKind::GuildIncidentReportFalseAlarm => {
    //         DiscordMessageKindSlint::GuildIncidentReportFalseAlarm
    //     },           // 39
    //     DiscordMessageKind::GuildDeadchatRevivePrompt => {
    //         DiscordMessageKindSlint::GuildDeadchatRevivePrompt
    //     },               // 40
    //     DiscordMessageKind::CustomGift => {
    //         DiscordMessageKindSlint::CustomGift
    //     },                              // 41
    //     DiscordMessageKind::GuildGamingStatsPrompt => {
    //         DiscordMessageKindSlint::GuildGamingStatsPrompt
    //     },                  // 42
    //     DiscordMessageKind::PurchaseNotification => {
    //         DiscordMessageKindSlint::PurchaseNotification
    //     },                    // 44
    //     DiscordMessageKind::PollResult => {
    //         DiscordMessageKindSlint::PollResult
    //     },                              // 46
    //     DiscordMessageKind::Changelog => {
    //         DiscordMessageKindSlint::Changelog
    //     },                               // 47
    //     DiscordMessageKind::NitroNotification => {
    //         DiscordMessageKindSlint::NitroNotification
    //     },                       // 48
    //     DiscordMessageKind::ChannelLinkedToLobby => {
    //         DiscordMessageKindSlint::ChannelLinkedToLobby
    //     },                    // 49
    //     DiscordMessageKind::GiftingPrompt => {
    //         DiscordMessageKindSlint::GiftingPrompt
    //     },                           // 50
    //     DiscordMessageKind::InGameMessageNux => {
    //         DiscordMessageKindSlint::InGameMessageNux
    //     },                        // 51
    //     DiscordMessageKind::GuildJoinRequestAcceptNotification => {
    //         DiscordMessageKindSlint::GuildJoinRequestAcceptNotification
    //     },      // 52
    //     DiscordMessageKind::GuildJoinRequestRejectNotification => {
    //         DiscordMessageKindSlint::GuildJoinRequestRejectNotification
    //     },      // 53
    //     DiscordMessageKind::GuildJoinRequestWithdrawnNotification => {
    //         DiscordMessageKindSlint::GuildJoinRequestWithdrawnNotification
    //     },   // 54
    //     DiscordMessageKind::HdStreamingUpgraded => {
    //         DiscordMessageKindSlint::HdStreamingUpgraded
    //     },                     // 55
    //     DiscordMessageKind::ReportToModDeletedMessage => {
    //         DiscordMessageKindSlint::ReportToModDeletedMessage
    //     },               // 58
    //     DiscordMessageKind::ReportToModTimeoutUser => {
    //         DiscordMessageKindSlint::ReportToModTimeoutUser
    //     },                  // 59
    //     DiscordMessageKind::ReportToModKickUser => {
    //         DiscordMessageKindSlint::ReportToModKickUser
    //     },                     // 60
    //     DiscordMessageKind::ReportToModBanUser => {
    //         DiscordMessageKindSlint::ReportToModBanUser
    //     },                      // 61
    //     DiscordMessageKind::ReportToModClosedReport => {
    //         DiscordMessageKindSlint::ReportToModClosedReport
    //     },                 // 62
    //     DiscordMessageKind::EmojiAdded => {
    //         DiscordMessageKindSlint::EmojiAdded
    //     },                              // 63
}

unsafe impl Send for DiscordMessageSlint {}
unsafe impl Sync for DiscordMessageSlint {}

unsafe impl Send for MessageAuthorSlint {}
unsafe impl Sync for MessageAuthorSlint {}

unsafe impl Send for ReferencedMessageSlint {}
unsafe impl Sync for ReferencedMessageSlint {}
