/// https://discord.com/developers/docs/resources/application#application-object-application-structure
public struct DiscordApplication: Sendable, Codable {

	/// https://discord.com/developers/docs/resources/application#application-object-application-flags
	@UnstableEnum<UInt>
	public enum Flag: Sendable {
		case applicationAutoModerationRuleCreateBadge  // 6
		case gatewayPresence  // 12
		case gatewayPresenceLimited  // 13
		case gatewayGuildMembers  // 14
		case gatewayGuildMembersLimited  // 15
		case verificationPendingGuildLimit  // 16
		case embedded  // 17
		case gatewayMessageContent  // 18
		case gatewayMessageContentLimited  // 19
		case applicationCommandBadge  // 23
		case __undocumented(UInt)
	}

	/// https://discord.com/developers/docs/resources/application#install-params-object
	public struct InstallParams: Sendable, Codable, Equatable, Hashable {
		public var scopes: [OAuth2Scope]
		public var permissions: StringBitField<Permission>

		public init(scopes: [OAuth2Scope], permissions: StringBitField<Permission>)
		{
			self.scopes = scopes
			self.permissions = permissions
		}
	}

	/// https://discord.com/developers/docs/resources/application#application-object-application-integration-types
	@_spi(UserInstallableApps)
	@UnstableEnum<Int>
	public enum IntegrationKind: Sendable, Codable, CodingKeyRepresentable,
		Equatable
	{
		case guildInstall  // 0
		case userInstall  // 1
		case __undocumented(Int)
	}

	/// https://discord.com/developers/docs/resources/application#application-object-application-integration-type-configuration-object
	@_spi(UserInstallableApps)
	public struct IntegrationKindConfiguration: Sendable, Codable, Equatable, Hashable {
		public var oauth2_install_params: InstallParams?

		public init(oauth2_install_params: InstallParams? = nil) {
			self.oauth2_install_params = oauth2_install_params
		}
	}

	public var id: ApplicationSnowflake
	public var name: String
	public var icon: String?
	public var description: String
	public var rpc_origins: [String]?
	public var bot_public: Bool
	public var bot_require_code_grant: Bool
	public var bot: PartialUser?
	public var terms_of_service_url: String?
	public var privacy_policy_url: String?
	public var owner: PartialUser?
	public var verify_key: String
	public var team: Team?
	public var guild_id: GuildSnowflake?
	public var guild: PartialGuild?
	public var primary_sku_id: SKUSnowflake?
	public var slug: String?
	public var cover_image: String?
	public var flags: IntBitField<Flag>?
	public var approximate_guild_count: Int?
	public var redirect_uris: [String]?
	public var interactions_endpoint_url: String?
	public var role_connections_verification_url: String?
	public var tags: [String]?
	public var install_params: InstallParams?
	@_spi(UserInstallableApps) @DecodeOrNil
	public var integration_types: [IntegrationKind]?
	@_spi(UserInstallableApps) @DecodeOrNil
	public var integration_types_config:
		[IntegrationKind: IntegrationKindConfiguration]?
	public var custom_install_url: String?
  
  /// https://docs.discord.food/resources/application#application-asset-object
  public struct Asset: Sendable, Codable, Equatable, Hashable {
    public var id: ApplicationAssetSnowflake
    public var type: Kind
    public var name: String
    
    /// https://docs.discord.food/resources/application#application-asset-type
    @UnstableEnum<UInt>
    public enum Kind: Sendable, Codable {
      case one // 1
      case two // 2
      case __undocumented(UInt)
    }
  }
}

/// https://discord.com/developers/docs/resources/application#application-object-application-structure
public struct PartialApplication: Sendable, Codable, Equatable, Hashable {
	public var id: ApplicationSnowflake
	public var name: String?
	public var icon: String?
	public var description: String?
	public var rpc_origins: [String]?
	public var bot_public: Bool?
	public var bot_require_code_grant: Bool?
	public var bot: PartialUser?
	public var terms_of_service_url: String?
	public var privacy_policy_url: String?
	public var owner: PartialUser?
	public var verify_key: String?
	public var team: Team?
	public var guild_id: GuildSnowflake?
	public var guild: PartialGuild?
	public var primary_sku_id: SKUSnowflake?
	public var slug: String?
	public var cover_image: String?
	public var flags: IntBitField<DiscordApplication.Flag>?
	public var approximate_guild_count: Int?
	public var redirect_uris: [String]?
	public var interactions_endpoint_url: String?
	public var role_connections_verification_url: String?
	public var tags: [String]?
	public var install_params: DiscordApplication.InstallParams?
	@_spi(UserInstallableApps) @DecodeOrNil
	public var integration_types: [DiscordApplication.IntegrationKind]?
	@_spi(UserInstallableApps) @DecodeOrNil
	public var integration_types_config:
		[DiscordApplication.IntegrationKind: DiscordApplication
			.IntegrationKindConfiguration]?
	public var custom_install_url: String?
}

/// https://docs.discord.food/resources/application#get-embedded-activities
public struct EmbeddedActivities: Sendable, Codable, Equatable, Hashable {
  public var activities: [ActivityConfiguration]
  public var applications: [PartialApplication]
  public var assets: [ApplicationAssetSnowflake: [DiscordApplication.Asset]]
  
  /// https://docs.discord.food/resources/application#embedded-activity-config-object
  public struct ActivityConfiguration: Sendable, Codable, Equatable, Hashable {
    public var application_id: ApplicationSnowflake?
    public var activity_preview_video_asset_id: ApplicationAssetSnowflake?
    public var supported_platforms: [SupportedPlatform]
    public var default_orientation_lock_state: OrientationLockState
    public var tablet_default_orientation_lock_state: OrientationLockState
    public var requires_age_gate: Bool
    public var legacy_responsive_aspect_ratio: Bool
    public var client_platform_config: [String: PlatformConfiguration]
    public var shelf_rank: Int
    public var has_csp_exception: Bool
    public var displays_advertisements: Bool
    
    @UnstableEnum<String>
    public enum SupportedPlatform: Sendable, Codable {
      case web
      case ios
      case android
      case __undocumented(String)
    }
    
    @UnstableEnum<UInt>
    public enum OrientationLockState: Sendable, Codable {
      case unlocked // 0
      case portrait // 1
      case landscape // 2
      case __undocumented(UInt)
    }
    
    public struct PlatformConfiguration: Sendable, Codable, Equatable, Hashable {
      public var label_type: LabelType
      public var label_until: DiscordTimestamp?
      public var release_phase: ReleasePhase
      public var omit_badge_from_surfaces: [String]
      
      @UnstableEnum<UInt>
      public enum LabelType: Sendable, Codable {
        case none // 0
        case new // 1
        case updated // 2
        case __undocumented(UInt)
      }
      
      @UnstableEnum<String>
      public enum ReleasePhase: Sendable, Codable {
        case inDevelopment // in_development
        case activitiesTeam // activities_team
        case employeeRelease // employee_release
        case softLaunch // soft_launch
        case softLaunchMultiGeo // soft_launch_multi_geo
        case globalLaunch // global_launch
        case __undocumented(String)
      }
    }
  }
}
