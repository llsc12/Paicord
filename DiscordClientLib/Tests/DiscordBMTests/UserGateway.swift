//
//  UserGateway.swift
//  DiscordClientLib
//
//  Created by Lakhan Lothiyi on 26/08/2025.
//

import DiscordClientLib
import Logging
import XCTest

class UserGatewayTests: XCTestCase {

	func testGateway() async throws {
		//		DiscordGlobalConfiguration.makeLogger = { loggerLabel in
		//			var logger = Logger(label: loggerLabel)
		//			logger.logLevel = .trace
		//			return logger
		//		}

		let gateway = await UserGatewayManager(
			token:
				"redacted"
		)
		//		let client = gateway.client

		await gateway.connect()

		for await event in await gateway.events {
			print(event, "\n")
		}
	}

	func testSuperProperties() {
	  print(SuperProperties.GenerateSuperPropertiesHeader())
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
