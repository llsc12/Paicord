//
//  DiscordClient+UserAPIEndpoint.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 03/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import DiscordModels
import NIOHTTP1

extension DiscordClient {
  // MARK: - Authentication
  /// https://docs.discord.food/authentication

  /// Returns the user experiment assignments and optionally guild experiment rollouts for the user or fingerprint.
  /// https://docs.discord.food/topics/experiments#get-experiment-assignments
  @inlinable
  public func getExperiments()
    async throws -> DiscordClientResponse<FingerprintExperiments>
  {
    let endpoint = UserAPIEndpoint.getExperiments
    return try await self.send(request: .init(to: endpoint))
  }

  /// Retrieves an authentication token for the given credentials.
  /// https://docs.discord.food/authentication#login-account
  @inlinable
  public func userLogin(
    payload: Payloads.Authentication,
    fingerprint: String
  ) async throws -> DiscordClientResponse<UserAuthentication> {
    let endpoint = UserAPIEndpoint.userLogin
    return try await self.send(
      request: .init(
        to: endpoint,
        headers: [
          "X-Fingerprint": fingerprint
        ]
      ),
      payload: payload
    )
  }

  /// Sends a multi-factor authentication code to the user's phone number for verification.
  /// https://docs.discord.food/authentication#send-mfa-sms
  @inlinable
  public func verifySendSMS(
    ticket: Secret,
    fingerprint: String
  ) async throws -> DiscordClientResponse<UserAuthenticationMFASMS> {
    let endpoint = UserAPIEndpoint.verifySendSMS
    return try await self.send(
      request: .init(
        to: endpoint,
        headers: [
          "X-Fingerprint": fingerprint
        ]
      ),
      payload: Payloads.AuthenticationMFASendSMS(
        ticket: ticket
      )
    )
  }

  /// Verifies a multi-factor login and retrieves an authentication token using the specified authenticator type.
  /// https://docs.discord.food/authentication#verify-mfa-login
  @inlinable
  public func verifyMFALogin(
    type: Payloads.MFASubmitData.MFAKind,
    payload: Payloads.AuthenticationMFA,
    fingerprint: String
  ) async throws -> DiscordClientResponse<UserAuthentication> {
    let endpoint = UserAPIEndpoint.verifyMFALogin(type: type)
    return try await self.send(
      request: .init(
        to: endpoint,
        headers: [
          "X-Fingerprint": fingerprint
        ]
      ),
      payload: payload
    )
  }

  /// Returns up to 50 of the user's active authentication sessions.
  /// https://docs.discord.food/authentication#get-auth-sessions
  @inlinable
  public func getAuthSessions() async throws -> DiscordClientResponse<
    UserAuthenticationSessions
  > {
    let endpoint = UserAPIEndpoint.getAuthSessions
    return try await self.send(request: .init(to: endpoint))
  }

  /// Invalidates a list of authentication sessions. Returns a 204 empty response on success.
  /// NOTE: Requires MFA, hence you may receive an error and need to decode that for MFA Request object.
  /// https://docs.discord.food/authentication#logout-auth-sessions
  @inlinable
  public func logoutAuthSessions(_ sessionIdHashes: [String]) async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.logoutAuthSessions
    return try await self.send(
      request: .init(to: endpoint),
      payload: Payloads.LogoutSessions(session_id_hashes: sessionIdHashes)
    )
  }

  /// Initiates the password reset process for the given email or phone number. Returns a 204 empty response on success.
  /// https://docs.discord.food/authentication#forgot-password
  @inlinable
  public func forgotPassword(
    payload: Payloads.ForgotPassword,
    fingerprint: String
  ) async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.forgotPassword
    return try await self.send(
      request: .init(
        to: endpoint,
        headers: [
          "X-Fingerprint": fingerprint
        ]
      ),
      payload: payload
    )
  }

  /// Verifies a user's identity using multi-factor authentication. On success, returns a cookie that can be used to bypass MFA for the next 5 minutes.
  /// https://docs.discord.food/authentication#verify-mfa
  @inlinable
  public func verifyMFA(
    payload: Payloads.MFASubmitData
  ) async throws -> DiscordClientResponse<MFAResponse> {
    let endpoint = UserAPIEndpoint.verifyMFA
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  // MARK: - Applications
  /// https://docs.discord.food/resources/application

  /// Returns a list of application objects that the current user has.
  /// https://docs.discord.food/resources/application#get-applications
  @inlinable
  public func getApplications(withTeamApplications: Bool = false) async throws
    -> DiscordClientResponse<[PartialApplication]>
  {
    let endpoint = UserAPIEndpoint.getApplications(
      withTeamApplications: withTeamApplications
    )
    return try await self.send(request: .init(to: endpoint))
  }

  /// Returns a list of application objects that the current user has, additionally including the application's assets.
  /// https://docs.discord.food/resources/application#get-applications-with-assets
  @inlinable
  public func getApplicationsWithAssets(withTeamApplications: Bool = false)
    async throws -> DiscordClientResponse<
      [PartialApplication]
    >
  {
    let endpoint = UserAPIEndpoint.getApplicationsWithAssets(
      withTeamApplications: withTeamApplications
    )
    return try await self.send(request: .init(to: endpoint))
  }

  /// Returns the embedded activities available globally or in a particular guild.
  /// https://docs.discord.food/resources/application#get-embedded-activities
  @inlinable
  public func getEmbeddedActivities(guildID: GuildSnowflake) async throws
    -> DiscordClientResponse<EmbeddedActivities>
  {
    let endpoint = UserAPIEndpoint.getEmbeddedActivities(guildId: guildID)
    return try await self.send(request: .init(to: endpoint))
  }

  /// Returns a list of partial application objects for the given IDs.
  /// https://docs.discord.food/resources/application#get-partial-applications
  @inlinable
  public func getPartialApplications(applicationIDs: [ApplicationSnowflake])
    async throws -> DiscordClientResponse<[PartialApplication]>
  {
    let endpoint = UserAPIEndpoint.getPartialApplications(ids: applicationIDs)
    return try await self.send(request: .init(to: endpoint))
  }

  /// Returns a partial application object for the given ID with all public application fields.
  /// https://docs.discord.food/resources/application#get-partial-application
  @inlinable
  public func getPartialApplication(
    applicationID: ApplicationSnowflake,
    withGuild: Bool = false
  ) async throws -> DiscordClientResponse<PartialApplication> {
    let endpoint = UserAPIEndpoint.getPartialApplication(
      id: applicationID,
      withGuild: withGuild
    )
    return try await self.send(request: .init(to: endpoint))
  }

  // /// Returns a list of detectable application objects representing games that can be detected by Discord for rich presence.
  // /// https://docs.discord.food/resources/application#get-detectable-applications
  //  @inlinable
  //  func getDetectableApplications() async throws -> DiscordClientResponse<[PartialApplication]> {
  //    let endpoint = UserAPIEndpoint.getDetectableApplications
  //    return try await self.send(request: .init(to: endpoint))
  //  }

  // MARK: - Auto Moderation

  /// Validates a potential rule request's schema for the guild. Requires the MANAGE_GUILD permission.
  /// https://docs.discord.food/resources/auto-moderation#validate-guild-automod-rule
  @inlinable
  public func validateAutoModRule(
    guildID: GuildSnowflake,
    payload: Payloads.AutoModTriggerMetadata
  ) async throws -> DiscordClientResponse<Payloads.AutoModTriggerMetadata> {
    let endpoint = UserAPIEndpoint.validateAutoModRule(guildId: guildID)
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  /// Executes an alert action on an AutoMod alert. Requires the `MANAGE_GUILD` permission. Returns a 204 empty response on success. Fires a Message Update Gateway event.
  /// https://docs.discord.food/resources/auto-moderation#execute-automod-alert-action
  @inlinable
  public func executeAutoModAlertAction(
    guildID: GuildSnowflake,
    payload: Payloads.ExecuteAutoModAlertAction
  ) async throws -> DiscordHTTPResponse {
    let endpoint = UserAPIEndpoint.executeAutoModAlertAction(guildId: guildID)
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  // MARK: - Emoji

  /// Returns the most-used emojis for the given guild.
  /// https://docs.discord.food/resources/emoji#get-guild-top-emojis
  @inlinable
  public func getGuildTopEmojis(guildID: GuildSnowflake) async throws
    -> DiscordClientResponse<[Guild.TopEmoji]>
  {
    let endpoint = UserAPIEndpoint.getGuildTopEmojis(guildId: guildID)
    return try await self.send(request: .init(to: endpoint))
  }

  // MARK: - Invites

  /// Accepts an invite to a guild, group DM, or DM. Returns an invite object on success. May fire a Guild Create, Guild Member Add, Guild Join Request Create, Channel Create, and/or Relationship Add Gateway event.
  /// https://docs.discord.food/resources/invite#accept-invite
  @inlinable
  public func acceptInvite(code: String, payload: Payloads.AcceptInvite)
    async throws -> DiscordClientResponse<Invite>
  {
    let endpoint = UserAPIEndpoint.acceptInvite(code: code)
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  /// Returns a list of friend invite objects (with invite metadata) for the current user.
  /// https://docs.discord.food/resources/invite#get-user-invites
  @inlinable
  public func getUserInvites() async throws -> DiscordClientResponse<
    [InviteWithMetadata]
  > {
    let endpoint = UserAPIEndpoint.getUserInvites
    return try await self.send(request: .init(to: endpoint))
  }

  /// Creates a new friend invite. Returns a friend invite object (with invite metadata) on success.
  /// https://docs.discord.food/resources/invite#create-user-invite
  @inlinable
  public func createUserInvite(payload: Payloads.CreateUserInvite) async throws
    -> DiscordClientResponse<InviteWithMetadata>
  {
    let endpoint = UserAPIEndpoint.createUserInvite
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  /// Revokes all of the current user's friend invites. Returns a list of revoked friend invite objects (with invite metadata) on success.
  /// https://docs.discord.food/resources/invite#revoke-user-invites
  @inlinable
  public func revokeUserInvites() async throws -> DiscordClientResponse<
    [InviteWithMetadata]
  > {
    let endpoint = UserAPIEndpoint.revokeUserInvites
    return try await self.send(request: .init(to: endpoint))
  }

  // MARK: - Relationships

  /// Returns a list of relationship objects for the current user.
  /// https://docs.discord.food/resources/relationships#get-relationships
  @inlinable
  public func getRelationships() async throws -> DiscordClientResponse<
    [DiscordRelationship]
  > {
    let endpoint = UserAPIEndpoint.getRelationships
    return try await self.send(request: .init(to: endpoint))
  }

  /// Sends a friend request to another user, which can be accepted by creating a new relationship of type FRIEND. Returns a 204 empty response on success. Fires a Relationship Add Gateway event.
  /// https://docs.discord.food/resources/relationships#send-friend-request
  @inlinable
  public func sendFriendRequest(payload: Payloads.SendFriendRequest)
    async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.sendFriendRequest
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  /// Creates a relationship with another user. Returns a 204 empty response on success. Fires a Relationship Add Gateway event.
  /// https://docs.discord.food/resources/relationships#create-relationship
  @inlinable
  public func createRelationship(
    userID: UserSnowflake,
    payload: Payloads.CreateRelationship
  )
    async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.createRelationship(userId: userID)
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  /// Ignores a user. Returns a 204 empty response on success. Fires a Relationship Add or Relationship Update Gateway event.
  /// https://docs.discord.food/resources/relationships#ignore-user
  @inlinable
  public func ignoreUser(userID: UserSnowflake) async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.ignoreUser(userId: userID)
    return try await self.send(
      request: .init(to: endpoint)
    )
  }

  /// Unignores a user. Returns a 204 empty response on success. Fires a Relationship Update or Relationship Remove Gateway event.
  /// https://docs.discord.food/resources/relationships#unignore-user
  @inlinable
  public func unignoreUser(userID: UserSnowflake) async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.unignoreUser(userId: userID)
    return try await self.send(
      request: .init(to: endpoint)
    )
  }

  /// Modifies a relationship to another user. Returns a 204 empty response on success. Fires a Relationship Update Gateway event.
  /// https://docs.discord.food/resources/relationships#modify-relationship
  @inlinable
  public func modifyRelationship(
    userID: UserSnowflake,
    payload: Payloads.ModifyRelationship
  ) async throws -> DiscordHTTPResponse {
    let endpoint = UserAPIEndpoint.modifyRelationship(userId: userID)
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  /// Removes a relationship with another user. Returns a 204 empty response on success. Fires a Relationship Remove Gateway event.
  /// https://docs.discord.food/resources/relationships#remove-relationship
  @inlinable
  public func removeRelationship(userID: UserSnowflake) async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.removeRelationship(userId: userID)
    return try await self.send(
      request: .init(to: endpoint)
    )
  }

  /// Removes multiple relationships. Returns a 204 empty response on success. May fire multiple Relationship Remove Gateway events.
  /// https://docs.discord.food/resources/relationships#bulk-remove-relationships
  @inlinable
  public func bulkRemoveRelationships(
    relationshipType: DiscordRelationship.Kind = .incomingRequest,
    payload: Payloads.BulkRemoveRelationships
  ) async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.bulkRemoveRelationships(
      type: relationshipType
    )
    return try await self.send(
      request: .init(to: endpoint)
    )
  }

  /// Adds multiple relationships from contact sync. May fire multiple Relationship Add Gateway events.
  /// https://docs.discord.food/resources/relationships#bulk-add-relationships
  @inlinable
  public func bulkAddRelationships(payload: Payloads.BulkAddRelationships)
    async throws -> DiscordClientResponse<BulkAddRelationshipsResult>
  {
    let endpoint = UserAPIEndpoint.bulkAddRelationships
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  /// Returns a list of friend suggestion objects for the current user.
  /// https://docs.discord.food/resources/relationships#get-friend-suggestions
  @inlinable
  public func getFriendSuggestions() async throws -> DiscordClientResponse<
    FriendSuggestions
  > {
    let endpoint = UserAPIEndpoint.getFriendSuggestions
    return try await self.send(request: .init(to: endpoint))
  }

  /// Removes a friend suggestion for the current user. Returns a 204 empty response on success. Fires a Friend Suggestion Delete Gateway event.
  /// https://docs.discord.food/resources/relationships#remove-friend-suggestion
  @inlinable
  public func removeFriendSuggestion(userID: UserSnowflake) async throws
    -> DiscordHTTPResponse
  {
    let endpoint = UserAPIEndpoint.removeFriendSuggestion(userId: userID)
    return try await self.send(
      request: .init(to: endpoint)
    )
  }

  /// Returns a list of soundboard sound objects that can be used by all users.
  /// https://docs.discord.food/resources/soundboard#get-default-soundboard-sounds
  @inlinable
  public func getDefaultSoundboardSounds() async throws
    -> DiscordClientResponse<
      Gateway.SoundboardSounds
    >
  {
    let endpoint = UserAPIEndpoint.getDefaultSoundboardSounds
    return try await self.send(request: .init(to: endpoint))
  }

  /// Returns an object containing a list of soundboard sound objects for the given guild. Includes the user field if the user has the `CREATE_EXPRESSIONS` or `MANAGE_EXPRESSIONS` permission.
  /// https://docs.discord.food/resources/soundboard#get-guild-soundboard-sounds
  @inlinable
  public func getGuildSoundboardSounds(guildID: GuildSnowflake) async throws
    -> DiscordClientResponse<
      Gateway.SoundboardSounds
    >
  {
    let endpoint = UserAPIEndpoint.getGuildSoundboardSounds(guildId: guildID)
    return try await self.send(request: .init(to: endpoint))
  }

  /// Returns a soundboard sound object for the given guild and sound ID. Includes the user field if the user has the `CREATE_EXPRESSIONS` or `MANAGE_EXPRESSIONS` permission.
  /// https://docs.discord.food/resources/soundboard#get-guild-soundboard-sound
  @inlinable
  public func getGuildSoundboardSound(
    guildID: GuildSnowflake,
    soundID: SoundSnowflake
  ) async throws -> DiscordClientResponse<
    SoundboardSound
  > {
    let endpoint = UserAPIEndpoint.getGuildSoundboardSound(
      guildId: guildID,
      soundId: soundID
    )
    return try await self.send(request: .init(to: endpoint))
  }

  //  /// Creates a new soundboard sound for the guild. Requires the `CREATE_EXPRESSIONS` permission. Returns the new soundboard sound object on success. Fires a Guild Soundboard Sound Create Gateway event.
  //  /// https://docs.discord.food/resources/soundboard#create-guild-soundboard-sound
  //  @inlinable
  //  public func createGuildSoundboardSound(

  //  /// Modifies the given soundboard sound. For sounds created by the current user, requires either the `CREATE_EXPRESSIONS` or `MANAGE_EXPRESSIONS` permission. For other sounds, requires the `MANAGE_EXPRESSIONS` permission. Returns the updated soundboard sound object on success. Fires a Guild Soundboard Sound Update Gateway event.
  //  /// https://docs.discord.food/resources/soundboard#modify-guild-soundboard-sound
  //  @inlinable
  //  public func modifyGuildSoundboardSound(

  /// For sounds created by the current user, requires either the `CREATE_EXPRESSIONS` or `MANAGE_EXPRESSIONS` permission. For other sounds, requires the `MANAGE_EXPRESSIONS` permission. Returns a 204 empty response on success. Fires a Guild Soundboard Sound Delete Gateway event.
  /// https://docs.discord.food/resources/soundboard#delete-guild-soundboard-sound
  @inlinable
  public func deleteGuildSoundboardSound(
    guildID: GuildSnowflake,
    soundID: SoundSnowflake
  ) async throws -> DiscordHTTPResponse {
    let endpoint = UserAPIEndpoint.deleteGuildSoundboardSound(
      guildId: guildID,
      soundId: soundID
    )
    return try await self.send(
      request: .init(to: endpoint)
    )
  }

  //  /// Returns a discoverable guild object for the guild that owns the given sound. This endpoint requires the guild to be discoverable, not be auto-removed, and have guild expression discoverability enabled.
  //  /// https://docs.discord.food/resources/soundboard#get-soundboard-sound-guild
  //  @inlinable
  //  public func getSoundboardSoundGuild(
  //    soundID: SoundSnowflake
  //  ) async throws -> DiscordClientResponse<

  /// Sends a soundboard sound to a voice channel. Returns a 204 empty response on success. Fires a Voice Channel Effect Send Gateway event.
  /// NOTE: Sending a soundboard sound requires the current user to be connected to the voice channel. The user cannot be server muted, deafened, or suppressed.
  /// https://docs.discord.food/resources/soundboard#send-soundboard-sound
  @inlinable
  public func sendSoundboardSound(
    channelID: ChannelSnowflake,
    payload: Payloads.SendSoundboardSound
  ) async throws -> DiscordHTTPResponse {
    let endpoint = UserAPIEndpoint.sendSoundboardSound(channelId: channelID)
    return try await self.send(
      request: .init(to: endpoint),
      payload: payload
    )
  }

  // MARK: - Stickers

  /// Returns the list of sticker packs available to use.
  /// https://docs.discord.food/resources/sticker#get-sticker-packs
  @inlinable
  public func getStickerPacks() async throws -> DiscordClientResponse<
    Responses.ListStickerPacks
  > {
    let endpoint = UserAPIEndpoint.getStickerPacks
    return try await self.send(request: .init(to: endpoint))
  }

  /// Returns a sticker pack object for the given pack ID.
  /// https://docs.discord.food/resources/sticker#get-sticker-pack
  @inlinable
  public func getStickerPack(packID: StickerPackSnowflake) async throws
    -> DiscordClientResponse<StickerPack>
  {
    let endpoint = UserAPIEndpoint.getStickerPack(stickerPackId: packID)
    return try await self.send(request: .init(to: endpoint))
  }

  //  /// Returns a discoverable guild object for the guild that owns the given sticker. This endpoint requires the guild to be discoverable, not be auto-removed, and have guild expression discoverability enabled.
  //  /// https://docs.discord.food/resources/sticker#get-sticker-guild
  //  @inlinable
  //  public func getStickerGuild(
  //    stickerID: StickerSnowflake
  //  ) async throws -> DiscordClientResponse<

  // MARK: - Users

  /// Returns a user profile object for a given user ID.
  /// Warning: This endpoint requires one of the following:
  /// - The user is a bot
  /// - The user shares a mutual guild with the current user
  /// - The user is a friend of the current user
  /// - The user is a friend suggestion of the current user
  /// - The user has an outgoing friend request to the current user
  /// - A valid join_request_id is provided
  /// https://docs.discord.food/resources/user#get-user-profile
  @inlinable
  public func getUserProfile(
    userID: UserSnowflake,
    withMutualGuilds: Bool,
    withMutualFriends: Bool,
    withMutualFriendsCount: Bool,
    guildID: GuildSnowflake? = nil
      //    , joinRequestID: AnySnowflake? = nil
  ) async throws -> DiscordClientResponse<DiscordUser.Profile> {
    let endpoint = UserAPIEndpoint.getUserProfile(
      userId: userID,
      withMutualGuilds: withMutualGuilds,
      withMutualFriends: withMutualFriends,
      withMutualFriendsCount: withMutualFriendsCount,
      guildId: guildID
    )
    return try await self.send(request: .init(to: endpoint))
  }
}
