import PaicordLib

extension RoleRust {
    init(role: Role) {
        self.id = SnowflakeRust(inner: UInt64(role.id.rawValue) ?? 0)
        //self.name = role.name.intoRustString()
        // self.description = role.description.map { $0.intoRustString() }
        self.color = DiscordColorRust(color: role.color)
        // self.hoist = role.hoist
        // self.icon = role.icon.map { $0.intoRustString() }
        // self.unicode_emoji = role.unicode_emoji.map { $0.intoRustString() }
        self.position = Int32(role.position)
        // self.managed = role.managed
        // self.mentionable = role.mentionable
        // self.version = role.version.map { Int32($0) }
    }
}
