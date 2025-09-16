//
//  GatewayStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 06/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

@Observable
final class GatewayStore {
	let accounts = TokenStore()

	@ObservationIgnored var captchaCallback: CaptchaChallengeHandler?
	@ObservationIgnored var mfaCallback: MFAVerificationHandler?
	@ObservationIgnored private(set) var gateway: UserGatewayManager?

	@ObservationIgnored
	var client: DiscordClient {
		gateway?.client ?? unauthenticatedClient
	}

	@ObservationIgnored
	private lazy var unauthenticatedClient: DefaultDiscordClient = {
		DefaultDiscordClient(
			captchaCallback: captchaCallback,
			mfaCallback: mfaCallback
		)
	}()

	var state: GatewayState = .noConnection {
		didSet {
			print("Gateway state changed to \(state)")
		}
	}
	var eventTask: Task<Void, Never>? = nil

	/// Disconnects current gateway and cancels event task if needed
	private func disconnectIfNeeded() async {
		guard ![.stopped, .noConnection].contains(state) else { return }
		await gateway?.disconnect()
		eventTask?.cancel()
	}

	/// Connects to the gateway if it is not already connected
	func connectIfNeeded() async {
		guard [.stopped, .noConnection].contains(state), eventTask == nil else { return }
		if let accountID = accounts.currentAccountID {
			let account = accounts.account(for: accountID)!
			await logIn(as: account)
		}
	}

	/// Login with a specific token
	func logIn(as account: TokenStore.AccountData) async {
		await disconnectIfNeeded()
		gateway = await UserGatewayManager(
			token: account.token,
			captchaCallback: captchaCallback,
			mfaCallback: mfaCallback,
			stateCallback: { [weak self] in self?.state = $0 }
		)
		setupEventHandling()
		await gateway?.connect()
	}

	private func setupEventHandling() {
		eventTask = Task { @MainActor in
			guard let gateway else { return }
			for await event in await gateway.events {
//				print(event.data)
				switch event.data {
				default: break
				}
			}
		}
	}
}

