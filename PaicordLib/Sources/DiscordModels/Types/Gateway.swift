import Foundation

public struct Gateway: Sendable, Codable {

	/// https://discord.com/developers/docs/topics/opcodes-and-status-codes#opcodes-and-status-codes
	public enum Opcode: UInt8, Sendable, Codable, CustomStringConvertible {
		// common
		case dispatch = 0
		case heartbeat = 1
		case identify = 2
		case presenceUpdate = 3
		case voiceStateUpdate = 4
		case resume = 6
		case reconnect = 7
		case requestGuildMembers = 8
		case invalidSession = 9
		case hello = 10
		case heartbeatAccepted = 11
		case requestSoundboardSounds = 31

		// user only gateway opcodes ?
		case voiceServerPing = 5
		case callConnect = 13
		case guildSubscriptions = 14
		case lobbyVoiceStates = 17
		case streamCreate = 18
		case streamDelete = 19
		case streamWatch = 20
		case streamPing = 21
		case streamSetPaused = 22
		case requestForumUnread = 28
		case remoteCommand = 29
		case requestDeletedEntityIds = 30
		case speedtestCreate = 32
		case speedtestDelete = 33
		case requestLastMessages = 34
		case searchRecentMembers = 35
		case requestChannelStatuses = 36
		case guildSubscriptionsBulk = 37
		case guildChannelsResync = 38
		case requestChannelMemberCounts = 39
		case qosHeartbeat = 40
		case updateTimeSpentSessionId = 41

		public var description: String {
			switch self {
			case .dispatch: return "dispatch"
			case .heartbeat: return "heartbeat"
			case .identify: return "identify"
			case .presenceUpdate: return "presenceUpdate"
			case .voiceStateUpdate: return "voiceStateUpdate"
			case .resume: return "resume"
			case .reconnect: return "reconnect"
			case .requestGuildMembers: return "requestGuildMembers"
			case .invalidSession: return "invalidSession"
			case .hello: return "hello"
			case .heartbeatAccepted: return "heartbeatAccepted"
			case .requestSoundboardSounds: return "requestSoundboardSounds"
			case .voiceServerPing: return "voiceServerPing"
			case .callConnect: return "callConnect"
			case .guildSubscriptions: return "guildSubscriptions"
			case .lobbyVoiceStates: return "lobbyVoiceStates"
			case .streamCreate: return "streamCreate"
			case .streamDelete: return "streamDelete"
			case .streamWatch: return "streamWatch"
			case .streamPing: return "streamPing"
			case .streamSetPaused: return "streamSetPaused"
			case .requestForumUnread: return "requestForumUnread"
			case .remoteCommand: return "remoteCommand"
			case .requestDeletedEntityIds: return "requestDeletedEntityIds"
			case .speedtestCreate: return "speedtestCreate"
			case .speedtestDelete: return "speedtestDelete"
			case .requestLastMessages: return "requestLastMessages"
			case .searchRecentMembers: return "searchRecentMembers"
			case .requestChannelStatuses: return "requestChannelStatuses"
			case .guildSubscriptionsBulk: return "guildSubscriptionsBulk"
			case .guildChannelsResync: return "guildChannelsResync"
			case .requestChannelMemberCounts: return "requestChannelMemberCounts"
			case .qosHeartbeat: return "qosHeartbeat"
			case .updateTimeSpentSessionId: return "updateTimeSpentSessionId"
			}
		}
	}

	/// The top-level gateway event.
	/// https://discord.com/developers/docs/topics/gateway#gateway-events
	public struct Event: Sendable, Codable {

		/// This enum is just for swiftly organizing Discord gateway event's `data`.
		/// You need to read each case's inner payload's documentation for more info.
		///
		/// `indirect` is used to mitigate this issue: https://github.com/swiftlang/swift/issues/74303
		indirect
			public enum Payload: Sendable
		{
			/// https://discord.com/developers/docs/topics/gateway-events#heartbeat
			case heartbeat(lastSequenceNumber: Int?)
			case identify(Identify)
			case hello(Hello)
			case ready(Ready)
			case readySupplemental(ReadySupplemental)  // TODO
			/// Is sent when we want to send a resume request
			case resume(Resume)
			/// Is received when Discord has ended replying our lost events, after a resume
			/// https://discord.com/developers/docs/topics/gateway-events#resumed
			case resumed
			/// https://discord.com/developers/docs/topics/gateway-events#invalid-session
			case invalidSession(canResume: Bool)
			case authSessionChange(AuthSessionChange)
			case sessionReplace(SessionReplace)

			//      case authenticatorCreate // TODO
			//      case authenticatorUpdate // TODO
			//      case authenticatorDelete // TODO

			case channelCreate(DiscordChannel)
			case channelUpdate(DiscordChannel)
			case channelDelete(DiscordChannel)

			case callCreate(CallCreate)
			case callUpdate(CallUpdate)
			case callDelete(CallDelete)

			case voiceChannelStatuses(VoiceChannelStatuses)
			case channelPinsUpdate(ChannelPinsUpdate)

			case conversationSummaryUpdate(ConversationSummaryUpdate)

			case channelRecipientAdd(ChannelRecipientAdd)
			case channelRecipientRemove(ChannelRecipientRemove)
				
			case channelUnreadUpdate(ChannelUnreadUpdate)

			case consoleCommandUpdate(ConsoleCommandUpdate)  // TODO

			case dmSettingsShow(DMSettingsShow)

			case threadCreate(DiscordChannel)
			case threadUpdate(DiscordChannel)
			case threadDelete(ThreadDelete)

			case threadSyncList(ThreadListSync)
			case threadMemberUpdate(ThreadMemberUpdate)
			case threadMembersUpdate(ThreadMembersUpdate)

			case entitlementCreate(Entitlement)
			case entitlementUpdate(Entitlement)
			case entitlementDelete(Entitlement)

			case friendSuggestionCreate(FriendSuggestionCreate)
			case friendSuggestionDelete(FriendSuggestionDelete)

			//			case giftCodeCreate // TODO
			//			case giftCodeUpdate // TODO

			case guildCreate(GuildCreate)
			case guildUpdate(Guild)
			case guildDelete(UnavailableGuild)

			case guildApplicationCommandIndexUpdate(
				GuildApplicationCommandIndexUpdate)
			case guildAppliedBoostsUpdate(Guild.PremiumGuildSubscription)
			case guildAuditLogEntryCreate(AuditLog.Entry)

			case guildBanAdd(GuildBan)
			case guildBanRemove(GuildBan)

			//			case guildDirectoryEntryCreate // TODO
			//			case guildDirectoryEntryUpdate // TODO
			//			case guildDirectoryEntryDelete // TODO

			//			case guildJoinRequestCreate // TODO
			//			case guildJoinRequestUpdate // TODO
			//			case guildJoinRequestDelete // TODO

			case guildMemberAdd(GuildMemberAdd)
			case guildMemberRemove(GuildMemberRemove)
			case guildMemberUpdate(GuildMemberAdd)

			case guildRoleCreate(GuildRole)
			case guildRoleUpdate(GuildRole)
			case guildRoleDelete(GuildRoleDelete)

			case guildMembersChunk(GuildMembersChunk)
			case requestGuildMembers(RequestGuildMembers)

			//			case guildPowerupEntitlementsCreate // TODO
			//			case guildPowerupEntitlementsDelete // TODO

			case guildEmojisUpdate(GuildEmojisUpdate)
			case guildStickersUpdate(GuildStickersUpdate)

			case guildScheduledEventCreate(GuildScheduledEvent)
			case guildScheduledEventUpdate(GuildScheduledEvent)
			case guildScheduledEventDelete(GuildScheduledEvent)

			case guildScheduledEventExceptionCreate(GuildScheduledEventException)
			case guildScheduledEventExceptionUpdate(GuildScheduledEventException)
			case guildScheduledEventExceptionDelete(GuildScheduledEventException)
			case guildScheduledEventExceptionsDelete(
				GuildScheduledEventExceptionsDelete)

			case guildScheduledEventUserAdd(GuildScheduledEventUser)
			case guildScheduledEventUserRemove(GuildScheduledEventUser)

			case guildSoundboardSoundCreate(SoundboardSound)
			case guildSoundboardSoundUpdate(SoundboardSound)
			case guildSoundboardSoundDelete(SoundboardSoundDelete)  // TODO

			case soundboardSounds(SoundboardSounds)

			case guildIntegrationsUpdate(GuildIntegrationsUpdate)

			case integrationCreate(IntegrationCreate)
			case integrationUpdate(IntegrationCreate)
			case integrationDelete(IntegrationDelete)

			//			case interactionCreate(Interaction) // bot gets full interaction object
			case interactionCreate(InteractionCreate)  // user gets limited object
			case interactionFailure(InteractionFailure)
			case interactionSuccess(InteractionSuccess)

			case applicationCommandAutocompleteResponse(
				ApplicationCommandAutocomplete)

			case interactionModalCreate(InteractionModalCreate)
			case interactionIFrameModalCreate(InteractionIFrameModalCreate)

			case inviteCreate(InviteCreate)
			case inviteDelete(InviteDelete)

			case messageCreate(MessageCreate)
			case messageUpdate(DiscordChannel.PartialMessage)
			case messageDelete(MessageDelete)
			case messageDeleteBulk(MessageDeleteBulk)

			case messagePollVoteAdd(MessagePollVote)
			case messagePollVoteRemove(MessagePollVote)

			case messageReactionAdd(MessageReactionAdd)
			case messageReactionAddMany(MessageReactionAddMany)
			case messageReactionRemove(MessageReactionRemove)
			case messageReactionRemoveAll(MessageReactionRemoveAll)
			case messageReactionRemoveEmoji(MessageReactionRemoveEmoji)

			case recentMentionDelete(RecentMentionDelete)
			case lastMessages(LastMessages)

			case notificationSettingsUpdate(NotificationSettings)

			//			case oauth2TokenRevoke // TODO

			case presenceUpdate(PresenceUpdate)
			case requestPresenceUpdate(Identify.Presence)

			//			case questsUserStatusUpdate // TODO
			//			case questsUserCompletionUpdate // TODO

			case relationshipAdd(DiscordRelationship)
			case relationshipUpdate(PartialRelationship)
			case relationshipRemove(PartialRelationship)

			//			case gameRelationshipAdd // TODO
			//			case gameRelationshipRemove // TODO

			case savedMessageCreate(SavedMessageCreate)
			case savedMessageDelete(SavedMessageDelete)

			case channelMemberCountUpdate(ChannelMemberCountUpdate)
			case requestChannelMemberCount(RequestChannelMemberCount)

			case autoModerationRuleCreate(AutoModerationRule)
			case autoModerationRuleUpdate(AutoModerationRule)
			case autoModerationRuleDelete(AutoModerationRule)

			case autoModerationActionExecution(AutoModerationActionExecution)
			case autoModerationMentionRaidDetection(
				AutoModerationMentionRaidDetection)

			case stageInstanceCreate(StageInstance)
			case stageInstanceDelete(StageInstance)
			case stageInstanceUpdate(StageInstance)

			//			case streamCreateStream() // TODO
			//			case streamServerUpdate() // TODO
			//			case streamUpdateStream() // TODO
			//			case streamDelete() // TODO

			//			case speedTestCreate() // TODO
			//			case speedTestServerUpdate() // TODO
			//			case speedTestUpdate() // TODO
			//			case speedTestDelete() // TODO

			case typingStart(TypingStart)

			case userUpdate(DiscordUser)

			case voiceStateUpdate(VoiceState)
			case requestVoiceStateUpdate(VoiceStateUpdate)
			case voiceChannelStatusUpdate(VoiceChannelStatusUpdate)
			case voiceServerUpdate(VoiceServerUpdate)
			//			case voiceChannelEffectSend() // TODO

			case webhooksUpdate(WebhooksUpdate)

			case applicationCommandPermissionsUpdate(
				GuildApplicationCommandPermissions
			)

			case userApplicationUpdate(UserApplicationUpdate)
			case userApplicationRemove(UserApplicationRemove)

			case userConnectionsUpdate(UserConnectionsUpdate)

			case userGuildSettingsUpdate(Guild.UserGuildSettings)

			case userNoteUpdate(UserNote)

			//			case userRequiredActionUpdate() // TODO
			case userSettingsUpdate(UserSettingsProtoUpdate)

			//				case audioSettingsUpdate() // TODO

			//			case userPremiumGuildSubscriptionSlotCreate() // TODO
			//			case userPremiumGuildSubscriptionSlotUpdate() // TODO
			//			case userPremiumGuildSubscriptionSlotDelete() // TODO

			case __undocumented

			// MARK: - End of payloads

			public var correspondingIntents: [Intent] {
				switch self {
				case .heartbeat, .identify, .hello, .ready, .resume, .resumed,
					.invalidSession, .requestGuildMembers,
					.requestPresenceUpdate, .requestVoiceStateUpdate, .interactionCreate,
					.entitlementCreate,
					.entitlementUpdate, .entitlementDelete,
					.applicationCommandPermissionsUpdate, .userUpdate,
					.voiceServerUpdate:
					return []
				case .guildCreate, .guildUpdate, .guildDelete, .guildMembersChunk,
					.guildRoleCreate, .guildRoleUpdate,
					.guildRoleDelete, .channelCreate, .channelUpdate, .channelDelete,
					.threadCreate, .threadUpdate,
					.threadDelete, .threadSyncList, .threadMemberUpdate,
					.stageInstanceCreate, .stageInstanceDelete,
					.stageInstanceUpdate:
					return [.guilds]
				case .channelPinsUpdate:
					return [.guilds, .directMessages]
				case .threadMembersUpdate, .guildMemberAdd, .guildMemberRemove,
					.guildMemberUpdate:
					return [.guilds, .guildMembers]
				case .guildAuditLogEntryCreate, .guildBanAdd, .guildBanRemove:
					return [.guildModeration]
				case .guildEmojisUpdate, .guildStickersUpdate:
					return [.guildEmojisAndStickers]
				case .guildIntegrationsUpdate, .integrationCreate, .integrationUpdate,
					.integrationDelete:
					return [.guildIntegrations]
				case .webhooksUpdate:
					return [.guildWebhooks]
				case .inviteCreate, .inviteDelete:
					return [.guildInvites]
				case .voiceStateUpdate:
					return [.guildVoiceStates]
				case .presenceUpdate:
					return [.guildPresences]
				case .messageCreate, .messageUpdate, .messageDelete:
					return [.guildMessages, .directMessages]
				case .messageDeleteBulk:
					return [.guildMessages]
				case .messageReactionAdd, .messageReactionRemove,
					.messageReactionRemoveAll,
					.messageReactionRemoveEmoji:
					return [.guildMessageReactions]
				case .typingStart:
					return [.guildMessageTyping]
				case .guildScheduledEventCreate, .guildScheduledEventUpdate,
					.guildScheduledEventDelete,
					.guildScheduledEventUserAdd, .guildScheduledEventUserRemove:
					return [.guildScheduledEvents]
				case .autoModerationRuleCreate, .autoModerationRuleUpdate,
					.autoModerationRuleDelete:
					return [.autoModerationConfiguration]
				case .autoModerationActionExecution:
					return [.autoModerationExecution]
				case .messagePollVoteAdd:
					return [.guildMessagePolls, .directMessagePolls]
				case .messagePollVoteRemove:
					return [.guildMessagePolls, .directMessagePolls]
				case .__undocumented:
					return []
				default: return []
				}
			}
		}

		public enum GatewayDecodingError: Error, CustomStringConvertible {
			/// The dispatch event type '\(type ?? "nil")' is unhandled. This is probably a new Discord event which is not yet officially documented. I actively look for new events, and check Discord docs, so there is nothing to worry about. The library will support this event when it should.
			case unhandledDispatchEvent(type: String?)

			public var description: String {
				switch self {
				case let .unhandledDispatchEvent(type):
					return
						"Gateway.Event.GatewayDecodingError.unhandledDispatchEvent(type: \(type ?? "nil"))"
				}
			}
		}

		enum CodingKeys: String, CodingKey {
			case opcode = "op"
			case data = "d"
			case sequenceNumber = "s"
			case type = "t"
		}

		public var opcode: Opcode
		public var data: Payload?
		public var sequenceNumber: Int?
		public var type: String?

		public init(
			opcode: Opcode,
			data: Payload? = nil,
			sequenceNumber: Int? = nil,
			type: String? = nil
		) {
			self.opcode = opcode
			self.data = data
			self.sequenceNumber = sequenceNumber
			self.type = type
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.opcode = try container.decode(Opcode.self, forKey: .opcode)
			self.sequenceNumber = try container.decodeIfPresent(
				Int.self,
				forKey: .sequenceNumber
			)
			self.type = try container.decodeIfPresent(String.self, forKey: .type)

			func decodeData<D: Decodable>(as type: D.Type = D.self) throws -> D {
				try container.decode(D.self, forKey: .data)
			}

			switch opcode {
			case .heartbeat, .heartbeatAccepted, .reconnect:
				guard try container.decodeNil(forKey: .data) else {
					throw DecodingError.typeMismatch(
						Optional<Never>.self,
						.init(
							codingPath: container.codingPath,
							debugDescription:
								"`\(opcode)` opcode is supposed to have no data."
						)
					)
				}
				self.data = nil
			case .identify, .presenceUpdate, .voiceStateUpdate, .resume,
				.requestGuildMembers, .requestSoundboardSounds, .voiceServerPing,
				.callConnect,
				.guildSubscriptions, .lobbyVoiceStates, .streamCreate, .streamDelete,
				.streamWatch, .streamPing, .streamSetPaused, .requestForumUnread,
				.remoteCommand, .requestDeletedEntityIds, .speedtestCreate,
				.speedtestDelete, .requestLastMessages, .searchRecentMembers,
				.requestChannelStatuses, .guildSubscriptionsBulk, .guildChannelsResync,
				.requestChannelMemberCounts, .qosHeartbeat, .updateTimeSpentSessionId:
				throw DecodingError.dataCorrupted(
					.init(
						codingPath: container.codingPath,
						debugDescription:
							"'\(opcode)' opcode is supposed to never be received."
					)
				)
			case .invalidSession:
				self.data = try .invalidSession(canResume: decodeData())
			case .hello:
				self.data = try .hello(decodeData())
			case .dispatch:
				switch self.type {
				case "READY":
					self.data = try .ready(decodeData())
				case "READY_SUPPLEMENTAL":
					self.data = try .readySupplemental(decodeData())
				case "RESUMED":
					self.data = .resumed
				case "CHANNEL_CREATE":
					self.data = try .channelCreate(decodeData())
				case "CHANNEL_UPDATE":
					self.data = try .channelUpdate(decodeData())
				case "CHANNEL_DELETE":
					self.data = try .channelDelete(decodeData())
				case "CHANNEL_PINS_UPDATE":
					self.data = try .channelPinsUpdate(decodeData())
				case "THREAD_CREATE":
					self.data = try .threadCreate(decodeData())
				case "THREAD_UPDATE":
					self.data = try .threadUpdate(decodeData())
				case "THREAD_DELETE":
					self.data = try .threadDelete(decodeData())
				case "THREAD_LIST_SYNC":
					self.data = try .threadSyncList(decodeData())
				case "THREAD_MEMBER_UPDATE":
					self.data = try .threadMemberUpdate(decodeData())
				case "THREAD_MEMBERS_UPDATE":
					self.data = try .threadMembersUpdate(decodeData())
				case "ENTITLEMENT_CREATE":
					self.data = try .entitlementCreate(decodeData())
				case "ENTITLEMENT_UPDATE":
					self.data = try .entitlementUpdate(decodeData())
				case "ENTITLEMENT_DELETE":
					self.data = try .entitlementDelete(decodeData())
				case "GUILD_CREATE":
					self.data = try .guildCreate(decodeData())
				case "GUILD_UPDATE":
					self.data = try .guildUpdate(decodeData())
				case "GUILD_DELETE":
					self.data = try .guildDelete(decodeData())
				case "GUILD_BAN_ADD":
					self.data = try .guildBanAdd(decodeData())
				case "GUILD_BAN_REMOVE":
					self.data = try .guildBanRemove(decodeData())
				case "GUILD_EMOJIS_UPDATE":
					self.data = try .guildEmojisUpdate(decodeData())
				case "GUILD_STICKERS_UPDATE":
					self.data = try .guildStickersUpdate(decodeData())
				case "GUILD_INTEGRATIONS_UPDATE":
					self.data = try .guildIntegrationsUpdate(decodeData())
				case "GUILD_MEMBER_ADD":
					self.data = try .guildMemberAdd(decodeData())
				case "GUILD_MEMBER_REMOVE":
					self.data = try .guildMemberRemove(decodeData())
				case "GUILD_MEMBER_UPDATE":
					self.data = try .guildMemberUpdate(decodeData())
				case "GUILD_MEMBERS_CHUNK":
					self.data = try .guildMembersChunk(decodeData())
				case "GUILD_ROLE_CREATE":
					self.data = try .guildRoleCreate(decodeData())
				case "GUILD_ROLE_UPDATE":
					self.data = try .guildRoleUpdate(decodeData())
				case "GUILD_ROLE_DELETE":
					self.data = try .guildRoleDelete(decodeData())
				case "GUILD_SCHEDULED_EVENT_CREATE":
					self.data = try .guildScheduledEventCreate(decodeData())
				case "GUILD_SCHEDULED_EVENT_UPDATE":
					self.data = try .guildScheduledEventUpdate(decodeData())
				case "GUILD_SCHEDULED_EVENT_DELETE":
					self.data = try .guildScheduledEventDelete(decodeData())
				case "GUILD_SCHEDULED_EVENT_USER_ADD":
					self.data = try .guildScheduledEventUserAdd(decodeData())
				case "GUILD_SCHEDULED_EVENT_USER_REMOVE":
					self.data = try .guildScheduledEventUserRemove(decodeData())
				case "GUILD_AUDIT_LOG_ENTRY_CREATE":
					self.data = try .guildAuditLogEntryCreate(decodeData())
				case "INTEGRATION_CREATE":
					self.data = try .integrationCreate(decodeData())
				case "INTEGRATION_UPDATE":
					self.data = try .integrationUpdate(decodeData())
				case "INTEGRATION_DELETE":
					self.data = try .integrationDelete(decodeData())
				case "INTERACTION_CREATE":
					self.data = try .interactionCreate(decodeData())
				case "INVITE_CREATE":
					self.data = try .inviteCreate(decodeData())
				case "INVITE_DELETE":
					self.data = try .inviteDelete(decodeData())
				case "MESSAGE_CREATE":
					self.data = try .messageCreate(decodeData())
				case "MESSAGE_UPDATE":
					self.data = try .messageUpdate(decodeData())
				case "MESSAGE_DELETE":
					self.data = try .messageDelete(decodeData())
				case "MESSAGE_DELETE_BULK":
					self.data = try .messageDeleteBulk(decodeData())
				case "MESSAGE_REACTION_ADD":
					self.data = try .messageReactionAdd(decodeData())
				case "MESSAGE_REACTION_REMOVE":
					self.data = try .messageReactionRemove(decodeData())
				case "MESSAGE_REACTION_REMOVE_ALL":
					self.data = try .messageReactionRemoveAll(decodeData())
				case "MESSAGE_REACTION_REMOVE_EMOJI":
					self.data = try .messageReactionRemoveEmoji(decodeData())
				case "PRESENCE_UPDATE":
					self.data = try .presenceUpdate(decodeData())
				case "STAGE_INSTANCE_CREATE":
					self.data = try .stageInstanceCreate(decodeData())
				case "STAGE_INSTANCE_DELETE":
					self.data = try .stageInstanceDelete(decodeData())
				case "STAGE_INSTANCE_UPDATE":
					self.data = try .stageInstanceUpdate(decodeData())
				case "CHANNEL_UNREAD_UPDATE":
					self.data = try .channelUnreadUpdate(decodeData())
				case "TYPING_START":
					self.data = try .typingStart(decodeData())
				case "USER_UPDATE":
					self.data = try .userUpdate(decodeData())
				case "VOICE_STATE_UPDATE":
					self.data = try .voiceStateUpdate(decodeData())
				case "VOICE_SERVER_UPDATE":
					self.data = try .voiceServerUpdate(decodeData())
				case "WEBHOOKS_UPDATE":
					self.data = try .webhooksUpdate(decodeData())
				case "APPLICATION_COMMAND_PERMISSIONS_UPDATE":
					self.data = try .applicationCommandPermissionsUpdate(decodeData())
				case "AUTO_MODERATION_RULE_CREATE":
					self.data = try .autoModerationRuleCreate(decodeData())
				case "AUTO_MODERATION_RULE_UPDATE":
					self.data = try .autoModerationRuleUpdate(decodeData())
				case "AUTO_MODERATION_RULE_DELETE":
					self.data = try .autoModerationRuleDelete(decodeData())
				case "AUTO_MODERATION_ACTION_EXECUTION":
					self.data = try .autoModerationActionExecution(decodeData())
				case "MESSAGE_POLL_VOTE_ADD":
					self.data = try .messagePollVoteAdd(decodeData())
				case "MESSAGE_POLL_VOTE_REMOVE":
					self.data = try .messagePollVoteRemove(decodeData())
				case "AUTH_SESSION_CHANGE":
					self.data = try .authSessionChange(decodeData())
				case "AUTO_MODERATION_MENTION_RAID_DETECTION":
					self.data = try .autoModerationMentionRaidDetection(decodeData())
				case "CALL_CREATE":
					self.data = try .callCreate(decodeData())
				case "CALL_UPDATE":
					self.data = try .callUpdate(decodeData())
				case "CALL_DELETE":
					self.data = try .callDelete(decodeData())
				case "CHANNEL_STATUSES":
					self.data = try .voiceChannelStatuses(decodeData())
				case "VOICE_CHANNEL_STATUS_UPDATE":
					self.data = try .voiceChannelStatusUpdate(decodeData())
				case "CHANNEL_MEMBER_COUNT_UPDATE":
					self.data = try .channelMemberCountUpdate(decodeData())
				case "CHANNEL_RECIPIENT_ADD":
					self.data = try .channelRecipientAdd(decodeData())
				case "CHANNEL_RECIPIENT_REMOVE":
					self.data = try .channelRecipientRemove(decodeData())
				case "CONSOLE_COMMAND_UPDATE":
					self.data = try .consoleCommandUpdate(decodeData())
				case "CONVERSATION_SUMMARY_UPDATE":
					self.data = try .conversationSummaryUpdate(decodeData())
				case "DM_SETTINGS_UPSELL_SHOW":
					self.data = try .dmSettingsShow(decodeData())
				case "FRIEND_SUGGESTION_CREATE":
					self.data = try .friendSuggestionCreate(decodeData())
				case "FRIEND_SUGGESTION_DELETE":
					self.data = try .friendSuggestionDelete(decodeData())
				case "GUILD_APPLICATION_COMMAND_INDEX_UPDATE":
					self.data = try .guildApplicationCommandIndexUpdate(decodeData())
				case "GUILD_APPLIED_BOOSTS_UPDATE":
					self.data = try .guildAppliedBoostsUpdate(decodeData())
				case "GUILD_SCHEDULED_EVENT_EXCEPTION_CREATE":
					self.data = try .guildScheduledEventExceptionCreate(decodeData())
				case "GUILD_SCHEDULED_EVENT_EXCEPTION_UPDATE":
					self.data = try .guildScheduledEventExceptionUpdate(decodeData())
				case "GUILD_SCHEDULED_EVENT_EXCEPTION_DELETE":
					self.data = try .guildScheduledEventExceptionDelete(decodeData())
				case "GUILD_SCHEDULED_EVENT_EXCEPTIONS_DELETE":
					self.data = try .guildScheduledEventExceptionsDelete(decodeData())
				case "GUILD_SOUNDBOARDS_SOUND_CREATE":
					self.data = try .guildSoundboardSoundCreate(decodeData())
				case "GUILD_SOUNDBOARDS_SOUND_UPDATE":
					self.data = try .guildSoundboardSoundUpdate(decodeData())
				case "GUILD_SOUNDBOARDS_SOUND_DELETE":
					self.data = try .guildSoundboardSoundDelete(decodeData())
				case "SOUNDBOARD_SOUNDS":
					self.data = try .soundboardSounds(decodeData())
				case "INTERACTION_FAILURE":
					self.data = try .interactionFailure(decodeData())
				case "INTERACTION_SUCCESS":
					self.data = try .interactionSuccess(decodeData())
				case "APPLICATION_COMMAND_AUTOCOMPLETE_RESPONSE":
					self.data = try .applicationCommandAutocompleteResponse(decodeData())
				case "INTERACTION_MODAL_CREATE":
					self.data = try .interactionModalCreate(decodeData())
				case "INTERACTION_IFRAME_MODAL_CREATE":
					self.data = try .interactionIFrameModalCreate(decodeData())
				case "MESSAGE_REACTION_ADD_MANY":
					self.data = try .messageReactionAddMany(decodeData())
				case "RECENT_MENTION_DELETE":
					self.data = try .recentMentionDelete(decodeData())
				case "LAST_MESSAGES":
					self.data = try .lastMessages(decodeData())
				case "NOTIFICATION_SETTINGS_UPDATE":
					self.data = try .notificationSettingsUpdate(decodeData())
				case "RELATIONSHIP_ADD":
					self.data = try .relationshipAdd(decodeData())
				case "RELATIONSHIP_UPDATE":
					self.data = try .relationshipUpdate(decodeData())
				case "RELATIONSHIP_REMOVE":
					self.data = try .relationshipRemove(decodeData())
				case "SAVED_MESSAGE_CREATE":
					self.data = try .savedMessageCreate(decodeData())
				case "SAVED_MESSAGE_DELETE":
					self.data = try .savedMessageCreate(decodeData())
				case "SESSIONS_REPLACE":
					self.data = try .sessionReplace(decodeData())
				case "USER_APPLICATION_UPDATE":
					self.data = try .userApplicationUpdate(decodeData())
				case "USER_APPLICATION_REMOVE":
					self.data = try .userApplicationRemove(decodeData())
				case "USER_CONNECTIONS_UPDATE":
					self.data = try .userConnectionsUpdate(decodeData())
				case "USER_NOTE_UPDATE":
					self.data = try .userNoteUpdate(decodeData())
				case "USER_GUILD_SETTINGS_UPDATE":
					self.data = try .userGuildSettingsUpdate(decodeData())
				case "USER_SETTINGS_UPDATE":
					self.data = try .userSettingsUpdate(decodeData())
				default:
					throw GatewayDecodingError.unhandledDispatchEvent(type: self.type)
				}
			}
		}

		public enum EncodingError: Error, CustomStringConvertible {
			/// This event is not supposed to be sent at all. This could be a library issue, please report at https://github.com/DiscordBM/DiscordBM/issues.
			case notSupposedToBeSent(message: String)

			public var description: String {
				switch self {
				case let .notSupposedToBeSent(message):
					return "Gateway.Event.EncodingError.notSupposedToBeSent(\(message))"
				}
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)

			switch self.opcode {
			case .dispatch, .reconnect, .invalidSession, .heartbeatAccepted, .hello:
				throw EncodingError.notSupposedToBeSent(
					message:
						"`\(self.opcode.rawValue)` opcode is supposed to never be sent."
				)
			default: break
			}
			try container.encode(self.opcode, forKey: .opcode)

			if self.sequenceNumber != nil {
				throw EncodingError.notSupposedToBeSent(
					message:
						"'sequenceNumber' is supposed to never be sent but wasn't nil (\(String(describing: sequenceNumber))."
				)
			}
			if self.type != nil {
				throw EncodingError.notSupposedToBeSent(
					message:
						"'type' is supposed to never be sent but wasn't nil (\(String(describing: type))."
				)
			}

			switch self.data {
			case .none:
				try container.encodeNil(forKey: .data)
			case let .heartbeat(lastSequenceNumber):
				try container.encode(lastSequenceNumber, forKey: .data)
			case let .identify(payload):
				try container.encode(payload, forKey: .data)
			case let .resume(payload):
				try container.encode(payload, forKey: .data)
			case let .requestGuildMembers(payload):
				try container.encode(payload, forKey: .data)
			case let .requestPresenceUpdate(payload):
				try container.encode(payload, forKey: .data)
			case let .requestVoiceStateUpdate(payload):
				try container.encode(payload, forKey: .data)
			default:
				throw EncodingError.notSupposedToBeSent(
					message: "'\(self)' data is supposed to never be sent."
				)
			}
		}
	}
}

// MARK: + Gateway.Intent
extension Gateway.Intent {
	/// All intents that require no privileges.
	/// https://discord.com/developers/docs/topics/gateway#privileged-intents
	public static var unprivileged: [Gateway.Intent] {
		Gateway.Intent.allCases.filter { !$0.isPrivileged }
	}

	/// https://discord.com/developers/docs/topics/gateway#privileged-intents
	public var isPrivileged: Bool {
		switch self {
		case .guilds: return false
		case .guildMembers: return true
		case .guildModeration: return false
		case .guildEmojisAndStickers: return false
		case .guildIntegrations: return false
		case .guildWebhooks: return false
		case .guildInvites: return false
		case .guildVoiceStates: return false
		case .guildPresences: return true
		case .guildMessages: return false
		case .guildMessageReactions: return false
		case .guildMessageTyping: return false
		case .directMessages: return false
		case .directMessageReactions: return false
		case .directMessageTyping: return false
		case .messageContent: return true
		case .guildScheduledEvents: return false
		case .autoModerationConfiguration: return false
		case .autoModerationExecution: return false
		case .guildMessagePolls: return false
		case .directMessagePolls: return false
		/// Undocumented cases are considered privileged just to be safe than sorry
		case .__undocumented: return true
		}
	}
}
