import PaicordLib

class BridgedGuildFolderVec {
    var inner: [DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder]

    init(inner: [DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder]) {
        self.inner = inner
    }

    func len() -> UInt {
        return UInt(self.inner.count)
    }

    func get_unchecked(index: UInt) -> GuildFolderRust {
        return GuildFolderRust(folder: self.inner[Int(index)])
    }
}

extension GuildFolderRust {
    init(folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder) {
        var guildIds: RustVec<UInt64> = RustVec()

        for guildId in folder.guildIds {
            guildIds.push(value: guildId)
        }

        self.guild_ids = guildIds
        self.id = if folder.hasID {
            folder.id.value
        } else {
            nil
        }

        self.name = if folder.hasName {
            folder.name.value.intoRustString()
        } else {
            nil
        }

        self.color = if folder.hasColor {
            DiscordColorRust(inner: Int32(folder.color.value))
        } else {
            nil
        }
    }
}

class BridgedGuildFolders {
    var inner: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolders

    init(inner: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolders) {
        self.inner = inner
    }

    func get_folders() -> BridgedGuildFolderVec {
        return BridgedGuildFolderVec(inner: self.inner.folders)
    }

    func get_guild_positions() -> RustVec<UInt64> {
        self.inner.guildPositions.withUnsafeBufferPointer({ buf in
            return  make_rust_vec_u64(buf)
        })
    }
}

class BridgedPreloadedUserSettings {
    var inner: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings

    init(inner: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings) {
        self.inner = inner
    }

    func get_guild_folders() -> BridgedGuildFolders {
        return BridgedGuildFolders(inner: self.inner.guildFolders)
    }
}