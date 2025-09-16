import DiscordHTTP
import NIOCore
import XCTest

@testable import DiscordModels

class DiscordModelsTests: XCTestCase {

    func testEventDecode() throws {

        do {
            let text = """
                {
                    "t": null,
                    "s": null,
                    "op": 11,
                    "d": null
                }
                """
            let decoded = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
            XCTAssertEqual(decoded.opcode, .heartbeatAccepted)
            XCTAssertEqual(decoded.sequenceNumber, nil)
            XCTAssertEqual(decoded.type, nil)
            XCTAssertTrue(decoded.data == nil)
        }

        do {
            let text = """
                {
                "t": "MESSAGE_CREATE",
                "s": 130,
                "op": 0,
                "d": {
                    "type": 0,
                    "tts": false,
                    "timestamp": "2022-10-07T19:44:07.295000+00:00",
                    "referenced_message": null,
                    "pinned": false,
                    "nonce": "1028029979960541184",
                    "mentions": [],
                    "mention_roles": [],
                    "mention_everyone": false,
                    "member": {
                        "roles": [
                            "431921695524126722"
                        ],
                        "premium_since": null,
                        "pending": false,
                        "nick": null,
                        "mute": false,
                        "joined_at": "2020-04-18T00:10:04.414000+00:00",
                        "flags": 0,
                        "deaf": false,
                        "communication_disabled_until": null,
                        "avatar": null
                    },
                    "id": "1028029980795478046",
                    "flags": 0,
                    "embeds": [],
                    "edited_timestamp": null,
                    "content": "blah bljhshADh blah",
                    "components": [],
                    "channel_id": "435923868503506954",
                    "author": {
                        "username": "GoodUser",
                        "public_flags": 0,
                        "id": "560661188019488714",
                        "discriminator": "4443",
                        "avatar_decoration": null,
                        "avatar": "845407ec1491b55828cc1f91c2436e8b"
                    },
                    "attachments": [],
                    "guild_id": "439103874612675485"
                    }
                }
                """
            let decoded = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
            XCTAssertEqual(decoded.opcode, .dispatch)
            XCTAssertEqual(decoded.sequenceNumber, 130)
            XCTAssertEqual(decoded.type, "MESSAGE_CREATE")
            guard case let .messageCreate(message) = decoded.data else {
                XCTFail("Unexpected data: \(String(describing: decoded.data))")
                return
            }
            XCTAssertEqual(message.type, .default)
            XCTAssertEqual(message.tts, false)
            XCTAssertEqual(message.timestamp.date.timeIntervalSince1970, 1665171847.295)
            XCTAssertTrue(message.referenced_message == nil)
            XCTAssertEqual(message.pinned, false)
            XCTAssertEqual(message.nonce?.asString, "1028029979960541184")
            XCTAssertTrue(message.mentions.isEmpty)
            XCTAssertEqual(message.mention_roles, [])
            XCTAssertEqual(message.mention_everyone, false)
            let member = try XCTUnwrap(message.member)
            XCTAssertEqual(member.roles, ["431921695524126722"])
            XCTAssertEqual(member.premium_since?.date, nil)
            XCTAssertEqual(member.pending, false)
            XCTAssertEqual(member.nick, nil)
            XCTAssertEqual(member.mute, false)
            XCTAssertEqual(member.joined_at?.date.timeIntervalSince1970, 1587168604.414)
            XCTAssertEqual(member.deaf, false)
            XCTAssertEqual(member.communication_disabled_until?.date, nil)
            XCTAssertEqual(member.avatar, nil)
            XCTAssertEqual(message.id, "1028029980795478046")
            XCTAssertEqual(message.flags, [])
            XCTAssertTrue(message.embeds.isEmpty)
            XCTAssertEqual(message.edited_timestamp?.date, nil)
            XCTAssertEqual(message.content, "blah bljhshADh blah")
            XCTAssertTrue(message.components?.isEmpty == true)
            XCTAssertEqual(message.channel_id, "435923868503506954")
            let author = try XCTUnwrap(message.author)
            XCTAssertEqual(author.username, "GoodUser")
            XCTAssertEqual(author.public_flags, [])
            XCTAssertEqual(author.id, "560661188019488714")
            XCTAssertEqual(author.discriminator, "4443")
            XCTAssertEqual(author.avatar, "845407ec1491b55828cc1f91c2436e8b")
            XCTAssertTrue(message.attachments.isEmpty)
            XCTAssertEqual(message.guild_id, "439103874612675485")
        }

        do {
            let text = """
                {
                    "t": "GUILD_AUDIT_LOG_ENTRY_CREATE",
                    "s": 1806139,
                    "op": 0,
                    "d": {
                        "user_id": "159985870458322944",
                        "target_id": "981723329457164289",
                        "id": "1063214083664511006",
                        "changes": [
                            {
                                "old_value": "Online Members: 24",
                                "new_value": "Online Members: 25",
                                "key": "name"
                            }
                        ],
                        "action_type": 11,
                        "guild_id": "964554609010040873"
                    }
                }
                """
            let decoded = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
            XCTAssertEqual(decoded.opcode, .dispatch)
            XCTAssertEqual(decoded.sequenceNumber, 1_806_139)
            XCTAssertEqual(decoded.type, "GUILD_AUDIT_LOG_ENTRY_CREATE")
            guard case let .guildAuditLogEntryCreate(auditLog) = decoded.data else {
                XCTFail("Unexpected data: \(String(describing: decoded.data))")
                return
            }
            XCTAssertEqual(auditLog.changes?.count, 1)
            XCTAssertEqual(auditLog.user_id, "159985870458322944")
            XCTAssertEqual(auditLog.id, "1063214083664511006")
            if case .channelUpdate = auditLog.action {
            } else {
                XCTFail("Unexpected action: \(String(describing: auditLog.action))")
            }
            XCTAssertEqual(auditLog.reason, nil)
        }

        do {
            let text = """
                {
                    "t": "VOICE_STATE_UPDATE",
                    "s": 134275,
                    "op": 0,
                    "d": {
                        "member": {
                            "user": {
                                "username": "djsole18",
                                "public_flags": 0,
                                "id": "984302584959500299",
                                "global_name": null,
                                "display_name": null,
                                "discriminator": "3901",
                                "bot": false,
                                "avatar_decoration": null,
                                "avatar": "561939e4a1550313f5cfdf2bd6dc3732"
                            },
                            "roles": [],
                            "premium_since": null,
                            "pending": false,
                            "nick": null,
                            "mute": false,
                            "joined_at": null,
                            "flags": 16,
                            "deaf": false,
                            "communication_disabled_until": null,
                            "avatar": null
                        },
                        "user_id": "984302584959500299",
                        "suppress": false,
                        "session_id": "8876d2ad2842d6d6e318267227de6eec",
                        "self_video": false,
                        "self_stream": true,
                        "self_mute": false,
                        "self_deaf": false,
                        "request_to_speak_timestamp": null,
                        "mute": false,
                        "guild_id": "1002085020187492383",
                        "deaf": false,
                        "channel_id": "1006294105111920822"
                    }
                }
                """
            _ = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
        }

        do {
            let text =
                #"{"t":"GUILD_AUDIT_LOG_ENTRY_CREATE","s":451,"op":0,"d":{"user_id":"235148962103951360","target_id":"930562427983130635","reason":"Normal reaction role","id":"1170341258422669332","changes":[{"new_value":[{"name":"sahne","id":"1010902088533938188"}],"key":"$add"}],"action_type":25,"guild_id":"922186320275722322"}}"#
            _ = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
        }
    }

    func testImageData() throws {
        typealias ImageData = Payloads.ImageData
        let data = ByteBuffer(data: resource(name: "1kb.png"))

        do {
            let image = ImageData(file: .init(data: data, filename: "1kb.png"))
            let string = image.encodeToString()
            XCTAssertEqual(string, base64EncodedImageString)
        }

        do {
            let file = ImageData.decodeFromString(base64EncodedImageString)
            XCTAssertEqual(file?.data, data)
            XCTAssertEqual(file?.extension, "png")
        }
    }

    func testWebhookAddress() throws {
        let webhookUrl =
            "https://discord.com/api/webhooks/1066287437724266536/dSmCyqTEGP1lBnpWJAVU-CgQy4s3GRXpzKIeHs0ApHm62FngQZPn7kgaOyaiZe6E5wl_"
        let expectedId: WebhookSnowflake = "1066287437724266536"
        let expectedToken = "dSmCyqTEGP1lBnpWJAVU-CgQy4s3GRXpzKIeHs0ApHm62FngQZPn7kgaOyaiZe6E5wl_"

        let address1 = try WebhookAddress.url(webhookUrl)
        XCTAssertEqual(address1.id, expectedId)
        XCTAssertEqual(address1.token, expectedToken)

        let address2 = try WebhookAddress.url(webhookUrl + "/")
        XCTAssertEqual(address2.id, expectedId)
        XCTAssertEqual(address2.token, expectedToken)
    }

    func testReaction() throws {
        XCTAssertNoThrow(try Reaction.unicodeEmoji("❤️"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("✅"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🇮🇷"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("❌"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🆔"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("📲"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🛳️"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🧂"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🌫️"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("👌🏿"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("😀"))
        XCTAssertThrowsError(try Reaction.unicodeEmoji("😀a"))
        XCTAssertThrowsError(try Reaction.unicodeEmoji("😀😀"))
    }

    func testMacroCodableConformance() throws {
        do {
            let json = #"{"some":100}"#
            let data = Data(json.utf8)
            let value = try JSONDecoder().decode(CodableContainer.self, from: data)
            XCTAssertEqual(value.some, .h)
        }

        do {
            let json = #"{"some": 12}"#
            let data = Data(json.utf8)
            let value = try JSONDecoder().decode(CodableContainer.self, from: data)
            XCTAssertEqual(value.some, .a)
        }

        do {
            let json = #"{"some":1}"#
            let data = Data(json.utf8)
            let value = try JSONDecoder().decode(CodableContainer.self, from: data)
            XCTAssertEqual(value.some, .__undocumented(1))
        }

        do {
            let json = #"{"some":"12"}"#
            let data = Data(json.utf8)
            XCTAssertThrowsError(try JSONDecoder().decode(CodableContainer.self, from: data))
        }
    }

    func testJSONErrorDecodingJSONError() throws {
        let json = """
            {
            "message": "Invalid authentication token",
            "code": 50014
            }
            """
        let data = ByteBuffer(string: json)
        let response = DiscordHTTPResponse(
            host: "discord.com",
            status: .unauthorized,
            version: .http1_1,
            body: data
        )
        let error = try XCTUnwrap(response.asError())
        if case let .jsonError(jsonError) = error {
            XCTAssertEqual(jsonError.message, "Invalid authentication token")
            XCTAssertEqual(jsonError.code, .invalidAuthenticationToken)
        } else {
            XCTFail("\(error) was not a 'jsonError'")
        }

        let jsonError = try response.decodeJSONError()
        XCTAssertEqual(jsonError.message, "Invalid authentication token")
        XCTAssertEqual(jsonError.code, .invalidAuthenticationToken)
    }

    func testJSONErrorDecodingBadStatusCode() throws {
        let json = """
            {
            "some": "thing"
            }
            """
        let data = ByteBuffer(string: json)
        let response = DiscordHTTPResponse(
            host: "discord.com",
            status: .badGateway,
            version: .http1_1,
            body: data
        )
        let error = try XCTUnwrap(response.asError())
        switch error {
        case .badStatusCode: break
        default:
            XCTFail("\(error) was not a 'badStatusCode'")
        }
    }

    func testActionRowDecode() throws {
        let json =
            #"{"t":"INTERACTION_CREATE","s":6,"op":0,"d":{"version":1,"type":5,"token":"aW50ZXJhY3Rpb246MTA5NTY2MTQ0MDk5NzgwNjE3MjpnWXgzbExDQ0FxVjZHbEZVWWJYQkF5Nm1SOGpYR2JVa0Q2NENWMFdwcnNEQ2Z2OUJ4VlBkRnhTM1BVVW1pSFdxNUZCSFBHWVFOVDQ1RldyellZb2QwZTAwTHJuV0tlODk3TUpxY0xvQkZWUk81MHhJZmR4blUzbWlBS0h2UFhmbw","member":{"user":{"username":"Mahdi BM","public_flags":4194304,"id":"290483761559240704","global_name":null,"display_name":null,"discriminator":"0517","avatar_decoration":null,"avatar":"2df0a0198e00ba23bf2dc728c4db94d9"},"roles":["892920753756975144","970723029262942248","970723101044244510"],"premium_since":null,"permissions":"70368744177663","pending":false,"nick":null,"mute":false,"joined_at":"2021-02-09T09:59:16.364000+00:00","is_pending":false,"flags":0,"deaf":false,"communication_disabled_until":null,"avatar":null},"locale":"en-US","id":"1095661440997806172","guild_locale":"en-US","guild_id":"808638139785936919","entitlements":[],"entitlement_sku_ids":[],"data":{"custom_id":"autoPings;add;match","components":[{"type":1,"components":[{"value":"Hello, dad","type":4,"custom_id":"texts"}]}]},"channel_id":"1016614538398937098","channel":{"type":0,"topic":null,"rate_limit_per_user":0,"position":3,"permissions":"70368744177663","parent_id":"808638139785936920","nsfw":false,"name":"penny","last_message_id":"1095658065069605024","id":"1016614538398937098","guild_id":"808638139785936919","flags":0},"application_id":"1016612301262041098","app_permissions":"70368744177663"}}"#
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        _ = try decoder.decode(Gateway.Event.self, from: data)
    }

    func testResolvedDataDecode() throws {
        let json = """
            {
                "users": {
                    "961607141037326386": {
                        "username": "Royale Alchemist",
                        "public_flags": 0,
                        "id": "961607141037326386",
                        "discriminator": "5658",
                        "bot": false,
                        "avatar_decoration": null,
                        "avatar": "c1c960fd53ae185d0741a9d1294539bb"
                    }
                },
                "members": {
                    "961607141037326386": {
                        "roles": [
                            "892920753756975144"
                        ],
                        "premium_since": null,
                        "permissions": "4398046511103",
                        "pending": false,
                        "nick": null,
                        "joined_at": "2022-04-17T03:04:52.022000+00:00",
                        "is_pending": false,
                        "flags": 0,
                        "communication_disabled_until": null,
                        "avatar": null
                    }
                }
            }
            """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Interaction.ApplicationCommand.ResolvedData.self, from: data)

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(decoded)

        _ = try decoder.decode(Interaction.ApplicationCommand.ResolvedData.self, from: encoded)
    }

    func testInteractionDataUtilities() throws {
        let applicationCommand: Interaction.Data = .applicationCommand(
            .init(id: "", name: "", type: .applicationCommand)
        )

        let messageComponent: Interaction.Data = .messageComponent(
            .init(custom_id: "", component_type: .actionRow)
        )

        let modalSubmit: Interaction.Data = .modalSubmit(
            .init(custom_id: "", components: [[.button(.init(label: "", url: ""))]])
        )

        XCTAssertNoThrow(try applicationCommand.requireApplicationCommand())
        XCTAssertThrowsError(try messageComponent.requireApplicationCommand())

        XCTAssertNoThrow(try messageComponent.requireMessageComponent())
        XCTAssertThrowsError(try modalSubmit.requireMessageComponent())

        XCTAssertNoThrow(try modalSubmit.requireModalSubmit())
        XCTAssertThrowsError(try applicationCommand.requireModalSubmit())
    }

    func testApplicationCommandUtilities() throws {
        let command = Interaction.ApplicationCommand(
            id: try! .makeFake(),
            name: "",
            type: .applicationCommand,
            options: [.init(name: "ppppp", type: .attachment)]
        )

        XCTAssertNotNil(command.option(named: "ppppp"))
        XCTAssertNoThrow(try command.requireOption(named: "ppppp"))

        XCTAssertNil(command.option(named: "dasdad"))
        XCTAssertThrowsError(try command.requireOption(named: "iaoso"))

        let option = Interaction.ApplicationCommand.Option(
            name: "dsdagedddd",
            type: .channel,
            options: [.init(name: "lsol", type: .number)]
        )

        XCTAssertNotNil(option.option(named: "lsol"))
        XCTAssertNoThrow(try option.requireOption(named: "lsol"))

        XCTAssertNil(option.option(named: "dasdad"))
        XCTAssertThrowsError(try option.requireOption(named: "iaoso"))

        let options = command.options!

        XCTAssertNotNil(options.option(named: "ppppp"))
        XCTAssertNoThrow(try options.requireOption(named: "ppppp"))

        XCTAssertNil(options.option(named: "dasdad"))
        XCTAssertThrowsError(try options.requireOption(named: "iaoso"))

        let actionsRows: [Interaction.ActionRow] = [
            .init(components: [
                .button(.init(style: .primary, label: "lsofm", custom_id: "lcmjf"))
            ])
        ]

        XCTAssertNotNil(actionsRows.component(customId: "lcmjf"))
        XCTAssertNoThrow(try actionsRows.requireComponent(customId: "lcmjf"))

        XCTAssertNil(actionsRows.component(customId: "dafe"))
        XCTAssertThrowsError(try actionsRows.requireComponent(customId: "grwgwr"))

        let actionsRow = actionsRows[0]

        XCTAssertNotNil(actionsRow.component(customId: "lcmjf"))
        XCTAssertNoThrow(try actionsRow.requireComponent(customId: "lcmjf"))

        XCTAssertNil(actionsRow.component(customId: "dafe"))
        XCTAssertThrowsError(try actionsRow.requireComponent(customId: "grwgwr"))

        let components = actionsRows[0].components

        XCTAssertNotNil(components.component(customId: "lcmjf"))
        XCTAssertNoThrow(try components.requireComponent(customId: "lcmjf"))

        XCTAssertNil(components.component(customId: "dafe"))
        XCTAssertThrowsError(try components.requireComponent(customId: "grwgwr"))

        do {
            let component: Interaction.ActionRow.Component = .button(
                .init(label: "mmm", url: "https://fake.com")
            )

            XCTAssertNoThrow(try component.requireButton())
            XCTAssertThrowsError(try component.requireStringSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .stringSelect(
                .init(custom_id: "ooo", options: [])
            )

            XCTAssertNoThrow(try component.requireStringSelect())
            XCTAssertThrowsError(try component.requireTextInput())
        }

        do {
            let component: Interaction.ActionRow.Component = .textInput(
                .init(custom_id: "qqq")
            )

            XCTAssertNoThrow(try component.requireTextInput())
            XCTAssertThrowsError(try component.requireUserSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .userSelect(
                .init(custom_id: "iii")
            )

            XCTAssertNoThrow(try component.requireUserSelect())
            XCTAssertThrowsError(try component.requireRoleSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .roleSelect(
                .init(custom_id: "lll")
            )

            XCTAssertNoThrow(try component.requireRoleSelect())
            XCTAssertThrowsError(try component.requireMentionableSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .mentionableSelect(
                .init(custom_id: "uuewe")
            )

            XCTAssertNoThrow(try component.requireMentionableSelect())
            XCTAssertThrowsError(try component.requireChannelSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .channelSelect(
                .init(custom_id: "cnajc")
            )

            XCTAssertNoThrow(try component.requireChannelSelect())
            XCTAssertThrowsError(try component.requireButton())
        }
    }

    func testStringIntDoubleBoolUtilities() throws {
        func option(_ value: StringIntDoubleBool) -> Interaction.ApplicationCommand.Option {
            .init(name: "", type: .boolean, value: value)
        }

        do {
            let value = StringIntDoubleBool.string("l")

            XCTAssertNoThrow(try value.requireString())
            XCTAssertThrowsError(try value.requireInt())

            XCTAssertNoThrow(try option(value).requireString())
            XCTAssertThrowsError(try option(value).requireInt())
        }

        do {
            let value = StringIntDoubleBool.int(1)

            XCTAssertNoThrow(try value.requireInt())
            XCTAssertThrowsError(try value.requireDouble())

            XCTAssertNoThrow(try option(value).requireInt())
            XCTAssertThrowsError(try option(value).requireDouble())
        }

        do {
            let value = StringIntDoubleBool.double(9.8)

            XCTAssertNoThrow(try value.requireDouble())
            XCTAssertThrowsError(try value.requireBool())

            XCTAssertNoThrow(try option(value).requireDouble())
            XCTAssertThrowsError(try option(value).requireBool())
        }

        do {
            let value = StringIntDoubleBool.bool(false)

            XCTAssertNoThrow(try value.requireBool())
            XCTAssertThrowsError(try value.requireString())

            XCTAssertNoThrow(try option(value).requireBool())
            XCTAssertThrowsError(try option(value).requireString())
        }
    }

    func testCollectionIsNotEmpty() throws {
        let array1: [String]? = nil
        XCTAssertEqual(array1.isNotEmpty, false)

        let array2: [String]? = []
        XCTAssertEqual(array2.isNotEmpty, false)

        let array3: [String]? = ["a"]
        XCTAssertEqual(array3.isNotEmpty, true)

        let array4: [String] = []
        XCTAssertEqual(array4.isNotEmpty, false)

        let array5: [String] = ["a"]
        XCTAssertEqual(array5.isNotEmpty, true)
    }
}

private struct CodableContainer: Codable {

    @UnstableEnum<Int>
    enum UnstableEnumCodableTester: Codable {
        case a  // 12
        case h  // 100
        case __undocumented(Int)
    }

    var some: UnstableEnumCodableTester
}

private let base64EncodedImageString =
    #"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAMAAAD+MweGAAADAFBMVEUAAAAAAFUAAKoAAP8AJAAAJFUAJKoAJP8ASQAASVUASaoASf8AbQAAbVUAbaoAbf8AkgAAklUAkqoAkv8AtgAAtlUAtqoAtv8A2wAA21UA26oA2/8A/wAA/1UA/6oA//8kAAAkAFUkAKokAP8kJAAkJFUkJKokJP8kSQAkSVUkSaokSf8kbQAkbVUkbaokbf8kkgAkklUkkqokkv8ktgAktlUktqoktv8k2wAk21Uk26ok2/8k/wAk/1Uk/6ok//9JAABJAFVJAKpJAP9JJABJJFVJJKpJJP9JSQBJSVVJSapJSf9JbQBJbVVJbapJbf9JkgBJklVJkqpJkv9JtgBJtlVJtqpJtv9J2wBJ21VJ26pJ2/9J/wBJ/1VJ/6pJ//9tAABtAFVtAKptAP9tJABtJFVtJKptJP9tSQBtSVVtSaptSf9tbQBtbVVtbaptbf9tkgBtklVtkqptkv9ttgBttlVttqpttv9t2wBt21Vt26pt2/9t/wBt/1Vt/6pt//+SAACSAFWSAKqSAP+SJACSJFWSJKqSJP+SSQCSSVWSSaqSSf+SbQCSbVWSbaqSbf+SkgCSklWSkqqSkv+StgCStlWStqqStv+S2wCS21WS26qS2/+S/wCS/1WS/6qS//+2AAC2AFW2AKq2AP+2JAC2JFW2JKq2JP+2SQC2SVW2Saq2Sf+2bQC2bVW2baq2bf+2kgC2klW2kqq2kv+2tgC2tlW2tqq2tv+22wC221W226q22/+2/wC2/1W2/6q2///bAADbAFXbAKrbAP/bJADbJFXbJKrbJP/bSQDbSVXbSarbSf/bbQDbbVXbbarbbf/bkgDbklXbkqrbkv/btgDbtlXbtqrbtv/b2wDb21Xb26rb2//b/wDb/1Xb/6rb////AAD/AFX/AKr/AP//JAD/JFX/JKr/JP//SQD/SVX/Sar/Sf//bQD/bVX/bar/bf//kgD/klX/kqr/kv//tgD/tlX/tqr/tv//2wD/21X/26r/2////wD//1X//6r////qm24uAAAA1ElEQVR42h1PMW4CQQwc73mlFJGCQChFIp0Rh0RBGV5AFUXKC/KPfCFdqryEgoJ8IX0KEF64q0PPnow3jT2WxzNj+gAgAGfvvDdCQIHoSnGYcGDE2nH92DoRqTYJ2bTcsKgqhIi47VdgAWNmwFSFA1UAAT2sSFcnq8a3x/zkkJrhaHT3N+hD3aH7ZuabGHX7bsSMhxwTJLr3evf1e0nBVcwmqcTZuatKoJaB7dSHjTZdM0G1HBTWefly//q2EB7/BEvk5vmzeQaJ7/xKPImpzv8/s4grhAxHl0DsqGUAAAAASUVORK5CYII="#
