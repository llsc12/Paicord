/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct DiscordUser: Sendable, Codable, Equatable, Hashable {

	public init(
		id: UserSnowflake,
		username: String,
		discriminator: String,
		global_name: String? = nil,
		avatar: String? = nil,
		bot: Bool? = nil,
		system: Bool? = nil,
		mfa_enabled: Bool? = nil,
		banner: String? = nil,
		accent_color: DiscordColor? = nil,
		locale: DiscordLocale? = nil,
		verified: Bool? = nil,
		email: String? = nil,
		flags: IntBitField<Flag>? = nil,
		premium_type: PremiumKind? = nil,
		public_flags: IntBitField<Flag>? = nil,
		collectibles: Collectibles? = nil,
		avatar_decoration_data: AvatarDecoration? = nil
	) {
		self.id = id
		self.username = username
		self.discriminator = discriminator
		self.global_name = global_name
		self.avatar = avatar
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
	}

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
	public struct AvatarDecoration: Sendable, Codable, Equatable, Hashable {
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
	public var collectibles: Collectibles?
	public var avatar_decoration_data: AvatarDecoration?

	/// https://docs.discord.food/resources/user#collectibles-structure
	public struct Collectibles: Sendable, Codable, Equatable, Hashable {
    public init(nameplate: Nameplate? = nil) {
      self.nameplate = nameplate
    }
    
		public var nameplate: Nameplate?

		/// https://docs.discord.food/resources/user#nameplate-data-structure
		public struct Nameplate: Sendable, Codable, Equatable, Hashable {
      public init(asset: String, sku_id: SKUSnowflake, label: String, palette: ColorPalette, expires_at: DiscordTimestamp? = nil) {
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
}

extension DiscordUser.Collectibles.Nameplate.ColorPalette {
	public var color: (light: DiscordColor, dark: DiscordColor) {
		//		[r.P.Crimson]: {
		//				darkBackground: "#900007",
		//				lightBackground: "#E7040F",
		//				name: r.P.Crimson
		//		},
		//		[r.P.Berry]: {
		//				darkBackground: "#893A99",
		//				lightBackground: "#B11FCF",
		//				name: r.P.Berry
		//		},
		//		[r.P.Sky]: {
		//				darkBackground: "#0080B7",
		//				lightBackground: "#56CCFF",
		//				name: r.P.Sky
		//		},
		//		[r.P.Teal]: {
		//				darkBackground: "#086460",
		//				lightBackground: "#7DEED7",
		//				name: r.P.Teal
		//		},
		//		[r.P.Forest]: {
		//				darkBackground: "#2D5401",
		//				lightBackground: "#6AA624",
		//				name: r.P.Forest
		//		},
		//		[r.P.BubbleGum]: {
		//				darkBackground: "#DC3E97",
		//				lightBackground: "#F957B3",
		//				name: r.P.BubbleGum
		//		},
		//		[r.P.Violet]: {
		//				darkBackground: "#730BC8",
		//				lightBackground: "#972FED",
		//				name: r.P.Violet
		//		},
		//		[r.P.Cobalt]: {
		//				darkBackground: "#0131C2",
		//				lightBackground: "#4278FF",
		//				name: r.P.Cobalt
		//		},
		//		[r.P.Clover]: {
		//				darkBackground: "#047B20",
		//				lightBackground: "#63CD5A",
		//				name: r.P.Clover
		//		},
		//		[r.P.Lemon]: {
		//				darkBackground: "#F6CD12",
		//				lightBackground: "#FED400",
		//				name: r.P.Lemon
		//		},
		//		[r.P.White]: {
		//				darkBackground: "#FFFFFF",
		//				lightBackground: "#FFFFFF",
		//				name: r.P.White
		//		}

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
public struct MentionUser: Sendable, Codable, Equatable, Hashable {
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
	public struct ApplicationRoleConnection: Sendable, Codable, ValidatablePayload
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
}
