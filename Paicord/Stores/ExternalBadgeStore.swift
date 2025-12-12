//
//  ExternalBadgeStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 22/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

/// Pulls Paicord badges and Vencord badges.
@Observable
class ExternalBadgeStore {
  var vencordBadges: [UserSnowflake: [DiscordUser.Profile.Badge]] = [:]
  var paicordBadges: [UserSnowflake: [DiscordUser.Profile.Badge]] = [:]

  init() {
    fetch()
  }

  private func fetch() {
    Task.detached {
      let vencordBadgesURL = URL(
        string: "https://badges.vencord.dev/badges.json"
      )!
      let vdata = try? await URLSession.shared.data(from: vencordBadgesURL)
      if let data = vdata?.0, let decoded = try? JSONDecoder().decode(
        [String: [[String: String]]].self,
        from: data
      ) {
        for (userID, badgeDicts) in decoded {
          var userBadges: [DiscordUser.Profile.Badge] = []
          for badgeDict in badgeDicts {
            if let tooltip = badgeDict["tooltip"],
               let icon = badgeDict["badge"]
            {
              
              let badge: DiscordUser.Profile.Badge = .init(
                id: try! .makeFake(),
                description: tooltip,
                icon: icon
              )
              userBadges.append(badge)
            }
          }
          let badges = userBadges // immutable for async capture
          await MainActor.run {
            self.vencordBadges[.init(userID)] = badges
          }
        }
      }
      
      let paicordBadgesURL = URL(
        string: "https://paicord.llsc12.me/api/badges.json"
      )!
      let pdata = try? await URLSession.shared.data(from: paicordBadgesURL)
      if let data = pdata?.0, let decoded = try? JSONDecoder().decode(
        [String: [[String: String]]].self,
        from: data
      ) {
        for (userID, badgeDicts) in decoded {
          var userBadges: [DiscordUser.Profile.Badge] = []
          for badgeDict in badgeDicts {
            if let tooltip = badgeDict["tooltip"],
              let icon = badgeDict["badge"]
            {

              let badge: DiscordUser.Profile.Badge = .init(
                id: try! .makeFake(),
                description: tooltip,
                icon: icon
              )
              userBadges.append(badge)
            }
          }
          let badges = userBadges // immutable for async capture
          await MainActor.run {
            self.vencordBadges[.init(userID)] = badges
          }
        }
      }
    }
  }

  func badges(for userID: UserSnowflake?) -> [DiscordUser.Profile.Badge] {
    guard let userID else { return [] }
    return (paicordBadges[userID] ?? []) + (vencordBadges[userID] ?? [])
  }
}
