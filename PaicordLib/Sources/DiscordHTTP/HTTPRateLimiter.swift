import NIOHTTP1

import struct Foundation.Date

private let logger = DiscordGlobalConfiguration.makeLogger("DBM.HTTPRateLimiter")

@usableFromInline
actor HTTPRateLimiter {

    private struct Bucket: Hashable, CustomStringConvertible {
        let bucket: String
        let limit: Int
        let remaining: Int
        let reset: Double

        var description: String {
            "Bucket(" + "bucket: \(bucket.debugDescription), " + "limit: \(limit), " + "remaining: \(remaining), "
                + "reset: \(reset.debugDescription)" + ")"
        }

        init?(from headers: HTTPHeaders) {
            guard let bucket = headers.first(name: "x-ratelimit-bucket"),
                let limitStr = headers.first(name: "x-ratelimit-limit"),
                let limit = Int(limitStr),
                let remainingStr = headers.first(name: "x-ratelimit-remaining"),
                let remaining = Int(remainingStr),
                let resetStr = headers.first(name: "x-ratelimit-reset"),
                let reset = Double(resetStr)
            else { return nil }
            /// `x-ratelimit-reset-after: Double` not used since `x-ratelimit-reset` is enough.
            self.bucket = bucket
            self.limit = limit
            self.remaining = remaining
            self.reset = reset
        }

        func shouldRequest() -> ShouldRequest {
            if remaining > 0 {
                return .true
            } else {
                let wait = reset - Date().timeIntervalSince1970
                if wait > 0 {
                    return .after(wait)
                } else {
                    return .true
                }
            }
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(self.bucket)
        }

        static func == (lhs: Bucket, rhs: Bucket) -> Bool {
            lhs.bucket == rhs.bucket
        }
    }

    let label: String

    /// [Endpoint-ID: Bucket-ID]
    private var endpoints: [Int: String] = [:]

    /// [Bucket-ID: Bucket]
    private var buckets: [String: Bucket] = [:]

    /// To take care of the global rate limit.
    private var requestsThisSecond: (id: Int, count: Int) = (0, 0)

    /// Only 10K invalid requests allowed each 10 minutes.
    /// We keep track of 500 / 1 minute so we can prevent hitting the limit easier.
    private var invalidRequestsIn1Minute: (id: Int, count: Int) = (0, 0)

    /// Hitting the invalid requests limit will ban you for one day.
    /// Your code should be good enough not to send that many invalid requests.
    /// This is to prevent getting ip-banned.
    private var noRequestsUntil: Date? = nil

    init(label: String) {
        self.label = label
    }

    private func currentGlobalRateLimitId() -> Int {
        Int(Date().timeIntervalSince1970)
    }

    private func currentMinutelyRateLimitId() -> Int {
        Int(Date().timeIntervalSince1970) / 60
    }

    private func minutelyInvalidRequestsLimitAllows() -> Bool {
        /// Check not locked
        if let lockedUntil = self.noRequestsUntil {
            if lockedUntil > Date() {
                logger.error(
                    "HTTP rate-limiter has been locked for a few seconds, due to invalid requests",
                    metadata: [
                        "label": .string(label)
                    ]
                )
                return false
            } else {
                self.noRequestsUntil = nil
            }
        }
        /// Check the counter again
        let oneMinutelyId = self.currentMinutelyRateLimitId()
        if invalidRequestsIn1Minute.id == oneMinutelyId,
            invalidRequestsIn1Minute.count >= 500
        {
            logger.critical(
                "Hit HTTP global invalid-requests limit. Will accept no requests for 10s to avoid getting ip-banned",
                metadata: [
                    "label": .string(label)
                ]
            )
            self.noRequestsUntil = Date().addingTimeInterval(10)
            return false
        } else {
            return true
        }
    }

    private func globalRateLimitAllows() -> Bool {
        let globalId = self.currentGlobalRateLimitId()
        if self.requestsThisSecond.id == globalId {
            if self.requestsThisSecond.count >= DiscordGlobalConfiguration.globalRateLimit {
                logger.warning(
                    "Hit HTTP Global rate-limit",
                    metadata: [
                        "label": .string(label)
                    ]
                )
                return false
            } else {
                self.requestsThisSecond.count += 1
                return true
            }
        } else {
            self.requestsThisSecond = (globalId, 1)
            return true
        }
    }

    @usableFromInline
    func addGlobalRateLimitRecord() {
        let globalId = self.currentGlobalRateLimitId()
        if self.requestsThisSecond.id == globalId {
            self.requestsThisSecond.count += 1
        } else {
            self.requestsThisSecond = (globalId, 1)
        }
    }

    @usableFromInline
    enum ShouldRequest: Sendable {
        case `true`
        case `false`
        /// Need to wait some seconds if you want to make the request
        case after(Double)
    }

    /// Should request to the endpoint or not.
    /// This also adds a record to the global rate-limit, so if this returns `true`,
    /// you should make sure the request is sent, or otherwise this rate-limiter's
    /// global rate-limit will be less than the max amount and might not allow you
    /// to make too many requests per second, when it should.
    @usableFromInline
    func shouldRequest(to endpoint: AnyEndpoint) -> ShouldRequest {
        guard minutelyInvalidRequestsLimitAllows() else { return .false }
        if endpoint.countsAgainstGlobalRateLimit {
            guard globalRateLimitAllows() else { return .false }
        }
        if let bucketId = self.endpoints[endpoint.id],
            let bucket = self.buckets[bucketId]
        {
            switch bucket.shouldRequest() {
            case .true:
                self.addGlobalRateLimitRecord()
                return .true
            case .false:
                logger.warning(
                    "Hit HTTP Bucket rate-limit",
                    metadata: [
                        "label": .string(label),
                        "endpointId": .stringConvertible(endpoint.id),
                        "bucket": .stringConvertible(bucket),
                    ]
                )
                return .false
            case let .after(after):
                /// Need to call `addGlobalRateLimitRecord()` when doing the request.
                /// Also need to log necessary info to users, when e.g. we can't make the request.
                return .after(after)
            }
        } else {
            return .true
        }
    }

    @usableFromInline
    func include(endpoint: AnyEndpoint, headers: HTTPHeaders, status: HTTPResponseStatus) {
        /// Add to invalid requests limit if needed.
        if [429, 403, 401].contains(status.code) {
            let id = self.currentMinutelyRateLimitId()
            if self.invalidRequestsIn1Minute.id == id {
                self.invalidRequestsIn1Minute.count += 1
            } else {
                self.invalidRequestsIn1Minute = (id, 1)
            }
        }
        /// Take care of the rate limit headers.
        guard let newBucket = Bucket(from: headers) else { return }
        if !(self.endpoints[endpoint.id] == newBucket.bucket) {
            self.endpoints[endpoint.id] = newBucket.bucket
        }
        self.buckets[newBucket.bucket] = newBucket
    }
}
