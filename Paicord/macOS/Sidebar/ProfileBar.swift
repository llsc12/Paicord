//
//  ProfileBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 24/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import AVKit
import PaicordLib
import SDWebImageSwiftUI
import SwiftPrettyPrint
import SwiftUIX

struct ProfileBar: View {
  var body: some View {
    VStack(spacing: 0) {
      VoiceBarSection()
      Divider()
      ProfileBarSection()
    }
  }

  struct VoiceBarSection: View {
    @Environment(\.gateway) var gw
    var vgw: VoiceConnectionStore { gw.voice }

    var body: some View {
      if gw.voice.voiceGateway != nil {
        VStack(spacing: 2) {
          HStack {
            Group {
              switch vgw.voiceStatus {
              case .stopped:
                Image(systemName: "nosign")
                  .foregroundStyle(.red)
              case .noConnection:
                Image(systemName: "wifi.slash")
                  .foregroundStyle(.red)
              case .connecting:
                if #available(macOS 15.0, *) {
                  Image(systemName: "wifi")
                    .symbolEffect(
                      .bounce.up.byLayer,
                      options: .repeat(.periodic(delay: 0.0))
                    )
                    .foregroundStyle(.yellow)
                } else {
                  Image(systemName: "wifi.exclamationmark")
                    .foregroundStyle(.yellow)
                }
              case .configured:
                Image(systemName: "wifi.exclamationmark")
                  .foregroundStyle(.yellow)
              case .connected:
                Image(systemName: "wifi")
                  .foregroundStyle(.green)
                  .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
              }
            }
            .imageScale(.large)
            .frame(width: 30, height: 30)
            .background(Color.black.opacity(0.2))
            .clipShape(.rect(cornerRadius: 5))

            VStack(alignment: .leading) {
              Group {
                switch vgw.voiceStatus {
                case .stopped, .noConnection:
                  Text("Voice Disconnected")
                    .foregroundStyle(.red)
                case .connecting:
                  Text("Connecting to Voice")
                    .foregroundStyle(.yellow)
                case .configured:
                  Text("Awaiting Audio Setup")
                    .foregroundStyle(.yellow)
                case .connected:
                  Text("Voice Connected")
                    .foregroundStyle(.green)
                }
              }
              .font(.headline)
              .fontWeight(.semibold)

              let channelStore: ChannelStore? = {
                // shouldnt be nil.
                guard let channelID = vgw.channelId else { return nil }
                if let guildID = vgw.guildId {
                  let guildStore = gw.getGuildStore(for: guildID)
                  return gw.getChannelStore(for: channelID, from: guildStore)
                } else {
                  return gw.getChannelStore(for: channelID)
                }
              }()
              if let channel = channelStore?.channel {
                Group {
                  if let guild = channelStore?.guildStore?.guild,
                    let cName = channel.name
                  {
                    Text(verbatim: "\(guild.name) / \(cName)")
                  } else if let name = channel.name
                    ?? channel.recipients?.map({
                      $0.global_name ?? $0.username
                    }).joined(separator: ", ")
                  {
                    Text(verbatim: name)
                  } else {
                    Text("Unknown Channel")
                  }
                }
                .font(.caption)
              }
            }

            Spacer()

            Button {
              Task {
                await vgw.updateVoiceConnection(.disconnect)
              }
            } label: {
              // hang up call
              Image(systemName: "phone.down.fill")
                .font(.title2)
                .maxWidth(35)
                .maxHeight(35)
            }
            .buttonStyle(
              .borderlessHoverEffect(
                hoverColor: .red,
                pressedColor: .red
              )
            )

          }
          .frame(maxWidth: .infinity, alignment: .leading)
          HStack {

          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(4)
        .padding(.horizontal, 6)
      } else {
        EmptyView()
      }
    }
  }

  struct ProfileBarSection: View {
    @Environment(\.gateway) var gw
    #if os(macOS)
      @Environment(\.openWindow) var openWindow
    #endif

    @State var showingUsername = false
    @State var showingPopover = false
    @State var barHovered = false

    @State var micError = false
    
    @ViewStorage var didDeafenBeforeMute = false

    var vgw: VoiceConnectionStore { gw.voice }

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
              .maxHeight(30)
              .profileAnimated(barHovered)
              .profileShowsAvatarDecoration()
            }

            VStack(alignment: .leading) {
              Text(
                gw.user.currentUser?.global_name ?? gw.user.currentUser?
                  .username
                  ?? "Unknown User"
              )
              .bold()
              if showingUsername {
                Text(
                  verbatim:
                    "@\(gw.user.currentUser?.username ?? "Unknown User")"
                )
                .transition(.opacity)
              } else {
                if let session = gw.user.sessions.first(where: {
                  $0.id == "all"
                }
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

        Button {
          Task {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
              // if deafened whilst unmuting, undeafen
              await vgw.updateVoiceState(isMuted: !gw.voice.isMuted, isDeafened: vgw.isDeafened && gw.voice.isMuted ? false : nil)
            case .denied:
              micError = true
            case .undetermined:
              if await AVAudioApplication.requestRecordPermission() {
                await vgw.updateVoiceState(isMuted: false)
              }
            @unknown default:
              fatalError()
            }
          }
        } label: {
          if #available(macOS 15.0, iOS 18.0, *) {
            Image(systemName: vgw.isMuted ? "mic.slash.fill" : "mic.fill")
              .contentTransition(
                .symbolEffect(
                  .replace.magic(fallback: .upUp.byLayer),
                  options: .nonRepeating
                )
              )
              .font(.title2)
              .maxWidth(35)
              .maxHeight(35)
          } else {
            Image(systemName: vgw.isMuted ? "mic.slash.fill" : "mic.fill")
              .contentTransition(
                .symbolEffect(.replace.wholeSymbol, options: .nonRepeating)
              )
              .font(.title2)
              .maxWidth(35)
              .maxHeight(35)
          }
        }
        .buttonStyle(
          .borderlessHoverEffect(
            pressedColor: .red,
            isSelected: vgw.isMuted
          )
        )
        .alert("Microphone Unavailable", isPresented: $micError) {
          Button("OK", role: .cancel) {}
        } message: {
          Text(
            "Please allow microphone access in your system settings to unmute yourself in voice channels."
          )
        }

        Button {
          Task {
            // if going to deafen and not currently muted, deafen and mute. if coming back, undeafen and unmute too.
            var deaf = vgw.isDeafened
            var mute = vgw.isMuted
            if !deaf && !mute {
              didDeafenBeforeMute = true
              mute = true
            } else if vgw.isDeafened && didDeafenBeforeMute {
              mute = false
              didDeafenBeforeMute = false
            }
            deaf.toggle()
            await vgw.updateVoiceState(isMuted: mute, isDeafened: deaf)
          }
        } label: {
          if #available(macOS 15.0, iOS 18.0, *) {
            Image(
              systemName: gw.voice.isDeafened
                ? "headphones.slash" : "headphones"
            )
            .contentTransition(
              .symbolEffect(
                .replace.magic(fallback: .upUp.byLayer),
                options: .nonRepeating
              )
            )
            .font(.title2)
            .maxWidth(35)
            .maxHeight(35)
          } else {
            Image(
              systemName: gw.voice.isDeafened
                ? "headphones.slash" : "headphones"
            )
            .contentTransition(
              .symbolEffect(.replace.wholeSymbol, options: .nonRepeating)
            )
            .font(.title2)
            .maxWidth(35)
            .maxHeight(35)
          }
        }
        .buttonStyle(
          .borderlessHoverEffect(
            pressedColor: .red,
            isSelected: vgw.isDeafened
          )
        )

        #if os(macOS)
          Button {
            openWindow(id: "settings")
          } label: {
            Image(systemName: "gearshape.fill")
              .font(.title2)
              .maxWidth(35)
              .maxHeight(35)
          }

          .buttonStyle(
            .borderlessHoverEffect()
          )
        #elseif os(iOS)
          /// targetting ipad here, ios wouldnt have this at all
          // do something
        #endif
      }
      .padding(8)
      .background {
        if let nameplate = gw.user.currentUser?.collectibles?.nameplate {
          Profile.NameplateView(nameplate: nameplate)
            .nameplateAnimated(barHovered)
            .nameplateImageOpacity(0.4)
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
                gw.user.currentUser?.global_name ?? gw.user.currentUser?
                  .username
                  ?? "Unknown User"
              )
              .bold()
              Text(
                verbatim: "@\(gw.user.currentUser?.username ?? "Unknown User")"
              )
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
                    Text(verbatim: "@\(account.user.username)")
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
}

#Preview("nameplate test") {
  let decoration = DiscordUser.AvatarDecoration(
    asset: "a_741750ac1c9091a58059be33590c2821",
    sku_id: .init("1424960507143524495")
  )

  let llsc12 = DiscordUser(
    id: .init("381538809180848128"),
    username: "llsc12",
    discriminator: "0",
    global_name: nil,
    avatar: "df71b3f223666fd8331c9940c6f7cbd9",
    banner: nil,
    bot: false,
    system: false,
    mfa_enabled: true,
    accent_color: nil,
    locale: .englishUS,
    verified: true,
    email: nil,
    flags: .init(rawValue: 4_194_352),
    premium_type: nil,
    public_flags: .init(rawValue: 4_194_304),
    collectibles: .init(
      nameplate:
        .init(
          asset: "nameplates/nameplates_v3/bonsai/",
          sku_id: SKUSnowflake("1382845914225442886"),
          label: "COLLECTIBLES_NAMEPLATES_VOL_3_BONSAI_A11Y",
          palette: .bubble_gum
        )
    ),
    avatar_decoration_data: decoration
  )
  Group {
    Profile.NameplateView(nameplate: llsc12.collectibles!.nameplate!)
      .nameplateAnimated(true)
      .nameplateImageOpacity(0.4)
      .frame(width: 400, height: 80)
  }
}
