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
    channelId: ChannelSnowflake, messageId: MessageSnowflake, answerId: Int)
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
    channelId: ChannelSnowflake, overwriteId: AnySnowflake)
  case createDm
  case createGroupDm
  case followAnnouncementChannel(channelId: ChannelSnowflake)
  case triggerTypingIndicator(channelId: ChannelSnowflake)
  case updateChannel(channelId: ChannelSnowflake)
  case deleteChannel(channelId: ChannelSnowflake)
  case deleteChannelPermissionOverwrite(
    channelId: ChannelSnowflake, overwriteId: AnySnowflake)
  case deleteGroupDmUser(channelId: ChannelSnowflake, userId: UserSnowflake)
  case unpinMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)

  // MARK: Commands
  /// https://discord.com/developers/docs/interactions/application-commands

  case getApplicationCommand(
    applicationId: ApplicationSnowflake, commandId: CommandSnowflake)
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
    applicationId: ApplicationSnowflake, guildId: GuildSnowflake)
  case listGuildApplicationCommands(
    applicationId: ApplicationSnowflake, guildId: GuildSnowflake)
  case bulkSetApplicationCommands(applicationId: ApplicationSnowflake)
  case bulkSetGuildApplicationCommands(
    applicationId: ApplicationSnowflake, guildId: GuildSnowflake)
  case setGuildApplicationCommandPermissions(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake,
    commandId: CommandSnowflake
  )
  case createApplicationCommand(applicationId: ApplicationSnowflake)
  case createGuildApplicationCommand(
    applicationId: ApplicationSnowflake, guildId: GuildSnowflake)
  case updateApplicationCommand(
    applicationId: ApplicationSnowflake, commandId: CommandSnowflake)
  case updateGuildApplicationCommand(
    applicationId: ApplicationSnowflake,
    guildId: GuildSnowflake,
    commandId: CommandSnowflake
  )
  case deleteApplicationCommand(
    applicationId: ApplicationSnowflake, commandId: CommandSnowflake)
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
    applicationId: ApplicationSnowflake, entitlementId: EntitlementSnowflake)
  case createTestEntitlement(applicationId: ApplicationSnowflake)
  case deleteTestEntitlement(
    applicationId: ApplicationSnowflake, entitlementId: EntitlementSnowflake)

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
    guildId: GuildSnowflake, integrationId: IntegrationSnowflake)
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
    applicationId: ApplicationSnowflake, interactionToken: String,
    messageId: MessageSnowflake)
  case getOriginalInteractionResponse(
    applicationId: ApplicationSnowflake, interactionToken: String)
  case createFollowupMessage(
    applicationId: ApplicationSnowflake, interactionToken: String)
  case createInteractionResponse(
    interactionId: InteractionSnowflake, interactionToken: String)
  case updateFollowupMessage(
    applicationId: ApplicationSnowflake,
    interactionToken: String,
    messageId: MessageSnowflake
  )
  case updateOriginalInteractionResponse(
    applicationId: ApplicationSnowflake, interactionToken: String)
  case deleteFollowupMessage(
    applicationId: ApplicationSnowflake,
    interactionToken: String,
    messageId: MessageSnowflake
  )
  case deleteOriginalInteractionResponse(
    applicationId: ApplicationSnowflake, interactionToken: String)

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
    channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String)
  case listMessages(channelId: ChannelSnowflake)
  case addMessageReaction(
    channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String)
  case bulkDeleteMessages(channelId: ChannelSnowflake)
  case createMessage(channelId: ChannelSnowflake)
  case crosspostMessage(
    channelId: ChannelSnowflake, messageId: MessageSnowflake)
  case updateMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
  case deleteAllMessageReactions(
    channelId: ChannelSnowflake, messageId: MessageSnowflake)
  case deleteAllMessageReactionsByEmoji(
    channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String)
  case deleteMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
  case deleteOwnMessageReaction(
    channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String)
  case deleteUserMessageReaction(
    channelId: ChannelSnowflake,
    messageId: MessageSnowflake,
    emojiName: String,
    userId: UserSnowflake
  )

  // MARK: OAuth
  /// https://discord.com/developers/docs/topics/oauth2

  case getOwnOauth2Application

  // MARK: Roles
  /// https://discord.com/developers/docs/resources/guild

  case listGuildRoles(guildId: GuildSnowflake)
  case addGuildMemberRole(
    guildId: GuildSnowflake, userId: UserSnowflake, roleId: RoleSnowflake)
  case createGuildRole(guildId: GuildSnowflake)
  case updateGuildRole(guildId: GuildSnowflake, roleId: RoleSnowflake)
  case updateGuildRolePositions(guildId: GuildSnowflake)
  case deleteGuildMemberRole(
    guildId: GuildSnowflake, userId: UserSnowflake, roleId: RoleSnowflake)
  case deleteGuildRole(guildId: GuildSnowflake, roleId: RoleSnowflake)

  // MARK: Role Connections
  /// https://discord.com/developers/docs/resources/user

  case getApplicationUserRoleConnection(applicationId: ApplicationSnowflake)
  case listApplicationRoleConnectionMetadata(
    applicationId: ApplicationSnowflake)
  case bulkOverwriteApplicationRoleConnectionMetadata(
    applicationId: ApplicationSnowflake)
  case updateApplicationUserRoleConnection(applicationId: ApplicationSnowflake)

  // MARK: Scheduled Events
  /// https://discord.com/developers/docs/resources/guild-scheduled-event

  case getGuildScheduledEvent(
    guildId: GuildSnowflake, guildScheduledEventId: GuildScheduledEventSnowflake
  )
  case listGuildScheduledEventUsers(
    guildId: GuildSnowflake, guildScheduledEventId: GuildScheduledEventSnowflake
  )
  case listGuildScheduledEvents(guildId: GuildSnowflake)
  case createGuildScheduledEvent(guildId: GuildSnowflake)
  case updateGuildScheduledEvent(
    guildId: GuildSnowflake, guildScheduledEventId: GuildScheduledEventSnowflake
  )
  case deleteGuildScheduledEvent(
    guildId: GuildSnowflake, guildScheduledEventId: GuildScheduledEventSnowflake
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
  case listStickerPacks
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
    channelId: ChannelSnowflake, messageId: MessageSnowflake)
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
    webhookId: WebhookSnowflake, webhookToken: String,
    messageId: MessageSnowflake)
  case listChannelWebhooks(channelId: ChannelSnowflake)
  case createWebhook(channelId: ChannelSnowflake)
  case executeWebhook(webhookId: WebhookSnowflake, webhookToken: String)
  case updateWebhook(webhookId: WebhookSnowflake)
  case updateWebhookByToken(webhookId: WebhookSnowflake, webhookToken: String)
  case updateWebhookMessage(
    webhookId: WebhookSnowflake, webhookToken: String,
    messageId: MessageSnowflake)
  case deleteWebhook(webhookId: WebhookSnowflake)
  case deleteWebhookByToken(webhookId: WebhookSnowflake, webhookToken: String)
  case deleteWebhookMessage(
    webhookId: WebhookSnowflake, webhookToken: String,
    messageId: MessageSnowflake)

  /// This case serves as a way of discouraging exhaustive switch statements
  case __DO_NOT_USE_THIS_CASE

  var urlPrefix: String {
    "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
  }

  public var url: String {
    let suffix: String
    switch self {
    case let .listPollAnswerVoters(channelId, messageId, answerId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/polls/\(messageId)/answers/\(answerId)"
    case let .endPoll(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/polls/\(messageId)/expire"
    case let .getAutoModerationRule(guildId, ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case let .listAutoModerationRules(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules"
    case let .createAutoModerationRule(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules"
    case let .updateAutoModerationRule(guildId, ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case let .deleteAutoModerationRule(guildId, ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case let .listGuildAuditLogEntries(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/audit-logs"
    case let .getChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case let .listPinnedMessages(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/pins"
    case let .addGroupDmUser(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/recipients/\(userId)"
    case let .pinMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/pins/\(messageId)"
    case let .setChannelPermissionOverwrite(channelId, overwriteId):
      let channelId = channelId.rawValue
      let overwriteId = overwriteId.rawValue
      suffix = "channels/\(channelId)/permissions/\(overwriteId)"
    case .createDm:
      suffix = "users/@me/channels"
    case .createGroupDm:
      suffix = "users/@me/channels"
    case let .followAnnouncementChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/followers"
    case let .triggerTypingIndicator(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/typing"
    case let .updateChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case let .deleteChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
      let channelId = channelId.rawValue
      let overwriteId = overwriteId.rawValue
      suffix = "channels/\(channelId)/permissions/\(overwriteId)"
    case let .deleteGroupDmUser(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/recipients/\(userId)"
    case let .unpinMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/pins/\(messageId)"
    case let .getApplicationCommand(applicationId, commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case let .getGuildApplicationCommand(applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case let .getGuildApplicationCommandPermissions(
      applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    case let .listApplicationCommands(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case let .listGuildApplicationCommandPermissions(applicationId, guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
    case let .listGuildApplicationCommands(applicationId, guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case let .bulkSetApplicationCommands(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case let .bulkSetGuildApplicationCommands(applicationId, guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case let .setGuildApplicationCommandPermissions(
      applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    case let .createApplicationCommand(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case let .createGuildApplicationCommand(applicationId, guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case let .updateApplicationCommand(applicationId, commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case let .deleteApplicationCommand(applicationId, commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case let .getGuildEmoji(guildId, emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case let .listGuildEmojis(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/emojis"
    case let .createGuildEmoji(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/emojis"
    case let .updateGuildEmoji(guildId, emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case let .deleteGuildEmoji(guildId, emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case let .listEntitlements(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/entitlements"
    case let .consumeEntitlement(applicationId, entitlementId):
      let applicationId = applicationId.rawValue
      let entitlementId = entitlementId.rawValue
      suffix =
        "applications/\(applicationId)/entitlements/\(entitlementId)/consume"
    case let .createTestEntitlement(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/entitlements"
    case let .deleteTestEntitlement(applicationId, entitlementId):
      let applicationId = applicationId.rawValue
      let entitlementId = entitlementId.rawValue
      suffix = "applications/\(applicationId)/entitlements/\(entitlementId)"
    case .getBotGateway:
      suffix = "gateway/bot"
    case .getGateway:
      suffix = "gateway"
    case let .getGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case let .getGuildBan(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case let .getGuildOnboarding(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/onboarding"
    case let .getGuildPreview(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/preview"
    case let .getGuildVanityUrl(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/vanity-url"
    case let .getGuildWelcomeScreen(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/welcome-screen"
    case let .getGuildWidget(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget.json"
    case let .getGuildWidgetPng(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget.png"
    case let .getGuildWidgetSettings(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget"
    case let .listGuildBans(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/bans"
    case let .listGuildChannels(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case let .listGuildIntegrations(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/integrations"
    case .listOwnGuilds:
      suffix = "users/@me/guilds"
    case let .previewPruneGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/prune"
    case let .banUserFromGuild(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case let .updateGuildOnboarding(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/onboarding"
    case let .bulkBanUsersFromGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/bulk-ban"
    case .createGuild:
      suffix = "guilds"
    case let .createGuildChannel(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case let .pruneGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/prune"
    case let .setGuildMfaLevel(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/mfa"
    case let .updateGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case let .updateGuildChannelPositions(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case let .updateGuildWelcomeScreen(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/welcome-screen"
    case let .updateGuildWidgetSettings(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget"
    case let .deleteGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case let .deleteGuildIntegration(guildId, integrationId):
      let guildId = guildId.rawValue
      let integrationId = integrationId.rawValue
      suffix = "guilds/\(guildId)/integrations/\(integrationId)"
    case let .leaveGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "users/@me/guilds/\(guildId)"
    case let .unbanUserFromGuild(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case let .getGuildTemplate(code):
      suffix = "guilds/templates/\(code)"
    case let .listGuildTemplates(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates"
    case let .syncGuildTemplate(guildId, code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case let .createGuildFromTemplate(code):
      suffix = "guilds/templates/\(code)"
    case let .createGuildTemplate(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates"
    case let .updateGuildTemplate(guildId, code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case let .deleteGuildTemplate(guildId, code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case let .getFollowupMessage(applicationId, interactionToken, messageId):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case let .getOriginalInteractionResponse(applicationId, interactionToken):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case let .createFollowupMessage(applicationId, interactionToken):
      let applicationId = applicationId.rawValue
      suffix = "webhooks/\(applicationId)/\(interactionToken)"
    case let .createInteractionResponse(interactionId, interactionToken):
      let interactionId = interactionId.rawValue
      suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
    case let .updateFollowupMessage(applicationId, interactionToken, messageId):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case let .updateOriginalInteractionResponse(applicationId, interactionToken):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case let .listChannelInvites(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/invites"
    case let .listGuildInvites(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/invites"
    case let .resolveInvite(code):
      suffix = "invites/\(code)"
    case let .createChannelInvite(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/invites"
    case let .revokeInvite(code):
      suffix = "invites/\(code)"
    case let .getGuildMember(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case let .getOwnGuildMember(guildId):
      let guildId = guildId.rawValue
      suffix = "users/@me/guilds/\(guildId)/member"
    case let .listGuildMembers(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members"
    case let .searchGuildMembers(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members/search"
    case let .addGuildMember(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case let .updateGuildMember(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case let .updateOwnGuildMember(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members/@me"
    case let .deleteGuildMember(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case let .getMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
    case let .listMessages(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages"
    case let .addMessageReaction(channelId, messageId, emojiName):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
    case let .bulkDeleteMessages(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages/bulk-delete"
    case let .createMessage(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages"
    case let .crosspostMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
    case let .updateMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case let .deleteAllMessageReactions(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
    case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
    case let .deleteMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
    case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      let userId = userId.rawValue
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
    case .getOwnOauth2Application:
      suffix = "oauth2/applications/@me"
    case let .listGuildRoles(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case let .addGuildMemberRole(guildId, userId, roleId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    case let .createGuildRole(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case let .updateGuildRole(guildId, roleId):
      let guildId = guildId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/roles/\(roleId)"
    case let .updateGuildRolePositions(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case let .deleteGuildMemberRole(guildId, userId, roleId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    case let .deleteGuildRole(guildId, roleId):
      let guildId = guildId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/roles/\(roleId)"
    case let .getApplicationUserRoleConnection(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "users/@me/applications/\(applicationId)/role-connection"
    case let .listApplicationRoleConnectionMetadata(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/role-connections/metadata"
    case let .bulkOverwriteApplicationRoleConnectionMetadata(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/role-connections/metadata"
    case let .updateApplicationUserRoleConnection(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "users/@me/applications/\(applicationId)/role-connection"
    case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix =
        "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
    case let .listGuildScheduledEvents(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events"
    case let .createGuildScheduledEvent(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events"
    case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case let .listSkus(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/skus"
    case let .getStageInstance(channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case .createStageInstance:
      suffix = "stage-instances"
    case let .updateStageInstance(channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case let .deleteStageInstance(channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case let .getGuildSticker(guildId, stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case let .getSticker(stickerId):
      let stickerId = stickerId.rawValue
      suffix = "stickers/\(stickerId)"
    case let .listGuildStickers(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/stickers"
    case .listStickerPacks:
      suffix = "sticker-packs"
    case let .createGuildSticker(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/stickers"
    case let .updateGuildSticker(guildId, stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case let .deleteGuildSticker(guildId, stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case let .getThreadMember(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case let .listActiveGuildThreads(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/threads/active"
    case let .listOwnPrivateArchivedThreads(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/users/@me/threads/archived/private"
    case let .listPrivateArchivedThreads(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads/archived/private"
    case let .listPublicArchivedThreads(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads/archived/public"
    case let .listThreadMembers(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members"
    case let .addThreadMember(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case let .joinThread(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members/@me"
    case let .createThread(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads"
    case let .createThreadFromMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/threads"
    case let .createThreadInForumChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads"
    case let .deleteThreadMember(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case let .leaveThread(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members/@me"
    case .getOwnApplication:
      suffix = "applications/@me"
    case .getOwnUser:
      suffix = "users/@me"
    case let .getUser(userId):
      let userId = userId.rawValue
      suffix = "users/\(userId)"
    case .listOwnConnections:
      suffix = "users/@me/connections"
    case .updateOwnApplication:
      suffix = "applications/@me"
    case .updateOwnUser:
      suffix = "users/@me"
    case let .listGuildVoiceRegions(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/regions"
    case .listVoiceRegions:
      suffix = "voice/regions"
    case let .updateSelfVoiceState(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/voice-states/@me"
    case let .updateVoiceState(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/voice-states/\(userId)"
    case let .getGuildWebhooks(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/webhooks"
    case let .getWebhook(webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case let .getWebhookByToken(webhookId, webhookToken):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case let .getWebhookMessage(webhookId, webhookToken, messageId):
      let webhookId = webhookId.rawValue
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case let .listChannelWebhooks(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/webhooks"
    case let .createWebhook(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/webhooks"
    case let .executeWebhook(webhookId, webhookToken):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case let .updateWebhook(webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case let .updateWebhookByToken(webhookId, webhookToken):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case let .updateWebhookMessage(webhookId, webhookToken, messageId):
      let webhookId = webhookId.rawValue
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case let .deleteWebhook(webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case let .deleteWebhookByToken(webhookId, webhookToken):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
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
    case let .listPollAnswerVoters(channelId, messageId, answerId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/polls/\(messageId)/answers/\(answerId)"
    case let .endPoll(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/polls/\(messageId)/expire"
    case let .getAutoModerationRule(guildId, ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case let .listAutoModerationRules(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules"
    case let .createAutoModerationRule(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules"
    case let .updateAutoModerationRule(guildId, ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case let .deleteAutoModerationRule(guildId, ruleId):
      let guildId = guildId.rawValue
      let ruleId = ruleId.rawValue
      suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
    case let .listGuildAuditLogEntries(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/audit-logs"
    case let .getChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case let .listPinnedMessages(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/pins"
    case let .addGroupDmUser(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/recipients/\(userId)"
    case let .pinMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/pins/\(messageId)"
    case let .setChannelPermissionOverwrite(channelId, overwriteId):
      let channelId = channelId.rawValue
      let overwriteId = overwriteId.rawValue
      suffix = "channels/\(channelId)/permissions/\(overwriteId)"
    case .createDm:
      suffix = "users/@me/channels"
    case .createGroupDm:
      suffix = "users/@me/channels"
    case let .followAnnouncementChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/followers"
    case let .triggerTypingIndicator(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/typing"
    case let .updateChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case let .deleteChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)"
    case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
      let channelId = channelId.rawValue
      let overwriteId = overwriteId.rawValue
      suffix = "channels/\(channelId)/permissions/\(overwriteId)"
    case let .deleteGroupDmUser(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/recipients/\(userId)"
    case let .unpinMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/pins/\(messageId)"
    case let .getApplicationCommand(applicationId, commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case let .getGuildApplicationCommand(applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case let .getGuildApplicationCommandPermissions(
      applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    case let .listApplicationCommands(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case let .listGuildApplicationCommandPermissions(applicationId, guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
    case let .listGuildApplicationCommands(applicationId, guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case let .bulkSetApplicationCommands(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case let .bulkSetGuildApplicationCommands(applicationId, guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case let .setGuildApplicationCommandPermissions(
      applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    case let .createApplicationCommand(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/commands"
    case let .createGuildApplicationCommand(applicationId, guildId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
    case let .updateApplicationCommand(applicationId, commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case let .deleteApplicationCommand(applicationId, commandId):
      let applicationId = applicationId.rawValue
      let commandId = commandId.rawValue
      suffix = "applications/\(applicationId)/commands/\(commandId)"
    case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
      let applicationId = applicationId.rawValue
      let guildId = guildId.rawValue
      let commandId = commandId.rawValue
      suffix =
        "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    case let .getGuildEmoji(guildId, emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case let .listGuildEmojis(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/emojis"
    case let .createGuildEmoji(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/emojis"
    case let .updateGuildEmoji(guildId, emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case let .deleteGuildEmoji(guildId, emojiId):
      let guildId = guildId.rawValue
      let emojiId = emojiId.rawValue
      suffix = "guilds/\(guildId)/emojis/\(emojiId)"
    case let .listEntitlements(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/entitlements"
    case let .consumeEntitlement(applicationId, entitlementId):
      let applicationId = applicationId.rawValue
      let entitlementId = entitlementId.rawValue
      suffix =
        "applications/\(applicationId)/entitlements/\(entitlementId)/consume"
    case let .createTestEntitlement(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/entitlements"
    case let .deleteTestEntitlement(applicationId, entitlementId):
      let applicationId = applicationId.rawValue
      let entitlementId = entitlementId.rawValue
      suffix = "applications/\(applicationId)/entitlements/\(entitlementId)"
    case .getBotGateway:
      suffix = "gateway/bot"
    case .getGateway:
      suffix = "gateway"
    case let .getGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case let .getGuildBan(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case let .getGuildOnboarding(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/onboarding"
    case let .getGuildPreview(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/preview"
    case let .getGuildVanityUrl(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/vanity-url"
    case let .getGuildWelcomeScreen(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/welcome-screen"
    case let .getGuildWidget(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget.json"
    case let .getGuildWidgetPng(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget.png"
    case let .getGuildWidgetSettings(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget"
    case let .listGuildBans(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/bans"
    case let .listGuildChannels(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case let .listGuildIntegrations(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/integrations"
    case .listOwnGuilds:
      suffix = "users/@me/guilds"
    case let .previewPruneGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/prune"
    case let .banUserFromGuild(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case let .updateGuildOnboarding(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/onboarding"
    case let .bulkBanUsersFromGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/bulk-ban"
    case .createGuild:
      suffix = "guilds"
    case let .createGuildChannel(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case let .pruneGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/prune"
    case let .setGuildMfaLevel(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/mfa"
    case let .updateGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case let .updateGuildChannelPositions(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/channels"
    case let .updateGuildWelcomeScreen(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/welcome-screen"
    case let .updateGuildWidgetSettings(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/widget"
    case let .deleteGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)"
    case let .deleteGuildIntegration(guildId, integrationId):
      let guildId = guildId.rawValue
      let integrationId = integrationId.rawValue
      suffix = "guilds/\(guildId)/integrations/\(integrationId)"
    case let .leaveGuild(guildId):
      let guildId = guildId.rawValue
      suffix = "users/@me/guilds/\(guildId)"
    case let .unbanUserFromGuild(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/bans/\(userId)"
    case let .getGuildTemplate(code):
      suffix = "guilds/templates/\(code)"
    case let .listGuildTemplates(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates"
    case let .syncGuildTemplate(guildId, code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case let .createGuildFromTemplate(code):
      suffix = "guilds/templates/\(code)"
    case let .createGuildTemplate(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates"
    case let .updateGuildTemplate(guildId, code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case let .deleteGuildTemplate(guildId, code):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/templates/\(code)"
    case let .getFollowupMessage(applicationId, interactionToken, messageId):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case let .getOriginalInteractionResponse(applicationId, interactionToken):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case let .createFollowupMessage(applicationId, interactionToken):
      let applicationId = applicationId.rawValue
      suffix = "webhooks/\(applicationId)/\(interactionToken)"
    case let .createInteractionResponse(interactionId, interactionToken):
      let interactionId = interactionId.rawValue
      suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
    case let .updateFollowupMessage(applicationId, interactionToken, messageId):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case let .updateOriginalInteractionResponse(applicationId, interactionToken):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
      let applicationId = applicationId.rawValue
      let messageId = messageId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
    case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
      let applicationId = applicationId.rawValue
      suffix =
        "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
    case let .listChannelInvites(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/invites"
    case let .listGuildInvites(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/invites"
    case let .resolveInvite(code):
      suffix = "invites/\(code)"
    case let .createChannelInvite(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/invites"
    case let .revokeInvite(code):
      suffix = "invites/\(code)"
    case let .getGuildMember(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case let .getOwnGuildMember(guildId):
      let guildId = guildId.rawValue
      suffix = "users/@me/guilds/\(guildId)/member"
    case let .listGuildMembers(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members"
    case let .searchGuildMembers(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members/search"
    case let .addGuildMember(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case let .updateGuildMember(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case let .updateOwnGuildMember(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/members/@me"
    case let .deleteGuildMember(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)"
    case let .getMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
    case let .listMessages(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages"
    case let .addMessageReaction(channelId, messageId, emojiName):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
    case let .bulkDeleteMessages(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages/bulk-delete"
    case let .createMessage(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/messages"
    case let .crosspostMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
    case let .updateMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case let .deleteAllMessageReactions(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
    case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
    case let .deleteMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)"
    case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
    case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      let emojiName = emojiName.urlPathEncoded()
      let userId = userId.rawValue
      suffix =
        "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
    case .getOwnOauth2Application:
      suffix = "oauth2/applications/@me"
    case let .listGuildRoles(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case let .addGuildMemberRole(guildId, userId, roleId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    case let .createGuildRole(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case let .updateGuildRole(guildId, roleId):
      let guildId = guildId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/roles/\(roleId)"
    case let .updateGuildRolePositions(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/roles"
    case let .deleteGuildMemberRole(guildId, userId, roleId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    case let .deleteGuildRole(guildId, roleId):
      let guildId = guildId.rawValue
      let roleId = roleId.rawValue
      suffix = "guilds/\(guildId)/roles/\(roleId)"
    case let .getApplicationUserRoleConnection(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "users/@me/applications/\(applicationId)/role-connection"
    case let .listApplicationRoleConnectionMetadata(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/role-connections/metadata"
    case let .bulkOverwriteApplicationRoleConnectionMetadata(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/role-connections/metadata"
    case let .updateApplicationUserRoleConnection(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "users/@me/applications/\(applicationId)/role-connection"
    case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix =
        "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
    case let .listGuildScheduledEvents(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events"
    case let .createGuildScheduledEvent(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events"
    case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
      let guildId = guildId.rawValue
      let guildScheduledEventId = guildScheduledEventId.rawValue
      suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
    case let .listSkus(applicationId):
      let applicationId = applicationId.rawValue
      suffix = "applications/\(applicationId)/skus"
    case let .getStageInstance(channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case .createStageInstance:
      suffix = "stage-instances"
    case let .updateStageInstance(channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case let .deleteStageInstance(channelId):
      let channelId = channelId.rawValue
      suffix = "stage-instances/\(channelId)"
    case let .getGuildSticker(guildId, stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case let .getSticker(stickerId):
      let stickerId = stickerId.rawValue
      suffix = "stickers/\(stickerId)"
    case let .listGuildStickers(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/stickers"
    case .listStickerPacks:
      suffix = "sticker-packs"
    case let .createGuildSticker(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/stickers"
    case let .updateGuildSticker(guildId, stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case let .deleteGuildSticker(guildId, stickerId):
      let guildId = guildId.rawValue
      let stickerId = stickerId.rawValue
      suffix = "guilds/\(guildId)/stickers/\(stickerId)"
    case let .getThreadMember(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case let .listActiveGuildThreads(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/threads/active"
    case let .listOwnPrivateArchivedThreads(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/users/@me/threads/archived/private"
    case let .listPrivateArchivedThreads(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads/archived/private"
    case let .listPublicArchivedThreads(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads/archived/public"
    case let .listThreadMembers(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members"
    case let .addThreadMember(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case let .joinThread(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members/@me"
    case let .createThread(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads"
    case let .createThreadFromMessage(channelId, messageId):
      let channelId = channelId.rawValue
      let messageId = messageId.rawValue
      suffix = "channels/\(channelId)/messages/\(messageId)/threads"
    case let .createThreadInForumChannel(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/threads"
    case let .deleteThreadMember(channelId, userId):
      let channelId = channelId.rawValue
      let userId = userId.rawValue
      suffix = "channels/\(channelId)/thread-members/\(userId)"
    case let .leaveThread(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/thread-members/@me"
    case .getOwnApplication:
      suffix = "applications/@me"
    case .getOwnUser:
      suffix = "users/@me"
    case let .getUser(userId):
      let userId = userId.rawValue
      suffix = "users/\(userId)"
    case .listOwnConnections:
      suffix = "users/@me/connections"
    case .updateOwnApplication:
      suffix = "applications/@me"
    case .updateOwnUser:
      suffix = "users/@me"
    case let .listGuildVoiceRegions(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/regions"
    case .listVoiceRegions:
      suffix = "voice/regions"
    case let .updateSelfVoiceState(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/voice-states/@me"
    case let .updateVoiceState(guildId, userId):
      let guildId = guildId.rawValue
      let userId = userId.rawValue
      suffix = "guilds/\(guildId)/voice-states/\(userId)"
    case let .getGuildWebhooks(guildId):
      let guildId = guildId.rawValue
      suffix = "guilds/\(guildId)/webhooks"
    case let .getWebhook(webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case let .getWebhookByToken(webhookId, webhookToken):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case let .getWebhookMessage(webhookId, webhookToken, messageId):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case let .listChannelWebhooks(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/webhooks"
    case let .createWebhook(channelId):
      let channelId = channelId.rawValue
      suffix = "channels/\(channelId)/webhooks"
    case let .executeWebhook(webhookId, webhookToken):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case let .updateWebhook(webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case let .updateWebhookByToken(webhookId, webhookToken):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case let .updateWebhookMessage(webhookId, webhookToken, messageId):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      let messageId = messageId.rawValue
      suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
    case let .deleteWebhook(webhookId):
      let webhookId = webhookId.rawValue
      suffix = "webhooks/\(webhookId)"
    case let .deleteWebhookByToken(webhookId, webhookToken):
      let webhookId = webhookId.rawValue
      let webhookToken = webhookToken.urlPathEncoded().hash
      suffix = "webhooks/\(webhookId)/\(webhookToken)"
    case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
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
    case .createGroupDm: return .POST
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
    case .listStickerPacks: return .GET
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
    case .createGroupDm: return true
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
    case .listStickerPacks: return true
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
    case .createGroupDm: return true
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
    case .listStickerPacks: return true
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
    case let .listPollAnswerVoters(channelId, messageId, answerId):
      return [channelId.rawValue, messageId.rawValue, "\(answerId)"]
    case let .endPoll(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .getAutoModerationRule(guildId, ruleId):
      return [guildId.rawValue, ruleId.rawValue]
    case let .listAutoModerationRules(guildId):
      return [guildId.rawValue]
    case let .createAutoModerationRule(guildId):
      return [guildId.rawValue]
    case let .updateAutoModerationRule(guildId, ruleId):
      return [guildId.rawValue, ruleId.rawValue]
    case let .deleteAutoModerationRule(guildId, ruleId):
      return [guildId.rawValue, ruleId.rawValue]
    case let .listGuildAuditLogEntries(guildId):
      return [guildId.rawValue]
    case let .getChannel(channelId):
      return [channelId.rawValue]
    case let .listPinnedMessages(channelId):
      return [channelId.rawValue]
    case let .addGroupDmUser(channelId, userId):
      return [channelId.rawValue, userId.rawValue]
    case let .pinMessage(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .setChannelPermissionOverwrite(channelId, overwriteId):
      return [channelId.rawValue, overwriteId.rawValue]
    case .createDm:
      return []
    case .createGroupDm:
      return []
    case let .followAnnouncementChannel(channelId):
      return [channelId.rawValue]
    case let .triggerTypingIndicator(channelId):
      return [channelId.rawValue]
    case let .updateChannel(channelId):
      return [channelId.rawValue]
    case let .deleteChannel(channelId):
      return [channelId.rawValue]
    case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
      return [channelId.rawValue, overwriteId.rawValue]
    case let .deleteGroupDmUser(channelId, userId):
      return [channelId.rawValue, userId.rawValue]
    case let .unpinMessage(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .getApplicationCommand(applicationId, commandId):
      return [applicationId.rawValue, commandId.rawValue]
    case let .getGuildApplicationCommand(applicationId, guildId, commandId):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case let .getGuildApplicationCommandPermissions(
      applicationId, guildId, commandId):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case let .listApplicationCommands(applicationId):
      return [applicationId.rawValue]
    case let .listGuildApplicationCommandPermissions(applicationId, guildId):
      return [applicationId.rawValue, guildId.rawValue]
    case let .listGuildApplicationCommands(applicationId, guildId):
      return [applicationId.rawValue, guildId.rawValue]
    case let .bulkSetApplicationCommands(applicationId):
      return [applicationId.rawValue]
    case let .bulkSetGuildApplicationCommands(applicationId, guildId):
      return [applicationId.rawValue, guildId.rawValue]
    case let .setGuildApplicationCommandPermissions(
      applicationId, guildId, commandId):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case let .createApplicationCommand(applicationId):
      return [applicationId.rawValue]
    case let .createGuildApplicationCommand(applicationId, guildId):
      return [applicationId.rawValue, guildId.rawValue]
    case let .updateApplicationCommand(applicationId, commandId):
      return [applicationId.rawValue, commandId.rawValue]
    case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case let .deleteApplicationCommand(applicationId, commandId):
      return [applicationId.rawValue, commandId.rawValue]
    case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
      return [applicationId.rawValue, guildId.rawValue, commandId.rawValue]
    case let .getGuildEmoji(guildId, emojiId):
      return [guildId.rawValue, emojiId.rawValue]
    case let .listGuildEmojis(guildId):
      return [guildId.rawValue]
    case let .createGuildEmoji(guildId):
      return [guildId.rawValue]
    case let .updateGuildEmoji(guildId, emojiId):
      return [guildId.rawValue, emojiId.rawValue]
    case let .deleteGuildEmoji(guildId, emojiId):
      return [guildId.rawValue, emojiId.rawValue]
    case let .listEntitlements(applicationId):
      return [applicationId.rawValue]
    case let .consumeEntitlement(applicationId, entitlementId):
      return [applicationId.rawValue, entitlementId.rawValue]
    case let .createTestEntitlement(applicationId):
      return [applicationId.rawValue]
    case let .deleteTestEntitlement(applicationId, entitlementId):
      return [applicationId.rawValue, entitlementId.rawValue]
    case .getBotGateway:
      return []
    case .getGateway:
      return []
    case let .getGuild(guildId):
      return [guildId.rawValue]
    case let .getGuildBan(guildId, userId):
      return [guildId.rawValue, userId.rawValue]
    case let .getGuildOnboarding(guildId):
      return [guildId.rawValue]
    case let .getGuildPreview(guildId):
      return [guildId.rawValue]
    case let .getGuildVanityUrl(guildId):
      return [guildId.rawValue]
    case let .getGuildWelcomeScreen(guildId):
      return [guildId.rawValue]
    case let .getGuildWidget(guildId):
      return [guildId.rawValue]
    case let .getGuildWidgetPng(guildId):
      return [guildId.rawValue]
    case let .getGuildWidgetSettings(guildId):
      return [guildId.rawValue]
    case let .listGuildBans(guildId):
      return [guildId.rawValue]
    case let .listGuildChannels(guildId):
      return [guildId.rawValue]
    case let .listGuildIntegrations(guildId):
      return [guildId.rawValue]
    case .listOwnGuilds:
      return []
    case let .previewPruneGuild(guildId):
      return [guildId.rawValue]
    case let .banUserFromGuild(guildId, userId):
      return [guildId.rawValue, userId.rawValue]
    case let .updateGuildOnboarding(guildId):
      return [guildId.rawValue]
    case let .bulkBanUsersFromGuild(guildId):
      return [guildId.rawValue]
    case .createGuild:
      return []
    case let .createGuildChannel(guildId):
      return [guildId.rawValue]
    case let .pruneGuild(guildId):
      return [guildId.rawValue]
    case let .setGuildMfaLevel(guildId):
      return [guildId.rawValue]
    case let .updateGuild(guildId):
      return [guildId.rawValue]
    case let .updateGuildChannelPositions(guildId):
      return [guildId.rawValue]
    case let .updateGuildWelcomeScreen(guildId):
      return [guildId.rawValue]
    case let .updateGuildWidgetSettings(guildId):
      return [guildId.rawValue]
    case let .deleteGuild(guildId):
      return [guildId.rawValue]
    case let .deleteGuildIntegration(guildId, integrationId):
      return [guildId.rawValue, integrationId.rawValue]
    case let .leaveGuild(guildId):
      return [guildId.rawValue]
    case let .unbanUserFromGuild(guildId, userId):
      return [guildId.rawValue, userId.rawValue]
    case let .getGuildTemplate(code):
      return [code]
    case let .listGuildTemplates(guildId):
      return [guildId.rawValue]
    case let .syncGuildTemplate(guildId, code):
      return [guildId.rawValue, code]
    case let .createGuildFromTemplate(code):
      return [code]
    case let .createGuildTemplate(guildId):
      return [guildId.rawValue]
    case let .updateGuildTemplate(guildId, code):
      return [guildId.rawValue, code]
    case let .deleteGuildTemplate(guildId, code):
      return [guildId.rawValue, code]
    case let .getFollowupMessage(applicationId, interactionToken, messageId):
      return [applicationId.rawValue, interactionToken, messageId.rawValue]
    case let .getOriginalInteractionResponse(applicationId, interactionToken):
      return [applicationId.rawValue, interactionToken]
    case let .createFollowupMessage(applicationId, interactionToken):
      return [applicationId.rawValue, interactionToken]
    case let .createInteractionResponse(interactionId, interactionToken):
      return [interactionId.rawValue, interactionToken]
    case let .updateFollowupMessage(applicationId, interactionToken, messageId):
      return [applicationId.rawValue, interactionToken, messageId.rawValue]
    case let .updateOriginalInteractionResponse(applicationId, interactionToken):
      return [applicationId.rawValue, interactionToken]
    case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
      return [applicationId.rawValue, interactionToken, messageId.rawValue]
    case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
      return [applicationId.rawValue, interactionToken]
    case let .listChannelInvites(channelId):
      return [channelId.rawValue]
    case let .listGuildInvites(guildId):
      return [guildId.rawValue]
    case let .resolveInvite(code):
      return [code]
    case let .createChannelInvite(channelId):
      return [channelId.rawValue]
    case let .revokeInvite(code):
      return [code]
    case let .getGuildMember(guildId, userId):
      return [guildId.rawValue, userId.rawValue]
    case let .getOwnGuildMember(guildId):
      return [guildId.rawValue]
    case let .listGuildMembers(guildId):
      return [guildId.rawValue]
    case let .searchGuildMembers(guildId):
      return [guildId.rawValue]
    case let .addGuildMember(guildId, userId):
      return [guildId.rawValue, userId.rawValue]
    case let .updateGuildMember(guildId, userId):
      return [guildId.rawValue, userId.rawValue]
    case let .updateOwnGuildMember(guildId):
      return [guildId.rawValue]
    case let .deleteGuildMember(guildId, userId):
      return [guildId.rawValue, userId.rawValue]
    case let .getMessage(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
      return [channelId.rawValue, messageId.rawValue, emojiName]
    case let .listMessages(channelId):
      return [channelId.rawValue]
    case let .addMessageReaction(channelId, messageId, emojiName):
      return [channelId.rawValue, messageId.rawValue, emojiName]
    case let .bulkDeleteMessages(channelId):
      return [channelId.rawValue]
    case let .createMessage(channelId):
      return [channelId.rawValue]
    case let .crosspostMessage(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .updateMessage(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .deleteAllMessageReactions(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
      return [channelId.rawValue, messageId.rawValue, emojiName]
    case let .deleteMessage(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
      return [channelId.rawValue, messageId.rawValue, emojiName]
    case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
      return [
        channelId.rawValue, messageId.rawValue, emojiName, userId.rawValue,
      ]
    case .getOwnOauth2Application:
      return []
    case let .listGuildRoles(guildId):
      return [guildId.rawValue]
    case let .addGuildMemberRole(guildId, userId, roleId):
      return [guildId.rawValue, userId.rawValue, roleId.rawValue]
    case let .createGuildRole(guildId):
      return [guildId.rawValue]
    case let .updateGuildRole(guildId, roleId):
      return [guildId.rawValue, roleId.rawValue]
    case let .updateGuildRolePositions(guildId):
      return [guildId.rawValue]
    case let .deleteGuildMemberRole(guildId, userId, roleId):
      return [guildId.rawValue, userId.rawValue, roleId.rawValue]
    case let .deleteGuildRole(guildId, roleId):
      return [guildId.rawValue, roleId.rawValue]
    case let .getApplicationUserRoleConnection(applicationId):
      return [applicationId.rawValue]
    case let .listApplicationRoleConnectionMetadata(applicationId):
      return [applicationId.rawValue]
    case let .bulkOverwriteApplicationRoleConnectionMetadata(applicationId):
      return [applicationId.rawValue]
    case let .updateApplicationUserRoleConnection(applicationId):
      return [applicationId.rawValue]
    case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
      return [guildId.rawValue, guildScheduledEventId.rawValue]
    case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
      return [guildId.rawValue, guildScheduledEventId.rawValue]
    case let .listGuildScheduledEvents(guildId):
      return [guildId.rawValue]
    case let .createGuildScheduledEvent(guildId):
      return [guildId.rawValue]
    case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
      return [guildId.rawValue, guildScheduledEventId.rawValue]
    case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
      return [guildId.rawValue, guildScheduledEventId.rawValue]
    case let .listSkus(applicationId):
      return [applicationId.rawValue]
    case let .getStageInstance(channelId):
      return [channelId.rawValue]
    case .createStageInstance:
      return []
    case let .updateStageInstance(channelId):
      return [channelId.rawValue]
    case let .deleteStageInstance(channelId):
      return [channelId.rawValue]
    case let .getGuildSticker(guildId, stickerId):
      return [guildId.rawValue, stickerId.rawValue]
    case let .getSticker(stickerId):
      return [stickerId.rawValue]
    case let .listGuildStickers(guildId):
      return [guildId.rawValue]
    case .listStickerPacks:
      return []
    case let .createGuildSticker(guildId):
      return [guildId.rawValue]
    case let .updateGuildSticker(guildId, stickerId):
      return [guildId.rawValue, stickerId.rawValue]
    case let .deleteGuildSticker(guildId, stickerId):
      return [guildId.rawValue, stickerId.rawValue]
    case let .getThreadMember(channelId, userId):
      return [channelId.rawValue, userId.rawValue]
    case let .listActiveGuildThreads(guildId):
      return [guildId.rawValue]
    case let .listOwnPrivateArchivedThreads(channelId):
      return [channelId.rawValue]
    case let .listPrivateArchivedThreads(channelId):
      return [channelId.rawValue]
    case let .listPublicArchivedThreads(channelId):
      return [channelId.rawValue]
    case let .listThreadMembers(channelId):
      return [channelId.rawValue]
    case let .addThreadMember(channelId, userId):
      return [channelId.rawValue, userId.rawValue]
    case let .joinThread(channelId):
      return [channelId.rawValue]
    case let .createThread(channelId):
      return [channelId.rawValue]
    case let .createThreadFromMessage(channelId, messageId):
      return [channelId.rawValue, messageId.rawValue]
    case let .createThreadInForumChannel(channelId):
      return [channelId.rawValue]
    case let .deleteThreadMember(channelId, userId):
      return [channelId.rawValue, userId.rawValue]
    case let .leaveThread(channelId):
      return [channelId.rawValue]
    case .getOwnApplication:
      return []
    case .getOwnUser:
      return []
    case let .getUser(userId):
      return [userId.rawValue]
    case .listOwnConnections:
      return []
    case .updateOwnApplication:
      return []
    case .updateOwnUser:
      return []
    case let .listGuildVoiceRegions(guildId):
      return [guildId.rawValue]
    case .listVoiceRegions:
      return []
    case let .updateSelfVoiceState(guildId):
      return [guildId.rawValue]
    case let .updateVoiceState(guildId, userId):
      return [guildId.rawValue, userId.rawValue]
    case let .getGuildWebhooks(guildId):
      return [guildId.rawValue]
    case let .getWebhook(webhookId):
      return [webhookId.rawValue]
    case let .getWebhookByToken(webhookId, webhookToken):
      return [webhookId.rawValue, webhookToken]
    case let .getWebhookMessage(webhookId, webhookToken, messageId):
      return [webhookId.rawValue, webhookToken, messageId.rawValue]
    case let .listChannelWebhooks(channelId):
      return [channelId.rawValue]
    case let .createWebhook(channelId):
      return [channelId.rawValue]
    case let .executeWebhook(webhookId, webhookToken):
      return [webhookId.rawValue, webhookToken]
    case let .updateWebhook(webhookId):
      return [webhookId.rawValue]
    case let .updateWebhookByToken(webhookId, webhookToken):
      return [webhookId.rawValue, webhookToken]
    case let .updateWebhookMessage(webhookId, webhookToken, messageId):
      return [webhookId.rawValue, webhookToken, messageId.rawValue]
    case let .deleteWebhook(webhookId):
      return [webhookId.rawValue]
    case let .deleteWebhookByToken(webhookId, webhookToken):
      return [webhookId.rawValue, webhookToken]
    case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
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
    case .createGroupDm: return 15
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
    case .listStickerPacks: return 145
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
    case .listGuildVoiceRegions: return 168
    case .listVoiceRegions: return 169
    case .updateSelfVoiceState: return 170
    case .updateVoiceState: return 171
    case .getGuildWebhooks: return 172
    case .getWebhook: return 173
    case .getWebhookByToken: return 174
    case .getWebhookMessage: return 175
    case .listChannelWebhooks: return 176
    case .createWebhook: return 177
    case .executeWebhook: return 178
    case .updateWebhook: return 179
    case .updateWebhookByToken: return 180
    case .updateWebhookMessage: return 181
    case .deleteWebhook: return 182
    case .deleteWebhookByToken: return 183
    case .deleteWebhookMessage: return 184
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var description: String {
    switch self {
    case let .listPollAnswerVoters(channelId, messageId, answerId):
      return
        "listPollAnswerVoters(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), answerId: \(answerId))"
    case let .endPoll(channelId, messageId):
      return
        "endPoll(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .getAutoModerationRule(guildId, ruleId):
      return
        "getAutoModerationRule(guildId.rawValue: \(guildId.rawValue), ruleId.rawValue: \(ruleId.rawValue))"
    case let .listAutoModerationRules(guildId):
      return "listAutoModerationRules(guildId.rawValue: \(guildId.rawValue))"
    case let .createAutoModerationRule(guildId):
      return "createAutoModerationRule(guildId.rawValue: \(guildId.rawValue))"
    case let .updateAutoModerationRule(guildId, ruleId):
      return
        "updateAutoModerationRule(guildId.rawValue: \(guildId.rawValue), ruleId.rawValue: \(ruleId.rawValue))"
    case let .deleteAutoModerationRule(guildId, ruleId):
      return
        "deleteAutoModerationRule(guildId.rawValue: \(guildId.rawValue), ruleId.rawValue: \(ruleId.rawValue))"
    case let .listGuildAuditLogEntries(guildId):
      return "listGuildAuditLogEntries(guildId.rawValue: \(guildId.rawValue))"
    case let .getChannel(channelId):
      return "getChannel(channelId.rawValue: \(channelId.rawValue))"
    case let .listPinnedMessages(channelId):
      return "listPinnedMessages(channelId.rawValue: \(channelId.rawValue))"
    case let .addGroupDmUser(channelId, userId):
      return
        "addGroupDmUser(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .pinMessage(channelId, messageId):
      return
        "pinMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .setChannelPermissionOverwrite(channelId, overwriteId):
      return
        "setChannelPermissionOverwrite(channelId.rawValue: \(channelId.rawValue), overwriteId.rawValue: \(overwriteId.rawValue))"
    case .createDm:
      return "createDm"
    case .createGroupDm:
      return "createGroupDm"
    case let .followAnnouncementChannel(channelId):
      return
        "followAnnouncementChannel(channelId.rawValue: \(channelId.rawValue))"
    case let .triggerTypingIndicator(channelId):
      return "triggerTypingIndicator(channelId.rawValue: \(channelId.rawValue))"
    case let .updateChannel(channelId):
      return "updateChannel(channelId.rawValue: \(channelId.rawValue))"
    case let .deleteChannel(channelId):
      return "deleteChannel(channelId.rawValue: \(channelId.rawValue))"
    case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
      return
        "deleteChannelPermissionOverwrite(channelId.rawValue: \(channelId.rawValue), overwriteId.rawValue: \(overwriteId.rawValue))"
    case let .deleteGroupDmUser(channelId, userId):
      return
        "deleteGroupDmUser(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .unpinMessage(channelId, messageId):
      return
        "unpinMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .getApplicationCommand(applicationId, commandId):
      return
        "getApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case let .getGuildApplicationCommand(applicationId, guildId, commandId):
      return
        "getGuildApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case let .getGuildApplicationCommandPermissions(
      applicationId, guildId, commandId):
      return
        "getGuildApplicationCommandPermissions(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case let .listApplicationCommands(applicationId):
      return
        "listApplicationCommands(applicationId.rawValue: \(applicationId.rawValue))"
    case let .listGuildApplicationCommandPermissions(applicationId, guildId):
      return
        "listGuildApplicationCommandPermissions(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue))"
    case let .listGuildApplicationCommands(applicationId, guildId):
      return
        "listGuildApplicationCommands(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue))"
    case let .bulkSetApplicationCommands(applicationId):
      return
        "bulkSetApplicationCommands(applicationId.rawValue: \(applicationId.rawValue))"
    case let .bulkSetGuildApplicationCommands(applicationId, guildId):
      return
        "bulkSetGuildApplicationCommands(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue))"
    case let .setGuildApplicationCommandPermissions(
      applicationId, guildId, commandId):
      return
        "setGuildApplicationCommandPermissions(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case let .createApplicationCommand(applicationId):
      return
        "createApplicationCommand(applicationId.rawValue: \(applicationId.rawValue))"
    case let .createGuildApplicationCommand(applicationId, guildId):
      return
        "createGuildApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue))"
    case let .updateApplicationCommand(applicationId, commandId):
      return
        "updateApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
      return
        "updateGuildApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case let .deleteApplicationCommand(applicationId, commandId):
      return
        "deleteApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
      return
        "deleteGuildApplicationCommand(applicationId.rawValue: \(applicationId.rawValue), guildId.rawValue: \(guildId.rawValue), commandId.rawValue: \(commandId.rawValue))"
    case let .getGuildEmoji(guildId, emojiId):
      return
        "getGuildEmoji(guildId.rawValue: \(guildId.rawValue), emojiId.rawValue: \(emojiId.rawValue))"
    case let .listGuildEmojis(guildId):
      return "listGuildEmojis(guildId.rawValue: \(guildId.rawValue))"
    case let .createGuildEmoji(guildId):
      return "createGuildEmoji(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuildEmoji(guildId, emojiId):
      return
        "updateGuildEmoji(guildId.rawValue: \(guildId.rawValue), emojiId.rawValue: \(emojiId.rawValue))"
    case let .deleteGuildEmoji(guildId, emojiId):
      return
        "deleteGuildEmoji(guildId.rawValue: \(guildId.rawValue), emojiId.rawValue: \(emojiId.rawValue))"
    case let .listEntitlements(applicationId):
      return
        "listEntitlements(applicationId.rawValue: \(applicationId.rawValue))"
    case let .consumeEntitlement(applicationId, entitlementId):
      return
        "consumeEntitlement(applicationId.rawValue: \(applicationId.rawValue), entitlementId.rawValue: \(entitlementId.rawValue))"
    case let .createTestEntitlement(applicationId):
      return
        "createTestEntitlement(applicationId.rawValue: \(applicationId.rawValue))"
    case let .deleteTestEntitlement(applicationId, entitlementId):
      return
        "deleteTestEntitlement(applicationId.rawValue: \(applicationId.rawValue), entitlementId.rawValue: \(entitlementId.rawValue))"
    case .getBotGateway:
      return "getBotGateway"
    case .getGateway:
      return "getGateway"
    case let .getGuild(guildId):
      return "getGuild(guildId.rawValue: \(guildId.rawValue))"
    case let .getGuildBan(guildId, userId):
      return
        "getGuildBan(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .getGuildOnboarding(guildId):
      return "getGuildOnboarding(guildId.rawValue: \(guildId.rawValue))"
    case let .getGuildPreview(guildId):
      return "getGuildPreview(guildId.rawValue: \(guildId.rawValue))"
    case let .getGuildVanityUrl(guildId):
      return "getGuildVanityUrl(guildId.rawValue: \(guildId.rawValue))"
    case let .getGuildWelcomeScreen(guildId):
      return "getGuildWelcomeScreen(guildId.rawValue: \(guildId.rawValue))"
    case let .getGuildWidget(guildId):
      return "getGuildWidget(guildId.rawValue: \(guildId.rawValue))"
    case let .getGuildWidgetPng(guildId):
      return "getGuildWidgetPng(guildId.rawValue: \(guildId.rawValue))"
    case let .getGuildWidgetSettings(guildId):
      return "getGuildWidgetSettings(guildId.rawValue: \(guildId.rawValue))"
    case let .listGuildBans(guildId):
      return "listGuildBans(guildId.rawValue: \(guildId.rawValue))"
    case let .listGuildChannels(guildId):
      return "listGuildChannels(guildId.rawValue: \(guildId.rawValue))"
    case let .listGuildIntegrations(guildId):
      return "listGuildIntegrations(guildId.rawValue: \(guildId.rawValue))"
    case .listOwnGuilds:
      return "listOwnGuilds"
    case let .previewPruneGuild(guildId):
      return "previewPruneGuild(guildId.rawValue: \(guildId.rawValue))"
    case let .banUserFromGuild(guildId, userId):
      return
        "banUserFromGuild(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .updateGuildOnboarding(guildId):
      return "updateGuildOnboarding(guildId.rawValue: \(guildId.rawValue))"
    case let .bulkBanUsersFromGuild(guildId):
      return "bulkBanUsersFromGuild(guildId.rawValue: \(guildId.rawValue))"
    case .createGuild:
      return "createGuild"
    case let .createGuildChannel(guildId):
      return "createGuildChannel(guildId.rawValue: \(guildId.rawValue))"
    case let .pruneGuild(guildId):
      return "pruneGuild(guildId.rawValue: \(guildId.rawValue))"
    case let .setGuildMfaLevel(guildId):
      return "setGuildMfaLevel(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuild(guildId):
      return "updateGuild(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuildChannelPositions(guildId):
      return
        "updateGuildChannelPositions(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuildWelcomeScreen(guildId):
      return "updateGuildWelcomeScreen(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuildWidgetSettings(guildId):
      return "updateGuildWidgetSettings(guildId.rawValue: \(guildId.rawValue))"
    case let .deleteGuild(guildId):
      return "deleteGuild(guildId.rawValue: \(guildId.rawValue))"
    case let .deleteGuildIntegration(guildId, integrationId):
      return
        "deleteGuildIntegration(guildId.rawValue: \(guildId.rawValue), integrationId.rawValue: \(integrationId.rawValue))"
    case let .leaveGuild(guildId):
      return "leaveGuild(guildId.rawValue: \(guildId.rawValue))"
    case let .unbanUserFromGuild(guildId, userId):
      return
        "unbanUserFromGuild(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .getGuildTemplate(code):
      return "getGuildTemplate(code: \(code))"
    case let .listGuildTemplates(guildId):
      return "listGuildTemplates(guildId.rawValue: \(guildId.rawValue))"
    case let .syncGuildTemplate(guildId, code):
      return
        "syncGuildTemplate(guildId.rawValue: \(guildId.rawValue), code: \(code))"
    case let .createGuildFromTemplate(code):
      return "createGuildFromTemplate(code: \(code))"
    case let .createGuildTemplate(guildId):
      return "createGuildTemplate(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuildTemplate(guildId, code):
      return
        "updateGuildTemplate(guildId.rawValue: \(guildId.rawValue), code: \(code))"
    case let .deleteGuildTemplate(guildId, code):
      return
        "deleteGuildTemplate(guildId.rawValue: \(guildId.rawValue), code: \(code))"
    case let .getFollowupMessage(applicationId, interactionToken, messageId):
      return
        "getFollowupMessage(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken), messageId.rawValue: \(messageId.rawValue))"
    case let .getOriginalInteractionResponse(applicationId, interactionToken):
      return
        "getOriginalInteractionResponse(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken))"
    case let .createFollowupMessage(applicationId, interactionToken):
      return
        "createFollowupMessage(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken))"
    case let .createInteractionResponse(interactionId, interactionToken):
      return
        "createInteractionResponse(interactionId.rawValue: \(interactionId.rawValue), interactionToken: \(interactionToken))"
    case let .updateFollowupMessage(applicationId, interactionToken, messageId):
      return
        "updateFollowupMessage(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken), messageId.rawValue: \(messageId.rawValue))"
    case let .updateOriginalInteractionResponse(applicationId, interactionToken):
      return
        "updateOriginalInteractionResponse(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken))"
    case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
      return
        "deleteFollowupMessage(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken), messageId.rawValue: \(messageId.rawValue))"
    case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
      return
        "deleteOriginalInteractionResponse(applicationId.rawValue: \(applicationId.rawValue), interactionToken: \(interactionToken))"
    case let .listChannelInvites(channelId):
      return "listChannelInvites(channelId.rawValue: \(channelId.rawValue))"
    case let .listGuildInvites(guildId):
      return "listGuildInvites(guildId.rawValue: \(guildId.rawValue))"
    case let .resolveInvite(code):
      return "resolveInvite(code: \(code))"
    case let .createChannelInvite(channelId):
      return "createChannelInvite(channelId.rawValue: \(channelId.rawValue))"
    case let .revokeInvite(code):
      return "revokeInvite(code: \(code))"
    case let .getGuildMember(guildId, userId):
      return
        "getGuildMember(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .getOwnGuildMember(guildId):
      return "getOwnGuildMember(guildId.rawValue: \(guildId.rawValue))"
    case let .listGuildMembers(guildId):
      return "listGuildMembers(guildId.rawValue: \(guildId.rawValue))"
    case let .searchGuildMembers(guildId):
      return "searchGuildMembers(guildId.rawValue: \(guildId.rawValue))"
    case let .addGuildMember(guildId, userId):
      return
        "addGuildMember(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .updateGuildMember(guildId, userId):
      return
        "updateGuildMember(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .updateOwnGuildMember(guildId):
      return "updateOwnGuildMember(guildId.rawValue: \(guildId.rawValue))"
    case let .deleteGuildMember(guildId, userId):
      return
        "deleteGuildMember(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .getMessage(channelId, messageId):
      return
        "getMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
      return
        "listMessageReactionsByEmoji(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName))"
    case let .listMessages(channelId):
      return "listMessages(channelId.rawValue: \(channelId.rawValue))"
    case let .addMessageReaction(channelId, messageId, emojiName):
      return
        "addMessageReaction(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName))"
    case let .bulkDeleteMessages(channelId):
      return "bulkDeleteMessages(channelId.rawValue: \(channelId.rawValue))"
    case let .createMessage(channelId):
      return "createMessage(channelId.rawValue: \(channelId.rawValue))"
    case let .crosspostMessage(channelId, messageId):
      return
        "crosspostMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .updateMessage(channelId, messageId):
      return
        "updateMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .deleteAllMessageReactions(channelId, messageId):
      return
        "deleteAllMessageReactions(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
      return
        "deleteAllMessageReactionsByEmoji(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName))"
    case let .deleteMessage(channelId, messageId):
      return
        "deleteMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
      return
        "deleteOwnMessageReaction(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName))"
    case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
      return
        "deleteUserMessageReaction(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue), emojiName: \(emojiName), userId.rawValue: \(userId.rawValue))"
    case .getOwnOauth2Application:
      return "getOwnOauth2Application"
    case let .listGuildRoles(guildId):
      return "listGuildRoles(guildId.rawValue: \(guildId.rawValue))"
    case let .addGuildMemberRole(guildId, userId, roleId):
      return
        "addGuildMemberRole(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue), roleId.rawValue: \(roleId.rawValue))"
    case let .createGuildRole(guildId):
      return "createGuildRole(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuildRole(guildId, roleId):
      return
        "updateGuildRole(guildId.rawValue: \(guildId.rawValue), roleId.rawValue: \(roleId.rawValue))"
    case let .updateGuildRolePositions(guildId):
      return "updateGuildRolePositions(guildId.rawValue: \(guildId.rawValue))"
    case let .deleteGuildMemberRole(guildId, userId, roleId):
      return
        "deleteGuildMemberRole(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue), roleId.rawValue: \(roleId.rawValue))"
    case let .deleteGuildRole(guildId, roleId):
      return
        "deleteGuildRole(guildId.rawValue: \(guildId.rawValue), roleId.rawValue: \(roleId.rawValue))"
    case let .getApplicationUserRoleConnection(applicationId):
      return
        "getApplicationUserRoleConnection(applicationId.rawValue: \(applicationId.rawValue))"
    case let .listApplicationRoleConnectionMetadata(applicationId):
      return
        "listApplicationRoleConnectionMetadata(applicationId.rawValue: \(applicationId.rawValue))"
    case let .bulkOverwriteApplicationRoleConnectionMetadata(applicationId):
      return
        "bulkOverwriteApplicationRoleConnectionMetadata(applicationId.rawValue: \(applicationId.rawValue))"
    case let .updateApplicationUserRoleConnection(applicationId):
      return
        "updateApplicationUserRoleConnection(applicationId.rawValue: \(applicationId.rawValue))"
    case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
      return
        "getGuildScheduledEvent(guildId.rawValue: \(guildId.rawValue), guildScheduledEventId.rawValue: \(guildScheduledEventId.rawValue))"
    case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
      return
        "listGuildScheduledEventUsers(guildId.rawValue: \(guildId.rawValue), guildScheduledEventId.rawValue: \(guildScheduledEventId.rawValue))"
    case let .listGuildScheduledEvents(guildId):
      return "listGuildScheduledEvents(guildId.rawValue: \(guildId.rawValue))"
    case let .createGuildScheduledEvent(guildId):
      return "createGuildScheduledEvent(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
      return
        "updateGuildScheduledEvent(guildId.rawValue: \(guildId.rawValue), guildScheduledEventId.rawValue: \(guildScheduledEventId.rawValue))"
    case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
      return
        "deleteGuildScheduledEvent(guildId.rawValue: \(guildId.rawValue), guildScheduledEventId.rawValue: \(guildScheduledEventId.rawValue))"
    case let .listSkus(applicationId):
      return "listSkus(applicationId.rawValue: \(applicationId.rawValue))"
    case let .getStageInstance(channelId):
      return "getStageInstance(channelId.rawValue: \(channelId.rawValue))"
    case .createStageInstance:
      return "createStageInstance"
    case let .updateStageInstance(channelId):
      return "updateStageInstance(channelId.rawValue: \(channelId.rawValue))"
    case let .deleteStageInstance(channelId):
      return "deleteStageInstance(channelId.rawValue: \(channelId.rawValue))"
    case let .getGuildSticker(guildId, stickerId):
      return
        "getGuildSticker(guildId.rawValue: \(guildId.rawValue), stickerId.rawValue: \(stickerId.rawValue))"
    case let .getSticker(stickerId):
      return "getSticker(stickerId.rawValue: \(stickerId.rawValue))"
    case let .listGuildStickers(guildId):
      return "listGuildStickers(guildId.rawValue: \(guildId.rawValue))"
    case .listStickerPacks:
      return "listStickerPacks"
    case let .createGuildSticker(guildId):
      return "createGuildSticker(guildId.rawValue: \(guildId.rawValue))"
    case let .updateGuildSticker(guildId, stickerId):
      return
        "updateGuildSticker(guildId.rawValue: \(guildId.rawValue), stickerId.rawValue: \(stickerId.rawValue))"
    case let .deleteGuildSticker(guildId, stickerId):
      return
        "deleteGuildSticker(guildId.rawValue: \(guildId.rawValue), stickerId.rawValue: \(stickerId.rawValue))"
    case let .getThreadMember(channelId, userId):
      return
        "getThreadMember(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .listActiveGuildThreads(guildId):
      return "listActiveGuildThreads(guildId.rawValue: \(guildId.rawValue))"
    case let .listOwnPrivateArchivedThreads(channelId):
      return
        "listOwnPrivateArchivedThreads(channelId.rawValue: \(channelId.rawValue))"
    case let .listPrivateArchivedThreads(channelId):
      return
        "listPrivateArchivedThreads(channelId.rawValue: \(channelId.rawValue))"
    case let .listPublicArchivedThreads(channelId):
      return
        "listPublicArchivedThreads(channelId.rawValue: \(channelId.rawValue))"
    case let .listThreadMembers(channelId):
      return "listThreadMembers(channelId.rawValue: \(channelId.rawValue))"
    case let .addThreadMember(channelId, userId):
      return
        "addThreadMember(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .joinThread(channelId):
      return "joinThread(channelId.rawValue: \(channelId.rawValue))"
    case let .createThread(channelId):
      return "createThread(channelId.rawValue: \(channelId.rawValue))"
    case let .createThreadFromMessage(channelId, messageId):
      return
        "createThreadFromMessage(channelId.rawValue: \(channelId.rawValue), messageId.rawValue: \(messageId.rawValue))"
    case let .createThreadInForumChannel(channelId):
      return
        "createThreadInForumChannel(channelId.rawValue: \(channelId.rawValue))"
    case let .deleteThreadMember(channelId, userId):
      return
        "deleteThreadMember(channelId.rawValue: \(channelId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .leaveThread(channelId):
      return "leaveThread(channelId.rawValue: \(channelId.rawValue))"
    case .getOwnApplication:
      return "getOwnApplication"
    case .getOwnUser:
      return "getOwnUser"
    case let .getUser(userId):
      return "getUser(userId.rawValue: \(userId.rawValue))"
    case .listOwnConnections:
      return "listOwnConnections"
    case .updateOwnApplication:
      return "updateOwnApplication"
    case .updateOwnUser:
      return "updateOwnUser"
    case let .listGuildVoiceRegions(guildId):
      return "listGuildVoiceRegions(guildId.rawValue: \(guildId.rawValue))"
    case .listVoiceRegions:
      return "listVoiceRegions"
    case let .updateSelfVoiceState(guildId):
      return "updateSelfVoiceState(guildId.rawValue: \(guildId.rawValue))"
    case let .updateVoiceState(guildId, userId):
      return
        "updateVoiceState(guildId.rawValue: \(guildId.rawValue), userId.rawValue: \(userId.rawValue))"
    case let .getGuildWebhooks(guildId):
      return "getGuildWebhooks(guildId.rawValue: \(guildId.rawValue))"
    case let .getWebhook(webhookId):
      return "getWebhook(webhookId.rawValue: \(webhookId.rawValue))"
    case let .getWebhookByToken(webhookId, webhookToken):
      return
        "getWebhookByToken(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken))"
    case let .getWebhookMessage(webhookId, webhookToken, messageId):
      return
        "getWebhookMessage(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken), messageId.rawValue: \(messageId.rawValue))"
    case let .listChannelWebhooks(channelId):
      return "listChannelWebhooks(channelId.rawValue: \(channelId.rawValue))"
    case let .createWebhook(channelId):
      return "createWebhook(channelId.rawValue: \(channelId.rawValue))"
    case let .executeWebhook(webhookId, webhookToken):
      return
        "executeWebhook(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken))"
    case let .updateWebhook(webhookId):
      return "updateWebhook(webhookId.rawValue: \(webhookId.rawValue))"
    case let .updateWebhookByToken(webhookId, webhookToken):
      return
        "updateWebhookByToken(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken))"
    case let .updateWebhookMessage(webhookId, webhookToken, messageId):
      return
        "updateWebhookMessage(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken), messageId.rawValue: \(messageId.rawValue))"
    case let .deleteWebhook(webhookId):
      return "deleteWebhook(webhookId.rawValue: \(webhookId.rawValue))"
    case let .deleteWebhookByToken(webhookId, webhookToken):
      return
        "deleteWebhookByToken(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken))"
    case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
      return
        "deleteWebhookMessage(webhookId.rawValue: \(webhookId.rawValue), webhookToken: \(webhookToken), messageId.rawValue: \(messageId.rawValue))"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
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
  case listStickerPacks

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
    case .listStickerPacks: return "listStickerPacks"
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

  init?(endpoint: UserAPIEndpoint) {
    switch endpoint {
    default: return nil
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
    case .listStickerPacks: self = .listStickerPacks
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
