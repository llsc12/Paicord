import Logging
import NIOHTTP1
import XCTest

@testable import DiscordHTTP

class HTTPRateLimiterTests: XCTestCase {

    var rateLimiter = HTTPRateLimiter(label: "Test_RateLimiter")
    let endpoint = AnyEndpoint.botApi(.getGateway)
    /// Interactions endpoints are unique in the sense that they by-pass the global rate limit.
    let interactionEndpoint = APIEndpoint.createInteractionResponse(
        interactionId: "",
        interactionToken: ""
    )

    override func setUp() async throws {
        self.rateLimiter = HTTPRateLimiter(label: "Test_RateLimiter")
    }

    func testBucketAllows() async throws {
        let rateLimiter = HTTPRateLimiter(label: "Test")
        let headers: HTTPHeaders = [
            "x-ratelimit-bucket": "41f9cd5d28af77da04563bcb1d67fdfd",
            "x-ratelimit-limit": "2",
            "x-ratelimit-remaining": "1",
            "x-ratelimit-reset": "\(Date().timeIntervalSince1970 + 5)",
            "x-ratelimit-reset-after": "5.000",
        ]
        await rateLimiter.include(
            endpoint: endpoint,
            headers: headers,
            status: .ok
        )
        let shouldRequest = await rateLimiter.shouldRequest(to: endpoint)
        XCTAssertEqual(shouldRequest, .true)
    }

    func testBucketExhausted() async throws {
        let rateLimiter = HTTPRateLimiter(label: "Test")
        let headers: HTTPHeaders = [
            "x-ratelimit-bucket": "41f9cd5d28af77da04563bcb1d67fdfd",
            "x-ratelimit-limit": "2",
            "x-ratelimit-remaining": "0",
            "x-ratelimit-reset": "\(Date().timeIntervalSince1970 + 5)",
            "x-ratelimit-reset-after": "5.000",
        ]
        await rateLimiter.include(
            endpoint: endpoint,
            headers: headers,
            status: .ok
        )
        let shouldRequest = await rateLimiter.shouldRequest(to: endpoint)
        switch shouldRequest {
        case .after: break
        default:
            XCTFail("\(shouldRequest) was not a '.after'")
        }
    }

    /// Bucket is exhausted but the we've already past `x-ratelimit-reset`.
    func testBucketExhaustedAndExpired() async throws {
        let rateLimiter = HTTPRateLimiter(label: "Test")
        let headers: HTTPHeaders = [
            "x-ratelimit-bucket": "41f9cd5d28af77da04563bcb1d67fdfd",
            "x-ratelimit-limit": "2",
            "x-ratelimit-remaining": "0",
            "x-ratelimit-reset": "\(Date().timeIntervalSince1970 - 1)",
            "x-ratelimit-reset-after": "5.000",
        ]
        await rateLimiter.include(
            endpoint: endpoint,
            headers: headers,
            status: .ok
        )
        let shouldRequest = await rateLimiter.shouldRequest(to: endpoint)
        XCTAssertEqual(shouldRequest, .true)
    }

    func testBucketAllowsButReachedGlobalInvalidRequests() async throws {
        let invalidStatuses: [HTTPResponseStatus] = [.tooManyRequests, .forbidden, .unauthorized]
        for _ in 0..<499 {
            await rateLimiter.include(
                endpoint: endpoint,
                headers: [:],
                status: invalidStatuses.randomElement()!
            )
        }

        /// Still only 499 invalid requests, so should allow requests.
        do {
            let shouldRequest = await rateLimiter.shouldRequest(to: endpoint)
            XCTAssertEqual(shouldRequest, .true)
        }

        await rateLimiter.include(
            endpoint: endpoint,
            headers: [:],
            status: invalidStatuses.randomElement()!
        )
        /// Now 500 invalid requests, so should NOT allow requests.
        do {
            let shouldRequest = await rateLimiter.shouldRequest(to: endpoint)
            XCTAssertEqual(shouldRequest, .false)
        }
    }

    func testBucketAllowsButGlobalRateLimit() async throws {
        let start = Date()

        for _ in 0..<49 {
            _ = await rateLimiter.shouldRequest(to: endpoint)
        }

        /// Still only 49 requests, so should allow requests.
        do {
            let shouldRequest = await rateLimiter.shouldRequest(to: endpoint)
            XCTAssertEqual(shouldRequest, .true)
        }

        let end = Date()

        /// Now 50 invalid requests, so should NOT allow requests.
        do {
            let diff = end.timeIntervalSince1970 - start.timeIntervalSince1970
            let lessThan1min = diff < 60

            let shouldRequest = await rateLimiter.shouldRequest(to: endpoint)
            XCTAssertEqual(shouldRequest, lessThan1min ? .false : .true)
        }

        /// Interactions endpoints are not limited by the global rate limit, so should allow requests.
        do {
            let shouldRequest = await rateLimiter.shouldRequest(to: .botApi(interactionEndpoint))
            XCTAssertEqual(shouldRequest, .true)
        }
    }

    func testEmptyHeaders() async throws {
        await rateLimiter.include(
            endpoint: endpoint,
            headers: [:],
            status: .ok
        )
        let shouldRequest = await rateLimiter.shouldRequest(to: endpoint)
        XCTAssertEqual(shouldRequest, .true)
    }
}

extension HTTPRateLimiter.ShouldRequest: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if case .true = lhs, case .true = rhs {
            return true
        } else if case .false = lhs, case .false = rhs {
            return true
        } else if case let .after(lhs) = lhs, case let .after(rhs) = rhs {
            return lhs == rhs
        } else {
            return false
        }
    }
}
