//
//  GuildStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Collections
import Foundation
import PaicordLib
import SwiftPrettyPrint

@Observable
class GuildStore: DiscordDataStore {
  // MARK: - Protocol Properties
  var gateway: GatewayStore?
  var eventTask: Task<Void, Never>?

  // MARK: - Guild Properties
  let guildId: GuildSnowflake
  var guild: Guild?
  var channels: [ChannelSnowflake: DiscordChannel] = [:]
  var members: [UserSnowflake: Guild.PartialMember] = [:]
  var roles: OrderedDictionary<RoleSnowflake, Role> = [:]
  var presences: [UserSnowflake: Gateway.PresenceUpdate] = [:]
  var voiceStates: [UserSnowflake: VoiceState] = [:]

  // MARK: - Initializers, setup etc.

  init(id: GuildSnowflake, from guild: Guild?) {
    self.guildId = id
    self.guild = guild

    // populate properties based on initial guild data
    guard let guild else { return }
    populate(with: guild)
  }

  func populate(with guild: Guild) {
    // channels
    guild.channels?.forEach { channel in
      channels[channel.id] = channel
    }

    // roles
    // https://docs.discord.food/topics/permissions#permission-hierarchy
    let guildRoles = guild.roles.sorted {
      if $0.position == $1.position {
        return $0.id.rawValue < $1.id.rawValue
      } else {
        return $0.position > $1.position
      }
    }
    for role in guildRoles {
      roles[role.id] = role
    }

    // members (usually the connected user only)
    guild.members?.forEach { member in
      if let user = member.user {
        members[user.id] = member.toPartialMember()
      }
    }
  }

  // MARK: - Protocol Methods

  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }

    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        case .guildUpdate(let updatedGuild):
          if updatedGuild.id == guildId {
            handleGuildUpdate(updatedGuild)
          }

        case .guildDelete(let unavailableGuild):
          if unavailableGuild.id == guildId {
            handleGuildDelete(unavailableGuild)
          }

        case .channelCreate(let channel):
          if channel.guild_id == guildId {
            handleChannelCreate(channel)
          }

        case .channelUpdate(let channel):
          if channel.guild_id == guildId {
            handleChannelUpdate(channel)
          }

        case .channelDelete(let channel):
          if channel.guild_id == guildId {
            handleChannelDelete(channel)
          }
        //        case .threadSyncList(let threads):

        case .guildMemberAdd(let memberAdd):
          if memberAdd.guild_id == guildId {
            handleGuildMemberAdd(memberAdd)
          }

        case .guildMemberUpdate(let memberUpdate):
          if memberUpdate.guild_id == guildId {
            handleGuildMemberUpdate(memberUpdate)
          }

        case .guildMemberRemove(let memberRemove):
          if memberRemove.guild_id == guildId {
            handleGuildMemberRemove(memberRemove)
          }

        case .guildMembersChunk(let membersChunk):
          if membersChunk.guild_id == guildId {
            handleGuildMembersChunk(membersChunk)
          }

        case .guildRoleCreate(let roleCreate):
          if roleCreate.guild_id == guildId {
            handleGuildRoleCreate(roleCreate)
          }

        case .guildRoleUpdate(let roleUpdate):
          if roleUpdate.guild_id == guildId {
            handleGuildRoleUpdate(roleUpdate)
          }

        case .guildRoleDelete(let roleDelete):
          if roleDelete.guild_id == guildId {
            handleGuildRoleDelete(roleDelete)
          }

        case .presenceUpdate(let presence):
          if presence.guild_id == guildId {
            handlePresenceUpdate(presence)
          }

        case .voiceStateUpdate(let voiceState):
          if voiceState.guild_id == guildId {
            handleVoiceStateUpdate(voiceState)
          }

        default:
          break
        }
      }
    }
  }

  // MARK: - Event Handlers
  private func handleGuildUpdate(_ updatedGuild: Guild) {
    guild = updatedGuild

    // Update cached roles
    let guildRoles = updatedGuild.roles
    roles.removeAll()
    for role in guildRoles {
      roles[role.id] = role
    }
  }

  private func handleGuildDelete(_ unavailableGuild: UnavailableGuild) {
    // Guild was deleted or became unavailable, clear all data
    guild = nil
    channels.removeAll()
    members.removeAll()
    roles.removeAll()
    presences.removeAll()
    voiceStates.removeAll()
  }

  private func handleChannelCreate(_ channel: DiscordChannel) {
    channels[channel.id] = channel
  }

  private func handleChannelUpdate(_ channel: DiscordChannel) {
    channels[channel.id] = channel
  }

  private func handleChannelDelete(_ channel: DiscordChannel) {
    channels.removeValue(forKey: channel.id)
  }

  private func handleGuildMemberAdd(_ memberAdd: Gateway.GuildMemberAdd) {
    members[memberAdd.user.id] = memberAdd.toMember().toPartialMember()
  }

  private func handleGuildMemberUpdate(_ memberUpdate: Gateway.GuildMemberAdd) {
    members[memberUpdate.user.id] = memberUpdate.toMember().toPartialMember()
  }

  private func handleGuildMemberRemove(
    _ memberRemove: Gateway.GuildMemberRemove
  ) {
    members.removeValue(forKey: memberRemove.user.id)
  }

  private func handleGuildMembersChunk(
    _ membersChunk: Gateway.GuildMembersChunk
  ) {
    print(
      "[GuildStore] Received members chunk with \(membersChunk.members.count) members for guild \(membersChunk.guild_id.rawValue)"
    )
    guard membersChunk.guild_id == guildId else { return }
    for member in membersChunk.members {
      if let user = member.user {
        members[user.id] = member.toPartialMember()
      }
    }
  }

  private func handleGuildRoleCreate(_ roleCreate: Gateway.GuildRole) {
    // insert role based on position
    let newRole = roleCreate.role
    var inserted = false
    for (index, existingRole) in roles.values.enumerated() {
      if newRole.position > existingRole.position
        || (newRole.position == existingRole.position
          && newRole.id.rawValue < existingRole.id.rawValue)
      {
        roles.updateValue(newRole, forKey: newRole.id, insertingAt: index)
      }
      inserted = true
      break
    }
    // if not inserted, it means it's the lowest role but unlikely since @everyone exists. whatever.
    if !inserted {
      roles[newRole.id] = newRole
    }
  }

  private func handleGuildRoleUpdate(_ roleUpdate: Gateway.GuildRole) {
    // compare positions and remove and re-insert if position changed
    if let existingRole = roles[roleUpdate.role.id],
      existingRole.position != roleUpdate.role.position
    {
      roles.removeValue(forKey: roleUpdate.role.id)
      // re-insert based on new position
      let newRole = roleUpdate.role
      var inserted = false
      for (index, existingRole) in roles.values.enumerated() {
        if newRole.position > existingRole.position
          || (newRole.position == existingRole.position
            && newRole.id.rawValue < existingRole.id.rawValue)
        {
          roles.updateValue(
            newRole,
            forKey: newRole.id,
            insertingAt: index
          )
          inserted = true
          break
        }
      }
      // if not inserted, it means it's the lowest role but unlikely since @everyone exists. whatever.
      if !inserted {
        roles[newRole.id] = newRole
      }
    } else {
      // position didn't change, just update
      roles[roleUpdate.role.id] = roleUpdate.role
    }
  }

  private func handleGuildRoleDelete(_ roleDelete: Gateway.GuildRoleDelete) {
    roles.removeValue(forKey: roleDelete.role_id)
  }

  private func handlePresenceUpdate(_ presence: Gateway.PresenceUpdate) {
    presences[presence.user.id] = presence
  }

  private func handleVoiceStateUpdate(_ voiceState: VoiceState) {
    if voiceState.channel_id != nil {
      voiceStates[voiceState.user_id] = voiceState
    } else {
      // User left voice channel
      voiceStates.removeValue(forKey: voiceState.user_id)
    }
  }

  // MARK: - Helpers

  // Track requested member IDs to avoid duplicate requests
  var requestedMemberIds: Set<UserSnowflake> = []

  func requestMembers(for ids: Set<UserSnowflake>) async {
    // Check IDs to request, excluding prior requested ppl
    let idsToRequest = ids.subtracting(requestedMemberIds)
    guard !idsToRequest.isEmpty else { return }

    // Add to requested IDs and send gateway request
    requestedMemberIds.formUnion(idsToRequest)
    await gateway?.gateway?.requestGuildMembersChunk(
      payload: .init(
        guild_id: guildId,
        presences: false,
        user_ids: Array(ids)
      )
    )
  }

  /// Stores references to existing member lists.
  var memberLists: [MemberListSnowflake: ChannelStore.MemberListAccumulator] =
    [:]
  // Max of 5 subscribed member lists at a time per guild.
  // Ordered so that we can evict the oldest one when subscribing to a new one after reaching the limit.
  var subscribedMemberListIDs:
    OrderedDictionary<
      MemberListSnowflake, (channelID: ChannelSnowflake, ranges: [IntPair])
    > = [:]

  /// Sends discord what member lists we're tracking and where in the list we want updates for.
  /// Call this after updating `subscribedMemberListIDs` to sync with the gateway.
  func updateSubscriptions() async {
    guard let gateway = gateway?.gateway, let guild else { return }
    // for subscriptions, we just have to push one dictionary with our
    // current subscriptions. no need to unsubscribe from prior channels since
    // its implied if it isnt in the new list.

    // evict oldest subscription if at limit
    if subscribedMemberListIDs.count >= 5 {
      // suffix to top 5, new subscriptions will be added to the end, so the oldest one is at the start
      subscribedMemberListIDs = subscribedMemberListIDs.suffix(5).reduce(
        into: [:]) { partialResult, element in
          partialResult[element.key] = element.value
        }
    }

    print("[MemberListSubscriptions] Member list ids", subscribedMemberListIDs)

    // channels can share member lists. this often happens for public channels which everyone can access.
    // channels with permission overwrites for specific roles or members will have unique member lists though.
    // channels with matching permission overwrites will also share member lists.
    // if we subscribe to two channels with the same member list, this will cause issues.
    // this is why we dedupe via memberlistsnowflake then find channel snowflakes for each member list snowflake.
    // also the gateway doesnt take member list ids, we send channel snowflakes
    let subscriptions: [ChannelSnowflake: [IntPair]] =
      subscribedMemberListIDs.reduce(into: [:]) { partialResult, element in
        let channelSnowflake = element.value.channelID
        partialResult[channelSnowflake] = element.value.ranges
      }

    print("[MemberListSubscriptions] Subscriptions", subscriptions)

    await gateway.updateGuildSubscriptions(
      payload: .init(
        subscriptions: [
          guild.id: .init(channels: subscriptions)
        ]
      )
    )
  }
}
