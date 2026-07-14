//
//  MFASheet.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 11/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUI

struct MFASheet: View {
  @Environment(\.theme) var theme
  @Environment(\.appState) var appState
  @Environment(\.gateway) var gw
  let verificationData: MFAVerificationData
  let onToken: (MFAResponse) -> Void

  @State var mfaTask: Task<Void, Never>? = nil
  @State var taskInProgress: Bool = false

  @State var chosenMethod: MFAVerificationData.MFAMethod? = nil
  @State var input = ""
  @FocusState var inputFocused: Bool

  var body: some View {
    ZStack {
      VStack {
        Text("Multi-Factor Authentication")
          .font(.title2)
          .bold()
        Text("An action required MFA to continue.")

        VStack {
          if chosenMethod == nil {
            ForEach(verificationData.methods, id: \.type) { method in
              Button {
                chosenMethod = method
              } label: {
                userFriendlyName(for: method.type)
                  .foregroundStyle(.white)
                  .frame(maxWidth: .infinity)
                  .padding(10)
                  .background(theme.common.primaryButton)
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

      VStack {
        Spacer()
        Text(
          "Further MFA restricted actions will be allowed for the next 5 minutes."
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
    }
    .padding(.top, 15)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(theme.common.primaryBackground)
    .overlay(alignment: .topLeading) {
      if chosenMethod != nil {
        Button {
          chosenMethod = nil
          input = ""
        } label: {
          // chevron left
          Image(systemName: "chevron.left")
            .padding(5)
            .background(theme.common.primaryButtonBackground)
            .clipShape(.circle)
        }
        .buttonStyle(.borderless)
        .padding()
      }
    }
    .animation(.default, value: chosenMethod == nil)
  }

  func userFriendlyName(for type: MFAVerificationData.MFAMethod.MFAKind) -> (
    some View
  )? {
    return switch type {
    case .sms:
      Label("SMS", systemImage: "message")
    case .totp:
      Label("Authenticator App", systemImage: "lock.rotation")
    case .backup:
      Label("Backup Code", systemImage: "key")
    case .password:
      Label("Password", systemImage: "lock")
    default: nil
    }
  }

  @ViewBuilder
  var form: some View {
    if let chosenMethod {
      switch chosenMethod.type {
      case .totp:
        VStack {
          Text("Enter your authentication code")
            .foregroundStyle(.secondary)
            .font(.caption)

          SixDigitInput(input: $input) {
            submit(type: chosenMethod.type, code: $0)
          }
          .disabled(taskInProgress)
        }
      case .backup:
        VStack {
          Text("Enter your backup code")
            .foregroundStyle(.secondary)
            .font(.caption)
          Text("You can only use each backup code once.")
            .foregroundStyle(.tertiary)
            .font(.caption2)

          TextField(text: $input)
            .textFieldStyle(.plain)
            .padding(10)
            .frame(maxWidth: .infinity)
            .focused($inputFocused)
            .background(theme.common.primaryBackground.opacity(0.75))
            .clipShape(.rounded)
            .overlay {
              RoundedRectangle()
                .stroke(
                  inputFocused ? theme.common.primaryButton : Color.clear,
                  lineWidth: 1
                )
                .fill(.clear)
            }
            .disabled(taskInProgress)
            .onChange(of: input) {
              input = String(
                input.replacingOccurrences(of: "-", with: "").prefix(8)
              ).lowercased()
              guard input.count == 8 else { return }
              submit(type: chosenMethod.type, code: input)
            }
        }
      case .sms:
        VStack {
          Text("Enter the code sent to your phone")
            .foregroundStyle(.secondary)
            .font(.caption)

          HStack {
            TextField(text: $input)
              .textFieldStyle(.plain)
              .keyboardType(.numberPad)
              .padding(10)
              .frame(maxWidth: .infinity)
              .focused($inputFocused)

            Divider()
              .maxHeight(10)

            AsyncButton("Send SMS") {
              let req = try await gw.client.verifySendSMS(
                ticket: verificationData.ticket
              )
              if let error = req.asError() { throw error }
              try? await Task.sleep(for: .seconds(30))  // throttle
            } catch: { error in
              self.appState.error = error
            }
            .padding(.trailing, 8)
          }
          .background(theme.common.primaryBackground.opacity(0.75))
          .clipShape(.rounded)
          .overlay {
            RoundedRectangle()
              .stroke(
                inputFocused ? theme.common.primaryButton : Color.clear,
                lineWidth: 1
              )
              .fill(.clear)
          }
          .disabled(taskInProgress)
          .onChange(of: input) {
            input = String(input.filter { $0.isNumber }.prefix(6))
            guard input.count == 6 else { return }
            submit(type: chosenMethod.type, code: input)
          }
        }
      default:
        Text("This MFA method is not currently supported.")
      }
    }
  }

  // MARK: - Submission

  func submit(type: MFAVerificationData.MFAMethod.MFAKind, code: String) {
    guard let submitKind = Payloads.MFASubmitData.MFAKind(rawValue: type.rawValue) else {
      return
    }
    self.taskInProgress = true
    self.mfaTask = .init {
      defer { self.taskInProgress = false }
      do {
        let req = try await gw.client.verifyMFA(
          payload: .init(
            ticket: verificationData.ticket,
            mfa_type: submitKind,
            data: code
          )
        )
        if let error = req.asError() { throw error }
        let response = try req.decode()
        onToken(response)
      } catch {
        self.appState.error = error
      }
    }
  }
}

#Preview {
  MFASheet(
    verificationData: .init(
      ticket: "gm",
      methods: [
        .init(
          type: .totp,
          backup_codes_allowed: false
        ),
        .init(
          type: .sms
        ),
      ]
    )
  ) {
    response in
    print(response)
  }
  .frame(width: 400, height: 300)
  .fontDesign(.rounded)
}

struct SixDigitInput: View {
  @Environment(\.theme) var theme
  // check if view was disabled with environment values
  @Environment(\.isEnabled) var enabled

  @Binding var input: String
  let onCommit: (String) -> Void
  @FocusState var textfield

  var body: some View {
    HStack(spacing: 10) {
      ForEach(0..<6, id: \.self) { index in
        ZStack {
          let prevCharacter = character(at: index - 1)
          let character = character(at: index)
          RoundedRectangle(cornerRadius: 8)
            .stroke(
              (textfield && enabled)
                ? (character.isEmpty && !prevCharacter.isEmpty
                  ? theme.common.hyperlink : .gray) : .gray,
              lineWidth: 1
            )
            .frame(width: 40, height: 50)
          if character.isEmpty && !prevCharacter.isEmpty && enabled {
            BlinkingCursor()
          } else {
            Text(verbatim: character)
              .font(.title)
          }
        }
      }
    }
    .opacity(enabled ? 1 : 0.25)
    .onTapGesture {
      textfield = true
    }
    .onAppear {
      textfield = true
    }
    .background(theme.common.primaryBackground.opacity(0.001))
    .overlay(
      TextField(text: $input)
        .textFieldStyle(.plain)
        .textContentType(.oneTimeCode)
        .opacity(0.008)
        .onChange(of: input) {
          let filtered = input.filter { $0.isNumber }
          if filtered.count > 6 {
            input = String(filtered.prefix(6))
          } else {
            input = filtered
          }
          if input.count == 6 {
            onCommit(input)
          }
        }
        .frame(width: 260, height: 50)
        .focused($textfield)
        .disabled(!enabled)  // redundant but whatevs
    )
  }

  struct BlinkingCursor: View {
    @State var blink = true
    var body: some View {
      Text(verbatim: "|")
        .font(.title)
        .opacity(blink ? 1 : 0)
        .onAppear {
          withAnimation(
            .easeInOut(duration: 0.15).delay(0.3).repeatForever(
              autoreverses: true
            )
          ) {
            blink = false
          }
        }
    }
  }

  func character(at index: Int) -> String {
    // double check that the index isnt sub 0, if it is just return "0" so the first box can have cursor blink
    if index < 0 {
      return "0"
    }
    if index < input.count {
      let charIndex = input.index(input.startIndex, offsetBy: index)
      return String(input[charIndex])
    }
    return ""
  }
}
