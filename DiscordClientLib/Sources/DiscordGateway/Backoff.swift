import Foundation
import NIOCore

/// Exponential backoff
final class Backoff {

    let base: Double
    let maxExponentiation: Int
    let coefficient: Double
    let minBackoff: TimeInterval
    var tryCount = 0
    var previousTry = Date.distantPast.timeIntervalSince1970

    init(
        base: Double,
        maxExponentiation: Int,
        coefficient: Double,
        minBackoff: TimeInterval
    ) {
        self.base = base
        self.maxExponentiation = maxExponentiation
        self.coefficient = coefficient
        self.minBackoff = minBackoff
    }

    /// Returns `nil` if can perform immediately,
    /// otherwise `Duration` to wait before attempting to perform.
    /// Assumes you will definitely perform the task after calling this.
    func canPerformIn() -> Duration? {
        let tryCount = self.tryCount
        let previousTry = self.previousTry
        self.tryCount += 1
        let now = Date().timeIntervalSince1970
        if tryCount == 0 {
            /// Even if the last connection was successful, don't try to connect too fast.
            let timePast = now - previousTry
            if timePast > self.minBackoff {
                return nil
            } else {
                let remaining = self.minBackoff - timePast
                let millis = Int64(remaining * 1_000)
                return .milliseconds(millis)
            }
        } else {
            let effectiveTryCount = min(tryCount, self.maxExponentiation)
            let factor = self.coefficient * pow(self.base, Double(effectiveTryCount))
            let timePast = now - previousTry
            let calculatedWait = factor - timePast
            let minRequiredWait = self.minBackoff - timePast
            let toWait = max(calculatedWait, minRequiredWait)
            if toWait > 0 {
                let millis = Int64(toWait * 1_000) + 1
                return .milliseconds(millis)
            } else {
                return nil
            }
        }
    }

    func resetTryCount() {
        self.tryCount = 0
    }

    func willTry() {
        self.previousTry = Date().timeIntervalSince1970
    }

    #if DEBUG
    func test_setTryCount(to newValue: Int) {
        self.tryCount = newValue
    }

    func test_setPreviousTry(to newValue: TimeInterval) {
        self.previousTry = newValue
    }
    #endif
}
