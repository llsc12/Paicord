//
//  VoiceView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/03/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Algorithms
import Collections
import ColorCube
import PaicordLib
import SDWebImage
import SwiftUIX

struct VoiceView: View {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  var vm: ChannelStore
  var vgw: VoiceConnectionStore? { gw.voice }

  @Namespace private var voiceGridAnimations
  @ViewStorage var frame: CGRect = .zero
  @ViewStorage var monitor: Any?
  @ViewStorage var isHovering: Bool = false
  @ViewStorage var timer: Timer? = nil
  @State var showingVoiceUI = false

  var body: some View {
    Group {
      VStack(spacing: 15) {
        let voiceChannels = gw.voiceChannels
        let guildID = vm.guildStore?.guildId
        let voiceStates =
          voiceChannels.voiceStates[guildID]?[vm.channelId] ?? [:]
        if !voiceStates.isEmpty {
          CurrentPeopleGrid(
            members: voiceStates,
            showingVoiceUI: $showingVoiceUI,
            namespace: voiceGridAnimations
          )
          .padding(.vertical, 30)
          .animation(.spring, value: voiceStates)
        }
        if vgw?.channelId != vm.channelId {
          Text(vm.channel?.name ?? "Unknown Channel")
            .font(.largeTitle)

          if voiceStates.isEmpty {
            Text("No one is currently in voice")
              .foregroundStyle(.white.secondary)
          } else {
            let firstTwo = voiceStates.prefix(2).compactMap {
              let member = $0.value.member ?? vm.guildStore?.members[$0.key]
              let user = member?.user?.toPartialUser() ?? gw.user.users[$0.key]
              return member?.nick ?? user?.global_name ?? user?.username
                ?? "Unknown User"
            }
            let remainderCount = voiceStates.count - firstTwo.count
            Text(
              "\(firstTwo.joined(separator: voiceStates.count == 2 ? " and " : ", "))\(remainderCount > 0 ? " and \(remainderCount) other\(remainderCount == 1 ? "" : "s")" : "") \(voiceStates.count == 1 ? "is" : "are") currently in voice"
            )
          }

          Button {
            Task {
              do {
                let channelID = vm.channelId
                guard let guildID = vm.guildStore?.guildId else { return }
                await gw.voice.updateVoiceConnection(
                  .join(
                    channelId: channelID,
                    guildId: guildID,
                  )
                )
              } catch {
                print("Failed to leave voice channel with error: \(error)")
              }
            }

          } label: {
            Text("Join Voice")
          }
          .disabled(!(vm.guildStore?.hasPermission(channel: vm, .connect) ?? true))
        }
      }
      .foregroundStyle(.white.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
    .overlay(alignment: .topLeading) {
      if vgw?.channelId == vm.channelId && showingVoiceUI {
        HStack {
          Image(systemName: "speaker.wave.2.fill")
            .imageScale(.large)
          Text(vm.channel?.name ?? "unknown")
            .font(.headline)
        }
        .foregroundStyle(.white)
        .padding(8)
        .transition(.offset(x: -20).combined(with: .opacity))
      }
    }
    .animation(.spring, value: showingVoiceUI)
    .onGeometryChange(
      for: CGRect.self,
      of: { $0.frame(in: .local) },
      action: { frame = $0 }
    )
    .onAppear {
      // monitor mouse movement
      monitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) {
        event in
        if isHovering {
          if !showingVoiceUI {
            showingVoiceUI = true
          }
          timer?.invalidate()
          timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) {
            _ in
            self.showingVoiceUI = false
          }
        } else {
          if showingVoiceUI {
            showingVoiceUI = false
          }
        }
        return event
      }

      timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
        self.showingVoiceUI = false
      }
    }
    .onHover { isHovering = $0 }
    .onDisappear {
      if let monitor {
        NSEvent.removeMonitor(monitor)
      }
    }
  }

  // shown before joining. smaller grid.
  struct CurrentPeopleGrid: View {
    @Environment(\.gateway) var gw
    @Environment(\.channelStore) var channelStore
    var vgw: VoiceConnectionStore? { gw.voice }
    var members: OrderedDictionary<UserSnowflake, VoiceState>
    @State var contentSize: CGSize = .zero
    @Binding var showingVoiceUI: Bool
    var namespace: Namespace.ID

    var itemSize: CGFloat? {
      vgw?.channelId != channelStore?.channelId ? 150 : nil
    }

    var body: some View {
      let chunks:
        ChunksOfCountCollection<
          OrderedDictionary<UserSnowflake, VoiceState>.Values
        > = {
          // chunk by powers of 2 to make a nicely expanding grid
          let count = members.count
          let chunkSize: Int = {
            var size = 1
            while Int(pow(2.0, Double(size))) < count {
              size += 1
            }
            return size + (itemSize != nil ? 1 : 0)
          }()
          return members.values.chunks(ofCount: chunkSize)
        }()
      VStack(alignment: .center, spacing: 0) {
        ForEach(Array(chunks.enumerated()), id: \.offset) { _, chunk in
          HStack(alignment: .center, spacing: 0) {
            ForEach(Array(chunk), id: \.self) { voiceState in
              GridCell(showingVoiceUI: $showingVoiceUI, state: voiceState)
                .maxWidth(itemSize ?? .infinity)
                .matchedGeometryEffect(
                  id: voiceState.user_id,
                  in: namespace,
                  properties: .frame
                )
            }
          }
        }
      }
      .minWidth(itemSize)
      .maxWidth(itemSize == nil ? nil : min(contentSize.width, itemSize! * 4))
      .padding()
      .onGeometryChange(
        for: CGSize.self,
        of: { $0.size },
        action: {
          contentSize = $0
        }
      )
      .animation(.spring, value: itemSize)
    }

    struct GridCell: View {
      @Environment(\.gateway) var gw
      @Environment(\.channelStore) var channelStore
      @Environment(\.guildStore) var guildStore
      @Binding var showingVoiceUI: Bool
      var vgw: VoiceConnectionStore? { gw.voice }
      var state: VoiceState

      var isDeafened: Bool {
        state.self_deaf || state.deaf
      }

      var isServerDeafened: Bool {
        state.deaf
      }

      var isMuted: Bool {
        state.self_mute || state.mute
      }

      var isServerMuted: Bool {
        state.mute
      }

      var isSpeaking: Bool {
        if let state = vgw?.usersSpeakingState[state.user_id] {
          return state.isEmpty == false
        }
        return false
      }

      var member: Guild.PartialMember? {
        state.member ?? guildStore?.members[state.user_id]
      }

      var user: PartialUser? {
        state.member?.user?.toPartialUser() ?? gw.user.users[state.user_id]
      }

      @State var accentColor = Color.white

      var body: some View {
        VStack {
          Profile.Avatar(
            member: member,
            user: user
          )
          .width(50)
          .height(50)
          .padding()
          .maxWidth(.infinity)
          .maxHeight(.infinity)
        }
        .aspectRatio(1.8, contentMode: .fit)
        .background(accentColor)
        .overlay(alignment: .bottomLeading) {
          if (isMuted || isDeafened || showingVoiceUI)
            && vgw?.channelId == channelStore?.channelId
          {
            HStack {
              if isDeafened {
                Image(systemName: "headphones.slash")
                  .foregroundStyle(isServerDeafened ? .red : .white)
              } else if isMuted {
                Image(systemName: "mic.slash")
                  .foregroundStyle(isServerMuted ? .red : .white)
              }
              if showingVoiceUI {
                Text(
                  member?.nick ?? user?.global_name ?? user?.username
                    ?? "Unknown User"
                )
                .foregroundStyle(.white)
                .lineLimit(1)
              }
            }
            .padding(6)
            .background(.black.opacity(0.5))
            .clipShape(.rounded)
            .padding(6)
          }
        }
        .clipShape(.rounded)
        .overlay {
          if isSpeaking {
            ZStack {
              RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.black, lineWidth: 4)
              RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.green, lineWidth: 2)
            }
          }
        }
        .padding(2)
        .transaction(value: isSpeaking) { t in
          t.disableAnimations()
        }
        .task(id: user, grabColor)
        .task(id: member, grabColor)
      }

      @Sendable
      func grabColor() async {
        let cc = CCColorCube()
        // use sdwebimage's image manager, get the avatar image and extract colors using colorcube
        let m: Guild.PartialMember? = member
        guard
          let avatarURL = Utils.fetchUserAvatarURL(
            member: m,
            guildId: guildStore?.guildId,
            user: user,
            animated: false
          )
        else {
          return
        }
        let imageManager: SDWebImageManager = .shared
        imageManager.loadImage(
          with: avatarURL,
          progress: nil
        ) { image, _, error, _, _, _ in
          guard let image else {
            return
          }
          let colors = cc.extractColors(
            from: image,
            flags: [.orderByBrightness, .avoidBlack, .avoidWhite]
          )
          if let firstColor = colors?.first {
            DispatchQueue.main.async {
              self.accentColor = Color(firstColor)
            }
          } else {
          }
        }
      }
    }
  }
}
