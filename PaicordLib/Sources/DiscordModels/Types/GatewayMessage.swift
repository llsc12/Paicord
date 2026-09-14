extension DiscordChannel.Message {
  public init(_ event: Gateway.MessageCreate) {
    self.init(
      id: event.id,
      channel_id: event.channel_id,
      author: event.author,
      content: event.content,
      timestamp: event.timestamp,
      edited_timestamp: event.edited_timestamp,
      tts: event.tts,
      mention_everyone: event.mention_everyone,
      mentions: event.mentions,
      mention_roles: event.mention_roles,
      mention_channels: event.mention_channels,
      attachments: event.attachments,
      embeds: event.embeds,
      reactions: event.reactions,
      nonce: event.nonce,
      pinned: event.pinned,
      webhook_id: event.webhook_id,
      type: event.type,
      activity: event.activity,
      application: event.application,
      application_id: event.application_id,
      message_reference: event.message_reference,
      message_snapshots: event.message_snapshots,
      flags: event.flags,
      referenced_message: event.referenced_message.map { .init(value: .init($0.value)) },
      interaction: event.interaction,
      thread: event.thread,
      components: event.components,
      sticker_items: event.sticker_items,
      stickers: event.stickers,
      position: event.position,
      role_subscription_data: event.role_subscription_data,
      resolved: event.resolved,
      poll: event.poll,
      call: event.call,
      guild_id: event.guild_id,
      member: event.member
    )
    interaction_metadata = event.interaction_metadata
  }
}
