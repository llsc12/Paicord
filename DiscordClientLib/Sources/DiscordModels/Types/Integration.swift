/// https://discord.com/developers/docs/resources/guild#integration-object
public struct Integration: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/guild#integration-object-integration-structure
    @UnstableEnum<String>
    public enum Kind: Sendable, Codable {
        case twitch
        case youtube
        case discord
        case guildSubscription  // "guild_subscription"
        case __undocumented(String)
    }

    /// https://discord.com/developers/docs/resources/guild#integration-object-integration-expire-behaviors
    @UnstableEnum<Int>
    public enum ExpireBehavior: Sendable, Codable {
        case removeRole  // 0
        case kick  // 1
        case __undocumented(Int)
    }

    public var id: IntegrationSnowflake
    public var name: String
    public var type: Kind
    public var enabled: Bool
    public var syncing: Bool?
    public var role_id: RoleSnowflake?
    public var enable_emoticons: Bool?
    public var expire_behavior: ExpireBehavior?
    public var expire_grace_period: Int?
    public var user: DiscordUser?
    public var account: IntegrationAccount
    public var synced_at: DiscordTimestamp?
    public var subscriber_count: Int?
    public var revoked: Bool?
    public var application: IntegrationApplication?
    public var scopes: [OAuth2Scope]?

    public init(integrationCreate: Gateway.IntegrationCreate) {
        self.id = integrationCreate.id
        self.name = integrationCreate.name
        self.type = integrationCreate.type
        self.enabled = integrationCreate.enabled
        self.syncing = integrationCreate.syncing
        self.role_id = integrationCreate.role_id
        self.enable_emoticons = integrationCreate.enable_emoticons
        self.expire_behavior = integrationCreate.expire_behavior
        self.expire_grace_period = integrationCreate.expire_grace_period
        self.user = integrationCreate.user
        self.account = integrationCreate.account
        self.synced_at = integrationCreate.synced_at
        self.subscriber_count = integrationCreate.subscriber_count
        self.revoked = integrationCreate.revoked
        self.application = integrationCreate.application
        self.scopes = integrationCreate.scopes
    }
}

/// https://discord.com/developers/docs/resources/guild#integration-object
public struct PartialIntegration: Sendable, Codable {
    public var id: IntegrationSnowflake
    public var name: String?
    public var type: Integration.Kind?
    public var enabled: Bool?
    public var syncing: Bool?
    public var role_id: RoleSnowflake?
    public var enable_emoticons: Bool?
    public var expire_behavior: Integration.ExpireBehavior?
    public var expire_grace_period: Int?
    public var user: DiscordUser?
    public var account: IntegrationAccount?
    public var synced_at: DiscordTimestamp?
    public var subscriber_count: Int?
    public var revoked: Bool?
    public var application: IntegrationApplication?
    public var scopes: [OAuth2Scope]?
}
