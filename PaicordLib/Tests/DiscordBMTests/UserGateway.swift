//
//  UserGateway.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 26/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import Logging
import XCTest

class UserGatewayTests: XCTestCase {
  func testGateway() async throws {
//    DiscordGlobalConfiguration.makeLogger = { loggerLabel in
//      var logger = Logger(label: loggerLabel)
//      logger.logLevel = .trace
//      return logger
//    }

    let gateway = await UserGatewayManager(
      token:
        "OTMzMTI0MzIzMDM4ODU5MzE1.GgHeou.k7b3Ar40tj4Qr4v0hSoBnV15yKoNRLnW3uDRqs"
    )

    await gateway.connect()

    for await event in await gateway.events {
      print(event, "\n")
    }
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
