/// https://discord.com/developers/docs/monetization/skus#sku-object-sku-structure
public struct SKU: Sendable, Codable {

  /// https://discord.com/developers/docs/monetization/skus#sku-object-sku-types
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum Kind: Sendable, Codable {
    case durable  // 2
    case consumable  // 3
    case subscription  // 5
    case subscriptionGroup  // 6
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/monetization/skus#sku-object-sku-flags
  #if Non64BitSystemsCompatibility
    @UnstableEnum<UInt64>
  #else
    @UnstableEnum<UInt>
  #endif
  public enum Flag: Sendable {
    case available  // 2
    case guildSubscription  // 7
    case userSubscription  // 8

    #if Non64BitSystemsCompatibility
      case __undocumented(UInt64)
    #else
      case __undocumented(UInt)
    #endif
  }

  public var id: SKUSnowflake
  public var type: Kind
  public var application_id: ApplicationSnowflake
  public var name: String
  public var slug: String
  public var flags: IntBitField<Flag>
}
