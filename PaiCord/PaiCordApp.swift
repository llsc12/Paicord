//
//  PaiCordApp.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSVGCoder
import SwiftUI

@main
struct PaiCordApp: App {
	let gatewayStore: GatewayStore

	// captcha handling
	@State private var captchaChallenge: CaptchaChallengeData?
	@State private var captchaContinuation:
		CheckedContinuation<CaptchaSubmitData?, Never>?
	// mfa handling
	@State private var mfaVerification: MFAVerificationData?
	@State private var mfaContinuation: CheckedContinuation<MFAResponse?, Never>?

	init() {
		let SVGCoder = SDImageSVGCoder.shared
		SDImageCodersManager.shared.addCoder(SVGCoder)

		let store = GatewayStore()
		self.gatewayStore = store
	}
	var body: some Scene {
		WindowGroup {
			Group {
				//			ContentView()
				LoginView()
			}
			.fontDesign(.rounded)
			.sheet(item: $captchaChallenge) { challenge in
				CaptchaSheet(challenge: challenge) { submitData in
					// Resume continuation with solution or nil
					captchaContinuation?.resume(returning: submitData)
					captchaContinuation = nil
					captchaChallenge = nil
				}
				.frame(idealWidth: 400, idealHeight: 400)
				.environment(gatewayStore)
			}
			.sheet(item: $mfaVerification) { mfaData in
				MFASheet(verificationData: mfaData) { response in
					mfaContinuation?.resume(returning: response)
					mfaContinuation = nil
					mfaVerification = nil
				}
				.frame(idealWidth: 400, idealHeight: 300)
				.environment(gatewayStore)
			}
			.environment(gatewayStore)
			.onAppear {
				gatewayStore.captchaCallback = { captcha in
					await withCheckedContinuation { continuation in
						// Idk why but this looks horror,,
						DispatchQueue.main.async {
							captchaChallenge = captcha
							captchaContinuation = continuation
						}
					}
				}
				gatewayStore.mfaCallback = { mfaData in
					await withCheckedContinuation { continuation in
						DispatchQueue.main.async {
							mfaVerification = mfaData
							mfaContinuation = continuation
						}
					}
				}
			}
		}
		.windowStyle(.hiddenTitleBar)
	}
}

struct ContentView: View {
	var body: some View {
		#if os(iOS)
			SmallBaseplate()
		#else
			LargeBaseplate()
		#endif
	}
}

#Preview {
	ContentView()
}
