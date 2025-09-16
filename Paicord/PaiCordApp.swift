//
//  PaiCordApp.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSVGCoder
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

@main
struct PaiCordApp: App {
	let gatewayStore: GatewayStore
	@Bindable var appState = PaicordAppState()

	// captcha handling
	@State private var captchaChallenge: CaptchaChallengeData?
	@State private var captchaContinuation:
		CheckedContinuation<CaptchaSubmitData?, Never>?
	// mfa handling
	@State private var mfaVerification: MFAVerificationData?
	@State private var mfaContinuation: CheckedContinuation<MFAResponse?, Never>?

	@Environment(\.userInterfaceIdiom) var idiom

	init() {
		let SVGCoder = SDImageSVGCoder.shared
		SDImageCodersManager.shared.addCoder(SVGCoder)

		let store = GatewayStore()
		self.gatewayStore = store
	}

	var body: some Scene {
		WindowGroup {
			Group {
				if gatewayStore.accounts.currentAccountID == nil {
					LoginView()
						.environment(gatewayStore)
						.environment(appState)
				} else {
					if gatewayStore.state != .connected {
						ConnectionStateView(state: gatewayStore.state)
							.transition(
								.opacity.combined(with: .scale(scale: 1.1)).animation(
									.easeInOut(duration: 0.5))
							)
							.task {
								await gatewayStore.connectIfNeeded()
							}
					} else {
						Group {
							if idiom == .phone {
								#if os(iOS)
									SmallBaseplate()  // iphone
								#endif
							} else {
								LargeBaseplate()  // mac, ipad
							}
						}
						.navigationTitle("")
					}

				}
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
			.environment(appState)
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
			.alert(
				"Error", isPresented: $appState.showingError,
				actions: {
					Button("OK", role: .cancel) {
						appState.error = nil
					}
				},
				message: {
					if let error = appState.error as? DiscordHTTPErrorResponse {
						Text(error.description)
					} else if let error = appState.error {
						Text(error.localizedDescription)
					} else {
						Text("An unknown error occurred.")
					}
				})
		}
		.windowToolbarStyle(.unifiedCompact)
		.commands {
			CommandMenu("Account") {
				Button("Log Out") {
					gatewayStore.logOut()
				}
			}
		}

		#if os(macOS)
			Settings {
				SettingsView()
			}
		#endif
	}
}

@Observable
final class PaicordAppState {
	var selectedServer: GuildSnowflake? = nil  // nil means dms
	var selectedChannel: ChannelSnowflake? = nil  // idk man

	var showingError = false
	var error: Error? = nil {
		didSet {
			showingError = error != nil
		}
	}
}
