import DiscordModels
import Logging

/// Convenience protocol for handling gateway payloads.
///
/// Create a type that conforms to `GatewayEventHandler`:
/// ```
/// struct EventHandler: GatewayEventHandler {
///     let event: Gateway.Event
///
///     func onMessageCreate(_ payload: Gateway.MessageCreate) async {
///         /// Do what you want
///     }
///
///     func onInteractionCreate(_ payload: Interaction) async {
///         /// Do what you want
///     }
///
///     /// Use other functions you'd like ...
/// }
/// ```
///
/// Make sure to actually use the type:
/// ```
/// let bot: any GatewayManager = <#GatewayManager_YOU_MADE_IN_PREVIOUS_STEPS#>
///
/// for await event in await bot.makeEventsStream() {
///     EventHandler(event: event).handle()
/// }
/// ```
//public protocol GatewayEventHandler: Sendable {
//  var event: Gateway.Event { get }
//  var logger: Logger { get }
//
//  /// To be executed before handling events.
//  /// If returns `false`, the event won't be passed to the functions below anymore.
//  func onEventHandlerStart() async throws -> Bool
//  func onEventHandlerEnd() async throws
//
//  /// MARK: State-management data
//  func onHeartbeat(lastSequenceNumber: Int?) async throws
//  func onHello(_ payload: Gateway.Hello) async throws
//  func onReady(_ payload: Gateway.Ready) async throws
//  func onResumed() async throws
//  func onInvalidSession(canResume: Bool) async throws
//
//  /// MARK: Events
//  func onChannelCreate(_ payload: DiscordChannel) async throws
//  func onChannelUpdate(_ payload: DiscordChannel) async throws
//  func onChannelDelete(_ payload: DiscordChannel) async throws
//  func onChannelPinsUpdate(_ payload: Gateway.ChannelPinsUpdate) async throws
//  func onThreadCreate(_ payload: DiscordChannel) async throws
//  func onThreadUpdate(_ payload: DiscordChannel) async throws
//  func onThreadDelete(_ payload: Gateway.ThreadDelete) async throws
//  func onThreadSyncList(_ payload: Gateway.ThreadListSync) async throws
//  func onThreadMemberUpdate(_ payload: Gateway.ThreadMemberUpdate) async throws
//  func onThreadMembersUpdate(_ payload: Gateway.ThreadMembersUpdate)
//    async throws
//  func onEntitlementCreate(_ payload: Entitlement) async throws
//  func onEntitlementUpdate(_ payload: Entitlement) async throws
//  func onEntitlementDelete(_ payload: Entitlement) async throws
//  func onGuildCreate(_ payload: Gateway.GuildCreate) async throws
//  func onGuildUpdate(_ payload: Guild) async throws
//  func onGuildDelete(_ payload: UnavailableGuild) async throws
//  func onGuildBanAdd(_ payload: Gateway.GuildBan) async throws
//  func onGuildBanRemove(_ payload: Gateway.GuildBan) async throws
//  func onGuildEmojisUpdate(_ payload: Gateway.GuildEmojisUpdate) async throws
//  func onGuildStickersUpdate(_ payload: Gateway.GuildStickersUpdate)
//    async throws
//  func onGuildIntegrationsUpdate(_ payload: Gateway.GuildIntegrationsUpdate)
//    async throws
//  func onGuildMemberAdd(_ payload: Gateway.GuildMemberAdd) async throws
//  func onGuildMemberRemove(_ payload: Gateway.GuildMemberRemove) async throws
//  func onGuildMemberUpdate(_ payload: Gateway.GuildMemberAdd) async throws
//  func onGuildMembersChunk(_ payload: Gateway.GuildMembersChunk) async throws
//  func onRequestGuildMembers(_ payload: Gateway.RequestGuildMembers)
//    async throws
//  func onGuildRoleCreate(_ payload: Gateway.GuildRole) async throws
//  func onGuildRoleUpdate(_ payload: Gateway.GuildRole) async throws
//  func onGuildRoleDelete(_ payload: Gateway.GuildRoleDelete) async throws
//  func onGuildScheduledEventCreate(_ payload: GuildScheduledEvent) async throws
//  func onGuildScheduledEventUpdate(_ payload: GuildScheduledEvent) async throws
//  func onGuildScheduledEventDelete(_ payload: GuildScheduledEvent) async throws
//  func onGuildScheduledEventUserAdd(_ payload: Gateway.GuildScheduledEventUser)
//    async throws
//  func onGuildScheduledEventUserRemove(
//    _ payload: Gateway.GuildScheduledEventUser
//  ) async throws
//  func onGuildAuditLogEntryCreate(_ payload: AuditLog.Entry) async throws
//  func onIntegrationCreate(_ payload: Gateway.IntegrationCreate) async throws
//  func onIntegrationUpdate(_ payload: Gateway.IntegrationCreate) async throws
//  func onIntegrationDelete(_ payload: Gateway.IntegrationDelete) async throws
//  func onInteractionCreate(_ payload: Gateway.InteractionCreate) async throws
//  func onInviteCreate(_ payload: Gateway.InviteCreate) async throws
//  func onInviteDelete(_ payload: Gateway.InviteDelete) async throws
//  func onMessageCreate(_ payload: Gateway.MessageCreate) async throws
//  func onMessageUpdate(_ payload: DiscordChannel.PartialMessage) async throws
//  func onMessageDelete(_ payload: Gateway.MessageDelete) async throws
//  func onMessageAcknowledge(_ payload: Gateway.MessageAcknowledge) async throws
//  func onChannelPinsAcknowledge(_ payload: Gateway.ChannelPinsAcknowledge)
//    async throws
//  func onUserNonChannelAcknowledge(_ payload: Gateway.UserNonChannelAcknowledge)
//    async throws
//  func onMessageDeleteBulk(_ payload: Gateway.MessageDeleteBulk) async throws
//  func onMessageReactionAdd(_ payload: Gateway.MessageReactionAdd) async throws
//  func onMessageReactionRemove(_ payload: Gateway.MessageReactionRemove)
//    async throws
//  func onMessageReactionRemoveAll(_ payload: Gateway.MessageReactionRemoveAll)
//    async throws
//  func onMessageReactionRemoveEmoji(
//    _ payload: Gateway.MessageReactionRemoveEmoji
//  ) async throws
//  func onPresenceUpdate(_ payload: Gateway.PresenceUpdate) async throws
//  func onRequestPresenceUpdate(_ payload: Gateway.Identify.Presence)
//    async throws
//  func onStageInstanceCreate(_ payload: StageInstance) async throws
//  func onStageInstanceDelete(_ payload: StageInstance) async throws
//  func onStageInstanceUpdate(_ payload: StageInstance) async throws
//  func onTypingStart(_ payload: Gateway.TypingStart) async throws
//  func onUserUpdate(_ payload: DiscordUser) async throws
//  func onVoiceStateUpdate(_ payload: VoiceState) async throws
//  func onRequestVoiceStateUpdate(_ payload: VoiceStateUpdate) async throws
//  func onVoiceServerUpdate(_ payload: Gateway.VoiceServerUpdate) async throws
//  func onWebhooksUpdate(_ payload: Gateway.WebhooksUpdate) async throws
//  func onApplicationCommandPermissionsUpdate(
//    _ payload: GuildApplicationCommandPermissions
//  ) async throws
//  func onAutoModerationRuleCreate(_ payload: AutoModerationRule) async throws
//  func onAutoModerationRuleUpdate(_ payload: AutoModerationRule) async throws
//  func onAutoModerationRuleDelete(_ payload: AutoModerationRule) async throws
//  func onAutoModerationActionExecution(_ payload: AutoModerationActionExecution)
//    async throws
//  func onMessagePollVoteAdd(_ payload: Gateway.MessagePollVote) async throws
//  func onMessagePollVoteRemove(_ payload: Gateway.MessagePollVote) async throws
//  func onReadySupplemental(_ payload: Gateway.ReadySupplemental) async throws
//  func onAuthSessionChange(_ payload: Gateway.AuthSessionChange) async throws
//  func onVoiceChannelStatuses(_ payload: Gateway.VoiceChannelStatuses)
//    async throws
//  func onConversationSummaryUpdate(_ payload: Gateway.ConversationSummaryUpdate)
//    async throws
//  func onChannelRecipientAdd(_ payload: Gateway.ChannelRecipientAdd)
//    async throws
//  func onChannelRecipientRemove(_ payload: Gateway.ChannelRecipientRemove)
//    async throws
//  func onConsoleCommandUpdate(_ payload: Gateway.ConsoleCommandUpdate)
//    async throws
//  func onDMSettingsShow(_ payload: Gateway.DMSettingsShow) async throws
//  func onFriendSuggestionCreate(_ payload: Gateway.FriendSuggestionCreate)
//    async throws
//  func onFriendSuggestionDelete(_ payload: Gateway.FriendSuggestionDelete)
//    async throws
//  func onGuildApplicationCommandIndexUpdate(
//    _ payload: Gateway.GuildApplicationCommandIndexUpdate
//  ) async throws
//  func onGuildAppliedBoostsUpdate(_ payload: Guild.PremiumGuildSubscription)
//    async throws
//  func onGuildScheduledEventExceptionCreate(
//    _ payload: GuildScheduledEventException
//  ) async throws
//  func onGuildScheduledEventExceptionUpdate(
//    _ payload: GuildScheduledEventException
//  ) async throws
//  func onGuildScheduledEventExceptionDelete(
//    _ payload: GuildScheduledEventException
//  ) async throws
//  func onGuildScheduledEventExceptionsDelete(
//    _ payload: Gateway.GuildScheduledEventExceptionsDelete
//  ) async throws
//  func onInteractionFailure(_ payload: Gateway.InteractionFailure) async throws
//  func onInteractionSuccess(_ payload: Gateway.InteractionSuccess) async throws
//  func onApplicationCommandAutocompleteResponse(
//    _ payload: Gateway.ApplicationCommandAutocomplete
//  ) async throws
//  func onInteractionModalCreate(_ payload: Gateway.InteractionModalCreate)
//    async throws
//  func onInteractionIFrameModalCreate(
//    _ payload: Gateway.InteractionIFrameModalCreate
//  ) async throws
//  func onMessageReactionAddMany(_ payload: Gateway.MessageReactionAddMany)
//    async throws
//  func onRecentMentionDelete(_ payload: Gateway.RecentMentionDelete)
//    async throws
//  func onRequestLastMessages(_ payload: Gateway.RequestLastMessages)
//    async throws
//  func onLastMessages(_ payload: Gateway.LastMessages) async throws
//  func onNotificationSettingsUpdate(_ payload: Gateway.NotificationSettings)
//    async throws
//  func onRelationshipAdd(_ payload: DiscordRelationship) async throws
//  func onRelationshipUpdate(_ payload: Gateway.PartialRelationship) async throws
//  func onRelationshipRemove(_ payload: Gateway.PartialRelationship) async throws
//  func onSavedMessageCreate(_ payload: Gateway.SavedMessageCreate) async throws
//  func onSavedMessageDelete(_ payload: Gateway.SavedMessageDelete) async throws
//  func onChannelMemberCountUpdate(_ payload: Gateway.ChannelMemberCountUpdate)
//    async throws
//  func onRequestChannelMemberCount(_ payload: Gateway.RequestChannelMemberCount)
//    async throws
//  func onAutoModerationMentionRaidDetection(
//    _ payload: AutoModerationMentionRaidDetection
//  ) async throws
//  func onCallCreate(_ payload: Gateway.CallCreate) async throws
//  func onCallUpdate(_ payload: Gateway.CallUpdate) async throws
//  func onCallDelete(_ payload: Gateway.CallDelete) async throws
//  func onVoiceChannelStatusUpdate(_ payload: Gateway.VoiceChannelStatusUpdate)
//    async throws
//  func onSessionsReplace(_ payload: Gateway.SessionsReplace) async throws
//  func onUserApplicationUpdate(_ payload: Gateway.UserApplicationUpdate)
//    async throws
//  func onUserApplicationRemove(_ payload: Gateway.UserApplicationRemove)
//    async throws
//  func onUserConnectionsUpdate(_ payload: Gateway.UserConnectionsUpdate)
//    async throws
//  func onUserGuildSettingsUpdate(_ payload: Guild.UserGuildSettings)
//    async throws
//  func onUserNoteUpdate(_ payload: Gateway.UserNote) async throws
//  func onUserSettingsUpdate(_ payload: Gateway.UserSettingsProtoUpdate)
//    async throws
//  func onGuildSoundboardSoundCreate(_ payload: SoundboardSound) async throws
//  func onGuildSoundboardSoundUpdate(_ payload: SoundboardSound) async throws
//  func onGuildSoundboardSoundDelete(_ payload: Gateway.SoundboardSoundDelete)
//    async throws
//  func onSoundboardSounds(_ payload: Gateway.SoundboardSounds) async throws
//  func onChannelUnreadUpdate(_ payload: Gateway.ChannelUnreadUpdate)
//    async throws
//  func onGuildMemberListUpdate(_ payload: Gateway.GuildMemberListUpdate)
//    async throws
//}
//
//extension GatewayEventHandler {
//
//  public var logger: Logger {
//    Logger(label: "GatewayEventHandler")
//  }
//
//  @inlinable
//  public func handle() {
//    Task {
//      await self.handleAsync()
//    }
//  }
//
//  // MARK: - Default Do-Nothings
//
//  @inlinable
//  public func onEventHandlerStart() async throws -> Bool { true }
//  public func onEventHandlerEnd() async throws {}
//
//  public func onHeartbeat(lastSequenceNumber _: Int?) async throws {}
//  public func onHello(_: Gateway.Hello) async throws {}
//  public func onReady(_: Gateway.Ready) async throws {}
//  public func onResumed() async throws {}
//  public func onInvalidSession(canResume _: Bool) async throws {}
//  public func onChannelCreate(_: DiscordChannel) async throws {}
//  public func onChannelUpdate(_: DiscordChannel) async throws {}
//  public func onChannelDelete(_: DiscordChannel) async throws {}
//  public func onChannelPinsUpdate(_: Gateway.ChannelPinsUpdate) async throws {}
//  public func onThreadCreate(_: DiscordChannel) async throws {}
//  public func onThreadUpdate(_: DiscordChannel) async throws {}
//  public func onThreadDelete(_: Gateway.ThreadDelete) async throws {}
//  public func onThreadSyncList(_: Gateway.ThreadListSync) async throws {}
//  public func onThreadMemberUpdate(_: Gateway.ThreadMemberUpdate) async throws {
//  }
//  public func onEntitlementCreate(_: Entitlement) async throws {}
//  public func onEntitlementUpdate(_: Entitlement) async throws {}
//  public func onEntitlementDelete(_: Entitlement) async throws {}
//  public func onThreadMembersUpdate(_: Gateway.ThreadMembersUpdate) async throws
//  {}
//  public func onGuildCreate(_: Gateway.GuildCreate) async throws {}
//  public func onGuildUpdate(_: Guild) async throws {}
//  public func onGuildDelete(_: UnavailableGuild) async throws {}
//  public func onGuildBanAdd(_: Gateway.GuildBan) async throws {}
//  public func onGuildBanRemove(_: Gateway.GuildBan) async throws {}
//  public func onGuildEmojisUpdate(_: Gateway.GuildEmojisUpdate) async throws {}
//  public func onGuildStickersUpdate(_: Gateway.GuildStickersUpdate) async throws
//  {}
//  public func onGuildIntegrationsUpdate(_: Gateway.GuildIntegrationsUpdate)
//    async throws
//  {}
//  public func onGuildMemberAdd(_: Gateway.GuildMemberAdd) async throws {}
//  public func onGuildMemberRemove(_: Gateway.GuildMemberRemove) async throws {}
//  public func onGuildMemberUpdate(_: Gateway.GuildMemberAdd) async throws {}
//  public func onGuildMembersChunk(_: Gateway.GuildMembersChunk) async throws {}
//  public func onRequestGuildMembers(_: Gateway.RequestGuildMembers) async throws
//  {}
//  public func onGuildRoleCreate(_: Gateway.GuildRole) async throws {}
//  public func onGuildRoleUpdate(_: Gateway.GuildRole) async throws {}
//  public func onGuildRoleDelete(_: Gateway.GuildRoleDelete) async throws {}
//  public func onGuildScheduledEventCreate(_: GuildScheduledEvent) async throws {
//  }
//  public func onGuildScheduledEventUpdate(_: GuildScheduledEvent) async throws {
//  }
//  public func onGuildScheduledEventDelete(_: GuildScheduledEvent) async throws {
//  }
//  public func onGuildScheduledEventUserAdd(_: Gateway.GuildScheduledEventUser)
//    async throws
//  {}
//  public func onGuildScheduledEventUserRemove(
//    _: Gateway.GuildScheduledEventUser
//  ) async throws {}
//  public func onGuildAuditLogEntryCreate(_: AuditLog.Entry) async throws {}
//  public func onIntegrationCreate(_: Gateway.IntegrationCreate) async throws {}
//  public func onIntegrationUpdate(_: Gateway.IntegrationCreate) async throws {}
//  public func onIntegrationDelete(_: Gateway.IntegrationDelete) async throws {}
//  public func onInteractionCreate(_: Interaction) async throws {}
//  public func onInviteCreate(_: Gateway.InviteCreate) async throws {}
//  public func onInviteDelete(_: Gateway.InviteDelete) async throws {}
//  public func onMessageCreate(_: Gateway.MessageCreate) async throws {}
//  public func onMessageUpdate(_: DiscordChannel.PartialMessage) async throws {}
//  public func onMessageDelete(_: Gateway.MessageDelete) async throws {}
//  public func onMessageAcknowledge(_ payload: Gateway.MessageAcknowledge)
//    async throws
//  {}
//  public func onChannelPinsAcknowledge(
//    _ payload: Gateway.ChannelPinsAcknowledge
//  ) async throws {}
//  public func onUserNonChannelAcknowledge(
//    _ payload: Gateway.UserNonChannelAcknowledge
//  ) async throws {}
//  public func onMessageDeleteBulk(_: Gateway.MessageDeleteBulk) async throws {}
//  public func onMessageReactionAdd(_: Gateway.MessageReactionAdd) async throws {
//  }
//  public func onMessageReactionRemove(_: Gateway.MessageReactionRemove)
//    async throws
//  {}
//  public func onMessageReactionRemoveAll(_: Gateway.MessageReactionRemoveAll)
//    async throws
//  {}
//  public func onMessageReactionRemoveEmoji(
//    _: Gateway.MessageReactionRemoveEmoji
//  ) async throws {}
//  public func onPresenceUpdate(_: Gateway.PresenceUpdate) async throws {}
//  public func onRequestPresenceUpdate(_: Gateway.Identify.Presence) async throws
//  {}
//  public func onStageInstanceCreate(_: StageInstance) async throws {}
//  public func onStageInstanceDelete(_: StageInstance) async throws {}
//  public func onStageInstanceUpdate(_: StageInstance) async throws {}
//  public func onTypingStart(_: Gateway.TypingStart) async throws {}
//  public func onUserUpdate(_: DiscordUser) async throws {}
//  public func onVoiceStateUpdate(_: VoiceState) async throws {}
//  public func onRequestVoiceStateUpdate(_: VoiceStateUpdate) async throws {}
//  public func onVoiceServerUpdate(_: Gateway.VoiceServerUpdate) async throws {}
//  public func onWebhooksUpdate(_: Gateway.WebhooksUpdate) async throws {}
//  public func onApplicationCommandPermissionsUpdate(
//    _: GuildApplicationCommandPermissions
//  ) async throws {}
//  public func onAutoModerationRuleCreate(_: AutoModerationRule) async throws {}
//  public func onAutoModerationRuleUpdate(_: AutoModerationRule) async throws {}
//  public func onAutoModerationRuleDelete(_: AutoModerationRule) async throws {}
//  public func onAutoModerationActionExecution(_: AutoModerationActionExecution)
//    async throws
//  {}
//  public func onMessagePollVoteAdd(_: Gateway.MessagePollVote) async throws {}
//  public func onMessagePollVoteRemove(_: Gateway.MessagePollVote) async throws {
//  }
//  public func onReadySupplemental(_ payload: Gateway.ReadySupplemental)
//    async throws
//  {}
//  public func onAuthSessionChange(_ payload: Gateway.AuthSessionChange)
//    async throws
//  {}
//  public func onVoiceChannelStatuses(_ payload: Gateway.VoiceChannelStatuses)
//    async throws
//  {}
//  public func onConversationSummaryUpdate(
//    _ payload: Gateway.ConversationSummaryUpdate
//  ) async throws {}
//  public func onChannelRecipientAdd(_ payload: Gateway.ChannelRecipientAdd)
//    async throws
//  {}
//  public func onChannelRecipientRemove(
//    _ payload: Gateway.ChannelRecipientRemove
//  ) async throws {}
//  public func onConsoleCommandUpdate(_ payload: Gateway.ConsoleCommandUpdate)
//    async throws
//  {}
//  public func onDMSettingsShow(_ payload: Gateway.DMSettingsShow) async throws {
//  }
//  public func onFriendSuggestionCreate(
//    _ payload: Gateway.FriendSuggestionCreate
//  ) async throws {}
//  public func onFriendSuggestionDelete(
//    _ payload: Gateway.FriendSuggestionDelete
//  ) async throws {}
//  public func onGuildApplicationCommandIndexUpdate(
//    _ payload: Gateway.GuildApplicationCommandIndexUpdate
//  ) async throws {}
//  public func onGuildAppliedBoostsUpdate(
//    _ payload: Guild.PremiumGuildSubscription
//  ) async throws {}
//  public func onGuildScheduledEventExceptionCreate(
//    _ payload: GuildScheduledEventException
//  ) async throws {}
//  public func onGuildScheduledEventExceptionUpdate(
//    _ payload: GuildScheduledEventException
//  ) async throws {}
//  public func onGuildScheduledEventExceptionDelete(
//    _ payload: GuildScheduledEventException
//  ) async throws {}
//  public func onGuildScheduledEventExceptionsDelete(
//    _ payload: Gateway.GuildScheduledEventExceptionsDelete
//  ) async throws {}
//  public func onInteractionFailure(_ payload: Gateway.InteractionFailure)
//    async throws
//  {}
//  public func onInteractionSuccess(_ payload: Gateway.InteractionSuccess)
//    async throws
//  {}
//  public func onApplicationCommandAutocompleteResponse(
//    _ payload: Gateway.ApplicationCommandAutocomplete
//  ) async throws {}
//  public func onInteractionModalCreate(
//    _ payload: Gateway.InteractionModalCreate
//  ) async throws {}
//  public func onInteractionIFrameModalCreate(
//    _ payload: Gateway.InteractionIFrameModalCreate
//  ) async throws {}
//  public func onMessageReactionAddMany(
//    _ payload: Gateway.MessageReactionAddMany
//  ) async throws {}
//  public func onRecentMentionDelete(_ payload: Gateway.RecentMentionDelete)
//    async throws
//  {}
//  public func onRequestLastMessages(_ payload: Gateway.RequestLastMessages)
//    async throws
//  {}
//  public func onLastMessages(_ payload: Gateway.LastMessages) async throws {}
//  public func onNotificationSettingsUpdate(
//    _ payload: Gateway.NotificationSettings
//  ) async throws {}
//  public func onRelationshipAdd(_ payload: DiscordRelationship) async throws {}
//  public func onRelationshipUpdate(_ payload: Gateway.PartialRelationship)
//    async throws
//  {}
//  public func onRelationshipRemove(_ payload: Gateway.PartialRelationship)
//    async throws
//  {}
//  public func onSavedMessageCreate(_ payload: Gateway.SavedMessageCreate)
//    async throws
//  {}
//  public func onSavedMessageDelete(_ payload: Gateway.SavedMessageDelete)
//    async throws
//  {}
//  public func onChannelMemberCountUpdate(
//    _ payload: Gateway.ChannelMemberCountUpdate
//  ) async throws {}
//  public func onRequestChannelMemberCount(
//    _ payload: Gateway.RequestChannelMemberCount
//  ) async throws {}
//  public func onAutoModerationMentionRaidDetection(
//    _ payload: AutoModerationMentionRaidDetection
//  ) async throws {}
//  public func onCallCreate(_ payload: Gateway.CallCreate) async throws {}
//  public func onCallUpdate(_ payload: Gateway.CallUpdate) async throws {}
//  public func onCallDelete(_ payload: Gateway.CallDelete) async throws {}
//  public func onVoiceChannelStatusUpdate(
//    _ payload: Gateway.VoiceChannelStatusUpdate
//  ) async throws {}
//  public func onSessionsReplace(_ payload: Gateway.SessionsReplace) async throws
//  {
//  }
//  public func onUserApplicationUpdate(_ payload: Gateway.UserApplicationUpdate)
//    async throws
//  {}
//  public func onUserApplicationRemove(_ payload: Gateway.UserApplicationRemove)
//    async throws
//  {}
//  public func onUserConnectionsUpdate(_ payload: Gateway.UserConnectionsUpdate)
//    async throws
//  {}
//  public func onUserGuildSettingsUpdate(_ payload: Guild.UserGuildSettings)
//    async throws
//  {}
//  public func onUserNoteUpdate(_ payload: Gateway.UserNote) async throws {}
//  public func onUserSettingsUpdate(_ payload: Gateway.UserSettingsProtoUpdate)
//    async throws
//  {}
//  public func onGuildSoundboardSoundCreate(_ payload: SoundboardSound)
//    async throws
//  {}
//  public func onGuildSoundboardSoundUpdate(_ payload: SoundboardSound)
//    async throws
//  {}
//  public func onGuildSoundboardSoundDelete(
//    _ payload: Gateway.SoundboardSoundDelete
//  ) async throws {}
//  public func onSoundboardSounds(_ payload: Gateway.SoundboardSounds)
//    async throws
//  {}
//  public func onGuildMemberListUpdate(_ payload: Gateway.GuildMemberListUpdate)
//    async throws
//  {}
//}
//
//// MARK: - Handle
//extension GatewayEventHandler {
//  @inlinable
//  public func handleAsync() async {
//    do {
//      guard try await self.onEventHandlerStart() else { return }
//    } catch {
//      logError(function: "onEventHandlerStart", error: error)
//      return
//    }
//
//    switch event.data {
//    case .none, .resume, .identify, .updateGuildSubscriptions, .qosHeartbeat,
//      .heartbeat,
//      .updateTimeSpentSessionId:
//      /// Only sent, never received.
//      break
//    case .hello(let hello):
//      await withLogging(for: "onHello") {
//        try await onHello(hello)
//      }
//    case .ready(let ready):
//      await withLogging(for: "onReady") {
//        try await onReady(ready)
//      }
//    case .resumed:
//      await withLogging(for: "onResumed") {
//        try await onResumed()
//      }
//    case .invalidSession(let canResume):
//      await withLogging(for: "onInvalidSession") {
//        try await onInvalidSession(canResume: canResume)
//      }
//    case .channelCreate(let payload):
//      await withLogging(for: "onChannelCreate") {
//        try await onChannelCreate(payload)
//      }
//    case .channelUpdate(let payload):
//      await withLogging(for: "onChannelUpdate") {
//        try await onChannelUpdate(payload)
//      }
//    case .channelDelete(let payload):
//      await withLogging(for: "onChannelDelete") {
//        try await onChannelDelete(payload)
//      }
//    case .channelPinsUpdate(let payload):
//      await withLogging(for: "onChannelPinsUpdate") {
//        try await onChannelPinsUpdate(payload)
//      }
//    case .threadCreate(let payload):
//      await withLogging(for: "onThreadCreate") {
//        try await onThreadCreate(payload)
//      }
//    case .threadUpdate(let payload):
//      await withLogging(for: "onThreadUpdate") {
//        try await onThreadUpdate(payload)
//      }
//    case .threadDelete(let payload):
//      await withLogging(for: "onThreadDelete") {
//        try await onThreadDelete(payload)
//      }
//    case .threadSyncList(let payload):
//      await withLogging(for: "onThreadSyncList") {
//        try await onThreadSyncList(payload)
//      }
//    case .threadMemberUpdate(let payload):
//      await withLogging(for: "onThreadMemberUpdate") {
//        try await onThreadMemberUpdate(payload)
//      }
//    case .entitlementCreate(let payload):
//      await withLogging(for: "onEntitlementCreate") {
//        try await onEntitlementCreate(payload)
//      }
//    case .entitlementUpdate(let payload):
//      await withLogging(for: "onEntitlementUpdate") {
//        try await onEntitlementUpdate(payload)
//      }
//    case .entitlementDelete(let payload):
//      await withLogging(for: "onEntitlementDelete") {
//        try await onEntitlementDelete(payload)
//      }
//    case .threadMembersUpdate(let payload):
//      await withLogging(for: "onThreadMembersUpdate") {
//        try await onThreadMembersUpdate(payload)
//      }
//    case .guildCreate(let payload):
//      await withLogging(for: "onGuildCreate") {
//        try await onGuildCreate(payload)
//      }
//    case .guildUpdate(let payload):
//      await withLogging(for: "onGuildUpdate") {
//        try await onGuildUpdate(payload)
//      }
//    case .guildDelete(let payload):
//      await withLogging(for: "onGuildDelete") {
//        try await onGuildDelete(payload)
//      }
//    case .guildBanAdd(let payload):
//      await withLogging(for: "onGuildBanAdd") {
//        try await onGuildBanAdd(payload)
//      }
//    case .guildBanRemove(let payload):
//      await withLogging(for: "onGuildBanRemove") {
//        try await onGuildBanRemove(payload)
//      }
//    case .guildEmojisUpdate(let payload):
//      await withLogging(for: "onGuildEmojisUpdate") {
//        try await onGuildEmojisUpdate(payload)
//      }
//    case .guildStickersUpdate(let payload):
//      await withLogging(for: "onGuildStickersUpdate") {
//        try await onGuildStickersUpdate(payload)
//      }
//    case .guildIntegrationsUpdate(let payload):
//      await withLogging(for: "onGuildIntegrationsUpdate") {
//        try await onGuildIntegrationsUpdate(payload)
//      }
//    case .guildMemberAdd(let payload):
//      await withLogging(for: "onGuildMemberAdd") {
//        try await onGuildMemberAdd(payload)
//      }
//    case .guildMemberRemove(let payload):
//      await withLogging(for: "onGuildMemberRemove") {
//        try await onGuildMemberRemove(payload)
//      }
//    case .guildMemberUpdate(let payload):
//      await withLogging(for: "onGuildMemberUpdate") {
//        try await onGuildMemberUpdate(payload)
//      }
//    case .guildMembersChunk(let payload):
//      await withLogging(for: "onGuildMembersChunk") {
//        try await onGuildMembersChunk(payload)
//      }
//    case .requestGuildMembers(let payload):
//      await withLogging(for: "onRequestGuildMembers") {
//        try await onRequestGuildMembers(payload)
//      }
//    case .guildRoleCreate(let payload):
//      await withLogging(for: "onGuildRoleCreate") {
//        try await onGuildRoleCreate(payload)
//      }
//    case .guildRoleUpdate(let payload):
//      await withLogging(for: "onGuildRoleUpdate") {
//        try await onGuildRoleUpdate(payload)
//      }
//    case .guildRoleDelete(let payload):
//      await withLogging(for: "onGuildRoleDelete") {
//        try await onGuildRoleDelete(payload)
//      }
//    case .guildScheduledEventCreate(let payload):
//      await withLogging(for: "onGuildScheduledEventCreate") {
//        try await onGuildScheduledEventCreate(payload)
//      }
//    case .guildScheduledEventUpdate(let payload):
//      await withLogging(for: "onGuildScheduledEventUpdate") {
//        try await onGuildScheduledEventUpdate(payload)
//      }
//    case .guildScheduledEventDelete(let payload):
//      await withLogging(for: "onGuildScheduledEventDelete") {
//        try await onGuildScheduledEventDelete(payload)
//      }
//    case .guildScheduledEventUserAdd(let payload):
//      await withLogging(for: "onGuildScheduledEventUserAdd") {
//        try await onGuildScheduledEventUserAdd(payload)
//      }
//    case .guildScheduledEventUserRemove(let payload):
//      await withLogging(for: "onGuildScheduledEventUserRemove") {
//        try await onGuildScheduledEventUserRemove(payload)
//      }
//    case .guildAuditLogEntryCreate(let payload):
//      await withLogging(for: "onGuildAuditLogEntryCreate") {
//        try await onGuildAuditLogEntryCreate(payload)
//      }
//    case .integrationCreate(let payload):
//      await withLogging(for: "onIntegrationCreate") {
//        try await onIntegrationCreate(payload)
//      }
//    case .integrationUpdate(let payload):
//      await withLogging(for: "onIntegrationUpdate") {
//        try await onIntegrationUpdate(payload)
//      }
//    case .integrationDelete(let payload):
//      await withLogging(for: "onIntegrationDelete") {
//        try await onIntegrationDelete(payload)
//      }
//    case .interactionCreate(let payload):
//      await withLogging(for: "onInteractionCreate") {
//        try await onInteractionCreate(payload)
//      }
//    case .inviteCreate(let payload):
//      await withLogging(for: "onInviteCreate") {
//        try await onInviteCreate(payload)
//      }
//    case .inviteDelete(let payload):
//      await withLogging(for: "onInviteDelete") {
//        try await onInviteDelete(payload)
//      }
//    case .messageCreate(let payload):
//      await withLogging(for: "onMessageCreate") {
//        try await onMessageCreate(payload)
//      }
//    case .messageUpdate(let payload):
//      await withLogging(for: "onMessageUpdate") {
//        try await onMessageUpdate(payload)
//      }
//    case .messageDelete(let payload):
//      await withLogging(for: "onMessageDelete") {
//        try await onMessageDelete(payload)
//      }
//    case .messageAcknowledge(let payload):
//      await withLogging(for: "onMessageAcknowledge") {
//        try await onMessageAcknowledge(payload)
//      }
//    case .channelPinsAcknowledge(let payload):
//      await withLogging(for: "onChannelPinsAcknowledge") {
//        try await onChannelPinsAcknowledge(payload)
//      }
//    case .userNonChannelAcknowledge(let payload):
//      await withLogging(for: "onUserNonChannelAcknowledge") {
//        try await onUserNonChannelAcknowledge(payload)
//      }
//    case .messageDeleteBulk(let payload):
//      await withLogging(for: "onMessageDeleteBulk") {
//        try await onMessageDeleteBulk(payload)
//      }
//    case .messageReactionAdd(let payload):
//      await withLogging(for: "onMessageReactionAdd") {
//        try await onMessageReactionAdd(payload)
//      }
//    case .messageReactionRemove(let payload):
//      await withLogging(for: "onMessageReactionRemove") {
//        try await onMessageReactionRemove(payload)
//      }
//    case .messageReactionRemoveAll(let payload):
//      await withLogging(for: "onMessageReactionRemoveAll") {
//        try await onMessageReactionRemoveAll(payload)
//      }
//    case .messageReactionRemoveEmoji(let payload):
//      await withLogging(for: "onMessageReactionRemoveEmoji") {
//        try await onMessageReactionRemoveEmoji(payload)
//      }
//    case .presenceUpdate(let payload):
//      await withLogging(for: "onPresenceUpdate") {
//        try await onPresenceUpdate(payload)
//      }
//    case .requestPresenceUpdate(let payload):
//      await withLogging(for: "onRequestPresenceUpdate") {
//        try await onRequestPresenceUpdate(payload)
//      }
//    case .stageInstanceCreate(let payload):
//      await withLogging(for: "onStageInstanceCreate") {
//        try await onStageInstanceCreate(payload)
//      }
//    case .stageInstanceDelete(let payload):
//      await withLogging(for: "onStageInstanceDelete") {
//        try await onStageInstanceDelete(payload)
//      }
//    case .stageInstanceUpdate(let payload):
//      await withLogging(for: "onStageInstanceUpdate") {
//        try await onStageInstanceUpdate(payload)
//      }
//    case .typingStart(let payload):
//      await withLogging(for: "onTypingStart") {
//        try await onTypingStart(payload)
//      }
//    case .userUpdate(let payload):
//      await withLogging(for: "onUserUpdate") {
//        try await onUserUpdate(payload)
//      }
//    case .voiceStateUpdate(let payload):
//      await withLogging(for: "onVoiceStateUpdate") {
//        try await onVoiceStateUpdate(payload)
//      }
//    case .requestVoiceStateUpdate(let payload):
//      await withLogging(for: "onRequestVoiceStateUpdate") {
//        try await onRequestVoiceStateUpdate(payload)
//      }
//    case .voiceServerUpdate(let payload):
//      await withLogging(for: "onVoiceServerUpdate") {
//        try await onVoiceServerUpdate(payload)
//      }
//    case .webhooksUpdate(let payload):
//      await withLogging(for: "onWebhooksUpdate") {
//        try await onWebhooksUpdate(payload)
//      }
//    case .applicationCommandPermissionsUpdate(let payload):
//      await withLogging(for: "onApplicationCommandPermissionsUpdate") {
//        try await onApplicationCommandPermissionsUpdate(payload)
//      }
//    case .autoModerationRuleCreate(let payload):
//      await withLogging(for: "onAutoModerationRuleCreate") {
//        try await onAutoModerationRuleCreate(payload)
//      }
//    case .autoModerationRuleUpdate(let payload):
//      await withLogging(for: "onAutoModerationRuleUpdate") {
//        try await onAutoModerationRuleUpdate(payload)
//      }
//    case .autoModerationRuleDelete(let payload):
//      await withLogging(for: "onAutoModerationRuleDelete") {
//        try await onAutoModerationRuleDelete(payload)
//      }
//    case .autoModerationActionExecution(let payload):
//      await withLogging(for: "onAutoModerationActionExecution") {
//        try await onAutoModerationActionExecution(payload)
//      }
//    case .messagePollVoteAdd(let payload):
//      await withLogging(for: "onMessagePollVoteAdd") {
//        try await onMessagePollVoteAdd(payload)
//      }
//    case .messagePollVoteRemove(let payload):
//      await withLogging(for: "onMessagePollVoteRemove") {
//        try await onMessagePollVoteRemove(payload)
//      }
//    case .readySupplemental(let payload):
//      await withLogging(for: "onReadySupplemental") {
//        try await onReadySupplemental(payload)
//      }
//    case .authSessionChange(let payload):
//      await withLogging(for: "onAuthSessionChange") {
//        try await onAuthSessionChange(payload)
//      }
//    case .voiceChannelStatuses(let payload):
//      await withLogging(for: "onVoiceChannelStatuses") {
//        try await onVoiceChannelStatuses(payload)
//      }
//    case .conversationSummaryUpdate(let payload):
//      await withLogging(for: "onConversationSummaryUpdate") {
//        try await onConversationSummaryUpdate(payload)
//      }
//    case .channelRecipientAdd(let payload):
//      await withLogging(for: "onChannelRecipientAdd") {
//        try await onChannelRecipientAdd(payload)
//      }
//    case .channelRecipientRemove(let payload):
//      await withLogging(for: "onChannelRecipientRemove") {
//        try await onChannelRecipientRemove(payload)
//      }
//    case .consoleCommandUpdate(let payload):
//      await withLogging(for: "onConsoleCommandUpdate") {
//        try await onConsoleCommandUpdate(payload)
//      }
//    case .dmSettingsShow(let payload):
//      await withLogging(for: "onDMSettingsShow") {
//        try await onDMSettingsShow(payload)
//      }
//    case .friendSuggestionCreate(let payload):
//      await withLogging(for: "onFriendSuggestionCreate") {
//        try await onFriendSuggestionCreate(payload)
//      }
//    case .friendSuggestionDelete(let payload):
//      await withLogging(for: "onFriendSuggestionDelete") {
//        try await onFriendSuggestionDelete(payload)
//      }
//    case .guildApplicationCommandIndexUpdate(let payload):
//      await withLogging(for: "onGuildApplicationCommandIndexUpdate") {
//        try await onGuildApplicationCommandIndexUpdate(payload)
//      }
//    case .guildAppliedBoostsUpdate(let payload):
//      await withLogging(for: "onGuildAppliedBoostsUpdate") {
//        try await onGuildAppliedBoostsUpdate(payload)
//      }
//    case .guildScheduledEventExceptionCreate(let payload):
//      await withLogging(for: "onGuildScheduledEventExceptionCreate") {
//        try await onGuildScheduledEventExceptionCreate(payload)
//      }
//    case .guildScheduledEventExceptionUpdate(let payload):
//      await withLogging(for: "onGuildScheduledEventExceptionUpdate") {
//        try await onGuildScheduledEventExceptionUpdate(payload)
//      }
//    case .guildScheduledEventExceptionDelete(let payload):
//      await withLogging(for: "onGuildScheduledEventExceptionDelete") {
//        try await onGuildScheduledEventExceptionDelete(payload)
//      }
//    case .guildScheduledEventExceptionsDelete(let payload):
//      await withLogging(for: "onGuildScheduledEventExceptionsDelete") {
//        try await onGuildScheduledEventExceptionsDelete(payload)
//      }
//    case .interactionFailure(let payload):
//      await withLogging(for: "onInteractionFailure") {
//        try await onInteractionFailure(payload)
//      }
//    case .interactionSuccess(let payload):
//      await withLogging(for: "onInteractionSuccess") {
//        try await onInteractionSuccess(payload)
//      }
//    case .applicationCommandAutocompleteResponse(let payload):
//      await withLogging(for: "onApplicationCommandAutocompleteResponse") {
//        try await onApplicationCommandAutocompleteResponse(payload)
//      }
//    case .interactionModalCreate(let payload):
//      await withLogging(for: "onInteractionModalCreate") {
//        try await onInteractionModalCreate(payload)
//      }
//    case .interactionIFrameModalCreate(let payload):
//      await withLogging(for: "onInteractionIFrameModalCreate") {
//        try await onInteractionIFrameModalCreate(payload)
//      }
//    case .messageReactionAddMany(let payload):
//      await withLogging(for: "onMessageReactionAddMany") {
//        try await onMessageReactionAddMany(payload)
//      }
//    case .recentMentionDelete(let payload):
//      await withLogging(for: "onRecentMentionDelete") {
//        try await onRecentMentionDelete(payload)
//      }
//    case .requestLastMessages(let payload):
//      await withLogging(for: "onRequestLastMessages") {
//        try await onRequestLastMessages(payload)
//      }
//    case .lastMessages(let payload):
//      await withLogging(for: "onLastMessages") {
//        try await onLastMessages(payload)
//      }
//    case .notificationSettingsUpdate(let payload):
//      await withLogging(for: "onNotificationSettingsUpdate") {
//        try await onNotificationSettingsUpdate(payload)
//      }
//    case .relationshipAdd(let payload):
//      await withLogging(for: "onRelationshipAdd") {
//        try await onRelationshipAdd(payload)
//      }
//    case .relationshipUpdate(let payload):
//      await withLogging(for: "onRelationshipUpdate") {
//        try await onRelationshipUpdate(payload)
//      }
//    case .relationshipRemove(let payload):
//      await withLogging(for: "onRelationshipRemove") {
//        try await onRelationshipRemove(payload)
//      }
//    case .savedMessageCreate(let payload):
//      await withLogging(for: "onSavedMessageCreate") {
//        try await onSavedMessageCreate(payload)
//      }
//    case .savedMessageDelete(let payload):
//      await withLogging(for: "onSavedMessageDelete") {
//        try await onSavedMessageDelete(payload)
//      }
//    case .channelMemberCountUpdate(let payload):
//      await withLogging(for: "onChannelMemberCountUpdate") {
//        try await onChannelMemberCountUpdate(payload)
//      }
//    case .requestChannelMemberCount(let payload):
//      await withLogging(for: "onRequestChannelMemberCount") {
//        try await onRequestChannelMemberCount(payload)
//      }
//    case .autoModerationMentionRaidDetection(let payload):
//      await withLogging(for: "onAutoModerationMentionRaidDetection") {
//        try await onAutoModerationMentionRaidDetection(payload)
//      }
//    case .callCreate(let payload):
//      await withLogging(for: "onCallCreate") {
//        try await onCallCreate(payload)
//      }
//    case .callUpdate(let payload):
//      await withLogging(for: "onCallUpdate") {
//        try await onCallUpdate(payload)
//      }
//    case .callDelete(let payload):
//      await withLogging(for: "onCallDelete") {
//        try await onCallDelete(payload)
//      }
//    case .voiceChannelStatusUpdate(let payload):
//      await withLogging(for: "onVoiceChannelStatusUpdate") {
//        try await onVoiceChannelStatusUpdate(payload)
//      }
//    case .sessionsReplace(let payload):
//      await withLogging(for: "onSessionsReplace") {
//        try await onSessionsReplace(payload)
//      }
//    case .userApplicationUpdate(let payload):
//      await withLogging(for: "onUserApplicationUpdate") {
//        try await onUserApplicationUpdate(payload)
//      }
//    case .userApplicationRemove(let payload):
//      await withLogging(for: "onUserApplicationRemove") {
//        try await onUserApplicationRemove(payload)
//      }
//    case .userConnectionsUpdate(let payload):
//      await withLogging(for: "onUserConnectionsUpdate") {
//        try await onUserConnectionsUpdate(payload)
//      }
//    case .userGuildSettingsUpdate(let payload):
//      await withLogging(for: "onUserGuildSettingsUpdate") {
//        try await onUserGuildSettingsUpdate(payload)
//      }
//    case .userNoteUpdate(let payload):
//      await withLogging(for: "onUserNoteUpdate") {
//        try await onUserNoteUpdate(payload)
//      }
//    case .userSettingsUpdate(let payload):
//      await withLogging(for: "onUserSettingsUpdate") {
//        try await onUserSettingsUpdate(payload)
//      }
//    case .guildSoundboardSoundCreate(let payload):
//      await withLogging(for: "onGuildSoundboardSoundCreate") {
//        try await onGuildSoundboardSoundCreate(payload)
//      }
//    case .guildSoundboardSoundUpdate(let payload):
//      await withLogging(for: "onGuildSoundboardSoundUpdate") {
//        try await onGuildSoundboardSoundUpdate(payload)
//      }
//    case .guildSoundboardSoundDelete(let payload):
//      await withLogging(for: "onGuildSoundboardSoundDelete") {
//        try await onGuildSoundboardSoundDelete(payload)
//      }
//    case .soundboardSounds(let payload):
//      await withLogging(for: "onSoundboardSounds") {
//        try await onSoundboardSounds(payload)
//      }
//    case .channelUnreadUpdate(let payload):
//      await withLogging(for: "onChannelUnreadUpdate") {
//        try await onChannelUnreadUpdate(payload)
//      }
//    case .guildMemberListUpdate(let payload):
//      await withLogging(for: "guildMemberListUpdate") {
//        try await onGuildMemberListUpdate(payload)
//      }
//    case .__undocumented: break
//    }
//
//    await withLogging(for: "onEventHandlerEnd") {
//      try await onEventHandlerEnd()
//    }
//  }
//
//  @usableFromInline
//  func withLogging(for function: String, block: () async throws -> Void) async {
//    do {
//      try await block()
//    } catch {
//      logError(function: function, error: error)
//    }
//  }
//
//  @usableFromInline
//  func logError(function: String, error: any Error) {
//    logger.error(
//      "\(Self.self) produced an error",
//      metadata: [
//        "event-handler-func": .string(function),
//        "error": .string(String(reflecting: error)),
//      ]
//    )
//  }
//}

// this has no use in paicord.
