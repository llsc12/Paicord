//
//  ChannelHeader.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

extension ChatView {
  struct ChannelHeader: View {
    @Environment(\.gateway) var gw
    @Environment(\.userInterfaceIdiom) var idiom
    var vm: ChannelStore

    var body: some View {
      switch vm.channel?.type {
      case .dm, .groupDm:
        let ppl = vm.channel?.recipients ?? []
        let channel = vm.channel
        HStack(spacing: 8) {
          Group {
            if let icon = channel?.icon {
              let url = URL(
                string: CDNEndpoint.channelIcon(
                  channelId: vm.channelId,
                  icon: icon
                )
                .url + ".png?size=80"
              )
              WebImage(url: url)
                .resizable()
                .scaledToFit()
                .clipShape(.circle)
                .padding(2)
            } else {
              VStack {
                if let firstUser = channel?.recipients?.first(where: {
                  $0.id != gw.user.currentUser?.id
                }),
                  let lastUser = channel?.recipients?.last(where: {
                    $0.id != gw.user.currentUser?.id && $0.id != firstUser.id
                  })
                {
                  Group {
                    Profile.Avatar(
                      member: nil,
                      user: firstUser.toPartialUser()
                    )
                    .profileShowsAvatarDecoration()
                    .scaleEffect(0.75, anchor: .topLeading)
                    .overlay(
                      Profile.Avatar(
                        member: nil,
                        user: lastUser.toPartialUser()
                      )
                      .profileShowsAvatarDecoration()
                      .scaleEffect(0.75, anchor: .bottomTrailing)
                    )
                  }
                  .padding(2)
                } else if let user = channel?.recipients?.first {
                  Profile.AvatarWithPresence(
                    member: nil,
                    user: user.toPartialUser()
                  )
                  .profileShowsAvatarDecoration()
                  .padding(2)
                } else {
                  Circle()
                    .fill(Color.gray)
                    .padding(2)
                }
              }
              .aspectRatio(1, contentMode: .fit)
            }
          }
          .frame(width: 36, height: 36)

          Text(
            vm.channel?.name
              ?? ppl.map({
                $0.global_name ?? $0.username
              }).joined(separator: ", ")
          )
          .font(idiom == .phone ? .headline : .title3)
          .fontWeight(.semibold)
        }
      default:
        HStack(spacing: 4) {
          Image(systemName: "number")
            .foregroundStyle(.secondary)
            .imageScale(idiom == .phone ? .medium : .large)
          let name = vm.channel?.name ?? "Unknown Channel"
          Text(name)
            .font(idiom == .phone ? .headline : .title3)
            .fontWeight(.semibold)
        }
      }
    }
  }

  //  struct ChannelTopic: View {
  //    var topic: String
  //    @State private var showChannelInfo: Bool = false
  //
  //    var body: some View {
  //      Button {
  //        showChannelInfo.toggle()
  //      } label: {
  //        LabeledContent {
  //          HStack(spacing: 5) {
  //            Text(verbatim: "•")
  //              .foregroundStyle(.tertiary)
  //
  //            Text(topic)
  //              .lineLimit(1)
  //              .truncationMode(.tail)
  //              .foregroundStyle(.secondary)
  //              .font(.body)
  //          }
  //        } label: {
  //          Text(topic)
  //        }
  //      }
  //      .buttonStyle(.plain)
  //      .sheet(isPresented: $showChannelInfo) {
  //        Text(topic)
  //          .padding()
  //      }
  //    }
  //  }
}
