//
//  Merging.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 21/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib

extension Guild {
  mutating func update(with new: Gateway.GuildCreate) {
    self.id = new.id
    self.name = new.name
    self.icon = new.icon
    self.icon_hash = new.icon_hash
    self.splash = new.splash
    self.discovery_splash = new.discovery_splash
    self.owner = new.owner
    self.owner_id = new.owner_id
    self.permissions = new.permissions
    self.afk_channel_id = new.afk_channel_id
    self.afk_timeout = new.afk_timeout
    self.widget_enabled = new.widget_enabled
    self.widget_channel_id = new.widget_channel_id
    self.verification_level = new.verification_level
    self.default_message_notifications = new.default_message_notifications
    self.explicit_content_filter = new.explicit_content_filter
    self.roles = new.roles
    self.emojis = new.emojis
    self.features = new.features
    self.mfa_level = new.mfa_level
    self.application_id = new.application_id
    self.system_channel_id = new.system_channel_id
    self.system_channel_flags = new.system_channel_flags
    self.rules_channel_id = new.rules_channel_id
    self.max_presences = new.max_presences
    self.max_members = new.max_members
    self.vanity_url_code = new.vanity_url_code
    self.description = new.description
    self.banner = new.banner
    self.premium_tier = new.premium_tier
    self.premium_subscription_count = new.premium_subscription_count
    self.preferred_locale = new.preferred_locale
    self.public_updates_channel_id = new.public_updates_channel_id
    self.max_video_channel_users = new.max_video_channel_users
    self.max_stage_video_channel_users = new.max_stage_video_channel_users
    self.approximate_member_count = new.approximate_member_count
    self.approximate_presence_count = new.approximate_presence_count
    self.welcome_screen = new.welcome_screen
    self.nsfw_level = new.nsfw_level
    self.stickers = new.stickers
    self.premium_progress_bar_enabled = new.premium_progress_bar_enabled
    self.`lazy` = new.`lazy`
    //		self.hub_type = new.hub_type
    self.nsfw = new.nsfw
    self.application_command_counts = new.application_command_counts
    self.embedded_activities = new.embedded_activities
    self.version = new.version
    self.guild_id = new.guild_id
  }
}

extension Gateway.GuildCreate {
  func toGuild() -> Guild {
    .init(
      id: id,
      name: name,
      icon: icon,
      icon_hash: icon_hash,
      splash: splash,
      discovery_splash: discovery_splash,
      owner: owner,
      owner_id: owner_id,
      channels: channels,
      permissions: permissions,
      afk_channel_id: afk_channel_id,
      afk_timeout: afk_timeout,
      widget_enabled: widget_enabled,
      widget_channel_id: widget_channel_id,
      verification_level: verification_level,
      default_message_notifications: default_message_notifications,
      explicit_content_filter: explicit_content_filter,
      roles: roles,
      emojis: emojis,
      features: features,
      mfa_level: mfa_level,
      application_id: application_id,
      system_channel_id: system_channel_id,
      system_channel_flags: system_channel_flags,
      rules_channel_id: rules_channel_id,
      safety_alerts_channel_id: safety_alerts_channel_id,
      max_presences: max_presences,
      max_members: max_members,
      vanity_url_code: vanity_url_code,
      description: description,
      banner: banner,
      premium_tier: premium_tier,
      premium_subscription_count: premium_subscription_count,
      preferred_locale: preferred_locale,
      public_updates_channel_id: public_updates_channel_id,
      max_video_channel_users: max_video_channel_users,
      max_stage_video_channel_users: max_stage_video_channel_users,
      approximate_member_count: approximate_member_count,
      approximate_presence_count: approximate_presence_count,
      welcome_screen: welcome_screen,
      nsfw_level: nsfw_level,
      stickers: stickers,
      premium_progress_bar_enabled: premium_progress_bar_enabled,
      //			hub_type: hub_type,
      nsfw: nsfw,
      application_command_counts: application_command_counts,
      embedded_activities: embedded_activities,
      version: version,
      guild_id: guild_id
    )
  }
}

extension Gateway.GuildMemberAdd {
  func toMember() -> Guild.Member {
    .init(guildMemberAdd: self)
  }
}

extension DiscordChannel.Message {
  mutating func update(with new: DiscordChannel.PartialMessage) {
    self.author = new.author ?? self.author
    self.content = new.content ?? self.content
    self.timestamp = new.timestamp ?? self.timestamp
    self.edited_timestamp = new.edited_timestamp ?? self.edited_timestamp
    self.tts = new.tts ?? self.tts
    self.mention_everyone = new.mention_everyone ?? self.mention_everyone
    self.mentions = new.mentions ?? self.mentions
    self.mention_roles = new.mention_roles ?? self.mention_roles
    self.mention_channels = new.mention_channels ?? self.mention_channels
    self.attachments = new.attachments ?? self.attachments
    self.embeds = new.embeds ?? self.embeds
    self.reactions = new.reactions ?? self.reactions
    self.nonce = new.nonce ?? self.nonce
    self.pinned = new.pinned ?? self.pinned
    self.webhook_id = new.webhook_id ?? self.webhook_id
    self.type = new.type ?? self.type
    self.activity = new.activity ?? self.activity
    self.application = new.application ?? self.application
    self.application_id = new.application_id ?? self.application_id
    self.message_reference = new.message_reference ?? self.message_reference
    self.flags = new.flags ?? self.flags
    self.interaction = new.interaction ?? self.interaction
    self.thread = new.thread ?? self.thread
    self.components = new.components ?? self.components
    self.sticker_items = new.sticker_items ?? self.sticker_items
    self.stickers = new.stickers ?? self.stickers
    self.position = new.position ?? self.position
    self.role_subscription_data =
      new.role_subscription_data ?? self.role_subscription_data
    self.resolved = new.resolved ?? self.resolved
    self.poll = new.poll ?? self.poll
    self.call = new.call ?? self.call
    self.member = new.member ?? self.member
    self.guild_id = new.guild_id ?? self.guild_id

    if let ref = new.referenced_message {
      var selfref = self.referenced_message?.value
      selfref?.update(with: ref.value)
      let box: DereferenceBox<DiscordChannel.Message>? =
        selfref == nil ? nil : .init(value: selfref!)
      self.referenced_message = box ?? self.referenced_message
    }
  }
}

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

extension Guild.Member {
  func toPartialMember() -> Guild.PartialMember {
    .init(
      user: self.user,
      nick: self.nick,
      avatar: self.avatar,
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

  mutating func update(with new: Guild.PartialMember) {
    self.user = new.user ?? self.user
    self.nick = new.nick ?? self.nick
    self.avatar = new.avatar ?? self.avatar
    self.roles = new.roles ?? self.roles
    self.joined_at = new.joined_at ?? self.joined_at
    self.premium_since = new.premium_since ?? self.premium_since
    self.deaf = new.deaf ?? self.deaf
    self.mute = new.mute ?? self.mute
    self.pending = new.pending ?? self.pending
    self.flags = new.flags ?? self.flags
    self.permissions = new.permissions ?? self.permissions
    self.communication_disabled_until =
      new.communication_disabled_until ?? self.communication_disabled_until
    self.avatar_decoration_data =
      new.avatar_decoration_data ?? self.avatar_decoration_data
  }
}

extension Guild.PartialMember {
  mutating func update(with new: Guild.PartialMember) {
    self.user = new.user ?? self.user
    self.nick = new.nick ?? self.nick
    self.avatar = new.avatar ?? self.avatar
    self.roles = new.roles ?? self.roles
    self.joined_at = new.joined_at ?? self.joined_at
    self.premium_since = new.premium_since ?? self.premium_since
    self.deaf = new.deaf ?? self.deaf
    self.mute = new.mute ?? self.mute
    self.pending = new.pending ?? self.pending
    self.flags = new.flags ?? self.flags
    self.permissions = new.permissions ?? self.permissions
    self.communication_disabled_until =
      new.communication_disabled_until ?? self.communication_disabled_until
    self.avatar_decoration_data =
      new.avatar_decoration_data ?? self.avatar_decoration_data
  }
}

extension DiscordRelationship {
  mutating func update(with new: Gateway.PartialRelationship) {
    self.id = new.id
    self.type = new.type
    self.nickname = new.nickname ?? self.nickname
    self.stranger_request = new.stranger_request ?? self.stranger_request
    self.user_ignored = new.user_ignored ?? self.user_ignored
    self.since = new.since ?? self.since
  }
}
