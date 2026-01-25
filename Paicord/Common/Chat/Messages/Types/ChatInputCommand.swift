//
//  ChatInputCommand.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

extension MessageCell {
  struct ChatInputCommandMessage: View {
    let message: DiscordChannel.Message
    let channelStore: ChannelStore

    @State private var editedPopover = false
    @State private var profileOpen = false

    private var timestampText: String {
      let date = message.timestamp.date
      if Calendar.current.isDateInToday(date) {
        return Self.timeFormatter.string(from: date)
      } else if Calendar.current.isDateInYesterday(date) {
        return "Yesterday at " + Self.timeFormatter.string(from: date)
      } else {
        return Self.fullDateFormatter.string(from: date)
      }
    }

    private var editedText: String? {
      guard let edited = message.edited_timestamp?.date else { return nil }
      return Self.fullDateTimeFormatter.string(from: edited)
    }

    private var replyPreview: (name: String, content: String)? {
      guard let ref = message.referenced_message else { return nil }
      let mention = ref.mentions.map(\.id).contains(ref.author?.id) ? "@" : ""
      let name = ref.member?.nick ?? ref.author?.global_name ?? ref.author?.username ?? "Unknown"
      let content = ref.content
      return (name: "\(mention)\(name)", content: content)
    }

    private static let timeFormatter: DateFormatter = {
      let f = DateFormatter()
      f.timeStyle = .short
      f.dateStyle = .none
      return f
    }()

    private static let fullDateFormatter: DateFormatter = {
      let f = DateFormatter()
      f.dateStyle = .medium
      f.timeStyle = .none
      return f
    }()

    private static let fullDateTimeFormatter: DateFormatter = {
      let f = DateFormatter()
      f.dateStyle = .medium
      f.timeStyle = .short
      return f
    }()

    static func == (lhs: ChatInputCommandMessage, rhs: ChatInputCommandMessage) -> Bool {
      lhs.message.id == rhs.message.id &&
      lhs.message.edited_timestamp == rhs.message.edited_timestamp &&
      lhs.message.embeds == rhs.message.embeds
    }

    var body: some View {
      VStack(alignment: .leading, spacing: 4) {
        replyView
        HStack(alignment: .bottom, spacing: 8) {
          MessageAuthor.Avatar(
            message: message,
            guildStore: channelStore.guildStore,
            profileOpen: $profileOpen
          )
          #if os(macOS)
          .padding(.trailing, 4) // balancing
          #endif
          userAndMessage
        }
      }
    }

    @ViewBuilder
    private var replyView: some View {
      if let preview = replyPreview {
        HStack(spacing: 6) {
          ReplyLine()
            .padding(.leading, avatarSize / 2)
          Text(preview.name)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .font(.caption2)
          Text("•")
            .foregroundStyle(.secondary)
            .font(.caption2)
          Text(markdown: preview.content)
            .lineLimit(1)
            .foregroundStyle(.secondary)
            .font(.caption2)
        }
        .opacity(0.7)
      }
    }

    @ViewBuilder
    private var userAndMessage: some View {
      VStack(alignment: .leading, spacing: 2) {
        HStack(alignment: .center, spacing: 6) {
          MessageAuthor.Username(
            message: message,
            guildStore: channelStore.guildStore,
            profileOpen: $profileOpen
          )
          Text(timestampText)
            .font(.caption2)
            .foregroundStyle(.secondary)
          if let editedText {
            EditStamp(editedText: editedText)
          }
        }
        MessageBody(message: message, channelStore: channelStore)
      }
    }

    struct EditStamp: View {
      var editedText: String
      @State private var editedPopover = false
      var body: some View {
        Text("(edited)")
          .font(.caption)
          .foregroundStyle(.secondary)
          .popover(isPresented: $editedPopover) {
            Text("Edited at \(editedText)")
              .padding()
          }
          .onHover { isHovering in
            if editedPopover != isHovering { editedPopover = isHovering }
          }
      }
    }
  }
}
