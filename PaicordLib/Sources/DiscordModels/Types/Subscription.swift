
/// https://discord.com/developers/docs/resources/subscription#subscription-object
public struct Subscription: Sendable, Codable {

  /// https://discord.com/developers/docs/resources/subscription#subscription-statuses
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum Status: Sendable, Codable {
    case active  // 0
    case ending  // 1
    case inactive  // 2
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  public var id: SubscriptionSnowflake
  public var user_id: UserSnowflake
  public var sku_ids: [SKUSnowflake]
  public var entitlement_ids: [EntitlementSnowflake]
  public var renewal_sku_ids: [SKUSnowflake]?
  public var current_period_start: DiscordTimestamp
  public var current_period_end: DiscordTimestamp
  public var status: Status
  public var canceled_at: DiscordTimestamp?
  public var country: String?
}
