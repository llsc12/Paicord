import DiscordModels
import NIOHTTP1

/// CDN Endpoints.
/// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
public enum CDNEndpoint: Endpoint {
    case customEmoji(emojiId: EmojiSnowflake)
    case guildIcon(guildId: GuildSnowflake, icon: String)
    case guildSplash(guildId: GuildSnowflake, splash: String)
    case guildDiscoverySplash(guildId: GuildSnowflake, splash: String)
    case guildBanner(guildId: GuildSnowflake, banner: String)
    case userBanner(userId: UserSnowflake, banner: String)
    case defaultUserAvatar(discriminator: String)
    case userAvatar(userId: UserSnowflake, avatar: String)
    case guildMemberAvatar(guildId: GuildSnowflake, userId: UserSnowflake, avatar: String)
    case userAvatarDecoration(userId: UserSnowflake, avatarDecoration: String)
    case avatarDecoration(asset: String)
    case applicationIcon(appId: ApplicationSnowflake, icon: String)
    case applicationCover(appId: ApplicationSnowflake, cover: String)
    case applicationAsset(
        appId: ApplicationSnowflake,
        assetId: AssetsSnowflake
    )
    /// FIXME: `achievementId` should be of type `Snowflake<Achievement>` but
    /// `DiscordBM` doesn't have the `Achievement` type.
    case achievementIcon(
        appId: ApplicationSnowflake,
        achievementId: AnySnowflake,
        icon: String
    )
    case storePageAsset(
        appId: ApplicationSnowflake,
        assetId: AssetsSnowflake
    )
    case stickerPackBanner(assetId: AssetsSnowflake)
    case teamIcon(teamId: TeamSnowflake, icon: String)
    case sticker(stickerId: StickerSnowflake)
    case roleIcon(roleId: RoleSnowflake, icon: String)
    case guildScheduledEventCover(eventId: GuildScheduledEventSnowflake, cover: String)
    case guildMemberBanner(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        banner: String
    )

    /// This case serves as a way of discouraging exhaustive switch statements
    case __DO_NOT_USE_THIS_CASE

    var urlSuffix: String {
        let suffix: String
        switch self {
        case let .customEmoji(emojiId):
            suffix = "emojis/\(emojiId.rawValue)"
        case let .guildIcon(guildId, icon):
            suffix = "icons/\(guildId.rawValue)/\(icon)"
        case let .guildSplash(guildId, splash):
            suffix = "splashes/\(guildId.rawValue)/\(splash)"
        case let .guildDiscoverySplash(guildId, splash):
            suffix = "discovery-splashes/\(guildId.rawValue)/\(splash)"
        case let .guildBanner(guildId, banner):
            suffix = "banners/\(guildId.rawValue)/\(banner)"
        case let .userBanner(userId, banner):
            suffix = "banners/\(userId.rawValue)/\(banner)"
        case let .defaultUserAvatar(discriminator):
            suffix = "embed/avatars/\(discriminator).png"
        /// Needs `.png`
        case let .userAvatar(userId, avatar):
            suffix = "avatars/\(userId.rawValue)/\(avatar)"
        case let .guildMemberAvatar(guildId, userId, avatar):
            suffix = "guilds/\(guildId.rawValue)/users/\(userId.rawValue)/avatars/\(avatar)"
        case let .userAvatarDecoration(userId, avatarDecoration):
            suffix = "avatar-decorations/\(userId.rawValue)/\(avatarDecoration)"
        case let .avatarDecoration(asset):
            suffix = "avatar-decoration-presets/\(asset)"
        case let .applicationIcon(appId, icon):
            suffix = "app-icons/\(appId.rawValue)/\(icon)"
        case let .applicationCover(appId, cover):
            suffix = "app-icons/\(appId.rawValue)/\(cover)"
        case let .applicationAsset(appId, assetId):
            suffix = "app-assets/\(appId.rawValue)/\(assetId.rawValue)"
        case let .achievementIcon(appId, achievementId, icon):
            suffix = "app-assets/\(appId.rawValue)/achievements/\(achievementId.rawValue)/icons/\(icon)"
        case let .storePageAsset(appId, assetId):
            suffix = "app-assets/\(appId.rawValue)/store/\(assetId.rawValue)"
        case let .stickerPackBanner(assetId):
            suffix = "app-assets/710982414301790216/store/\(assetId.rawValue)"
        case let .teamIcon(teamId, icon):
            suffix = "team-icons/\(teamId.rawValue)/\(icon)"
        case let .sticker(stickerId):
            suffix = "stickers/\(stickerId.rawValue).png"
        /// Needs `.png`
        case let .roleIcon(roleId, icon):
            suffix = "role-icons/\(roleId.rawValue)/\(icon)"
        case let .guildScheduledEventCover(eventId, cover):
            suffix = "guild-events/\(eventId.rawValue)/\(cover)"
        case let .guildMemberBanner(guildId, userId, banner):
            suffix = "guilds/\(guildId.rawValue)/users/\(userId.rawValue)/banners/\(banner)"
        case .__DO_NOT_USE_THIS_CASE:
            fatalError("If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used")
        }
        return suffix.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? suffix
    }

    private var urlSuffixDescription: String {
        urlSuffix
    }

    public var url: String {
        "https://cdn.discordapp.com/" + urlSuffix
    }

    /// Doesn't expose secret url path parameters.
    public var urlDescription: String {
        url
    }

    public var httpMethod: HTTPMethod {
        .GET
    }

    /// Interaction endpoints don't count against the global rate limit.
    /// Even if the global rate-limit is exceeded, you can still respond to interactions.
    public var countsAgainstGlobalRateLimit: Bool {
        true
    }

    /// Some endpoints like don't require an authorization header because the endpoint itself
    /// contains some kind of authorization token. Like half of the webhook endpoints.
    public var requiresAuthorizationHeader: Bool {
        false
    }

    /// URL-path parameters.
    public var parameters: [String] {
        switch self {
        case .customEmoji(let emojiId):
            return [emojiId.rawValue]
        case .guildIcon(let guildId, let icon):
            return [guildId.rawValue, icon]
        case .guildSplash(let guildId, let splash):
            return [guildId.rawValue, splash]
        case .guildDiscoverySplash(let guildId, let splash):
            return [guildId.rawValue, splash]
        case .guildBanner(let guildId, let banner):
            return [guildId.rawValue, banner]
        case .userBanner(let userId, let banner):
            return [userId.rawValue, banner]
        case .defaultUserAvatar(let discriminator):
            return [discriminator]
        case .userAvatar(let userId, let avatar):
            return [userId.rawValue, avatar]
        case .guildMemberAvatar(let guildId, let userId, let avatar):
            return [guildId.rawValue, userId.rawValue, avatar]
        case .userAvatarDecoration(let userId, let avatarDecoration):
            return [userId.rawValue, avatarDecoration]
        case .avatarDecoration(let asset):
            return [asset]
        case .applicationIcon(let appId, let icon):
            return [appId.rawValue, icon]
        case .applicationCover(let appId, let cover):
            return [appId.rawValue, cover]
        case .applicationAsset(let appId, let assetId):
            return [appId.rawValue, assetId.rawValue]
        case .achievementIcon(let appId, let achievementId, let icon):
            return [appId.rawValue, achievementId.rawValue, icon]
        case .storePageAsset(let appId, let assetId):
            return [appId.rawValue, assetId.rawValue]
        case .stickerPackBanner(let assetId):
            return [assetId.rawValue]
        case .teamIcon(let teamId, let icon):
            return [teamId.rawValue, icon]
        case .sticker(let stickerId):
            return [stickerId.rawValue]
        case .roleIcon(let roleId, let icon):
            return [roleId.rawValue, icon]
        case .guildScheduledEventCover(let eventId, let cover):
            return [eventId.rawValue, cover]
        case .guildMemberBanner(let guildId, let userId, let banner):
            return [guildId.rawValue, userId.rawValue, banner]
        case .__DO_NOT_USE_THIS_CASE:
            fatalError("If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used")
        }
    }

    public var id: Int {
        switch self {
        case .customEmoji: return 1
        case .guildIcon: return 2
        case .guildSplash: return 3
        case .guildDiscoverySplash: return 4
        case .guildBanner: return 5
        case .userBanner: return 6
        case .defaultUserAvatar: return 7
        case .userAvatar: return 8
        case .guildMemberAvatar: return 9
        case .userAvatarDecoration: return 10
        case .avatarDecoration: return 11
        case .applicationIcon: return 12
        case .applicationCover: return 13
        case .applicationAsset: return 14
        case .achievementIcon: return 15
        case .storePageAsset: return 16
        case .stickerPackBanner: return 17
        case .teamIcon: return 18
        case .sticker: return 19
        case .roleIcon: return 20
        case .guildScheduledEventCover: return 21
        case .guildMemberBanner: return 22
        case .__DO_NOT_USE_THIS_CASE:
            fatalError("If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used")
        }
    }

    public var description: String {
        switch self {
        case let .customEmoji(emojiId):
            return "customEmoji(emojiId: \(emojiId))"
        case let .guildIcon(guildId, icon):
            return "guildIcon(guildId: \(guildId), icon: \(icon))"
        case let .guildSplash(guildId, splash):
            return "guildSplash(guildId: \(guildId), splash: \(splash))"
        case let .guildDiscoverySplash(guildId, splash):
            return "guildDiscoverySplash(guildId: \(guildId), splash: \(splash))"
        case let .guildBanner(guildId, banner):
            return "guildBanner(guildId: \(guildId), banner: \(banner))"
        case let .userBanner(userId, banner):
            return "userBanner(userId: \(userId), banner: \(banner))"
        case let .defaultUserAvatar(discriminator):
            return "defaultUserAvatar(discriminator: \(discriminator))"
        case let .userAvatar(userId, avatar):
            return "userAvatar(userId: \(userId), avatar: \(avatar))"
        case let .guildMemberAvatar(guildId, userId, avatar):
            return "guildMemberAvatar(guildId: \(guildId), userId: \(userId), avatar: \(avatar))"
        case let .userAvatarDecoration(userId, avatarDecoration):
            return "userAvatarDecoration(userId: \(userId), avatarDecoration: \(avatarDecoration))"
        case let .avatarDecoration(asset):
            return "avatarDecoration(asset: \(asset))"
        case let .applicationIcon(appId, icon):
            return "applicationIcon(appId: \(appId), icon: \(icon))"
        case let .applicationCover(appId, cover):
            return "applicationCover(appId: \(appId), cover: \(cover))"
        case let .applicationAsset(appId, assetId):
            return "applicationAsset(appId: \(appId), assetId: \(assetId))"
        case let .achievementIcon(appId, achievementId, icon):
            return "achievementIcon(appId: \(appId), achievementId: \(achievementId), icon: \(icon))"
        case let .storePageAsset(appId, assetId):
            return "storePageAsset(appId: \(appId), assetId: \(assetId))"
        case let .stickerPackBanner(assetId):
            return "stickerPackBanner(assetId: \(assetId))"
        case let .teamIcon(teamId, icon):
            return "teamIcon(teamId: \(teamId), icon: \(icon))"
        case let .sticker(stickerId):
            return "sticker(stickerId: \(stickerId))"
        case let .roleIcon(roleId, icon):
            return "roleIcon(roleId: \(roleId), icon: \(icon))"
        case let .guildScheduledEventCover(eventId, cover):
            return "guildScheduledEventCover(eventId: \(eventId), cover: \(cover))"
        case let .guildMemberBanner(guildId, userId, banner):
            return "guildMemberBanner(guildId: \(guildId), userId: \(userId), banner: \(banner))"
        case .__DO_NOT_USE_THIS_CASE:
            fatalError("If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used")
        }
    }
}

public enum CDNEndpointIdentity: Int, Sendable, Hashable, CustomStringConvertible {
    case customEmoji
    case guildIcon
    case guildSplash
    case guildDiscoverySplash
    case guildBanner
    case userBanner
    case defaultUserAvatar
    case userAvatar
    case guildMemberAvatar
    case userAvatarDecoration
    case avatarDecoration
    case applicationIcon
    case applicationCover
    case applicationAsset
    case achievementIcon
    case storePageAsset
    case stickerPackBanner
    case teamIcon
    case sticker
    case roleIcon
    case guildScheduledEventCover
    case guildMemberBanner

    /// This case serves as a way of discouraging exhaustive switch statements
    case __DO_NOT_USE_THIS_CASE

    public var description: String {
        switch self {
        case .customEmoji: return "customEmoji"
        case .guildIcon: return "guildIcon"
        case .guildSplash: return "guildSplash"
        case .guildDiscoverySplash: return "guildDiscoverySplash"
        case .guildBanner: return "guildBanner"
        case .userBanner: return "userBanner"
        case .defaultUserAvatar: return "defaultUserAvatar"
        case .userAvatar: return "userAvatar"
        case .guildMemberAvatar: return "guildMemberAvatar"
        case .userAvatarDecoration: return "userAvatarDecoration"
        case .avatarDecoration: return "avatarDecoration"
        case .applicationIcon: return "applicationIcon"
        case .applicationCover: return "applicationCover"
        case .applicationAsset: return "applicationAsset"
        case .achievementIcon: return "achievementIcon"
        case .storePageAsset: return "storePageAsset"
        case .stickerPackBanner: return "stickerPackBanner"
        case .teamIcon: return "teamIcon"
        case .sticker: return "sticker"
        case .roleIcon: return "roleIcon"
        case .guildScheduledEventCover: return "guildScheduledEventCover"
        case .guildMemberBanner: return "guildMemberBanner"
        case .__DO_NOT_USE_THIS_CASE:
            fatalError("If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used")
        }
    }

    init(endpoint: CDNEndpoint) {
        switch endpoint {
        case .customEmoji: self = .customEmoji
        case .guildIcon: self = .guildIcon
        case .guildSplash: self = .guildSplash
        case .guildDiscoverySplash: self = .guildDiscoverySplash
        case .guildBanner: self = .guildBanner
        case .userBanner: self = .userBanner
        case .defaultUserAvatar: self = .defaultUserAvatar
        case .userAvatar: self = .userAvatar
        case .guildMemberAvatar: self = .guildMemberAvatar
        case .userAvatarDecoration: self = .userAvatarDecoration
        case .avatarDecoration: self = .avatarDecoration
        case .applicationIcon: self = .applicationIcon
        case .applicationCover: self = .applicationCover
        case .applicationAsset: self = .applicationAsset
        case .achievementIcon: self = .achievementIcon
        case .storePageAsset: self = .storePageAsset
        case .stickerPackBanner: self = .stickerPackBanner
        case .teamIcon: self = .teamIcon
        case .sticker: self = .sticker
        case .roleIcon: self = .roleIcon
        case .guildScheduledEventCover: self = .guildScheduledEventCover
        case .guildMemberBanner: self = .guildMemberBanner
        case .__DO_NOT_USE_THIS_CASE:
            fatalError("If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used")
        }
    }
}
