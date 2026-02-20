/// https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
/// https://docs.discord.food/topics/opcodes-and-status-codes#gateway-close-event-codes
public enum GatewayCloseCode: UInt16, Sendable, Codable {
  case unknownError = 4000
  case unknownOpcode = 4001
  case decodeError = 4002
  case notAuthenticated = 4003
  case authenticationFailed = 4004
  case alreadyAuthenticated = 4005
  case sessionNoLongerValid = 4006
  case invalidSequence = 4007
  case rateLimited = 4008
  case sessionTimedOut = 4009
  case invalidShard = 4010
  case shardingRequired = 4011
  case invalidAPIVersion = 4012
  case invalidIntents = 4013
  case disallowedIntents = 4014
  case tooManySessions = 4015
  case connectionRequestCancelled = 4016

  public var canTryReconnect: Bool {
    switch self {
    case .unknownError: return true
    case .unknownOpcode: return true
    case .decodeError: return true
    case .notAuthenticated: return true
    case .authenticationFailed: return false
    case .alreadyAuthenticated: return true
    case .sessionNoLongerValid: return true
    case .invalidSequence: return true
    case .rateLimited: return true
    case .sessionTimedOut: return true
    case .invalidShard: return false
    case .shardingRequired: return false
    case .invalidAPIVersion: return false
    case .invalidIntents: return false
    case .disallowedIntents: return false
    case .tooManySessions: return false
    case .connectionRequestCancelled: return false
    }
  }
}

// CODE  DESCRIPTION
// 4001  Unknown opcode
// 4002  Failed to decode
// 4003  Not authenticated
// 4004  Authentication failed
// 4005  Already authenticated
// 4006  Session no longer valid
// 4009  Session timeout
// 4011  Server not found
// 4012  Unknown protocol
// 4014  Disconnected
// 4015  Voice server crashed
// 4016  Unknown encryption
// 4020  Bad request
// 4021  Rate limited
// 4022  Disconnected
/// https://docs.discord.food/topics/opcodes-and-status-codes#voice-close-event-codes
public enum VoiceGatewayCloseCode: UInt16, Sendable, Codable {
  case unknownOpcode = 4001
  case decodeError = 4002
  case notAuthenticated = 4003
  case authenticationFailed = 4004
  case alreadyAuthenticated = 4005
  case sessionNoLongerValid = 4006
  case sessionTimedOut = 4009
  case serverNotFound = 4011
  case unknownProtocol = 4012
  case disconnected1 = 4014
  case voiceServerCrashed = 4015
  case unknownEncryption = 4016
  case badRequest = 4020
  case rateLimited = 4021
  case disconnected2 = 4022

  public var canTryReconnect: Bool {
    switch self {
    case .unknownOpcode: return true
    case .decodeError: return true
    case .notAuthenticated: return true
    case .authenticationFailed: return false
    case .alreadyAuthenticated: return true
    case .rateLimited: return true
    case .sessionTimedOut: return true
    case .sessionNoLongerValid: return true
    case .serverNotFound: return false
    case .unknownProtocol: return false
    case .disconnected1, .disconnected2: return true
    case .voiceServerCrashed: return true
    case .unknownEncryption: return false
    case .badRequest: return false
    }
  }
}

/// https://discord.com/developers/docs/topics/opcodes-and-status-codes#json-json-error-codes
#if Non64BitSystemsCompatibility
  @UnstableEnum<Int64>
#else
  @UnstableEnum<Int>
#endif
public enum JSONErrorCode: Sendable, Codable {
  case generalError  // 0
  case unknownAccount  // 10001
  case unknownApplication  // 10002
  case unknownChannel  // 10003
  case unknownGuild  // 10004
  case unknownIntegration  // 10005
  case unknownInvite  // 10006
  case unknownMember  // 10007
  case unknownMessage  // 10008
  case unknownPermissionOverwrite  // 10009
  case unknownProvider  // 10010
  case unknownRole  // 10011
  case unknownToken  // 10012
  case unknownUser  // 10013
  case unknownEmoji  // 10014
  case unknownWebhook  // 10015
  case unknownWebhookService  // 10016
  case unknownSession  // 10020
  case unknownAsset  // 10021
  case unknownBan  // 10026
  case unknownSKU  // 10027
  case unknownStoreListing  // 10028
  case unknownEntitlement  // 10029
  case unknownBuild  // 10030
  case unknownLobby  // 10031
  case unknownBranch  // 10032
  case unknownStoreDirectoryLayout  // 10033
  case unknownRedistributable  // 10036
  case unknownGiftCode  // 10038
  case unknownStream  // 10049
  case unknownPremiumServerSubscribeCooldown  // 10050
  case unknownGuildTemplate  // 10057
  case unknownDiscoverableServerCategory  // 10059
  case unknownSticker  // 10060
  case unknownStickerPack  // 10061
  case unknownInteraction  // 10062
  case unknownApplicationCommand  // 10063
  case unknownVoiceState  // 10065
  case unknownApplicationCommandPermissions  // 10066
  case unknownStageInstance  // 10067
  case unknownGuildMemberVerificationForm  // 10068
  case unknownGuildWelcomeScreen  // 10069
  case unknownGuildScheduledEvent  // 10070
  case unknownGuildScheduledEventUser  // 10071
  case unknownTag  // 10087
  case unknownSound  // 10097
  case botsCannotUseEndpoint  // 20001
  case onlyBotsCanUseEndpoint  // 20002
  case explicitContentCannotBeSentToRecipients  // 20009
  case notAuthorizedToPerformActionOnApplication  // 20012
  case cantPerformDueToSlowModeRateLimit  // 20016
  case onlyTheOwnerOfAccountCanPerformAction  // 20018
  case messageCannotBeEditedDueToAnnouncementRateLimits  // 20022
  case underMinimumAge  // 20024
  case channelHitWriteRateLimit  // 20028
  case actionOnServerHitWriteRateLimit  // 20029
  case
    stageTopicOrServerNameOrServerDescriptionOrChannelNamesContainDisallowedWords  // 20031
  case guildPremiumSubscriptionLevelTooLow  // 20035
  case maxNumberOfGuildsReached  // 30001
  case maxNumberOfFriendsReached  // 30002
  case maxNumberOfPinsReachedForTheChannel  // 30003
  case maxNumberOfRecipientsReached  // 30004
  case maxNumberOfGuildRolesReached  // 30005
  case maxNumberOfWebhooksReached  // 30007
  case maxNumberOfEmojisReached  // 30008
  case maxNumberOfReactionsReached  // 30010
  case maxNumberOfGroupDMsReached  // 30011
  case maxNumberOfGuildChannelsReached  // 30013
  case maxNumberOfAttachmentsInMessageReached  // 30015
  case maxNumberOfInvitesReached  // 30016
  case maxNumberOfAnimatedEmojisReached  // 30018
  case maxNumberOfServerMembersReached  // 30019
  case maxNumberOfServerCategoriesReached  // 30030
  case guildAlreadyHasTemplate  // 30031
  case maxNumberOfApplicationCommandsReached  // 30032
  case maxNumberOfThreadParticipantsReached  // 30033
  case maxNumberOfDailyApplicationCommandCreatesReached  // 30034
  case maxNumberOfBansForNonGuildMembersExceeded  // 30035
  case maxNumberOfBansFetchesReached  // 30037
  case maxNumberOfUncompletedGuildScheduledEventsReached  // 30038
  case maxNumberOfStickersReached  // 30039
  case maxNumberOfPruneRequestsReached  // 30040
  case maxNumberOfGuildWidgetSettingsUpdatesReached  // 30042
  case maxNumberOfSoundboardSoundsReached  // 30045
  case maxNumberOfEditsToMessagesOlderThan1HourReached  // 30046
  case maxNumberOfPinnedThreadsInForumChannelReached  // 30047
  case maxNumberOfTagsInForumChannelReached  // 30048
  case BitrateIsTooHighForChannelOfThisType  // 30052
  case maxNumberOfPremiumEmojisReached  // 30056
  case maxNumberOfWebhooksPerGuildReached  // 30058
  case maxNumberOfChannelPermissionOverwritesReached  // 30060
  case channelsForThisGuildAreTooLarge  // 30061
  case UnauthorizedNeedToProvideValidToken  // 40001
  case needToVerifyYourAccountForAction  // 40002
  case openingDMsTooFast  // 40003
  case sendMessagesTemporarilyDisabled  // 40004
  case requestEntityTooLarge  // 40005
  case featureTemporarilyDisabledOnServerSide  // 40006
  case userIsBannedFromGuild  // 40007
  case connectionRevoked  // 40012
  case onlyConsumableSKUsCanBeConsumed  // 40018
  case youCanOnlyDeleteSandboxEntitlements  // 40019
  case userNotConnectedToVoice  // 40032
  case messageAlreadyCrossposted  // 40033
  case applicationCommandWithNameAlreadyExists  // 40041
  case applicationInteractionFailedToSend  // 40043
  case cannotSendMessageInForumChannel  // 40058
  case interactionAlreadyBeenAcknowledged  // 40060
  case namesMustBeUnique  // 40061
  case serviceResourceRateLimited  // 40062
  case noTagsAvailableThatCanBeSetByNonModerators  // 40066
  case tagRequiredToCreateForumPostInChannel  // 40067
  case anEntitlementHasAlreadyBeenGrantedForThisResource  // 40074
  case thisInteractionHasHitTheMaximumNumberOfFollowUpMessage  // 40094
  case
    cloudflareIsBlockingYourRequestThisCanOftenBeResolvedBySettingProperUserAgent  // 40333
  case missingAccess  // 50001
  case invalidAccountType  // 50002
  case cannotExecuteActionOnDMChannel  // 50003
  case guildWidgetDisabled  // 50004
  case cannotEditMessageAuthoredByAnotherUser  // 50005
  case cannotSendEmptyMessage  // 50006
  case cannotSendMessagesToThisUser  // 50007
  case cannotSendMessagesInNonTextChannel  // 50008
  case channelVerificationLevelIsTooHighForYouToGainAccess  // 50009
  case oAuth2ApplicationDoesNotHaveBot  // 50010
  case oAuth2ApplicationLimitReached  // 50011
  case invalidOAuth2State  // 50012
  case missingPermissions  // 50013
  case invalidAuthenticationToken  // 50014
  case noteWasTooLong  // 50015
  case tooFewOrTooManyMessagesToDelete  // 50016
  case invalidMFALevel  // 50017
  case messageCanOnlyBePinnedToTheChannelItWasSentIn  // 50019
  case inviteCodeWasInvalidOrTaken  // 50020
  case cannotExecuteActionOnSystemMessage  // 50021
  case cannotExecuteActionOnThisChannelType  // 50024
  case invalidOAuth2AccessToken  // 50025
  case missingRequiredOAuth2Scope  // 50026
  case invalidWebhookToken  // 50027
  case invalidRole  // 50028
  case invalidRecipients  // 50033
  case messageWasTooOldToBulkDelete  // 50034
  case invalidFormBodyOrInvalidContentType  // 50035
  case inviteWasAcceptedToGuildTheApplicationBotIsNotIn  // 50036
  case invalidActivityAction  // 50039
  case invalidAPIVersion  // 50041
  case fileUploadedExceedsMaxSize  // 50045
  case invalidFileUploaded  // 50046
  case cannotSelfRedeemThisGift  // 50054
  case invalidGuild  // 50055
  case invalidSKU  // 50057
  case invalidRequestOrigin  // 50067
  case invalidMessageType  // 50068
  case paymentSourceRequiredToRedeemGift  // 50070
  case cannotModifySystemWebhook  // 50073
  case cannotDeleteChannelRequiredForCommunityGuilds  // 50074
  case cannotEditStickersWithinMessage  // 50080
  case invalidStickerSent  // 50081
  case triedToPerformOperationOnArchivedThread  // 50083
  case invalidThreadNotificationSettings  // 50084
  case beforeValueIsEarlierThanThreadCreationDate  // 50085
  case communityServerChannelsMustBeTextChannels  // 50086
  case entityTypeOfTheEventIsDifferentFromEntityYouAreTryingToStartEventFor  // 50091
  case serverNotAvailableInYourLocation  // 50095
  case serverNeedsMonetizationEnabledToPerformAction  // 50097
  case serverNeedsMoreBoostsToPerformThisAction  // 50101
  case requestBodyContainsInvalidJSON  // 50109
  case providedFileIsInvalid  // 50110
  case providedFileTypeIsInvalid  // 50123
  case providedFileDurationExceedsMaximumOf5_2Seconds  // 50124
  case ownerCannotBePendingMember  // 50131
  case ownershipCannotBeTransferredToBotUser  // 50132
  case failedToResizeAssetBelowTheMaxSize  // 50138
  case cannotMixSubscriptionAndNonSubscriptionRolesForEmoji  // 50144
  case cannotConvertBetweenPremiumEmojiAndNormalEmoji  // 50145
  case uploadedFileNotFound  // 50146
  case specifiedEmojiIsInvalid  // 50151
  case voiceMessagesDoNotSupportAdditionalContent  // 50159
  case voiceMessagesMustHaveASingleAudioAttachment  // 50160
  case voiceMessagesMustHaveSupportingMetadata  // 50161
  case voiceMessagesCannotBeEdited  // 50162
  case cannotDeleteGuildSubscriptionIntegration  // 50163
  case cannotSendVoiceMessagesInThisChannel  // 50173
  case theUserAccountMustFirstBeVerified  // 50178
  case providedFileDoesNotHaveAValidDuration  // 50192
  case missingPermissionToSendSticker  // 50600
  case twoFactorRequiredForOperation  // 60003
  case noUsersWithDiscordTagExist  // 80004
  case reactionWasBlocked  // 90001
  case userCannotUseBurstReactions  // 90002
  case applicationNotYetAvailable  // 110001
  case APIResourceIsCurrentlyOverloaded  // 130000
  case stageIsAlreadyOpen  // 150006
  case cannotReplyWithoutPermissionToReadMessageHistory  // 160002
  case threadAlreadyCreatedForMessage  // 160004
  case threadLocked  // 160005
  case maxNumberOfActiveThreadsReached  // 160006
  case maxNumberOfActiveAnnouncementThreadsReached  // 160007
  case invalidJSONForUploadedLottieFile  // 170001
  case uploadedLottiesCannotContainRasterizedImagesSuchAsPNGOrJPEG  // 170002
  case stickerMaxFrameRateExceeded  // 170003
  case stickerFrameCountExceedsMaxOf1000Frames  // 170004
  case lottieAnimationMaxDimensionsExceeded  // 170005
  case stickerFrameRateIsTooSmallOrTooLarge  // 170006
  case stickerAnimationDurationExceedsMaxOf5Seconds  // 170007
  case cannotUpdateFinishedEvent  // 180000
  case failedToCreateStage  // 180002
  case messageWasBlockedByAutomaticModeration  // 200000
  case titleWasBlockedByAutomaticModeration  // 200001
  case webhooksPostedToForumChannelsMustHaveThreadNameOrThreadId  // 220001
  case webhooksPostedToForumChannelsCannotHaveBothThreadNameAndThreadId  // 220002
  case webhooksCanOnlyCreateThreadsInForumChannels  // 220003
  case webhookServicesCannotBeUsedInForumChannels  // 220004
  case messageBlockedByHarmfulLinksFilter  // 240000
  case cannotEnableOnboardingRequirementsAreNotMet  // 350000
  case cannotUpdateOnboardingWhileBelowRequirements  // 350001
  case failedToBanUsers  // 500000
  case pollVotingBlocked  // 520000
  case pollExpired  // 520001
  case invalidChannelTypeForPollCreation  // 520002
  case cannotEditPollMessage  // 520003
  case cannotUseEmojiIncludedWithThePoll  // 520004
  case cannotExpireNonPollMessage  // 520006
  #if Non64BitSystemsCompatibility
    case __undocumented(Int64)
  #else
    case __undocumented(Int)
  #endif
}

/// https://discord.com/developers/docs/topics/opcodes-and-status-codes#json
public struct JSONError: Sendable, Codable {
  public var message: String
  /// Might be `nil` in case of something like a rate-limit error.
  public var code: JSONErrorCode?
  /// Might exist for MFA required error. This goes unused by the library as it is caught differently.
  public var mfa: MFAVerificationData?
  /// Contains form errors
  public var errors: Errors?

  //	{
  //		"message": "Invalid Form Body",
  //		"code": 50035,
  //		"errors": {
  //			"login": {
  //				"_errors": [{
  //					"code": "EMAIL_DOES_NOT_EXIST",
  //					"message": "Email does not exist."
  //				}]
  //			}
  //		}
  //	}

  public struct Errors: Sendable, Codable {
    public struct FieldError: Sendable, Codable {
      public var code: String
      public var message: String
    }

    public var fieldErrors: [String: [FieldError]]

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
      var fieldErrors: [String: [FieldError]] = [:]

      for key in container.allKeys {
        // get errors for each field
        do {
          let fieldContainer = try container.nestedContainer(
            keyedBy: DynamicCodingKeys.self,
            forKey: key
          )
          let errorsArray = try fieldContainer.decodeIfPresent(
            [FieldError].self,
            forKey: DynamicCodingKeys(stringValue: "_errors")!
          )
          fieldErrors[key.stringValue] = errorsArray ?? []
        } catch {
          print(
            "Failed to decode field errors for key \(key.stringValue): \(error)"
          )
          fieldErrors[key.stringValue] = []
        }
      }

      self.fieldErrors = fieldErrors
    }

    // similar to https://stackoverflow.com/a/71525522
    struct DynamicCodingKeys: CodingKey {
      var stringValue: String
      init?(stringValue: String) { self.stringValue = stringValue }
      var intValue: Int? { nil }
      init?(intValue: Int) { nil }
    }
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.message = try container.decode(String.self, forKey: .message)
    self.code = try container.decodeIfPresent(JSONErrorCode.self, forKey: .code)
    self.mfa = try container.decodeIfPresent(
      MFAVerificationData.self,
      forKey: .mfa
    )

    do {
      self.errors = try container.decodeIfPresent(Errors.self, forKey: .errors)
    } catch {
      print("Failed to decode errors: \(error)")
      // this isnt critical and i'd rather not fail decoding the entire error
      self.errors = nil
    }
  }

  enum CodingKeys: String, CodingKey {
    case message, code, mfa, errors
  }
}
