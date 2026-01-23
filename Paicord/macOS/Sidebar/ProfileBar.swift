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
                    AnimatedImage(url: url)
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
        ProfileButtonPopout()
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

  struct ProfileButtonPopout: View {
    @Environment(\.gateway) var gw
    @Environment(\.appState) var appState
    @State var statusSelectionExpanded = false
    @State var accountSelectionExpanded = false

    var body: some View {
      List {
        HStack {
          if let user = gw.user.currentUser {
            Profile.AvatarWithPresence(
              member: nil,
              user: user
            )
            .maxWidth(40)
            .maxHeight(40)
            .profileAnimated(false)
            .profileShowsAvatarDecoration()
          }

          VStack(alignment: .leading) {
            Text(
              gw.user.currentUser?.global_name ?? gw.user.currentUser?.username
                ?? "Unknown User"
            )
            .bold()
            Text("@\(gw.user.currentUser?.username ?? "Unknown User")")
          }
        }
        .padding(.vertical, 5)

        NavigationLink(value: "gm") {
          Label("Edit Profile", systemImage: "pencil")
            .padding(.vertical, 4)
        }
        .disabled(true)

        DisclosureGroup(isExpanded: $statusSelectionExpanded) {
          let statuses: [Gateway.Status] = [
            .online,
            .afk,
            .doNotDisturb,
            .invisible,
          ]

          ForEach(statuses, id: \.self) { status in
            AsyncButton {
            } catch: { error in
              appState.error = error
            } label: {
              statusItem(status)
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderless)
          }
        } label: {
          Button {
            withAnimation {
              statusSelectionExpanded.toggle()
            }
          } label: {
            statusItem(gw.presence.currentClientStatus)
              .padding(.vertical, 4)
          }
          .buttonStyle(.borderless)
        }

        DisclosureGroup(isExpanded: $accountSelectionExpanded) {
          ForEach(gw.accounts.accounts, id: \.id) { account in
            let isSignedInAccount = account.id == gw.accounts.currentAccountID
            AsyncButton {
              gw.accounts.currentAccountID = nil
              await gw.disconnectIfNeeded()
              gw.resetStores()
              gw.accounts.currentAccountID = account.id
            } catch: { error in
              appState.error = error
            } label: {
              HStack {
                Profile.AvatarWithPresence(
                  member: nil,
                  user: account.user
                )
                .maxWidth(25)
                .maxHeight(25)
                .profileAnimated(false)
                .profileShowsAvatarDecoration()

                VStack(alignment: .leading) {
                  Text(
                    account.user.global_name
                      ?? account.user.username
                  )
                  .lineSpacing(1)
                  .bold()
                  Text("@\(account.user.username)")
                    .lineSpacing(1)
                }

                Spacer()

                if isSignedInAccount {
                  Image(systemName: "checkmark")
                }
              }
              .padding(.vertical, 2)
            }
            .buttonStyle(.borderless)
            .disabled(isSignedInAccount)
          }

          AsyncButton {
            gw.accounts.currentAccountID = nil
            await gw.disconnectIfNeeded()
            gw.resetStores()
          } catch: { error in
            appState.error = error
          } label: {
            Label("Add Account", systemImage: "person.crop.circle.badge.plus")
              .padding(.vertical, 4)
          }
          .buttonStyle(.borderless)

        } label: {
          Button {
            withAnimation {
              accountSelectionExpanded.toggle()
            }
          } label: {
            Label("Switch Account", systemImage: "person.crop.circle")
              .padding(.vertical, 4)
          }
          .buttonStyle(.borderless)

        }

      }
      .minWidth(250)
      .minHeight(300)
    }

    @ViewBuilder
    func statusItem(_ status: Gateway.Status) -> some View {
      let color: Color = {
        switch status {
        case .online: return .init(hexadecimal6: 0x42a25a)
        case .afk: return .init(hexadecimal6: 0xca9653)
        case .doNotDisturb: return .init(hexadecimal6: 0xd83a42)
        default: return .init(hexadecimal6: 0x82838b)
        }
      }()

      Label {
        Text(status.rawValue.capitalized)
      } icon: {
        Group {
          switch status {
          case .online:
            StatusIndicatorShapes.OnlineShape()
          case .afk:
            StatusIndicatorShapes.IdleShape()
          case .doNotDisturb:
            StatusIndicatorShapes.DNDShape()
          default:
            StatusIndicatorShapes.InvisibleShape()
          }
        }
        .foregroundStyle(color)
        .frame(width: 15, height: 15)
      }
    }
  }

}
