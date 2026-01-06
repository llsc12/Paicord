//
//  EntityContextMenu.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 06/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

extension View {
  func entityContextMenu<Entity>(
    for entity: Entity,
    case: EntityContextMenuUseCase? = nil
  ) -> some View {
    self
      .modifier(EntityContextMenu<Entity>(entity: entity))
  }
}

enum EntityContextMenuUseCase {
  case channelFromDMsScroller
  case channelFromGuildScroller
}

struct EntityContextMenu<Entity>: ViewModifier {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  @Environment(\.guildStore) var guild
  @Environment(\.channelStore) var channel

  var settings: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings {
    gw.settings.userSettings
  }

  var entity: Entity

  func body(content: Content) -> some View {
    content
      .contextMenu {
        switch entity {
        case let user as PartialUser:
          userContextMenu(user: user)
        case let message as DiscordChannel.Message:
          messageContextMenu(message: message)
        default: EmptyView()
        }
      }
  }

  @ViewBuilder
  func messageContextMenu(message: DiscordChannel.Message) -> some View {
    if hasPermission(.addReactions) {
      ControlGroup {
        Button {
        } label: {
          WebImage(
            url: .init(
              string:
                "https://cdn.discordapp.com/emojis/1026533070955872337.png?size=96"
            )
          )
          .resizable()
          .scaledToFit()
          .frame(width: 36, height: 36)
        }
        Button {
        } label: {
          WebImage(
            url: .init(
              string:
                "https://cdn.discordapp.com/emojis/1026533070955872337.png?size=96"
            )
          )
          .resizable()
          .scaledToFit()
          .frame(width: 36, height: 36)
        }
        Button {
        } label: {
          WebImage(
            url: .init(
              string:
                "https://cdn.discordapp.com/emojis/1026533070955872337.png?size=96"
            )
          )
          .resizable()
          .scaledToFit()
          .frame(width: 36, height: 36)
        }
        Button {
        } label: {
          WebImage(
            url: .init(
              string:
                "https://cdn.discordapp.com/emojis/1024751291504791654.png?size=96"
            )
          )
          .resizable()
          .scaledToFit()
          .frame(width: 36, height: 36)
        }
      }
      .controlGroupStyle(.compactMenu)
    }

    ControlGroup {
      if hasPermission(.createPublicThreads) {
        Button {
        } label: {
          Label("Thread", systemImage: "option")
        }
      }
      Button {
      } label: {
        Label("Forward", systemImage: "arrowshape.turn.up.right.fill")
      }
      if hasPermission(.sendMessages) {
        Button {
        } label: {
          Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
        }
      }
      if messageIsFromSelf(message) {
        Button {
        } label: {
          Label("Edit Message", systemImage: "pencil")
        }
      }
    }

    Divider()

    Menu {
      Button {
        copyText(message.content)
      } label: {
        Label("Copy Text", systemImage: "document.on.document.fill")
      }
      Button {
        let guildID = appState.selectedGuild?.rawValue ?? "@me"
        let channelID = message.channel_id.rawValue
        let messageID = message.id.rawValue
        copyText(
          "https://discord.com/channels/\(guildID)/\(channelID)/\(messageID)"
        )
      } label: {
        Label("Copy Message Link", systemImage: "link")
      }
      if isDeveloperModeEnabled() {
        Button {
          copyText(message.id.rawValue)
        } label: {
          Label("Copy Message ID", systemImage: "circle.grid.2x1.right.filled")
        }
        if let authorID = message.author?.id.rawValue {
          Button {
            copyText(authorID)
          } label: {
            Label("Copy Author ID", systemImage: "circle.grid.2x1.right.filled")
          }
        }
      }
    } label: {
      Label("Copy", systemImage: "doc.on.doc.fill")
    }

    Button {
    } label: {
      Label("Mark Unread", systemImage: "envelope.badge.fill")
    }
    //    Button {
    //    } label: {
    //      Label("Save Message", systemImage: "bookmark")
    //    }

    Menu {
      Button("1", action: {})
      Button("2", action: {})
      Button("3", action: {})
    } label: {
      Label("Apps", systemImage: "puzzlepiece.fill")
    }

    Button {
    } label: {
      Label("Mention", systemImage: "at")
    }

    Divider()

    if messageIsFromSelf(message) || hasPermission(.manageMessages) {
      Menu {
        Section {
          Button(role: .destructive) {
            Task {
              var res: DiscordHTTPResponse?
              do {
                res = try await gw.client.deleteMessage(
                  channelId: message.channel_id,
                  messageId: message.id
                )
                try res?.guardSuccess()
              } catch {
                if let error = res?.asError() {
                  appState.error = error
                } else {
                  appState.error = error
                }
              }
            }
          } label: {
            Label("Delete", systemImage: "trash")
          }
        } header: {
          Text("Are you sure?")
        }
      } label: {
        Label("Delete Message", systemImage: "trash")
      }
    }
  }

  @ViewBuilder
  func userContextMenu(user: PartialUser) -> some View {
    Button {
      copyText(user.id.rawValue)
    } label: {
      Label("Copy User ID", systemImage: "circle.grid.2x1.right.filled")
    }
  }

  // Helpers

  func messageIsFromSelf(_ msg: DiscordChannel.Message) -> Bool {
    guard let currentUserID = gw.user.currentUser?.id else {
      return false
    }
    return msg.author?.id == currentUserID
  }

  func isDeveloperModeEnabled() -> Bool {
    settings.appearance.developerMode
  }

  func hasPermission(
    _ permission: Permission
  ) -> Bool {
    guard let guild else { return true }
    return guild.hasPermission(channel: channel, permission)
  }

  func copyText(_ string: String) {
    #if os(iOS)
      UIPasteboard.general.string = string
    #elseif os(macOS)
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(string, forType: .string)
    #endif
  }
}
