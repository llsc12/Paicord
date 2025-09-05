//
//  User Authentication.swift
//  DiscordClientLib
//
//  Created by Lakhan Lothiyi on 03/09/2025.
//

public struct UserAuthenticationSessions: Sendable, Codable {
  public var user_sessions: [Session]
  
  public struct Session: Sendable, Codable {
	public var id_hash: String
	public var approx_last_used_time: DiscordTimestamp
	public var client_info: ClientInfo
	
	public struct ClientInfo: Sendable, Codable {
	  public var os: String?
	  public var platform: String?
	  public var location: String?
	}
  }
}

public struct UserAuthentication: Sendable, Codable {
  public var user_id: UserSnowflake
  public var token: Secret?
  public var ticket: Secret?
  
  public var totp: Bool?
  public var sms: Bool?
  public var mfa: Bool?
  public var backup: Bool?
}

public struct FingerprintExperiments: Sendable, Codable {
  public var fingerprint: String?
//  public var assignments
//  public var guild_experiments
}

public struct UserAuthenticationMFASMS: Sendable, Codable {
  public var phone: String
}
