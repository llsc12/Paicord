//
//  CallView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/03/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

// stacked on top of chat view in dms.

import AVFAudio
import Collections
import PaicordLib
import SwiftUIX

struct CallView: View {
  @Environment(\.gateway) var gw
  @Environment(\.channelStore) var channel
  var vcs: VoiceChannelsStore { gw.voiceChannels }
  var currentUser: CurrentUserStore { gw.user }
  @ViewStorage var timer: Timer? = nil
  @State var showingVoiceUI = false

  // the large baseplate will handle stacking this view vertically above the chat.
  // this just needs to handle sizing itself, and switching to the standard VoiceView
  // when video is enabled, activities are happening etc.
  var body: some View {
    if let channelID = channel?.channelId,
      let states = vcs.voiceStates[nil]?[channelID],
      let call = vcs.calls[channelID]
    {
      callInterface(
        states: states.values,
        call: call
      )
      .maxWidth(.infinity)
      .maxHeight(viewHeight)
      .background(.black)
      .overlay(alignment: .bottom) { drawerResizeGrabber }
      .overlay(alignment: .bottom) {
        if showingVoiceUI
          || !states.keys.contains(currentUser.currentUser?.id ?? .init("0"))
        {
          BottomCallBar()
            .padding(.bottom, 10)
        }
      }
      .onContinuousHover(coordinateSpace: .local) { phase in
        switch phase {
        case .active:
          if !showingVoiceUI {
            showingVoiceUI = true
          }
          timer?.invalidate()
          timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) {
            _ in
            self.showingVoiceUI = false
          }
        case .ended: break
        }
      }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  func callInterface(
    states: OrderedDictionary<UserSnowflake, VoiceState>.Values,
    call: Gateway.CallCreate
  ) -> some View {
    VStack(spacing: 0) {
      HStack {
        let ids = states.map(\.user_id) + call.ringing
        ForEach(ids) { id in
          CallParticipantView(
            channelID: call.channel_id,
            userID: id,
            isRinging: call.ringing.contains(id)
          )
        }
      }
    }
  }

  struct BottomCallBar: View {
    @Environment(\.gateway) var gw
    @Environment(\.channelStore) var channel
    var vgw: VoiceConnectionStore { gw.voice }
    var call: Gateway.CallCreate? {
      guard let channelID = channel?.channelId else { return nil }
      let call = gw.voiceChannels.calls[channelID]
      return call
    }
    var states: OrderedDictionary<UserSnowflake, VoiceState>? {
      guard let channelID = channel?.channelId else { return nil }
      let states = gw.voiceChannels.voiceStates[nil]?[channelID]
      return states
    }
    @State var micError = false
    @ViewStorage var didDeafenBeforeMute = false

    var body: some View {
      HStack {
        // 3 states. not in call but is ringing, call active without us but not ringing us, or in a call.
        let userID: UserSnowflake = gw.user.currentUser?.id ?? .init("0")
        if let states, states.keys.contains(userID) {  // ongoing call, user is in it
          microphoneButton
          deafenButton
          hangupButton
        } else if let call, call.ringing.contains(userID) {  // not in call but ongoing call and ringing
          callButton
          hangupButton
        } else if call != nil {  // not in call, but ongoing call and not ringing
          callButton
        }
      }
    }

    @ViewBuilder
    var microphoneButton: some View {
      // shows when in call
      Button {
        Task {
          switch AVAudioApplication.shared.recordPermission {
          case .granted:
            // if deafened whilst unmuting, undeafen
            await vgw.updateVoiceState(
              isMuted: !gw.voice.isMuted,
              isDeafened: vgw.isDeafened && gw.voice.isMuted ? false : nil
            )
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
    }

    @ViewBuilder
    var deafenButton: some View {
      // shows when in call
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
    }

    @ViewBuilder
    var callButton: some View {
      // shows when not in call, ringing or not ringing
      Button {
        Task {
          if let channelId = call?.channel_id {
            await vgw.updateVoiceConnection(
              .join(channelId: channelId, guildId: nil)
            )
          }
        }
      } label: {
        Image(systemName: "phone.fill")
          .font(.title2)
          .maxWidth(35)
          .maxHeight(35)
      }
      .buttonStyle(
        .borderlessHoverEffect(
          pressedColor: .green,
          isSelected: true
        )
      )
    }

    @ViewBuilder
    var hangupButton: some View {
      // shows when not in call and ringing, or when in call.
      Button {
        Task {
          // if in call, leave.
          // if not in call but ringing, hit the stopringing endpoint.
          if states?.keys.contains(gw.user.currentUser?.id ?? .init("0"))
            == true
          {
            await vgw.updateVoiceConnection(.disconnect)
          } else if let channelId = call?.channel_id,
            call?.ringing.contains(gw.user.currentUser?.id ?? .init("0"))
              == true
          {
            try? await gw.client.stopRingingChannelRecipients(
              channelID: channelId,
              payload: .init()
            ).guardSuccess()
          }
        }
      } label: {
        Image(systemName: "phone.down.fill")
          .font(.title2)
          .maxWidth(35)
          .maxHeight(35)
      }
      .buttonStyle(
        .borderlessHoverEffect(
          pressedColor: .red,
          isSelected: true
        )
      )
    }
  }

  struct CallParticipantView: View {
    @Environment(\.gateway) var gw
    var vgw: VoiceConnectionStore { gw.voice }
    var vc: VoiceChannelsStore { gw.voiceChannels }

    var previewUser: DiscordUser? = nil

    var channelID: ChannelSnowflake
    var userID: UserSnowflake
    var isRinging: Bool

    var user: PartialUser? {
      gw.user.users[userID] ?? previewUser?.toPartialUser()
    }

    var state: VoiceState? {
      vc.voiceStates[nil]?[channelID]?[userID]
    }

    var isDeafened: Bool {
      state?.self_deaf == true || state?.deaf == true
    }

    var isServerDeafened: Bool {
      state?.deaf == true
    }

    var isMuted: Bool {
      state?.self_mute == true || state?.mute == true
    }

    var isServerMuted: Bool {
      state?.mute == true
    }

    var isSpeaking: Bool {
      if let state = vgw.usersSpeakingState[userID] {
        return state.isEmpty == false
      }
      return false
    }

    var body: some View {
      Profile.Avatar(
        member: nil,
        user: user
      )
      .frame(width: 80, height: 80)
      .overlay {
        if isRinging {
          Circle()
            .fill(.black.opacity(0.5))
        }
      }
      .background {
        if isRinging {
          Circle()
            .fill(.clear)
            .strokeBorder(.primary, style: .init(lineWidth: 2))
            .phaseAnimator([0, 1, 2, 3]) { view, phase in
              // 0, 1 pulse, 2, 3 do nothing, then repeat.
              // scale up from 0.8 to 1.25 while fading out from 1 to 0.
              view
                .scaleEffect(phase == 0 ? 0.8 : (phase == 1 ? 1.25 : 0.8))
                .opacity(phase == 0 ? 1 : (phase == 1 ? 0 : 0))
            }
        }
      }
      .overlay {
        if isSpeaking {
          ZStack {
            Circle()
              .strokeBorder(.black, lineWidth: 4)
            Circle()
              .strokeBorder(.green, lineWidth: 2)
          }
        }
      }
      .overlay(alignment: .bottomTrailing) {
        if isDeafened || isMuted {
          Group {
            if isDeafened {
              Image(systemName: "headphones.slash")
                .imageScale(.large)
            } else if isMuted {
              Image(systemName: "mic.slash.fill")
                .imageScale(.large)
            }
          }
          .foregroundStyle(.white)
          .padding(4)
          .background(.red, in: .circle)
          .overlay {
            Circle()
              .strokeBorder(.black, lineWidth: 4)
          }
        }
      }
    }
  }

  var panelSize: CGSize = .zero
  @State var viewHeight: CGFloat = 200
  @State var isDragging = false
  @State var isHovering = false

  @ViewBuilder var drawerResizeGrabber: some View {
    ZStack {
      Rectangle()
        .fill(Color.tertiarySystemFill)
        .frame(height: 4)
      Rectangle()
        .fill(Color.primary)
        .frame(width: 100, height: 6)
        .clipShape(.capsule)
        .onHover { hovering in
          let cursor = NSCursor.resizeUpDown
          if hovering {
            cursor.push()
          } else {
            NSCursor.pop()
          }
        }
        .gesture(
          DragGesture()
            .onChanged { value in
              if !isDragging { isDragging = true }
              let newHeight = viewHeight + value.translation.height
              viewHeight = newHeight.clamped(
                to: 200...(max(210, panelSize.height * 0.7))
              )
            }
            .onEnded { _ in
              isDragging = false
            }
        )
        .onChange(of: isDragging) {
          let cursor = NSCursor.resizeUpDown
          if isDragging {
            cursor.push()
          } else {
            NSCursor.pop()
          }
        }
    }
    .frame(height: 6)
    .offset(y: 3)
    .opacity(isHovering || isDragging ? 1 : 0.001)
    .onHover { self.isHovering = $0 }
    .animation(.easeInOut, value: isHovering || isDragging)
  }
}
