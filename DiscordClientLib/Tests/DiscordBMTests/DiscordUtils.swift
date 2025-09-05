import DiscordUtilities
import XCTest

class DiscordUtilsTests: XCTestCase {

    func test() {
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.mention(id: UserSnowflake(id))
            XCTAssertEqual(string, "<@\(id)>")
        }

        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.mention(id: ChannelSnowflake(id))
            XCTAssertEqual(string, "<#\(id)>")
        }

        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.mention(id: RoleSnowflake(id))
            XCTAssertEqual(string, "<@&\(id)>")
        }

        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(name: "abcd", id: Snowflake(id))
            XCTAssertEqual(string, "</abcd:\(id)>")
        }

        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(name: "polikj", id: Snowflake(id), subcommand: "hey")
            XCTAssertEqual(string, "</polikj hey:\(id)>")
        }

        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(
                name: "bhjksa",
                id: Snowflake(id),
                subcommand: "poi",
                subcommandGroup: "homdas"
            )
            XCTAssertEqual(string, "</bhjksa homdas poi:\(id)>")
        }

        do {
            let string = DiscordUtils.standardUnicodeEmoji(emoji: "🥳")
            XCTAssertEqual(string, "🥳")
        }

        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.customEmoji(name: "qwerrt", id: Snowflake(id))
            XCTAssertEqual(string, "<:qwerrt:\(id)>")
        }

        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.customAnimatedEmoji(name: "pwqoe", id: Snowflake(id))
            XCTAssertEqual(string, "<a:pwqoe:\(id)>")
        }

        do {
            let date = Date()
            let string1 = DiscordUtils.timestamp(date: date)
            let string2 = DiscordUtils.timestamp(unixTimestamp: date.timeIntervalSince1970)
            let string3 = DiscordUtils.timestamp(unixTimestamp: Int(date.timeIntervalSince1970))
            XCTAssertEqual(string1, "<t:\(Int(date.timeIntervalSince1970))>")
            XCTAssertEqual(string1, string2)
            XCTAssertEqual(string2, string3)
            XCTAssertEqual(string3, string1)
        }

        do {
            let date = Date()
            let string1 = DiscordUtils.timestamp(date: date, style: .relativeTime)
            let string2 = DiscordUtils.timestamp(
                unixTimestamp: date.timeIntervalSince1970,
                style: .relativeTime
            )
            let string3 = DiscordUtils.timestamp(
                unixTimestamp: Int(date.timeIntervalSince1970),
                style: .relativeTime
            )
            XCTAssertEqual(string1, "<t:\(Int(date.timeIntervalSince1970)):R>")
            XCTAssertEqual(string1, string2)
            XCTAssertEqual(string2, string3)
            XCTAssertEqual(string3, string1)
        }
    }

    func testEscapingSpecialCharacters() throws {
        let text = #"""
            *Hello!*
            __***How are you?***__
            > _I'm fine thank you!_
            > ~Not really :\(~
            || Just Kidding! || LOL | HEHE
            """#
        let expected = #"""
            \*Hello!\*
            \_\_\*\*\*How are you?\*\*\*\_\_
            \> \_I'm fine thank you!\_
            \> \~Not really \:\\(\~
            \|\| Just Kidding! \|\| LOL \| HEHE
            """#
        let escaped = DiscordUtils.escapingSpecialCharacters(text)
        XCTAssertEqual(escaped, expected)

        let link =
            #"https://raw.githubusercontent.com/apple/swift-evolution/proposals/0401-remove-property-wrapper-isolation.md"#
        let escapedLink = DiscordUtils.escapingSpecialCharacters(link, options: .keepLinks)
        XCTAssertEqual(escapedLink, link)

        let noNewLines =
            #"\*Hello!\*\n\_\_\*\*\*How are you?\*\*\*\_\_\n\> \_I'm fine thank you!\_\n\> \~Not really \:\\(\~\n\|\| Just Kidding! \|\| LOL \| HEHE"#
        let escapedLines = DiscordUtils.escapingSpecialCharacters(text, options: .escapeNewLines)
        XCTAssertEqual(escapedLines, noNewLines)
    }
}
