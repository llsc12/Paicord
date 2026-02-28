import PaicordLib

extension PremiumKindRust {
    init(premiumKind: DiscordUser.PremiumKind) {
        switch premiumKind {
        case .none:
            self = .None
        case .nitroClassic:
            self = .NitroClassic
        case .nitro:
            self = .Nitro
        case .nitroBasic:
            self = .NitroBasic
        case .__undocumented(let inner):
            self = .Undocumented(Int32(inner))
        }
    }
}

extension ColorPaletteRust {
    init(palette: DiscordUser.Collectibles.Nameplate.ColorPalette) {
        switch palette {
        case .none:
            self = .None
        case .crimson:
            self = .Crimson
        case .berry:
            self = .Berry
        case .sky:
            self = .Sky
        case .teal:
            self = .Teal
        case .forest:
            self = .Forest
        case .bubble_gum:
            self = .BubbleGum
        case .violet:
            self = .Violet
        case .cobalt:
            self = .Cobalt
        case .clover:
            self = .Clover
        case .lemon:
            self = .Lemon
        case .white:
            self = .White
        case .__undocumented(let inner):
            self = .Undocumented(inner.intoRustString())
        }
    }
}

extension DiscordUserRust {
    init(user: DiscordUser) {
        self.id = SnowflakeRust(inner: UInt64(user.id.rawValue) ?? 0)
        self.username = user.username.intoRustString()
        self.discriminator = user.discriminator.intoRustString()
        self.global_name = user.global_name?.intoRustString() ?? nil
        self.avatar = user.avatar?.intoRustString() ?? nil
        self.banner = user.banner?.intoRustString() ?? nil
        self.bot = user.bot
        self.system = user.system
        self.mfa_enabled = user.mfa_enabled
        self.pronouns = user.pronouns?.intoRustString() ?? nil
        self.accent_color = user.accent_color.map { DiscordColorRust(color: $0) }
        self.locale = user.locale.map { DiscordLocaleRust(locale: $0) }
        self.verified = user.verified
        self.email = user.email?.intoRustString() ?? nil
        self.premium_type = user.premium_type.map { PremiumKindRust(premiumKind: $0) }
        self.avatar_decoration = user.avatar_decoration?.intoRustString() ?? nil
        self.collectibles = user.collectibles.map {
            CollectiblesRust(collectibles: $0)
        }
        self.avatar_decoration_data = user.avatar_decoration_data.map { AvatarDecorationRust(decoration: $0) }
        self.primary_guild = user.primary_guild.map { PrimaryGuildRust(primaryGuild: $0) }
    }
}

extension CollectiblesRust {
    init(collectibles: DiscordUser.Collectibles) {
        self.nameplate = collectibles.nameplate.map { NameplateRust(nameplate: $0) }
    }
}

extension NameplateRust {
    init(nameplate: DiscordUser.Collectibles.Nameplate) {
        self.asset = nameplate.asset.intoRustString()
        self.expires_at = nameplate.expires_at.map { DiscordTimestampRust(timestamp: $0) }
        self.label = nameplate.label.intoRustString()
        self.palette = ColorPaletteRust(palette: nameplate.palette)
        self.sku_id = SnowflakeRust(inner: UInt64(nameplate.sku_id.rawValue) ?? 0)
    }
}

extension AvatarDecorationRust {
    init(decoration: DiscordUser.AvatarDecoration) {
        self.sku_id = SnowflakeRust(inner: UInt64(decoration.sku_id.rawValue) ?? 0)
        self.asset = decoration.asset.intoRustString()
    }
}

extension PrimaryGuildRust {
    init(primaryGuild: DiscordUser.PrimaryGuild) {
        self.badge = primaryGuild.badge?.intoRustString() ?? nil
        self.identity_enabled = primaryGuild.identity_enabled
        self.identity_guild_id = primaryGuild.identity_guild_id.map { SnowflakeRust(inner: UInt64($0.rawValue) ?? 0) }
        self.tag = primaryGuild.tag?.intoRustString() ?? nil
    }
}