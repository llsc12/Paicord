import Foundation
import Logging
import NIOCore

actor SerialQueue {

    var lastSend: Date
    let waitTime: Duration

    init(waitTime: Duration) {
        /// Setting `lastSend` to sometime in the past that is not way too far.
        let waitSeconds = waitTime.asTimeInterval
        self.lastSend = Date().addingTimeInterval(-waitSeconds * 2)
        self.waitTime = waitTime
    }

    func reset() {
        let waitSeconds = waitTime.asTimeInterval
        self.lastSend = Date().addingTimeInterval(-waitSeconds * 2)
    }

    nonisolated func perform(_ task: @escaping @Sendable () -> Void) {
        Task { await self._perform(task) }
    }

    private func _perform(_ task: @escaping @Sendable () -> Void) {
        if let performIn = canPerformIn() {
            queueTask(task, in: performIn)
        } else {
            self.lastSend = Date()
            task()
        }
    }

    private func canPerformIn() -> Duration? {
        let now = Date().timeIntervalSince1970
        let past = now - self.lastSend.timeIntervalSince1970
        let pastNanos = Int64(past * 1_000_000_000)
        let waitMore = waitTime.nanoseconds - pastNanos
        return waitMore > 0 ? .nanoseconds(waitMore) : nil
    }

    private func queueTask(_ task: @escaping @Sendable () -> Void, in wait: Duration) {
        Task {
            do {
                try await Task.sleep(for: wait)
            } catch {
                DiscordGlobalConfiguration.makeLogger("DiscordSerialQueue").warning(
                    "Unexpected SerialQueue failure",
                    metadata: ["error": .string("\(error)")]
                )
                return
            }
            self.perform(task)
        }
    }
}

extension Duration {
    fileprivate var asTimeInterval: TimeInterval {
        let comps = self.components
        let attos = Double(comps.attoseconds) / 1_000_000_000_000_000_000
        return Double(comps.seconds) + attos
    }

    fileprivate var nanoseconds: Int64 {
        let comps = self.components
        let seconds = comps.seconds * 1_000_000_000
        let attos = comps.attoseconds / 1_000_000_000
        return seconds + attos
    }
}
