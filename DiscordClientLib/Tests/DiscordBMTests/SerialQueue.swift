import Atomics
import XCTest

@testable import DiscordGateway

class SerialQueueTests: XCTestCase {

    func testFirstTrySucceedsImmediately() async {
        let queue = SerialQueue(waitTime: .milliseconds(250))
        let number = ManagedAtomic(0)

        Task {
            queue.perform {
                number.wrappingIncrement(ordering: .relaxed)
            }
        }

        try! await Task.sleep(for: .milliseconds(20))
        XCTAssertEqual(number.load(ordering: .relaxed), 1)
    }

    func testSecondTryNeedsToWait() async {
        let queue = SerialQueue(waitTime: .seconds(2))
        let container = Container()

        Task {
            for _ in 0..<2 {
                queue.perform {
                    Task { await container.add() }
                }
            }
        }

        try! await Task.sleep(for: .milliseconds(2_250))

        let times = await container.times

        for (idx, time) in times.enumerated() {
            XCTAssertGreaterThan(time, Double(idx) * 2)
            if idx != 0 {
                let passedBetweenTimes = times[idx] - times[idx - 1]
                /// 1.99 since it might not be accurate to the exact 2 second.
                XCTAssertGreaterThan(passedBetweenTimes, 1.99)
            }
        }
    }

    func testALotOfTriesNeedToWaitInQueue() async {
        let queue = SerialQueue(waitTime: .milliseconds(100))
        let container = Container()

        Task {
            for _ in 0..<5 {
                queue.perform {
                    Task { await container.add() }
                }
            }
        }

        try! await Task.sleep(for: .milliseconds(1_600))

        let times = await container.times

        for (idx, time) in times.enumerated() {
            XCTAssertGreaterThan(time, Double(idx) * 0.1)
            if idx != 0 {
                let passedBetweenTimes = times[idx] - times[idx - 1]
                /// 0.098 since it might not be accurate to the exact 0.1 second.
                XCTAssertGreaterThan(passedBetweenTimes, 0.098)
            }
        }
    }
}

private actor Container {
    var times = [Double]()
    let startTime = Date().timeIntervalSince1970

    func add() {
        let passed = Date().timeIntervalSince1970 - startTime
        self.times.append(passed)
    }
}
