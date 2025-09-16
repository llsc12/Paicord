/// https://discord.com/developers/docs/monetization/entitlements#entitlement-object-entitlement-structure
public struct Entitlement: Sendable, Codable {

    @UnstableEnum<Int>
    public enum Kind: Sendable, Codable {
        case purchase  // 1
        case premiumSubscription  // 2
        case developerGift  // 3
        case testModePurchase  // 4
        case freePurchase  // 5
        case userGift  // 6
        case premiumPurchase  // 7
        case applicationSubscription  // 8
        case __undocumented(Int)
    }

    public var id: EntitlementSnowflake
    public var sku_id: SKUSnowflake
    public var application_id: ApplicationSnowflake
    public var user_id: UserSnowflake?
    public var type: Kind
    public var deleted: Bool
    public var starts_at: DiscordTimestamp?
    public var ends_at: DiscordTimestamp?
    public var guild_id: GuildSnowflake?
    public var consumed: Bool?
}
