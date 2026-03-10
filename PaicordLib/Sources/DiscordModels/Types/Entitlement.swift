/// https://discord.com/developers/docs/monetization/entitlements#entitlement-object-entitlement-structure
public struct Entitlement: Sendable, Codable {

  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum Kind: Sendable, Codable {
    case purchase  // 1
    case premiumSubscription  // 2
    case developerGift  // 3
    case testModePurchase  // 4
    case freePurchase  // 5
    case userGift  // 6
    case premiumPurchase  // 7
    case applicationSubscription  // 8
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
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
