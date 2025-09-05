import AsyncHTTPClient
import Atomics
import Foundation
import Logging
import XCTest

@testable import DiscordGateway

class GatewayConnectionTests: XCTestCase, @unchecked Sendable {

    /// Don't use `HTTPClient.shared` to test not using it.
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

    @available(*, deprecated, message: "To avoid deprecation warnings for 'makeEventsParseFailureStream'")
    func testConnect() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        /// Also tests with default `HTTPClient.shared` and `HTTPClient.shared.eventLoopGroup`.
        let bot = await BotGatewayManager(
            token: Constants.token,
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        XCTAssertEqual(bot.client.appId?.rawValue, Constants.botId.rawValue)

        let expectation = Expectation(description: "Connected")

        let connectionInfo = ConnectionInfo()

        Task {
            for await event in await bot.events {
                if case let .ready(ready) = event.data {
                    await connectionInfo.setReady(ready)
                    expectation.fulfill()
                } else if event.opcode == .hello {
                    await connectionInfo.setDidHello()
                } else if await connectionInfo.ready == nil {
                    expectation.fulfill()
                }
            }
        }

        Task {
            /// Trying to keep `.makeEventsParseFailureStream()` to make sure the func still works.
            /// Parsing failures are not the end of the world.
            /// They might even be acceptable.
            /// However since we know this gateway manager won't do much more than
            /// the basic regular stuff like identify/ping-pong, it shouldn't throw
            /// parsing errors for those.
            if Bool.random() {
                for await (error, buffer) in await bot.eventFailures {
                    XCTFail(
                        "Received parsing failure. Error: \(error), buffer: \(buffer), string-buffer: \(String(buffer: buffer))"
                    )
                }
            } else {
                for await (error, buffer) in await bot.makeEventsParseFailureStream() {
                    XCTFail(
                        "Received parsing failure. Error: \(error), buffer: \(buffer), string-buffer: \(String(buffer: buffer))"
                    )
                }
            }
        }

        /// To make sure these 2 `Task`s are triggered in order
        try await Task.sleep(for: .milliseconds(200))

        Task { await bot.connect() }

        await waitFulfillment(of: [expectation], timeout: 10)

        let didHello = await connectionInfo.didHello
        let _ready = await connectionInfo.ready
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
        XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
        XCTAssertEqual(ready.application.id, Snowflake(Constants.botId))
        XCTAssertFalse(ready.session_id.isEmpty)
        XCTAssertEqual(ready.user.id, Constants.botId)
        XCTAssertEqual(ready.user.bot, true)

        /// The bot should not disconnect for 120s.
        /// This is to make sure we aren't getting invalid-session-ed immediately.
        /// Also to check that ping-ponging works.
        try await Task.sleep(for: .seconds(120))
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)

        await bot.disconnect()

        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
    }

    @available(*, deprecated, message: "To avoid deprecation warnings for 'makeEventsStream'")
    func testShardingGatewayManager() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        let shardCount = 20

        let bot: any GatewayManager = await ShardingGatewayManager(
            eventLoopGroup: self.httpClient.eventLoopGroup,
            httpClient: self.httpClient,
            configuration: .init(
                shardCount: .exact(shardCount),
                makeIntents: { _, _ in Gateway.Intent.allCases }
            ),
            token: Constants.token,
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        let counter = ShardCounter(shardCount: shardCount)

        Task {
            func handleEvent(_ event: Gateway.Event) async throws {
                if case let .ready(ready) = event.data {
                    let shardIdx = try XCTUnwrap(ready.shard?.first)
                    await counter.increase(shardIdx: shardIdx)
                } else if event.opcode == .invalidSession {
                    XCTFail("Received invalid session in a shard")
                } else {
                    /// Do nothing
                }
            }
            /// Trying to keep `.makeEventsStream()` to make sure the func still works.
            if Bool.random() {
                for await event in await bot.events {
                    try await handleEvent(event)
                }
            } else {
                for await event in await bot.makeEventsStream() {
                    try await handleEvent(event)
                }
            }
        }

        /// To make sure these 2 `Task`s are triggered in order
        try await Task.sleep(for: .milliseconds(200))

        Task { await bot.connect() }

        await counter.waitFulfillment()
    }

    @available(*, deprecated, message: "To avoid deprecation warnings for 'makeEventsStream'")
    func testGatewayStopsOnInvalidToken() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        let criticalLogExpectation = Expectation(description: "criticalLogExpectation")
        let logHandler = TestingLogHandler(expectation: criticalLogExpectation)

        DiscordGlobalConfiguration.makeLogger = { label in
            Logger(label: label, factory: { _ in logHandler })
        }

        let bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: Constants.token.dropLast(4) + "aaaa",
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        let expectation = Expectation(description: "Connected")

        let didReceiveAnythingOtherThanHello = ManagedAtomic(false)

        Task {
            /// Trying to keep `.makeEventsStream()` to make sure the func still works.
            for await event in await bot.makeEventsStream() {
                if case .hello = event.data {
                    expectation.fulfill()
                } else {
                    didReceiveAnythingOtherThanHello.store(true, ordering: .relaxed)
                }
            }
        }

        /// To make sure these 2 `Task`s are triggered in order
        try await Task.sleep(for: .milliseconds(200))

        Task { await bot.connect() }

        await waitFulfillment(of: [expectation, criticalLogExpectation], timeout: 10)

        /// We sent an invalid token so Discord shouldn't even respond to us.
        XCTAssertFalse(didReceiveAnythingOtherThanHello.load(ordering: .relaxed))

        let messages = logHandler.getMessages()

        XCTAssertEqual(messages.count, 1)
        let first = try XCTUnwrap(messages.first)
        XCTAssertEqual(
            first,
            #"Will not reconnect because Discord does not allow it. Something is wrong. Your close code is 'authenticationFailed', check Discord docs at https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes and see what it means. Report at https://github.com/DiscordBM/DiscordBM/issues if you think this is a library issue"#
        )

        /// Wait 1s just incase.
        try await Task.sleep(for: .seconds(1))

        /// BotGatewayManager already "stopped" itself and increased the `connectionId`
        /// since token was invalid and Discord complains about that.
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
    }

    func testGatewayRequests() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        let bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: Constants.token,
            presence: .init(
                activities: [.init(name: "Test Activity!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabledWithPresences
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

        /// Didn't find a way to properly verify these functions.
        /// Here we just make the requests and make sure we aren't getting invalid-session-ed.

        let activityName = "Test Activity! \(UInt.random(in: .min ... .max))"
        await bot.updatePresence(
            payload: .init(
                since: .now,
                activities: [.init(name: activityName, type: .listening)],
                status: .online,
                afk: true
            )
        )
        await bot.updateVoiceState(
            payload: .init(
                guildId: Constants.guildId,
                selfMute: true,
                selfDeaf: false
            )
        )

        try await Task.sleep(for: .seconds(5))

        /// `DiscordCache` itself will do `requestGuildMembersChunk`s,
        /// but we also do it to make sure we get the new presence.
        await bot.requestGuildMembersChunk(
            payload: .init(
                guild_id: Constants.guildId,
                presences: true,
                user_ids: [Constants.botId.rawValue]
            )
        )

        /// To make sure it doesn't mess up other connections,
        /// and to make sure we aren't getting invalid-session-ed.
        /// And also to wait for propagation of the presence update to us through DiscordCache.
        try await Task.sleep(for: .seconds(30))
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)

        await bot.disconnect()

        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)

        let _guild = await cache.guilds[Constants.guildId]
        let guild = try XCTUnwrap(_guild)
        let presence = try XCTUnwrap(guild.presences.first(where: { $0.user?.id == Constants.botId }), "\(guild)")
        let activity = try XCTUnwrap(presence.activities?.first)
        XCTAssertEqual(activity.name, activityName)
    }
}

private actor ConnectionInfo {
    var ready: Gateway.Ready? = nil
    var didHello = false

    init() {}

    func setReady(_ ready: Gateway.Ready) {
        self.ready = ready
    }

    func setDidHello() {
        self.didHello = true
    }
}

private actor ShardCounter {
    private var connectedShards = Set<Int>()
    private var shardCount: Int
    private var expectation: Expectation?

    init(shardCount: Int) {
        self.shardCount = shardCount
    }

    func increase(shardIdx: Int, file: StaticString = #filePath, line: UInt = #line) {
        if !connectedShards.insert(shardIdx).inserted {
            XCTFail("Seems like ShardCounter has already been fulfilled for shardIdx '\(shardIdx)'")
        }
        if connectedShards.sorted() == Array(0..<(shardCount)) {
            self.expectation?.fulfill(file: file, line: line)
            self.expectation = nil
        }
    }

    func waitFulfillment(
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        if connectedShards.sorted() == Array(0..<(shardCount)) {
            return
        } else {
            let exp = Expectation(description: "Counter")
            self.expectation = exp
            await Expectation.waitFulfillment(
                of: [exp],
                timeout: Double(shardCount * 25),
                file: file,
                line: line
            )
        }
    }
}

/// Fulfills the expectation on the first log.
private class TestingLogHandler: @unchecked Sendable, LogHandler {
    var expectation: Expectation?
    let queue = DispatchQueue(label: "TestingLogHandler")

    private var messages: [String] = []

    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .critical
    subscript(metadataKey _: String) -> Logger.Metadata.Value? {
        get { nil }
        set {}
    }

    init(expectation: Expectation) {
        self.expectation = expectation
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        queue.sync {
            self.messages.append(message.description)
            self.expectation?.fulfill()
            self.expectation = nil
        }
    }

    func getMessages() -> [String] {
        queue.sync {
            self.messages
        }
    }
}
