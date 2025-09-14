//
//  MFAVerificationData.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 11/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

public typealias MFAVerificationHandler = @Sendable (MFAVerificationData)
	async -> (MFAResponse?)

// returned object when a user needs to complete MFA
public struct MFAVerificationData: Sendable, Codable, Identifiable {
	public var id: String { ticket.value }
	
	public var ticket: Secret
	public var methods: [MFAMethod]
	
	public init(ticket: Secret, methods: [MFAMethod]) {
		self.ticket = ticket
		self.methods = methods
	}
	
	public struct MFAMethod: Sendable, Codable {
		public var type: MFAKind
		public var challenge: String? // webauthn
		public var backup_codes_allowed: Bool? // this is not nil when its totp
		
		public init(type: MFAKind, backup_codes_allowed: Bool? = nil) {
			self.type = type
			self.backup_codes_allowed = backup_codes_allowed
		}
		
		// this type is received. an MFA type in Payloads has the sendable type with rawValue String
		@UnstableEnum<String>
		public enum MFAKind: Sendable, Codable {
			case totp // totp
			case sms // sms
			case backup // backup
			case webauthn // webauthn
			case password // password
			case __undocumented(String)
		}
	}
}

// they respond with this on successful mfa
public struct MFAResponse: Sendable, Codable {
	public var token: String
}
