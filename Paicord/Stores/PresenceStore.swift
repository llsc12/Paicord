//
//  PresenceStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 30/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib
import SwiftPrettyPrint
import SwiftUIX

// When it's time to add support for rich presence data from other apps and games, this will need reworking.

@Observable
class PresenceStore: DiscordDataStore {
  var gateway: GatewayStore?

  var eventTask: Task<Void, Never>?

  func setupEventHandling() {
    eventTask = Task { @MainActor in
      guard let gateway = gateway?.gateway else { return }
      for await event in await gateway.events {
        switch event.data {
        case .ready(let readyData):
          handleReady(readyData)
        case .sessionsReplace(let sessions):
          handleSessionsReplace(sessions)
        default: break
        }
      }
    }
  }

  // Stores custom status which is a form of activity
  @ObservationIgnored
  @AppStorage("Paicord.Presence.LastKnownClientStatusActivity")
  @Storage
  var _currentClientStatusActivity: Gateway.Activity? = nil
  @ObservationIgnored
  @AppStorage("Paicord.Presence.LastKnownClientStatus")  // dnd, afk, online, invisible, offline
  @Storage
  var _currentClientStatus: Gateway.Status = .online

  var currentClientStatusActivity: Gateway.Activity? {
    get {
      access(keyPath: \._currentClientStatusActivity)
      return _currentClientStatusActivity
    }
    set {
      withMutation(keyPath: \._currentClientStatusActivity) {
        _currentClientStatusActivity = newValue
      }
    }
  }
  var currentClientStatus: Gateway.Status {
    get {
      access(keyPath: \._currentClientStatus)
      return _currentClientStatus
    }
    set {
      withMutation(keyPath: \._currentClientStatus) {
        _currentClientStatus = newValue
      }
    }
  }

  var sessions: [Gateway.Session] = []

  private func handleReady(_ data: Gateway.Ready) {
    self.sessions = data.sessions

    // theres two routes to go here
    // 1. we have a stored presence, set this if there are no other existing sessions with a presence to copy
    // 2. there's another session already, other than us, with a presence, copy that presence over to us and set it as our presence
    if let session = data.sessions.first(where: { $0.id == "all" })
      ?? data.sessions.first
    {
      self.currentClientStatus = session.status
      if let existingActivity = session.activities.first(where: {
        $0.type == .custom
      }) {
        self.currentClientStatusActivity = existingActivity
      }
    }
    // use stored presence if any to update our presence
    Task {
      var activities: [Gateway.Activity] = []
      if let activity = self.currentClientStatusActivity {
        activities.append(activity)
      }
      await self.setPresence(
        status: self.currentClientStatus,
        activities: activities
      )
    }
  }

  private func handleSessionsReplace(_ sessions: Gateway.SessionsReplace) {
    defer { self.sessions = sessions }
    // a session updated presence probably. every session has the same custom activity data and status except the one that just changed
    // also this event doesnt send "all" session. we'll need to update our presence if another session changed theirs
    // other sessions (not this client) will update their presence, according to this sessionreplace too so we'll receive more of these events.
    // we'll filter `sessions` to get rid of our own session first, then filter by those with custom activity that isnt equal to our current status activity and status
    // all session isnt included here, but filtering it out just bc ykyk

    // ultra sanity check
    Task {
      let oldStatusActivity = self.currentClientStatusActivity
      let oldStatus = self.currentClientStatus

      let currentSessionID = await gateway?.gateway?.getSessionID()

      let otherSessions =
        sessions
        .filter { $0.id != "all" }
        .filter { $0.id != currentSessionID }

      if let session = otherSessions.first {
        self.currentClientStatus = session.status
        if let existingActivity = session.activities.first(where: {
          $0.type == .custom
        }) {
          self.currentClientStatusActivity = existingActivity
        }
        self.currentClientStatus = session.status
      }

      if oldStatus != self.currentClientStatus
        || oldStatusActivity != self.currentClientStatusActivity
      {
        // presence changed, update our presence to match
        var activities: [Gateway.Activity] = []
        if let activity = self.currentClientStatusActivity {
          activities.append(activity)
        }
        await self.setPresence(
          status: self.currentClientStatus,
          activities: activities
        )
      }
    }
  }

  func setPresence(
    status: Gateway.Status? = nil,
    activities: [Gateway.Activity]? = nil,
  ) async {
    guard let gateway = gateway?.gateway else { return }
    if status == nil && activities == nil {
      return
    }
    let status = status ?? currentClientStatus
    let activities = activities ?? self.currentClientStatusActivity.map { [$0] } ?? []
    await gateway.updatePresence(
      payload: .init(
        activities: activities,
        status: status,
        afk: false
      )
    )
  }
}

// allow storing of Gateway.Activity in AppStorage
extension Optional: AppStorageConvertible where Wrapped == Gateway.Activity {
  init?(_ storedValue: String) {
    guard let data = storedValue.data(using: .utf8) else {
      self = nil
      return
    }
    let decoder = JSONDecoder()
    if let decoded = try? decoder.decode(Gateway.Activity.self, from: data) {
      self = .some(decoded)
    } else {
      self = nil
    }
  }

  var storedValue: String {
    guard let self = self else {
      return ""
    }
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(self),
      let jsonString = String(data: data, encoding: .utf8)
    {
      return jsonString
    } else {
      return ""
    }
  }
}

extension Gateway.Status: AppStorageConvertible {
  init?(_ storedValue: String) {
    // store rawvalue
    self = Gateway.Status(rawValue: storedValue) ?? .online
  }
  var storedValue: String {
    self.rawValue
  }
}
