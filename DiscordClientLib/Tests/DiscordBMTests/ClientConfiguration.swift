import XCTest

import struct NIOHTTP1.HTTPHeaders

@testable import DiscordHTTP

class ClientConfigurationTests: XCTestCase {

    typealias RetryPolicy = ClientConfiguration.RetryPolicy
    typealias Backoff = ClientConfiguration.RetryPolicy.Backoff

    func testRetryPolicyShouldRetry() throws {
        do {
            let policy = RetryPolicy.default
            XCTAssertTrue(policy.shouldRetry(status: .internalServerError, retriesSoFar: 0))
            XCTAssertTrue(policy.shouldRetry(status: .internalServerError, retriesSoFar: 1))
            XCTAssertTrue(policy.shouldRetry(status: .internalServerError, retriesSoFar: 2))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 3))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 4))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 100000))
        }

        do {
            let policy = RetryPolicy(
                statuses: [.badGateway],
                maxRetries: 5
            )

            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 0))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 1))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 2))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 3))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 4))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 5))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 6))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 7))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 100000))

            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 2))
        }

        do {
            var policy = RetryPolicy.default
            policy.statuses.insert(.serviceUnavailable)
            policy.maxRetries = 1

            XCTAssertTrue(policy.shouldRetry(status: .serviceUnavailable, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .serviceUnavailable, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .serviceUnavailable, retriesSoFar: 2))
            XCTAssertFalse(policy.shouldRetry(status: .serviceUnavailable, retriesSoFar: 10))
            XCTAssertFalse(policy.shouldRetry(status: .serviceUnavailable, retriesSoFar: 100000))

            XCTAssertTrue(policy.shouldRetry(status: .internalServerError, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 2))
        }
    }

    func testRetryPolicyConstantBackoff() throws {
        let backoff = Backoff.constant(1)
        let times = [
            backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: Int.max - 1, headers: [:]),
        ]
        for time in times {
            XCTAssertEqual(time, 1)
        }
    }

    func testRetryPolicyLinearBackoff() throws {
        let base = 0.2
        let coefficient = 0.8
        let backoff = Backoff.linear(base: base, coefficient: coefficient, upToTimes: 3)

        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]), base + coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]), base + 2 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 3, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 4, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 5, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: Int.max - 1, headers: [:]), base + 3 * coefficient)
    }

    func testRetryPolicyExponentialBackoff() throws {
        let base = 1.5
        let coefficient = 0.8
        let rate = 3.0
        let backoff = Backoff.exponential(
            base: base,
            coefficient: coefficient,
            rate: rate,
            upToTimes: 4
        )

        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]), base + coefficient * rate)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]), base + coefficient * (pow(rate, 2)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]), base + coefficient * (pow(rate, 3)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 3, headers: [:]), base + coefficient * (pow(rate, 4)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 4, headers: [:]), base + coefficient * (pow(rate, 4)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 5, headers: [:]), base + coefficient * (pow(rate, 4)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]), base + coefficient * (pow(rate, 4)))
        XCTAssertEqual(
            backoff.waitTimeBeforeRetry(retriesSoFar: Int.max - 1, headers: [:]),
            base + coefficient * (pow(rate, 4))
        )
    }

    func testRetryPolicyHeadersBackoffWithElse() throws {
        let base = 0.2
        let coefficient = 0.8
        let linearBackoff = Backoff.linear(base: base, coefficient: coefficient, upToTimes: 3)
        let maxAllowed = 12.0
        let backoff = Backoff.basedOnHeaders(
            maxAllowed: 12,
            retryIfGreater: true,
            else: linearBackoff
        )

        /// Headers greater than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "166")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1, headers: headers), maxAllowed)
        }

        /// Headers smaller than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "8.939")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            let headerTime = 8.939
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1, headers: headers), headerTime)
        }

        /// No headers
        do {
            func backoffWait(retriesSoFar: Int) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: [:])
            }
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]), base + coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]), base + 2 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 3, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 4, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 5, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: Int.max - 1, headers: [:]), base + 3 * coefficient)
        }
    }

    func testRetryPolicyHeadersBackoffWithoutElse() throws {
        let maxAllowed = 10.0
        let backoff = Backoff.basedOnHeaders(
            maxAllowed: maxAllowed,
            retryIfGreater: false,
            else: nil
        )

        /// Headers greater than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "11.5555")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1, headers: headers), nil)
        }

        /// Headers smaller than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "1")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            let headerTime = 1.0
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1, headers: headers), headerTime)
        }

        /// No headers
        do {
            func backoffWait(retriesSoFar: Int) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: [:])
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 1), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 2), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 3), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 4), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 5), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 10), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1), nil)
        }
    }

    func testCacheClient() async throws {

        /// Basic caching
        do {
            let cache = ClientCache()
            let response = DiscordHTTPResponse(
                host: "something.else",
                status: .ok,
                version: .http2,
                headers: [:],
                body: .init(string: "body right here :)")
            )
            let item = ClientCache.CacheableItem(
                identity: .api(.getChannel),
                parameters: [],
                queries: []
            )
            await cache.save(response: response, item: item, ttl: .seconds(5))
            let fromCache = await cache.get(item: item)
            XCTAssertEqual(response, fromCache)
        }

        /// Caching with queries
        do {
            let cache = ClientCache()
            let response = DiscordHTTPResponse(
                host: "something.else",
                status: .ok,
                version: .http2,
                headers: [:],
                body: .init(string: "body right here :)")
            )
            let item = ClientCache.CacheableItem(
                identity: .api(.getChannel),
                parameters: [],
                queries: [("name", "mahdi"), ("age", "99"), ("height", nil)]
            )
            await cache.save(response: response, item: item, ttl: .seconds(5))
            let fromCache = await cache.get(item: item)
            XCTAssertEqual(response, fromCache)
        }

        /// No cached available
        do {
            let cache = ClientCache()
            let response = DiscordHTTPResponse(
                host: "something.else",
                status: .ok,
                version: .http2,
                headers: [:],
                body: .init(string: "body right here :)")
            )
            let item = ClientCache.CacheableItem(
                identity: .api(.getChannel),
                parameters: [],
                queries: []
            )
            await cache.save(response: response, item: item, ttl: .seconds(5))
            let fromCache = await cache.get(
                item: .init(
                    identity: .api(.listGuildAuditLogEntries),
                    parameters: [],
                    queries: []
                )
            )
            XCTAssertNil(fromCache)
        }

        /// No cached available because parameters different
        do {
            let cache = ClientCache()
            let response = DiscordHTTPResponse(
                host: "something.else",
                status: .ok,
                version: .http2,
                headers: [:],
                body: .init(string: "body right here :)")
            )
            let item = ClientCache.CacheableItem(
                identity: .api(.getChannel),
                parameters: ["1"],
                queries: []
            )
            await cache.save(response: response, item: item, ttl: .seconds(5))
            let fromCache = await cache.get(
                item: .init(
                    identity: .api(.getChannel),
                    parameters: [],
                    queries: []
                )
            )
            XCTAssertNil(fromCache)
        }

        /// No cached available because queries different
        do {
            let cache = ClientCache()
            let response = DiscordHTTPResponse(
                host: "something.else",
                status: .ok,
                version: .http2,
                headers: [:],
                body: .init(string: "body right here :)")
            )
            let item = ClientCache.CacheableItem(
                identity: .api(.getChannel),
                parameters: [],
                queries: [("name", "mahdi")]
            )
            await cache.save(response: response, item: item, ttl: .seconds(5))
            let fromCache = await cache.get(
                item: .init(
                    identity: .api(.getChannel),
                    parameters: [],
                    queries: []
                )
            )
            XCTAssertNil(fromCache)
        }

        /// No cached available because queries different
        do {
            let cache = ClientCache()
            let response = DiscordHTTPResponse(
                host: "something.else",
                status: .ok,
                version: .http2,
                headers: [:],
                body: .init(string: "body right here :)")
            )
            let item = ClientCache.CacheableItem(
                identity: .api(.getChannel),
                parameters: [],
                queries: []
            )
            await cache.save(response: response, item: item, ttl: .seconds(5))
            let fromCache = await cache.get(
                item: .init(
                    identity: .api(.getChannel),
                    parameters: [],
                    queries: [("name", "mahdi")]
                )
            )
            XCTAssertNil(fromCache)
        }

        /// No cached available because ttl
        do {
            let cache = ClientCache()
            let response = DiscordHTTPResponse(
                host: "something.else",
                status: .ok,
                version: .http2,
                headers: [:],
                body: .init(string: "body right here :)")
            )
            let item = ClientCache.CacheableItem(
                identity: .api(.getChannel),
                parameters: [],
                queries: []
            )
            await cache.save(response: response, item: item, ttl: .milliseconds(1_500))
            try await Task.sleep(for: .milliseconds(1_500))
            let fromCache = await cache.get(item: item)
            XCTAssertNil(fromCache)
        }
    }

    func testAuthenticationHeader() async throws {
        let header1 = AuthenticationHeader.botToken(
            "MTEwOTUzODY0MTY2OTI3MTY4NA.GnqP8q.8hhS0qeDTbAkKJB_bvwl5VfCzflKzkQgbMXNiA"
        )
        XCTAssertEqual(header1.extractAppIdIfAvailable(), "1109538641669271684")

        let header2 = AuthenticationHeader.botToken(
            "OTUwNjk1Mjk0OTA2MDA3NTcz.GnqP8q.8hhS0qeDTbAkKJB_bvwl5VfCzflKzkQgbMXNiA"
        )
        XCTAssertEqual(header2.extractAppIdIfAvailable(), "950695294906007573")

        func makeFakeToken(id: UInt) -> String {
            let base64 = Data(id.description.utf8).base64EncodedString()
            return "\(base64).GnqP8q.8hhS0qeDTbAkKJB_bvwl5VfCzflKzkQgbMXNiA"
        }

        /// Swift's base64 decoding seems to be rather strict,
        /// so we test a wide a range of numbers here to make sure
        for length in (1...19) {
            for _ in 0..<100 {
                let numberChars = "0123456789"
                let numberString = (0..<length).map { _ in numberChars.randomElement()! }
                if let number = UInt(String(numberString)) {
                    let token = makeFakeToken(id: number)
                    let header = AuthenticationHeader.botToken(Secret(token))
                    XCTAssertEqual(header.extractAppIdIfAvailable()?.rawValue, "\(number)")
                }
            }
        }
    }
}

// MARK: - DiscordHTTPResponse + Equatable
extension DiscordHTTPResponse: Equatable {
    public static func == (lhs: DiscordHTTPResponse, rhs: DiscordHTTPResponse) -> Bool {
        lhs.host == rhs.host && lhs.status == rhs.status && lhs.version == rhs.version && lhs.headers == rhs.headers
            && lhs.body == rhs.body
    }
}
