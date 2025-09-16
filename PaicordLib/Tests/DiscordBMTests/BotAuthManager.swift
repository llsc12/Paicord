import PaicordLib
import XCTest

class BotAuthManagerTests: XCTestCase {

    let clientId = "121232141392410"
    lazy var manager = BotAuthManager(clientId: clientId)

    func testBotAuthURLPlain() throws {
        let url1 = manager.makeBotAuthorizationURL()

        XCTAssertEqual(
            url1,
            "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=0&scope=bot"
        )

        let url2 = manager.makeBotAuthorizationURL(
            permissions: [.addReactions, .changeNickname]
        )

        XCTAssertEqual(
            url2,
            "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=67108928&scope=bot"
        )
    }

    @available(*, deprecated)
    func testBotAuthURLDeprecated() throws {
        let url1 = manager.makeBotAuthorizationURL(
            withApplicationCommands: false,
            permissions: [.addReactions, .changeNickname]
        )

        XCTAssertEqual(
            url1,
            "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=67108928&scope=bot"
        )

        let url2 = manager.makeBotAuthorizationURL(
            withApplicationCommands: false,
            permissions: [.manageRoles, .manageGuild, .createInstantInvite],
            guildId: "123456789123456789",
            disableGuildSelect: true
        )

        XCTAssertEqual(
            url2,
            "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=268435489&scope=bot&guild_id=123456789123456789&disable_guild_select=true"
        )

        let url3 = manager.makeBotAuthorizationURL(
            withApplicationCommands: true,
            permissions: [.manageRoles, .manageGuild, .createInstantInvite],
            guildId: "123456789123456789",
            disableGuildSelect: true
        )

        XCTAssertEqual(
            url3,
            "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=268435489&scope=bot%20applications.commands&guild_id=123456789123456789&disable_guild_select=true"
        )
    }
}
