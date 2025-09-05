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
public protocol GatewayEventHandler: Sendable {
    var event: Gateway.Event { get }
    var logger: Logger { get }

    /// To be executed before handling events.
    /// If returns `false`, the event won't be passed to the functions below anymore.
    func onEventHandlerStart() async throws -> Bool
    func onEventHandlerEnd() async throws

    /// MARK: State-management data
    func onHeartbeat(lastSequenceNumber: Int?) async throws
    func onHello(_ payload: Gateway.Hello) async throws
    func onReady(_ payload: Gateway.Ready) async throws
    func onResumed() async throws
    func onInvalidSession(canResume: Bool) async throws

    /// MARK: Events
    func onChannelCreate(_ payload: DiscordChannel) async throws
    func onChannelUpdate(_ payload: DiscordChannel) async throws
    func onChannelDelete(_ payload: DiscordChannel) async throws
    func onChannelPinsUpdate(_ payload: Gateway.ChannelPinsUpdate) async throws
    func onThreadCreate(_ payload: DiscordChannel) async throws
    func onThreadUpdate(_ payload: DiscordChannel) async throws
    func onThreadDelete(_ payload: Gateway.ThreadDelete) async throws
    func onThreadSyncList(_ payload: Gateway.ThreadListSync) async throws
    func onThreadMemberUpdate(_ payload: Gateway.ThreadMemberUpdate) async throws
    func onThreadMembersUpdate(_ payload: Gateway.ThreadMembersUpdate) async throws
    func onEntitlementCreate(_ payload: Entitlement) async throws
    func onEntitlementUpdate(_ payload: Entitlement) async throws
    func onEntitlementDelete(_ payload: Entitlement) async throws
    func onGuildCreate(_ payload: Gateway.GuildCreate) async throws
    func onGuildUpdate(_ payload: Guild) async throws
    func onGuildDelete(_ payload: UnavailableGuild) async throws
    func onGuildBanAdd(_ payload: Gateway.GuildBan) async throws
    func onGuildBanRemove(_ payload: Gateway.GuildBan) async throws
    func onGuildEmojisUpdate(_ payload: Gateway.GuildEmojisUpdate) async throws
    func onGuildStickersUpdate(_ payload: Gateway.GuildStickersUpdate) async throws
    func onGuildIntegrationsUpdate(_ payload: Gateway.GuildIntegrationsUpdate) async throws
    func onGuildMemberAdd(_ payload: Gateway.GuildMemberAdd) async throws
    func onGuildMemberRemove(_ payload: Gateway.GuildMemberRemove) async throws
    func onGuildMemberUpdate(_ payload: Gateway.GuildMemberAdd) async throws
    func onGuildMembersChunk(_ payload: Gateway.GuildMembersChunk) async throws
    func onRequestGuildMembers(_ payload: Gateway.RequestGuildMembers) async throws
    func onGuildRoleCreate(_ payload: Gateway.GuildRole) async throws
    func onGuildRoleUpdate(_ payload: Gateway.GuildRole) async throws
    func onGuildRoleDelete(_ payload: Gateway.GuildRoleDelete) async throws
    func onGuildScheduledEventCreate(_ payload: GuildScheduledEvent) async throws
    func onGuildScheduledEventUpdate(_ payload: GuildScheduledEvent) async throws
    func onGuildScheduledEventDelete(_ payload: GuildScheduledEvent) async throws
    func onGuildScheduledEventUserAdd(_ payload: Gateway.GuildScheduledEventUser) async throws
    func onGuildScheduledEventUserRemove(_ payload: Gateway.GuildScheduledEventUser) async throws
    func onGuildAuditLogEntryCreate(_ payload: AuditLog.Entry) async throws
    func onIntegrationCreate(_ payload: Gateway.IntegrationCreate) async throws
    func onIntegrationUpdate(_ payload: Gateway.IntegrationCreate) async throws
    func onIntegrationDelete(_ payload: Gateway.IntegrationDelete) async throws
    func onInteractionCreate(_ payload: Interaction) async throws
    func onInviteCreate(_ payload: Gateway.InviteCreate) async throws
    func onInviteDelete(_ payload: Gateway.InviteDelete) async throws
    func onMessageCreate(_ payload: Gateway.MessageCreate) async throws
    func onMessageUpdate(_ payload: DiscordChannel.PartialMessage) async throws
    func onMessageDelete(_ payload: Gateway.MessageDelete) async throws
    func onMessageDeleteBulk(_ payload: Gateway.MessageDeleteBulk) async throws
    func onMessageReactionAdd(_ payload: Gateway.MessageReactionAdd) async throws
    func onMessageReactionRemove(_ payload: Gateway.MessageReactionRemove) async throws
    func onMessageReactionRemoveAll(_ payload: Gateway.MessageReactionRemoveAll) async throws
    func onMessageReactionRemoveEmoji(_ payload: Gateway.MessageReactionRemoveEmoji) async throws
    func onPresenceUpdate(_ payload: Gateway.PresenceUpdate) async throws
    func onRequestPresenceUpdate(_ payload: Gateway.Identify.Presence) async throws
    func onStageInstanceCreate(_ payload: StageInstance) async throws
    func onStageInstanceDelete(_ payload: StageInstance) async throws
    func onStageInstanceUpdate(_ payload: StageInstance) async throws
    func onTypingStart(_ payload: Gateway.TypingStart) async throws
    func onUserUpdate(_ payload: DiscordUser) async throws
    func onVoiceStateUpdate(_ payload: VoiceState) async throws
    func onRequestVoiceStateUpdate(_ payload: VoiceStateUpdate) async throws
    func onVoiceServerUpdate(_ payload: Gateway.VoiceServerUpdate) async throws
    func onWebhooksUpdate(_ payload: Gateway.WebhooksUpdate) async throws
    func onApplicationCommandPermissionsUpdate(_ payload: GuildApplicationCommandPermissions) async throws
    func onAutoModerationRuleCreate(_ payload: AutoModerationRule) async throws
    func onAutoModerationRuleUpdate(_ payload: AutoModerationRule) async throws
    func onAutoModerationRuleDelete(_ payload: AutoModerationRule) async throws
    func onAutoModerationActionExecution(_ payload: AutoModerationActionExecution) async throws
    func onMessagePollVoteAdd(_ payload: Gateway.MessagePollVote) async throws
    func onMessagePollVoteRemove(_ payload: Gateway.MessagePollVote) async throws
}

extension GatewayEventHandler {

    public var logger: Logger {
        Logger(label: "GatewayEventHandler")
    }

    @inlinable
    public func handle() {
        Task {
            await self.handleAsync()
        }
    }

    // MARK: - Default Do-Nothings

    @inlinable
    public func onEventHandlerStart() async throws -> Bool { true }
    public func onEventHandlerEnd() async throws {}

    public func onHeartbeat(lastSequenceNumber _: Int?) async throws {}
    public func onHello(_: Gateway.Hello) async throws {}
    public func onReady(_: Gateway.Ready) async throws {}
    public func onResumed() async throws {}
    public func onInvalidSession(canResume _: Bool) async throws {}
    public func onChannelCreate(_: DiscordChannel) async throws {}
    public func onChannelUpdate(_: DiscordChannel) async throws {}
    public func onChannelDelete(_: DiscordChannel) async throws {}
    public func onChannelPinsUpdate(_: Gateway.ChannelPinsUpdate) async throws {}
    public func onThreadCreate(_: DiscordChannel) async throws {}
    public func onThreadUpdate(_: DiscordChannel) async throws {}
    public func onThreadDelete(_: Gateway.ThreadDelete) async throws {}
    public func onThreadSyncList(_: Gateway.ThreadListSync) async throws {}
    public func onThreadMemberUpdate(_: Gateway.ThreadMemberUpdate) async throws {}
    public func onEntitlementCreate(_: Entitlement) async throws {}
    public func onEntitlementUpdate(_: Entitlement) async throws {}
    public func onEntitlementDelete(_: Entitlement) async throws {}
    public func onThreadMembersUpdate(_: Gateway.ThreadMembersUpdate) async throws {}
    public func onGuildCreate(_: Gateway.GuildCreate) async throws {}
    public func onGuildUpdate(_: Guild) async throws {}
    public func onGuildDelete(_: UnavailableGuild) async throws {}
    public func onGuildBanAdd(_: Gateway.GuildBan) async throws {}
    public func onGuildBanRemove(_: Gateway.GuildBan) async throws {}
    public func onGuildEmojisUpdate(_: Gateway.GuildEmojisUpdate) async throws {}
    public func onGuildStickersUpdate(_: Gateway.GuildStickersUpdate) async throws {}
    public func onGuildIntegrationsUpdate(_: Gateway.GuildIntegrationsUpdate) async throws {}
    public func onGuildMemberAdd(_: Gateway.GuildMemberAdd) async throws {}
    public func onGuildMemberRemove(_: Gateway.GuildMemberRemove) async throws {}
    public func onGuildMemberUpdate(_: Gateway.GuildMemberAdd) async throws {}
    public func onGuildMembersChunk(_: Gateway.GuildMembersChunk) async throws {}
    public func onRequestGuildMembers(_: Gateway.RequestGuildMembers) async throws {}
    public func onGuildRoleCreate(_: Gateway.GuildRole) async throws {}
    public func onGuildRoleUpdate(_: Gateway.GuildRole) async throws {}
    public func onGuildRoleDelete(_: Gateway.GuildRoleDelete) async throws {}
    public func onGuildScheduledEventCreate(_: GuildScheduledEvent) async throws {}
    public func onGuildScheduledEventUpdate(_: GuildScheduledEvent) async throws {}
    public func onGuildScheduledEventDelete(_: GuildScheduledEvent) async throws {}
    public func onGuildScheduledEventUserAdd(_: Gateway.GuildScheduledEventUser) async throws {}
    public func onGuildScheduledEventUserRemove(_: Gateway.GuildScheduledEventUser) async throws {}
    public func onGuildAuditLogEntryCreate(_: AuditLog.Entry) async throws {}
    public func onIntegrationCreate(_: Gateway.IntegrationCreate) async throws {}
    public func onIntegrationUpdate(_: Gateway.IntegrationCreate) async throws {}
    public func onIntegrationDelete(_: Gateway.IntegrationDelete) async throws {}
    public func onInteractionCreate(_: Interaction) async throws {}
    public func onInviteCreate(_: Gateway.InviteCreate) async throws {}
    public func onInviteDelete(_: Gateway.InviteDelete) async throws {}
    public func onMessageCreate(_: Gateway.MessageCreate) async throws {}
    public func onMessageUpdate(_: DiscordChannel.PartialMessage) async throws {}
    public func onMessageDelete(_: Gateway.MessageDelete) async throws {}
    public func onMessageDeleteBulk(_: Gateway.MessageDeleteBulk) async throws {}
    public func onMessageReactionAdd(_: Gateway.MessageReactionAdd) async throws {}
    public func onMessageReactionRemove(_: Gateway.MessageReactionRemove) async throws {}
    public func onMessageReactionRemoveAll(_: Gateway.MessageReactionRemoveAll) async throws {}
    public func onMessageReactionRemoveEmoji(_: Gateway.MessageReactionRemoveEmoji) async throws {}
    public func onPresenceUpdate(_: Gateway.PresenceUpdate) async throws {}
    public func onRequestPresenceUpdate(_: Gateway.Identify.Presence) async throws {}
    public func onStageInstanceCreate(_: StageInstance) async throws {}
    public func onStageInstanceDelete(_: StageInstance) async throws {}
    public func onStageInstanceUpdate(_: StageInstance) async throws {}
    public func onTypingStart(_: Gateway.TypingStart) async throws {}
    public func onUserUpdate(_: DiscordUser) async throws {}
    public func onVoiceStateUpdate(_: VoiceState) async throws {}
    public func onRequestVoiceStateUpdate(_: VoiceStateUpdate) async throws {}
    public func onVoiceServerUpdate(_: Gateway.VoiceServerUpdate) async throws {}
    public func onWebhooksUpdate(_: Gateway.WebhooksUpdate) async throws {}
    public func onApplicationCommandPermissionsUpdate(_: GuildApplicationCommandPermissions) async throws {}
    public func onAutoModerationRuleCreate(_: AutoModerationRule) async throws {}
    public func onAutoModerationRuleUpdate(_: AutoModerationRule) async throws {}
    public func onAutoModerationRuleDelete(_: AutoModerationRule) async throws {}
    public func onAutoModerationActionExecution(_: AutoModerationActionExecution) async throws {}
    public func onMessagePollVoteAdd(_: Gateway.MessagePollVote) async throws {}
    public func onMessagePollVoteRemove(_: Gateway.MessagePollVote) async throws {}
}

// MARK: - Handle
extension GatewayEventHandler {
    @inlinable
    public func handleAsync() async {
        do {
            guard try await self.onEventHandlerStart() else { return }
        } catch {
            logError(function: "onEventHandlerStart", error: error)
            return
        }

        switch event.data {
        case .none, .resume, .identify:
            /// Only sent, never received.
            break
        case let .heartbeat(lastSequenceNumber):
            await withLogging(for: "onHeartbeat") {
                try await onHeartbeat(lastSequenceNumber: lastSequenceNumber)
            }
        case let .hello(hello):
            await withLogging(for: "onHello") {
                try await onHello(hello)
            }
        case let .ready(ready):
            await withLogging(for: "onReady") {
                try await onReady(ready)
            }
        case .resumed:
            await withLogging(for: "onResumed") {
                try await onResumed()
            }
        case let .invalidSession(canResume):
            await withLogging(for: "onInvalidSession") {
                try await onInvalidSession(canResume: canResume)
            }
        case let .channelCreate(payload):
            await withLogging(for: "onChannelCreate") {
                try await onChannelCreate(payload)
            }
        case let .channelUpdate(payload):
            await withLogging(for: "onChannelUpdate") {
                try await onChannelUpdate(payload)
            }
        case let .channelDelete(payload):
            await withLogging(for: "onChannelDelete") {
                try await onChannelDelete(payload)
            }
        case let .channelPinsUpdate(payload):
            await withLogging(for: "onChannelPinsUpdate") {
                try await onChannelPinsUpdate(payload)
            }
        case let .threadCreate(payload):
            await withLogging(for: "onThreadCreate") {
                try await onThreadCreate(payload)
            }
        case let .threadUpdate(payload):
            await withLogging(for: "onThreadUpdate") {
                try await onThreadUpdate(payload)
            }
        case let .threadDelete(payload):
            await withLogging(for: "onThreadDelete") {
                try await onThreadDelete(payload)
            }
        case let .threadSyncList(payload):
            await withLogging(for: "onThreadSyncList") {
                try await onThreadSyncList(payload)
            }
        case let .threadMemberUpdate(payload):
            await withLogging(for: "onThreadMemberUpdate") {
                try await onThreadMemberUpdate(payload)
            }
        case let .entitlementCreate(payload):
            await withLogging(for: "onEntitlementCreate") {
                try await onEntitlementCreate(payload)
            }
        case let .entitlementUpdate(payload):
            await withLogging(for: "onEntitlementUpdate") {
                try await onEntitlementUpdate(payload)
            }
        case let .entitlementDelete(payload):
            await withLogging(for: "onEntitlementDelete") {
                try await onEntitlementDelete(payload)
            }
        case let .threadMembersUpdate(payload):
            await withLogging(for: "onThreadMembersUpdate") {
                try await onThreadMembersUpdate(payload)
            }
        case let .guildCreate(payload):
            await withLogging(for: "onGuildCreate") {
                try await onGuildCreate(payload)
            }
        case let .guildUpdate(payload):
            await withLogging(for: "onGuildUpdate") {
                try await onGuildUpdate(payload)
            }
        case let .guildDelete(payload):
            await withLogging(for: "onGuildDelete") {
                try await onGuildDelete(payload)
            }
        case let .guildBanAdd(payload):
            await withLogging(for: "onGuildBanAdd") {
                try await onGuildBanAdd(payload)
            }
        case let .guildBanRemove(payload):
            await withLogging(for: "onGuildBanRemove") {
                try await onGuildBanRemove(payload)
            }
        case let .guildEmojisUpdate(payload):
            await withLogging(for: "onGuildEmojisUpdate") {
                try await onGuildEmojisUpdate(payload)
            }
        case let .guildStickersUpdate(payload):
            await withLogging(for: "onGuildStickersUpdate") {
                try await onGuildStickersUpdate(payload)
            }
        case let .guildIntegrationsUpdate(payload):
            await withLogging(for: "onGuildIntegrationsUpdate") {
                try await onGuildIntegrationsUpdate(payload)
            }
        case let .guildMemberAdd(payload):
            await withLogging(for: "onGuildMemberAdd") {
                try await onGuildMemberAdd(payload)
            }
        case let .guildMemberRemove(payload):
            await withLogging(for: "onGuildMemberRemove") {
                try await onGuildMemberRemove(payload)
            }
        case let .guildMemberUpdate(payload):
            await withLogging(for: "onGuildMemberUpdate") {
                try await onGuildMemberUpdate(payload)
            }
        case let .guildMembersChunk(payload):
            await withLogging(for: "onGuildMembersChunk") {
                try await onGuildMembersChunk(payload)
            }
        case let .requestGuildMembers(payload):
            await withLogging(for: "onRequestGuildMembers") {
                try await onRequestGuildMembers(payload)
            }
        case let .guildRoleCreate(payload):
            await withLogging(for: "onGuildRoleCreate") {
                try await onGuildRoleCreate(payload)
            }
        case let .guildRoleUpdate(payload):
            await withLogging(for: "onGuildRoleUpdate") {
                try await onGuildRoleUpdate(payload)
            }
        case let .guildRoleDelete(payload):
            await withLogging(for: "onGuildRoleDelete") {
                try await onGuildRoleDelete(payload)
            }
        case let .guildScheduledEventCreate(payload):
            await withLogging(for: "onGuildScheduledEventCreate") {
                try await onGuildScheduledEventCreate(payload)
            }
        case let .guildScheduledEventUpdate(payload):
            await withLogging(for: "onGuildScheduledEventUpdate") {
                try await onGuildScheduledEventUpdate(payload)
            }
        case let .guildScheduledEventDelete(payload):
            await withLogging(for: "onGuildScheduledEventDelete") {
                try await onGuildScheduledEventDelete(payload)
            }
        case let .guildScheduledEventUserAdd(payload):
            await withLogging(for: "onGuildScheduledEventUserAdd") {
                try await onGuildScheduledEventUserAdd(payload)
            }
        case let .guildScheduledEventUserRemove(payload):
            await withLogging(for: "onGuildScheduledEventUserRemove") {
                try await onGuildScheduledEventUserRemove(payload)
            }
        case let .guildAuditLogEntryCreate(payload):
            await withLogging(for: "onGuildAuditLogEntryCreate") {
                try await onGuildAuditLogEntryCreate(payload)
            }
        case let .integrationCreate(payload):
            await withLogging(for: "onIntegrationCreate") {
                try await onIntegrationCreate(payload)
            }
        case let .integrationUpdate(payload):
            await withLogging(for: "onIntegrationUpdate") {
                try await onIntegrationUpdate(payload)
            }
        case let .integrationDelete(payload):
            await withLogging(for: "onIntegrationDelete") {
                try await onIntegrationDelete(payload)
            }
        case let .interactionCreate(payload):
            await withLogging(for: "onInteractionCreate") {
                try await onInteractionCreate(payload)
            }
        case let .inviteCreate(payload):
            await withLogging(for: "onInviteCreate") {
                try await onInviteCreate(payload)
            }
        case let .inviteDelete(payload):
            await withLogging(for: "onInviteDelete") {
                try await onInviteDelete(payload)
            }
        case let .messageCreate(payload):
            await withLogging(for: "onMessageCreate") {
                try await onMessageCreate(payload)
            }
        case let .messageUpdate(payload):
            await withLogging(for: "onMessageUpdate") {
                try await onMessageUpdate(payload)
            }
        case let .messageDelete(payload):
            await withLogging(for: "onMessageDelete") {
                try await onMessageDelete(payload)
            }
        case let .messageDeleteBulk(payload):
            await withLogging(for: "onMessageDeleteBulk") {
                try await onMessageDeleteBulk(payload)
            }
        case let .messageReactionAdd(payload):
            await withLogging(for: "onMessageReactionAdd") {
                try await onMessageReactionAdd(payload)
            }
        case let .messageReactionRemove(payload):
            await withLogging(for: "onMessageReactionRemove") {
                try await onMessageReactionRemove(payload)
            }
        case let .messageReactionRemoveAll(payload):
            await withLogging(for: "onMessageReactionRemoveAll") {
                try await onMessageReactionRemoveAll(payload)
            }
        case let .messageReactionRemoveEmoji(payload):
            await withLogging(for: "onMessageReactionRemoveEmoji") {
                try await onMessageReactionRemoveEmoji(payload)
            }
        case let .presenceUpdate(payload):
            await withLogging(for: "onPresenceUpdate") {
                try await onPresenceUpdate(payload)
            }
        case let .requestPresenceUpdate(payload):
            await withLogging(for: "onRequestPresenceUpdate") {
                try await onRequestPresenceUpdate(payload)
            }
        case let .stageInstanceCreate(payload):
            await withLogging(for: "onStageInstanceCreate") {
                try await onStageInstanceCreate(payload)
            }
        case let .stageInstanceDelete(payload):
            await withLogging(for: "onStageInstanceDelete") {
                try await onStageInstanceDelete(payload)
            }
        case let .stageInstanceUpdate(payload):
            await withLogging(for: "onStageInstanceUpdate") {
                try await onStageInstanceUpdate(payload)
            }
        case let .typingStart(payload):
            await withLogging(for: "onTypingStart") {
                try await onTypingStart(payload)
            }
        case let .userUpdate(payload):
            await withLogging(for: "onUserUpdate") {
                try await onUserUpdate(payload)
            }
        case let .voiceStateUpdate(payload):
            await withLogging(for: "onVoiceStateUpdate") {
                try await onVoiceStateUpdate(payload)
            }
        case let .requestVoiceStateUpdate(payload):
            await withLogging(for: "onRequestVoiceStateUpdate") {
                try await onRequestVoiceStateUpdate(payload)
            }
        case let .voiceServerUpdate(payload):
            await withLogging(for: "onVoiceServerUpdate") {
                try await onVoiceServerUpdate(payload)
            }
        case let .webhooksUpdate(payload):
            await withLogging(for: "onWebhooksUpdate") {
                try await onWebhooksUpdate(payload)
            }
        case let .applicationCommandPermissionsUpdate(payload):
            await withLogging(for: "onApplicationCommandPermissionsUpdate") {
                try await onApplicationCommandPermissionsUpdate(payload)
            }
        case let .autoModerationRuleCreate(payload):
            await withLogging(for: "onAutoModerationRuleCreate") {
                try await onAutoModerationRuleCreate(payload)
            }
        case let .autoModerationRuleUpdate(payload):
            await withLogging(for: "onAutoModerationRuleUpdate") {
                try await onAutoModerationRuleUpdate(payload)
            }
        case let .autoModerationRuleDelete(payload):
            await withLogging(for: "onAutoModerationRuleDelete") {
                try await onAutoModerationRuleDelete(payload)
            }
        case let .autoModerationActionExecution(payload):
            await withLogging(for: "onAutoModerationActionExecution") {
                try await onAutoModerationActionExecution(payload)
            }
        case let .messagePollVoteAdd(payload):
            await withLogging(for: "onMessagePollVoteAdd") {
                try await onMessagePollVoteAdd(payload)
            }
        case let .messagePollVoteRemove(payload):
            await withLogging(for: "onMessagePollVoteRemove") {
                try await onMessagePollVoteRemove(payload)
            }
        case .__undocumented:
            break
        }

        await withLogging(for: "onEventHandlerEnd") {
            try await onEventHandlerEnd()
        }
    }

    @usableFromInline
    func withLogging(for function: String, block: () async throws -> Void) async {
        do {
            try await block()
        } catch {
            logError(function: function, error: error)
        }
    }

    @usableFromInline
    func logError(function: String, error: any Error) {
        logger.error(
            "\(Self.self) produced an error",
            metadata: [
                "event-handler-func": .string(function),
                "error": .string(String(reflecting: error)),
            ]
        )
    }
}
