extension Gateway.GuildCreate {

    /// Whether or not a member has a permission in a guild and channel.
    /// Member must be of the same guild.
    /// This a best-effort function based on what Discord has documented.
    /// https://discord.com/developers/docs/topics/permissions#permission-overwrites
    public func memberHasPermissions(
        member: Guild.Member,
        userId: UserSnowflake,
        channelId: ChannelSnowflake,
        permissions perms: [Permission]
    ) -> Bool {
        if let channel = self.channels.first(where: { $0.id == channelId }) {
            return _memberHasPermissions(
                member: member,
                userId: userId,
                channel: channel,
                permissions: perms
            )
        } else if let thread = self.threads.first(where: { $0.id == channelId }),
            let parentId = thread.parent_id,
            let channel = self.channels.first(where: { $0.id == parentId })
        {
            if thread.type == .privateThread {
                /// For private threads you must be a thread member or a guild admin.
                /// If you are an admin, then you automatically have all perms.
                if memberHasGuildPermission(
                    member: member,
                    userId: userId,
                    permission: .administrator
                ) {
                    return true
                }

                /// At this point, you must be a thread member or you don't have access.
                if !(thread.threadMembers?.contains { $0.user_id == userId } ?? false) {
                    return false
                }

                /// At this point, the perms are the same as the channel.
                return _memberHasPermissions(
                    member: member,
                    userId: userId,
                    channel: channel,
                    permissions: perms
                )
            } else {
                return _memberHasPermissions(
                    member: member,
                    userId: userId,
                    channel: channel,
                    permissions: perms
                )
                    && _memberHasPermissions(
                        member: member,
                        userId: userId,
                        channel: thread,
                        permissions: perms
                    )
            }
        } else {
            /// No proper channel or thread found.
            return false
        }
    }

    /// Use `memberHasPermissions(userId:channelId:permissions:)` instead.
    func _memberHasPermissions(
        member: Guild.Member,
        userId: UserSnowflake,
        channel: DiscordChannel,
        permissions perms: [Permission]
    ) -> Bool {
        /// Guild owner has all permissions.
        if self.owner_id == userId { return true }

        /// `administrator` perm is like the guild owner.
        if self.roles.contains(where: { role in
            role.permissions.contains(.administrator) && self.memberHasRole(member: member, roleId: role.id)
        }) {
            return true
        }

        /// We've already checked for it.
        if perms.contains(.administrator) { return false }

        func hasPerm(_ perm: Permission) -> Bool {
            _memberHasPermission(
                userId: userId,
                member: member,
                channel: channel,
                permission: perm
            )
        }

        /// Has the permissions at all.
        for perm in perms {
            if !hasPerm(perm) { return false }
        }

        /// Some permission require other permissions first.
        /// These are the ones that Discord has documented.
        let requireSendMessages: [Permission] = [
            .mentionEveryone,
            .sendTtsMessages,
            .attachFiles,
            .embedLinks,
        ]
        /// If perms already contains `sendMessage`, then we've already checked for it.
        if !perms.contains(.sendMessages),
            perms.contains(where: { requireSendMessages.contains($0) })
        {
            if !hasPerm(.sendMessages) { return false }
        }

        /// If perms already contains `viewChannel`, then we've already checked for it.
        if !perms.contains(.viewChannel) {
            /// Member must have `viewChannel` permission for anything else to begin with.
            if !hasPerm(.viewChannel) { return false }
        }

        /// For voice and stage channels, `connect` permission is necessary.
        /// If perms already contains `connect`, then we've already checked for it.
        if [.guildVoice, .guildStageVoice].contains(channel.type),
            !perms.contains(.connect)
        {
            if !hasPerm(.connect) { return false }
        }

        return true
    }

    /// Use `memberHasPermissions(userId:channelId:permissions:)` instead.
    /// This only checks if the user actually has the permission itself.
    /// Doesn't guarantee the member has the abilities related to the permission _in practice_.
    func _memberHasPermission(
        userId: UserSnowflake,
        member: Guild.Member,
        channel: DiscordChannel,
        permission perm: Permission
    ) -> Bool {
        var memberOverwriteDenies = false
        var roleOverwriteAllows = false
        var roleOverwriteDenies = false
        var everyoneIsAllowed = false
        var everyoneIsDenied = false

        for overwrite in (channel.permission_overwrites ?? []) {
            switch overwrite.type {
            case .member where overwrite.id == userId:
                if overwrite.allow.contains(perm) {
                    /// Has the most priority at this point, we can just return immediately.
                    return true
                }
                if overwrite.deny.contains(perm) {
                    memberOverwriteDenies = true
                }
            case .role where member.roles.contains(where: { $0 == overwrite.id }):
                if overwrite.allow.contains(perm) {
                    roleOverwriteAllows = true
                }
                if overwrite.deny.contains(perm) {
                    roleOverwriteDenies = true
                }
            case .role where overwrite.id == self.id:
                /// `@everyone` overwrites
                if overwrite.allow.contains(perm) {
                    everyoneIsAllowed = true
                }
                if overwrite.deny.contains(perm) {
                    everyoneIsDenied = true
                }
            default: break
            }
        }

        /// Checking these based on the Discord-said priority.
        if memberOverwriteDenies { return false }
        if roleOverwriteAllows { return true }
        if roleOverwriteDenies { return false }
        if everyoneIsAllowed { return true }
        if everyoneIsDenied { return false }

        /// Member has any roles that allow.
        for role in roles where member.roles.contains(role.id) {
            if role.permissions.contains(perm) {
                return true
            }
        }

        /// `@everyone` role allows.
        if let everyoneRole = self.roles.first(where: { $0.id == self.id }),
            everyoneRole.permissions.contains(perm)
        {
            return true
        }

        return false
    }

    /// Member has permission in guild. Doesn't check for channel overwrites.
    /// This a best-effort function based on what Discord has documented.
    public func memberHasGuildPermission(
        member: Guild.Member,
        userId: UserSnowflake,
        permission perm: Permission
    ) -> Bool {
        /// Guild owner has all permissions.
        if self.owner_id == userId { return true }

        /// `administrator` perm is like the guild owner.
        if self.roles.contains(where: { role in
            role.permissions.contains(.administrator) && self.memberHasRole(member: member, roleId: role.id)
        }) {
            return true
        }

        /// Already checked for it.
        if perm == .administrator { return false }

        /// Member has any roles that allow.
        for role in roles where member.roles.contains(role.id) {
            if role.permissions.contains(perm) {
                return true
            }
        }

        /// `@everyone` role allows.
        if let everyoneRole = self.roles.first(where: { $0.id == self.id }),
            everyoneRole.permissions.contains(perm)
        {
            return true
        }

        return false
    }

    /// Whether or not a user has a permission in a guild and channel.
    /// This a best-effort function based on what Discord has documented.
    /// - NOTE: You should request all guild member from gateway before calling this function.
    /// `GatewayManager` has a `requestGuildMembersChunk(payload:)` function, for that.
    /// `DiscordCache` comes with a configuration option to request all guild members for you.
    /// https://discord.com/developers/docs/topics/permissions#permission-overwrites
    public func userHasPermissions(
        userId: UserSnowflake,
        channelId: ChannelSnowflake,
        permissions perms: [Permission]
    ) -> Bool {
        guard let member = self.member(withUserId: userId) else {
            /// Don't even have access to the member.
            return false
        }
        return self.memberHasPermissions(
            member: member,
            userId: userId,
            channelId: channelId,
            permissions: perms
        )
    }

    /// User has permission in guild. Doesn't check for channel overwrites.
    /// This a best-effort function based on what Discord has documented.
    public func userHasGuildPermission(
        userId: UserSnowflake,
        permission perm: Permission
    ) -> Bool {
        guard let member = self.member(withUserId: userId) else {
            /// Don't even have access to the member.
            return false
        }
        return self.memberHasGuildPermission(
            member: member,
            userId: userId,
            permission: perm
        )
    }

    /// Get member with the specified user id.
    public func member(withUserId userId: UserSnowflake) -> Guild.Member? {
        self.members.first(where: { $0.user?.id == userId })
    }

    /// Check to see if a member has a role.
    /// The member object must belong to the guild.
    public func memberHasRole(member: Guild.Member, roleId: RoleSnowflake) -> Bool {
        /// `@everyone` role's id is equal to guild's id.
        if roleId == self.id {
            return true
        } else if member.roles.contains(roleId) {
            return true
        } else {
            return false
        }
    }

    /// Check to see if a user has the roles.
    /// Returns false if user is not present in the members list of the guild.
    public func userHasRole(userId: UserSnowflake, roleId: RoleSnowflake) -> Bool {
        guard let member = self.member(withUserId: userId) else {
            return false
        }
        return self.memberHasRole(member: member, roleId: roleId)
    }
}
