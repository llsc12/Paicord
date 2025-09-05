/// https://discord.com/developers/docs/resources/voice#voice-state-object-voice-state-structure
public struct VoiceState: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake?
    public var user_id: UserSnowflake
    public var member: Guild.PartialMember?
    public var session_id: String
    public var deaf: Bool
    public var mute: Bool
    public var self_deaf: Bool
    public var self_mute: Bool
    public var self_stream: Bool?
    public var self_video: Bool
    public var suppress: Bool
    public var request_to_speak_timestamp: DiscordTimestamp?
}

/// https://discord.com/developers/docs/resources/voice#voice-state-object-voice-state-structure
public struct PartialVoiceState: Sendable, Codable {
    public var channel_id: ChannelSnowflake?
    public var user_id: UserSnowflake
    public var member: Guild.PartialMember?
    public var session_id: String
    public var deaf: Bool
    public var mute: Bool
    public var self_deaf: Bool
    public var self_mute: Bool
    public var self_stream: Bool?
    public var self_video: Bool
    public var suppress: Bool
    public var request_to_speak_timestamp: DiscordTimestamp?

    public init(voiceState: VoiceState) {
        self.channel_id = voiceState.channel_id
        self.user_id = voiceState.user_id
        self.member = voiceState.member
        self.session_id = voiceState.session_id
        self.deaf = voiceState.deaf
        self.mute = voiceState.mute
        self.self_deaf = voiceState.self_deaf
        self.self_mute = voiceState.self_mute
        self.self_stream = voiceState.self_stream
        self.self_video = voiceState.self_video
        self.suppress = voiceState.suppress
        self.request_to_speak_timestamp = voiceState.request_to_speak_timestamp
    }
}

/// https://discord.com/developers/docs/resources/voice#voice-region-object-voice-region-structure
public struct VoiceRegion: Sendable, Codable {
    public var id: String
    public var name: String
    public var optimal: Bool
    public var deprecated: Bool
    public var custom: Bool
}

/// https://discord.com/developers/docs/topics/gateway-events#update-voice-state-gateway-voice-state-update-structure
public struct VoiceStateUpdate: Sendable, Codable {
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake?
    public var self_deaf: Bool
    public var self_mute: Bool

    /// For Gateway Voice-State update.
    public init(
        guildId: GuildSnowflake,
        channelId: ChannelSnowflake? = nil,
        selfMute: Bool,
        selfDeaf: Bool
    ) {
        self.guild_id = guildId
        self.channel_id = channelId
        self.self_mute = selfMute
        self.self_deaf = selfDeaf
    }

    private enum CodingKeys: CodingKey {
        case guild_id
        case channel_id
        case self_deaf
        case self_mute
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.guild_id, forKey: .guild_id)
        /// Need to encode `null` if `nil`, considering a Discord bug.
        /// So don't use `encodeIfPresent`.
        try container.encode(self.channel_id, forKey: .channel_id)
        try container.encode(self.self_deaf, forKey: .self_deaf)
        try container.encode(self.self_mute, forKey: .self_mute)
    }
}
