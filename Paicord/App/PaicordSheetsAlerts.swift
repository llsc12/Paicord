//
//  PaicordSheetsAlerts.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUI

struct PaicordSheetsAlerts: ViewModifier {
  let gatewayStore: GatewayStore
  @Bindable var appState: PaicordAppState
  @EnvironmentObject var challenges: Challenges

  func body(content: Content) -> some View {
    content
      .sheet(item: $challenges.captchaChallenge) { challenge in
        CaptchaSheet(challenge: challenge) { submitData in
          challenges.completeCaptcha(submitData)
        }
        .frame(idealWidth: 400, idealHeight: 400)
        .environment(gatewayStore)
      }
      .sheet(item: $challenges.mfaVerification) { mfaData in
        MFASheet(verificationData: mfaData) { response in
          challenges.completeMFA(response)
        }
        .frame(idealWidth: 400, idealHeight: 300)
        .environment(gatewayStore)
      }
      .alert(
        "Error",
        isPresented: $appState.showingError,
        actions: {
          Button("OK", role: .cancel) { appState.error = nil }
          Button("Details") {
            appState.showingErrorSheet = true
            appState.showingError = false
          }
        },
        message: {
          errorTextView(error: appState.error)
        }
      )
      .sheet(isPresented: $appState.showingErrorSheet) {
        ScrollView { errorTextView(error: appState.error) }
      }
  }

  @ViewBuilder
  private func errorTextView(error: Error?) -> some View {
    if let error = error as? DiscordHTTPErrorResponse {
      Text(error.description)
    } else if let error = error as? DiscordHTTPError {
      Text(error.description)
    } else if let error = error {
      Text(error.localizedDescription)
    } else {
      Text("An unknown error occurred.")
    }
  }
}
