import AsyncHTTPClient
import PaicordLib
import Logging
import XCTest

class PermissionChecker: XCTestCase {

    let httpClient = HTTPClient()

    override func setUp() {
        DiscordGlobalConfiguration.makeLogger = {
            var logger = Logger(label: $0)
            logger.logLevel = .trace
            return logger
        }
    }

    override func tearDown() async throws {
        DiscordGlobalConfiguration.makeLogger = { Logger(label: $0) }
    }

    /// Can't use the async `shutdown()` in `tearDown()`. Will get `Fatal error: leaking promise created at (file: "NIOPosix/HappyEyeballs.swift", line: 300)`
    deinit {
        try! httpClient.syncShutdown()
    }

    /// Checks to see if the permission checker functions work properly.
    func testCheckPermissions() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        let bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: Constants.token,
            appId: Snowflake(Constants.botId),
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabled
        )

        let expectation = Expectation(description: "Connected")

        Task {
            for await event in await bot.events {
                if case .ready = event.data {
                    expectation.fulfill()
                }
            }
        }

        /// To make sure these 2 `Task`s are triggered in order
        try await Task.sleep(for: .milliseconds(200))

        Task { await bot.connect() }

        await waitFulfillment(of: [expectation], timeout: 10)

        let publicThread = try await bot.client.createThread(
            channelId: Constants.Channels.perm1.id,
            payload: .init(
                name: "Perm test thread",
                type: .publicThread
            )
        ).decode()

        let privateThread = try await bot.client.createThread(
            channelId: Constants.Channels.spam.id,
            payload: .init(
                name: "Perm private test thread",
                type: .privateThread
            )
        ).decode()

        /// For cache to get populated
        try await Task.sleep(for: .seconds(5))

        let _guild = await cache.guilds[Constants.guildId]
        let guild = try XCTUnwrap(_guild)

        /// The bot is `administrator` in the server.
        XCTAssertTrue(
            guild.userHasGuildPermission(
                userId: Snowflake(Constants.botId),
                permission: .administrator
            )
        )
        /// The bot does not have `manageEvents` perm, but is `administrator`,
        /// so in practice has the perm.
        XCTAssertTrue(
            guild.userHasGuildPermission(
                userId: Snowflake(Constants.botId),
                permission: .manageEvents
            )
        )
        /// The account does not have the perm at all.
        XCTAssertFalse(
            guild.userHasGuildPermission(
                userId: Constants.secondAccountId,
                permission: .manageRoles
            )
        )
        /// The account has the perm but doesn't have `viewChannel`,
        /// so in practice doesn't have the perm.
        XCTAssertFalse(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm1.id,
                permissions: [.manageChannels]
            )
        )
        /// The account has the perm.
        XCTAssertTrue(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm2.id,
                permissions: [.viewChannel]
            )
        )
        /// The account doesn't have the perm.
        XCTAssertFalse(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm2.id,
                permissions: [.sendMessages]
            )
        )
        /// The account doesn't has the perm but doesn't have the `sendMessages` perm,
        ///  which blocks this specific perm in practice.
        XCTAssertFalse(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm2.id,
                permissions: [.embedLinks]
            )
        )
        /// The account has all the permissions.
        XCTAssertTrue(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm3.id,
                permissions: [.viewChannel, .manageChannels, .createInstantInvite, .useExternalStickers]
            )
        )
        /// The account has all the permissions but one.
        XCTAssertFalse(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm3.id,
                permissions: [.viewChannel, .manageChannels, .sendTtsMessages, .useExternalStickers]
            )
        )
        /// The account has the permission thanks to a member-perm-overwrite.
        XCTAssertTrue(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm3.id,
                permissions: [.useExternalEmojis]
            )
        )
        /// The account has the perm in the guild, doesn't have it based on role-overwrite
        /// in the channel, but still has it based on member-overwrite in the channel.
        XCTAssertTrue(
            guild.userHasGuildPermission(
                userId: Constants.secondAccountId,
                permission: .manageWebhooks
            )
        )
        XCTAssertTrue(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm3.id,
                permissions: [.manageWebhooks]
            )
        )
        /// The account has the perm in the guild, and has it based on role-overwrite
        /// in the channel, but doesn't have it based on member-overwrite in the channel.
        XCTAssertTrue(
            guild.userHasGuildPermission(
                userId: Constants.secondAccountId,
                permission: .manageThreads
            )
        )
        XCTAssertFalse(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: Constants.Channels.perm3.id,
                permissions: [.manageThreads]
            )
        )

        /// The account doesn't have access to the channel, so
        /// doesn't have access to the thread either.
        XCTAssertFalse(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: publicThread.id,
                permissions: [.viewChannel]
            )
        )

        /// The account has access to the channel, but the thread is private.
        XCTAssertFalse(
            guild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: privateThread.id,
                permissions: [.viewChannel]
            )
        )

        /// Is not in the private thread but is guild owner, so has access.
        XCTAssertTrue(
            guild.userHasPermissions(
                userId: Constants.personalId,
                channelId: privateThread.id,
                permissions: [.viewChannel]
            )
        )

        /// Is thread creator, so has access.
        XCTAssertTrue(
            guild.userHasPermissions(
                userId: Constants.botId,
                channelId: privateThread.id,
                permissions: [.viewChannel]
            )
        )

        /// Mention the second account so it is added to the members list.
        try await bot.client.createMessage(
            channelId: privateThread.id,
            payload: .init(
                content: DiscordUtils.mention(id: Constants.secondAccountId)
            )
        ).guardSuccess()

        /// For cache to get populated
        try await Task.sleep(for: .seconds(3))

        let _updatedGuild = await cache.guilds[Constants.guildId]
        let updatedGuild = try XCTUnwrap(_updatedGuild)

        /// The account has access to the channel, and is joined to the thread.
        XCTAssertTrue(
            updatedGuild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: privateThread.id,
                permissions: [.viewChannel, .sendMessages, .readMessageHistory]
            )
        )

        /// The account has access to the channel, and is joined to the thread,
        /// but doesn't have the perm.
        XCTAssertFalse(
            updatedGuild.userHasPermissions(
                userId: Constants.secondAccountId,
                channelId: privateThread.id,
                permissions: [.manageGuild]
            )
        )

        try await bot.client.deleteChannel(id: publicThread.id).guardSuccess()
        try await bot.client.deleteChannel(id: privateThread.id).guardSuccess()

        await bot.disconnect()
    }
}
