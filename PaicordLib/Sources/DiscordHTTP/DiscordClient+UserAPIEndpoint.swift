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
    payload: Payloads.Authentication,
		fingerprint: String
	) async throws -> DiscordClientResponse<UserAuthentication> {
		let endpoint = UserAPIEndpoint.userLogin
		return try await self.send(
			request: .init(
				to: endpoint,
				headers: [
					"X-Fingerprint": fingerprint
				]),
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
				]),
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
			payload: Payloads.LogoutSessions(session_id_hashes: sessionIdHashes))
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
				]),
      payload: payload)
	}

	/// Verifies a user's identity using multi-factor authentication. On success, returns a cookie that can be used to bypass MFA for the next 5 minutes.
	/// https://docs.discord.food/authentication#verify-mfa
	@inlinable
	public func verifyMFA(
    payload: Payloads.MFASubmitData,
  ) async throws -> DiscordClientResponse<MFAResponse> {
		let endpoint = UserAPIEndpoint.verifyMFA
		return try await self.send(
			request: .init(to: endpoint),
			payload: payload
		)
	}
}
