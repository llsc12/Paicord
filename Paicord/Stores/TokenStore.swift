//
//  AuthenticationStorage.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 01/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import KeychainAccess
import PaicordLib

@Observable
final class TokenStore {
  private static let keychain = Keychain(service: "com.llsc12.Paicord.Accounts")
  private static let currentAccountIDKey = "TokenStore.CurrentAccountID"
  private static let accountDataKey = "AccountData"

  /// If this is nil, there is no logged-in account.
  var currentAccountID: UserSnowflake? {
    get {
      access(keyPath: \.currentAccountID)
      return _currentAccountID
    }
    set {
      withMutation(keyPath: \.currentAccountID) {
        _currentAccountID = newValue
      }
    }
  }

  /// Returns the current account (if one is set)
  var currentAccount: AccountData? {
    get {
      access(keyPath: \.currentAccount)
      guard let id = currentAccountID else { return nil }
      return account(for: id)
    }
    set {
      withMutation(keyPath: \.currentAccount) {
        guard let id = newValue?.user.id else {
          currentAccountID = nil
          return
        }
        currentAccountID = id
        self.updateAccount(for: id, newValue!)
      }
    }
  }

  @ObservationIgnored
  private var _currentAccountID: UserSnowflake? {
    get {
      guard
        let str = UserDefaults.standard.string(forKey: Self.currentAccountIDKey)
      else { return nil }
      return UserSnowflake(str)
    }
    set {
      if let newValue = newValue {
        UserDefaults.standard.set(
          newValue.rawValue,
          forKey: Self.currentAccountIDKey
        )
      } else {
        UserDefaults.standard.removeObject(forKey: Self.currentAccountIDKey)
      }
    }
  }

  var accounts: [AccountData] {
    didSet { Self.save(accounts) }  // only works on set, not mutation i think
  }

  init() {
    accounts = Self.load()
  }

  func addAccount(token: Secret, user: DiscordUser) {
    accounts.append(AccountData(user: user, token: token))
    currentAccountID = user.id
    Self.save(accounts)
  }

  func removeAccount(_ account: AccountData) {
    accounts.removeAll { $0 == account }
    if currentAccountID == account.user.id {
      currentAccountID = nil  // push to login screen to choose an account or log in
    }
    Self.save(accounts)
  }

  func updateProfile(for id: UserSnowflake, _ data: DiscordUser) {
    guard let index = accounts.firstIndex(where: { $0.user.id == id }) else {
      return
    }
    accounts[index].user = data
  }

  func updateAccount(for id: UserSnowflake, _ account: AccountData) {
    guard let index = accounts.firstIndex(where: { $0.user.id == id }) else {
      return
    }
    accounts[index] = account
    Self.save(accounts)
  }

  func account(for id: UserSnowflake) -> AccountData? {
    accounts.first { $0.user.id == id }
  }

  // MARK: - Persistence

  private static func load() -> [AccountData] {
    let data = (try? keychain.getData(accountDataKey)) ?? Data()
    return
      (try? DiscordGlobalConfiguration.decoder.decode(
        [AccountData].self,
        from: data
      )) ?? []
  }

  private static func save(_ data: [AccountData]) {
    guard let encoded = try? DiscordGlobalConfiguration.encoder.encode(data)
    else { return }
    try? keychain.set(encoded, key: accountDataKey)
  }

  struct AccountData: Codable, Equatable, Identifiable, Sendable {
    var id: UserSnowflake { user.id }

    var user: DiscordUser
    var token: Secret

    static func == (lhs: AccountData, rhs: AccountData) -> Bool {
      lhs.user.id == rhs.user.id
    }
  }

  // MARK: - Static Helpers
  static func getSelf(token: Secret) async throws -> DiscordUser {
    let client = await DefaultDiscordClient(authentication: .userToken(token))
    let res = try await client.getOwnUser()
    return try res.decode()
  }
}
