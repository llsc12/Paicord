//
//  GuildButton.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 02/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import Playgrounds
import SDWebImageSwiftUI
import SwiftUIX

/// Shows a guild folder or standalone guild
struct GuildButton: View {
  var guild: Guild?
  var guilds: [Guild]?
  var folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder?
  @Environment(\.appState) var appState
  @Environment(\.gateway) var gw
  @Environment(\.colorScheme) var colorScheme

  init(guild: Guild?) {
    self.guild = guild
    self.guilds = nil
    self.folder = nil
  }

  init(
    folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder,
    guilds: [Guild]
  ) {
    self.guilds = guilds
    self.folder = folder
  }

  var body: some View {
    if let folder, let guilds, folder.hasID {
      // must be a folder
      FolderButtons(id: folder.id.value, folder: folder, guilds: guilds)
        .padding(-2)
    } else {
      // either a guild or DMs
      guildButton(from: guild)
    }
  }

  /// Contains its own list of buttons, expands and contracts.
  struct FolderButtons: View {
    @Environment(\.gateway) var gw
    @Environment(\.colorScheme) var colorScheme

    var id: Int64
    var folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder
    var guilds: [Guild]

    // key is GuildFolders.\(id).isExpanded
    @State var isExpanded: Bool {
      didSet {
        UserDefaults.standard.set(
          isExpanded,
          forKey: "GuildFolders.\(id).isExpanded"
        )
      }
    }

    init(
      id: Int64,
      folder: DiscordProtos_DiscordUsers_V1_PreloadedUserSettings.GuildFolder,
      guilds: [Guild]
    ) {
      self.id = id
      self.folder = folder
      self.guilds = guilds
      self._isExpanded = .init(
        initialValue: UserDefaults.standard.bool(
          forKey: "GuildFolders.\(id).isExpanded"
        )
      )
    }

    var body: some View {
      VStack {
        Button {
          withAnimation {
            isExpanded.toggle()
          }
        } label: {
          if isExpanded {
            Rectangle()
              .fill(.clear)
              .aspectRatio(1, contentMode: .fit)
              .overlay {
                if folder.hasColor,
                   let color = DiscordColor(value: Int(folder.color.value))?.asColor()
                {
                  Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundStyle(color)
                } else {
                  Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
                }
              }
              .transition(.blurReplace)
          } else {
            // 2 x 2 grid of first 4 guilds. If less than 4, just show what we have with empty spaces. no animated icons here.
            Rectangle()
              .fill(.clear)
              .aspectRatio(1, contentMode: .fit)
              .overlay {
                VStack(spacing: 2) {
                  HStack(spacing: 2) {
                    if let guild = guilds[safe: 0] {
                      icon(for: guild)
                    } else {
                      Color.clear
                    }
                    if let guild = guilds[safe: 1] {
                      icon(for: guild)
                    } else {
                      Color.clear
                    }
                  }
                  HStack(spacing: 2) {
                    if let guild = guilds[safe: 2] {
                      icon(for: guild)
                    } else {
                      Color.clear
                    }
                    if let guild = guilds[safe: 3] {
                      icon(for: guild)
                    } else {
                      Color.clear
                    }
                  }
                }
                .padding(2)
              }
              .transition(.blurReplace)
          }
        }
        .buttonStyle(.borderless)
        .clipShape(
          .rect(cornerRadius: 10, style: .continuous)
        )

        if isExpanded {
          let guilds: [Guild] = folder.guildIds.compactMap { guildID in
            let guildID = GuildSnowflake(guildID.description)
            return gw.user.guilds[guildID]
          }
          ForEach(guilds) { guild in
            GuildButton(guild: guild)  // imagine recursion lol (i joke)
              .padding(.horizontal, 2)
              .padding(
                .top,
                guild.id == guilds.first?.id ? 2 : 0
              )
              .padding(
                .bottom,
                guild.id == (guilds.last?.id ?? (try! .makeFake())) ? 2 : 0
              )
          }
          .transition(.move(edge: .top).combined(with: .opacity))
        }
      }
      .background {
        if folder.hasColor,
           let color = DiscordColor(value: Int(folder.color.value))?.asColor()
        {
          Rectangle()
            .fill(color.secondary.opacity(0.35))
        } else {
          Rectangle()
            .fill(.tableBackground.secondary)
        }
      }
      .clipShape(.rect(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    func icon(for guild: Guild) -> some View {
      if let icon = guild.icon,
        let url = iconURL(
          id: guild.id,
          icon: icon,
          animated: false
        )
      {
        WebImage(url: url)
          .resizable()
          .scaledToFill()
          .clipShape(.circle)
      } else {
        Rectangle()
          .fill(.gray.opacity(0.3))
          .aspectRatio(1, contentMode: .fit)
          .overlay {
            //            // get initials from guild name
            let initials: String = guild.name
              .split(separator: " ")
              .compactMap(\.first)
              .reduce("") { $0 + String($1) }

            Text(initials)
              .minimumScaleFactor(0.1)
              .foregroundStyle(
                colorScheme == .dark
                  ? .white
                  : .black
              )
          }
          .clipShape(.rounded)
      }
    }

    func iconURL(id: GuildSnowflake, icon: String, animated: Bool) -> URL? {
      if icon.starts(with: "a_") {
        return URL(
          string: CDNEndpoint.guildIcon(guildId: id, icon: icon).url
            + ".\(animated ? "gif" : "png")?size=128&animated=\(animated.description)"
        )
      } else {
        return URL(
          string: CDNEndpoint.guildIcon(guildId: id, icon: icon).url
            + ".png?size=128&animated=false"
        )
      }
    }
  }

  /// A button representing a guild or DMs
  func guildButton(from guild: Guild?) -> some View {
    Button {
      appState.selectedGuild = guild?.id
    } label: {
      let isSelected = appState.selectedGuild == guild?.id
      Group {
        if let id = guild?.id {
          Group {
            let shouldAnimate = appState.selectedGuild == id
            if let icon = guild?.icon,
              let url = iconURL(id: id, icon: icon, animated: shouldAnimate)
            {
              AnimatedImage(
                url: url,
                isAnimating: .constant(shouldAnimate)
              )
              .resizable()
              .scaledToFill()
            } else {
              // server name initials TODO
              Rectangle()
                .fill(.clear)
                .aspectRatio(1, contentMode: .fit)
                .background(isSelected ? .accent : .gray.opacity(0.3))
                .overlay {
                  // get initials from guild name
                  let initials = (guild?.name ?? "")
                    .split(separator: " ")
                    .compactMap(\.first)
                    .reduce("") { $0 + String($1) }

                  Text(initials)
                    .font(.title2)
                    .minimumScaleFactor(0.1)
                    .foregroundStyle(
                      colorScheme == .dark
                        ? Color.white
                        : (isSelected
                           ? Color.white
                          : Color.black)
                    )
                }
            }
          }
        } else {
          Rectangle()
            .fill(.clear)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
              Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.title2)
                .foregroundStyle(
                  colorScheme == .dark ? .white : isSelected ? .white : .black
                )
            }
            .background(isSelected ? .accent : .gray.opacity(0.3))
        }
      }
      .clipShape(.rect(cornerRadius: isSelected ? 10 : 32, style: .continuous))
      .animation(.default, value: isSelected)
    }
    .buttonStyle(.borderless)
    .contextMenu {
      if let id = guild?.id {
        Button("Copy ID") {
          #if os(macOS)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(id.rawValue, forType: .string)
          #elseif os(iOS)
            UIPasteboard.general.string = id.rawValue
          #endif
        }
      }
    }
  }

  func iconURL(id: GuildSnowflake, icon: String, animated: Bool) -> URL? {
    if icon.starts(with: "a_") {
      return URL(
        string: CDNEndpoint.guildIcon(guildId: id, icon: icon).url
          + ".\(animated ? "gif" : "png")?size=128&animated=\(animated.description)"
      )
    } else {
      return URL(
        string: CDNEndpoint.guildIcon(guildId: id, icon: icon).url
          + ".png?size=128&animated=false"
      )
    }
  }
}

#Preview {
  ScrollView {
    GuildButton(guild: nil)
  }
}
