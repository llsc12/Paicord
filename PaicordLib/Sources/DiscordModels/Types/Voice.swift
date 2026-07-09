/// https://discord.com/developers/docs/resources/voice#voice-state-object-voice-state-structure
public struct VoiceState: Sendable, Codable {
  public var guild_id: GuildSnowflake?
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
  public var guild_id: GuildSnowflake?
  public var channel_id: ChannelSnowflake?
  public var self_mute: Bool
  public var self_deaf: Bool
  public var self_video: Bool?
  public var preferred_region: String?
  public var preferred_regions: [String]?
  public var flags: IntBitField<Flags>?

  public init(
    guild_id: GuildSnowflake? = nil,
    channel_id: ChannelSnowflake? = nil,
    self_mute: Bool,
    self_deaf: Bool,
    self_video: Bool? = nil,
    preferred_region: String? = nil,
    preferred_regions: [String]? = nil,
    flags: IntBitField<Flags>? = nil
  ) {
    self.guild_id = guild_id
    self.channel_id = channel_id
    self.self_mute = self_mute
    self.self_deaf = self_deaf
    self.self_video = self_video
    self.preferred_region = preferred_region
    self.preferred_regions = preferred_regions
    self.flags = flags
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    /// Need to encode `null` if `nil`, considering a Discord bug.
    /// So don't use `encodeIfPresent`.
    try container.encode(self.guild_id, forKey: .guild_id)
    try container.encode(self.channel_id, forKey: .channel_id)

    try container.encode(self.self_deaf, forKey: .self_deaf)
    try container.encode(self.self_mute, forKey: .self_mute)

    /// rest of the properties can be omitted if `nil`
    try container.encodeIfPresent(self.self_video, forKey: .self_video)
    try container.encodeIfPresent(
      self.preferred_region,
      forKey: .preferred_region
    )
    try container.encodeIfPresent(
      self.preferred_regions,
      forKey: .preferred_regions
    )
    try container.encodeIfPresent(self.flags, forKey: .flags)

  }

  private enum CodingKeys: String, CodingKey {
    case guild_id
    case channel_id
    case self_mute
    case self_deaf
    case self_video
    case preferred_region
    case preferred_regions
    case flags
  }

  /// https://docs.discord.food/topics/voice-connections#voice-flags
  #if Non64BitSystemsCompatibility
    @UnstableEnum<UInt64>
  #else
    @UnstableEnum<UInt>
  #endif
  public enum Flags: Sendable {
    case clipsEnabled  // 0
    case allowVoiceRecording  // 1
    case allowAnyViewerClips  // 2

    #if Non64BitSystemsCompatibility
      case __undocumented(UInt64)
    #else
      case __undocumented(UInt)
    #endif
  }
}
