/// https://discord.com/developers/docs/topics/teams#data-models-team-object
public struct Team: Sendable, Codable, Equatable, Hashable {

  /// https://discord.com/developers/docs/topics/teams#data-models-team-member-object
  public struct Member: Sendable, Codable, Equatable, Hashable {

    /// https://discord.com/developers/docs/topics/teams#data-models-membership-state-enum
    #if Non64BitSystemsCompatibility
      @UnstableEnum<Int64>
    #else
      @UnstableEnum<Int>
    #endif
    public enum State: Sendable, Codable {
      case invited  // 1
      case accepted  // 2
      #if Non64BitSystemsCompatibility
        case __undocumented(Int64)
      #else
        case __undocumented(Int)
      #endif
    }

    /// https://discord.com/developers/docs/topics/teams#data-models-team-member-role-types
    @UnstableEnum<String>
    public enum Role: Sendable, Codable {
      case admin  // admin
      case developer  // developer
      case readOnly  // read_only
      case __undocumented(String)
    }

    public var membership_state: State
    @available(
      *,
      deprecated,
      message: "Will always be `[\"*\"]` when sent by Discord"
    )
    public var permissions: [String]
    public var team_id: TeamSnowflake?
    public var user: PartialUser
    public var role: Role
  }

  public var icon: String?
  public var id: TeamSnowflake
  public var members: [Member]
  public var name: String
  public var owner_user_id: UserSnowflake
}
