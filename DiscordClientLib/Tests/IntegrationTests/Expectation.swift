import Foundation
import XCTest

/// XCTest's own `XCTestExpectation` is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay too flaky on linux.
actor Expectation {

    enum State: String {
        case started
        case failed
        case done
    }

    nonisolated let description: String
    private var state = State.started
    private var fulfillment: (@Sendable () -> Void)? = nil

    init(description: String) {
        self.description = description
    }

    nonisolated func fulfill(file: StaticString = #filePath, line: UInt = #line) {
        Task { await self._fulfill(file: file, line: line) }
    }

    private func _fulfill(file: StaticString, line: UInt) async {
        if self.state != .started {
            XCTFail(
                "Expectation '\(self.description)' was already fulfilled with state: \(self.state)",
                file: file,
                line: line
            )
        } else {
            self.state = .done
            self.fulfillment?()
        }
    }

    nonisolated private func onFulfillment(block: @Sendable @escaping () -> Void) {
        Task { await self._onFulfillment(block: block) }
    }

    private func _onFulfillment(block: @Sendable @escaping () -> Void) {
        switch self.state {
        case .done:
            block()
        case .started:
            self.fulfillment = block
        case .failed:
            break
        }
    }

    static func waitFulfillment(
        of expectations: [Expectation],
        message: @Sendable @autoclosure @escaping () -> String = "",
        timeout: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let storage = FulfillmentStorage()

        let task = Task {
            try await Task.sleep(for: .nanoseconds(Int(timeout * 1_000_000_000)))
            let indices = storage.getIndices()
            let left =
                expectations
                .enumerated()
                .filter { !indices.contains($0.offset) }
                .map(\.element.description)
            if !left.isEmpty {
                /// End the continuation so the tests don't hang.
                storage.endContinuation(file: file, line: line)
                XCTFail(
                    "Some expectations failed to resolve in \(timeout) seconds: \(left). \(message())",
                    file: file,
                    line: line
                )
            }
        }

        await withCheckedContinuation { continuation in
            storage.setContinuation(to: continuation)

            for (idx, expectation) in expectations.enumerated() {
                expectation.onFulfillment {
                    let indices = storage.appendingIndex(idx)
                    let left =
                        expectations
                        .enumerated()
                        .filter { !indices.contains($0.offset) }
                    if left.isEmpty {
                        task.cancel()
                        /// End the continuation and notify the waiter.
                        storage.endContinuation(file: file, line: line)
                    }
                }
            }
        }
    }
}

// MARK: - +XCTestCase
extension XCTestCase {
    func waitFulfillment(
        of expectations: [Expectation],
        message: @Sendable @autoclosure @escaping () -> String = "",
        timeout: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        await Expectation.waitFulfillment(
            of: expectations,
            message: message(),
            timeout: timeout,
            file: file,
            line: line
        )
    }
}

// MARK: - FulfillmentStorage

/// This was initially an `actor`, but having it as a `class` and
/// synchronizing using a `DispatchQueue` simplifies a lot of stuff.
private class FulfillmentStorage: @unchecked Sendable {
    private var indices: [Int] = []
    private var continuation: CheckedContinuation<(), Never>? = nil
    private let queue = DispatchQueue(label: "FulfillmentStorageQueue")

    init() {}

    func getIndices() -> [Int] {
        queue.sync {
            self.indices
        }
    }

    func appendingIndex(_ index: Int) -> [Int] {
        queue.sync {
            self.indices.append(index)
            return self.indices
        }
    }

    func setContinuation(to new: CheckedContinuation<(), Never>) {
        queue.sync {
            self.continuation = new
        }
    }

    func endContinuation(file: StaticString, line: UInt) {
        queue.sync {
            if self.continuation != nil {
                self.continuation!.resume()
                self.continuation = nil
            } else {
                XCTFail(
                    "Trying to end continuation when it has already ended",
                    file: file,
                    line: line
                )
            }
        }
    }
}
