import PaicordLib

class BridgedDiscordChannel {
    var channel: DiscordChannel

    init(channel: DiscordChannel) {
        self.channel = channel
    }

    func get_id() -> UInt64 {
        return UInt64(self.channel.id.rawValue) ?? 0
    }

    func has_guild_id() -> Bool {
        return self.channel.guild_id != nil
    }

    func get_guild_id() -> SnowflakeRust {
        return SnowflakeRust(inner: UInt64(self.channel.guild_id!.rawValue) ?? 0)
    }

    func get_type() -> DiscordChannelKindRust {
        if let kind = self.channel.type {
            switch kind {
            case .guildText:
                return .GuildText
            case .dm:
                return .Dm
            case .guildVoice:
                return .GuildVoice
            case .groupDm:
                return .GroupDm
            case .guildCategory:
                return .GuildCategory
            case .guildAnnouncement:
                return .GuildAnnouncement
            case .guildStore:
                return .GuildStore
            case .announcementThread:
                return .AnnouncementThread
            case .publicThread:
                return .PublicThread
            case .privateThread:
                return .PrivateThread
            case .guildStageVoice:
                return .GuildStageVoice
            case .guildDirectory:
                return .GuildDirectory
            case .guildForum:
                return .GuildForum
            case .guildMedia:
                return .GuildMedia
            case .__undocumented(_):
                return .Undocumented
            }
        } else {
            return .Undocumented
        }
    }

    func get_name() -> Optional<String> {
        return self.channel.name
    }

    func get_topic() -> Optional<String> {
        return self.channel.topic
    }

    func get_parent_id() -> Optional<UInt64> {
        if let parent_id = self.channel.parent_id {
            return UInt64(parent_id.rawValue)
        } else {
            return nil
        }
    }

    func get_position() -> Optional<Int32> {
        if let position = self.channel.position {
            return Int32(position)
        } else {
            return nil
        }
    }
}

class BridgedPartialMessage {
    var message: DiscordChannel.PartialMessage

    init(message: DiscordChannel.PartialMessage) {
        self.message = message
    }

    func get_kind() -> DiscordMessageKindRust {
        if let kind: DiscordChannel.Message.Kind = self.message.type {
            switch kind {
                case .`default`:  // 0
                    return .Default
                case .recipientAdd:  // 1
                    return .RecipientAdd
                case .recipientRemove:  // 2
                    return .RecipientRemove
                case .call:  // 3
                    return .Call
                case .channelNameChange:  // 4
                    return .ChannelNameChange
                case .channelIconChange:  // 5
                    return .ChannelIconChange
                case .channelPinnedMessage:  // 6
                    return .ChannelPinnedMessage
                case .guildMemberJoin:  // 7
                    return .GuildMemberJoin
                case .userPremiumGuildSubscription:  // 8
                    return .UserPremiumGuildSubscription
                case .userPremiumGuildSubscriptionTier1:  // 9
                    return .UserPremiumGuildSubscriptionTier1
                case .userPremiumGuildSubscriptionTier2:  // 10
                    return .UserPremiumGuildSubscriptionTier2
                case .userPremiumGuildSubscriptionTier3:  // 11
                    return .UserPremiumGuildSubscriptionTier3
                case .channelFollowAdd:  // 12
                    return .ChannelFollowAdd
                case .guildDiscoveryDisqualified:  // 14
                    return .GuildDiscoveryDisqualified
                case .guildDiscoveryRequalified:  // 15
                    return .GuildDiscoveryRequalified
                case .guildDiscoveryGracePeriodInitialWarning:  // 16
                    return .GuildDiscoveryGracePeriodInitialWarning
                case .guildDiscoveryGracePeriodFinalWarning:  // 17
                    return .GuildDiscoveryGracePeriodFinalWarning
                case .threadCreated:  // 18
                    return .ThreadCreated
                case .reply:  // 19
                    return .Reply
                case .chatInputCommand:  // 20
                    return .ChatInputCommand
                case .threadStarterMessage:  // 21
                    return .ThreadStarterMessage
                case .guildInviteReminder:  // 22
                    return .GuildInviteReminder
                case .contextMenuCommand:  // 23
                    return .ContextMenuCommand
                case .autoModerationAction:  // 24
                    return .AutoModerationAction
                case .roleSubscriptionPurchase:  // 25
                    return .RoleSubscriptionPurchase
                case .interactionPremiumUpsell:  // 26
                    return .InteractionPremiumUpsell
                case .stageStart:  // 27
                    return .StageStart
                case .stageEnd:  // 28
                    return .StageEnd
                case .stageSpeaker:  // 29
                    return .StageSpeaker
                case .stageRaiseHand:  // 30
                    return .StageRaiseHand
                case .stageTopic:  // 31
                    return .StageTopic
                case .guildApplicationPremiumSubscription:  // 32
                    return .GuildApplicationPremiumSubscription
                case .premiumReferral:  // 35
                    return .PremiumReferral
                case .guildIncidentAlertModeEnabled:  // 36
                    return .GuildIncidentAlertModeEnabled
                case .guildIncidentAlertModeDisabled:  // 37
                    return .GuildIncidentAlertModeDisabled
                case .guildIncidentReportRaid:  // 38
                    return .GuildIncidentReportRaid
                case .guildIncidentReportFalseAlarm:  // 39
                    return .GuildIncidentReportFalseAlarm
                case .guildDeadchatRevivePrompt:  // 40
                    return .GuildDeadchatRevivePrompt
                case .customGift:  // 41
                    return .CustomGift
                case .guildGamingStatsPrompt:  // 42
                    return .GuildGamingStatsPrompt
                case .purchaseNotification:  // 44
                    return .PurchaseNotification
                case .pollResult:  // 46
                    return .PollResult
                case .changelog:  // 47
                    return .Changelog
                case .nitroNotification:  // 48
                    return .NitroNotification
                case .channelLinkedToLobby:  // 49
                    return .ChannelLinkedToLobby
                case .giftingPrompt:  // 50
                    return .GiftingPrompt
                case .inGameMessageNux:  // 51
                    return .InGameMessageNux
                case .guildJoinRequestAcceptNotification:  // 52
                    return .GuildJoinRequestAcceptNotification
                case .guildJoinRequestRejectNotification:  // 53
                    return .GuildJoinRequestRejectNotification
                case .guildJoinRequestWithdrawnNotification:  // 54
                    return .GuildJoinRequestWithdrawnNotification
                case .hdStreamingUpgraded:  // 55
                    return .HdStreamingUpgraded
                case .reportToModDeletedMessage:  // 58
                    return .ReportToModDeletedMessage
                case .reportToModTimeoutUser:  // 59
                    return .ReportToModTimeoutUser
                case .reportToModKickUser:  // 60
                    return .ReportToModKickUser
                case .reportToModBanUser:  // 61
                    return .ReportToModBanUser
                case .reportToModClosedReport:  // 62
                    return .ReportToModClosedReport
                case .emojiAdded:  // 63
                    return .EmojiAdded
                case .__undocumented(_):
                    return .Default
            }
        } else {
            return DiscordMessageKindRust.Default
        }
    }

    func get_id() -> SnowflakeRust {
        return SnowflakeRust(inner: UInt64(self.message.id.rawValue) ?? 0)
    }

    func get_channel_id() -> SnowflakeRust {
        return SnowflakeRust(inner: UInt64(self.message.channel_id.rawValue) ?? 0)
    }

    func has_guild_id() -> Bool {
        return self.message.guild_id != nil
    }

    func get_guild_id() -> SnowflakeRust {
        return SnowflakeRust(inner: UInt64(self.message.guild_id!.rawValue) ?? 0)
    }

    func has_author() -> Bool {
        return self.message.author != nil
    }

    func get_author() -> DiscordUserRust {
        return DiscordUserRust(user: self.message.author!)
    }

    func get_content() -> Optional<String> {
        return self.message.content
    }

    func has_timestamp() -> Bool {
        return self.message.timestamp != nil
    }

    func get_timestamp() -> DiscordTimestampRust {
        return DiscordTimestampRust(timestamp: self.message.timestamp!)
    }

    func has_edited_timestamp() -> Bool {
        return self.message.edited_timestamp != nil
    }

    func get_edited_timestamp() -> DiscordTimestampRust {
        return DiscordTimestampRust(timestamp: self.message.edited_timestamp!)
    }

    func attachment_count() -> Optional<UInt> {
        if let attachments = self.message.attachments {
            return UInt(attachments.count)
        } else {
            return nil
        }
    }

    func get_attachment(index: UInt) -> AttachmentRust {
        return AttachmentRust(attachment: self.message.attachments![Int(index)])
    }

    func has_referenced_message() -> Bool {
        return self.message.referenced_message != nil
    }

    func get_referenced_message() -> BridgedPartialMessage {
        BridgedPartialMessage(message: self.message.referenced_message!.value)
    }

    func has_member() -> Bool {
        return self.message.member != nil
    }

    func get_member() -> BridgedPartialMember {
        BridgedPartialMember(member: self.message.member!)
    }
}

extension AttachmentRust {
    init(attachment: DiscordChannel.Message.Attachment) {
        self.id = SnowflakeRust(inner: UInt64(attachment.id.rawValue) ?? 0)
        self.filename = attachment.filename.intoRustString()
        self.title = attachment.title?.intoRustString() ?? nil
        self.description = attachment.description?.intoRustString() ?? nil
        self.content_type = attachment.content_type?.intoRustString() ?? nil
        self.size = Int32(attachment.size)
        self.url = attachment.url.intoRustString()
        self.proxy_url = attachment.proxy_url.intoRustString()
        self.placeholder = attachment.placeholder?.intoRustString() ?? nil
        self.height = attachment.height.map({ Int32($0) })
        self.width = attachment.width.map({ Int32($0) })
        self.ephemeral = attachment.ephemeral
        self.duration_secs = attachment.duration_secs
        self.waveform = attachment.waveform?.intoRustString() ?? nil
    }
}