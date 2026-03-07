import PaicordLib

class BridgedGuild {
    var guild: Guild

    init (bridge: Guild) {
        self.guild = bridge
    }

    func get_id() -> UInt64 {
        return UInt64(self.guild.id.rawValue) ?? 0
    }

    func get_name() -> String {
        return self.guild.name
    }

    func get_icon() -> Optional<String> {
        return self.guild.icon
    }

    func get_banner() -> Optional<String> {
        return self.guild.banner
    }

    func get_channel_count() -> UInt {
        return UInt(self.guild.channels?.count ?? 0)
    }

    func get_channel(index: UInt) -> BridgedDiscordChannel {
        return BridgedDiscordChannel(channel: self.guild.channels![Int(index)])
    }

    func role_count() -> UInt {
        return UInt(self.guild.roles.count)
    }

    func get_role(index: UInt) -> RoleRust {
        return RoleRust(role: self.guild.roles[Int(index)])
    }
}

class BridgedPartialMember {
    var member: Guild.PartialMember

    init(member: Guild.PartialMember) {
        self.member = member
    }

    func has_user() -> Bool {
        return self.member.user != nil
    }

    func get_user() -> DiscordUserRust {
        return DiscordUserRust(user: self.member.user!)
    }

    func get_nick() -> Optional<String> {
        return self.member.nick
    }

    func get_avatar() -> Optional<String> {
        return self.member.avatar
    }

    func get_banner() -> Optional<String> {
        return self.member.banner
    }

    func get_pronouns() -> Optional<String> {
        return self.member.pronouns
    }

    func role_count() -> UInt {
        if let roles = self.member.roles {
            return UInt(roles.count)
        } else {
            return 0
        }
    }

    func get_role(index: UInt) -> SnowflakeRust {
        return SnowflakeRust(inner: UInt64(self.member.roles![Int(index)].rawValue) ?? 0)
    }

    func has_joined_at() -> Bool {
        return self.member.joined_at != nil
    }

    func get_joined_at() -> DiscordTimestampRust {
        return DiscordTimestampRust(timestamp: self.member.joined_at!)
    }

    func has_premium_since() -> Bool {
        return self.member.premium_since != nil
    }

    func get_premium_since() -> DiscordTimestampRust {
        return DiscordTimestampRust(timestamp: self.member.premium_since!)
    }

    func get_deaf() -> Bool {
        return self.member.deaf ?? false
    }

    func get_mute() -> Bool {
        return self.member.mute ?? false
    }

    func get_pending() -> Bool {
        return self.member.pending ?? false
    }

    func has_avatar_decoration() -> Bool {
        return self.member.avatar_decoration_data != nil
    }

    func get_avatar_decoration() -> AvatarDecorationRust {
        return AvatarDecorationRust(decoration: self.member.avatar_decoration_data!)
    }
}