// DO NOT EDIT. Auto-generated using the GenerateAPIEndpoints command plugin.

/// If you want to add an endpoint that somehow doesn't exist, you'll need to
/// properly edit `/Plugins/GenerateAPIEndpointsExec/Resources/openapi.yml`, then trigger
/// the `GenerateAPIEndpoints` plugin (right click on `DiscordBM` in the file navigator)

import DiscordModels
import NIOHTTP1

public enum APIEndpoint: Endpoint {

  // MARK: Polls
  /// https://discord.com/developers/docs/resources/poll

  case listPollAnswerVoters(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake,
    answerId: Int
  )
  case endPoll(channelId: ChannelSnowflake, messageId: MessageSnowflake)

  // MARK: AutoMod
  /// https://discord.com/developers/docs/resources/auto-moderation

  case getAutoModerationRule(guildId: GuildSnowflake, ruleId: RuleSnowflake)
  case listAutoModerationRules(guildId: GuildSnowflake)
  case createAutoModerationRule(guildId: GuildSnowflake)
  case updateAutoModerationRule(guildId: GuildSnowflake, ruleId: RuleSnowflake)
  case deleteAutoModerationRule(guildId: GuildSnowflake, ruleId: RuleSnowflake)

  // MARK: Audit Log
  /// https://discord.com/developers/docs/resources/audit-log

  case listGuildAuditLogEntries(guildId: GuildSnowflake)

  // MARK: Channels
  /// https://discord.com/developers/docs/resources/channel

  case getChannel(channelId: ChannelSnowflake)
  case listPinnedMessages(channelId: ChannelSnowflake)
  case addGroupDmUser(channelId: ChannelSnowflake, userId: UserSnowflake)
  case pinMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
  case setChannelPermissionOverwrite(
    channelId: ChannelSnowflake,
    overwriteId: AnySnowflake
  )
  case createDm
  //  case createGroupDm
  case followAnnouncementChannel(channelId: ChannelSnowflake)
  case triggerTypingIndicator(channelId: ChannelSnowflake)
  case updateChannel(channelId: ChannelSnowflake)
  case deleteChannel(channelId: ChannelSnowflake)
  case deleteChannelPermissionOverwrite(
    channelId: ChannelSnowflake,
    overwriteId: AnySnowflake
  )
  case deleteGroupDmUser(channelId: ChannelSnowflake, userId: UserSnowflake)
  case unpinMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)

  // MARK: Commands
  /// https://discord.com/developers/docs/interactions/application-commands

  case getApplicationCommand(
    applicationId: ApplicationSnowflake,
    commandId: CommandSnowflake
  )
  case getGuildApplicationCommand(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake,
    commandId: CommandSnowflake
  )
  case getGuildApplicationCommandPermissions(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake,
    commandId: CommandSnowflake
  )
  case listApplicationCommands(applicationId: ApplicationSnowflake)
  case listGuildApplicationCommandPermissions(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake
  )
  case listGuildApplicationCommands(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake
  )
  case bulkSetApplicationCommands(applicationId: ApplicationSnowflake)
  case bulkSetGuildApplicationCommands(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake
  )
  case setGuildApplicationCommandPermissions(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake,
    commandId: CommandSnowflake
  )
  case createApplicationCommand(applicationId: ApplicationSnowflake)
  case createGuildApplicationCommand(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake
  )
  case updateApplicationCommand(
    applicationId: ApplicationSnowflake,
    commandId: CommandSnowflake
  )
  case updateGuildApplicationCommand(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake,
    commandId: CommandSnowflake
  )
  case deleteApplicationCommand(
    applicationId: ApplicationSnowflake,
    commandId: CommandSnowflake
  )
  case deleteGuildApplicationCommand(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake,
    commandId: CommandSnowflake
  )

  // MARK: Emoji
  /// https://discord.com/developers/docs/resources/emoji

  case getGuildEmoji(guildId: GuildSnowflake, emojiId: EmojiSnowflake)
  case listGuildEmojis(guildId: GuildSnowflake)
  case createGuildEmoji(guildId: GuildSnowflake)
  case updateGuildEmoji(guildId: GuildSnowflake, emojiId: EmojiSnowflake)
  case deleteGuildEmoji(guildId: GuildSnowflake, emojiId: EmojiSnowflake)

  // MARK: Entitlements
  /// https://discord.com/developers/docs/monetization/entitlements

  case listEntitlements(applicationId: ApplicationSnowflake)
  case consumeEntitlement(
    applicationId: ApplicationSnowflake,
    entitlementId: EntitlementSnowflake
  )
  case createTestEntitlement(applicationId: ApplicationSnowflake)
  case deleteTestEntitlement(
    applicationId: ApplicationSnowflake,
    entitlementId: EntitlementSnowflake
  )

  // MARK: Gateway
  /// https://discord.com/developers/docs/topics/gateway

  case getBotGateway
  case getGateway

  // MARK: Guilds
  /// https://discord.com/developers/docs/resources/guild

  case getGuild(guildId: GuildSnowflake)
  case getGuildBan(guildId: GuildSnowflake, userId: UserSnowflake)
  case getGuildOnboarding(guildId: GuildSnowflake)
  case getGuildPreview(guildId: GuildSnowflake)
  case getGuildVanityUrl(guildId: GuildSnowflake)
  case getGuildWelcomeScreen(guildId: GuildSnowflake)
  case getGuildWidget(guildId: GuildSnowflake)
  case getGuildWidgetPng(guildId: GuildSnowflake)
  case getGuildWidgetSettings(guildId: GuildSnowflake)
  case listGuildBans(guildId: GuildSnowflake)
  case listGuildChannels(guildId: GuildSnowflake)
  case listGuildIntegrations(guildId: GuildSnowflake)
  case listOwnGuilds
  case previewPruneGuild(guildId: GuildSnowflake)
  case banUserFromGuild(guildId: GuildSnowflake, userId: UserSnowflake)
  case updateGuildOnboarding(guildId: GuildSnowflake)
  case bulkBanUsersFromGuild(guildId: GuildSnowflake)
  case createGuild
  case createGuildChannel(guildId: GuildSnowflake)
  case pruneGuild(guildId: GuildSnowflake)
  case setGuildMfaLevel(guildId: GuildSnowflake)
  case updateGuild(guildId: GuildSnowflake)
  case updateGuildChannelPositions(guildId: GuildSnowflake)
  case updateGuildWelcomeScreen(guildId: GuildSnowflake)
  case updateGuildWidgetSettings(guildId: GuildSnowflake)
  case deleteGuild(guildId: GuildSnowflake)
  case deleteGuildIntegration(
    guildId: GuildSnowflake,
    integrationId: IntegrationSnowflake
  )
  case leaveGuild(guildId: GuildSnowflake)
  case unbanUserFromGuild(guildId: GuildSnowflake, userId: UserSnowflake)

  // MARK: Guild Templates
  /// https://discord.com/developers/docs/resources/guild-template

  case getGuildTemplate(code: String)
  case listGuildTemplates(guildId: GuildSnowflake)
  case syncGuildTemplate(guildId: GuildSnowflake, code: String)
  case createGuildFromTemplate(code: String)
  case createGuildTemplate(guildId: GuildSnowflake)
  case updateGuildTemplate(guildId: GuildSnowflake, code: String)
  case deleteGuildTemplate(guildId: GuildSnowflake, code: String)

  // MARK: Interactions
  /// https://discord.com/developers/docs/interactions/receiving-and-responding

  case getFollowupMessage(
    applicationId: ApplicationSnowflake,
    interactionToken: String,
    messageId: MessageSnowflake
  )
  case getOriginalInteractionResponse(
    applicationId: ApplicationSnowflake,
    interactionToken: String
  )
  case createFollowupMessage(
    applicationId: ApplicationSnowflake,
    interactionToken: String
  )
  case createInteractionResponse(
    interactionId: InteractionSnowflake,
    interactionToken: String
  )
  case updateFollowupMessage(
    applicationId: ApplicationSnowflake,
    interactionToken: String,
    messageId: MessageSnowflake
  )
  case updateOriginalInteractionResponse(
    applicationId: ApplicationSnowflake,
    interactionToken: String
  )
  case deleteFollowupMessage(
    applicationId: ApplicationSnowflake,
    interactionToken: String,
    messageId: MessageSnowflake
  )
  case deleteOriginalInteractionResponse(
    applicationId: ApplicationSnowflake,
    interactionToken: String
  )

  // MARK: Invites
  /// https://discord.com/developers/docs/resources/invite

  case listChannelInvites(channelId: ChannelSnowflake)
  case listGuildInvites(guildId: GuildSnowflake)
  case resolveInvite(code: String)
  case createChannelInvite(channelId: ChannelSnowflake)
  case revokeInvite(code: String)

  // MARK: Members
  /// https://discord.com/developers/docs/resources/guild

  case getGuildMember(guildId: GuildSnowflake, userId: UserSnowflake)
  case getOwnGuildMember(guildId: GuildSnowflake)
  case listGuildMembers(guildId: GuildSnowflake)
  case searchGuildMembers(guildId: GuildSnowflake)
  case addGuildMember(guildId: GuildSnowflake, userId: UserSnowflake)
  case updateGuildMember(guildId: GuildSnowflake, userId: UserSnowflake)
  case updateOwnGuildMember(guildId: GuildSnowflake)
  case deleteGuildMember(guildId: GuildSnowflake, userId: UserSnowflake)

  // MARK: Messages
  /// https://discord.com/developers/docs/resources/channel

  case getMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
  case listMessageReactionsByEmoji(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake,
    emojiName: String
  )
  case listMessages(channelId: ChannelSnowflake)
  case addMessageReaction(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake,
    emojiName: String
  )
  case bulkDeleteMessages(channelId: ChannelSnowflake)
  case createMessage(channelId: ChannelSnowflake)
  case crosspostMessage(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake
  )
  case updateMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
  case deleteAllMessageReactions(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake
  )
  case deleteAllMessageReactionsByEmoji(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake,
    emojiName: String
  )
  case deleteMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
  case deleteOwnMessageReaction(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake,
    emojiName: String,
    type: Gateway.ReactionKind
  )
  case deleteUserMessageReaction(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake,
    emojiName: String,
    userId: UserSnowflake,
    type: Gateway.ReactionKind
  )

  // MARK: OAuth
  /// https://discord.com/developers/docs/topics/oauth2

  case getOwnOauth2Application

  // MARK: Roles
  /// https://discord.com/developers/docs/resources/guild

  case listGuildRoles(guildId: GuildSnowflake)
  case addGuildMemberRole(
    guildId: GuildSnowflake,
    userId: UserSnowflake,
    roleId: RoleSnowflake
  )
  case createGuildRole(guildId: GuildSnowflake)
  case updateGuildRole(guildId: GuildSnowflake, roleId: RoleSnowflake)
  case updateGuildRolePositions(guildId: GuildSnowflake)
  case deleteGuildMemberRole(
    guildId: GuildSnowflake,
    userId: UserSnowflake,
    roleId: RoleSnowflake
  )
  case deleteGuildRole(guildId: GuildSnowflake, roleId: RoleSnowflake)

  // MARK: Role Connections
  /// https://discord.com/developers/docs/resources/user

  case getApplicationUserRoleConnection(applicationId: ApplicationSnowflake)
  case listApplicationRoleConnectionMetadata(
    applicationId: ApplicationSnowflake
  )
  case bulkOverwriteApplicationRoleConnectionMetadata(
    applicationId: ApplicationSnowflake
  )
  case updateApplicationUserRoleConnection(applicationId: ApplicationSnowflake)

  // MARK: Scheduled Events
  /// https://discord.com/developers/docs/resources/guild-scheduled-event

  case getGuildScheduledEvent(
    guildId: GuildSnowflake,
    guildScheduledEventId: GuildScheduledEventSnowflake
  )
  case listGuildScheduledEventUsers(
    guildId: GuildSnowflake,
    guildScheduledEventId: GuildScheduledEventSnowflake
  )
  case listGuildScheduledEvents(guildId: GuildSnowflake)
  case createGuildScheduledEvent(guildId: GuildSnowflake)
  case updateGuildScheduledEvent(
    guildId: GuildSnowflake,
    guildScheduledEventId: GuildScheduledEventSnowflake
  )
  case deleteGuildScheduledEvent(
    guildId: GuildSnowflake,
    guildScheduledEventId: GuildScheduledEventSnowflake
  )

  // MARK: SKUs
  /// https://discord.com/developers/docs/monetization/skus

  case listSkus(applicationId: ApplicationSnowflake)

  // MARK: Stages
  /// https://discord.com/developers/docs/resources/stage-instance

  case getStageInstance(channelId: ChannelSnowflake)
  case createStageInstance
  case updateStageInstance(channelId: ChannelSnowflake)
  case deleteStageInstance(channelId: ChannelSnowflake)

  // MARK: Stickers
  /// https://discord.com/developers/docs/resources/sticker

  case getGuildSticker(guildId: GuildSnowflake, stickerId: StickerSnowflake)
  case getSticker(stickerId: StickerSnowflake)
  case listGuildStickers(guildId: GuildSnowflake)
  case createGuildSticker(guildId: GuildSnowflake)
  case updateGuildSticker(guildId: GuildSnowflake, stickerId: StickerSnowflake)
  case deleteGuildSticker(guildId: GuildSnowflake, stickerId: StickerSnowflake)

  // MARK: Threads
  /// https://discord.com/developers/docs/resources/channel

  case getThreadMember(channelId: ChannelSnowflake, userId: UserSnowflake)
  case listActiveGuildThreads(guildId: GuildSnowflake)
  case listOwnPrivateArchivedThreads(channelId: ChannelSnowflake)
  case listPrivateArchivedThreads(channelId: ChannelSnowflake)
  case listPublicArchivedThreads(channelId: ChannelSnowflake)
  case listThreadMembers(channelId: ChannelSnowflake)
  case addThreadMember(channelId: ChannelSnowflake, userId: UserSnowflake)
  case joinThread(channelId: ChannelSnowflake)
  case createThread(channelId: ChannelSnowflake)
  case createThreadFromMessage(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake
  )
  case createThreadInForumChannel(channelId: ChannelSnowflake)
  case deleteThreadMember(channelId: ChannelSnowflake, userId: UserSnowflake)
  case leaveThread(channelId: ChannelSnowflake)

  // MARK: Users
  /// https://discord.com/developers/docs/resources/user

  case getOwnApplication
  case getOwnUser
  case getUser(userId: UserSnowflake)
  case listOwnConnections
  case updateOwnApplication
  case updateOwnUser

  // MARK: Voice
  /// https://discord.com/developers/docs/resources/voice#list-voice-regions
  case getVoiceState(guildId: GuildSnowflake, userId: UserSnowflake)
  case listGuildVoiceRegions(guildId: GuildSnowflake)
  case listVoiceRegions
  case updateSelfVoiceState(guildId: GuildSnowflake)
  case updateVoiceState(guildId: GuildSnowflake, userId: UserSnowflake)

  // MARK: Webhooks
  /// https://discord.com/developers/docs/resources/webhook

  case getGuildWebhooks(guildId: GuildSnowflake)
  case getWebhook(webhookId: WebhookSnowflake)
  case getWebhookByToken(webhookId: WebhookSnowflake, webhookToken: String)
  case getWebhookMessage(
    webhookId: WebhookSnowflake,
    webhookToken: String,
    messageId: MessageSnowflake
  )
  case listChannelWebhooks(channelId: ChannelSnowflake)
  case createWebhook(channelId: ChannelSnowflake)
  case executeWebhook(webhookId: WebhookSnowflake, webhookToken: String)
  case updateWebhook(webhookId: WebhookSnowflake)
  case updateWebhookByToken(webhookId: WebhookSnowflake, webhookToken: String)
  case updateWebhookMessage(
    webhookId: WebhookSnowflake,
    webhookToken: String,
    messageId: MessageSnowflake
  )
  case deleteWebhook(webhookId: WebhookSnowflake)
  case deleteWebhookByToken(webhookId: WebhookSnowflake, webhookToken: String)
  case deleteWebhookMessage(
    webhookId: WebhookSnowflake,
    webhookToken: String,
    messageId: MessageSnowflake
  )

  /// This case serves as a way of discouraging exhaustive switch statements
  case __DO_NOT_USE_THIS_CASE

  var urlPrefix: String {
    "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
  }

  public var url: String {
    let suffix: String
    switch self {
    case .listPollAnswerVoters(let channelId, let messageId, let answerId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/polls/\(messageId)/answers/\(answerId)"
    case .endPoll(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/polls/\(messageId)/expire"
    case .getAutoModerationRule(let guildId, let ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case .listAutoModerationRules(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules"
    case .createAutoModerationRule(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules"
    case .updateAutoModerationRule(let guildId, let ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case .deleteAutoModerationRule(let guildId, let ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case .listGuildAuditLogEntries(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/audit-logs"
    case .getChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case .listPinnedMessages(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/pins"
    case .addGroupDmUser(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/recipients/\(userId)"
    case .pinMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/pins/\(messageId)"
    case .setChannelPermissionOverwrite(let channelId, let overwriteId):
      let channelId = channelId.rawValue
      let overwriteId = overwriteId.rawValue
      suffix = "channels/\(channelId)/permissions/\(overwriteId)"
    case .createDm:
      suffix = "users/@me/channels"
    //    case .createGroupDm:
    //      suffix = "users/@me/channels"
    case .followAnnouncementChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/followers"
    case .triggerTypingIndicator(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/typing"
    case .updateChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case .deleteChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case .deleteChannelPermissionOverwrite(let channelId, let overwriteId):
      let channelId = channelId.rawValue
      let overwriteId = overwriteId.rawValue
      suffix = "channels/\(channelId)/permissions/\(overwriteId)"
    case .deleteGroupDmUser(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/recipients/\(userId)"
    case .unpinMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/pins/\(messageId)"
    case .getApplicationCommand(let applicationId, let commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case .getGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case .getGuildApplicationCommandPermissions(
      let
        applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    case .listApplicationCommands(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case .listGuildApplicationCommandPermissions(let applicationId, let guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
    case .listGuildApplicationCommands(let applicationId, let guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case .bulkSetApplicationCommands(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case .bulkSetGuildApplicationCommands(let applicationId, let guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case .setGuildApplicationCommandPermissions(
      let
        applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    case .createApplicationCommand(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case .createGuildApplicationCommand(let applicationId, let guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case .updateApplicationCommand(let applicationId, let commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case .updateGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case .deleteApplicationCommand(let applicationId, let commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case .deleteGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case .getGuildEmoji(let guildId, let emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case .listGuildEmojis(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/emojis"
    case .createGuildEmoji(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/emojis"
    case .updateGuildEmoji(let guildId, let emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case .deleteGuildEmoji(let guildId, let emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case .listEntitlements(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/entitlements"
    case .consumeEntitlement(let applicationId, let entitlementId):
      let applicationId = applicationId.rawValue
      let entitlementId = entitlementId.rawValue
      suffix =
        "applications/\(applicationId)/entitlements/\(entitlementId)/consume"
    case .createTestEntitlement(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/entitlements"
    case .deleteTestEntitlement(let applicationId, let entitlementId):
      let applicationId = applicationId.rawValue
      let entitlementId = entitlementId.rawValue
      suffix = "applications/\(applicationId)/entitlements/\(entitlementId)"
    case .getBotGateway:
      suffix = "gateway/bot"
    case .getGateway:
      suffix = "gateway"
    case .getGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case .getGuildBan(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case .getGuildOnboarding(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/onboarding"
    case .getGuildPreview(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/preview"
    case .getGuildVanityUrl(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/vanity-url"
    case .getGuildWelcomeScreen(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/welcome-screen"
    case .getGuildWidget(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget.json"
    case .getGuildWidgetPng(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget.png"
    case .getGuildWidgetSettings(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget"
    case .listGuildBans(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/bans"
    case .listGuildChannels(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case .listGuildIntegrations(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/integrations"
    case .listOwnGuilds:
      suffix = "users/@me/guilds"
    case .previewPruneGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/prune"
    case .banUserFromGuild(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case .updateGuildOnboarding(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/onboarding"
    case .bulkBanUsersFromGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/bulk-ban"
    case .createGuild:
      suffix = "guilds"
    case .createGuildChannel(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case .pruneGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/prune"
    case .setGuildMfaLevel(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/mfa"
    case .updateGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case .updateGuildChannelPositions(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case .updateGuildWelcomeScreen(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/welcome-screen"
    case .updateGuildWidgetSettings(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget"
    case .deleteGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case .deleteGuildIntegration(let guildId, let integrationId):
      let guildId = guildId.rawValue
      let integrationId = integrationId.rawValue
      suffix = "guilds/\(guildId)/integrations/\(integrationId)"
    case .leaveGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "users/@me/guilds/\(guildId)"
    case .unbanUserFromGuild(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case .getGuildTemplate(let code):
      suffix = "guilds/templates/\(code)"
    case .listGuildTemplates(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates"
    case .syncGuildTemplate(let guildId, let code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case .createGuildFromTemplate(let code):
      suffix = "guilds/templates/\(code)"
    case .createGuildTemplate(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates"
    case .updateGuildTemplate(let guildId, let code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case .deleteGuildTemplate(let guildId, let code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case .getFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case .getOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case .createFollowupMessage(let applicationId, let interactionToken):
      let applicationId = applicationId.rawValue
      suffix = "webhooks/\(applicationId)/\(interactionToken)"
    case .createInteractionResponse(let interactionId, let interactionToken):
      let interactionId = interactionId.rawValue
      suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
    case .updateFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case .updateOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case .deleteFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case .deleteOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case .listChannelInvites(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/invites"
    case .listGuildInvites(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/invites"
    case .resolveInvite(let code):
      suffix = "invites/\(code)"
    case .createChannelInvite(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/invites"
    case .revokeInvite(let code):
      suffix = "invites/\(code)"
    case .getGuildMember(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case .getOwnGuildMember(let guildId):
      let guildId = guildId.rawValue
      suffix = "users/@me/guilds/\(guildId)/member"
    case .listGuildMembers(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members"
    case .searchGuildMembers(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members/search"
    case .addGuildMember(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case .updateGuildMember(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case .updateOwnGuildMember(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members/@me"
    case .deleteGuildMember(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case .getMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case .listMessageReactionsByEmoji(
      let channelId,
      let messageId,
      let emojiName,

    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
    case .listMessages(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages"
    case .addMessageReaction(
      let channelId,
      let messageId,
      let emojiName
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
    case .bulkDeleteMessages(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages/bulk-delete"
    case .createMessage(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages"
    case .crosspostMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
    case .updateMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case .deleteAllMessageReactions(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
    case .deleteAllMessageReactionsByEmoji(
      let channelId,
      let messageId,
      let emojiName
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
    case .deleteMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case .deleteOwnMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
      let type
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(type.rawValue)/@me"
    case .deleteUserMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
      let userId,
      let type
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      let userId = userId.rawValue
      suffix =
        "channels/\(channelId)/messages/\(messageId)/\(type)/reactions/\(emojiName)/\(userId)"
    case .getOwnOauth2Application:
      suffix = "oauth2/applications/@me"
    case .listGuildRoles(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case .addGuildMemberRole(let guildId, let userId, let roleId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    case .createGuildRole(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case .updateGuildRole(let guildId, let roleId):
      let guildId = guildId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/roles/\(roleId)"
    case .updateGuildRolePositions(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case .deleteGuildMemberRole(let guildId, let userId, let roleId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    case .deleteGuildRole(let guildId, let roleId):
      let guildId = guildId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/roles/\(roleId)"
    case .getApplicationUserRoleConnection(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "users/@me/applications/\(applicationId)/role-connection"
    case .listApplicationRoleConnectionMetadata(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/role-connections/metadata"
    case .bulkOverwriteApplicationRoleConnectionMetadata(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/role-connections/metadata"
    case .updateApplicationUserRoleConnection(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "users/@me/applications/\(applicationId)/role-connection"
    case .getGuildScheduledEvent(let guildId, let guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case .listGuildScheduledEventUsers(let guildId, let guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix =
        "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
    case .listGuildScheduledEvents(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events"
    case .createGuildScheduledEvent(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events"
    case .updateGuildScheduledEvent(let guildId, let guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case .deleteGuildScheduledEvent(let guildId, let guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case .listSkus(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/skus"
    case .getStageInstance(let channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case .createStageInstance:
      suffix = "stage-instances"
    case .updateStageInstance(let channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case .deleteStageInstance(let channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case .getGuildSticker(let guildId, let stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case .getSticker(let stickerId):
      let stickerId = stickerId.rawValue
      suffix = "stickers/\(stickerId)"
    case .listGuildStickers(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/stickers"
    case .createGuildSticker(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/stickers"
    case .updateGuildSticker(let guildId, let stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case .deleteGuildSticker(let guildId, let stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case .getThreadMember(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case .listActiveGuildThreads(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/threads/active"
    case .listOwnPrivateArchivedThreads(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/users/@me/threads/archived/private"
    case .listPrivateArchivedThreads(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads/archived/private"
    case .listPublicArchivedThreads(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads/archived/public"
    case .listThreadMembers(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members"
    case .addThreadMember(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case .joinThread(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members/@me"
    case .createThread(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads"
    case .createThreadFromMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/threads"
    case .createThreadInForumChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads"
    case .deleteThreadMember(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case .leaveThread(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members/@me"
    case .getOwnApplication:
      suffix = "applications/@me"
    case .getOwnUser:
      suffix = "users/@me"
    case .getUser(let userId):
      let userId = userId.rawValue
      suffix = "users/\(userId)"
    case .listOwnConnections:
      suffix = "users/@me/connections"
    case .updateOwnApplication:
      suffix = "applications/@me"
    case .updateOwnUser:
      suffix = "users/@me"
    case .getVoiceState(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/voice-states/\(userId)"
    case .listGuildVoiceRegions(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/regions"
    case .listVoiceRegions:
      suffix = "voice/regions"
    case .updateSelfVoiceState(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/voice-states/@me"
    case .updateVoiceState(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/voice-states/\(userId)"
    case .getGuildWebhooks(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/webhooks"
    case .getWebhook(let webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case .getWebhookByToken(let webhookId, let webhookToken):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case .getWebhookMessage(let webhookId, let webhookToken, let messageId):
      let webhookId = webhookId.rawValue
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case .listChannelWebhooks(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/webhooks"
    case .createWebhook(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/webhooks"
    case .executeWebhook(let webhookId, let webhookToken):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case .updateWebhook(let webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case .updateWebhookByToken(let webhookId, let webhookToken):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case .updateWebhookMessage(let webhookId, let webhookToken, let messageId):
      let webhookId = webhookId.rawValue
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case .deleteWebhook(let webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case .deleteWebhookByToken(let webhookId, let webhookToken):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case .deleteWebhookMessage(let webhookId, let webhookToken, let messageId):
      let webhookId = webhookId.rawValue
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
    return self.urlPrefix + suffix
  }

  public var urlDescription: String {
    let suffix: String
    switch self {
    case .listPollAnswerVoters(let channelId, let messageId, let answerId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/polls/\(messageId)/answers/\(answerId)"
    case .endPoll(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/polls/\(messageId)/expire"
    case .getAutoModerationRule(let guildId, let ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case .listAutoModerationRules(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules"
    case .createAutoModerationRule(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules"
    case .updateAutoModerationRule(let guildId, let ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case .deleteAutoModerationRule(let guildId, let ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case .listGuildAuditLogEntries(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/audit-logs"
    case .getChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case .listPinnedMessages(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/pins"
    case .addGroupDmUser(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/recipients/\(userId)"
    case .pinMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/pins/\(messageId)"
    case .setChannelPermissionOverwrite(let channelId, let overwriteId):
      let channelId = channelId.rawValue
      let overwriteId = overwriteId.rawValue
      suffix = "channels/\(channelId)/permissions/\(overwriteId)"
    case .createDm:
      suffix = "users/@me/channels"
    //    case .createGroupDm:
    //      suffix = "users/@me/channels"
    case .followAnnouncementChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/followers"
    case .triggerTypingIndicator(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/typing"
    case .updateChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case .deleteChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case .deleteChannelPermissionOverwrite(let channelId, let overwriteId):
      let channelId = channelId.rawValue
      let overwriteId = overwriteId.rawValue
      suffix = "channels/\(channelId)/permissions/\(overwriteId)"
    case .deleteGroupDmUser(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/recipients/\(userId)"
    case .unpinMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/pins/\(messageId)"
    case .getApplicationCommand(let applicationId, let commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case .getGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case .getGuildApplicationCommandPermissions(
      let
        applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    case .listApplicationCommands(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case .listGuildApplicationCommandPermissions(let applicationId, let guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
    case .listGuildApplicationCommands(let applicationId, let guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case .bulkSetApplicationCommands(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case .bulkSetGuildApplicationCommands(let applicationId, let guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case .setGuildApplicationCommandPermissions(
      let
        applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    case .createApplicationCommand(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case .createGuildApplicationCommand(let applicationId, let guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case .updateApplicationCommand(let applicationId, let commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case .updateGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case .deleteApplicationCommand(let applicationId, let commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case .deleteGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case .getGuildEmoji(let guildId, let emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case .listGuildEmojis(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/emojis"
    case .createGuildEmoji(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/emojis"
    case .updateGuildEmoji(let guildId, let emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case .deleteGuildEmoji(let guildId, let emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case .listEntitlements(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/entitlements"
    case .consumeEntitlement(let applicationId, let entitlementId):
      let applicationId = applicationId.rawValue
      let entitlementId = entitlementId.rawValue
      suffix =
        "applications/\(applicationId)/entitlements/\(entitlementId)/consume"
    case .createTestEntitlement(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/entitlements"
    case .deleteTestEntitlement(let applicationId, let entitlementId):
      let applicationId = applicationId.rawValue
      let entitlementId = entitlementId.rawValue
      suffix = "applications/\(applicationId)/entitlements/\(entitlementId)"
    case .getBotGateway:
      suffix = "gateway/bot"
    case .getGateway:
      suffix = "gateway"
    case .getGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case .getGuildBan(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case .getGuildOnboarding(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/onboarding"
    case .getGuildPreview(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/preview"
    case .getGuildVanityUrl(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/vanity-url"
    case .getGuildWelcomeScreen(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/welcome-screen"
    case .getGuildWidget(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget.json"
    case .getGuildWidgetPng(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget.png"
    case .getGuildWidgetSettings(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget"
    case .listGuildBans(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/bans"
    case .listGuildChannels(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case .listGuildIntegrations(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/integrations"
    case .listOwnGuilds:
      suffix = "users/@me/guilds"
    case .previewPruneGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/prune"
    case .banUserFromGuild(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case .updateGuildOnboarding(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/onboarding"
    case .bulkBanUsersFromGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/bulk-ban"
    case .createGuild:
      suffix = "guilds"
    case .createGuildChannel(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case .pruneGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/prune"
    case .setGuildMfaLevel(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/mfa"
    case .updateGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case .updateGuildChannelPositions(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case .updateGuildWelcomeScreen(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/welcome-screen"
    case .updateGuildWidgetSettings(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget"
    case .deleteGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case .deleteGuildIntegration(let guildId, let integrationId):
      let guildId = guildId.rawValue
      let integrationId = integrationId.rawValue
      suffix = "guilds/\(guildId)/integrations/\(integrationId)"
    case .leaveGuild(let guildId):
      let guildId = guildId.rawValue
      suffix = "users/@me/guilds/\(guildId)"
    case .unbanUserFromGuild(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case .getGuildTemplate(let code):
      suffix = "guilds/templates/\(code)"
    case .listGuildTemplates(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates"
    case .syncGuildTemplate(let guildId, let code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case .createGuildFromTemplate(let code):
      suffix = "guilds/templates/\(code)"
    case .createGuildTemplate(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates"
    case .updateGuildTemplate(let guildId, let code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case .deleteGuildTemplate(let guildId, let code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case .getFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case .getOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case .createFollowupMessage(let applicationId, let interactionToken):
      let applicationId = applicationId.rawValue
      suffix = "webhooks/\(applicationId)/\(interactionToken)"
    case .createInteractionResponse(let interactionId, let interactionToken):
      let interactionId = interactionId.rawValue
      suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
    case .updateFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case .updateOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case .deleteFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case .deleteOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case .listChannelInvites(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/invites"
    case .listGuildInvites(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/invites"
    case .resolveInvite(let code):
      suffix = "invites/\(code)"
    case .createChannelInvite(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/invites"
    case .revokeInvite(let code):
      suffix = "invites/\(code)"
    case .getGuildMember(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case .getOwnGuildMember(let guildId):
      let guildId = guildId.rawValue
      suffix = "users/@me/guilds/\(guildId)/member"
    case .listGuildMembers(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members"
    case .searchGuildMembers(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members/search"
    case .addGuildMember(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case .updateGuildMember(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case .updateOwnGuildMember(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members/@me"
    case .deleteGuildMember(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case .getMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case .listMessageReactionsByEmoji(
      let channelId,
      let messageId,
      let emojiName
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
    case .listMessages(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages"
    case .addMessageReaction(
      let channelId,
      let messageId,
      let emojiName
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
    case .bulkDeleteMessages(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages/bulk-delete"
    case .createMessage(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages"
    case .crosspostMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
    case .updateMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case .deleteAllMessageReactions(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
    case .deleteAllMessageReactionsByEmoji(
      let channelId,
      let messageId,
      let emojiName
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
    case .deleteMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case .deleteOwnMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
      let type
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(type.rawValue)/@me"
    case .deleteUserMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
      let userId,
      let type
    ):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      let userId = userId.rawValue
      suffix =
        "channels/\(channelId)/messages/\(messageId)/\(type)/reactions/\(emojiName)/\(userId)"
    case .getOwnOauth2Application:
      suffix = "oauth2/applications/@me"
    case .listGuildRoles(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case .addGuildMemberRole(let guildId, let userId, let roleId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    case .createGuildRole(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case .updateGuildRole(let guildId, let roleId):
      let guildId = guildId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/roles/\(roleId)"
    case .updateGuildRolePositions(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case .deleteGuildMemberRole(let guildId, let userId, let roleId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    case .deleteGuildRole(let guildId, let roleId):
      let guildId = guildId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/roles/\(roleId)"
    case .getApplicationUserRoleConnection(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "users/@me/applications/\(applicationId)/role-connection"
    case .listApplicationRoleConnectionMetadata(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/role-connections/metadata"
    case .bulkOverwriteApplicationRoleConnectionMetadata(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/role-connections/metadata"
    case .updateApplicationUserRoleConnection(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "users/@me/applications/\(applicationId)/role-connection"
    case .getGuildScheduledEvent(let guildId, let guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case .listGuildScheduledEventUsers(let guildId, let guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix =
        "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
    case .listGuildScheduledEvents(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events"
    case .createGuildScheduledEvent(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events"
    case .updateGuildScheduledEvent(let guildId, let guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case .deleteGuildScheduledEvent(let guildId, let guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case .listSkus(let applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/skus"
    case .getStageInstance(let channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case .createStageInstance:
      suffix = "stage-instances"
    case .updateStageInstance(let channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case .deleteStageInstance(let channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case .getGuildSticker(let guildId, let stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case .getSticker(let stickerId):
      let stickerId = stickerId.rawValue
      suffix = "stickers/\(stickerId)"
    case .listGuildStickers(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/stickers"
    case .createGuildSticker(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/stickers"
    case .updateGuildSticker(let guildId, let stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case .deleteGuildSticker(let guildId, let stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case .getThreadMember(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case .listActiveGuildThreads(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/threads/active"
    case .listOwnPrivateArchivedThreads(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/users/@me/threads/archived/private"
    case .listPrivateArchivedThreads(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads/archived/private"
    case .listPublicArchivedThreads(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads/archived/public"
    case .listThreadMembers(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members"
    case .addThreadMember(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case .joinThread(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members/@me"
    case .createThread(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads"
    case .createThreadFromMessage(let channelId, let messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/threads"
    case .createThreadInForumChannel(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads"
    case .deleteThreadMember(let channelId, let userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case .leaveThread(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members/@me"
    case .getOwnApplication:
      suffix = "applications/@me"
    case .getOwnUser:
      suffix = "users/@me"
    case .getUser(let userId):
      let userId = userId.rawValue
      suffix = "users/\(userId)"
    case .listOwnConnections:
      suffix = "users/@me/connections"
    case .updateOwnApplication:
      suffix = "applications/@me"
    case .updateOwnUser:
      suffix = "users/@me"
    case .getVoiceState(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/voice-states/\(userId)"
    case .listGuildVoiceRegions(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/regions"
    case .listVoiceRegions:
      suffix = "voice/regions"
    case .updateSelfVoiceState(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/voice-states/@me"
    case .updateVoiceState(let guildId, let userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/voice-states/\(userId)"
    case .getGuildWebhooks(let guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/webhooks"
    case .getWebhook(let webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case .getWebhookByToken(let webhookId, let webhookToken):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case .getWebhookMessage(let webhookId, let webhookToken, let messageId):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case .listChannelWebhooks(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/webhooks"
    case .createWebhook(let channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/webhooks"
    case .executeWebhook(let webhookId, let webhookToken):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case .updateWebhook(let webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case .updateWebhookByToken(let webhookId, let webhookToken):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case .updateWebhookMessage(let webhookId, let webhookToken, let messageId):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case .deleteWebhook(let webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case .deleteWebhookByToken(let webhookId, let webhookToken):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case .deleteWebhookMessage(let webhookId, let webhookToken, let messageId):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
    return self.urlPrefix + suffix
  }

  public var httpMethod: HTTPMethod {
    switch self {
    case .listPollAnswerVoters: return .GET
    case .endPoll: return .POST
    case .getAutoModerationRule: return .GET
    case .listAutoModerationRules: return .GET
    case .createAutoModerationRule: return .POST
    case .updateAutoModerationRule: return .PATCH
    case .deleteAutoModerationRule: return .DELETE
    case .listGuildAuditLogEntries: return .GET
    case .getChannel: return .GET
    case .listPinnedMessages: return .GET
    case .addGroupDmUser: return .PUT
    case .pinMessage: return .PUT
    case .setChannelPermissionOverwrite: return .PUT
    case .createDm: return .POST
    //    case .createGroupDm: return .POST
    case .followAnnouncementChannel: return .POST
    case .triggerTypingIndicator: return .POST
    case .updateChannel: return .PATCH
    case .deleteChannel: return .DELETE
    case .deleteChannelPermissionOverwrite: return .DELETE
    case .deleteGroupDmUser: return .DELETE
    case .unpinMessage: return .DELETE
    case .getApplicationCommand: return .GET
    case .getGuildApplicationCommand: return .GET
    case .getGuildApplicationCommandPermissions: return .GET
    case .listApplicationCommands: return .GET
    case .listGuildApplicationCommandPermissions: return .GET
    case .listGuildApplicationCommands: return .GET
    case .bulkSetApplicationCommands: return .PUT
    case .bulkSetGuildApplicationCommands: return .PUT
    case .setGuildApplicationCommandPermissions: return .PUT
    case .createApplicationCommand: return .POST
    case .createGuildApplicationCommand: return .POST
    case .updateApplicationCommand: return .PATCH
    case .updateGuildApplicationCommand: return .PATCH
    case .deleteApplicationCommand: return .DELETE
    case .deleteGuildApplicationCommand: return .DELETE
    case .getGuildEmoji: return .GET
    case .listGuildEmojis: return .GET
    case .createGuildEmoji: return .POST
    case .updateGuildEmoji: return .PATCH
    case .deleteGuildEmoji: return .DELETE
    case .listEntitlements: return .GET
    case .consumeEntitlement: return .POST
    case .createTestEntitlement: return .POST
    case .deleteTestEntitlement: return .DELETE
    case .getBotGateway: return .GET
    case .getGateway: return .GET
    case .getGuild: return .GET
    case .getGuildBan: return .GET
    case .getGuildOnboarding: return .GET
    case .getGuildPreview: return .GET
    case .getGuildVanityUrl: return .GET
    case .getGuildWelcomeScreen: return .GET
    case .getGuildWidget: return .GET
    case .getGuildWidgetPng: return .GET
    case .getGuildWidgetSettings: return .GET
    case .listGuildBans: return .GET
    case .listGuildChannels: return .GET
    case .listGuildIntegrations: return .GET
    case .listOwnGuilds: return .GET
    case .previewPruneGuild: return .GET
    case .banUserFromGuild: return .PUT
    case .updateGuildOnboarding: return .PUT
    case .bulkBanUsersFromGuild: return .POST
    case .createGuild: return .POST
    case .createGuildChannel: return .POST
    case .pruneGuild: return .POST
    case .setGuildMfaLevel: return .POST
    case .updateGuild: return .PATCH
    case .updateGuildChannelPositions: return .PATCH
    case .updateGuildWelcomeScreen: return .PATCH
    case .updateGuildWidgetSettings: return .PATCH
    case .deleteGuild: return .DELETE
    case .deleteGuildIntegration: return .DELETE
    case .leaveGuild: return .DELETE
    case .unbanUserFromGuild: return .DELETE
    case .getGuildTemplate: return .GET
    case .listGuildTemplates: return .GET
    case .syncGuildTemplate: return .PUT
    case .createGuildFromTemplate: return .POST
    case .createGuildTemplate: return .POST
    case .updateGuildTemplate: return .PATCH
    case .deleteGuildTemplate: return .DELETE
    case .getFollowupMessage: return .GET
    case .getOriginalInteractionResponse: return .GET
    case .createFollowupMessage: return .POST
    case .createInteractionResponse: return .POST
    case .updateFollowupMessage: return .PATCH
    case .updateOriginalInteractionResponse: return .PATCH
    case .deleteFollowupMessage: return .DELETE
    case .deleteOriginalInteractionResponse: return .DELETE
    case .listChannelInvites: return .GET
    case .listGuildInvites: return .GET
    case .resolveInvite: return .GET
    case .createChannelInvite: return .POST
    case .revokeInvite: return .DELETE
    case .getGuildMember: return .GET
    case .getOwnGuildMember: return .GET
    case .listGuildMembers: return .GET
    case .searchGuildMembers: return .GET
    case .addGuildMember: return .PUT
    case .updateGuildMember: return .PATCH
    case .updateOwnGuildMember: return .PATCH
    case .deleteGuildMember: return .DELETE
    case .getMessage: return .GET
    case .listMessageReactionsByEmoji: return .GET
    case .listMessages: return .GET
    case .addMessageReaction: return .PUT
    case .bulkDeleteMessages: return .POST
    case .createMessage: return .POST
    case .crosspostMessage: return .POST
    case .updateMessage: return .PATCH
    case .deleteAllMessageReactions: return .DELETE
    case .deleteAllMessageReactionsByEmoji: return .DELETE
    case .deleteMessage: return .DELETE
    case .deleteOwnMessageReaction: return .DELETE
    case .deleteUserMessageReaction: return .DELETE
    case .getOwnOauth2Application: return .GET
    case .listGuildRoles: return .GET
    case .addGuildMemberRole: return .PUT
    case .createGuildRole: return .POST
    case .updateGuildRole: return .PATCH
    case .updateGuildRolePositions: return .PATCH
    case .deleteGuildMemberRole: return .DELETE
    case .deleteGuildRole: return .DELETE
    case .getApplicationUserRoleConnection: return .GET
    case .listApplicationRoleConnectionMetadata: return .GET
    case .bulkOverwriteApplicationRoleConnectionMetadata: return .PUT
    case .updateApplicationUserRoleConnection: return .PUT
    case .getGuildScheduledEvent: return .GET
    case .listGuildScheduledEventUsers: return .GET
    case .listGuildScheduledEvents: return .GET
    case .createGuildScheduledEvent: return .POST
    case .updateGuildScheduledEvent: return .PATCH
    case .deleteGuildScheduledEvent: return .DELETE
    case .listSkus: return .GET
    case .getStageInstance: return .GET
    case .createStageInstance: return .POST
    case .updateStageInstance: return .PATCH
    case .deleteStageInstance: return .DELETE
    case .getGuildSticker: return .GET
    case .getSticker: return .GET
    case .listGuildStickers: return .GET
    case .createGuildSticker: return .POST
    case .updateGuildSticker: return .PATCH
    case .deleteGuildSticker: return .DELETE
    case .getThreadMember: return .GET
    case .listActiveGuildThreads: return .GET
    case .listOwnPrivateArchivedThreads: return .GET
    case .listPrivateArchivedThreads: return .GET
    case .listPublicArchivedThreads: return .GET
    case .listThreadMembers: return .GET
    case .addThreadMember: return .PUT
    case .joinThread: return .PUT
    case .createThread: return .POST
    case .createThreadFromMessage: return .POST
    case .createThreadInForumChannel: return .POST
    case .deleteThreadMember: return .DELETE
    case .leaveThread: return .DELETE
    case .getOwnApplication: return .GET
    case .getOwnUser: return .GET
    case .getUser: return .GET
    case .listOwnConnections: return .GET
    case .updateOwnApplication: return .PATCH
    case .updateOwnUser: return .PATCH
    case .getVoiceState: return .GET
    case .listGuildVoiceRegions: return .GET
    case .listVoiceRegions: return .GET
    case .updateSelfVoiceState: return .PATCH
    case .updateVoiceState: return .PATCH
    case .getGuildWebhooks: return .GET
    case .getWebhook: return .GET
    case .getWebhookByToken: return .GET
    case .getWebhookMessage: return .GET
    case .listChannelWebhooks: return .GET
    case .createWebhook: return .POST
    case .executeWebhook: return .POST
    case .updateWebhook: return .PATCH
    case .updateWebhookByToken: return .PATCH
    case .updateWebhookMessage: return .PATCH
    case .deleteWebhook: return .DELETE
    case .deleteWebhookByToken: return .DELETE
    case .deleteWebhookMessage: return .DELETE
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var countsAgainstGlobalRateLimit: Bool {
    switch self {
    case .listPollAnswerVoters: return true
    case .endPoll: return true
    case .getAutoModerationRule: return true
    case .listAutoModerationRules: return true
    case .createAutoModerationRule: return true
    case .updateAutoModerationRule: return true
    case .deleteAutoModerationRule: return true
    case .listGuildAuditLogEntries: return true
    case .getChannel: return true
    case .listPinnedMessages: return true
    case .addGroupDmUser: return true
    case .pinMessage: return true
    case .setChannelPermissionOverwrite: return true
    case .createDm: return true
    //    case .createGroupDm: return true
    case .followAnnouncementChannel: return true
    case .triggerTypingIndicator: return true
    case .updateChannel: return true
    case .deleteChannel: return true
    case .deleteChannelPermissionOverwrite: return true
    case .deleteGroupDmUser: return true
    case .unpinMessage: return true
    case .getApplicationCommand: return true
    case .getGuildApplicationCommand: return true
    case .getGuildApplicationCommandPermissions: return true
    case .listApplicationCommands: return true
    case .listGuildApplicationCommandPermissions: return true
    case .listGuildApplicationCommands: return true
    case .bulkSetApplicationCommands: return true
    case .bulkSetGuildApplicationCommands: return true
    case .setGuildApplicationCommandPermissions: return true
    case .createApplicationCommand: return true
    case .createGuildApplicationCommand: return true
    case .updateApplicationCommand: return true
    case .updateGuildApplicationCommand: return true
    case .deleteApplicationCommand: return true
    case .deleteGuildApplicationCommand: return true
    case .getGuildEmoji: return true
    case .listGuildEmojis: return true
    case .createGuildEmoji: return true
    case .updateGuildEmoji: return true
    case .deleteGuildEmoji: return true
    case .listEntitlements: return true
    case .consumeEntitlement: return true
    case .createTestEntitlement: return true
    case .deleteTestEntitlement: return true
    case .getBotGateway: return true
    case .getGateway: return true
    case .getGuild: return true
    case .getGuildBan: return true
    case .getGuildOnboarding: return true
    case .getGuildPreview: return true
    case .getGuildVanityUrl: return true
    case .getGuildWelcomeScreen: return true
    case .getGuildWidget: return true
    case .getGuildWidgetPng: return true
    case .getGuildWidgetSettings: return true
    case .listGuildBans: return true
    case .listGuildChannels: return true
    case .listGuildIntegrations: return true
    case .listOwnGuilds: return true
    case .previewPruneGuild: return true
    case .banUserFromGuild: return true
    case .updateGuildOnboarding: return true
    case .bulkBanUsersFromGuild: return true
    case .createGuild: return true
    case .createGuildChannel: return true
    case .pruneGuild: return true
    case .setGuildMfaLevel: return true
    case .updateGuild: return true
    case .updateGuildChannelPositions: return true
    case .updateGuildWelcomeScreen: return true
    case .updateGuildWidgetSettings: return true
    case .deleteGuild: return true
    case .deleteGuildIntegration: return true
    case .leaveGuild: return true
    case .unbanUserFromGuild: return true
    case .getGuildTemplate: return true
    case .listGuildTemplates: return true
    case .syncGuildTemplate: return true
    case .createGuildFromTemplate: return true
    case .createGuildTemplate: return true
    case .updateGuildTemplate: return true
    case .deleteGuildTemplate: return true
    case .getFollowupMessage: return false
    case .getOriginalInteractionResponse: return false
    case .createFollowupMessage: return false
    case .createInteractionResponse: return false
    case .updateFollowupMessage: return false
    case .updateOriginalInteractionResponse: return false
    case .deleteFollowupMessage: return false
    case .deleteOriginalInteractionResponse: return false
    case .listChannelInvites: return true
    case .listGuildInvites: return true
    case .resolveInvite: return true
    case .createChannelInvite: return true
    case .revokeInvite: return true
    case .getGuildMember: return true
    case .getOwnGuildMember: return true
    case .listGuildMembers: return true
    case .searchGuildMembers: return true
    case .addGuildMember: return true
    case .updateGuildMember: return true
    case .updateOwnGuildMember: return true
    case .deleteGuildMember: return true
    case .getMessage: return true
    case .listMessageReactionsByEmoji: return true
    case .listMessages: return true
    case .addMessageReaction: return true
    case .bulkDeleteMessages: return true
    case .createMessage: return true
    case .crosspostMessage: return true
    case .updateMessage: return true
    case .deleteAllMessageReactions: return true
    case .deleteAllMessageReactionsByEmoji: return true
    case .deleteMessage: return true
    case .deleteOwnMessageReaction: return true
    case .deleteUserMessageReaction: return true
    case .getOwnOauth2Application: return true
    case .listGuildRoles: return true
    case .addGuildMemberRole: return true
    case .createGuildRole: return true
    case .updateGuildRole: return true
    case .updateGuildRolePositions: return true
    case .deleteGuildMemberRole: return true
    case .deleteGuildRole: return true
    case .getApplicationUserRoleConnection: return true
    case .listApplicationRoleConnectionMetadata: return true
    case .bulkOverwriteApplicationRoleConnectionMetadata: return true
    case .updateApplicationUserRoleConnection: return true
    case .getGuildScheduledEvent: return true
    case .listGuildScheduledEventUsers: return true
    case .listGuildScheduledEvents: return true
    case .createGuildScheduledEvent: return true
    case .updateGuildScheduledEvent: return true
    case .deleteGuildScheduledEvent: return true
    case .listSkus: return true
    case .getStageInstance: return true
    case .createStageInstance: return true
    case .updateStageInstance: return true
    case .deleteStageInstance: return true
    case .getGuildSticker: return true
    case .getSticker: return true
    case .listGuildStickers: return true
    case .createGuildSticker: return true
    case .updateGuildSticker: return true
    case .deleteGuildSticker: return true
    case .getThreadMember: return true
    case .listActiveGuildThreads: return true
    case .listOwnPrivateArchivedThreads: return true
    case .listPrivateArchivedThreads: return true
    case .listPublicArchivedThreads: return true
    case .listThreadMembers: return true
    case .addThreadMember: return true
    case .joinThread: return true
    case .createThread: return true
    case .createThreadFromMessage: return true
    case .createThreadInForumChannel: return true
    case .deleteThreadMember: return true
    case .leaveThread: return true
    case .getOwnApplication: return true
    case .getOwnUser: return true
    case .getUser: return true
    case .listOwnConnections: return true
    case .updateOwnApplication: return true
    case .updateOwnUser: return true
    case .getVoiceState: return true
    case .listGuildVoiceRegions: return true
    case .listVoiceRegions: return true
    case .updateSelfVoiceState: return true
    case .updateVoiceState: return true
    case .getGuildWebhooks: return true
    case .getWebhook: return true
    case .getWebhookByToken: return true
    case .getWebhookMessage: return true
    case .listChannelWebhooks: return true
    case .createWebhook: return true
    case .executeWebhook: return true
    case .updateWebhook: return true
    case .updateWebhookByToken: return true
    case .updateWebhookMessage: return true
    case .deleteWebhook: return true
    case .deleteWebhookByToken: return true
    case .deleteWebhookMessage: return true
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var requiresAuthorizationHeader: Bool {
    switch self {
    case .listPollAnswerVoters: return true
    case .endPoll: return true
    case .getAutoModerationRule: return true
    case .listAutoModerationRules: return true
    case .createAutoModerationRule: return true
    case .updateAutoModerationRule: return true
    case .deleteAutoModerationRule: return true
    case .listGuildAuditLogEntries: return true
    case .getChannel: return true
    case .listPinnedMessages: return true
    case .addGroupDmUser: return true
    case .pinMessage: return true
    case .setChannelPermissionOverwrite: return true
    case .createDm: return true
    //    case .createGroupDm: return true
    case .followAnnouncementChannel: return true
    case .triggerTypingIndicator: return true
    case .updateChannel: return true
    case .deleteChannel: return true
    case .deleteChannelPermissionOverwrite: return true
    case .deleteGroupDmUser: return true
    case .unpinMessage: return true
    case .getApplicationCommand: return true
    case .getGuildApplicationCommand: return true
    case .getGuildApplicationCommandPermissions: return true
    case .listApplicationCommands: return true
    case .listGuildApplicationCommandPermissions: return true
    case .listGuildApplicationCommands: return true
    case .bulkSetApplicationCommands: return true
    case .bulkSetGuildApplicationCommands: return true
    case .setGuildApplicationCommandPermissions: return true
    case .createApplicationCommand: return true
    case .createGuildApplicationCommand: return true
    case .updateApplicationCommand: return true
    case .updateGuildApplicationCommand: return true
    case .deleteApplicationCommand: return true
    case .deleteGuildApplicationCommand: return true
    case .getGuildEmoji: return true
    case .listGuildEmojis: return true
    case .createGuildEmoji: return true
    case .updateGuildEmoji: return true
    case .deleteGuildEmoji: return true
    case .listEntitlements: return true
    case .consumeEntitlement: return true
    case .createTestEntitlement: return true
    case .deleteTestEntitlement: return true
    case .getBotGateway: return true
    case .getGateway: return true
    case .getGuild: return true
    case .getGuildBan: return true
    case .getGuildOnboarding: return true
    case .getGuildPreview: return true
    case .getGuildVanityUrl: return true
    case .getGuildWelcomeScreen: return true
    case .getGuildWidget: return true
    case .getGuildWidgetPng: return true
    case .getGuildWidgetSettings: return true
    case .listGuildBans: return true
    case .listGuildChannels: return true
    case .listGuildIntegrations: return true
    case .listOwnGuilds: return true
    case .previewPruneGuild: return true
    case .banUserFromGuild: return true
    case .updateGuildOnboarding: return true
    case .bulkBanUsersFromGuild: return true
    case .createGuild: return true
    case .createGuildChannel: return true
    case .pruneGuild: return true
    case .setGuildMfaLevel: return true
    case .updateGuild: return true
    case .updateGuildChannelPositions: return true
    case .updateGuildWelcomeScreen: return true
    case .updateGuildWidgetSettings: return true
    case .deleteGuild: return true
    case .deleteGuildIntegration: return true
    case .leaveGuild: return true
    case .unbanUserFromGuild: return true
    case .getGuildTemplate: return true
    case .listGuildTemplates: return true
    case .syncGuildTemplate: return true
    case .createGuildFromTemplate: return true
    case .createGuildTemplate: return true
    case .updateGuildTemplate: return true
    case .deleteGuildTemplate: return true
    case .getFollowupMessage: return true
    case .getOriginalInteractionResponse: return true
    case .createFollowupMessage: return true
    case .createInteractionResponse: return true
    case .updateFollowupMessage: return true
    case .updateOriginalInteractionResponse: return true
    case .deleteFollowupMessage: return true
    case .deleteOriginalInteractionResponse: return true
    case .listChannelInvites: return true
    case .listGuildInvites: return true
    case .resolveInvite: return true
    case .createChannelInvite: return true
    case .revokeInvite: return true
    case .getGuildMember: return true
    case .getOwnGuildMember: return true
    case .listGuildMembers: return true
    case .searchGuildMembers: return true
    case .addGuildMember: return true
    case .updateGuildMember: return true
    case .updateOwnGuildMember: return true
    case .deleteGuildMember: return true
    case .getMessage: return true
    case .listMessageReactionsByEmoji: return true
    case .listMessages: return true
    case .addMessageReaction: return true
    case .bulkDeleteMessages: return true
    case .createMessage: return true
    case .crosspostMessage: return true
    case .updateMessage: return true
    case .deleteAllMessageReactions: return true
    case .deleteAllMessageReactionsByEmoji: return true
    case .deleteMessage: return true
    case .deleteOwnMessageReaction: return true
    case .deleteUserMessageReaction: return true
    case .getOwnOauth2Application: return true
    case .listGuildRoles: return true
    case .addGuildMemberRole: return true
    case .createGuildRole: return true
    case .updateGuildRole: return true
    case .updateGuildRolePositions: return true
    case .deleteGuildMemberRole: return true
    case .deleteGuildRole: return true
    case .getApplicationUserRoleConnection: return true
    case .listApplicationRoleConnectionMetadata: return true
    case .bulkOverwriteApplicationRoleConnectionMetadata: return true
    case .updateApplicationUserRoleConnection: return true
    case .getGuildScheduledEvent: return true
    case .listGuildScheduledEventUsers: return true
    case .listGuildScheduledEvents: return true
    case .createGuildScheduledEvent: return true
    case .updateGuildScheduledEvent: return true
    case .deleteGuildScheduledEvent: return true
    case .listSkus: return true
    case .getStageInstance: return true
    case .createStageInstance: return true
    case .updateStageInstance: return true
    case .deleteStageInstance: return true
    case .getGuildSticker: return true
    case .getSticker: return true
    case .listGuildStickers: return true
    case .createGuildSticker: return true
    case .updateGuildSticker: return true
    case .deleteGuildSticker: return true
    case .getThreadMember: return true
    case .listActiveGuildThreads: return true
    case .listOwnPrivateArchivedThreads: return true
    case .listPrivateArchivedThreads: return true
    case .listPublicArchivedThreads: return true
    case .listThreadMembers: return true
    case .addThreadMember: return true
    case .joinThread: return true
    case .createThread: return true
    case .createThreadFromMessage: return true
    case .createThreadInForumChannel: return true
    case .deleteThreadMember: return true
    case .leaveThread: return true
    case .getOwnApplication: return true
    case .getOwnUser: return true
    case .getUser: return true
    case .listOwnConnections: return true
    case .updateOwnApplication: return true
    case .updateOwnUser: return true
    case .getVoiceState: return true
    case .listGuildVoiceRegions: return true
    case .listVoiceRegions: return true
    case .updateSelfVoiceState: return true
    case .updateVoiceState: return true
    case .getGuildWebhooks: return true
    case .getWebhook: return true
    case .getWebhookByToken: return false
    case .getWebhookMessage: return false
    case .listChannelWebhooks: return true
    case .createWebhook: return true
    case .executeWebhook: return false
    case .updateWebhook: return true
    case .updateWebhookByToken: return false
    case .updateWebhookMessage: return false
    case .deleteWebhook: return true
    case .deleteWebhookByToken: return false
    case .deleteWebhookMessage: return false
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var parameters: [String] {
    switch self {
    case .listPollAnswerVoters(let channelId, let messageId, let answerId):
      return [channelId.rawValue, messageId.rawValue, "\(answerId)"]
    case .endPoll(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .getAutoModerationRule(let guildId, let ruleId):
      return [guildId.rawValue, ruleId.rawValue]
    case .listAutoModerationRules(let guildId):
      return [guildId.rawValue]
    case .createAutoModerationRule(let guildId):
      return [guildId.rawValue]
    case .updateAutoModerationRule(let guildId, let ruleId):
      return [guildId.rawValue, ruleId.rawValue]
    case .deleteAutoModerationRule(let guildId, let ruleId):
      return [guildId.rawValue, ruleId.rawValue]
    case .listGuildAuditLogEntries(let guildId):
      return [guildId.rawValue]
    case .getChannel(let channelId):
      return [channelId.rawValue]
    case .listPinnedMessages(let channelId):
      return [channelId.rawValue]
    case .addGroupDmUser(let channelId, let userId):
      return [channelId.rawValue, userId.rawValue]
    case .pinMessage(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .setChannelPermissionOverwrite(let channelId, let overwriteId):
      return [channelId.rawValue, overwriteId.rawValue]
    case .createDm:
      return []
    //    case .createGroupDm:
    //      return []
    case .followAnnouncementChannel(let channelId):
      return [channelId.rawValue]
    case .triggerTypingIndicator(let channelId):
      return [channelId.rawValue]
    case .updateChannel(let channelId):
      return [channelId.rawValue]
    case .deleteChannel(let channelId):
      return [channelId.rawValue]
    case .deleteChannelPermissionOverwrite(let channelId, let overwriteId):
      return [channelId.rawValue, overwriteId.rawValue]
    case .deleteGroupDmUser(let channelId, let userId):
      return [channelId.rawValue, userId.rawValue]
    case .unpinMessage(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .getApplicationCommand(let applicationId, let commandId):
      return [applicationId.rawValue, commandId.rawValue]
    case .getGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case .getGuildApplicationCommandPermissions(
      let
        applicationId,
      let guildId,
      let commandId
    ):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case .listApplicationCommands(let applicationId):
      return [applicationId.rawValue]
    case .listGuildApplicationCommandPermissions(let applicationId, let guildId):
      return [applicationId.rawValue, guildId.rawValue]
    case .listGuildApplicationCommands(let applicationId, let guildId):
      return [applicationId.rawValue, guildId.rawValue]
    case .bulkSetApplicationCommands(let applicationId):
      return [applicationId.rawValue]
    case .bulkSetGuildApplicationCommands(let applicationId, let guildId):
      return [applicationId.rawValue, guildId.rawValue]
    case .setGuildApplicationCommandPermissions(
      let
        applicationId,
      let guildId,
      let commandId
    ):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case .createApplicationCommand(let applicationId):
      return [applicationId.rawValue]
    case .createGuildApplicationCommand(let applicationId, let guildId):
      return [applicationId.rawValue, guildId.rawValue]
    case .updateApplicationCommand(let applicationId, let commandId):
      return [applicationId.rawValue, commandId.rawValue]
    case .updateGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case .deleteApplicationCommand(let applicationId, let commandId):
      return [applicationId.rawValue, commandId.rawValue]
    case .deleteGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case .getGuildEmoji(let guildId, let emojiId):
      return [guildId.rawValue, emojiId.rawValue]
    case .listGuildEmojis(let guildId):
      return [guildId.rawValue]
    case .createGuildEmoji(let guildId):
      return [guildId.rawValue]
    case .updateGuildEmoji(let guildId, let emojiId):
      return [guildId.rawValue, emojiId.rawValue]
    case .deleteGuildEmoji(let guildId, let emojiId):
      return [guildId.rawValue, emojiId.rawValue]
    case .listEntitlements(let applicationId):
      return [applicationId.rawValue]
    case .consumeEntitlement(let applicationId, let entitlementId):
      return [applicationId.rawValue, entitlementId.rawValue]
    case .createTestEntitlement(let applicationId):
      return [applicationId.rawValue]
    case .deleteTestEntitlement(let applicationId, let entitlementId):
      return [applicationId.rawValue, entitlementId.rawValue]
    case .getBotGateway:
      return []
    case .getGateway:
      return []
    case .getGuild(let guildId):
      return [guildId.rawValue]
    case .getGuildBan(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .getGuildOnboarding(let guildId):
      return [guildId.rawValue]
    case .getGuildPreview(let guildId):
      return [guildId.rawValue]
    case .getGuildVanityUrl(let guildId):
      return [guildId.rawValue]
    case .getGuildWelcomeScreen(let guildId):
      return [guildId.rawValue]
    case .getGuildWidget(let guildId):
      return [guildId.rawValue]
    case .getGuildWidgetPng(let guildId):
      return [guildId.rawValue]
    case .getGuildWidgetSettings(let guildId):
      return [guildId.rawValue]
    case .listGuildBans(let guildId):
      return [guildId.rawValue]
    case .listGuildChannels(let guildId):
      return [guildId.rawValue]
    case .listGuildIntegrations(let guildId):
      return [guildId.rawValue]
    case .listOwnGuilds:
      return []
    case .previewPruneGuild(let guildId):
      return [guildId.rawValue]
    case .banUserFromGuild(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .updateGuildOnboarding(let guildId):
      return [guildId.rawValue]
    case .bulkBanUsersFromGuild(let guildId):
      return [guildId.rawValue]
    case .createGuild:
      return []
    case .createGuildChannel(let guildId):
      return [guildId.rawValue]
    case .pruneGuild(let guildId):
      return [guildId.rawValue]
    case .setGuildMfaLevel(let guildId):
      return [guildId.rawValue]
    case .updateGuild(let guildId):
      return [guildId.rawValue]
    case .updateGuildChannelPositions(let guildId):
      return [guildId.rawValue]
    case .updateGuildWelcomeScreen(let guildId):
      return [guildId.rawValue]
    case .updateGuildWidgetSettings(let guildId):
      return [guildId.rawValue]
    case .deleteGuild(let guildId):
      return [guildId.rawValue]
    case .deleteGuildIntegration(let guildId, let integrationId):
      return [guildId.rawValue, integrationId.rawValue]
    case .leaveGuild(let guildId):
      return [guildId.rawValue]
    case .unbanUserFromGuild(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .getGuildTemplate(let code):
      return [code]
    case .listGuildTemplates(let guildId):
      return [guildId.rawValue]
    case .syncGuildTemplate(let guildId, let code):
      return [guildId.rawValue, code]
    case .createGuildFromTemplate(let code):
      return [code]
    case .createGuildTemplate(let guildId):
      return [guildId.rawValue]
    case .updateGuildTemplate(let guildId, let code):
      return [guildId.rawValue, code]
    case .deleteGuildTemplate(let guildId, let code):
      return [guildId.rawValue, code]
    case .getFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      return [applicationId.rawValue, interactionToken, messageId.rawValue]
    case .getOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      return [applicationId.rawValue, interactionToken]
    case .createFollowupMessage(let applicationId, let interactionToken):
      return [applicationId.rawValue, interactionToken]
    case .createInteractionResponse(let interactionId, let interactionToken):
      return [interactionId.rawValue, interactionToken]
    case .updateFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      return [applicationId.rawValue, interactionToken, messageId.rawValue]
    case .updateOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      return [applicationId.rawValue, interactionToken]
    case .deleteFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      return [applicationId.rawValue, interactionToken, messageId.rawValue]
    case .deleteOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      return [applicationId.rawValue, interactionToken]
    case .listChannelInvites(let channelId):
      return [channelId.rawValue]
    case .listGuildInvites(let guildId):
      return [guildId.rawValue]
    case .resolveInvite(let code):
      return [code]
    case .createChannelInvite(let channelId):
      return [channelId.rawValue]
    case .revokeInvite(let code):
      return [code]
    case .getGuildMember(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .getOwnGuildMember(let guildId):
      return [guildId.rawValue]
    case .listGuildMembers(let guildId):
      return [guildId.rawValue]
    case .searchGuildMembers(let guildId):
      return [guildId.rawValue]
    case .addGuildMember(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .updateGuildMember(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .updateOwnGuildMember(let guildId):
      return [guildId.rawValue]
    case .deleteGuildMember(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .getMessage(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .listMessageReactionsByEmoji(
      let channelId,
      let messageId,
      let emojiName
    ):
      return [channelId.rawValue, messageId.rawValue, emojiName]
    case .listMessages(let channelId):
      return [channelId.rawValue]
    case .addMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
    ):
      return [
        channelId.rawValue, messageId.rawValue, emojiName,
      ]
    case .bulkDeleteMessages(let channelId):
      return [channelId.rawValue]
    case .createMessage(let channelId):
      return [channelId.rawValue]
    case .crosspostMessage(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .updateMessage(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .deleteAllMessageReactions(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .deleteAllMessageReactionsByEmoji(
      let channelId,
      let messageId,
      let emojiName
    ):
      return [channelId.rawValue, messageId.rawValue, emojiName]
    case .deleteMessage(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .deleteOwnMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
      let type
    ):
      return [
        channelId.rawValue, messageId.rawValue, emojiName,
        type.rawValue.description,
      ]
    case .deleteUserMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
      let userId,
      let type
    ):
      return [
        channelId.rawValue, messageId.rawValue, emojiName, userId.rawValue,
        type.rawValue.description,
      ]
    case .getOwnOauth2Application:
      return []
    case .listGuildRoles(let guildId):
      return [guildId.rawValue]
    case .addGuildMemberRole(let guildId, let userId, let roleId):
      return [guildId.rawValue, userId.rawValue, roleId.rawValue]
    case .createGuildRole(let guildId):
      return [guildId.rawValue]
    case .updateGuildRole(let guildId, let roleId):
      return [guildId.rawValue, roleId.rawValue]
    case .updateGuildRolePositions(let guildId):
      return [guildId.rawValue]
    case .deleteGuildMemberRole(let guildId, let userId, let roleId):
      return [guildId.rawValue, userId.rawValue, roleId.rawValue]
    case .deleteGuildRole(let guildId, let roleId):
      return [guildId.rawValue, roleId.rawValue]
    case .getApplicationUserRoleConnection(let applicationId):
      return [applicationId.rawValue]
    case .listApplicationRoleConnectionMetadata(let applicationId):
      return [applicationId.rawValue]
    case .bulkOverwriteApplicationRoleConnectionMetadata(let applicationId):
      return [applicationId.rawValue]
    case .updateApplicationUserRoleConnection(let applicationId):
      return [applicationId.rawValue]
    case .getGuildScheduledEvent(let guildId, let guildScheduledEventId):
      return [guildId.rawValue, guildScheduledEventId.rawValue]
    case .listGuildScheduledEventUsers(let guildId, let guildScheduledEventId):
      return [guildId.rawValue, guildScheduledEventId.rawValue]
    case .listGuildScheduledEvents(let guildId):
      return [guildId.rawValue]
    case .createGuildScheduledEvent(let guildId):
      return [guildId.rawValue]
    case .updateGuildScheduledEvent(let guildId, let guildScheduledEventId):
      return [guildId.rawValue, guildScheduledEventId.rawValue]
    case .deleteGuildScheduledEvent(let guildId, let guildScheduledEventId):
      return [guildId.rawValue, guildScheduledEventId.rawValue]
    case .listSkus(let applicationId):
      return [applicationId.rawValue]
    case .getStageInstance(let channelId):
      return [channelId.rawValue]
    case .createStageInstance:
      return []
    case .updateStageInstance(let channelId):
      return [channelId.rawValue]
    case .deleteStageInstance(let channelId):
      return [channelId.rawValue]
    case .getGuildSticker(let guildId, let stickerId):
      return [guildId.rawValue, stickerId.rawValue]
    case .getSticker(let stickerId):
      return [stickerId.rawValue]
    case .listGuildStickers(let guildId):
      return [guildId.rawValue]
    case .createGuildSticker(let guildId):
      return [guildId.rawValue]
    case .updateGuildSticker(let guildId, let stickerId):
      return [guildId.rawValue, stickerId.rawValue]
    case .deleteGuildSticker(let guildId, let stickerId):
      return [guildId.rawValue, stickerId.rawValue]
    case .getThreadMember(let channelId, let userId):
      return [channelId.rawValue, userId.rawValue]
    case .listActiveGuildThreads(let guildId):
      return [guildId.rawValue]
    case .listOwnPrivateArchivedThreads(let channelId):
      return [channelId.rawValue]
    case .listPrivateArchivedThreads(let channelId):
      return [channelId.rawValue]
    case .listPublicArchivedThreads(let channelId):
      return [channelId.rawValue]
    case .listThreadMembers(let channelId):
      return [channelId.rawValue]
    case .addThreadMember(let channelId, let userId):
      return [channelId.rawValue, userId.rawValue]
    case .joinThread(let channelId):
      return [channelId.rawValue]
    case .createThread(let channelId):
      return [channelId.rawValue]
    case .createThreadFromMessage(let channelId, let messageId):
      return [channelId.rawValue, messageId.rawValue]
    case .createThreadInForumChannel(let channelId):
      return [channelId.rawValue]
    case .deleteThreadMember(let channelId, let userId):
      return [channelId.rawValue, userId.rawValue]
    case .leaveThread(let channelId):
      return [channelId.rawValue]
    case .getOwnApplication:
      return []
    case .getOwnUser:
      return []
    case .getUser(let userId):
      return [userId.rawValue]
    case .listOwnConnections:
      return []
    case .updateOwnApplication:
      return []
    case .updateOwnUser:
      return []
    case .getVoiceState(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .listGuildVoiceRegions(let guildId):
      return [guildId.rawValue]
    case .listVoiceRegions:
      return []
    case .updateSelfVoiceState(let guildId):
      return [guildId.rawValue]
    case .updateVoiceState(let guildId, let userId):
      return [guildId.rawValue, userId.rawValue]
    case .getGuildWebhooks(let guildId):
      return [guildId.rawValue]
    case .getWebhook(let webhookId):
      return [webhookId.rawValue]
    case .getWebhookByToken(let webhookId, let webhookToken):
      return [webhookId.rawValue, webhookToken]
    case .getWebhookMessage(let webhookId, let webhookToken, let messageId):
      return [webhookId.rawValue, webhookToken, messageId.rawValue]
    case .listChannelWebhooks(let channelId):
      return [channelId.rawValue]
    case .createWebhook(let channelId):
      return [channelId.rawValue]
    case .executeWebhook(let webhookId, let webhookToken):
      return [webhookId.rawValue, webhookToken]
    case .updateWebhook(let webhookId):
      return [webhookId.rawValue]
    case .updateWebhookByToken(let webhookId, let webhookToken):
      return [webhookId.rawValue, webhookToken]
    case .updateWebhookMessage(let webhookId, let webhookToken, let messageId):
      return [webhookId.rawValue, webhookToken, messageId.rawValue]
    case .deleteWebhook(let webhookId):
      return [webhookId.rawValue]
    case .deleteWebhookByToken(let webhookId, let webhookToken):
      return [webhookId.rawValue, webhookToken]
    case .deleteWebhookMessage(let webhookId, let webhookToken, let messageId):
      return [webhookId.rawValue, webhookToken, messageId.rawValue]
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var id: Int {
    switch self {
    case .listPollAnswerVoters: return 1
    case .endPoll: return 2
    case .getAutoModerationRule: return 3
    case .listAutoModerationRules: return 4
    case .createAutoModerationRule: return 5
    case .updateAutoModerationRule: return 6
    case .deleteAutoModerationRule: return 7
    case .listGuildAuditLogEntries: return 8
    case .getChannel: return 9
    case .listPinnedMessages: return 10
    case .addGroupDmUser: return 11
    case .pinMessage: return 12
    case .setChannelPermissionOverwrite: return 13
    case .createDm: return 14
    //    case .createGroupDm: return 15
    case .followAnnouncementChannel: return 16
    case .triggerTypingIndicator: return 17
    case .updateChannel: return 18
    case .deleteChannel: return 19
    case .deleteChannelPermissionOverwrite: return 20
    case .deleteGroupDmUser: return 21
    case .unpinMessage: return 22
    case .getApplicationCommand: return 23
    case .getGuildApplicationCommand: return 24
    case .getGuildApplicationCommandPermissions: return 25
    case .listApplicationCommands: return 26
    case .listGuildApplicationCommandPermissions: return 27
    case .listGuildApplicationCommands: return 28
    case .bulkSetApplicationCommands: return 29
    case .bulkSetGuildApplicationCommands: return 30
    case .setGuildApplicationCommandPermissions: return 31
    case .createApplicationCommand: return 32
    case .createGuildApplicationCommand: return 33
    case .updateApplicationCommand: return 34
    case .updateGuildApplicationCommand: return 35
    case .deleteApplicationCommand: return 36
    case .deleteGuildApplicationCommand: return 37
    case .getGuildEmoji: return 38
    case .listGuildEmojis: return 39
    case .createGuildEmoji: return 40
    case .updateGuildEmoji: return 41
    case .deleteGuildEmoji: return 42
    case .listEntitlements: return 43
    case .consumeEntitlement: return 44
    case .createTestEntitlement: return 45
    case .deleteTestEntitlement: return 46
    case .getBotGateway: return 47
    case .getGateway: return 48
    case .getGuild: return 49
    case .getGuildBan: return 50
    case .getGuildOnboarding: return 51
    case .getGuildPreview: return 52
    case .getGuildVanityUrl: return 53
    case .getGuildWelcomeScreen: return 54
    case .getGuildWidget: return 55
    case .getGuildWidgetPng: return 56
    case .getGuildWidgetSettings: return 57
    case .listGuildBans: return 58
    case .listGuildChannels: return 59
    case .listGuildIntegrations: return 60
    case .listOwnGuilds: return 61
    case .previewPruneGuild: return 62
    case .banUserFromGuild: return 63
    case .updateGuildOnboarding: return 64
    case .bulkBanUsersFromGuild: return 65
    case .createGuild: return 66
    case .createGuildChannel: return 67
    case .pruneGuild: return 68
    case .setGuildMfaLevel: return 69
    case .updateGuild: return 70
    case .updateGuildChannelPositions: return 71
    case .updateGuildWelcomeScreen: return 72
    case .updateGuildWidgetSettings: return 73
    case .deleteGuild: return 74
    case .deleteGuildIntegration: return 75
    case .leaveGuild: return 76
    case .unbanUserFromGuild: return 77
    case .getGuildTemplate: return 78
    case .listGuildTemplates: return 79
    case .syncGuildTemplate: return 80
    case .createGuildFromTemplate: return 81
    case .createGuildTemplate: return 82
    case .updateGuildTemplate: return 83
    case .deleteGuildTemplate: return 84
    case .getFollowupMessage: return 85
    case .getOriginalInteractionResponse: return 86
    case .createFollowupMessage: return 87
    case .createInteractionResponse: return 88
    case .updateFollowupMessage: return 89
    case .updateOriginalInteractionResponse: return 90
    case .deleteFollowupMessage: return 91
    case .deleteOriginalInteractionResponse: return 92
    case .listChannelInvites: return 93
    case .listGuildInvites: return 94
    case .resolveInvite: return 95
    case .createChannelInvite: return 96
    case .revokeInvite: return 97
    case .getGuildMember: return 98
    case .getOwnGuildMember: return 99
    case .listGuildMembers: return 100
    case .searchGuildMembers: return 101
    case .addGuildMember: return 102
    case .updateGuildMember: return 103
    case .updateOwnGuildMember: return 104
    case .deleteGuildMember: return 105
    case .getMessage: return 106
    case .listMessageReactionsByEmoji: return 107
    case .listMessages: return 108
    case .addMessageReaction: return 109
    case .bulkDeleteMessages: return 110
    case .createMessage: return 111
    case .crosspostMessage: return 112
    case .updateMessage: return 113
    case .deleteAllMessageReactions: return 114
    case .deleteAllMessageReactionsByEmoji: return 115
    case .deleteMessage: return 116
    case .deleteOwnMessageReaction: return 117
    case .deleteUserMessageReaction: return 118
    case .getOwnOauth2Application: return 119
    case .listGuildRoles: return 120
    case .addGuildMemberRole: return 121
    case .createGuildRole: return 122
    case .updateGuildRole: return 123
    case .updateGuildRolePositions: return 124
    case .deleteGuildMemberRole: return 125
    case .deleteGuildRole: return 126
    case .getApplicationUserRoleConnection: return 127
    case .listApplicationRoleConnectionMetadata: return 128
    case .bulkOverwriteApplicationRoleConnectionMetadata: return 129
    case .updateApplicationUserRoleConnection: return 130
    case .getGuildScheduledEvent: return 131
    case .listGuildScheduledEventUsers: return 132
    case .listGuildScheduledEvents: return 133
    case .createGuildScheduledEvent: return 134
    case .updateGuildScheduledEvent: return 135
    case .deleteGuildScheduledEvent: return 136
    case .listSkus: return 137
    case .getStageInstance: return 138
    case .createStageInstance: return 139
    case .updateStageInstance: return 140
    case .deleteStageInstance: return 141
    case .getGuildSticker: return 142
    case .getSticker: return 143
    case .listGuildStickers: return 144
    case .createGuildSticker: return 146
    case .updateGuildSticker: return 147
    case .deleteGuildSticker: return 148
    case .getThreadMember: return 149
    case .listActiveGuildThreads: return 150
    case .listOwnPrivateArchivedThreads: return 151
    case .listPrivateArchivedThreads: return 152
    case .listPublicArchivedThreads: return 153
    case .listThreadMembers: return 154
    case .addThreadMember: return 155
    case .joinThread: return 156
    case .createThread: return 157
    case .createThreadFromMessage: return 158
    case .createThreadInForumChannel: return 159
    case .deleteThreadMember: return 160
    case .leaveThread: return 161
    case .getOwnApplication: return 162
    case .getOwnUser: return 163
    case .getUser: return 164
    case .listOwnConnections: return 165
    case .updateOwnApplication: return 166
    case .updateOwnUser: return 167
    case .getVoiceState: return 168
    case .listGuildVoiceRegions: return 169
    case .listVoiceRegions: return 170
    case .updateSelfVoiceState: return 171
    case .updateVoiceState: return 172
    case .getGuildWebhooks: return 173
    case .getWebhook: return 174
    case .getWebhookByToken: return 175
    case .getWebhookMessage: return 176
    case .listChannelWebhooks: return 177
    case .createWebhook: return 178
    case .executeWebhook: return 179
    case .updateWebhook: return 180
    case .updateWebhookByToken: return 181
    case .updateWebhookMessage: return 182
    case .deleteWebhook: return 183
    case .deleteWebhookByToken: return 184
    case .deleteWebhookMessage: return 185
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var description: String {
    switch self {
    case .listPollAnswerVoters(let channelId, let messageId, let answerId):
      return
        "listPollAnswerVoters(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), answerId: \(answerId))"
    case .endPoll(let channelId, let messageId):
      return
        "endPoll(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .getAutoModerationRule(let guildId, let ruleId):
      return
        "getAutoModerationRule(guildId.rawValue: \(guildId.rawValue), ruleId.rawValue: \(ruleId.rawValue))"
    case .listAutoModerationRules(let guildId):
      return "listAutoModerationRules(guildId.rawValue: \(guildId.rawValue))"
    case .createAutoModerationRule(let guildId):
      return "createAutoModerationRule(guildId.rawValue: \(guildId.rawValue))"
    case .updateAutoModerationRule(let guildId, let ruleId):
      return
        "updateAutoModerationRule(guildId.rawValue: \(guildId.rawValue), ruleId.rawValue: \(ruleId.rawValue))"
    case .deleteAutoModerationRule(let guildId, let ruleId):
      return
        "deleteAutoModerationRule(guildId.rawValue: \(guildId.rawValue), ruleId.rawValue: \(ruleId.rawValue))"
    case .listGuildAuditLogEntries(let guildId):
      return "listGuildAuditLogEntries(guildId.rawValue: \(guildId.rawValue))"
    case .getChannel(let channelId):
      return "getChannel(channelId.rawValue: \(channelId.rawValue))"
    case .listPinnedMessages(let channelId):
      return "listPinnedMessages(channelId.rawValue: \(channelId.rawValue))"
    case .addGroupDmUser(let channelId, let userId):
      return
        "addGroupDmUser(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .pinMessage(let channelId, let messageId):
      return
        "pinMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .setChannelPermissionOverwrite(let channelId, let overwriteId):
      return
        "setChannelPermissionOverwrite(channelId.rawValue: \(channelId.rawValue), overwriteId.rawValue: \(overwriteId.rawValue))"
    case .createDm:
      return "createDm"
    //    case .createGroupDm:
    //      return "createGroupDm"
    case .followAnnouncementChannel(let channelId):
      return
        "followAnnouncementChannel(channelId.rawValue: \(channelId.rawValue))"
    case .triggerTypingIndicator(let channelId):
      return "triggerTypingIndicator(channelId.rawValue: \(channelId.rawValue))"
    case .updateChannel(let channelId):
      return "updateChannel(channelId.rawValue: \(channelId.rawValue))"
    case .deleteChannel(let channelId):
      return "deleteChannel(channelId.rawValue: \(channelId.rawValue))"
    case .deleteChannelPermissionOverwrite(let channelId, let overwriteId):
      return
        "deleteChannelPermissionOverwrite(channelId.rawValue: \(channelId.rawValue), overwriteId.rawValue: \(overwriteId.rawValue))"
    case .deleteGroupDmUser(let channelId, let userId):
      return
        "deleteGroupDmUser(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .unpinMessage(let channelId, let messageId):
      return
        "unpinMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .getApplicationCommand(let applicationId, let commandId):
      return
        "getApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case .getGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      return
        "getGuildApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case .getGuildApplicationCommandPermissions(
      let
        applicationId,
      let guildId,
      let commandId
    ):
      return
        "getGuildApplicationCommandPermissions(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case .listApplicationCommands(let applicationId):
      return
        "listApplicationCommands(applicationId.rawValue: \(applicationId.rawValue))"
    case .listGuildApplicationCommandPermissions(let applicationId, let guildId):
      return
        "listGuildApplicationCommandPermissions(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue))"
    case .listGuildApplicationCommands(let applicationId, let guildId):
      return
        "listGuildApplicationCommands(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue))"
    case .bulkSetApplicationCommands(let applicationId):
      return
        "bulkSetApplicationCommands(applicationId.rawValue: \(applicationId.rawValue))"
    case .bulkSetGuildApplicationCommands(let applicationId, let guildId):
      return
        "bulkSetGuildApplicationCommands(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue))"
    case .setGuildApplicationCommandPermissions(
      let
        applicationId,
      let guildId,
      let commandId
    ):
      return
        "setGuildApplicationCommandPermissions(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case .createApplicationCommand(let applicationId):
      return
        "createApplicationCommand(applicationId.rawValue: \(applicationId.rawValue))"
    case .createGuildApplicationCommand(let applicationId, let guildId):
      return
        "createGuildApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue))"
    case .updateApplicationCommand(let applicationId, let commandId):
      return
        "updateApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case .updateGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      return
        "updateGuildApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case .deleteApplicationCommand(let applicationId, let commandId):
      return
        "deleteApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case .deleteGuildApplicationCommand(
      let applicationId,
      let guildId,
      let commandId
    ):
      return
        "deleteGuildApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case .getGuildEmoji(let guildId, let emojiId):
      return
        "getGuildEmoji(guildId.rawValue: \(guildId.rawValue), emojiId.rawValue: \(emojiId.rawValue))"
    case .listGuildEmojis(let guildId):
      return "listGuildEmojis(guildId.rawValue: \(guildId.rawValue))"
    case .createGuildEmoji(let guildId):
      return "createGuildEmoji(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuildEmoji(let guildId, let emojiId):
      return
        "updateGuildEmoji(guildId.rawValue: \(guildId.rawValue), emojiId.rawValue: \(emojiId.rawValue))"
    case .deleteGuildEmoji(let guildId, let emojiId):
      return
        "deleteGuildEmoji(guildId.rawValue: \(guildId.rawValue), emojiId.rawValue: \(emojiId.rawValue))"
    case .listEntitlements(let applicationId):
      return
        "listEntitlements(applicationId.rawValue: \(applicationId.rawValue))"
    case .consumeEntitlement(let applicationId, let entitlementId):
      return
        "consumeEntitlement(applicationId.rawValue: \(applicationId.rawValue), entitlementId.rawValue: \(entitlementId.rawValue))"
    case .createTestEntitlement(let applicationId):
      return
        "createTestEntitlement(applicationId.rawValue: \(applicationId.rawValue))"
    case .deleteTestEntitlement(let applicationId, let entitlementId):
      return
        "deleteTestEntitlement(applicationId.rawValue: \(applicationId.rawValue), entitlementId.rawValue: \(entitlementId.rawValue))"
    case .getBotGateway:
      return "getBotGateway"
    case .getGateway:
      return "getGateway"
    case .getGuild(let guildId):
      return "getGuild(guildId.rawValue: \(guildId.rawValue))"
    case .getGuildBan(let guildId, let userId):
      return
        "getGuildBan(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .getGuildOnboarding(let guildId):
      return "getGuildOnboarding(guildId.rawValue: \(guildId.rawValue))"
    case .getGuildPreview(let guildId):
      return "getGuildPreview(guildId.rawValue: \(guildId.rawValue))"
    case .getGuildVanityUrl(let guildId):
      return "getGuildVanityUrl(guildId.rawValue: \(guildId.rawValue))"
    case .getGuildWelcomeScreen(let guildId):
      return "getGuildWelcomeScreen(guildId.rawValue: \(guildId.rawValue))"
    case .getGuildWidget(let guildId):
      return "getGuildWidget(guildId.rawValue: \(guildId.rawValue))"
    case .getGuildWidgetPng(let guildId):
      return "getGuildWidgetPng(guildId.rawValue: \(guildId.rawValue))"
    case .getGuildWidgetSettings(let guildId):
      return "getGuildWidgetSettings(guildId.rawValue: \(guildId.rawValue))"
    case .listGuildBans(let guildId):
      return "listGuildBans(guildId.rawValue: \(guildId.rawValue))"
    case .listGuildChannels(let guildId):
      return "listGuildChannels(guildId.rawValue: \(guildId.rawValue))"
    case .listGuildIntegrations(let guildId):
      return "listGuildIntegrations(guildId.rawValue: \(guildId.rawValue))"
    case .listOwnGuilds:
      return "listOwnGuilds"
    case .previewPruneGuild(let guildId):
      return "previewPruneGuild(guildId.rawValue: \(guildId.rawValue))"
    case .banUserFromGuild(let guildId, let userId):
      return
        "banUserFromGuild(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .updateGuildOnboarding(let guildId):
      return "updateGuildOnboarding(guildId.rawValue: \(guildId.rawValue))"
    case .bulkBanUsersFromGuild(let guildId):
      return "bulkBanUsersFromGuild(guildId.rawValue: \(guildId.rawValue))"
    case .createGuild:
      return "createGuild"
    case .createGuildChannel(let guildId):
      return "createGuildChannel(guildId.rawValue: \(guildId.rawValue))"
    case .pruneGuild(let guildId):
      return "pruneGuild(guildId.rawValue: \(guildId.rawValue))"
    case .setGuildMfaLevel(let guildId):
      return "setGuildMfaLevel(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuild(let guildId):
      return "updateGuild(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuildChannelPositions(let guildId):
      return
        "updateGuildChannelPositions(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuildWelcomeScreen(let guildId):
      return "updateGuildWelcomeScreen(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuildWidgetSettings(let guildId):
      return "updateGuildWidgetSettings(guildId.rawValue: \(guildId.rawValue))"
    case .deleteGuild(let guildId):
      return "deleteGuild(guildId.rawValue: \(guildId.rawValue))"
    case .deleteGuildIntegration(let guildId, let integrationId):
      return
        "deleteGuildIntegration(guildId.rawValue: \(guildId.rawValue), integrationId.rawValue: \(integrationId.rawValue))"
    case .leaveGuild(let guildId):
      return "leaveGuild(guildId.rawValue: \(guildId.rawValue))"
    case .unbanUserFromGuild(let guildId, let userId):
      return
        "unbanUserFromGuild(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .getGuildTemplate(let code):
      return "getGuildTemplate(code: \(code))"
    case .listGuildTemplates(let guildId):
      return "listGuildTemplates(guildId.rawValue: \(guildId.rawValue))"
    case .syncGuildTemplate(let guildId, let code):
      return
        "syncGuildTemplate(guildId.rawValue: \(guildId.rawValue), code: \(code))"
    case .createGuildFromTemplate(let code):
      return "createGuildFromTemplate(code: \(code))"
    case .createGuildTemplate(let guildId):
      return "createGuildTemplate(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuildTemplate(let guildId, let code):
      return
        "updateGuildTemplate(guildId.rawValue: \(guildId.rawValue), code: \(code))"
    case .deleteGuildTemplate(let guildId, let code):
      return
        "deleteGuildTemplate(guildId.rawValue: \(guildId.rawValue), code: \(code))"
    case .getFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      return
        "getFollowupMessage(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken), messageId.rawValue: \(messageId.rawValue))"
    case .getOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      return
        "getOriginalInteractionResponse(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken))"
    case .createFollowupMessage(let applicationId, let interactionToken):
      return
        "createFollowupMessage(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken))"
    case .createInteractionResponse(let interactionId, let interactionToken):
      return
        "createInteractionResponse(interactionId.rawValue: \(interactionId.rawValue), interactionToken: \(interactionToken))"
    case .updateFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      return
        "updateFollowupMessage(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken), messageId.rawValue: \(messageId.rawValue))"
    case .updateOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      return
        "updateOriginalInteractionResponse(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken))"
    case .deleteFollowupMessage(
      let applicationId,
      let interactionToken,
      let messageId
    ):
      return
        "deleteFollowupMessage(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken), messageId.rawValue: \(messageId.rawValue))"
    case .deleteOriginalInteractionResponse(
      let applicationId,
      let interactionToken
    ):
      return
        "deleteOriginalInteractionResponse(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken))"
    case .listChannelInvites(let channelId):
      return "listChannelInvites(channelId.rawValue: \(channelId.rawValue))"
    case .listGuildInvites(let guildId):
      return "listGuildInvites(guildId.rawValue: \(guildId.rawValue))"
    case .resolveInvite(let code):
      return "resolveInvite(code: \(code))"
    case .createChannelInvite(let channelId):
      return "createChannelInvite(channelId.rawValue: \(channelId.rawValue))"
    case .revokeInvite(let code):
      return "revokeInvite(code: \(code))"
    case .getGuildMember(let guildId, let userId):
      return
        "getGuildMember(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .getOwnGuildMember(let guildId):
      return "getOwnGuildMember(guildId.rawValue: \(guildId.rawValue))"
    case .listGuildMembers(let guildId):
      return "listGuildMembers(guildId.rawValue: \(guildId.rawValue))"
    case .searchGuildMembers(let guildId):
      return "searchGuildMembers(guildId.rawValue: \(guildId.rawValue))"
    case .addGuildMember(let guildId, let userId):
      return
        "addGuildMember(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .updateGuildMember(let guildId, let userId):
      return
        "updateGuildMember(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .updateOwnGuildMember(let guildId):
      return "updateOwnGuildMember(guildId.rawValue: \(guildId.rawValue))"
    case .deleteGuildMember(let guildId, let userId):
      return
        "deleteGuildMember(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .getMessage(let channelId, let messageId):
      return
        "getMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .listMessageReactionsByEmoji(
      let channelId,
      let messageId,
      let emojiName
    ):
      return
        "listMessageReactionsByEmoji(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName))"
    case .listMessages(let channelId):
      return "listMessages(channelId.rawValue: \(channelId.rawValue))"
    case .addMessageReaction(
      let channelId,
      let messageId,
      let emojiName
    ):
      return
        "addMessageReaction(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName))"
    case .bulkDeleteMessages(let channelId):
      return "bulkDeleteMessages(channelId.rawValue: \(channelId.rawValue))"
    case .createMessage(let channelId):
      return "createMessage(channelId.rawValue: \(channelId.rawValue))"
    case .crosspostMessage(let channelId, let messageId):
      return
        "crosspostMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .updateMessage(let channelId, let messageId):
      return
        "updateMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .deleteAllMessageReactions(let channelId, let messageId):
      return
        "deleteAllMessageReactions(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .deleteAllMessageReactionsByEmoji(
      let channelId,
      let messageId,
      let emojiName
    ):
      return
        "deleteAllMessageReactionsByEmoji(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName))"
    case .deleteMessage(let channelId, let messageId):
      return
        "deleteMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .deleteOwnMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
      let type
    ):
      return
        "deleteOwnMessageReaction(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName)), type: \(type.rawValue.description))"
    case .deleteUserMessageReaction(
      let channelId,
      let messageId,
      let emojiName,
      let userId,
      let type
    ):
      return
        "deleteUserMessageReaction(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName), userId.rawValue: \(userId.rawValue), type: \(type.rawValue.description))"
    case .getOwnOauth2Application:
      return "getOwnOauth2Application"
    case .listGuildRoles(let guildId):
      return "listGuildRoles(guildId.rawValue: \(guildId.rawValue))"
    case .addGuildMemberRole(let guildId, let userId, let roleId):
      return
        "addGuildMemberRole(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue), roleId.rawValue: \(roleId.rawValue))"
    case .createGuildRole(let guildId):
      return "createGuildRole(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuildRole(let guildId, let roleId):
      return
        "updateGuildRole(guildId.rawValue: \(guildId.rawValue), roleId.rawValue: \(roleId.rawValue))"
    case .updateGuildRolePositions(let guildId):
      return "updateGuildRolePositions(guildId.rawValue: \(guildId.rawValue))"
    case .deleteGuildMemberRole(let guildId, let userId, let roleId):
      return
        "deleteGuildMemberRole(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue), roleId.rawValue: \(roleId.rawValue))"
    case .deleteGuildRole(let guildId, let roleId):
      return
        "deleteGuildRole(guildId.rawValue: \(guildId.rawValue), roleId.rawValue: \(roleId.rawValue))"
    case .getApplicationUserRoleConnection(let applicationId):
      return
        "getApplicationUserRoleConnection(applicationId.rawValue: \(applicationId.rawValue))"
    case .listApplicationRoleConnectionMetadata(let applicationId):
      return
        "listApplicationRoleConnectionMetadata(applicationId.rawValue: \(applicationId.rawValue))"
    case .bulkOverwriteApplicationRoleConnectionMetadata(let applicationId):
      return
        "bulkOverwriteApplicationRoleConnectionMetadata(applicationId.rawValue: \(applicationId.rawValue))"
    case .updateApplicationUserRoleConnection(let applicationId):
      return
        "updateApplicationUserRoleConnection(applicationId.rawValue: \(applicationId.rawValue))"
    case .getGuildScheduledEvent(let guildId, let guildScheduledEventId):
      return
        "getGuildScheduledEvent(guildId.rawValue: \(guildId.rawValue), guildScheduledEventId.rawValue: \(guildScheduledEventId.rawValue))"
    case .listGuildScheduledEventUsers(let guildId, let guildScheduledEventId):
      return
        "listGuildScheduledEventUsers(guildId.rawValue: \(guildId.rawValue), guildScheduledEventId.rawValue: \(guildScheduledEventId.rawValue))"
    case .listGuildScheduledEvents(let guildId):
      return "listGuildScheduledEvents(guildId.rawValue: \(guildId.rawValue))"
    case .createGuildScheduledEvent(let guildId):
      return "createGuildScheduledEvent(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuildScheduledEvent(let guildId, let guildScheduledEventId):
      return
        "updateGuildScheduledEvent(guildId.rawValue: \(guildId.rawValue), guildScheduledEventId.rawValue: \(guildScheduledEventId.rawValue))"
    case .deleteGuildScheduledEvent(let guildId, let guildScheduledEventId):
      return
        "deleteGuildScheduledEvent(guildId.rawValue: \(guildId.rawValue), guildScheduledEventId.rawValue: \(guildScheduledEventId.rawValue))"
    case .listSkus(let applicationId):
      return "listSkus(applicationId.rawValue: \(applicationId.rawValue))"
    case .getStageInstance(let channelId):
      return "getStageInstance(channelId.rawValue: \(channelId.rawValue))"
    case .createStageInstance:
      return "createStageInstance"
    case .updateStageInstance(let channelId):
      return "updateStageInstance(channelId.rawValue: \(channelId.rawValue))"
    case .deleteStageInstance(let channelId):
      return "deleteStageInstance(channelId.rawValue: \(channelId.rawValue))"
    case .getGuildSticker(let guildId, let stickerId):
      return
        "getGuildSticker(guildId.rawValue: \(guildId.rawValue), stickerId.rawValue: \(stickerId.rawValue))"
    case .getSticker(let stickerId):
      return "getSticker(stickerId.rawValue: \(stickerId.rawValue))"
    case .listGuildStickers(let guildId):
      return "listGuildStickers(guildId.rawValue: \(guildId.rawValue))"
    case .createGuildSticker(let guildId):
      return "createGuildSticker(guildId.rawValue: \(guildId.rawValue))"
    case .updateGuildSticker(let guildId, let stickerId):
      return
        "updateGuildSticker(guildId.rawValue: \(guildId.rawValue), stickerId.rawValue: \(stickerId.rawValue))"
    case .deleteGuildSticker(let guildId, let stickerId):
      return
        "deleteGuildSticker(guildId.rawValue: \(guildId.rawValue), stickerId.rawValue: \(stickerId.rawValue))"
    case .getThreadMember(let channelId, let userId):
      return
        "getThreadMember(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .listActiveGuildThreads(let guildId):
      return "listActiveGuildThreads(guildId.rawValue: \(guildId.rawValue))"
    case .listOwnPrivateArchivedThreads(let channelId):
      return
        "listOwnPrivateArchivedThreads(channelId.rawValue: \(channelId.rawValue))"
    case .listPrivateArchivedThreads(let channelId):
      return
        "listPrivateArchivedThreads(channelId.rawValue: \(channelId.rawValue))"
    case .listPublicArchivedThreads(let channelId):
      return
        "listPublicArchivedThreads(channelId.rawValue: \(channelId.rawValue))"
    case .listThreadMembers(let channelId):
      return "listThreadMembers(channelId.rawValue: \(channelId.rawValue))"
    case .addThreadMember(let channelId, let userId):
      return
        "addThreadMember(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .joinThread(let channelId):
      return "joinThread(channelId.rawValue: \(channelId.rawValue))"
    case .createThread(let channelId):
      return "createThread(channelId.rawValue: \(channelId.rawValue))"
    case .createThreadFromMessage(let channelId, let messageId):
      return
        "createThreadFromMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case .createThreadInForumChannel(let channelId):
      return
        "createThreadInForumChannel(channelId.rawValue: \(channelId.rawValue))"
    case .deleteThreadMember(let channelId, let userId):
      return
        "deleteThreadMember(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .leaveThread(let channelId):
      return "leaveThread(channelId.rawValue: \(channelId.rawValue))"
    case .getOwnApplication:
      return "getOwnApplication"
    case .getOwnUser:
      return "getOwnUser"
    case .getUser(let userId):
      return "getUser(userId.rawValue: \(userId.rawValue))"
    case .listOwnConnections:
      return "listOwnConnections"
    case .updateOwnApplication:
      return "updateOwnApplication"
    case .updateOwnUser:
      return "updateOwnUser"
    case let .getVoiceState(guildId, userId):
      return "getVoiceState(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .listGuildVoiceRegions(let guildId):
      return "listGuildVoiceRegions(guildId.rawValue: \(guildId.rawValue))"
    case .listVoiceRegions:
      return "listVoiceRegions"
    case .updateSelfVoiceState(let guildId):
      return "updateSelfVoiceState(guildId.rawValue: \(guildId.rawValue))"
    case .updateVoiceState(let guildId, let userId):
      return
        "updateVoiceState(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case .getGuildWebhooks(let guildId):
      return "getGuildWebhooks(guildId.rawValue: \(guildId.rawValue))"
    case .getWebhook(let webhookId):
      return "getWebhook(webhookId.rawValue: \(webhookId.rawValue))"
    case .getWebhookByToken(let webhookId, let webhookToken):
      return
        "getWebhookByToken(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken))"
    case .getWebhookMessage(let webhookId, let webhookToken, let messageId):
      return
        "getWebhookMessage(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken), messageId.rawValue: \(messageId.rawValue))"
    case .listChannelWebhooks(let channelId):
      return "listChannelWebhooks(channelId.rawValue: \(channelId.rawValue))"
    case .createWebhook(let channelId):
      return "createWebhook(channelId.rawValue: \(channelId.rawValue))"
    case .executeWebhook(let webhookId, let webhookToken):
      return
        "executeWebhook(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken))"
    case .updateWebhook(let webhookId):
      return "updateWebhook(webhookId.rawValue: \(webhookId.rawValue))"
    case .updateWebhookByToken(let webhookId, let webhookToken):
      return
        "updateWebhookByToken(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken))"
    case .updateWebhookMessage(let webhookId, let webhookToken, let messageId):
      return
        "updateWebhookMessage(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken), messageId.rawValue: \(messageId.rawValue))"
    case .deleteWebhook(let webhookId):
      return "deleteWebhook(webhookId.rawValue: \(webhookId.rawValue))"
    case .deleteWebhookByToken(let webhookId, let webhookToken):
      return
        "deleteWebhookByToken(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken))"
    case .deleteWebhookMessage(let webhookId, let webhookToken, let messageId):
      return
        "deleteWebhookMessage(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken), messageId.rawValue: \(messageId.rawValue))"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var specialisedRatelimit: (maxRequests: Int, for: Duration)? {
    switch self {
    case .createDm: return (maxRequests: 10, for: .minutes(10))
    default: return nil
    }
  }
}

public enum CacheableAPIEndpointIdentity: Int, Sendable, Hashable,
  CustomStringConvertible
{

  // MARK: Polls
  /// https://discord.com/developers/docs/resources/poll

  case listPollAnswerVoters

  // MARK: AutoMod
  /// https://discord.com/developers/docs/resources/auto-moderation

  case getAutoModerationRule
  case listAutoModerationRules

  // MARK: Audit Log
  /// https://discord.com/developers/docs/resources/audit-log

  case listGuildAuditLogEntries

  // MARK: Channels
  /// https://discord.com/developers/docs/resources/channel

  case getChannel
  case listPinnedMessages

  // MARK: Commands
  /// https://discord.com/developers/docs/interactions/application-commands

  case getApplicationCommand
  case getGuildApplicationCommand
  case getGuildApplicationCommandPermissions
  case listApplicationCommands
  case listGuildApplicationCommandPermissions
  case listGuildApplicationCommands

  // MARK: Emoji
  /// https://discord.com/developers/docs/resources/emoji

  case getGuildEmoji
  case listGuildEmojis

  // MARK: Entitlements
  /// https://discord.com/developers/docs/monetization/entitlements

  case listEntitlements

  // MARK: Gateway
  /// https://discord.com/developers/docs/topics/gateway

  case getBotGateway
  case getGateway

  // MARK: Guilds
  /// https://discord.com/developers/docs/resources/guild

  case getGuild
  case getGuildBan
  case getGuildOnboarding
  case getGuildPreview
  case getGuildVanityUrl
  case getGuildWelcomeScreen
  case getGuildWidget
  case getGuildWidgetPng
  case getGuildWidgetSettings
  case listGuildBans
  case listGuildChannels
  case listGuildIntegrations
  case listOwnGuilds
  case previewPruneGuild

  // MARK: Guild Templates
  /// https://discord.com/developers/docs/resources/guild-template

  case getGuildTemplate
  case listGuildTemplates

  // MARK: Interactions
  /// https://discord.com/developers/docs/interactions/receiving-and-responding

  case getFollowupMessage
  case getOriginalInteractionResponse

  // MARK: Invites
  /// https://discord.com/developers/docs/resources/invite

  case listChannelInvites
  case listGuildInvites
  case resolveInvite

  // MARK: Members
  /// https://discord.com/developers/docs/resources/guild

  case getGuildMember
  case getOwnGuildMember
  case listGuildMembers
  case searchGuildMembers

  // MARK: Messages
  /// https://discord.com/developers/docs/resources/channel

  case getMessage
  case listMessageReactionsByEmoji
  case listMessages

  // MARK: OAuth
  /// https://discord.com/developers/docs/topics/oauth2

  case getOwnOauth2Application

  // MARK: Roles
  /// https://discord.com/developers/docs/resources/guild

  case listGuildRoles

  // MARK: Role Connections
  /// https://discord.com/developers/docs/resources/user

  case getApplicationUserRoleConnection
  case listApplicationRoleConnectionMetadata

  // MARK: Scheduled Events
  /// https://discord.com/developers/docs/resources/guild-scheduled-event

  case getGuildScheduledEvent
  case listGuildScheduledEventUsers
  case listGuildScheduledEvents

  // MARK: SKUs
  /// https://discord.com/developers/docs/monetization/skus

  case listSkus

  // MARK: Stages
  /// https://discord.com/developers/docs/resources/stage-instance

  case getStageInstance

  // MARK: Stickers
  /// https://discord.com/developers/docs/resources/sticker

  case getGuildSticker
  case getSticker
  case listGuildStickers

  // MARK: Threads
  /// https://discord.com/developers/docs/resources/channel

  case getThreadMember
  case listActiveGuildThreads
  case listOwnPrivateArchivedThreads
  case listPrivateArchivedThreads
  case listPublicArchivedThreads
  case listThreadMembers

  // MARK: Users
  /// https://discord.com/developers/docs/resources/user

  case getOwnApplication
  case getOwnUser
  case getUser
  case listOwnConnections

  // MARK: Voice
  /// https://discord.com/developers/docs/resources/voice#list-voice-regions

  case getVoiceState
  case listGuildVoiceRegions
  case listVoiceRegions

  // MARK: Webhooks
  /// https://discord.com/developers/docs/resources/webhook

  case getGuildWebhooks
  case getWebhook
  case getWebhookByToken
  case getWebhookMessage
  case listChannelWebhooks

  /// This case serves as a way of discouraging exhaustive switch statements
  case __DO_NOT_USE_THIS_CASE

  public var description: String {
    switch self {
    case .listPollAnswerVoters: return "listPollAnswerVoters"
    case .getAutoModerationRule: return "getAutoModerationRule"
    case .listAutoModerationRules: return "listAutoModerationRules"
    case .listGuildAuditLogEntries: return "listGuildAuditLogEntries"
    case .getChannel: return "getChannel"
    case .listPinnedMessages: return "listPinnedMessages"
    case .getApplicationCommand: return "getApplicationCommand"
    case .getGuildApplicationCommand: return "getGuildApplicationCommand"
    case .getGuildApplicationCommandPermissions:
      return "getGuildApplicationCommandPermissions"
    case .listApplicationCommands: return "listApplicationCommands"
    case .listGuildApplicationCommandPermissions:
      return "listGuildApplicationCommandPermissions"
    case .listGuildApplicationCommands: return "listGuildApplicationCommands"
    case .getGuildEmoji: return "getGuildEmoji"
    case .listGuildEmojis: return "listGuildEmojis"
    case .listEntitlements: return "listEntitlements"
    case .getBotGateway: return "getBotGateway"
    case .getGateway: return "getGateway"
    case .getGuild: return "getGuild"
    case .getGuildBan: return "getGuildBan"
    case .getGuildOnboarding: return "getGuildOnboarding"
    case .getGuildPreview: return "getGuildPreview"
    case .getGuildVanityUrl: return "getGuildVanityUrl"
    case .getGuildWelcomeScreen: return "getGuildWelcomeScreen"
    case .getGuildWidget: return "getGuildWidget"
    case .getGuildWidgetPng: return "getGuildWidgetPng"
    case .getGuildWidgetSettings: return "getGuildWidgetSettings"
    case .listGuildBans: return "listGuildBans"
    case .listGuildChannels: return "listGuildChannels"
    case .listGuildIntegrations: return "listGuildIntegrations"
    case .listOwnGuilds: return "listOwnGuilds"
    case .previewPruneGuild: return "previewPruneGuild"
    case .getGuildTemplate: return "getGuildTemplate"
    case .listGuildTemplates: return "listGuildTemplates"
    case .getFollowupMessage: return "getFollowupMessage"
    case .getOriginalInteractionResponse:
      return "getOriginalInteractionResponse"
    case .listChannelInvites: return "listChannelInvites"
    case .listGuildInvites: return "listGuildInvites"
    case .resolveInvite: return "resolveInvite"
    case .getGuildMember: return "getGuildMember"
    case .getOwnGuildMember: return "getOwnGuildMember"
    case .listGuildMembers: return "listGuildMembers"
    case .searchGuildMembers: return "searchGuildMembers"
    case .getMessage: return "getMessage"
    case .listMessageReactionsByEmoji: return "listMessageReactionsByEmoji"
    case .listMessages: return "listMessages"
    case .getOwnOauth2Application: return "getOwnOauth2Application"
    case .listGuildRoles: return "listGuildRoles"
    case .getApplicationUserRoleConnection:
      return "getApplicationUserRoleConnection"
    case .listApplicationRoleConnectionMetadata:
      return "listApplicationRoleConnectionMetadata"
    case .getGuildScheduledEvent: return "getGuildScheduledEvent"
    case .listGuildScheduledEventUsers: return "listGuildScheduledEventUsers"
    case .listGuildScheduledEvents: return "listGuildScheduledEvents"
    case .listSkus: return "listSkus"
    case .getStageInstance: return "getStageInstance"
    case .getGuildSticker: return "getGuildSticker"
    case .getSticker: return "getSticker"
    case .listGuildStickers: return "listGuildStickers"
    case .getThreadMember: return "getThreadMember"
    case .listActiveGuildThreads: return "listActiveGuildThreads"
    case .listOwnPrivateArchivedThreads: return "listOwnPrivateArchivedThreads"
    case .listPrivateArchivedThreads: return "listPrivateArchivedThreads"
    case .listPublicArchivedThreads: return "listPublicArchivedThreads"
    case .listThreadMembers: return "listThreadMembers"
    case .getOwnApplication: return "getOwnApplication"
    case .getOwnUser: return "getOwnUser"
    case .getUser: return "getUser"
    case .listOwnConnections: return "listOwnConnections"
    case .getVoiceState: return "getVoiceState"
    case .listGuildVoiceRegions: return "listGuildVoiceRegions"
    case .listVoiceRegions: return "listVoiceRegions"
    case .getGuildWebhooks: return "getGuildWebhooks"
    case .getWebhook: return "getWebhook"
    case .getWebhookByToken: return "getWebhookByToken"
    case .getWebhookMessage: return "getWebhookMessage"
    case .listChannelWebhooks: return "listChannelWebhooks"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  init?(endpoint: APIEndpoint) {
    switch endpoint {
    case .listPollAnswerVoters: self = .listPollAnswerVoters
    case .getAutoModerationRule: self = .getAutoModerationRule
    case .listAutoModerationRules: self = .listAutoModerationRules
    case .listGuildAuditLogEntries: self = .listGuildAuditLogEntries
    case .getChannel: self = .getChannel
    case .listPinnedMessages: self = .listPinnedMessages
    case .getApplicationCommand: self = .getApplicationCommand
    case .getGuildApplicationCommand: self = .getGuildApplicationCommand
    case .getGuildApplicationCommandPermissions:
      self = .getGuildApplicationCommandPermissions
    case .listApplicationCommands: self = .listApplicationCommands
    case .listGuildApplicationCommandPermissions:
      self = .listGuildApplicationCommandPermissions
    case .listGuildApplicationCommands: self = .listGuildApplicationCommands
    case .getGuildEmoji: self = .getGuildEmoji
    case .listGuildEmojis: self = .listGuildEmojis
    case .listEntitlements: self = .listEntitlements
    case .getBotGateway: self = .getBotGateway
    case .getGateway: self = .getGateway
    case .getGuild: self = .getGuild
    case .getGuildBan: self = .getGuildBan
    case .getGuildOnboarding: self = .getGuildOnboarding
    case .getGuildPreview: self = .getGuildPreview
    case .getGuildVanityUrl: self = .getGuildVanityUrl
    case .getGuildWelcomeScreen: self = .getGuildWelcomeScreen
    case .getGuildWidget: self = .getGuildWidget
    case .getGuildWidgetPng: self = .getGuildWidgetPng
    case .getGuildWidgetSettings: self = .getGuildWidgetSettings
    case .listGuildBans: self = .listGuildBans
    case .listGuildChannels: self = .listGuildChannels
    case .listGuildIntegrations: self = .listGuildIntegrations
    case .listOwnGuilds: self = .listOwnGuilds
    case .previewPruneGuild: self = .previewPruneGuild
    case .getGuildTemplate: self = .getGuildTemplate
    case .listGuildTemplates: self = .listGuildTemplates
    case .getFollowupMessage: self = .getFollowupMessage
    case .getOriginalInteractionResponse: self = .getOriginalInteractionResponse
    case .listChannelInvites: self = .listChannelInvites
    case .listGuildInvites: self = .listGuildInvites
    case .resolveInvite: self = .resolveInvite
    case .getGuildMember: self = .getGuildMember
    case .getOwnGuildMember: self = .getOwnGuildMember
    case .listGuildMembers: self = .listGuildMembers
    case .searchGuildMembers: self = .searchGuildMembers
    case .getMessage: self = .getMessage
    case .listMessageReactionsByEmoji: self = .listMessageReactionsByEmoji
    case .listMessages: self = .listMessages
    case .getOwnOauth2Application: self = .getOwnOauth2Application
    case .listGuildRoles: self = .listGuildRoles
    case .getApplicationUserRoleConnection:
      self = .getApplicationUserRoleConnection
    case .listApplicationRoleConnectionMetadata:
      self = .listApplicationRoleConnectionMetadata
    case .getGuildScheduledEvent: self = .getGuildScheduledEvent
    case .listGuildScheduledEventUsers: self = .listGuildScheduledEventUsers
    case .listGuildScheduledEvents: self = .listGuildScheduledEvents
    case .listSkus: self = .listSkus
    case .getStageInstance: self = .getStageInstance
    case .getGuildSticker: self = .getGuildSticker
    case .getSticker: self = .getSticker
    case .listGuildStickers: self = .listGuildStickers
    case .getThreadMember: self = .getThreadMember
    case .listActiveGuildThreads: self = .listActiveGuildThreads
    case .listOwnPrivateArchivedThreads: self = .listOwnPrivateArchivedThreads
    case .listPrivateArchivedThreads: self = .listPrivateArchivedThreads
    case .listPublicArchivedThreads: self = .listPublicArchivedThreads
    case .listThreadMembers: self = .listThreadMembers
    case .getOwnApplication: self = .getOwnApplication
    case .getOwnUser: self = .getOwnUser
    case .getUser: self = .getUser
    case .listOwnConnections: self = .listOwnConnections
    case .getVoiceState: self = .getVoiceState
    case .listGuildVoiceRegions: self = .listGuildVoiceRegions
    case .listVoiceRegions: self = .listVoiceRegions
    case .getGuildWebhooks: self = .getGuildWebhooks
    case .getWebhook: self = .getWebhook
    case .getWebhookByToken: self = .getWebhookByToken
    case .getWebhookMessage: self = .getWebhookMessage
    case .listChannelWebhooks: self = .listChannelWebhooks
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    default: return nil
    }
  }
}
