//
//  PermsHelper.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 30/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib
import Playgrounds

enum PermissionsHelper {
  static func computeBasePermissions(
    member: Guild.PartialMember,
    guild: GuildStore
  ) -> IntBitField<Permission> {
    let isOwner = guild.guild?.owner_id == guild.gateway?.user.currentUser?.id

    if isOwner {
      return .all
    }

    // get @everyone role
    let everyoneRoleID: RoleSnowflake = .init(guild.guild!.id.rawValue)
    guard let everyoneRole = guild.role(everyoneRoleID) else {
      return .none
    }

    var permissions = everyoneRole.permissions

    for roleID in member.roles ?? [] {
      if let role = guild.role(roleID) {
        permissions.formUnion(role.permissions)
      }
    }

    if permissions.contains(.administrator) {
      return .all
    }

    return permissions.toIntBitField()
  }

  static func computeOverwrites(
    basePermissions: IntBitField<Permission>,
    member: Guild.PartialMember,
    guildStore: GuildStore?,
    channel: DiscordChannel
  ) -> IntBitField<Permission> {
    // ADMINISTRATOR overrides any potential permission overwrites, so there is nothing to do here.
    if basePermissions.contains(.administrator) {
      return .all
    }

    var permissions = basePermissions.toStringBitField()

    // Find (@everyone) role overwrite and apply it.
    if let guildID = guildStore?.guildId,
      let overwriteEveryone = channel.rolePermissionOverwrites[
        RoleSnowflake(guildID.rawValue)
      ]
    {
      permissions.subtract(overwriteEveryone.deny)
      permissions.formUnion(overwriteEveryone.allow)
    }

    // Apply role specific overwrites.
    var allow: StringBitField<Permission> = []
    var deny: StringBitField<Permission> = []

    for roleID in member.roles ?? [] {
      if let overwriteRole = channel.rolePermissionOverwrites[roleID] {
        allow.formUnion(overwriteRole.allow)
        deny.formUnion(overwriteRole.deny)
      }
    }

    permissions.subtract(deny)
    permissions.formUnion(allow)

    // Apply member specific overwrite if it exist.
    if let userID = member.user?.id,
      let overwriteMember = channel.memberPermissionOverwrites[userID]
    {
      permissions.subtract(overwriteMember.deny)
      permissions.formUnion(overwriteMember.allow)
    }

    return permissions.toIntBitField()
  }

  static func computePermissions(
    member: Guild.PartialMember,
    guildStore: GuildStore?,
    channel: DiscordChannel
  ) -> IntBitField<Permission> {
    guard let guildStore else {
      return .none
    }

    let basePermissions = computeBasePermissions(
      member: member,
      guild: guildStore
    )

    return computeOverwrites(
      basePermissions: basePermissions,
      member: member,
      guildStore: guildStore,
      channel: channel
    )
  }
}

extension GuildStore {
  func hasPermission(
    channel: ChannelStore?,
    _ permission: Permission
  ) -> Bool {
    guard let id = self.gateway?.user.currentUser?.id else {
      return true
    }
    return self.memberHasPermission(
      memberID: id,
      channel: channel,
      permission
    )
  }

  func memberHasPermission(
    memberID: UserSnowflake,
    channel: ChannelStore?,
    _ permission: Permission
  ) -> Bool {
    self.memberHasPermission(
      memberID: memberID,
      channel: channel?.channel,
      permission
    )
  }

  func hasPermission(
    channel: DiscordChannel?,
    _ permission: Permission
  ) -> Bool {
    // fetch member first ofc
    guard
      let memberID = self.gateway?.user.currentUser?.id,
      let member = self.member(memberID)
    else {
      return true
    }
    // if channel is nil, compute base permissions and compare
    if let channel {
      let permissions = PermissionsHelper.computePermissions(
        member: member,
        guildStore: self,
        channel: channel
      )
      return permissions.contains(permission)
    } else {  // compute base permissions
      let basePermissions = PermissionsHelper.computeBasePermissions(
        member: member,
        guild: self
      )
      return basePermissions.contains(permission)
    }
  }

  func memberHasPermission(
    memberID: UserSnowflake,
    channel: DiscordChannel?,
    _ permission: Permission
  ) -> Bool {
    // fetch member first ofc
    guard let member = self.member(memberID) else {
      return true
    }
    // if channel is nil, compute base permissions and compare
    if let channel {
      let permissions = PermissionsHelper.computePermissions(
        member: member,
        guildStore: self,
        channel: channel
      )
      return permissions.contains(permission)
    } else {  // compute base permissions
      let basePermissions = PermissionsHelper.computeBasePermissions(
        member: member,
        guild: self
      )
      return basePermissions.contains(permission)
    }
  }
}

// Utility extensions

extension IntBitField where R == Permission {
  static let all: IntBitField<Permission> = [
    .createInstantInvite,
    .kickMembers,
    .banMembers,
    .administrator,
    .manageChannels,
    .manageGuild,
    .addReactions,
    .viewAuditLog,
    .prioritySpeaker,
    .stream,
    .viewChannel,
    .sendMessages,
    .sendTtsMessages,
    .manageMessages,
    .embedLinks,
    .attachFiles,
    .readMessageHistory,
    .mentionEveryone,
    .useExternalEmojis,
    .viewGuildInsights,
    .connect,
    .speak,
    .muteMembers,
    .deafenMembers,
    .moveMembers,
    .useVAD,
    .changeNickname,
    .manageNicknames,
    .manageRoles,
    .manageWebhooks,
    .manageGuildExpressions,
    .useApplicationCommands,
    .requestToSpeak,
    .manageEvents,
    .manageThreads,
    .createPublicThreads,
    .createPrivateThreads,
    .useExternalStickers,
    .sendMessagesInThreads,
    .useEmbeddedActivities,
    .moderateMembers,
    .viewCreatorMonetizationAnalytics,
    .useSoundboard,
    .createGuildExpressions,
    .createEvents,
    .useExternalSounds,
    .sendVoiceMessages,
    .setVoiceChannelStatus,
    .sendPolls,
    .useExternalApps,
    .pinMessages,
  ]

  static let none: IntBitField<Permission> = []
}

extension DiscordChannel {
  fileprivate var memberPermissionOverwrites: [UserSnowflake: DiscordChannel.Overwrite] {
    var overwrites: [UserSnowflake: DiscordChannel.Overwrite] = [:]
    for overwrite in self.permission_overwrites ?? [] {
      switch overwrite.type {
      case .member:
        overwrites[UserSnowflake(overwrite.id.rawValue)] = overwrite
      default:
        continue
      }
    }
    return overwrites
  }
  fileprivate var rolePermissionOverwrites: [RoleSnowflake: DiscordChannel.Overwrite] {
    var overwrites: [RoleSnowflake: DiscordChannel.Overwrite] = [:]
    for overwrite in self.permission_overwrites ?? [] {
      switch overwrite.type {
      case .role:
        overwrites[RoleSnowflake(overwrite.id.rawValue)] = overwrite
      default:
        continue
      }
    }
    return overwrites
  }
}
