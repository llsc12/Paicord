import PaicordLib

extension Gateway.MessageCreate {
    func toMessage() -> DiscordChannel.Message {
        let refMsg = self.referenced_message?.value.toMessage()
        let box: DereferenceBox<DiscordChannel.Message>? =
            refMsg == nil ? nil : .init(value: refMsg!)

        return .init(
            id: self.id,
            channel_id: self.channel_id,
            author: self.author,
            content: self.content,
            timestamp: self.timestamp,
            edited_timestamp: self.edited_timestamp,
            tts: self.tts,
            mention_everyone: self.mention_everyone,
            mentions: self.mentions,
            mention_roles: self.mention_roles,
            mention_channels: self.mention_channels,
            attachments: self.attachments,
            embeds: self.embeds,
            reactions: self.reactions,
            nonce: self.nonce,
            pinned: self.pinned,
            webhook_id: self.webhook_id,
            type: self.type,
            activity: self.activity,
            application: self.application,
            application_id: self.application_id,
            message_reference: self.message_reference,
            message_snapshots: self.message_snapshots,
            flags: self.flags,
            referenced_message: box,
            interaction: self.interaction,
            thread: self.thread,
            components: self.components,
            sticker_items: self.sticker_items,
            stickers: self.stickers,
            position: self.position,
            role_subscription_data: self.role_subscription_data,
            resolved: self.resolved,
            poll: self.poll,
            call: self.call,
            guild_id: self.guild_id,
            member: self.member
        )
    }
}

extension DiscordChannel.Message {
    func toPartialMessage() -> DiscordChannel.PartialMessage {
        let refMsg = self.referenced_message?.value.toPartialMessage()
        let box: DereferenceBox<DiscordChannel.PartialMessage>? =
            refMsg == nil ? nil : .init(value: refMsg!)

        return .init(
            id: self.id,
            channel_id: self.channel_id,
            author: self.author,
            content: self.content,
            timestamp: self.timestamp,
            edited_timestamp: self.edited_timestamp,
            tts: self.tts,
            mention_everyone: self.mention_everyone,
            mentions: self.mentions,
            mention_roles: self.mention_roles,
            mention_channels: self.mention_channels,
            attachments: self.attachments,
            embeds: self.embeds,
            reactions: self.reactions,
            nonce: self.nonce,
            pinned: self.pinned,
            webhook_id: self.webhook_id,
            type: self.type,
            activity: self.activity,
            application: self.application,
            application_id: self.application_id,
            message_reference: self.message_reference,
            flags: self.flags,
            referenced_message: box,
            message_snapshots: self.message_snapshots,
            interaction: self.interaction,
            thread: self.thread,
            components: self.components,
            sticker_items: self.sticker_items,
            stickers: self.stickers,
            position: self.position,
            role_subscription_data: self.role_subscription_data,
            resolved: self.resolved,
            poll: self.poll,
            call: self.call,
            member: self.member,
            guild_id: self.guild_id
        )
    }
}

extension Guild.Member {
    func toPartialMember() -> Guild.PartialMember {
        .init(
            user: self.user,
            nick: self.nick,
            avatar: self.avatar,
            banner: self.banner,
            pronouns: self.pronouns,
            roles: self.roles,
            joined_at: self.joined_at,
            premium_since: self.premium_since,
            deaf: self.deaf,
            mute: self.mute,
            pending: self.pending,
            flags: self.flags,
            permissions: self.permissions,
            communication_disabled_until: self.communication_disabled_until,
            avatar_decoration_data: self.avatar_decoration_data
        )
    }
}
