import XCTest

@testable import DiscordGateway

class BackoffTests: XCTestCase {

    func testNoWaitTimeForTheFirstTime() async {
        for _ in 0..<50 {
            let backoff = Backoff(
                base: .random(in: 2...10),
                maxExponentiation: .random(in: 2...20),
                coefficient: .random(in: 2...20),
                minBackoff: .random(in: 5...60)
            )
            let canPerformIn = backoff.canPerformIn()
            XCTAssertEqual(canPerformIn, nil)
            let tryCount = backoff.tryCount
            XCTAssertEqual(tryCount, 1)
        }
    }

    func testMinPastTime1() async throws {
        for _ in 0..<50 {
            let minBackoff = Double.random(in: 5...60)
            let backoff = Backoff(
                base: 2,
                maxExponentiation: 10,
                coefficient: 1,
                minBackoff: minBackoff
            )
            backoff.willTry()
            backoff.test_setTryCount(to: 1)
            let _canPerformIn = backoff.canPerformIn()
            let canPerformIn = try XCTUnwrap(_canPerformIn)
            let canPerformDouble = canPerformIn.asTimeInterval
            XCTAssertTolerantIsEqual(canPerformDouble, minBackoff)
        }
    }

    func testMinPastTime2() async throws {
        for _ in 0..<500 {
            for num in 1...5 {
                let minBackoff = Double.random(in: 0...3.5)
                let base = Double.random(in: 2...5)
                let coefficient = Double.random(in: 2...5)
                let backoff = Backoff(
                    base: base,
                    maxExponentiation: 5,
                    coefficient: coefficient,
                    minBackoff: minBackoff
                )
                backoff.willTry()
                let exponent = num
                backoff.test_setTryCount(to: exponent)
                let _canPerformIn = backoff.canPerformIn()
                let canPerformIn = try XCTUnwrap(_canPerformIn)
                let canPerformDouble = canPerformIn.asTimeInterval
                /// With the settings above, `canPerformIn` will always exceed `minPastTime`.
                XCTAssertGreaterThan(canPerformDouble, minBackoff)
                XCTAssertTolerantIsEqual(canPerformDouble, coefficient * pow(base, Double(exponent)))
            }
        }
    }

    func testMaxExponentiation() async throws {
        /// Less than `minBackoff`
        do {
            let backoff = Backoff(
                base: 2,
                maxExponentiation: 5,
                coefficient: 1,
                minBackoff: 10
            )
            backoff.willTry()
            backoff.test_setTryCount(to: 15)
            let _canPerformIn = backoff.canPerformIn()
            let canPerformIn = try XCTUnwrap(_canPerformIn)
            let canPerformDouble = canPerformIn.asTimeInterval
            XCTAssertTolerantIsEqual(canPerformDouble, 32)
        }

        /// Greater than `minBackoff`
        do {
            let backoff = Backoff(
                base: 2,
                maxExponentiation: 8,
                coefficient: 1,
                minBackoff: 257
            )
            backoff.willTry()
            backoff.test_setTryCount(to: 9)
            let _canPerformIn = backoff.canPerformIn()
            let canPerformIn = try XCTUnwrap(_canPerformIn)
            let canPerformDouble = canPerformIn.asTimeInterval
            XCTAssertTolerantIsEqual(canPerformDouble, 257)
        }
    }

    func testTryCountIncrement() async throws {
        for _ in 0..<50 {
            let minBackoff = Double.random(in: 5...60)
            let backoff = Backoff(
                base: 2,
                maxExponentiation: 10,
                coefficient: 1,
                minBackoff: minBackoff
            )
            backoff.willTry()
            let tryCount = Int.random(in: 0...50)
            backoff.test_setTryCount(to: tryCount)
            _ = backoff.canPerformIn()
            let backoffTryCount = backoff.tryCount
            XCTAssertEqual(backoffTryCount, tryCount + 1)
        }
    }

    func testPreviousTry() async throws {
        for _ in 0..<500 {
            for num in 1...5 {
                let minBackoff = Double.random(in: 1...3.9)
                let base = Double.random(in: 2...5)
                let coefficient = Double.random(in: 2...5)
                let backoff = Backoff(
                    base: base,
                    maxExponentiation: 5,
                    coefficient: coefficient,
                    minBackoff: minBackoff
                )
                let timePastAfterPreviousTry = Double.random(in: 0.5..<minBackoff)
                backoff.test_setPreviousTry(
                    to: Date().timeIntervalSince1970 - timePastAfterPreviousTry
                )
                let exponent = num
                backoff.test_setTryCount(to: exponent)
                let _canPerformIn = backoff.canPerformIn()
                let canPerformIn = try XCTUnwrap(_canPerformIn)
                let canPerformDouble = canPerformIn.asTimeInterval
                /// With the settings above, `canPerformIn` will always exceed `minPastTime`.
                XCTAssertGreaterThan(canPerformDouble, minBackoff - timePastAfterPreviousTry)
                XCTAssertTolerantIsEqual(
                    canPerformDouble,
                    coefficient * pow(base, Double(exponent)) - timePastAfterPreviousTry
                )
            }
        }
    }

    func XCTAssertTolerantIsEqual(_ lhs: Double, _ rhs: Double) {
        let tolerance = 0.1
        let acceptedRange = (-tolerance...tolerance)
        guard acceptedRange.contains(lhs - rhs) else {
            XCTFail("\(lhs) is not equal to \(rhs).")
            return
        }
    }
}

extension Duration {
    fileprivate var asTimeInterval: TimeInterval {
        let comps = self.components
        let attos = Double(comps.attoseconds) / 1_000_000_000_000_000_000
        return Double(comps.seconds) + attos
    }
}
