/// Must not import `DiscordModels` as `@testable` to make sure
/// these tests are run using `public` declarations.
@_spi(UserInstallableApps) import DiscordModels
import XCTest

class DecodeToleranceTests: XCTestCase {

    typealias IntegrationKindConfiguration = DiscordApplication.IntegrationKindConfiguration
    typealias IntegrationKind = DiscordApplication.IntegrationKind

    /// Test that collections of raw-representable codable enums
    /// don't fail on decoding unknown values.
    func testNoThrowEnums() throws {
        do {
            let text = """
                {
                    "value": [
                        1,
                        2,
                        3,
                        500
                    ]
                }
                """

            /// The values include `500` which is not in `DiscordChannel.Kind`.
            /// Decoding the `500` normally fails, but based on our `UnstableEnum` macro,
            /// this should never fail.
            let decoded = try JSONDecoder().decode(
                TestContainer<[DiscordChannel.Kind]>.self,
                from: Data(text.utf8)
            ).value
            XCTAssertEqual(decoded.count, 4)
        }

        do {
            let text = """
                {
                    "value": [
                        "online",
                        "dnd",
                        "bothOfflineAndOnlineWhichIsInvalid",
                        "idle",
                        "offline"
                    ]
                }
                """

            /// Refer to the comment above for some explanations.
            let decoded = try JSONDecoder().decode(
                TestContainer<[Gateway.Status]>.self,
                from: Data(text.utf8)
            ).value
            XCTAssertEqual(decoded.count, 5)
        }

        do {
            let text = """
                {
                    "scopes": [
                        "something.completely.new",
                        "activities.read",
                        "activities.write",
                        "applications.builds.read",
                        "applications.builds.upload",
                        "applications.commands"
                    ],
                    "permissions": "15"
                }
                """

            /// Refer to the comment above for some explanations.
            let decoded = try JSONDecoder().decode(
                DiscordApplication.InstallParams.self,
                from: Data(text.utf8)
            )
            XCTAssertEqual(decoded.scopes.count, 6)
            XCTAssertEqual(decoded.permissions.rawValue, 15)
        }

        do {
            let text = #"{"value":["BadFeature"]}"#
            _ = try JSONDecoder().decode(TestContainer<[Guild.Feature]>.self, from: Data(text.utf8))
        }

        do {
            let text =
                #"[{"id":"1036881950696288277","name":"DiscordBM Test Server","icon":null,"owner":false,"permissions":"140737488355327","features":["NEWS","COMMUNITY","GUILD_ONBOARDING_HAS_PROMPTS","GUILD_ONBOARDING_EVER_ENABLED","GUILD_SERVER_GUIDE","GUILD_ONBOARDING"]}]"#
            _ = try JSONDecoder().decode([PartialGuild].self, from: Data(text.utf8))
        }
    }

    func testCodingKeyRepresentableDictKey() throws {
        let text = """
            {
               "value":{
                  "0":{
                     "oauth2_install_params":{
                        "scopes":[
                           "applications.commands",
                           "bot"
                        ],
                        "permissions":"2048"
                     }
                  },
                  "1":{
                     "oauth2_install_params":{
                        "scopes":[
                           "applications.commands"
                        ],
                        "permissions":"4"
                     }
                  }
               }
            }
            """

        let container = try JSONDecoder().decode(
            TestContainer<[IntegrationKind: IntegrationKindConfiguration]>.self,
            from: Data(text.utf8)
        )

        let value = try XCTUnwrap(container.value)

        XCTAssertEqual(value.count, 2)
        let firstOAuthInstallParams = try XCTUnwrap(value.values.first?.oauth2_install_params)
        XCTAssertGreaterThan(firstOAuthInstallParams.permissions.rawValue, 0)
    }
}

private struct TestContainer<C: Codable>: Codable {
    var value: C
}
