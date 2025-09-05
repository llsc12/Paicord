//
//  DiscordClient+UserAPIEndpoint.swift
//  DiscordClientLib
//
//  Created by Lakhan Lothiyi on 03/09/2025.
//

import DiscordModels
import NIOHTTP1

extension DiscordClient {
  // MARK: User Authentication
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
    login: String,
    password: String,
    undelete: Bool = false,
    fingerprint: String
  ) async throws -> DiscordClientResponse<UserAuthentication> {
	let endpoint = UserAPIEndpoint.userLogin
    return try await self.send(
      request: .init(
        to: endpoint,
        headers: [
          "X-Fingerprint": fingerprint
        ]),
      payload: Payloads.Authentication(
        login: login,
        password: .init(password),
        undelete: undelete
      )
    )
  }
  
  /// Sends a multi-factor authentication code to the user's phone number for verification.
  /// https://docs.discord.food/authentication#send-mfa-sms
  @inlinable
  public func verifySendSMS(
	fingerprint: String,
	ticket: Secret
  ) async throws -> DiscordClientResponse<UserAuthenticationMFASMS> {
	let endpoint = UserAPIEndpoint.verifySendSMS
	return try await self.send(
	  request: .init(
		to: endpoint,
		headers: [
		  "X-Fingerprint": fingerprint
		]),
	  payload: Payloads.AuthenticationMFASendSMS(
		ticket: ticket
	  )
	)
  }
  
  /// Verifies a multi-factor login and retrieves an authentication token using the specified authenticator type.
  /// https://docs.discord.food/authentication#verify-mfa-login
  @inlinable
  public func verifyMFALogin(
	type: Payloads.AuthenticationMFA.MFAType,
	code: String,
	ticket: Secret,
	fingerprint: String
  ) async throws -> DiscordClientResponse<UserAuthentication> {
	let endpoint = UserAPIEndpoint.verifyMFALogin(type: type)
	return try await self.send(
	  request: .init(
		to: endpoint,
		headers: [
		  "X-Fingerprint": fingerprint
		]),
	  payload: Payloads.AuthenticationMFA(
		code: code,
		ticket: ticket
	  )
	)
  }
  
  /// Returns up to 50 of the user's active authentication sessions.
  /// https://docs.discord.food/authentication#get-auth-sessions
  @inlinable
  public func getAuthSessions() async throws -> DiscordClientResponse<UserAuthenticationSessions> {
	let endpoint = UserAPIEndpoint.getAuthSessions
	return try await self.send(request: .init(to: endpoint))
  }
  
  
}
