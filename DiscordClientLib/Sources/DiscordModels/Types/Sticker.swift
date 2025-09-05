/// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-structure
public struct Sticker: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-types
    @UnstableEnum<Int>
    public enum Kind: Sendable, Codable {
        case standard  // 1
        case guild  // 2
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-format-types
    @UnstableEnum<Int>
    public enum FormatKind: Sendable, Codable {
        case png  // 1
        case apng  // 2
        case lottie  // 3
        case gif  // 4
        case __undocumented(Int)
    }

    public var id: StickerSnowflake
    public var pack_id: StickerPackSnowflake?
    public var name: String
    public var description: String?
    public var tags: String
    public var asset: String?
    public var type: Kind
    public var format_type: FormatKind
    public var available: Bool?
    public var guild_id: GuildSnowflake?
    public var user: DiscordUser?
    public var sort_value: Int?
}

/// https://discord.com/developers/docs/resources/sticker#sticker-item-object
public struct StickerItem: Sendable, Codable {
    public var id: StickerSnowflake
    public var name: String
    public var format_type: Sticker.FormatKind
}

/// https://discord.com/developers/docs/resources/sticker#sticker-pack-object-sticker-pack-structure
public struct StickerPack: Sendable, Codable {
    public var id: StickerPackSnowflake
    public var stickers: [Sticker]
    public var name: String
    public var sku_id: AnySnowflake
    public var cover_sticker_id: StickerSnowflake?
    public var description: String
    public var banner_asset_id: AssetsSnowflake?
}
