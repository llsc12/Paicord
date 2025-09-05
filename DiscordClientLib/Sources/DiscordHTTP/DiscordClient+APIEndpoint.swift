import DiscordModels
import Foundation
import NIOHTTP1

#if compiler(>=5.10)
/// It's safe the way DiscordBM uses it.
nonisolated(unsafe) private let iso8601DateFormatter = ISO8601DateFormatter()
#else
private let iso8601DateFormatter = ISO8601DateFormatter()
#endif

/// MARK: - +APIEndpoint
extension DiscordClient {

    // MARK: Application Commands
    /// https://discord.com/developers/docs/interactions/application-commands

    /// https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands
    @inlinable
    public func listApplicationCommands(
        appId: ApplicationSnowflake? = nil,
        with_localizations: Bool? = nil
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = APIEndpoint.listApplicationCommands(applicationId: try requireAppId(appId))
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("with_localizations", with_localizations.map { "\($0)" })]
            )
        )
    }

    /// https://discord.com/developers/docs/interactions/application-commands#create-global-application-command
    @inlinable
    public func createApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        payload: Payloads.ApplicationCommandCreate
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.createApplicationCommand(applicationId: try requireAppId(appId))
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/application-commands#get-global-application-command
    @inlinable
    public func getApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        commandId: CommandSnowflake
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.getApplicationCommand(
            applicationId: try requireAppId(appId),
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/interactions/application-commands#edit-global-application-command
    @inlinable
    public func updateApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        commandId: CommandSnowflake,
        payload: Payloads.ApplicationCommandEdit
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.updateApplicationCommand(
            applicationId: try requireAppId(appId),
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/application-commands#delete-global-application-command
    @inlinable
    public func deleteApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteApplicationCommand(
            applicationId: try requireAppId(appId),
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/interactions/application-commands#bulk-overwrite-global-application-commands
    @inlinable
    public func bulkSetApplicationCommands(
        appId: ApplicationSnowflake? = nil,
        payload: [Payloads.ApplicationCommandCreate]
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = APIEndpoint.bulkSetApplicationCommands(
            applicationId: try requireAppId(appId)
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/application-commands#get-guild-application-commands
    @inlinable
    public func listGuildApplicationCommands(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        with_localizations: Bool? = nil
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = APIEndpoint.listGuildApplicationCommands(
            applicationId: try requireAppId(appId),
            guildId: guildId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("with_localizations", with_localizations.map { "\($0)" })]
            )
        )
    }

    /// https://discord.com/developers/docs/interactions/application-commands#create-guild-application-command
    @inlinable
    public func createGuildApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        payload: Payloads.ApplicationCommandCreate
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.createGuildApplicationCommand(
            applicationId: try requireAppId(appId),
            guildId: guildId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/application-commands#get-guild-application-command
    @inlinable
    public func getGuildApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.getGuildApplicationCommand(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/interactions/application-commands#edit-guild-application-command
    @inlinable
    public func updateGuildApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake,
        payload: Payloads.ApplicationCommandEdit
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.updateGuildApplicationCommand(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/application-commands#delete-guild-application-command
    @inlinable
    public func deleteGuildApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildApplicationCommand(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/interactions/application-commands#bulk-overwrite-guild-application-commands
    @inlinable
    public func bulkSetGuildApplicationCommands(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        payload: [Payloads.ApplicationCommandCreate]
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = APIEndpoint.bulkSetGuildApplicationCommands(
            applicationId: try requireAppId(appId),
            guildId: guildId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/application-commands#get-application-command-permissions
    @inlinable
    public func listGuildApplicationCommandPermissions(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[GuildApplicationCommandPermissions]> {
        let endpoint = APIEndpoint.listGuildApplicationCommandPermissions(
            applicationId: try requireAppId(appId),
            guildId: guildId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/interactions/application-commands#edit-application-command-permissions
    @inlinable
    public func getGuildApplicationCommandPermissions(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordClientResponse<GuildApplicationCommandPermissions> {
        let endpoint = APIEndpoint.getGuildApplicationCommandPermissions(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// This endpoint requires a `DiscordClient` with an OAuth token.
    /// By default the authentication method is by a bot token, and not an OAuth one.
    /// https://discord.com/developers/docs/interactions/application-commands#batch-edit-application-command-permissions
    @inlinable
    public func setGuildApplicationCommandPermissions(
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake,
        payload: Payloads.EditApplicationCommandPermissions
    ) async throws -> DiscordClientResponse<GuildApplicationCommandPermissions> {
        let endpoint = APIEndpoint.setGuildApplicationCommandPermissions(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }

    // MARK: Application Role Connection Metadata
    /// https://discord.com/developers/docs/resources/application-role-connection-metadata

    /// https://discord.com/developers/docs/resources/application-role-connection-metadata#get-application-role-connection-metadata-records
    @inlinable
    public func listApplicationRoleConnectionMetadata(
        appId: ApplicationSnowflake? = nil
    ) async throws -> DiscordClientResponse<[ApplicationRoleConnectionMetadata]> {
        let endpoint = APIEndpoint.listApplicationRoleConnectionMetadata(
            applicationId: try requireAppId(appId)
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// Note: At the time of writing this, Discord docs mistakenly don't mention that
    /// this endpoint takes a payload of type `[ApplicationRoleConnectionMetadata]`.
    /// https://discord.com/developers/docs/resources/application-role-connection-metadata#update-application-role-connection-metadata-records
    @inlinable
    public func bulkOverwriteApplicationRoleConnectionMetadata(
        appId: ApplicationSnowflake? = nil,
        payload: [ApplicationRoleConnectionMetadata]
    ) async throws -> DiscordClientResponse<[ApplicationRoleConnectionMetadata]> {
        let endpoint = APIEndpoint.bulkOverwriteApplicationRoleConnectionMetadata(
            applicationId: try requireAppId(appId)
        )
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    // MARK: Audit Logs
    /// https://discord.com/developers/docs/resources/audit-log

    /// NOTE: `limit`, if provided, must be between `1` and `1_000`.
    /// https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log
    @inlinable
    public func listGuildAuditLogEntries(
        guildId: GuildSnowflake,
        userId: UserSnowflake? = nil,
        action_type: AuditLog.Entry.ActionKind? = nil,
        before: AuditLogEntrySnowflake? = nil,
        after: AuditLogEntrySnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<AuditLog> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = APIEndpoint.listGuildAuditLogEntries(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("user_id", userId?.rawValue),
                    ("action_type", action_type.map { "\($0.rawValue)" }),
                    ("before", before?.rawValue),
                    ("after", after?.rawValue),
                    ("limit", limit.map { "\($0)" }),
                ]
            )
        )
    }

    // MARK: Auto Moderation
    /// https://discord.com/developers/docs/resources/auto-moderation

    /// https://discord.com/developers/docs/resources/auto-moderation#list-auto-moderation-rules-for-guild
    @inlinable
    public func listAutoModerationRules(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[AutoModerationRule]> {
        let endpoint = APIEndpoint.listAutoModerationRules(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/auto-moderation#get-auto-moderation-rule
    @inlinable
    public func getAutoModerationRule(
        guildId: GuildSnowflake,
        ruleId: RuleSnowflake
    ) async throws -> DiscordClientResponse<AutoModerationRule> {
        let endpoint = APIEndpoint.getAutoModerationRule(guildId: guildId, ruleId: ruleId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/auto-moderation#create-auto-moderation-rule
    @inlinable
    public func createAutoModerationRule(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateAutoModerationRule
    ) async throws -> DiscordClientResponse<AutoModerationRule> {
        let endpoint = APIEndpoint.createAutoModerationRule(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/auto-moderation#modify-auto-moderation-rule
    @inlinable
    public func updateAutoModerationRule(
        guildId: GuildSnowflake,
        ruleId: RuleSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyAutoModerationRule
    ) async throws -> DiscordClientResponse<AutoModerationRule> {
        let endpoint = APIEndpoint.updateAutoModerationRule(guildId: guildId, ruleId: ruleId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/auto-moderation#delete-auto-moderation-rule
    @inlinable
    public func deleteAutoModerationRule(
        guildId: GuildSnowflake,
        ruleId: RuleSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteAutoModerationRule(guildId: guildId, ruleId: ruleId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    // MARK: Channels
    /// https://discord.com/developers/docs/resources/channel

    /// https://discord.com/developers/docs/resources/channel#get-channel
    @inlinable
    public func getChannel(
        id: ChannelSnowflake
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.getChannel(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// This endpoint doesn't have a test since we can't create group DMs easily,
    /// but still should work fine if you actually needed it, because there are two similar
    /// functions down below for updating other types of channels, and those do have tests.
    /// https://discord.com/developers/docs/resources/channel#modify-channel
    @inlinable
    public func updateGroupDMChannel(
        id: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGroupDMChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.updateChannel(channelId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#modify-channel
    @inlinable
    public func updateGuildChannel(
        id: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGuildChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.updateChannel(channelId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#modify-channel
    @inlinable
    public func updateThreadChannel(
        id: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyThreadChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.updateChannel(channelId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#deleteclose-channel
    @inlinable
    public func deleteChannel(
        id: ChannelSnowflake,
        reason: String? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.deleteChannel(channelId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// NOTE: `around`, `before` and `after` are mutually exclusive.
    /// https://discord.com/developers/docs/resources/channel#get-channel-messages
    @inlinable
    public func listMessages(
        channelId: ChannelSnowflake,
        around: MessageSnowflake? = nil,
        before: MessageSnowflake? = nil,
        after: MessageSnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[DiscordChannel.Message]> {
        try checkMutuallyExclusive(queries: [
            ("around", around?.rawValue),
            ("before", before?.rawValue),
            ("after", after?.rawValue),
        ])
        let endpoint = APIEndpoint.listMessages(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("around", around?.rawValue),
                    ("before", before?.rawValue),
                    ("after", after?.rawValue),
                    ("limit", limit.map({ "\($0)" })),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#get-channel-message
    @inlinable
    public func getMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getMessage(
            channelId: channelId,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#create-message
    @inlinable
    public func createMessage(
        channelId: ChannelSnowflake,
        payload: Payloads.CreateMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.createMessage(channelId: channelId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/resources/channel#crosspost-message
    @inlinable
    public func crosspostMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.crosspostMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#create-reaction
    @inlinable
    public func addMessageReaction(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addMessageReaction(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#delete-own-reaction
    @inlinable
    public func deleteOwnMessageReaction(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteOwnMessageReaction(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#delete-user-reaction
    @inlinable
    public func deleteUserMessageReaction(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emoji: Reaction,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteUserMessageReaction(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription,
            userId: userId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#get-reactions
    @inlinable
    public func listMessageReactionsByEmoji(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emoji: Reaction,
        type: Gateway.ReactionKind? = nil,
        after: UserSnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[DiscordUser]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 100)
        let endpoint = APIEndpoint.listMessageReactionsByEmoji(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("type", type.map({ "\($0.rawValue)" })),
                    ("after", after?.rawValue),
                    ("limit", limit.map({ "\($0)" })),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#delete-all-reactions
    @inlinable
    public func deleteAllMessageReactions(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteAllMessageReactions(
            channelId: channelId,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#delete-all-reactions-for-emoji
    @inlinable
    public func deleteAllMessageReactionsByEmoji(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteAllMessageReactionsByEmoji(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#edit-message
    @inlinable
    public func updateMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        payload: Payloads.EditMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.updateMessage(channelId: channelId, messageId: messageId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/resources/channel#delete-message
    @inlinable
    public func deleteMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteMessage(channelId: channelId, messageId: messageId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#bulk-delete-messages
    @inlinable
    public func bulkDeleteMessages(
        channelId: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.BulkDeleteMessages
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.bulkDeleteMessages(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#edit-channel-permissions
    @inlinable
    public func setChannelPermissionOverwrite(
        channelId: ChannelSnowflake,
        overwriteId: AnySnowflake,
        reason: String? = nil,
        payload: Payloads.EditChannelPermissions
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.setChannelPermissionOverwrite(
            channelId: channelId,
            overwriteId: overwriteId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#get-channel-invites
    @inlinable
    public func listChannelInvites(
        channelId: ChannelSnowflake
    ) async throws -> DiscordClientResponse<[InviteWithMetadata]> {
        let endpoint = APIEndpoint.listChannelInvites(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#create-channel-invite
    @inlinable
    public func createChannelInvite(
        channelId: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateChannelInvite
    ) async throws -> DiscordClientResponse<Invite> {
        let endpoint = APIEndpoint.createChannelInvite(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#delete-channel-permission
    @inlinable
    public func deleteChannelPermissionOverwrite(
        channelId: ChannelSnowflake,
        overwriteId: AnySnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteChannelPermissionOverwrite(
            channelId: channelId,
            overwriteId: overwriteId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#follow-announcement-channel
    @inlinable
    public func followAnnouncementChannel(
        id: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.FollowAnnouncementChannel
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.followAnnouncementChannel(channelId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#trigger-typing-indicator
    @inlinable
    public func triggerTypingIndicator(channelId: ChannelSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.triggerTypingIndicator(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#get-pinned-messages
    @inlinable
    public func listPinnedMessages(
        channelId: ChannelSnowflake
    ) async throws -> DiscordClientResponse<[DiscordChannel.Message]> {
        let endpoint = APIEndpoint.listPinnedMessages(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#pin-message
    @inlinable
    public func pinMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.pinMessage(channelId: channelId, messageId: messageId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#unpin-message
    @inlinable
    public func unpinMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.unpinMessage(channelId: channelId, messageId: messageId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#group-dm-add-recipient
    @inlinable
    public func addGroupDmUser(
        channelId: ChannelSnowflake,
        userId: UserSnowflake,
        payload: Payloads.AddGroupDMUser
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addGroupDmUser(channelId: channelId, userId: userId)
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#group-dm-remove-recipient
    @inlinable
    public func deleteGroupDmUser(
        channelId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGroupDmUser(channelId: channelId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: Threads
    /// https://discord.com/developers/docs/resources/channel#start-thread-from-message

    /// https://discord.com/developers/docs/resources/channel#start-thread-from-message
    @inlinable
    public func createThreadFromMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateThreadFromMessage
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createThreadFromMessage(channelId: channelId, messageId: messageId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#start-thread-without-message
    @inlinable
    public func createThread(
        channelId: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateThreadWithoutMessage
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createThread(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#start-thread-in-forum-or-media-channel
    @available(*, deprecated, renamed: "startThreadInForumOrMediaChannel(channelId:reason:payload:)")
    @inlinable
    public func startThreadInForumChannel(
        channelId: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateThreadInForumChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createThreadInForumChannel(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#start-thread-in-forum-or-media-channel
    @inlinable
    public func startThreadInForumOrMediaChannel(
        channelId: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateThreadInForumChannel
    ) async throws -> DiscordClientResponse<Responses.ChannelWithMessage> {
        let endpoint = APIEndpoint.createThreadInForumChannel(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#join-thread
    @inlinable
    public func joinThread(id: ChannelSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.joinThread(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#add-thread-member
    @inlinable
    public func addThreadMember(
        threadId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#leave-thread
    @inlinable
    public func leaveThread(id: ChannelSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveThread(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#remove-thread-member
    @inlinable
    public func deleteThreadMember(
        threadId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    public func getThreadMember(
        threadId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordClientResponse<ThreadMember> {
        let endpoint = APIEndpoint.getThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    public func getThreadMemberWithMember(
        threadId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordClientResponse<ThreadMemberWithMember> {
        let endpoint = APIEndpoint.getThreadMember(channelId: threadId, userId: userId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("with_member", "true")]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#list-thread-members
    @inlinable
    public func listThreadMembers(
        threadId: ChannelSnowflake
    ) async throws -> DiscordClientResponse<[ThreadMember]> {
        let endpoint = APIEndpoint.listThreadMembers(channelId: threadId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#list-thread-members
    @inlinable
    public func listThreadMembersWithMember(
        threadId: ChannelSnowflake,
        after: UserSnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[ThreadMemberWithMember]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 100)
        let endpoint = APIEndpoint.listThreadMembers(channelId: threadId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("with_member", "true"),
                    ("after", after?.rawValue),
                    ("limit", limit.map({ "\($0)" })),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#list-public-archived-threads
    public func listPublicArchivedThreads(
        channelId: ChannelSnowflake,
        before: Date? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<Responses.ListArchivedThreads> {
        /// Not documented, but correct, at least at the time of writing the code.
        try checkInBounds(name: "limit", value: limit, lowerBound: 2, upperBound: 100)
        let endpoint = APIEndpoint.listPublicArchivedThreads(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("before", before.map(iso8601DateFormatter.string(from:))),
                    ("limit", limit.map({ "\($0)" })),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#list-private-archived-threads
    public func listPrivateArchivedThreads(
        channelId: ChannelSnowflake,
        before: Date? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<Responses.ListArchivedThreads> {
        /// Not documented, but correct, at least at the time of writing the code.
        try checkInBounds(name: "limit", value: limit, lowerBound: 2, upperBound: 100)
        let endpoint = APIEndpoint.listPrivateArchivedThreads(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("before", before.map(iso8601DateFormatter.string(from:))),
                    ("limit", limit.map({ "\($0)" })),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/channel#list-joined-private-archived-threads
    @inlinable
    public func listOwnPrivateArchivedThreads(
        channelId: ChannelSnowflake,
        before: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<Responses.ListArchivedThreads> {
        /// Not documented, but correct, at least at the time of writing the code.
        try checkInBounds(name: "limit", value: limit, lowerBound: 2, upperBound: 100)
        let endpoint = APIEndpoint.listOwnPrivateArchivedThreads(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("before", before),
                    ("limit", limit.map({ "\($0)" })),
                ]
            )
        )
    }

    // MARK: Emojis
    /// https://discord.com/developers/docs/resources/emoji

    /// https://discord.com/developers/docs/resources/emoji#list-guild-emojis
    @inlinable
    public func listGuildEmojis(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[Emoji]> {
        let endpoint = APIEndpoint.listGuildEmojis(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/emoji#get-guild-emoji
    @inlinable
    public func getGuildEmoji(
        guildId: GuildSnowflake,
        emojiId: EmojiSnowflake
    ) async throws -> DiscordClientResponse<Emoji> {
        let endpoint = APIEndpoint.getGuildEmoji(guildId: guildId, emojiId: emojiId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/emoji#create-guild-emoji
    @inlinable
    public func createGuildEmoji(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateGuildEmoji
    ) async throws -> DiscordClientResponse<Emoji> {
        let endpoint = APIEndpoint.createGuildEmoji(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/emoji#create-guild-emoji
    @inlinable
    public func updateGuildEmoji(
        guildId: GuildSnowflake,
        emojiId: EmojiSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGuildEmoji
    ) async throws -> DiscordClientResponse<Emoji> {
        let endpoint = APIEndpoint.updateGuildEmoji(guildId: guildId, emojiId: emojiId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/emoji#delete-guild-emoji
    @inlinable
    public func deleteGuildEmoji(
        guildId: GuildSnowflake,
        emojiId: EmojiSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildEmoji(guildId: guildId, emojiId: emojiId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    // MARK: Entitlements
    /// https://discord.com/developers/docs/monetization/entitlements

    /// https://discord.com/developers/docs/monetization/entitlements#list-entitlements
    @inlinable
    public func listEntitlements(
        appId: ApplicationSnowflake? = nil,
        userId: UserSnowflake? = nil,
        skuIds: [SKUSnowflake]? = nil,
        before: EntitlementSnowflake? = nil,
        after: EntitlementSnowflake? = nil,
        limit: Int? = nil,
        guildId: GuildSnowflake? = nil,
        excludeEnded: Bool? = nil
    ) async throws -> DiscordClientResponse<[Entitlement]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 100)
        try checkMutuallyExclusive(queries: [
            ("before", before?.rawValue),
            ("after", after?.rawValue),
        ])
        let endpoint = APIEndpoint.listEntitlements(applicationId: try requireAppId(appId))
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("user_id", userId?.rawValue),
                    ("sku_ids", skuIds?.map(\.rawValue).joined(separator: ",")),
                    ("before", before?.rawValue),
                    ("after", after?.rawValue),
                    ("limit", limit.map({ "\($0)" })),
                    ("guild_id", guildId?.rawValue),
                    ("exclude_ended", excludeEnded.map({ "\($0)" })),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/monetization/entitlements#consume-an-entitlement
    @inlinable
    public func consumeEntitlement(
        appId: ApplicationSnowflake? = nil,
        entitlementId: EntitlementSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.consumeEntitlement(
            applicationId: try requireAppId(appId),
            entitlementId: entitlementId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/monetization/entitlements#create-test-entitlement
    @inlinable
    public func createTestEntitlement(
        appId: ApplicationSnowflake? = nil,
        payload: Payloads.CreateTestEntitlement
    ) async throws -> DiscordClientResponse<Entitlement> {
        let endpoint = APIEndpoint.createTestEntitlement(applicationId: try requireAppId(appId))
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/monetization/entitlements#delete-test-entitlement
    @inlinable
    public func deleteTestEntitlement(
        appId: ApplicationSnowflake? = nil,
        entitlementId: EntitlementSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteTestEntitlement(
            applicationId: try requireAppId(appId),
            entitlementId: entitlementId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: Guilds
    /// https://discord.com/developers/docs/resources/guild

    /// https://discord.com/developers/docs/resources/guild#create-guild
    @inlinable
    public func createGuild(
        payload: Payloads.CreateGuild
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = APIEndpoint.createGuild
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild
    @inlinable
    public func getGuild(
        id: GuildSnowflake,
        withCounts: Bool? = nil
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = APIEndpoint.getGuild(guildId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("with_counts", withCounts.map { "\($0)" })]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-preview
    @inlinable
    public func getGuildPreview(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<Guild.Preview> {
        let endpoint = APIEndpoint.getGuildPreview(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild
    @inlinable
    public func updateGuild(
        id: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGuild
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = APIEndpoint.updateGuild(guildId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#delete-guild
    @inlinable
    public func deleteGuild(id: GuildSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuild(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-channels
    @inlinable
    public func listGuildChannels(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[DiscordChannel]> {
        let endpoint = APIEndpoint.listGuildChannels(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#create-guild-channel
    @inlinable
    public func createGuildChannel(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateGuildChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createGuildChannel(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild-channel-positions
    @inlinable
    public func updateGuildChannelPositions(
        guildId: GuildSnowflake,
        payload: [Payloads.ModifyGuildChannelPositions]
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildChannelPositions(guildId: guildId)
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#list-active-guild-threads
    @inlinable
    public func listActiveGuildThreads(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<Responses.ListActiveGuildThreads> {
        let endpoint = APIEndpoint.listActiveGuildThreads(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-member
    @inlinable
    public func getGuildMember(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = APIEndpoint.getGuildMember(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#list-guild-members
    @inlinable
    public func listGuildMembers(
        guildId: GuildSnowflake,
        limit: Int? = nil,
        after: UserSnowflake? = nil
    ) async throws -> DiscordClientResponse<[Guild.Member]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = APIEndpoint.listGuildMembers(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("limit", limit?.description),
                    ("after", after.map { $0.rawValue }),
                ]
            )
        )
    }

    /// NOTE: `limit`, if provided, must be between `1` and `1_000`.
    /// https://discord.com/developers/docs/resources/guild#search-guild-members
    @inlinable
    public func searchGuildMembers(
        guildId: GuildSnowflake,
        query: String,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[Guild.Member]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = APIEndpoint.searchGuildMembers(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("query", query),
                    ("limit", limit?.description),
                ]
            )
        )
    }

    /// NOTE: Sometimes doesn't return a guild member object. Read the docs.
    /// https://discord.com/developers/docs/resources/guild#add-guild-member
    @inlinable
    public func addGuildMember(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        payload: Payloads.AddGuildMember
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = APIEndpoint.addGuildMember(guildId: guildId, userId: userId)
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild-member
    @inlinable
    public func updateGuildMember(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGuildMember
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = APIEndpoint.updateGuildMember(guildId: guildId, userId: userId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-current-member
    @inlinable
    public func updateOwnGuildMember(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyCurrentMember
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = APIEndpoint.updateOwnGuildMember(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#add-guild-member-role
    @inlinable
    public func addGuildMemberRole(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        roleId: RoleSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild#remove-guild-member-role
    @inlinable
    public func deleteGuildMemberRole(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        roleId: RoleSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild#remove-guild-member
    @inlinable
    public func deleteGuildMember(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildMember(guildId: guildId, userId: userId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-bans
    @inlinable
    public func listGuildBans(
        guildId: GuildSnowflake,
        limit: Int? = nil,
        before: UserSnowflake? = nil,
        after: UserSnowflake? = nil
    ) async throws -> DiscordClientResponse<[Guild.Ban]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = APIEndpoint.listGuildBans(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("limit", limit.map { "\($0)" }),
                    ("before", before?.rawValue),
                    ("after", after?.rawValue),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-ban
    @inlinable
    public func getGuildBan(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordClientResponse<Guild.Ban> {
        let endpoint = APIEndpoint.getGuildBan(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#create-guild-ban
    @inlinable
    public func banUserFromGuild(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateGuildBan
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.banUserFromGuild(guildId: guildId, userId: userId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#bulk-guild-ban
    @inlinable
    public func bulkBanUsersFromGuild(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateBulkGuildBan
    ) async throws -> DiscordClientResponse<Responses.GuildBulkBan> {
        let endpoint = APIEndpoint.bulkBanUsersFromGuild(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#remove-guild-ban
    @inlinable
    public func unbanUserFromGuild(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.unbanUserFromGuild(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-roles
    @inlinable
    public func listGuildRoles(id: GuildSnowflake) async throws -> DiscordClientResponse<[Role]> {
        let endpoint = APIEndpoint.listGuildRoles(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#create-guild-role
    @inlinable
    public func createGuildRole(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.GuildRole
    ) async throws -> DiscordClientResponse<Role> {
        let endpoint = APIEndpoint.createGuildRole(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild-role-positions
    @inlinable
    public func updateGuildRolePositions(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: [Payloads.ModifyGuildRolePositions]
    ) async throws -> DiscordClientResponse<[Role]> {
        let endpoint = APIEndpoint.updateGuildRolePositions(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    @inlinable
    public func updateGuildRole(
        guildId: GuildSnowflake,
        roleId: RoleSnowflake,
        reason: String? = nil,
        payload: Payloads.GuildRole
    ) async throws -> DiscordClientResponse<Role> {
        let endpoint = APIEndpoint.updateGuildRole(guildId: guildId, roleId: roleId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild-mfa-level
    @inlinable
    public func setGuildMfaLevel(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGuildMFALevel
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.setGuildMfaLevel(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#delete-guild-role
    @inlinable
    public func deleteGuildRole(
        guildId: GuildSnowflake,
        roleId: RoleSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildRole(guildId: guildId, roleId: roleId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// NOTE: `days`, if provided, must be between `1` and `30`.
    /// https://discord.com/developers/docs/resources/guild#get-guild-prune-count
    @inlinable
    public func previewPruneGuild(
        guildId: GuildSnowflake,
        days: Int? = nil,
        includeRoles: [RoleSnowflake]? = nil
    ) async throws -> DiscordClientResponse<Responses.GuildPrune> {
        try checkInBounds(name: "days", value: days, lowerBound: 1, upperBound: 30)
        let endpoint = APIEndpoint.previewPruneGuild(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("days", days.map { "\($0)" }),
                    ("include_roles", includeRoles.map { $0.map(\.rawValue).joined(separator: ",") }),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild#begin-guild-prune
    @inlinable
    public func pruneGuild(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.BeginGuildPrune
    ) async throws -> DiscordClientResponse<Responses.GuildPrune> {
        let endpoint = APIEndpoint.pruneGuild(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-voice-regions
    @inlinable
    public func listGuildVoiceRegions(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[VoiceRegion]> {
        let endpoint = APIEndpoint.listGuildVoiceRegions(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-invites
    @inlinable
    public func listGuildInvites(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[InviteWithMetadata]> {
        let endpoint = APIEndpoint.listGuildInvites(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-integrations
    @inlinable
    public func listGuildIntegrations(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[Integration]> {
        let endpoint = APIEndpoint.listGuildIntegrations(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#delete-guild-integration
    @inlinable
    public func deleteGuildIntegration(
        guildId: GuildSnowflake,
        integrationId: IntegrationSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildIntegration(
            guildId: guildId,
            integrationId: integrationId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-widget-settings
    @inlinable
    public func getGuildWidgetSettings(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<Guild.WidgetSettings> {
        let endpoint = APIEndpoint.getGuildWidgetSettings(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild-widget
    @inlinable
    public func updateGuildWidgetSettings(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyWidgetSettings
    ) async throws -> DiscordClientResponse<Guild.WidgetSettings> {
        let endpoint = APIEndpoint.updateGuildWidgetSettings(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-widget
    @inlinable
    public func getGuildWidget(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<Guild.Widget> {
        let endpoint = APIEndpoint.getGuildWidget(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-vanity-url
    @inlinable
    public func getGuildVanityUrl(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<PartialInvite> {
        let endpoint = APIEndpoint.getGuildVanityUrl(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-widget-image
    @inlinable
    public func getGuildWidgetPng(
        guildId: GuildSnowflake,
        style: Payloads.WidgetStyle? = nil
    ) async throws -> DiscordCDNResponse {
        let endpoint = APIEndpoint.getGuildWidgetPng(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("style", style.map { $0.rawValue })]
            ),
            fallbackFileName: "widget_\((style ?? .default).rawValue)_\(guildId.rawValue)"
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-welcome-screen
    @inlinable
    public func getGuildWelcomeScreen(
        guildId: GuildSnowflake,
        reason: String? = nil
    ) async throws -> DiscordClientResponse<Guild.WelcomeScreen> {
        let endpoint = APIEndpoint.getGuildWelcomeScreen(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild-welcome-screen
    @inlinable
    public func updateGuildWelcomeScreen(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGuildWelcomeScreen
    ) async throws -> DiscordClientResponse<Guild.WelcomeScreen> {
        let endpoint = APIEndpoint.updateGuildWelcomeScreen(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-onboarding
    @inlinable
    public func getGuildOnboarding(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<Guild.Onboarding> {
        let endpoint = APIEndpoint.getGuildOnboarding(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild-onboarding
    @inlinable
    public func updateGuildOnboarding(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.UpdateGuildOnboarding
    ) async throws -> DiscordClientResponse<Guild.Onboarding> {
        let endpoint = APIEndpoint.updateGuildOnboarding(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-current-user-voice-state
    @inlinable
    public func updateSelfVoiceState(
        guildId: GuildSnowflake,
        payload: Payloads.ModifyCurrentUserVoiceState
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateSelfVoiceState(guildId: guildId)
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-user-voice-state
    @inlinable
    public func updateVoiceState(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        payload: Payloads.ModifyUserVoiceState
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateVoiceState(guildId: guildId, userId: userId)
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    // MARK: Guild Scheduled Events
    /// https://discord.com/developers/docs/resources/guild-scheduled-event

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#list-scheduled-events-for-guild
    @inlinable
    public func listGuildScheduledEvents(
        guildId: GuildSnowflake,
        withUserCount: Bool? = nil
    ) async throws -> DiscordClientResponse<[GuildScheduledEvent]> {
        let endpoint = APIEndpoint.listGuildScheduledEvents(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("with_user_count", withUserCount.map { "\($0)" })]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#create-guild-scheduled-event
    @inlinable
    public func createGuildScheduledEvent(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateGuildScheduledEvent
    ) async throws -> DiscordClientResponse<GuildScheduledEvent> {
        let endpoint = APIEndpoint.createGuildScheduledEvent(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#get-guild-scheduled-event
    @inlinable
    public func getGuildScheduledEvent(
        guildId: GuildSnowflake,
        guildScheduledEventId: GuildScheduledEventSnowflake,
        withUserCount: Bool? = nil
    ) async throws -> DiscordClientResponse<GuildScheduledEvent> {
        let endpoint = APIEndpoint.getGuildScheduledEvent(
            guildId: guildId,
            guildScheduledEventId: guildScheduledEventId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("with_user_count", withUserCount.map { "\($0)" })]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#modify-guild-scheduled-event
    @inlinable
    public func updateGuildScheduledEvent(
        guildId: GuildSnowflake,
        guildScheduledEventId: GuildScheduledEventSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateGuildScheduledEvent
    ) async throws -> DiscordClientResponse<GuildScheduledEvent> {
        let endpoint = APIEndpoint.updateGuildScheduledEvent(
            guildId: guildId,
            guildScheduledEventId: guildScheduledEventId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#delete-guild-scheduled-event
    @inlinable
    public func deleteGuildScheduledEvent(
        guildId: GuildSnowflake,
        guildScheduledEventId: GuildScheduledEventSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildScheduledEvent(
            guildId: guildId,
            guildScheduledEventId: guildScheduledEventId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#get-guild-scheduled-event-users
    @inlinable
    public func listGuildScheduledEventUsers(
        guildId: GuildSnowflake,
        guildScheduledEventId: GuildScheduledEventSnowflake,
        limit: Int? = nil,
        withMember: Bool? = nil,
        before: UserSnowflake? = nil,
        after: UserSnowflake? = nil
    ) async throws -> DiscordClientResponse<[GuildScheduledEvent.User]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 100)
        let endpoint = APIEndpoint.listGuildScheduledEventUsers(
            guildId: guildId,
            guildScheduledEventId: guildScheduledEventId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("limit", limit.map { "\($0)" }),
                    ("with_member", withMember.map { "\($0)" }),
                    ("before", before?.rawValue),
                    ("after", after?.rawValue),
                ]
            )
        )
    }

    // MARK: Gateway
    /// https://discord.com/developers/docs/topics/gateway

    /// https://discord.com/developers/docs/topics/gateway#get-gateway
    @inlinable
    public func getGateway() async throws -> DiscordClientResponse<Gateway.URL> {
        let endpoint = APIEndpoint.getGateway
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/topics/gateway#get-gateway-bot
    @inlinable
    public func getBotGateway() async throws -> DiscordClientResponse<Gateway.BotConnectionInfo> {
        let endpoint = APIEndpoint.getBotGateway
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: Guild Templates
    /// https://discord.com/developers/docs/resources/guild-template

    /// https://discord.com/developers/docs/resources/guild-template#get-guild-template
    @inlinable
    public func getGuildTemplate(code: String) async throws -> DiscordClientResponse<GuildTemplate> {
        let endpoint = APIEndpoint.getGuildTemplate(code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild-template#create-guild-from-guild-template
    @inlinable
    public func createGuildFromTemplate(
        code: String,
        payload: Payloads.CreateGuildFromGuildTemplate
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = APIEndpoint.createGuildFromTemplate(code: code)
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild-template#get-guild-templates
    @inlinable
    public func listGuildTemplates(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[GuildTemplate]> {
        let endpoint = APIEndpoint.listGuildTemplates(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild-template#create-guild-template
    @inlinable
    public func createGuildTemplate(
        guildId: GuildSnowflake,
        payload: Payloads.CreateGuildTemplate
    ) async throws -> DiscordClientResponse<GuildTemplate> {
        let endpoint = APIEndpoint.createGuildTemplate(guildId: guildId)
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild-template#sync-guild-template
    @inlinable
    public func syncGuildTemplate(
        guildId: GuildSnowflake,
        code: String
    ) async throws -> DiscordClientResponse<GuildTemplate> {
        let endpoint = APIEndpoint.syncGuildTemplate(guildId: guildId, code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild-template#modify-guild-template
    @inlinable
    public func updateGuildTemplate(
        guildId: GuildSnowflake,
        code: String,
        payload: Payloads.ModifyGuildTemplate
    ) async throws -> DiscordClientResponse<GuildTemplate> {
        let endpoint = APIEndpoint.updateGuildTemplate(guildId: guildId, code: code)
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild-template#delete-guild-template
    @inlinable
    public func deleteGuildTemplate(
        guildId: GuildSnowflake,
        code: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildTemplate(guildId: guildId, code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: Interactions
    /// https://discord.com/developers/docs/interactions/receiving-and-responding

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response
    @inlinable
    public func createInteractionResponse(
        id: InteractionSnowflake,
        token: String,
        payload: Payloads.InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createInteractionResponse(
            interactionId: id,
            interactionToken: token
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#get-original-interaction-response
    @inlinable
    public func getOriginalInteractionResponse(
        appId: ApplicationSnowflake? = nil,
        token: String,
        threadId: ChannelSnowflake? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getOriginalInteractionResponse(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId?.rawValue)]
            )
        )
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-original-interaction-response
    @inlinable
    public func updateOriginalInteractionResponse(
        appId: ApplicationSnowflake? = nil,
        token: String,
        payload: Payloads.EditWebhookMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.updateOriginalInteractionResponse(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#delete-original-interaction-response
    @inlinable
    public func deleteOriginalInteractionResponse(
        appId: ApplicationSnowflake? = nil,
        token: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteOriginalInteractionResponse(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
    @inlinable
    public func createFollowupMessage(
        appId: ApplicationSnowflake? = nil,
        token: String,
        payload: Payloads.ExecuteWebhook
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#get-followup-message
    @inlinable
    public func getFollowupMessage(
        appId: ApplicationSnowflake? = nil,
        token: String,
        messageId: MessageSnowflake,
        threadId: ChannelSnowflake? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token,
            messageId: messageId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId?.rawValue)]
            )
        )
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-followup-message
    @inlinable
    public func updateFollowupMessage(
        appId: ApplicationSnowflake? = nil,
        token: String,
        messageId: MessageSnowflake,
        payload: Payloads.InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token,
            messageId: messageId
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#delete-followup-message
    @inlinable
    public func deleteFollowupMessage(
        appId: ApplicationSnowflake? = nil,
        token: String,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: Invites
    /// https://discord.com/developers/docs/resources/invite

    /// https://discord.com/developers/docs/resources/invite#get-invite
    @inlinable
    public func resolveInvite(
        code: String,
        withCounts: Bool? = nil,
        withExpiration: Bool? = nil,
        guildScheduledEventId: GuildScheduledEventSnowflake? = nil
    ) async throws -> DiscordClientResponse<Invite> {
        let endpoint = APIEndpoint.resolveInvite(code: code)
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("with_counts", withCounts.map { "\($0)" }),
                    ("with_expiration", withExpiration.map { "\($0)" }),
                    ("guild_scheduled_event_id", guildScheduledEventId.map { "\($0.rawValue)" }),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/invite#delete-invite
    @inlinable
    public func revokeInvite(
        code: String,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.revokeInvite(code: code)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    // MARK: OAuth
    /// https://discord.com/developers/docs/topics/oauth2

    /// https://discord.com/developers/docs/topics/oauth2#get-current-bot-application-information
    @inlinable
    public func getOwnOauth2Application() async throws -> DiscordClientResponse<DiscordApplication> {
        let endpoint = APIEndpoint.getOwnOauth2Application
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: SKUs
    /// https://discord.com/developers/docs/monetization/skus

    /// https://discord.com/developers/docs/monetization/skus#list-skus
    @inlinable
    public func listSKUs(
        appId: ApplicationSnowflake? = nil
    ) async throws -> DiscordClientResponse<[SKU]> {
        let endpoint = APIEndpoint.listSkus(applicationId: try requireAppId(appId))
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: Stage Instances
    /// https://discord.com/developers/docs/resources/stage-instance

    /// https://discord.com/developers/docs/resources/stage-instance#create-stage-instance
    @inlinable
    public func createStageInstance(
        reason: String? = nil,
        payload: Payloads.CreateStageInstance
    ) async throws -> DiscordClientResponse<StageInstance> {
        let endpoint = APIEndpoint.createStageInstance
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/stage-instance#get-stage-instance
    @inlinable
    public func getStageInstance(
        channelId: ChannelSnowflake
    ) async throws -> DiscordClientResponse<StageInstance> {
        let endpoint = APIEndpoint.getStageInstance(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/stage-instance#modify-stage-instance
    @inlinable
    public func updateStageInstance(
        channelId: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyStageInstance
    ) async throws -> DiscordClientResponse<StageInstance> {
        let endpoint = APIEndpoint.updateStageInstance(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/stage-instance#delete-stage-instance
    @inlinable
    public func deleteStageInstance(
        channelId: ChannelSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteStageInstance(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    // MARK: Stickers
    /// https://discord.com/developers/docs/resources/sticker

    /// https://discord.com/developers/docs/resources/sticker#get-sticker
    @inlinable
    public func getSticker(id: StickerSnowflake) async throws -> DiscordClientResponse<Sticker> {
        let endpoint = APIEndpoint.getSticker(stickerId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/sticker#list-nitro-sticker-packs
    @inlinable
    public func listStickerPacks() async throws -> DiscordClientResponse<Responses.ListStickerPacks> {
        let endpoint = APIEndpoint.listStickerPacks
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/sticker#list-guild-stickers
    @inlinable
    public func listGuildStickers(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<[Sticker]> {
        let endpoint = APIEndpoint.listGuildStickers(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/sticker#get-guild-sticker
    @inlinable
    public func getGuildSticker(
        guildId: GuildSnowflake,
        stickerId: StickerSnowflake
    ) async throws -> DiscordClientResponse<Sticker> {
        let endpoint = APIEndpoint.getGuildSticker(guildId: guildId, stickerId: stickerId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/sticker#create-guild-sticker
    @inlinable
    public func createGuildSticker(
        guildId: GuildSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateGuildSticker
    ) async throws -> DiscordClientResponse<Sticker> {
        let endpoint = APIEndpoint.createGuildSticker(guildId: guildId)
        return try await self.sendMultipart(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/sticker#modify-guild-sticker
    @inlinable
    public func updateGuildSticker(
        guildId: GuildSnowflake,
        stickerId: StickerSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGuildSticker
    ) async throws -> DiscordClientResponse<Sticker> {
        let endpoint = APIEndpoint.updateGuildSticker(guildId: guildId, stickerId: stickerId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/sticker#delete-guild-sticker
    @inlinable
    public func deleteGuildSticker(
        guildId: GuildSnowflake,
        stickerId: StickerSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildSticker(guildId: guildId, stickerId: stickerId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    // MARK: User
    /// https://discord.com/developers/docs/resources/user

    /// https://discord.com/developers/docs/resources/user#get-current-user
    @inlinable
    public func getOwnUser() async throws -> DiscordClientResponse<DiscordUser> {
        let endpoint = APIEndpoint.getOwnUser
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/topics/oauth2#get-current-application
    @inlinable
    public func getOwnApplication() async throws -> DiscordClientResponse<DiscordApplication> {
        let endpoint = APIEndpoint.getOwnApplication
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/application#edit-current-application
    @inlinable
    public func updateOwnApplication(
        payload: Payloads.UpdateOwnApplication
    ) async throws -> DiscordClientResponse<DiscordApplication> {
        let endpoint = APIEndpoint.updateOwnApplication
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/user#get-user
    @inlinable
    public func getUser(id: UserSnowflake) async throws -> DiscordClientResponse<DiscordUser> {
        let endpoint = APIEndpoint.getUser(userId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/user#modify-current-user
    @inlinable
    public func updateOwnUser(
        payload: Payloads.ModifyCurrentUser
    ) async throws -> DiscordClientResponse<DiscordUser> {
        let endpoint = APIEndpoint.updateOwnUser
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/user#get-current-user-guilds
    @inlinable
    public func listOwnGuilds(
        before: GuildSnowflake? = nil,
        after: GuildSnowflake? = nil,
        limit: Int? = nil,
        withCounts: Bool? = nil
    ) async throws -> DiscordClientResponse<[PartialGuild]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 200)
        let endpoint = APIEndpoint.listOwnGuilds
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("before", before?.rawValue),
                    ("after", after?.rawValue),
                    ("limit", limit.map { "\($0)" }),
                    ("with_counts", withCounts.map { "\($0)" }),
                ]
            )
        )
    }

    /// This endpoint requires a `DiscordClient` with an OAuth token.
    /// By default the authentication method is by a bot token, and not an OAuth one.
    /// https://discord.com/developers/docs/resources/user#get-current-user-guild-member
    @inlinable
    public func getOwnGuildMember(
        guildId: GuildSnowflake
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = APIEndpoint.getOwnGuildMember(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/user#leave-guild
    @inlinable
    public func leaveGuild(id: GuildSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveGuild(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// You can use this function to create a new **or** retrieve an existing DM channel.
    /// https://discord.com/developers/docs/resources/user#create-dm
    @inlinable
    public func createDm(
        payload: Payloads.CreateDM
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createDm
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/user#create-group-dm
    @inlinable
    public func createGroupDm(
        payload: Payloads.CreateGroupDM
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createGroupDm
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/user#get-user-connections
    @inlinable
    public func listOwnConnections() async throws -> DiscordClientResponse<[DiscordUser.Connection]> {
        let endpoint = APIEndpoint.listOwnConnections
        return try await self.send(request: .init(to: endpoint))
    }

    /// This endpoint requires a `DiscordClient` with an OAuth token.
    /// By default the authentication method is by a bot token, and not an OAuth one.
    /// https://discord.com/developers/docs/resources/user#get-user-application-role-connection
    @inlinable
    public func getApplicationUserRoleConnection(
        appId: ApplicationSnowflake? = nil
    ) async throws -> DiscordClientResponse<DiscordUser.Connection> {
        let endpoint = APIEndpoint.getApplicationUserRoleConnection(
            applicationId: try requireAppId(appId)
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// This endpoint requires a `DiscordClient` with an OAuth token.
    /// By default the authentication method is by a bot token, and not an OAuth one.
    /// https://discord.com/developers/docs/resources/user#update-user-application-role-connection
    @inlinable
    public func updateApplicationUserRoleConnection(
        appId: ApplicationSnowflake? = nil,
        payload: Payloads.UpdateUserApplicationRoleConnection
    ) async throws -> DiscordClientResponse<DiscordUser.Connection> {
        let endpoint = APIEndpoint.updateApplicationUserRoleConnection(
            applicationId: try requireAppId(appId)
        )
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    // MARK: Polls
    /// https://discord.com/developers/docs/resources/poll

    /// https://discord.com/developers/docs/resources/poll#get-answer-voters
    @inlinable
    public func listPollAnswerVotes(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        answerId: Int,
        after: UserSnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<Responses.ListPollAnswerVoters> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 100)
        let endpoint = APIEndpoint.listPollAnswerVoters(
            channelId: channelId,
            messageId: messageId,
            answerId: answerId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [
                    ("after", after?.rawValue),
                    ("limit", limit.map { "\($0)" }),
                ]
            )
        )
    }

    /// https://discord.com/developers/docs/resources/poll#end-poll
    @inlinable
    public func endPoll(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.endPoll(
            channelId: channelId,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: Voice
    /// https://discord.com/developers/docs/resources/voice

    /// https://discord.com/developers/docs/resources/voice#list-voice-regions
    @inlinable
    public func listVoiceRegions() async throws -> DiscordClientResponse<[VoiceRegion]> {
        let endpoint = APIEndpoint.listVoiceRegions
        return try await self.send(request: .init(to: endpoint))
    }

    // MARK: Webhook
    /// https://discord.com/developers/docs/resources/webhook

    /// https://discord.com/developers/docs/resources/webhook#create-webhook
    @inlinable
    public func createWebhook(
        channelId: ChannelSnowflake,
        reason: String? = nil,
        payload: Payloads.CreateWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.createWebhook(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/webhook#get-channel-webhooks
    @inlinable
    public func listChannelWebhooks(channelId: ChannelSnowflake) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = APIEndpoint.listChannelWebhooks(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/webhook#get-guild-webhooks
    @inlinable
    public func getGuildWebhooks(guildId: GuildSnowflake) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = APIEndpoint.getGuildWebhooks(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook
    @inlinable
    public func getWebhook(id: WebhookSnowflake) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.getWebhook(webhookId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook-with-token
    @inlinable
    public func getWebhook(address: WebhookAddress) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.getWebhookByToken(
            webhookId: address.id,
            webhookToken: address.token
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#modify-webhook
    @inlinable
    public func updateWebhook(
        id: WebhookSnowflake,
        reason: String? = nil,
        payload: Payloads.ModifyGuildWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.updateWebhook(webhookId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#modify-webhook-with-token
    @inlinable
    public func updateWebhook(
        address: WebhookAddress,
        reason: String? = nil,
        payload: Payloads.ModifyWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.updateWebhookByToken(
            webhookId: address.id,
            webhookToken: address.token
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#delete-webhook
    @inlinable
    public func deleteWebhook(
        id: WebhookSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteWebhook(webhookId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#delete-webhook-with-token
    @inlinable
    public func deleteWebhook(
        address: WebhookAddress,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteWebhookByToken(
            webhookId: address.id,
            webhookToken: address.token
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            )
        )
    }

    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#execute-webhook
    @inlinable
    public func executeWebhook(
        address: WebhookAddress,
        threadId: ChannelSnowflake? = nil,
        payload: Payloads.ExecuteWebhook
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.executeWebhook(
            webhookId: address.id,
            webhookToken: address.token
        )
        return try await self.sendMultipart(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId?.rawValue)]
            ),
            payload: payload
        )
    }

    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#execute-webhook
    @inlinable
    public func executeWebhookWithResponse(
        address: WebhookAddress,
        threadId: ChannelSnowflake? = nil,
        payload: Payloads.ExecuteWebhook
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.executeWebhook(
            webhookId: address.id,
            webhookToken: address.token
        )
        return try await self.sendMultipart(
            request: .init(
                to: endpoint,
                queries: [
                    ("wait", "true"),
                    ("thread_id", threadId?.rawValue),
                ]
            ),
            payload: payload
        )
    }

    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook-message
    @inlinable
    public func getWebhookMessage(
        address: WebhookAddress,
        messageId: MessageSnowflake,
        threadId: ChannelSnowflake? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getWebhookMessage(
            webhookId: address.id,
            webhookToken: address.token,
            messageId: messageId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId?.rawValue)]
            )
        )
    }

    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#edit-webhook-message
    @inlinable
    public func updateWebhookMessage(
        address: WebhookAddress,
        messageId: MessageSnowflake,
        threadId: ChannelSnowflake? = nil,
        payload: Payloads.EditWebhookMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.updateWebhookMessage(
            webhookId: address.id,
            webhookToken: address.token,
            messageId: messageId
        )
        return try await self.sendMultipart(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId?.rawValue)]
            ),
            payload: payload
        )
    }

    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#delete-webhook-message
    @inlinable
    public func deleteWebhookMessage(
        address: WebhookAddress,
        messageId: MessageSnowflake,
        threadId: ChannelSnowflake? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteWebhookMessage(
            webhookId: address.id,
            webhookToken: address.token,
            messageId: messageId
        )
        return try await self.send(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId?.rawValue)]
            )
        )
    }
}

//MARK: - Internal +DiscordClient
extension DiscordClient {

    @usableFromInline
    func requireAppId(
        _ providedAppId: ApplicationSnowflake?
    ) throws -> ApplicationSnowflake {
        if let appId = providedAppId ?? self.appId {
            return appId
        } else {
            /// You have not passed your app-id in the init of `DiscordClient`/`GatewayManager`.
            /// And the `DiscordClient` was also not able to find your app id using your token.
            /// You need to pass it in the function parameters at least.
            throw DiscordHTTPError.appIdParameterRequired
        }
    }

    /// For compiler warnings
    @available(*, deprecated, message: "App id must be optional otherwise there is no point")
    @usableFromInline
    func requireAppId(_ appId: ApplicationSnowflake) throws -> ApplicationSnowflake {
        appId
    }

    @usableFromInline
    func checkMutuallyExclusive(queries: [(String, String?)]) throws {
        let notNil = queries.filter { $0.1 != nil }
        guard notNil.count < 2 else {
            throw DiscordHTTPError.queryParametersMutuallyExclusive(
                /// Force-unwrap is safe. Guaranteed not to be nil.
                queries: notNil.map { ($0, $1!) }
            )
        }
    }

    @usableFromInline
    func checkInBounds(
        name: String,
        value: Int?,
        lowerBound: Int,
        upperBound: Int
    ) throws {
        guard value.map({ (lowerBound...upperBound).contains($0) }) != false else {
            throw DiscordHTTPError.queryParameterOutOfBounds(
                name: name,
                value: value?.description,
                lowerBound: lowerBound,
                upperBound: upperBound
            )
        }
    }
}
