//
//  Extensions.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 08/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Foundation

// MARK: - Protos for encode decode from base64 strings
extension DiscordProtos_DiscordUsers_V1_PreloadedUserSettings: Codable {
	public func encode(to encoder: any Encoder) throws {
		let data = try self.serializedData()
		let protoBase64String = data.base64EncodedString()
		var container = encoder.singleValueContainer()
		try container.encode(protoBase64String)
	}

	public init(from decoder: any Decoder) throws {
		let protoBase64String =
			try decoder
			.singleValueContainer()
			.decode(String.self)
		if let data = Data(base64Encoded: protoBase64String) {
			self = try Self(
				serializedBytes: data
			)
		} else {
			self = .init()
			return
		}
	}
}
extension DiscordProtos_DiscordUsers_V1_FrecencyUserSettings: Codable {
	public func encode(to encoder: any Encoder) throws {
		let data = try self.serializedData()
		let protoBase64String = data.base64EncodedString()
		var container = encoder.singleValueContainer()
		try container.encode(protoBase64String)
	}

	public init(from decoder: any Decoder) throws {
		let protoBase64String =
			try decoder
			.singleValueContainer()
			.decode(String.self)
		if let data = Data(base64Encoded: protoBase64String) {
			self = try Self(
				serializedBytes: data
			)
		} else {
			self = .init()
			return
		}
	}
}
