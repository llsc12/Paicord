/// https://discord.com/developers/docs/resources/invite#invite-object-invite-structure
public struct Invite: Sendable, Codable {

  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum Kind: Sendable, Codable {
    case guild  // 0
    case groupDm  // 1
    case friend  // 2
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/invite#invite-object-invite-target-types
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum TargetKind: Sendable, Codable {
    case stream  // 1
    case embeddedApplication  // 2
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  public var type: Kind
  public var code: String
  public var guild: PartialGuild?
  public var channel: DiscordChannel?
  public var inviter: DiscordUser?
  public var target_type: TargetKind?
  public var target_user: DiscordUser?
  public var target_application: PartialApplication?
  public var approximate_presence_count: Int?
  public var approximate_member_count: Int?
  public var expires_at: DiscordTimestamp?
  public var guild_scheduled_event: GuildScheduledEvent?
}

/// https://discord.com/developers/docs/resources/invite#invite-object-invite-structure
/// https://discord.com/developers/docs/resources/invite#invite-metadata-object-invite-metadata-structure
public struct InviteWithMetadata: Sendable, Codable {
  public var type: Invite.Kind
  public var code: String
  public var guild: PartialGuild?
  public var channel: DiscordChannel?
  public var inviter: DiscordUser?
  public var target_type: Invite.TargetKind?
  public var target_user: DiscordUser?
  public var target_application: PartialApplication?
  public var approximate_presence_count: Int?
  public var approximate_member_count: Int?
  public var expires_at: DiscordTimestamp?
  public var guild_scheduled_event: GuildScheduledEvent?
  public var uses: Int
  public var max_uses: Int
  public var max_age: Int
  public var temporary: Bool
  public var created_at: DiscordTimestamp
}

/// https://discord.com/developers/docs/resources/invite#invite-object-invite-structure
public struct PartialInvite: Sendable, Codable {
  public var type: Invite.Kind?
  public var code: String?
  public var guild: PartialGuild?
  public var channel: DiscordChannel?
  public var inviter: DiscordUser?
  public var target_type: Invite.TargetKind?
  public var target_user: DiscordUser?
  public var target_application: PartialApplication?
  public var approximate_presence_count: Int?
  public var approximate_member_count: Int?
  public var expires_at: DiscordTimestamp?
  public var guild_scheduled_event: GuildScheduledEvent?
}
