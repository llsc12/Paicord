//
//  GuildMemberJoin.swift
//  Paicord
//
//  Created by tiramisu on 2026.05.04.
//

import PaicordLib
import SwiftUIX

extension MessageCell {
  struct GuildMemberJoinMessage: View, Equatable {
    let message: DiscordChannel.Message
    let channelStore: ChannelStore
    
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
    
    static func == (lhs: GuildMemberJoinMessage, rhs: GuildMemberJoinMessage) -> Bool {
      lhs.message.id == rhs.message.id
    }
    
    var body: some View {
      HStack(spacing: 8) {
        Image(systemName: "arrow.right")
          .width(avatarSize)
          .foregroundStyle(.green)
        
        HStack(spacing: 6) {
          HStack(spacing: 4) {
            MessageAuthor.Username(
              message: message,
              guildStore: channelStore.guildStore,
              profileOpen: $profileOpen
            ).popover(isPresented: $profileOpen) {
              if let userId = message.author?.id, let user = message.author {
                ProfilePopoutView(
                  guild: channelStore.guildStore,
                  member: channelStore.guildStore?.member(userId)
                  ?? message.member,
                  user: user.toPartialUser()
                )
              }
            }
            
            Text("just slid into the server.")
#if os(iOS)
              .font(.callout)
#elseif os(macOS)
              .font(.body)
#endif
          }
          
          Text(timestampText)
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }.frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
