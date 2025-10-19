//
//  UsrGatewayTests.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 26/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Logging
import PaicordLib
import XCTest

class UserGatewayTests: XCTestCase {
	func testGateway() async throws {
		// insane logging pls dont use
		DiscordGlobalConfiguration.makeLogger = { loggerLabel in
			var logger = Logger(label: loggerLabel)
			logger.logLevel = .trace
			return logger
		}

		let gateway = await UserGatewayManager(
			token:"redacted"
		)

		await gateway.connect()

		for await event in await gateway.events {
			print(event, "\n")
		}
	}

	func testFormErrorDecode() throws {
		let data = """
			{
				"message": "Invalid Form Body",
				"code": 50035,
				"errors": {
					"login": {
						"_errors": [{
							"code": "EMAIL_DOES_NOT_EXIST",
							"message": "Email does not exist."
						}]
					}
				}
			}
			""".data(using: .utf8)!

		let error = try DiscordGlobalConfiguration.decoder.decode(JSONError.self, from: data)
		print(error)
	}
	
	func testSuperPropertiesGeneration() {
		let properties = Gateway.Identify.ConnectionProperties.init(ws: false)
		let data = try! DiscordGlobalConfiguration.encoder.encode(properties)
		let json = String(data: data, encoding: .utf8)!
		print(json)
	}
}

extension IntBitField where R: CaseIterable {
	var descriptionMembers: String {
		R.allCases
			.filter { self.contains($0) }
			.map { "\($0)" }
			.joined(separator: ", ")
	}
}
