//
//  MFAView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUI

struct MFAView: View {
  let authentication: UserAuthentication
  let fingerprint: String
  let loginClient: any DiscordClient
  let onFinish: (Secret?) -> Void

  let options: [Payloads.MFASubmitData.MFAKind]

  @Environment(\.appState) var appState

  @State var mfaTask: Task<Void, Never>? = nil
  @State var taskInProgress: Bool = false

  @Binding var chosenMethod: Payloads.MFASubmitData.MFAKind?
  @State var input: String = ""

  init(
    authentication: UserAuthentication,
    fingerprint: String,
    loginClient: any DiscordClient,
    chosenMethod: Binding<Payloads.MFASubmitData.MFAKind?>,
    onFinish: @escaping (Secret?) -> Void
  ) {
    self.authentication = authentication
    self.fingerprint = fingerprint
    self.loginClient = loginClient
    self._chosenMethod = chosenMethod
    self.onFinish = onFinish
    self.options = MFAView.Options(from: authentication)
  }

  var body: some View {
    ZStack {
      VStack {
        Text("Multi-Factor Authentication")
          .font(.title2).bold()
        Text("Login requires MFA to continue.")

        VStack {
          if chosenMethod == nil {
            ForEach(options, id: \.self) { method in
              Button {
                chosenMethod = method
              } label: {
                userFriendlyName(for: method)
                  .frame(maxWidth: .infinity)
                  .padding(10)
                  .background(Color.theme.common.primaryButton)
                  .clipShape(.rounded)
                  .font(.title3)
              }
              .buttonStyle(.borderless)
            }
            .transition(.offset(x: -100).combined(with: .opacity))
          }
          if chosenMethod != nil {
            form
              .transition(.offset(x: 100).combined(with: .opacity))
          }
        }
        .padding(25)
      }
    }
    .padding(.top, 15)
    .minHeight(200)
    .maxWidth(.infinity)
    .overlay(alignment: .topLeading) {
      Button {
        if chosenMethod == nil {
          onFinish(nil)
        } else {
          chosenMethod = nil
          input = ""
        }
      } label: {
        Image(systemName: chosenMethod != nil ? "chevron.left" : "xmark")
          .padding(5)
          .background(Color.theme.common.primaryButtonBackground)
          .clipShape(.circle)
          .contentTransition(.symbolEffect(.replace))
      }
      .buttonStyle(.borderless)
    }
    .animation(.default, value: chosenMethod == nil)
  }

  func userFriendlyName(for type: Payloads.MFASubmitData.MFAKind) -> some View {
    switch type {
    case .sms: Label("SMS", systemImage: "message")
    case .totp: Label("Authenticator App", systemImage: "lock.rotation")
    case .backup: Label("Backup Code", systemImage: "key")
    default: Label("Unimplemented", systemImage: "key")
    }
  }

  @ViewBuilder var form: some View {
    VStack {
      switch chosenMethod {
      case .totp:
        VStack {
          Text("Enter your authentication code")
            .foregroundStyle(.secondary)
            .font(.caption)

          SixDigitInput(input: $input) {
            let input = $0
            self.taskInProgress = true
            self.mfaTask = .init {
              defer { self.taskInProgress = false }
              do {
                let req = try await loginClient.verifyMFALogin(
                  type: chosenMethod!,
                  payload: .init(code: input, ticket: authentication.ticket!),
                  fingerprint: fingerprint
                )
                if let error = req.asError() { throw error }
                let data = try req.decode()
                guard let token = data.token else {
                  throw
                    "No authentication token was sent despite MFA being completed."
                }
                onFinish(token)
              } catch {
                self.appState.error = error
              }
            }
          }
          .disabled(taskInProgress)
        }
      default:
        Text("wip bro go do totp")
      }
    }
  }

  static func Options(from auth: UserAuthentication) -> [Payloads.MFASubmitData
    .MFAKind]
  {
    var options: [Payloads.MFASubmitData.MFAKind] = []
    if auth.totp == true { options.append(.totp) }
    if auth.backup == true { options.append(.backup) }
    if auth.sms == true { options.append(.sms) }
    return options
  }
}
