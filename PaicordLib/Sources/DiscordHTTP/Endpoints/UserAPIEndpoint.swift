// this file is made by hand :c

import DiscordModels
import NIOHTTP1

public enum UserAPIEndpoint: Endpoint {
  // MARK: - Authentication
  case getExperiments
  case userLogin  // requires fingerprint
  case verifySendSMS  // requires fingerprint
  case verifyMFALogin(type: Payloads.MFASubmitData.MFAKind)  // requires fingerprint
  case getAuthSessions
  case logoutAuthSessions
  case forgotPassword
  case verifyMFA

  // MARK: - Applications
  case getApplications(withTeamApplications: Bool)
  case getApplicationsWithAssets(withTeamApplications: Bool)
  case getEmbeddedActivities(guildId: GuildSnowflake?)
  case getPartialApplications(ids: [ApplicationSnowflake])
  case getPartialApplication(id: ApplicationSnowflake, withGuild: Bool)
  case getDetectableApplications

  // MARK: Audit Log

  // MARK: Auto Moderation
  case validateAutoModRule(guildId: GuildSnowflake)
  case executeAutoModAlertAction(guildId: GuildSnowflake)

  // MARK: - Billing

  // MARK: - Channels

  // MARK: - Components

  // MARK: - Connected Accounts

  // MARK: - Directory Entries

  // MARK: - Discovery

  // MARK: - Emoji
  case getGuildTopEmojis(guildId: GuildSnowflake)

  // MARK: - Entitlements

  // MARK: - Family Center

  // MARK: - Guilds

  // MARK: - Guild Analytics

  // MARK: - Guild Scheduled Events

  // MARK: - Guild Templates

  // MARK: - Integrations

  // MARK: - Invites
  case acceptInvite(code: String)
  case getUserInvites
  case createUserInvite
  case revokeUserInvites

  // MARK: - Lobbies

  // MARK: - Messages

  // MARK: - Payments

  // MARK: - Premium Referrals

  // MARK: - Presences

  // MARK: - Quests

  // MARK: - Relationships
  case getRelationships
  case sendFriendRequest
  case createRelationship(userId: UserSnowflake)
  case ignoreUser(userId: UserSnowflake)
  case unignoreUser(userId: UserSnowflake)
  case modifyRelationship(userId: UserSnowflake)
  case removeRelationship(userId: UserSnowflake)
  case bulkRemoveRelationships(type: DiscordRelationship.Kind)
  case bulkAddRelationships
  case getFriendSuggestions
  case removeFriendSuggestion(userId: UserSnowflake)

  // MARK: - Safety Hub

  // MARK: - Soundboard
  case getDefaultSoundboardSounds
  case getGuildSoundboardSounds(guildId: GuildSnowflake)
  case getGuildSoundboardSound(guildId: GuildSnowflake, soundId: SoundSnowflake)
  case createGuildSoundboardSound(guildId: GuildSnowflake)
  case modifyGuildSoundboardSound(
    guildId: GuildSnowflake,
    soundId: SoundSnowflake
  )
  case deleteGuildSoundboardSound(
    guildId: GuildSnowflake,
    soundId: SoundSnowflake
  )
  case getSoundboardSoundGuild(soundId: SoundSnowflake, guildId: GuildSnowflake)
  case sendSoundboardSound(channelId: ChannelSnowflake)

  // MARK: - Stage Instances

  // MARK: Stickers
  case getStickerPacks
  case getStickerPack(stickerPackId: StickerPackSnowflake)
  case getStickerGuild(stickerId: StickerSnowflake)

  // MARK: - Subscriptions

  // MARK: - Teams

  // MARK: - Users
  case getUserProfile(
    userId: UserSnowflake,
    withMutualGuilds: Bool,
    withMutualFriends: Bool,
    withMutualFriendsCount: Bool,
    guildId: GuildSnowflake?
  )

  /// This case serves as a way of discouraging exhaustive switch statements
  case __DO_NOT_USE_THIS_CASE

  var urlPrefix: String {
    "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
  }

  public var url: String {
    let suffix: String
    switch self {
    // MARK: - Authentication
    case .getExperiments:
      suffix = "experiments"
    case .userLogin:
      suffix = "auth/login"
    case .verifySendSMS:
      suffix = "auth/mfa/sms/send"
    case .verifyMFALogin(let type):
      suffix = "auth/mfa/\(type.rawValue)"
    case .getAuthSessions:
      suffix = "auth/sessions"
    case .logoutAuthSessions:
      suffix = "auth/sessions/logout"
    case .forgotPassword:
      suffix = "auth/forgot"
    case .verifyMFA:
      suffix = "mfa/finish"

    // MARK: - Applications
    case .getApplications(let withTeamApplications):
      suffix = "applications?with_team_applications=\(withTeamApplications)"
    case .getApplicationsWithAssets(let withTeamApplications):
      suffix = "applications-with-assets?with_team_applications=\(withTeamApplications)"
    case .getEmbeddedActivities(let guildId):
      if let guildId {
        suffix = "activities/shelf?guild_id=\(guildId.rawValue)"
      } else {
        suffix = "activities/shelf"
      }
    case .getPartialApplications(let ids):
      let idsString = ids.map(\.rawValue).joined(separator: ",")
      suffix = "applications/public?application_ids=\(idsString)"
    case .getPartialApplication(let id, let withGuild):
      suffix = "applications/public/\(id.rawValue)?with_guild=\(withGuild)"
    case .getDetectableApplications:
      suffix = "applications/detectable"

    // MARK: - Auto Moderation
    case .validateAutoModRule(let guildId):
      suffix = "guilds/\(guildId.rawValue)/auto-moderation/rules/validate"
    case .executeAutoModAlertAction(let guildId):
      suffix = "guilds/\(guildId.rawValue)/auto-moderation/alert-action"

    // MARK: - Emojis
    case .getGuildTopEmojis(let guildId):
      suffix = "guilds/\(guildId.rawValue)/top-emojis"

    // MARK: - Invites
    case .acceptInvite(let code):
      suffix = "invites/\(code)"
    case .getUserInvites,
      .createUserInvite,
      .revokeUserInvites:
      suffix = "users/@me/invites"

    // MARK: - Relationships
    case .getRelationships:
      suffix = "users/@me/relationships"
    case .sendFriendRequest:
      suffix = "users/@me/relationships"
    case .createRelationship(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)"
    case .ignoreUser(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)/ignore"
    case .unignoreUser(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)/ignore"
    case .modifyRelationship(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)"
    case .removeRelationship(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)"
    case .bulkRemoveRelationships(let type):
      suffix = "users/@me/relationships?relationship_type=\(type.queryString)"
    case .bulkAddRelationships:
      suffix = "users/@me/relationships/bulk"
    case .getFriendSuggestions:
      suffix = "friend-suggestions"
    case .removeFriendSuggestion(let userId):
      suffix = "friend-suggestions/\(userId.rawValue)"

    // MARK: - Soundboard
    case .getDefaultSoundboardSounds:
      suffix = "soundboard-default-sounds"
    case .getGuildSoundboardSounds(let guildId):
      suffix = "guilds/\(guildId.rawValue)/soundboard-sounds"
    case .getGuildSoundboardSound(let guildId, let soundId):
      suffix =
        "guilds/\(guildId.rawValue)/soundboard-sounds/\(soundId.rawValue)"
    case .createGuildSoundboardSound(let guildId):
      suffix = "guilds/\(guildId.rawValue)/soundboard-sounds"
    case .modifyGuildSoundboardSound(let guildId, let soundId):
      suffix =
        "guilds/\(guildId.rawValue)/soundboard-sounds/\(soundId.rawValue)"
    case .deleteGuildSoundboardSound(let guildId, let soundId):
      suffix =
        "guilds/\(guildId.rawValue)/soundboard-sounds/\(soundId.rawValue)"
    case .getSoundboardSoundGuild(let soundId, let guildId):
      suffix =
        "soundboard-sounds/\(soundId.rawValue)/guilds/\(guildId.rawValue)"
    case .sendSoundboardSound(let channelId):
      suffix = "channels/\(channelId.rawValue)/send-soundboard-sound"

    // MARK: - Stickers
    case .getStickerPacks:
      suffix = "sticker-packs"
    case .getStickerPack(let stickerPackId):
      suffix = "sticker-packs/\(stickerPackId.rawValue)"
    case .getStickerGuild(let stickerId):
      suffix = "stickers/\(stickerId.rawValue)/guild"

    // MARK: - Users
    case .getUserProfile(
      let userId,
      let withMutualGuilds,
      let withMutualFriends,
      let withMutualFriendsCount,
      let guildId
    ):
      var queryItems: [String] = []
      if withMutualGuilds {
        queryItems.append("with_mutual_guilds=true")
      }
      if withMutualFriends {
        queryItems.append("with_mutual_friends=true")
      }
      if withMutualFriendsCount {
        queryItems.append("with_mutual_friends_count=true")
      }
      if let guildId {
        queryItems.append("guild_id=\(guildId.rawValue)")
      }
      let queryString =
        queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
      suffix = "users/\(userId.rawValue)/profile\(queryString)"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }

    return urlPrefix + suffix
  }

  public var urlDescription: String {
    let suffix: String
    switch self {
    case .getExperiments:
      suffix = "experiments"
    case .userLogin:
      suffix = "auth/login"
    case .verifySendSMS:
      suffix = "auth/mfa/sms/send"
    case .verifyMFALogin(let type):
      suffix = "auth/mfa/\(type.rawValue)"
    case .getAuthSessions:
      suffix = "auth/sessions"
    case .logoutAuthSessions:
      suffix = "auth/sessions/logout"
    case .forgotPassword:
      suffix = "auth/forgot"
    case .verifyMFA:
      suffix = "mfa/finish"
    case .getApplications(let withTeamApplications):
      suffix = "applications?with_team_applications=\(withTeamApplications)"
    case .getPartialApplication(let id, let withGuild):
      suffix = "applications/public/\(id.rawValue)?with_guild=\(withGuild)"
    case .getApplicationsWithAssets(let withTeamApplications):
      suffix = "applications-with-assets?with_team_applications=\(withTeamApplications)"
    case .getEmbeddedActivities(let guildId):
      if let guildId {
        suffix = "activities/shelf?guild_id=\(guildId.rawValue)"
      } else {
        suffix = "activities/shelf"
      }
    case .getPartialApplications(let ids):
      let idsString = ids.map(\.rawValue).joined(separator: ",")
      suffix = "applications/public?application_ids=\(idsString)"
    case .getDetectableApplications:
      suffix = "applications/detectable"
    case .validateAutoModRule(let guildId):
      suffix = "guilds/\(guildId.rawValue)/auto-moderation/rules/validate"
    case .executeAutoModAlertAction(let guildId):
      suffix = "guilds/\(guildId.rawValue)/auto-moderation/alert-action"
    case .getGuildTopEmojis(let guildId):
      suffix = "/guilds/\(guildId.rawValue)/top-emojis"
    case .acceptInvite(let code):
      suffix = "invites/\(code)"
    case .getUserInvites,
      .createUserInvite,
      .revokeUserInvites:
      suffix = "users/@me/invites"
    case .getRelationships:
      suffix = "users/@me/relationships"
    case .sendFriendRequest:
      suffix = "users/@me/relationships"
    case .createRelationship(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)"
    case .ignoreUser(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)/ignore"
    case .unignoreUser(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)/ignore"
    case .modifyRelationship(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)"
    case .removeRelationship(let userId):
      suffix = "users/@me/relationships/\(userId.rawValue)"
    case .bulkRemoveRelationships(let type):
      suffix = "users/@me/relationships?relationship_type=\(type.queryString)"
    case .bulkAddRelationships:
      suffix = "users/@me/relationships/bulk"
    case .getFriendSuggestions:
      suffix = "friend-suggestions"
    case .removeFriendSuggestion(let userId):
      suffix = "friend-suggestions/\(userId.rawValue)"
    case .getDefaultSoundboardSounds:
      suffix = "soundboard-default-sounds"
    case .getGuildSoundboardSounds(let guildId):
      suffix = "guilds/\(guildId.rawValue)/soundboard-sounds"
    case .getGuildSoundboardSound(let guildId, let soundId):
      suffix =
        "guilds/\(guildId.rawValue)/soundboard-sounds/\(soundId.rawValue)"
    case .createGuildSoundboardSound(let guildId):
      suffix = "guilds/\(guildId.rawValue)/soundboard-sounds"
    case .modifyGuildSoundboardSound(let guildId, let soundId):
      suffix =
        "guilds/\(guildId.rawValue)/soundboard-sounds/\(soundId.rawValue)"
    case .deleteGuildSoundboardSound(let guildId, let soundId):
      suffix =
        "guilds/\(guildId.rawValue)/soundboard-sounds/\(soundId.rawValue)"
    case .getSoundboardSoundGuild(let soundId, let guildId):
      suffix =
        "soundboard-sounds/\(soundId.rawValue)/guilds/\(guildId.rawValue)"
    case .sendSoundboardSound(let channelId):
      suffix = "channels/\(channelId.rawValue)/send-soundboard-sound"
    case .getStickerPacks:
      suffix = "sticker-packs"
    case .getStickerPack(let stickerPackId):
      suffix = "sticker-packs/\(stickerPackId.rawValue)"
    case .getStickerGuild(let stickerId):
      suffix = "stickers/\(stickerId.rawValue)/guild"
    case .getUserProfile(
      let userId,
      let withMutualGuilds,
      let withMutualFriends,
      let withMutualFriendsCount,
      let guildId
    ):
      var queryItems: [String] = []
      if withMutualGuilds {
        queryItems.append("with_mutual_guilds=true")
      }
      if withMutualFriends {
        queryItems.append("with_mutual_friends=true")
      }
      if withMutualFriendsCount {
        queryItems.append("with_mutual_friends_count=true")
      }
      if let guildId {
        queryItems.append("guild_id=\(guildId.rawValue)")
      }
      let queryString =
        queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
      suffix = "users/\(userId.rawValue)/profile\(queryString)"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }

    return self.urlPrefix + suffix
  }

  public var httpMethod: HTTPMethod {
    switch self {
    case .getExperiments: return .GET
    case .userLogin: return .POST
    case .verifySendSMS: return .POST
    case .verifyMFALogin: return .POST
    case .getAuthSessions: return .GET
    case .logoutAuthSessions: return .POST
    case .forgotPassword: return .POST
    case .verifyMFA: return .POST
    case .getApplications: return .GET
    case .getApplicationsWithAssets: return .GET
    case .getEmbeddedActivities: return .GET
    case .getPartialApplications: return .GET
    case .getPartialApplication: return .GET
    case .getDetectableApplications: return .GET
    case .validateAutoModRule: return .POST
    case .executeAutoModAlertAction: return .POST
    case .getGuildTopEmojis: return .GET
    case .acceptInvite: return .POST
    case .getUserInvites: return .GET
    case .createUserInvite: return .POST
    case .revokeUserInvites: return .DELETE
    case .getRelationships: return .GET
    case .sendFriendRequest: return .POST
    case .createRelationship: return .PUT
    case .ignoreUser: return .PUT
    case .unignoreUser: return .DELETE
    case .modifyRelationship: return .PATCH
    case .removeRelationship: return .DELETE
    case .bulkRemoveRelationships: return .DELETE
    case .bulkAddRelationships: return .POST
    case .getFriendSuggestions: return .GET
    case .removeFriendSuggestion: return .DELETE
    case .getDefaultSoundboardSounds: return .GET
    case .getGuildSoundboardSounds: return .GET
    case .getGuildSoundboardSound: return .GET
    case .createGuildSoundboardSound: return .POST
    case .modifyGuildSoundboardSound: return .PATCH
    case .deleteGuildSoundboardSound: return .DELETE
    case .getSoundboardSoundGuild: return .GET
    case .sendSoundboardSound: return .POST
    case .getStickerPacks: return .GET
    case .getStickerPack: return .GET
    case .getStickerGuild: return .GET
    case .getUserProfile: return .GET
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var countsAgainstGlobalRateLimit: Bool {
    switch self {
    case .getExperiments: return false
    case .userLogin: return true
    case .verifySendSMS: return true
    case .verifyMFALogin: return true
    case .getAuthSessions: return true
    case .logoutAuthSessions: return true
    case .forgotPassword: return true
    case .verifyMFA: return true
    case .getApplications: return true
    case .getApplicationsWithAssets: return true
    case .getEmbeddedActivities: return true
    case .getPartialApplications: return true
    case .getPartialApplication: return true
    case .getDetectableApplications: return true
    case .validateAutoModRule: return true
    case .executeAutoModAlertAction: return true
    case .getGuildTopEmojis: return true
    case .acceptInvite: return true
    case .getUserInvites: return true
    case .createUserInvite: return true
    case .revokeUserInvites: return true
    case .getRelationships: return true
    case .sendFriendRequest: return true
    case .createRelationship: return true
    case .ignoreUser: return true
    case .unignoreUser: return true
    case .modifyRelationship: return true
    case .removeRelationship: return true
    case .bulkRemoveRelationships: return true
    case .bulkAddRelationships: return true
    case .getFriendSuggestions: return true
    case .removeFriendSuggestion: return true
    case .getDefaultSoundboardSounds: return true
    case .getGuildSoundboardSounds: return true
    case .getGuildSoundboardSound: return true
    case .createGuildSoundboardSound: return true
    case .modifyGuildSoundboardSound: return true
    case .deleteGuildSoundboardSound: return true
    case .getSoundboardSoundGuild: return true
    case .sendSoundboardSound: return true
    case .getStickerPacks: return false
    case .getStickerPack: return false
    case .getStickerGuild: return true
    case .getUserProfile: return true
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var requiresAuthorizationHeader: Bool {
    switch self {
    case .getExperiments: return false
    case .userLogin: return false
    case .verifySendSMS: return false
    case .verifyMFALogin: return false
    case .getAuthSessions: return true
    case .logoutAuthSessions: return true
    case .forgotPassword: return false
    case .verifyMFA: return true
    case .getApplications: return true
    case .getApplicationsWithAssets: return true
    case .getEmbeddedActivities: return true
    case .getPartialApplications: return true
    case .getPartialApplication: return true
    case .getDetectableApplications: return true
    case .validateAutoModRule: return true
    case .executeAutoModAlertAction: return true
    case .getGuildTopEmojis: return true
    case .acceptInvite: return true
    case .getUserInvites: return true
    case .createUserInvite: return true
    case .revokeUserInvites: return true
    case .getRelationships: return true
    case .sendFriendRequest: return true
    case .createRelationship: return true
    case .ignoreUser: return true
    case .unignoreUser: return true
    case .modifyRelationship: return true
    case .removeRelationship: return true
    case .bulkRemoveRelationships: return true
    case .bulkAddRelationships: return true
    case .getFriendSuggestions: return true
    case .removeFriendSuggestion: return true
    case .getDefaultSoundboardSounds: return true
    case .getGuildSoundboardSounds: return true
    case .getGuildSoundboardSound: return true
    case .createGuildSoundboardSound: return true
    case .modifyGuildSoundboardSound: return true
    case .deleteGuildSoundboardSound: return true
    case .getSoundboardSoundGuild: return true
    case .sendSoundboardSound: return true
    case .getStickerPacks: return false
    case .getStickerPack: return false
    case .getStickerGuild: return true
    case .getUserProfile: return true
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var parameters: [String] {
    switch self {
    case .getExperiments: return []
    case .userLogin: return []
    case .verifySendSMS: return []
    case .verifyMFALogin(let type): return [type.rawValue]
    case .getAuthSessions: return []
    case .logoutAuthSessions: return []
    case .forgotPassword: return []
    case .verifyMFA: return []
    case .getApplications: return []
    case .getApplicationsWithAssets: return []
    case .getEmbeddedActivities(let guildId):
      return [guildId?.rawValue].compactMap { $0 }
    case .getPartialApplications(let ids): return ids.map { $0.rawValue }
    case .getPartialApplication(let id, _): return [id.rawValue]
    case .getDetectableApplications: return []
    case .validateAutoModRule(let guildId): return [guildId.rawValue]
    case .executeAutoModAlertAction(let guildId): return [guildId.rawValue]
    case .getGuildTopEmojis(let guildId): return [guildId.rawValue]
    case .acceptInvite(let code): return [code]
    case .getUserInvites: return []
    case .createUserInvite: return []
    case .revokeUserInvites: return []
    case .getRelationships: return []
    case .sendFriendRequest: return []
    case .createRelationship(let userId): return [userId.rawValue]
    case .ignoreUser(let userId): return [userId.rawValue]
    case .unignoreUser(let userId): return [userId.rawValue]
    case .modifyRelationship(let userId): return [userId.rawValue]
    case .removeRelationship(let userId): return [userId.rawValue]
    case .bulkRemoveRelationships(let type): return [type.queryString]
    case .bulkAddRelationships: return []
    case .getFriendSuggestions: return []
    case .removeFriendSuggestion(let userId): return [userId.rawValue]
    case .getDefaultSoundboardSounds: return []
    case .getGuildSoundboardSounds(let guildId): return [guildId.rawValue]
    case .getGuildSoundboardSound(let guildId, let soundId):
      return [guildId.rawValue, soundId.rawValue]
    case .createGuildSoundboardSound(let guildId): return [guildId.rawValue]
    case .modifyGuildSoundboardSound(let guildId, let soundId):
      return [guildId.rawValue, soundId.rawValue]
    case .deleteGuildSoundboardSound(let guildId, let soundId):
      return [guildId.rawValue, soundId.rawValue]
    case .getSoundboardSoundGuild(let soundId, let guildId):
      return [soundId.rawValue, guildId.rawValue]
    case .sendSoundboardSound(let channelId): return [channelId.rawValue]
    case .getStickerPacks: return []
    case .getStickerPack(let stickerPackId): return [stickerPackId.rawValue]
    case .getStickerGuild(let stickerId): return [stickerId.rawValue]
    case .getUserProfile(let userId, let withMutualGuilds, let withMutualFriends, let withMutualFriendsCount, let guildId):
      var params: [String] = [userId.rawValue]
      if withMutualGuilds {
        params.append("with_mutual_guilds=true")
      }
      if withMutualFriends {
        params.append("with_mutual_friends=true")
      }
      if withMutualFriendsCount {
        params.append("with_mutual_friends_count=true")
      }
      if let guildId {
        params.append("guild_id=\(guildId.rawValue)")
      }
      return params
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var id: Int {
    switch self {
    case .getExperiments: return 1
    case .userLogin: return 2
    case .verifySendSMS: return 3
    case .verifyMFALogin: return 4
    case .getAuthSessions: return 5
    case .logoutAuthSessions: return 6
    case .forgotPassword: return 7
    case .verifyMFA: return 8
    case .getApplications: return 9
    case .getApplicationsWithAssets: return 10
    case .getPartialApplication: return 11
    case .getEmbeddedActivities: return 12
    case .getPartialApplications: return 13
    case .getDetectableApplications: return 14
    case .validateAutoModRule: return 15
    case .executeAutoModAlertAction: return 16
    // ... space for ignored endpoints i didn't implement
    case .getGuildTopEmojis: return 41
    case .acceptInvite: return 51
    case .getUserInvites: return 52
    case .createUserInvite: return 53
    case .revokeUserInvites: return 54
    case .getRelationships: return 55
    case .sendFriendRequest: return 56
    case .createRelationship: return 57
    case .ignoreUser: return 58
    case .unignoreUser: return 59
    case .modifyRelationship: return 60
    case .removeRelationship: return 61
    case .bulkRemoveRelationships: return 62
    case .bulkAddRelationships: return 63
    case .getFriendSuggestions: return 64
    case .removeFriendSuggestion: return 65
    // ... space for safety hub endpoints
    case .getDefaultSoundboardSounds: return 75
    case .getGuildSoundboardSounds: return 76
    case .getGuildSoundboardSound: return 77
    case .createGuildSoundboardSound: return 78
    case .modifyGuildSoundboardSound: return 79
    case .deleteGuildSoundboardSound: return 80
    case .getSoundboardSoundGuild: return 81
    case .sendSoundboardSound: return 82
    case .getStickerPacks: return 91
    case .getStickerPack: return 92
    case .getStickerGuild: return 93
    case .getUserProfile: return 101
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var description: String {
    switch self {
    case .getExperiments: return "getExperiments"
    case .userLogin: return "userLoginCredentials"
    case .verifySendSMS: return "verifySendSMS"
    case .verifyMFALogin(let type):
      return "verifyMFALogin(type.rawValue: \(type.rawValue))"
    case .getAuthSessions: return "getAuthSessions"
    case .logoutAuthSessions: return "logoutAuthSessions"
    case .forgotPassword: return "forgotPassword"
    case .verifyMFA: return "verifyMFA"
    case .getApplications: return "getApplications"
    case .getApplicationsWithAssets: return "getApplicationsWithAssets"
    case .getEmbeddedActivities(let guildId):
      if let guildId {
        return "getEmbeddedActivities(guildId: \(guildId.rawValue))"
      } else {
        return "getEmbeddedActivities(guildId: nil)"
      }
    case .getPartialApplications(let ids):
      let idsString = ids.map(\.rawValue).joined(separator: ",")
      return "getPartialApplications(ids: [\(idsString)])"
    case .getDetectableApplications: return "getDetectableApplications"
    case .getPartialApplication(let id, let withGuild):
      return "getPartialApplication(id: \(id.rawValue), withGuild: \(withGuild))"
    case .validateAutoModRule(let guildId):
      return "validateAutoModRule(guildId: \(guildId.rawValue), ...)"
    case .executeAutoModAlertAction(let guildId):
      return "executeAutoModAlertAction(guildId: \(guildId.rawValue), ..."
    case .getGuildTopEmojis(let guildId):
      return "getGuildTopEmojis(guildId: \(guildId.rawValue))"
    case .acceptInvite(let code):
      return "acceptInvite(code: \(code))"
    case .getUserInvites: return "getUserInvites"
    case .createUserInvite: return "createUserInvite"
    case .revokeUserInvites: return "revokeUserInvites"
    case .getRelationships: return "getRelationships"
    case .sendFriendRequest: return "sendFriendRequest"
    case .createRelationship(let userId):
      return "createRelationship(userId: \(userId.rawValue))"
    case .ignoreUser(let userId):
      return "ignoreUser(userId: \(userId.rawValue))"
    case .unignoreUser(let userId):
      return "unignoreUser(userId: \(userId.rawValue))"
    case .modifyRelationship(let userId):
      return "modifyRelationship(userId: \(userId.rawValue))"
    case .removeRelationship(let userId):
      return "removeRelationship(userId: \(userId.rawValue))"
    case .bulkRemoveRelationships(let type):
      return "bulkRemoveRelationships(type: \(type.queryString))"
    case .bulkAddRelationships: return "bulkAddRelationships"
    case .getFriendSuggestions: return "getFriendSuggestions"
    case .removeFriendSuggestion(let userId):
      return "removeFriendSuggestion(userId: \(userId.rawValue))"
    case .getDefaultSoundboardSounds: return "getDefaultSoundboardSounds"
    case .getGuildSoundboardSounds(let guildId):
      return "getGuildSoundboardSounds(guildId: \(guildId.rawValue))"
    case .getGuildSoundboardSound(let guildId, let soundId):
      return
        "getGuildSoundboardSound(guildId: \(guildId.rawValue), soundId: \(soundId.rawValue))"
    case .createGuildSoundboardSound(let guildId):
      return "createGuildSoundboardSound(guildId: \(guildId.rawValue))"
    case .modifyGuildSoundboardSound(let guildId, let soundId):
      return
        "modifyGuildSoundboardSound(guildId: \(guildId.rawValue), soundId: \(soundId.rawValue))"
    case .deleteGuildSoundboardSound(let guildId, let soundId):
      return
        "deleteGuildSoundboardSound(guildId: \(guildId.rawValue), soundId: \(soundId.rawValue))"
    case .getSoundboardSoundGuild(let soundId, let guildId):
      return
        "getSoundboardSoundGuild(soundId: \(soundId.rawValue), guildId: \(guildId.rawValue))"
    case .sendSoundboardSound(let channelId):
      return "sendSoundboardSound(channelId: \(channelId.rawValue))"
    case .getStickerPacks: return "getStickerPacks"
    case .getStickerPack(let stickerPackId):
      return "getStickerPack(stickerPackId: \(stickerPackId.rawValue))"
    case .getStickerGuild(let stickerId):
      return "getStickerGuild(stickerId: \(stickerId.rawValue))"
    case .getUserProfile(
      let userId,
      let withMutualGuilds,
      let withMutualFriends,
      let withMutualFriendsCount,
      let guildId
    ):
      return
        "getUserProfile(userId: \(userId.rawValue), withMutualGuilds: \(withMutualGuilds), withMutualFriends: \(withMutualFriends), withMutualFriendsCount: \(withMutualFriendsCount), guildId: \(guildId?.rawValue ?? "nil"))"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var specialisedRatelimit: (maxRequests: Int, for: Duration)? {
    switch self {
    default: return nil
    }
  }
}
