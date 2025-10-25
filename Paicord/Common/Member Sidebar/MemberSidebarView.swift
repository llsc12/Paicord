//
//  MemberSidebarView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 24/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX
import DiscordModels
import SDWebImageSwiftUI

struct MemberSidebarView: View {
  @Environment(GatewayStore.self) var gw
  var guildStore: GuildStore?
  var channelStore: ChannelStore?
  var body: some View {
    Group {
      if let channelStore {
        if let recipients = channelStore.channel?.recipients, recipients.count > 1 {
          GroupDMsMemberList(channelStore: channelStore, recipients: recipients)
        } else if let guildStore {
          GuildMemberList(guildStore: guildStore, channelStore: channelStore)
        } else if let user = channelStore.channel?.recipients?.first {
          DMProfilePanel(user: user)
        } else {
          EmptyView()
        }
      } else {
        EmptyView()
      }
    }
    .ignoresSafeArea()
  }
  
  struct GuildMemberList: View {
    var guildStore: GuildStore
    var channelStore: ChannelStore
    
    var body: some View {
      Text("Unimplemented")
    }
  }
  
  struct GroupDMsMemberList: View {
    var channelStore: ChannelStore
    var recipients: [DiscordUser]
    var body: some View {
      ScrollView {
        LazyVStack {
          ForEach(recipients) { recipient in
            MemberRowView(user: recipient)
          }
        }
      }
      .scrollClipDisabled()
      .padding(4)
    }
  }
  
  struct DMProfilePanel: View {
    @Environment(GatewayStore.self) var gw
    @Environment(PaicordAppState.self) var appState
    var user: DiscordUser
    
    @State private var profile: DiscordUser.Profile?
    
    var body: some View {
      VStack() {
        ZStack(alignment: .bottomLeading) {
          WebImage(
            url: bannerURL(animated: true),
          )
          .resizable()
          .frame(height: 120)
          .maxWidth(.infinity)
          .background(.blue)
          
          Profile.AvatarWithPresence(
            member: nil,
            user: user
          )
          .animated(true)
          .showsAvatarDecoration()
          .frame(width: 60, height: 60)
          .background(
            Circle()
              .fill(Color.secondarySystemBackground)
              .stroke(Color.secondarySystemBackground, lineWidth: 6)
          )
          .offset(x: 35, y: 30)
        }
        .zIndex(1)
        
        VStack(alignment: .leading, spacing: 16) {
          HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
             Text(user.global_name ?? user.username)
               .font(.title)
               .bold()
              
              Text(user.username)
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            
//            Spacer()
            
//            // guild tag
//            if let tag_guild = user.primary_guild,
//               let tag = tag_guild.tag {
//              Label(tag, systemImage: "flame.fill")
//                .labelStyle(.titleAndIcon)
//                .padding(6)
//                .background(Color.purple.opacity(0.15))
//                .cornerRadius(8)
//            }
          }
          
//          HStack(spacing: 10) {
//            // badges
//            Label("", systemImage: "number")
//          }
//          .foregroundColor(.gray)
          
          Divider()
          
          VStack(alignment: .leading, spacing: 6) {
            Text("About Me")
              .font(.caption)
              .foregroundColor(.gray)
            Text(profile?.user_profile?.bio ?? "")
            if let userIdInfo = user.id.parse() {
              Text("Member Since")
                .font(.caption)
                .foregroundColor(.gray)
              Text(userIdInfo.date, style: .date)
                .font(.body)
            }
            if let since = gw.user.relationships[user.id]?.since {
              Text("Friends Since")
                .font(.caption)
                .foregroundColor(.gray)
              Text(since.date, style: .date)
                .font(.body)
            }
          }
          
          Divider()
          
          VStack(alignment: .leading, spacing: 6) {
            if let guildCount = profile?.mutual_guilds?.count, guildCount > 0 {
              MutualItem(
                title: "Mutual Servers",
                count: guildCount,
                action: {}
              )
            }
            if let friendCount = profile?.mutual_friends_count, friendCount > 0 {
              MutualItem(
                title: "Mutual Friends",
                count: friendCount,
                action: {}
              )
            }
          }
          
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 75)
        .padding(.bottom, 20)
        .background(Color.secondarySystemBackground)
        .cornerRadius(20)
        .padding(.horizontal)
        .offset(y: -40)
        .zIndex(0)
      }
      .ignoresSafeArea(edges: .top)
      .task(id: user.id) {
        let res = try? await gw.client.getUserProfile(
          userID: user.id,
          withMutualGuilds: true,
          withMutualFriends: true,
          withMutualFriendsCount: true,
          guildID: nil
        )
        do {
          // ensure request was successful
          try res?.guardSuccess()
          let profile = try res?.decode()
          self.profile = profile
        } catch {
          if let error = res?.asError() {
            appState.error = error
          } else {
            appState.error = error
          }
        }
      }
    }
    
    func bannerURL(animated: Bool) -> URL? {
      let userId = user.id
      if let banner = user.banner {
        return URL(
          string: CDNEndpoint.userBanner(
            userId: userId,
            banner: banner
          ).url
          + ((banner.hasPrefix("a_") && animated)
             ? ".gif" : ".png") + "?size=600"
        )
      } else if let banner = profile?.user_profile?.banner {
        return URL(
          string: CDNEndpoint.userBanner(
            userId: userId,
            banner: banner
          ).url
            + ((banner.hasPrefix("a_") && animated)
              ? ".gif" : ".png") + "?size=600"
        )
      }
      return nil
    }
  }
}

struct MutualItem: View {
    let title: String
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(title) — \(count)")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
