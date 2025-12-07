//
//  ProfileBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 24/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftPrettyPrint
import SwiftUIX

struct ProfileBar: View {
  @Environment(\.gateway) var gw
  #if os(macOS)
    @Environment(\.openWindow) var openWindow
  #endif

  @State var showingUsername = false
  @State var showingPopover = false
  @State var barHovered = false

  var body: some View {
    HStack {
      Button {
        showingPopover.toggle()
      } label: {
        HStack {
          if let user = gw.user.currentUser {
            Profile.AvatarWithPresence(
              member: nil,
              user: user
            )
            .maxHeight(40)
            .profileAnimated(barHovered)
            .profileShowsAvatarDecoration()
          }

          VStack(alignment: .leading) {
            Text(
              gw.user.currentUser?.global_name ?? gw.user.currentUser?.username
                ?? "Unknown User"
            )
            .bold()
            if showingUsername {
              Text("@\(gw.user.currentUser?.username ?? "Unknown User")")
                .transition(.opacity)
            } else {
              if let session = gw.user.sessions.first(where: { $0.id == "all" }
              ),
                let status = session.activities.first,
                status.type == .custom
              {
                if let emoji = status.emoji {
                  if let url = emojiURL(for: emoji, animated: true) {
                    WebImage(url: url)
                      .resizable()
                      .scaledToFit()
                      .frame(width: 16, height: 16)
                  } else {
                    Text(emoji.name)
                      .font(.system(size: 14))
                  }
                }

                Text(status.state ?? "")
                  .transition(.opacity)
              }
            }
          }
          .background(.black.opacity(0.001))
          .onHover { showingUsername = $0 }
          .animation(.spring(), value: showingUsername)
        }
      }
      .buttonStyle(.plain)
      .popover(isPresented: $showingPopover) {
        ScrollView {
          VStack {
            Menu {

            } label: {
              HStack {
                if let user = gw.user.currentUser {
                  Profile.AvatarWithPresence(
                    member: nil,
                    user: user
                  )
                  .maxHeight(22)
                }

                Text(
                  gw.user.currentUser?.global_name ?? gw.user.currentUser?
                    .username
                    ?? "Unknown User"
                )
                .bold()
              }

            }
          }
        }
        .minWidth(250)
        .minHeight(300)
      }

      Spacer()

      #if os(macOS)
        Button {
          openWindow(id: "settings")
        } label: {
          Image(systemName: "gearshape.fill")
            .font(.title2)
            .padding(5)
            .background(.ultraThinMaterial)
            .clipShape(.circle)
        }
        .buttonStyle(.borderless)
      #elseif os(iOS)
        /// targetting ipad here, ios wouldnt have this at all
        // do something
      #endif
    }
    .padding(10)
    .background {
      if let nameplate = gw.user.currentUser?.collectibles?.nameplate {
        Profile.NameplateView(nameplate: nameplate)
          .nameplateAnimated(barHovered)
          .saturation(0.9)
          .brightness(0.1)
      }
    }
    .clipped()
    .onHover { barHovered = $0 }
  }

  func emojiURL(for emoji: Gateway.Activity.ActivityEmoji, animated: Bool)
    -> URL?
  {
    guard let id = emoji.id else { return nil }
    return URL(
      string: CDNEndpoint.customEmoji(emojiId: id).url
        + (animated && emoji.animated == true ? ".gif" : ".png") + "?size=44"
    )
  }
}
