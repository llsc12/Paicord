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
    XCTAssertEqual(error.errors?.fieldErrors["login"]?.first?.code, "EMAIL_DOES_NOT_EXIST")
    XCTAssertEqual(error.errors?.fieldErrors["login"]?.first?.message, "Email does not exist.")
  }

  func testFormErrorDecodePreservesValidSiblings() throws {
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
          },
          "metadata": {
            "_errors": "invalid"
          }
        }
      }
      """.data(using: .utf8)!

    let error = try DiscordGlobalConfiguration.decoder.decode(JSONError.self, from: data)

    XCTAssertEqual(error.errors?.fieldErrors["login"]?.first?.code, "EMAIL_DOES_NOT_EXIST")
    XCTAssertNil(error.errors?.fieldErrors["metadata"])
  }

  func testGatewayControlPayloads() throws {
    let heartbeat = try DiscordGlobalConfiguration.decoder.decode(
      Gateway.Event.self,
      from: Data(#"{"op":1,"d":1788700476353}"#.utf8)
    )
    let reconnect = try DiscordGlobalConfiguration.decoder.decode(
      Gateway.Event.self,
      from: Data(#"{"op":7}"#.utf8)
    )
    let acknowledged = try DiscordGlobalConfiguration.decoder.decode(
      Gateway.Event.self,
      from: Data(#"{"op":11,"d":null}"#.utf8)
    )

    XCTAssertEqual(heartbeat.opcode, .heartbeat)
    XCTAssertNil(heartbeat.data)
    XCTAssertEqual(reconnect.opcode, .reconnect)
    XCTAssertNil(reconnect.data)
    XCTAssertEqual(acknowledged.opcode, .heartbeatAccepted)
    XCTAssertNil(acknowledged.data)
  }

  func testTimestampFormats() throws {
    let decoder = DiscordGlobalConfiguration.decoder
    let fractional = try decoder.decode(
      DiscordTimestamp.self,
      from: Data(#""2024-06-18T21:52:05.463000+00:00""#.utf8)
    )
    let wholeSeconds = try decoder.decode(
      DiscordTimestamp.self,
      from: Data(#""2024-06-18T21:52:05Z""#.utf8)
    )

    XCTAssertEqual(fractional.date.timeIntervalSince1970, 1_718_747_525.463, accuracy: 0.001)
    XCTAssertEqual(wholeSeconds.date.timeIntervalSince1970, 1_718_747_525, accuracy: 0.001)
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
