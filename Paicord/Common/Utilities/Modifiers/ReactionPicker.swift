//
//  ReactionPicker.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/09/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

// Presents the emoji picker for adding a reaction to a message. Lives at the
// root so the picker survives the message cell that asked for it going away.

import PaicordLib
import SwiftUIX

/// Identifies the message a reaction is being picked for.
struct ReactionPickerTarget: Identifiable, Hashable {
  let channelID: ChannelSnowflake
  let messageID: MessageSnowflake
  /// The guild the reaction lands in, or nil in a DM. Decides whether a custom
  /// emoji counts as external.
  let guildID: GuildSnowflake?

  var id: String { "\(channelID.rawValue)/\(messageID.rawValue)" }

  init(
    channelID: ChannelSnowflake,
    messageID: MessageSnowflake,
    guildID: GuildSnowflake?
  ) {
    self.channelID = channelID
    self.messageID = messageID
    self.guildID = guildID
  }

  init(message: DiscordChannel.Message, guildID: GuildSnowflake?) {
    self.init(
      channelID: message.channel_id,
      messageID: message.id,
      guildID: guildID
    )
  }
}

extension View {
  @ViewBuilder
  func reactionPicker() -> some View {
    self.modifier(ReactionPickerModifier())
  }
}

private struct ReactionPickerModifier: ViewModifier {
  @Environment(\.appState) var appState
  @Environment(\.gateway) var gw

  #if os(iOS)
    @State private var detent: PresentationDetent = .medium
  #endif

  func body(content: Content) -> some View {
    @Bindable var appState = appState
    content
      .sheet(item: $appState.reactionPickerTarget) { target in
        picker(for: target)
      }
      #if os(iOS)
        .onChange(of: appState.reactionPickerTarget) {
          // always open at the smaller detent
          if appState.reactionPickerTarget != nil { detent = .medium }
        }
      #endif
  }

  @ViewBuilder
  private func picker(for target: ReactionPickerTarget) -> some View {
    #if os(iOS)
      EmojiPicker(detent: $detent)
        .variant(.reactions)
        .allowsShiftToKeepOpen(false)
        .onPickedEmoji { emoji in
          appState.reactionPickerTarget = nil
          addReaction(emoji, to: target)
        }
        .presentationDetents([.medium, .large], selection: $detent)
    #else
      EmojiPicker()
        .variant(.reactions)
        .allowsShiftToKeepOpen(false)
        .onPickedEmoji { emoji in
          appState.reactionPickerTarget = nil
          addReaction(emoji, to: target)
        }
    #endif
  }

  /// Why this custom emoji can't be reacted with here, or nil if it can.
  ///
  /// Discord answers a reaction with an emoji the account isn't entitled to use
  /// with the same "Unknown Emoji" (10014) it gives for a malformed one, so the
  /// reason has to be worked out locally to say anything useful. Only reports a
  /// reason when the outcome is certain - anything uncertain is left to Discord
  /// rather than refusing a reaction that would have worked.
  @MainActor
  private func customEmojiUnavailableReason(
    _ emoji: DiscordModels.Emoji,
    in target: ReactionPickerTarget
  ) -> String? {
    guard let id = emoji.id else { return nil }  // unicode, nothing to check
    let label = emoji.name.map { ":\($0):" } ?? "That emoji"

    let source = gw.user.emojis.first { _, emojis in emojis[id] != nil }
    guard let (sourceGuildID, emojis) = source, let custom = emojis[id] else {
      return "\(label) isn't from a server you're in, so Discord won't accept it."
    }
    if custom.available == false {
      return "\(label) is currently unavailable on its server."
    }
    guard sourceGuildID != target.guildID else { return nil }  // same server: fine

    // Emoji from another server (or used in a DM) need Nitro.
    guard gw.user.premiumKind == .none else { return nil }
    let sourceName = gw.user.guilds[sourceGuildID]?.name ?? "another server"
    return
      "\(label) is from \(sourceName). Reacting with emoji from another server requires Nitro."
  }

  private func addReaction(
    _ emoji: DiscordModels.Emoji,
    to target: ReactionPickerTarget
  ) {
    ImpactGenerator.impact(style: .light)
    // The grid is built from SwiftEmojiIndex, which spells some sequences
    // differently to Discord; send Discord's spelling or it rejects the
    // reaction with "Unknown Emoji".
    if let reason = customEmojiUnavailableReason(emoji, in: target) {
      appState.error = reason
      return
    }
    var emoji = emoji
    if emoji.id == nil, let name = emoji.name {
      guard let character = DiscordEmojiNameIndex.discordCharacter(matching: name)
      else {
        appState.error = "Discord doesn't support reacting with \(name)."
        return
      }
      emoji = .init(name: character)
    }
    Task { @MainActor in
      do {
        let reaction = try Reaction(emoji: emoji)
        try await gw.client.addMessageReaction(
          channelId: target.channelID,
          messageId: target.messageID,
          emoji: reaction,
          type: .normal
        )
        .guardSuccess()
      } catch {
        appState.error = error
      }
    }
  }
}
