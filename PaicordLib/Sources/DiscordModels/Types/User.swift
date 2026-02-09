/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct DiscordUser: Sendable, Codable, Equatable, Hashable {

  public init(
    id: UserSnowflake,
    username: String,
    discriminator: String,
    global_name: String? = nil,
    avatar: String? = nil,
    banner: String? = nil,
    bot: Bool? = nil,
    system: Bool? = nil,
    mfa_enabled: Bool? = nil,
    pronouns: String? = nil,
    accent_color: DiscordColor? = nil,
    locale: DiscordLocale? = nil,
    verified: Bool? = nil,
    email: String? = nil,
    flags: IntBitField<Flag>? = nil,
    premium_type: PremiumKind? = nil,
    public_flags: IntBitField<Flag>? = nil,
    collectibles: Collectibles? = nil,
    avatar_decoration_data: AvatarDecoration? = nil,
    primary_guild: PrimaryGuild? = nil
  ) {
    self.id = id
    self.username = username
    self.discriminator = discriminator
    self.global_name = global_name
    self.avatar = avatar
    self.banner = banner
    self.pronouns = pronouns
    self.bot = bot
    self.system = system
    self.mfa_enabled = mfa_enabled
    self.banner = banner
    self.accent_color = accent_color
    self.locale = locale
    self.verified = verified
    self.email = email
    self.flags = flags
    self.premium_type = premium_type
    self.public_flags = public_flags
    self.collectibles = collectibles
    self.avatar_decoration_data = avatar_decoration_data
    self.primary_guild = primary_guild
  }

  /// https://discord.com/developers/docs/resources/user#user-object-premium-types
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum PremiumKind: Sendable, Codable {
    case none  // 0
    case nitroClassic  // 1
    case nitro  // 2
    case nitroBasic  // 3
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/user#user-object-user-flags
  #if Non64BitSystemsCompatibility
    @UnstableEnum<UInt64>
  #else
    @UnstableEnum<UInt>
  #endif
  public enum Flag: Sendable {
    case staff  // 0
    case partner  // 1
    case hypeSquad  // 2
    case BugHunterLevel1  // 3
    case hypeSquadOnlineHouse1  // 6
    case hypeSquadOnlineHouse2  // 7
    case hypeSquadOnlineHouse3  // 8
    case premiumEarlySupporter  // 9
    case teamPseudoUser  // 10
    case bugHunterLevel2  // 14
    case verifiedBot  // 16
    case verifiedDeveloper  // 17
    case certifiedModerator  // 18
    case botHttpInteractions  // 19
    case activeDeveloper  // 22

    #if Non64BitSystemsCompatibility
      case __undocumented(UInt64)
    #else
      case __undocumented(UInt)
    #endif
  }

  /// https://discord.com/developers/docs/resources/user#avatar-decoration-data-object
  public struct AvatarDecoration: Sendable, Codable, Equatable, Hashable {
    public var asset: String
    public var sku_id: SKUSnowflake

    public init(asset: String, sku_id: SKUSnowflake) {
      self.asset = asset
      self.sku_id = sku_id
    }
  }

  public var id: UserSnowflake
  public var username: String
  public var discriminator: String
  public var global_name: String?
  public var avatar: String?
  public var banner: String?
  public var bot: Bool?
  public var system: Bool?
  public var mfa_enabled: Bool?
  public var pronouns: String?
  public var accent_color: DiscordColor?
  public var locale: DiscordLocale?
  public var verified: Bool?
  public var email: String?
  public var flags: IntBitField<Flag>?
  public var premium_type: PremiumKind?
  public var public_flags: IntBitField<Flag>?
  @available(*, deprecated, renamed: "avatar_decoration_data")
  public var avatar_decoration: String?
  public var collectibles: Collectibles?
  public var avatar_decoration_data: AvatarDecoration?
  public var primary_guild: PrimaryGuild?

  /// https://docs.discord.food/resources/user#collectibles-structure
  public struct Collectibles: Sendable, Codable, Equatable, Hashable {
    public init(nameplate: Nameplate? = nil) {
      self.nameplate = nameplate
    }

    public var nameplate: Nameplate?

    /// https://docs.discord.food/resources/user#nameplate-data-structure
    public struct Nameplate: Sendable, Codable, Equatable, Hashable {
      public init(
        asset: String,
        sku_id: SKUSnowflake,
        label: String,
        palette: ColorPalette,
        expires_at: DiscordTimestamp? = nil
      ) {
        self.asset = asset
        self.sku_id = sku_id
        self.label = label
        self.palette = palette
        self.expires_at = expires_at
      }

      public var asset: String
      public var sku_id: SKUSnowflake
      public var label: String
      public var palette: ColorPalette
      public var expires_at: DiscordTimestamp?

      @UnstableEnum<String>
      public enum ColorPalette: Sendable, Codable {
        case none
        case crimson
        case berry
        case sky
        case teal
        case forest
        case bubble_gum
        case violet
        case cobalt
        case clover
        case lemon
        case white
        case __undocumented(String)
      }
    }
  }

  /// https://docs.discord.food/resources/user#get-user-profile
  public struct Profile: Sendable, Codable, Equatable, Hashable {
    public var application: ProfileApplication?
    public var user: PartialUser
    public var user_profile: Metadata?
    public var badges: [Badge]?
    public var guild_member: Guild.Member?
    public var guild_member_profile: Metadata?
    public var guild_badges: [Badge]?
    public var legacy_username: String?
    public var mutual_guilds: [MutualGuild]?
    public var mutual_friends: [PartialUser]?
    public var mutual_friends_count: Int?
    public var connected_accounts: [PartialConnection]?
    public var application_role_connections: [ApplicationRoleConnection]?
    public var premium_type: PremiumKind?
    public var premium_since: DiscordTimestamp?
    public var premium_guild_since: DiscordTimestamp?

    public init(
      application: ProfileApplication? = nil,
      user: PartialUser,
      user_profile: Metadata? = nil,
      badges: [Badge]? = nil,
      guild_member: Guild.Member? = nil,
      guild_member_profile: Metadata? = nil,
      guild_badges: [Badge]? = nil,
      legacy_username: String? = nil,
      mutual_guilds: [MutualGuild]? = nil,
      mutual_friends: [PartialUser]? = nil,
      mutual_friends_count: Int? = nil,
      connected_accounts: [PartialConnection]? = nil,
      application_role_connections: [ApplicationRoleConnection]? = nil,
      premium_type: PremiumKind? = nil,
      premium_since: DiscordTimestamp? = nil,
      premium_guild_since: DiscordTimestamp? = nil
    ) {
      self.application = application
      self.user = user
      self.user_profile = user_profile
      self.badges = badges
      self.guild_member = guild_member
      self.guild_member_profile = guild_member_profile
      self.guild_badges = guild_badges
      self.legacy_username = legacy_username
      self.mutual_guilds = mutual_guilds
      self.mutual_friends = mutual_friends
      self.mutual_friends_count = mutual_friends_count
      self.connected_accounts = connected_accounts
      self.application_role_connections = application_role_connections
      self.premium_type = premium_type
      self.premium_since = premium_since
      self.premium_guild_since = premium_guild_since
    }

    /// https://docs.discord.food/resources/user#profile-application-structure
    public struct ProfileApplication: Sendable, Codable, Equatable, Hashable {
    }

    /// https://docs.discord.food/resources/user#profile-metadata-object
    public struct Metadata: Sendable, Codable, Equatable, Hashable {
      public var guild_id: GuildSnowflake?
      public var pronouns: String?
      public var bio: String?
      public var banner: String?
      public var accent_color: DiscordColor?  // Not respected on guild profiles
      public var theme_colors: [DiscordColor]?  // 2 values if present, as two gradient stops

      //      public var popout_animation_particle_type: Int? // dolfies said these r unused
      //      public var emoji: Emoji?

      public var profile_effect: Effect?

      public init(
        guild_id: GuildSnowflake? = nil,
        pronouns: String? = nil,
        bio: String? = nil,
        banner: String? = nil,
        accent_color: DiscordColor? = nil,
        theme_colors: [DiscordColor]? = nil,
        profile_effect: Effect? = nil
      ) {
        self.guild_id = guild_id
        self.pronouns = pronouns
        self.bio = bio
        self.banner = banner
        self.accent_color = accent_color
        self.theme_colors = theme_colors
        self.profile_effect = profile_effect
      }
    }

    /// https://docs.discord.food/resources/user#profile-effect-structure
    public struct Effect: Sendable, Codable, Equatable, Hashable {
      public var id: AnySnowflake
      public var expires_at: DiscordTimestamp?

      public init(id: AnySnowflake, expires_at: DiscordTimestamp? = nil) {
        self.id = id
        self.expires_at = expires_at
      }
    }

    /// https://docs.discord.food/resources/user#profile-badge-structure
    public struct Badge: Sendable, Codable, Equatable, Hashable, Identifiable {
      public var id: AnySnowflake
      public var description: String
      public var icon: String
      public var link: String?

      public init(
        id: AnySnowflake,
        description: String,
        icon: String,
        link: String? = nil
      ) {
        self.id = id
        self.description = description
        self.icon = icon
        self.link = link
      }
    }

    /// https://docs.discord.food/resources/user#mutual-guild-structure
    public struct MutualGuild: Sendable, Codable, Equatable, Hashable {
      public var id: GuildSnowflake
      public var nick: String?

      public init(id: GuildSnowflake, nick: String? = nil) {
        self.id = id
        self.nick = nick
      }
    }
  }
}

extension DiscordUser.Collectibles.Nameplate.ColorPalette {
  public var color: (light: DiscordColor, dark: DiscordColor) {
    switch self {
    case .crimson:
      return (light: .init(hex: "#E7040F")!, dark: .init(hex: "#900007")!)
    case .berry:
      return (light: .init(hex: "#B11FCF")!, dark: .init(hex: "#893A99")!)
    case .sky:
      return (light: .init(hex: "#56CCFF")!, dark: .init(hex: "#0080B7")!)
    case .teal:
      return (light: .init(hex: "#7DEED7")!, dark: .init(hex: "#086460")!)
    case .forest:
      return (light: .init(hex: "#6AA624")!, dark: .init(hex: "#2D5401")!)
    case .bubble_gum:
      return (light: .init(hex: "#F957B3")!, dark: .init(hex: "#DC3E97")!)
    case .violet:
      return (light: .init(hex: "#972FED")!, dark: .init(hex: "#730BC8")!)
    case .cobalt:
      return (light: .init(hex: "#4278FF")!, dark: .init(hex: "#0131C2")!)
    case .clover:
      return (light: .init(hex: "#63CD5A")!, dark: .init(hex: "#047B20")!)
    case .lemon:
      return (light: .init(hex: "#FED400")!, dark: .init(hex: "#F6CD12")!)
    case .white:
      return (light: .init(hex: "#FFFFFF")!, dark: .init(hex: "#FFFFFF")!)
    case .none, .__undocumented:
      return (light: .init(hex: "#000000")!, dark: .init(hex: "#000000")!)
    }
  }
}

/// A partial ``DiscordUser`` object.
/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct PartialUser: Sendable, Codable, Equatable, Hashable {
  public var id: UserSnowflake
  public var username: String?
  public var discriminator: String?
  public var global_name: String?
  public var avatar: String?
  public var banner: String?
  public var pronouns: String?
  public var avatar_decoration_data: DiscordUser.AvatarDecoration?
  public var collectibles: DiscordUser.Collectibles?
  public var primary_guild: DiscordUser.PrimaryGuild?
  public var bot: Bool?
  public var system: Bool?
  public var accent_color: DiscordColor?
  public var public_flags: IntBitField<DiscordUser.Flag>?

  public init(
    id: UserSnowflake,
    username: String? = nil,
    discriminator: String? = nil,
    global_name: String? = nil,
    avatar: String? = nil,
    banner: String? = nil,
    pronouns: String? = nil,
    avatar_decoration_data: DiscordUser.AvatarDecoration? = nil,
    collectibles: DiscordUser.Collectibles? = nil,
    primary_guild: DiscordUser.PrimaryGuild? = nil,
    bot: Bool? = nil,
    system: Bool? = nil,
    accent_color: DiscordColor? = nil,
    public_flags: IntBitField<DiscordUser.Flag>? = nil
  ) {
    self.id = id
    self.username = username
    self.discriminator = discriminator
    self.global_name = global_name
    self.avatar = avatar
    self.banner = banner
    self.pronouns = pronouns
    self.avatar_decoration_data = avatar_decoration_data
    self.collectibles = collectibles
    self.primary_guild = primary_guild
    self.bot = bot
    self.system = system
    self.accent_color = accent_color
    self.public_flags = public_flags
  }
}

/// A ``DiscordUser`` with an extra `member` field.
/// https://discord.com/developers/docs/topics/gateway-events#message-create-message-create-extra-fields
/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct MentionUser: Sendable, Codable, Equatable, Hashable {
  public var id: UserSnowflake
  public var username: String
  public var discriminator: String
  public var global_name: String?
  public var avatar: String?
  public var pronouns: String?
  public var bot: Bool?
  public var system: Bool?
  public var mfa_enabled: Bool?
  public var banner: String?
  public var accent_color: DiscordColor?
  public var locale: DiscordLocale?
  public var verified: Bool?
  public var email: String?
  public var flags: IntBitField<DiscordUser.Flag>?
  public var premium_type: DiscordUser.PremiumKind?
  public var public_flags: IntBitField<DiscordUser.Flag>?
  @available(*, deprecated, renamed: "avatar_decoration_data")
  public var avatar_decoration: String?
  public var avatar_decoration_data: DiscordUser.AvatarDecoration?
  public var collectibles: DiscordUser.Collectibles?
  public var primary_guild: DiscordUser.PrimaryGuild?
  public var member: Guild.PartialMember?
}

extension DiscordUser {
  /// https://discord.com/developers/docs/resources/user#connection-object-connection-structure
  /// https://docs.discord.food/resources/connected-accounts#connection-structure
  public struct Connection: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/user#connection-object-services
    ///
    /// FIXME: I'm not sure, maybe the values of cases are wrong?
    /// E.g.: `case epicGames`'s value should be just `epicgames` like in the docs?
    @UnstableEnum<String>
    public enum Service: Sendable, Codable {
      case amazonMusic  // "Amazon Music"
      case battleNet  // "Battle.net"
      case bungie  // "Bungie.net"
      case bluesky  // "Bluesky"
      case crunchyroll  // "Crunchyroll"
      case domain  // Domain
      case ebay  // "eBay"
      case epicGames  // "Epic Games"
      case facebook  // "Facebook"
      case github  // "GitHub"
      case instagram  // "Instagram"
      case leagueOfLegends  // "League of Legends"
      case mastodon  // "Mastodon"
      case paypal  // "PayPal"
      case playstation  // "PlayStation Network"
      case reddit  // "Reddit"
      case riotGames  // "Riot Games"
      case roblox  // "Roblox"
      case spotify  // "Spotify"
      case skype  // "Skype"
      case steam  // "Steam"
      case tikTok  // "TikTok"
      case twitch  // "Twitch"
      case twitter  // "Twitter"
      case xbox  // "Xbox"
      case youtube  // "YouTube"
      case __undocumented(String)
    }

    /// https://discord.com/developers/docs/resources/user#connection-object-visibility-types
    #if Non64BitSystemsCompatibility
      @UnstableEnum<Int64>
    #else
      @UnstableEnum<Int>
    #endif
    public enum VisibilityKind: Sendable, Codable {
      case none  // 0
      case everyone  // 1
      #if Non64BitSystemsCompatibility
        case __undocumented(Int64)
      #else
        case __undocumented(Int)
      #endif
    }

    public var id: String
    public var name: String
    public var type: Service
    public var revoked: Bool?
    public var integrations: [PartialIntegration]?
    public var verified: Bool
    public var friend_sync: Bool
    public var show_activity: Bool
    public var two_way_link: Bool
    public var visibility: VisibilityKind
  }

  /// https://docs.discord.food/resources/connected-accounts#partial-connection-structure
  public struct PartialConnection: Sendable, Codable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var type: Connection.Service
    public var verified: Bool
  }

  /// https://discord.com/developers/docs/resources/user#application-role-connection-object
  public struct ApplicationRoleConnection: Sendable, Codable, Equatable,
    Hashable, ValidatablePayload
  {
    public var platform_name: String?
    public var platform_username: String?
    public var metadata: [String: ApplicationRoleConnectionMetadata]

    public func validate() -> [ValidationFailure] {
      validateCharacterCountDoesNotExceed(
        platform_name,
        max: 50,
        name: "platform_name"
      )
      validateCharacterCountDoesNotExceed(
        platform_username,
        max: 100,
        name: "platform_username"
      )
    }
  }

  public struct PrimaryGuild: Sendable, Codable, Equatable, Hashable {
    public var identity_enabled: Bool?
    public var identity_guild_id: GuildSnowflake?
    public var tag: String?
    public var badge: String?

    public init(
      identity_enabled: Bool? = nil,
      identity_guild_id: GuildSnowflake? = nil,
      tag: String? = nil,
      badge: String? = nil
    ) {
      self.identity_enabled = identity_enabled
      self.identity_guild_id = identity_guild_id
      self.tag = tag
      self.badge = badge
    }
  }
}
