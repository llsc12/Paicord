/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct DiscordUser: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/user#user-object-premium-types
    @UnstableEnum<Int>
    public enum PremiumKind: Sendable, Codable {
        case none  // 0
        case nitroClassic  // 1
        case nitro  // 2
        case nitroBasic  // 3
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/user#user-object-user-flags
    @UnstableEnum<UInt>
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
        case __undocumented(UInt)
    }

    /// https://discord.com/developers/docs/resources/user#avatar-decoration-data-object
    public struct AvatarDecoration: Sendable, Codable {
        public var asset: String
        public var sku_id: SKUSnowflake
    }

    public var id: UserSnowflake
    public var username: String
    public var discriminator: String
    public var global_name: String?
    public var avatar: String?
    public var bot: Bool?
    public var system: Bool?
    public var mfa_enabled: Bool?
    public var banner: String?
    public var accent_color: DiscordColor?
    public var locale: DiscordLocale?
    public var verified: Bool?
    public var email: String?
    public var flags: IntBitField<Flag>?
    public var premium_type: PremiumKind?
    public var public_flags: IntBitField<Flag>?
    @available(*, deprecated, renamed: "avatar_decoration_data")
    public var avatar_decoration: String?
    public var avatar_decoration_data: AvatarDecoration?
}

/// A partial ``DiscordUser`` object.
/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct PartialUser: Sendable, Codable {
    public var id: UserSnowflake
    public var username: String?
    public var discriminator: String?
    public var global_name: String?
    public var avatar: String?
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
}

/// A ``DiscordUser`` with an extra `member` field.
/// https://discord.com/developers/docs/topics/gateway-events#message-create-message-create-extra-fields
/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct MentionUser: Sendable, Codable {
    public var id: UserSnowflake
    public var username: String
    public var discriminator: String
    public var global_name: String?
    public var avatar: String?
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
    public var member: Guild.PartialMember?
}

extension DiscordUser {
    /// https://discord.com/developers/docs/resources/user#connection-object-connection-structure
    public struct Connection: Sendable, Codable {

        /// https://discord.com/developers/docs/resources/user#connection-object-services
        ///
        /// FIXME: I'm not sure, maybe the values of cases are wrong?
        /// E.g.: `case epicGames`'s value should be just `epicgames` like in the docs?
        @UnstableEnum<String>
        public enum Service: Sendable, Codable {
            case battleNet  // "Battle.net"
            case bungie  // "Bungie.net"
            case domain  // Domain
            case ebay  // "eBay"
            case epicGames  // "Epic Games"
            case facebook  // "Facebook"
            case github  // "GitHub"
            case instagram  // "Instagram"
            case leagueOfLegends  // "League of Legends"
            case paypal  // "PayPal"
            case playstation  // "PlayStation Network"
            case reddit  // "Reddit"
            case riotGames  // "Riot Games"
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
        @UnstableEnum<Int>
        public enum VisibilityKind: Sendable, Codable {
            case none  // 0
            case everyone  // 1
            case __undocumented(Int)
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

    /// https://discord.com/developers/docs/resources/user#application-role-connection-object
    public struct ApplicationRoleConnection: Sendable, Codable, ValidatablePayload {
        public var platform_name: String?
        public var platform_username: String?
        public var metadata: [String: ApplicationRoleConnectionMetadata]

        public func validate() -> [ValidationFailure] {
            validateCharacterCountDoesNotExceed(platform_name, max: 50, name: "platform_name")
            validateCharacterCountDoesNotExceed(platform_username, max: 100, name: "platform_username")
        }
    }
}
