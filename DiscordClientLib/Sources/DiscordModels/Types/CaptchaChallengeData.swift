//
//  CaptchaChallengeData.swift
//  DiscordClientLib
//
//  Created by Lakhan Lothiyi on 31/08/2025.
//

import Foundation

public struct CaptchaChallengeData: Sendable {
	public let captchaKey: [String]
	public let captchaService: String
	public let captchaSiteKey: String?
	public let captchaSessionId: String?
	public let captchaRqdata: String?
	public let captchaRqtoken: String?
	public let shouldServeInvisible: Bool?

	public init(
		captchaKey: [String],
		captchaService: String,
		captchaSiteKey: String?,
		captchaSessionId: String?,
		captchaRqdata: String?,
		captchaRqtoken: String?,
        shouldServeInvisible: Bool?
	) {
		self.captchaKey = captchaKey
		self.captchaService = captchaService
		self.captchaSiteKey = captchaSiteKey
		self.captchaSessionId = captchaSessionId
		self.captchaRqdata = captchaRqdata
		self.captchaRqtoken = captchaRqtoken
		self.shouldServeInvisible = shouldServeInvisible
	}
}

public struct CaptchaSubmitData: Sendable {
	public let solutionToken: String
	public let captchaSessionId: String?
	public let captchaRqtoken: String?

	public init(token: String, sessionId: String?, rqtoken: String?) {
		self.solutionToken = token
		self.captchaSessionId = sessionId
		self.captchaRqtoken = rqtoken
	}

	// Convenience init from CaptchaChallengeData
	public init(challenge: CaptchaChallengeData, token: String) {
		self.solutionToken = token
		self.captchaSessionId = challenge.captchaSessionId
		self.captchaRqtoken = challenge.captchaRqtoken
	}
}
