//
//  LoginViewModel.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
final class LoginViewModel {
  init() {

    Task { await fingerprintSetup() }
  }

  // Necessary stuff
  var loginClient: any DiscordClient {
    GatewayStore.shared.unauthenticatedClient
  }
  var fingerprint: String?

  // for when we're adding a new account to the app when we already have accounts
  var addingNewAccount = false

  // Fields
  var login: String = ""
  var password: String = ""
  // Set this if MFA is needed, the mfa view will appear
  var handleMFA: UserAuthentication? = nil

  // Forgot password
  var forgotPasswordPopover = false
  var forgotPasswordSent = false

  var gw: GatewayStore! = nil  // need to set this in an onAppear
  var appState: PaicordAppState! = nil  // need to set this in an onAppear

  @MainActor
  func fingerprintSetup() async {
    self.fingerprint = UserDefaults.standard.string(
      forKey: "Authentication.Fingerprint"
    )
    do {
      if self.fingerprint == nil {
        let request = try await loginClient.getExperiments()
        try request.guardSuccess()
        let data = try request.decode()
        self.fingerprint = data.fingerprint
        UserDefaults.standard.set(
          data.fingerprint,
          forKey: "Authentication.Fingerprint"
        )
      }
    } catch {
      self.appState.error = error
    }
  }

  @MainActor
  func forgotPassword() async {
    do {
      guard let fingerprint else {
        throw "A tracking fingerprint couldn't be generated."
      }
      let res = try await loginClient.forgotPassword(
        fingerprint: fingerprint,
        login: login
      )
      if let error = res.asError() { throw error }
      self.forgotPasswordSent.toggle()
    } catch {
      self.appState.error = error
    }
  }

  @MainActor
  func loginAction() async {
    do {
      guard let fingerprint else {
        throw "A tracking fingerprint couldn't be generated."
      }
      let request = try await loginClient.userLogin(
        login: login,
        password: password,
        fingerprint: fingerprint
      )
      if let error = request.asError() { throw error }
      let data = try request.decode()
      if data.mfa == true {
        self.handleMFA = data
      } else {
        guard let token = data.token else {
          throw
            "No authentication token was sent despite MFA not being required."
        }
        let user = try await TokenStore.getSelf(token: token)
        gw.accounts.addAccount(token: token, user: user)
        //
      }
    } catch {
      self.appState.error = error
    }
  }

  @MainActor
  func finishMFA(token: Secret?) {
    defer { self.handleMFA = nil }
    guard let token else { return }
    Task {
      do {
        let user = try await TokenStore.getSelf(token: token)
        gw.accounts.addAccount(token: token, user: user)
      } catch {
        self.appState.error = error
      }
    }
  }
}
