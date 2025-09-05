import XCTest

import struct NIOCore.ByteBuffer

@testable import DiscordGateway

class DiscordCacheTests: XCTestCase {

    func testItemsLimitPolicy() async throws {
        let storage = DiscordCache.Storage(auditLogs: ["1": []])
        let cache = await DiscordCache(
            gatewayManager: FakeGatewayManager(),
            intents: .all,
            requestAllMembers: .enabledWithPresences,
            itemsLimit: .constant(10),
            storage: storage
        )

        /// First 10 items must be kept like normal.
        for idx in 2...10 {
            await cache._tests_modifyStorage { storage in
                storage.auditLogs[AnySnowflake("\(idx)")] = []
            }
        }

        do {
            let auditLogs = await cache.storage.auditLogs
            XCTAssertEqual(auditLogs.keys.map(\.rawValue.description), (1...10).map(\.description))
        }

        /// The 11th item will trigger a check, and the first item will be removed.
        for idx in 11...11 {
            await cache._tests_modifyStorage { storage in
                storage.auditLogs[AnySnowflake("\(idx)")] = []
            }
        }

        do {
            let auditLogs = await cache.storage.auditLogs
            XCTAssertEqual(auditLogs.keys.map(\.rawValue.description), (2...11).map(\.description))
        }

        /// The 12-19th mutations won't trigger a check.
        for idx in 12...19 {
            await cache._tests_modifyStorage { storage in
                storage.auditLogs[AnySnowflake("\(idx)")] = []
            }
        }

        do {
            let auditLogs = await cache.storage.auditLogs
            XCTAssertEqual(auditLogs.keys.map(\.rawValue.description), (2...19).map(\.description))
        }

        /// The 20th mutation will trigger a check, and older items will be removed.
        for idx in 20...20 {
            await cache._tests_modifyStorage { storage in
                storage.auditLogs[AnySnowflake("\(idx)")] = []
            }
        }

        do {
            let auditLogs = await cache.storage.auditLogs
            XCTAssertEqual(auditLogs.keys.map(\.rawValue.description), (11...20).map(\.description))
        }
    }
}

private actor FakeGatewayManager: GatewayManager {
    nonisolated var client: any DiscordClient { fatalError() }
    nonisolated let id: UInt = 0
    nonisolated let identifyPayload: Gateway.Identify = .init(token: "", intents: [])
    func connect() async {}
    func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async {}
    func updatePresence(payload: Gateway.Identify.Presence) async {}
    func updateVoiceState(payload: VoiceStateUpdate) async {}
    func makeEventsStream() async -> AsyncStream<Gateway.Event> {
        AsyncStream<Gateway.Event> { _ in }
    }
    func makeEventsParseFailureStream() async -> AsyncStream<(any Error, ByteBuffer)> {
        AsyncStream<(any Error, ByteBuffer)> { _ in }
    }
    func disconnect() async {}
}
