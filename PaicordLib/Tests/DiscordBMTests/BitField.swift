import PaicordLib
import XCTest

class BitFieldTests: XCTestCase {

    typealias Raw = Permission
    let allCases: [Raw] = [
        .createInstantInvite, .kickMembers, .banMembers, .administrator, .manageChannels, .manageGuild, .addReactions,
        .viewAuditLog, .prioritySpeaker, .stream, .viewChannel, .sendMessages, .sendTtsMessages, .manageMessages,
        .embedLinks, .attachFiles, .readMessageHistory, .mentionEveryone, .useExternalEmojis, .viewGuildInsights,
        .connect, .speak, .muteMembers, .deafenMembers, .moveMembers, .useVAD, .changeNickname, .manageNicknames,
        .manageRoles, .manageWebhooks, .manageGuildExpressions, .useApplicationCommands, .requestToSpeak, .manageEvents,
        .manageThreads, .createPublicThreads, .createPrivateThreads, .useExternalStickers, .sendMessagesInThreads,
        .useEmbeddedActivities, .moderateMembers, .viewCreatorMonetizationAnalytics, .useSoundboard,
    ]

    /// To make sure `IntBitField` and `StringBitField` have similar behavior,
    /// so we can continue the tests with only one of them.
    func testBitFieldsEqual() {
        for idx in (0..<100) {
            let values = (0...idx).map { _ in
                allCases.randomElement()!
            }
            let intField = IntBitField<Raw>(Set(values))
            let stringField = StringBitField<Raw>(Set(values))
            XCTAssertEqual(intField.rawValue, stringField.rawValue)
        }
    }

    func testValueCalculation() {
        do {
            let field = IntBitField<Raw>([])
            XCTAssertEqual(field.rawValue, 0)
        }

        do {
            let field = IntBitField<Raw>([Raw(rawValue: 0)!])
            XCTAssertEqual(field.rawValue, 1)
        }

        do {
            let field = IntBitField<Raw>([Raw(rawValue: 1)!])
            XCTAssertEqual(field.rawValue, 2)
        }

        do {
            let field = IntBitField<Raw>([Raw(rawValue: 2)!])
            XCTAssertEqual(field.rawValue, 4)
        }

        do {
            let values = [0, 1, 2].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(values)
            XCTAssertEqual(field.rawValue, 7)
        }

        do {
            let values = [7, 8, 9, 15, 17, 18, 19, 20, 24].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(values)
            XCTAssertEqual(field.rawValue, 18_776_960)
        }

        do {
            let values = [0, 13, 14, 15, 18, 31].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(values)
            XCTAssertEqual(field.rawValue, 2_147_803_137)
        }
    }

    func testInitFromBitValue() {
        do {
            let field = IntBitField<Raw>(rawValue: 0)
            XCTAssertEqual(field, [])
        }

        do {
            let field = IntBitField<Raw>(rawValue: 1)
            XCTAssertEqual(field, [Raw(rawValue: 0)!])
        }

        do {
            let field = IntBitField<Raw>(rawValue: 2)
            XCTAssertEqual(field, [Raw(rawValue: 1)!])
        }

        do {
            let field = IntBitField<Raw>(rawValue: 3)
            XCTAssertEqual(field, [Raw(rawValue: 0)!, Raw(rawValue: 1)!])
        }

        do {
            let field = IntBitField<Raw>(rawValue: 4)
            XCTAssertEqual(field, [Raw(rawValue: 2)!])
        }

        do {
            let values = [7, 8, 9, 15, 17, 18, 19, 20, 24].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(rawValue: 18_776_960)
            XCTAssertEqual(field, IntBitField(values))
        }

        do {
            let values = [0, 13, 14, 15, 18, 31].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(rawValue: 2_147_803_137)
            XCTAssertEqual(field, IntBitField(values))
        }

        do {
            let field1 = IntBitField<Raw>(rawValue: 999_999_999_999_999)
            let field2 = IntBitField<Raw>([
                .administrator, .viewAuditLog, .kickMembers, .sendMessagesInThreads, .banMembers, .manageGuild,
                .manageChannels, .muteMembers, .manageMessages, .manageThreads, .sendMessages, .sendTtsMessages,
                .useExternalStickers, .manageWebhooks, .deafenMembers, .moderateMembers, .useExternalEmojis,
                .viewChannel, .prioritySpeaker, .createPrivateThreads, .useApplicationCommands, .createInstantInvite,
                .createPublicThreads, .embedLinks, .addReactions, .manageEvents, .changeNickname, .stream,
                .mentionEveryone, .useSoundboard,
            ])
            XCTAssertNotEqual(field1, field2)
        }
    }

    func testOptionSetFunctions() {
        typealias Field = StringBitField<DiscordUser.Flag>

        /// Remove
        do {
            var field = Field([
                .hypeSquadOnlineHouse1,
                .hypeSquadOnlineHouse2,
                .hypeSquadOnlineHouse3,
            ])
            field.remove(.hypeSquadOnlineHouse2)

            XCTAssertEqual(field, [.hypeSquadOnlineHouse1, .hypeSquadOnlineHouse3])
        }

        /// Contains
        do {
            let field = Field([
                .hypeSquadOnlineHouse1,
                .hypeSquadOnlineHouse2,
                .hypeSquadOnlineHouse3,
            ])

            XCTAssertTrue(field.contains(.hypeSquadOnlineHouse2))
        }

        /// Contains 2
        do {
            let field = Field([
                .hypeSquadOnlineHouse1,
                .hypeSquadOnlineHouse3,
            ])

            XCTAssertFalse(field.contains(.hypeSquadOnlineHouse2))
        }

        /// Contains 3
        do {
            let field = Field([
                .hypeSquadOnlineHouse1
            ])

            XCTAssertFalse(field.contains(.hypeSquadOnlineHouse2))
        }

        /// Contains 4
        do {
            let field = Field([
                .hypeSquadOnlineHouse1,
                .teamPseudoUser,
            ])

            XCTAssertFalse(field.contains(.hypeSquadOnlineHouse2))
        }

        /// Contains 5
        do {
            let field = Field([
                .hypeSquadOnlineHouse1,
                .teamPseudoUser,
            ])

            XCTAssertTrue(field.contains(.teamPseudoUser))
        }

        /// Insert
        do {
            var field = Field([.hypeSquadOnlineHouse1, .hypeSquadOnlineHouse3])
            field.insert(.hypeSquadOnlineHouse2)

            XCTAssertEqual(
                field,
                [
                    .hypeSquadOnlineHouse1,
                    .hypeSquadOnlineHouse2,
                    .hypeSquadOnlineHouse3,
                ]
            )
        }

        /// Insert 2
        do {
            var field = Field([
                .hypeSquadOnlineHouse1,
                .hypeSquadOnlineHouse2,
                .hypeSquadOnlineHouse3,
            ])
            field.insert(.hypeSquadOnlineHouse2)

            XCTAssertEqual(
                field,
                [
                    .hypeSquadOnlineHouse1,
                    .hypeSquadOnlineHouse2,
                    .hypeSquadOnlineHouse3,
                ]
            )
        }

        /// Update
        do {
            var field = Field([.hypeSquadOnlineHouse1, .hypeSquadOnlineHouse3])
            field.update(with: .hypeSquadOnlineHouse2)

            XCTAssertEqual(
                field,
                [
                    .hypeSquadOnlineHouse1,
                    .hypeSquadOnlineHouse2,
                    .hypeSquadOnlineHouse3,
                ]
            )
        }

        /// Update 2
        do {
            var field = Field([
                .hypeSquadOnlineHouse1,
                .hypeSquadOnlineHouse2,
                .hypeSquadOnlineHouse3,
            ])
            field.update(with: .hypeSquadOnlineHouse2)

            XCTAssertEqual(
                field,
                [
                    .hypeSquadOnlineHouse1,
                    .hypeSquadOnlineHouse2,
                    .hypeSquadOnlineHouse3,
                ]
            )
        }
    }
}
