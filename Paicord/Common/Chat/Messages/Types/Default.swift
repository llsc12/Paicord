//
//  Default.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 10/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

extension MessageCell {
  struct DefaultMessage: View {
    let message: DiscordChannel.Message
    let priorMessage: DiscordChannel.Message?
    let channelStore: ChannelStore
    let inline: Bool

    @State var editedPopover = false
    @State var avatarAnimated = false
    @State var profileOpen = false

    var body: some View {
      if inline {
        HStack(alignment: .top) {
          AvatarBalancing()

          MessageBody(
            message: message,
            channelStore: channelStore
          )
        }
      } else {
        VStack {
          reply
          HStack(alignment: .bottom) {
            MessageAuthor.Avatar(
              message: message,
              guildStore: channelStore.guildStore,
              profileOpen: $profileOpen,
              animated: avatarAnimated
            )
            #if os(macOS)
              .padding(.trailing, 4)  // balancing
            #endif
            userAndMessage
          }
          .fixedSize(horizontal: false, vertical: true)
        }
        .onHover { self.avatarAnimated = $0 }
      }
    }

    @ViewBuilder
    var reply: some View {
      if let ref = message.referenced_message {
        HStack {
          ReplyLine()
            .padding(.leading, avatarSize / 2)  // align with pfp

          Text("\(ref.author?.username ?? "Unknown") • \(ref.content)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }

    @ViewBuilder
    var userAndMessage: some View {
      VStack(spacing: 2) {
        HStack(alignment: .center) {
          MessageAuthor.Username(  // username line
            message: message,
            guildStore: channelStore.guildStore,
            profileOpen: $profileOpen
          )
          Date(for: message.timestamp.date)  // message date
          if let edit = message.edited_timestamp {  // edited notice
            EditStamp(edited: edit)
          }
        }
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .bottomLeading
        )
        .fixedSize(horizontal: false, vertical: true)

        MessageBody(
          message: message,
          channelStore: channelStore
        )  // content
      }
      .frame(maxHeight: .infinity, alignment: .bottom)  // align text to bottom of cell
    }

    @ViewBuilder
    func Date(for date: Date) -> some View {
      Group {
        if Calendar.current.isDateInToday(date) {
          Text(message.timestamp.date, style: .time)
        } else if Calendar.current.isDateInYesterday(date) {
          Text("Yesterday at ") + Text(message.timestamp.date, style: .time)
        } else {
          Text(date, format: .dateTime.month().day().year())
        }
      }
      .font(.caption2)
      .foregroundStyle(.secondary)
    }

    struct EditStamp: View {
      var edited: DiscordTimestamp
      @State private var editedPopover = false
      var body: some View {
        Text("(edited)")
          .font(.caption)
          .foregroundStyle(.secondary)
          .popover(isPresented: $editedPopover) {
            Text(
              "Edited at \(edited.date.formatted(date: .abbreviated, time: .standard))"
            )
            .padding()
          }
          .onHover { self.editedPopover = $0 }
      }
    }
  }
}
