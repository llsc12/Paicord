import PaicordLib

func guild_member_avatar(guild_id: UInt64, user_id: UInt64, avatar: RustString) -> String {
    let guildId = GuildSnowflake(guild_id.description)
    let userId = UserSnowflake(user_id.description)
    let avatarStr = avatar.toString()

    let animated = avatarStr.starts(with: "a_")

    return CDNEndpoint.guildMemberAvatar(guildId: guildId, userId: userId, avatar: avatar.toString()).url + ".\(animated ? "gif" : "png")?size=128&animated=\(animated.description)"
}

func user_avatar(user_id: UInt64, avatar: RustString) -> String {
    let userId = UserSnowflake(user_id.description)
    let avatarStr = avatar.toString()

    let animated = avatarStr.starts(with: "a_")

    return CDNEndpoint.userAvatar(userId: userId, avatar: avatar.toString()).url + ".\(animated ? "gif" : "png")?size=128&animated=\(animated.description)"
}

func default_user_avatar(user_id: UInt64) -> String {
    let userId = UserSnowflake(user_id.description)
    return CDNEndpoint.defaultUserAvatar(userId: userId).url + ".png"
}

func guild_icon(guild_id: UInt64, icon: RustString) -> String {
    let icon = icon.toString()
    let guildId = GuildSnowflake(guild_id.description)

    let animated = icon.starts(with: "a_")

    return CDNEndpoint.guildIcon(guildId: guildId, icon: icon).url + ".\(animated ? "gif" : "png")?size=128&animated=\(animated.description)"
}

func guild_banner(guild_id: UInt64, banner: RustString) -> String {
    let banner = banner.toString()
    let guildId = GuildSnowflake(guild_id.description)

    let animated = banner.starts(with: "a_")

    return CDNEndpoint.guildBanner(guildId: guildId, banner: banner).url + ".\(animated ? "gif" : "png")?size=600&animated=\(animated.description)"
}