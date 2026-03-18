//
//  CallView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/03/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

// stacked on top of chat view in dms.

import PaicordLib
import SwiftUIX
import Collections

struct CallView: View {
  @Environment(\.gateway) var gw
  @Environment(\.channelStore) var channel
  var vcs: VoiceChannelsStore { gw.voiceChannels }
  var currentUser: CurrentUserStore { gw.user }

  var panelSize: CGSize = .zero
  @State var viewHeight: CGFloat = 200
  @State var isDragging = false
  @State var isHovering = false

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
        ForEach(Array(states)) { state in
          CallParticipantView(
            channelID: call.channel_id,
            userID: state.user_id,
            isRinging: false
          )
        }
        
        ForEach(call.ringing) { userID in
          CallParticipantView(
            channelID: call.channel_id,
            userID: userID,
            isRinging: true
          )
        }
      }
    }
    .overlay(alignment: .bottom) {
      drawerResizeGrabber
    }
    .maxHeight(viewHeight)
  }
  
  struct CallParticipantView: View {
    @Environment(\.gateway) var gw
    var vgw: VoiceConnectionStore? { gw.voice }
    var vc: VoiceChannelsStore { gw.voiceChannels }

    var channelID: ChannelSnowflake
    var userID: UserSnowflake
    var isRinging: Bool
    
    
    var user: PartialUser? { gw.user.users[userID] }
    
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
      if let state = vgw?.usersSpeakingState[userID] {
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
    }
  }
  
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
