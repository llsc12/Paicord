/// https://discord.com/developers/docs/resources/stage-instance#stage-instance-object
public struct StageInstance: Sendable, Codable {

  /// https://discord.com/developers/docs/resources/stage-instance#stage-instance-object-privacy-level
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum PrivacyLevel: Sendable, Codable {
    case `public`  // 1
    case guildOnly  // 2
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  public var id: StageInstanceSnowflake
  public var guild_id: GuildSnowflake
  public var channel_id: ChannelSnowflake
  public var topic: String
  public var privacy_level: PrivacyLevel
  public var discoverable_disabled: Bool
  public var guild_scheduled_event_id: GuildScheduledEventSnowflake?
}
