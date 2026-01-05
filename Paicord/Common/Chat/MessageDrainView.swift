//
//  MessageDrainView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 04/01/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Collections
import PaicordLib
import SwiftUIX

struct MessageDrainView: View {
  @Environment(\.gateway) var gw
  @Environment(\.channelStore) var vm

  var drain: MessageDrainStore { gw.messageDrain }

  var body: some View {
    let pendingMessages:
      OrderedDictionary<MessageSnowflake, Payloads.CreateMessage> =
        if let channelId = vm?.channelId {
          drain.pendingMessages[channelId, default: [:]]
        } else { [:] }
    ForEach(pendingMessages.values.reversed()) { message in
      // if there is only one message, there is no prior. use the latest message from channelstore
      if pendingMessages.count > 1,
        let messageIndex = pendingMessages.values.firstIndex(where: {
          $0.nonce == message.nonce
        }),
        messageIndex > 0
      {
        let priorMessage = pendingMessages.values[messageIndex - 1]
        SendMessageCell(for: message, prior: priorMessage)
      } else if let channelStore = vm,
        let latestMessage = channelStore.messages.values.last
      {
        // if there is a prior message from the channel store, use that
        SendMessageCell(for: message, prior: latestMessage)
      } else {
        // no prior message
        SendMessageCell(
          for: message,
          prior: Optional<DiscordChannel.Message>.none
        )
      }
    }
  }
}

// copy of MessageCell for messages being sent
extension MessageDrainView {
  struct SendMessageCell: View {
    var message: Payloads.CreateMessage
    /// Set this if the prior message exists, from discord.
    var priorMessageExisting: DiscordChannel.Message?
    /// Set this if the prior message is from the drain queue.
    var priorMessageEnqueued: Payloads.CreateMessage?
    @Environment(\.channelStore) var channelStore
    @Environment(\.gateway) var gw
    @State var cellHighlighted = false

    init(
      for message: Payloads.CreateMessage,
      prior: DiscordChannel.Message? = nil
    ) {
      self.message = message
      self.priorMessageExisting = prior
    }
    init(
      for message: Payloads.CreateMessage,
      prior: Payloads.CreateMessage? = nil
    ) {
      self.message = message
      self.priorMessageEnqueued = prior
    }

    var userMentioned: Bool {
      guard let currentUserID = gw.user.currentUser?.id else {
        return false
      }
      let mentionedUser: Bool =
        message.content?.contains("<@\(currentUserID)>") == true
      let mentionedEveryone: Bool =
        message.content?.contains("@everyone") == true
        || message.content?.contains("@here") == true
      let mentionedUserByRole: Bool = {
        let usersRoles =
          channelStore?.guildStore?.members[currentUserID]?.roles ?? []
        for roleID in usersRoles {
          if message.content?.contains("<@&\(roleID)>") == true {
            return true
          }
        }
        return false
      }()
      return mentionedUser || mentionedEveryone || mentionedUserByRole
    }

    var body: some View {
      let inline =
        priorMessageExisting?.author?.id == gw.user.currentUser?.id
        || priorMessageEnqueued != nil && message.message_reference == nil

      // adding them together can cause arithmetic overflow, so hash instead
      let cellHash: Int = {
        var hasher = Hasher()
        hasher.combine(message)
        if let priorMessage = priorMessageExisting {
          hasher.combine(priorMessage)
        }
        if let priorMessage = priorMessageEnqueued {
          hasher.combine(priorMessage)
        }
        return hasher.finalize()
      }()

      Group {
        DefaultMessage(
          message: message,
          channelStore: channelStore!,
          inline: inline
        )
      }
      .background(Color.almostClear)
      .padding(.horizontal, 10)
      .padding(.vertical, 2)
      .background(
        Color(hexadecimal6: 0xcc8735).opacity(userMentioned ? 0.05 : 0)
      )
      .background(alignment: .leading) {
        Color(hexadecimal6: 0xce9c5c).opacity(userMentioned ? 1 : 0)
          .maxWidth(2)
      }
      .equatable(by: cellHash)
      /// stop updates to messages unless messages change.
      /// prevent updates to messages unless they change
      /// avoid re-render on message cell highlight
      #if os(macOS)
        .onHover { self.cellHighlighted = $0 }
        .background(
          cellHighlighted
            ? Color(NSColor.secondaryLabelColor).opacity(0.1) : .clear
        )
      #endif
      .entityContextMenu(for: message)
      .padding(.top, inline ? 0 : 15)  // adds space between message groups

    }
  }

  struct DefaultMessage: View {
    let message: Payloads.CreateMessage
    let channelStore: ChannelStore
    @Environment(\.gateway) var gw
    let inline: Bool

    @State var editedPopover = false
    @State var avatarAnimated = false
    @State var profileOpen = false

    var body: some View {
      if inline {
        HStack(alignment: .top) {
          MessageCell.AvatarBalancing()

          content
        }
      } else {
        VStack {
          reply
          HStack(alignment: .bottom) {
            avatar
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
      if let refID = message.message_reference?.message_id, let msg = channelStore.messages[refID] {
        HStack(spacing: 0) {
          MessageCell.ReplyLine()
            .padding(.leading, MessageCell.avatarSize / 2)  // align with pfp
            .padding(.trailing, 6)
          
          Group {
            Text("\(msg.author?.username ?? "Unknown") • ")
              .foregroundStyle(.secondary)
              .lineLimit(1)
            MarkdownText(content: msg.content, channelStore: channelStore)
              .lineLimit(1)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .font(.caption2)
          .opacity(0.6)
        }
      }
    }

    @ViewBuilder
    var userAndMessage: some View {
      VStack(spacing: 2) {
        HStack(alignment: .center) {
          username  // username
          // make date from nonce
          let date: Date =
            MessageSnowflake(message.nonce?.asString ?? "0").parse()?.date
            ?? Foundation.Date.now

          Date(for: date)  // message date
        }
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .bottomLeading
        )
        .fixedSize(horizontal: false, vertical: true)

        content  // message content
      }
      .frame(maxHeight: .infinity, alignment: .bottom)  // align text to bottom of cell
    }

    @ViewBuilder var avatar: some View {
      Button {
        guard gw.user.currentUser != nil else { return }
        ImpactGenerator.impact(style: .light)
        profileOpen = true
      } label: {
        let guildstoremember =
          gw.user.currentUser != nil
          ? channelStore.guildStore?.members[gw.user.currentUser!.id] : nil
        Profile.Avatar(
          member: guildstoremember,
          user: gw.user.currentUser?.toPartialUser()
        )
        .profileAnimated(avatarAnimated)
        .profileShowsAvatarDecoration()
        .frame(width: MessageCell.avatarSize, height: MessageCell.avatarSize)
      }
      .buttonStyle(.borderless)
      .popover(isPresented: $profileOpen) {
        if let userId = gw.user.currentUser?.id, let user = gw.user.currentUser
        {
          ProfilePopoutView(
            guild: channelStore.guildStore,
            member: channelStore.guildStore?.members[userId],
            user: user.toPartialUser()
          )
        }
      }
      .frame(maxHeight: .infinity, alignment: .top)  // align pfp to top of cell
    }

    @ViewBuilder var username: some View {
      Button {
        guard gw.user.currentUser != nil else { return }
        ImpactGenerator.impact(style: .light)
        profileOpen = true
      } label: {
        if let guildStore = channelStore.guildStore,
          let userID = gw.user.currentUser?.id
        {
          let member = guildStore.members[userID]
          let color = member?.roles?.compactMap { guildStore.roles[$0] }
            .sorted(by: { $0.position > $1.position })
            .compactMap { $0.color.value != 0 ? $0.color : nil }
            .first?.asColor()

          Text(
            member?.nick ?? gw.user.currentUser?.global_name ?? gw.user
              .currentUser?
              .username
              ?? "Unknown"
          )
          .foregroundStyle(color != nil ? color! : .primary)
        } else {
          Text(
            gw.user.currentUser?.global_name ?? gw.user.currentUser?.username
              ?? "Unknown"
          )
        }
      }
      .buttonStyle(.plain)
      #if os(iOS)
        .font(.callout)
      #elseif os(macOS)
        .font(.body)
      #endif
      .fontWeight(.semibold)
    }

    @ViewBuilder
    func Date(for date: Date) -> some View {
      Group {
        if Calendar.current.isDateInToday(date) {
          Text(date, style: .time)
        } else if Calendar.current.isDateInYesterday(date) {
          Text("Yesterday at ") + Text(date, style: .time)
        } else {
          Text(date, format: .dateTime.month().day().year())
        }
      }
      .font(.caption2)
      .foregroundStyle(.secondary)
    }

    @ViewBuilder var content: some View {
      VStack(alignment: .leading, spacing: 4) {
        MarkdownText(content: message.content ?? "", channelStore: channelStore)
          .equatable(by: message.content)
      }
      .opacity(0.6)  // indicate pending state
    }
  }
}
