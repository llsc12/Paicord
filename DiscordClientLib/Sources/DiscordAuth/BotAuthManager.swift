import DiscordModels

private let baseURLs = (
    authorization: "https://discord.com/api/oauth2/authorize",
    token: "https://discord.com/api/oauth2/token",
    tokenRevocation: "https://discord.com/api/oauth2/token/revoke"
)

/// For now, only to be able to make bot auth urls dynamically, on demand.
public struct BotAuthManager: Sendable {

    let clientId: String

    public init(clientId: String) {
        self.clientId = clientId
    }

    /// The bot will immediately join servers which authorize your bot via this URL.
    /// https://discord.com/developers/docs/topics/oauth2#bot-authorization-flow
    @available(
        *,
        deprecated,
        renamed: "makeBotAuthorizationURL(permissions:guildId:disableGuildSelect:)",
        message: "'.applicationsCommands' OAuth scope is automatically included by Discord for bots"
    )
    public func makeBotAuthorizationURL(
        withApplicationCommands: Bool = true,
        permissions: [Permission] = [],
        guildId: GuildSnowflake? = nil,
        disableGuildSelect: Bool? = nil
    ) -> String {
        var scopes: [OAuth2Scope] = [.bot]
        if withApplicationCommands {
            scopes.append(.applicationsCommands)
        }
        let permissions = IntBitField(permissions).rawValue
        let queries: [(String, String?)] = [
            ("client_id", self.clientId),
            ("permissions", "\(permissions)"),
            ("scope", scopes.map(\.rawValue).joined(separator: " ")),
            ("guild_id", guildId?.rawValue),
            ("disable_guild_select", disableGuildSelect?.description),
        ]
        return baseURLs.authorization + queries.makeForURLQuery()
    }

    /// The bot will immediately join servers which authorize your bot via this URL.
    /// https://discord.com/developers/docs/topics/oauth2#bot-authorization-flow
    public func makeBotAuthorizationURL(
        permissions: [Permission] = [],
        guildId: GuildSnowflake? = nil,
        disableGuildSelect: Bool? = nil
    ) -> String {
        let scopes: [OAuth2Scope] = [.bot]
        let permissions = IntBitField(permissions).rawValue
        let queries: [(String, String?)] = [
            ("client_id", self.clientId),
            ("permissions", "\(permissions)"),
            ("scope", scopes.map(\.rawValue).joined(separator: " ")),
            ("guild_id", guildId?.rawValue),
            ("disable_guild_select", disableGuildSelect?.description),
        ]
        return baseURLs.authorization + queries.makeForURLQuery()
    }
}
