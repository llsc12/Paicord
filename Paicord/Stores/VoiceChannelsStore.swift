//
//  VoiceChannelsStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 12/03/2026.
//

import Collections
import Foundation
import PaicordLib

@Observable
final class VoiceChannelsStore: DiscordDataStore {

  var eventTask: Task<Void, Never>?
  var gateway: GatewayStore?

  var startTimes: [ChannelSnowflake: Date] = [:]

  var voiceStates:
    [GuildSnowflake?: OrderedDictionary<
      ChannelSnowflake,
      OrderedDictionary<UserSnowflake, VoiceState>
    >] = [:]

  // secondary index
  var userChannelIndex: [GuildSnowflake?: [UserSnowflake: ChannelSnowflake]] =
    [:]

  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }

    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        case .ready(let payload):
          handleReady(payload)
        case .voiceChannelStartTimeUpdate(let payload):
          handleVoiceChannelStartTimeUpdate(payload)
        case .voiceStateUpdate(let payload):
          handleVoiceStateUpdate(payload)
        default:
          break
        }
      }
    }
  }

  func handleReady(_ payload: Gateway.Ready) {
    for guild in payload.guilds {
      for state in guild.voice_states ?? [] {
        guard let channelID = state.channel_id else { continue }
        let guildID = guild.id
        let userID = state.user_id

        voiceStates[guildID, default: [:]][channelID, default: [:]][userID] =
          state
        userChannelIndex[guildID, default: [:]][userID] = channelID
      }
    }
  }

  func handleVoiceChannelStartTimeUpdate(
    _ payload: Gateway.VoiceChannelStartTimeUpdate
  ) {
    if let startTime = payload.voice_start_time?.date {
      startTimes[payload.id] = startTime
    } else {
      startTimes.removeValue(forKey: payload.id)
    }
  }

  func handleVoiceStateUpdate(_ payload: VoiceState) {
    let guildID = payload.guild_id
    let userID = payload.user_id
    let newChannel = payload.channel_id

    if let member = payload.member, let user = member.user?.toPartialUser() {
      // update member store if we have the member cached
      gateway?.user.users[
        payload.user_id,
        default: user
      ].update(with: user)
    }
    if let guildId = payload.guild_id, let member = payload.member,
      let guildStore = gateway?._guilds[guildId]
    {
      guildStore.members[payload.user_id, default: member].update(with: member)
    }

    let oldChannel = userChannelIndex[guildID]?[userID]

    // remove prev user state
    if let oldChannel {
      voiceStates[guildID]?[oldChannel]?.removeValue(forKey: userID)

      if voiceStates[guildID]?[oldChannel]?.isEmpty == true {
        voiceStates[guildID]?.removeValue(forKey: oldChannel)
      }
    }

    // add new user state
    if let newChannel {
      voiceStates[guildID, default: [:]][newChannel, default: [:]][userID] =
        payload
      userChannelIndex[guildID, default: [:]][userID] = newChannel
    } else {
      // handle disconnect
      userChannelIndex[guildID]?.removeValue(forKey: userID)

      if userChannelIndex[guildID]?.isEmpty == true {
        userChannelIndex.removeValue(forKey: guildID)
      }
    }
  }
}
