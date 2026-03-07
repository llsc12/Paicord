import PaicordLib

class BridgedGatewayEvent {
    var inner: Gateway.Event

    init(inner: Gateway.Event) {
        self.inner = inner
    }

    func get_type() -> String? {
        self.inner.type
    }

    func has_payload() -> Bool {
        self.inner.data != nil
    }

    func get_payload() -> BridgedGatewayPayload {
        return BridgedGatewayPayload(inner: self.inner.data!)
    }
}

class BridgedGatewayPayload {
    var inner: Gateway.Event.Payload

    init(inner: Gateway.Event.Payload) {
        self.inner = inner
    }

    func as_ready_payload() -> BridgedReadyPayload {
        switch self.inner {
        case .ready(let ready):
            return BridgedReadyPayload(inner: ready)
        default:
            fatalError("Not a ready payload")
        }
    }

    func as_message_create_payload() -> BridgedMessageCreatePayload {
        switch self.inner {
        case .messageCreate(let messageCreate):
            return BridgedMessageCreatePayload(inner: messageCreate)
        default:
            fatalError("Not a message create payload")
        }
    }

    func as_guild_members_chunk_payload() -> BridgedGuildMembersChunkPayload {
        switch self.inner {
        case .guildMembersChunk(let chunk):
            return BridgedGuildMembersChunkPayload(inner: chunk)
        default:
            fatalError("Not a guild members chunk payload")
        }
    }
}

class BridgedReadyPayload {
    var inner: Gateway.Ready

    init(inner: Gateway.Ready) {
        self.inner = inner
    }

    func get_user() -> DiscordUserRust {
        return DiscordUserRust(user: self.inner.user)
    }

    func has_preloaded_user_settings() -> Bool {
        self.inner.user_settings_proto != nil
    }

    func get_preloaded_user_settings() -> BridgedPreloadedUserSettings {
        return BridgedPreloadedUserSettings(inner: self.inner.user_settings_proto!)
    }

    func get_guild_count() -> UInt {
        return UInt(self.inner.guilds.count)
    }
    
    func get_guild(index: UInt) -> BridgedGuild {
        return BridgedGuild(bridge: self.inner.guilds[Int(index)])
    }
}

class BridgedMessageCreatePayload {
    var inner: Gateway.MessageCreate

    init(inner: Gateway.MessageCreate) {
        self.inner = inner
    }

    func to_partial_message() -> BridgedPartialMessage {
        return BridgedPartialMessage(message: self.inner.toMessage().toPartialMessage())
    }
}

class BridgedGuildMembersChunkPayload {
    var inner: Gateway.GuildMembersChunk

    init(inner: Gateway.GuildMembersChunk) {
        self.inner = inner
    }

    func get_guild_id() -> SnowflakeRust {
        return SnowflakeRust(inner: UInt64(self.inner.guild_id.rawValue) ?? 0)
    }

    func member_count() -> UInt {
        return UInt(self.inner.members.count)
    }

    func get_member(index: UInt) -> BridgedPartialMember {
        return BridgedPartialMember(member: self.inner.members[Int(index)].toPartialMember())
    }
}