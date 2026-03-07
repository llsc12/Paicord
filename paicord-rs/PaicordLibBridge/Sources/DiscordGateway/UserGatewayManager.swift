import Logging
import PaicordLib

func user_gateway_manager_new(token: RustString) async -> UserGatewayManager {
    return await UserGatewayManager(token: Secret(token.toString()))
}

extension UserGatewayManager {
    func next_event() async -> BridgedGatewayEvent {
        for await event: Gateway.Event in await self.events {
            return BridgedGatewayEvent(inner: event)
        }

        fatalError("Event loop stopped unexpectedly")
    }

    func update_guild_subscriptions(
        id: SnowflakeRust, typing: Bool, activities: Bool, threads: Bool, member_updates: Bool
    ) async {
        let id = GuildSnowflake(id.inner.description)

        self.updateGuildSubscriptions(
            payload:
                .init(subscriptions: [
                    id: .init(
                        typing: typing,
                        activities: activities,
                        threads: threads,
                        member_updates: member_updates,
                        channels: [:],
                        thread_member_lists: nil
                    )
                ])
        )
    }

    func list_messages(channel: SnowflakeRust, limit: Int32) async throws(BridgedRustError)
        -> BridgedMessageVec
    {
        do {
            let messages = try await client.listMessages(
                channelId: ChannelSnowflake(channel.inner),
                limit: Int(limit)
            )

            try messages.guardSuccess()

            let fetched = try messages.decode()

            return BridgedMessageVec(inner: fetched.map { BridgedPartialMessage(message: $0.toPartialMessage()) })

        } catch {
            throw BridgedRustError.UnhandledError(
                "Failed to list messages: \(error.localizedDescription)".intoRustString())
        }
    }

    func request_guild_members_chunk(guild_id: SnowflakeRust, user_ids: RustVec<UInt64>) async {
        let guildId = GuildSnowflake(guild_id.inner)
        var userIds: [UserSnowflake] = [];

        for i in 0..<user_ids.len() {
            if let userId = user_ids.get(index: UInt(i)) {
                userIds.append(UserSnowflake(userId.description))
            }
            
        }

        self.requestGuildMembersChunk(
            payload: .init(
                guild_id: guildId,
                presences: false,
                user_ids: userIds
            )
        )
    }

    func send_message(channel: SnowflakeRust, content: RustString) async {
        let nonce: MessageSnowflake = try! .makeFake(date: .now)
        do {
            try await self.client.createMessage(
                channelId: ChannelSnowflake(channel.inner),
                payload: .init(
                    content: content.toString(), nonce: .string(nonce.rawValue))
            ).guardSuccess()
        } catch {
            print("Failed to send message")
        }
    }
}

class BridgedMessageVec {
    var inner: [BridgedPartialMessage]

    init(inner: [BridgedPartialMessage]) {
        self.inner = inner
    }

    func len() -> UInt {
        return UInt(inner.count)
    }

    func get(index: UInt) -> BridgedPartialMessage {
        return inner[Int(index)]
    }
}