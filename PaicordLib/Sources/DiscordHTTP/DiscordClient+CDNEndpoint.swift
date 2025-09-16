/// MARK: - +CDNEndpoint
extension DiscordClient {
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNCustomEmoji(emojiId: EmojiSnowflake) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.customEmoji(emojiId: emojiId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: emojiId.rawValue
        )
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNGuildIcon(
        guildId: GuildSnowflake,
        icon: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildIcon(guildId: guildId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNGuildSplash(
        guildId: GuildSnowflake,
        splash: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildSplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNGuildDiscoverySplash(
        guildId: GuildSnowflake,
        splash: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildDiscoverySplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNGuildBanner(guildId: GuildSnowflake, banner: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildBanner(guildId: guildId, banner: banner)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: banner)
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `banner`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNUserBanner(userId: UserSnowflake, banner: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.userBanner(userId: userId, banner: banner)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: banner)
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNDefaultUserAvatar(discriminator: Int) async throws -> DiscordCDNResponse {
        /// `discriminator % 5` is what Discord says.
        let modulo = "\(discriminator % 5)"
        let endpoint = CDNEndpoint.defaultUserAvatar(discriminator: modulo)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: "\(discriminator)"
        )
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNUserAvatar(userId: UserSnowflake, avatar: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.userAvatar(userId: userId, avatar: avatar)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: avatar)
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNGuildMemberAvatar(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        avatar: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildMemberAvatar(
            guildId: guildId,
            userId: userId,
            avatar: avatar
        )
        return try await self.send(request: .init(to: endpoint), fallbackFileName: avatar)
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `avatarDecoration`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @available(*, deprecated, renamed: "getCDNAvatarDecoration")
    @inlinable
    public func getCDNUserAvatarDecoration(
        userId: UserSnowflake,
        avatarDecoration: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.userAvatarDecoration(
            userId: userId,
            avatarDecoration: avatarDecoration
        )
        return try await self.send(request: .init(to: endpoint), fallbackFileName: avatarDecoration)
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `avatarDecoration`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNAvatarDecoration(
        asset: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.avatarDecoration(asset: asset)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: asset)
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `icon`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNApplicationIcon(appId: ApplicationSnowflake, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.applicationIcon(appId: appId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `cover`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNApplicationCover(appId: ApplicationSnowflake, cover: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.applicationCover(appId: appId, cover: cover)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: cover)
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNApplicationAsset(
        appId: ApplicationSnowflake,
        assetId: AssetsSnowflake
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.applicationAsset(appId: appId, assetId: assetId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: assetId.rawValue
        )
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `icon`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNAchievementIcon(
        appId: ApplicationSnowflake,
        achievementId: AnySnowflake,
        icon: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.achievementIcon(
            appId: appId,
            achievementId: achievementId,
            icon: icon
        )
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `assetId`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNStorePageAsset(
        appId: ApplicationSnowflake,
        assetId: AssetsSnowflake
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.storePageAsset(appId: appId, assetId: assetId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: assetId.rawValue
        )
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNStickerPackBanner(
        assetId: AssetsSnowflake
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.stickerPackBanner(assetId: assetId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: assetId.rawValue
        )
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `icon`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNTeamIcon(teamId: TeamSnowflake, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.teamIcon(teamId: teamId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNSticker(stickerId: StickerSnowflake) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.sticker(stickerId: stickerId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: stickerId.rawValue
        )
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNRoleIcon(roleId: RoleSnowflake, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.roleIcon(roleId: roleId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }

    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNGuildScheduledEventCover(
        eventId: GuildScheduledEventSnowflake,
        cover: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildScheduledEventCover(eventId: eventId, cover: cover)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: cover)
    }

    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `banner`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    public func getCDNGuildMemberBanner(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        banner: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildMemberBanner(
            guildId: guildId,
            userId: userId,
            banner: banner
        )
        return try await self.send(request: .init(to: endpoint), fallbackFileName: banner)
    }
}
