//
//  Challenges.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
@MainActor
final class Challenges: ObservableObject {
  // Captcha
  var captchaChallenge: CaptchaChallengeData?
  private var captchaContinuation:
    CheckedContinuation<CaptchaSubmitData?, Never>?

  // MFA
  var mfaVerification: MFAVerificationData?
  private var mfaContinuation: CheckedContinuation<MFAResponse?, Never>?

  func presentCaptcha(_ challenge: CaptchaChallengeData) async
    -> CaptchaSubmitData?
  {
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        self.captchaChallenge = challenge
        self.captchaContinuation = continuation
      }
    }
  }

  func presentMFA(_ data: MFAVerificationData) async -> MFAResponse? {
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        self.mfaVerification = data
        self.mfaContinuation = continuation
      }
    }
  }

  func completeCaptcha(_ submitData: CaptchaSubmitData?) {
    captchaContinuation?.resume(returning: submitData)
    captchaContinuation = nil
    captchaChallenge = nil
  }

  func completeMFA(_ response: MFAResponse?) {
    mfaContinuation?.resume(returning: response)
    mfaContinuation = nil
    mfaVerification = nil
  }
}
