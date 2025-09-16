import DiscordModels

import struct Foundation.Date

actor ShardCoordinator {
    private var lastConnectionDates = [Date]()
    /// Each `maxConcurrency` amount of connections need to wait **5** seconds.
    /// https://discord.com/developers/docs/topics/gateway#session-start-limit-object-session-start-limit-structure
    let waitTime = 5.0

    init() {}

    /// Wait until the other required shards have connected.
    func waitForOtherShards(shard: IntPair, maxConcurrency: Int) async {
        if self.lastConnectionDates.count < maxConcurrency {
            self.lastConnectionDates.append(Date())
            return
        } else {
            let index = self.lastConnectionDates.count - maxConcurrency
            /// `index` guaranteed to be valid for `lastConnectionDates`.
            let firstDateInMaxConcurrencyLimitBucket = self.lastConnectionDates[index]
            let first = firstDateInMaxConcurrencyLimitBucket.timeIntervalSince1970
            let now = Date().timeIntervalSince1970
            let diff = now - first
            let diffWithWaitTime = self.waitTime - diff
            if diffWithWaitTime > 0 {
                self.lastConnectionDates.append(Date().addingTimeInterval(diffWithWaitTime))
                try? await Task.sleep(nanoseconds: UInt64(diffWithWaitTime * 1_000_000_000))
            } else {
                self.lastConnectionDates.append(Date())
                return
            }
        }
    }
}
