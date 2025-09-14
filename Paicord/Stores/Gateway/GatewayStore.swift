//
//  GatewayStore.swift
//  Paicord
//
// Created by Lakhan Lothiyi on 06/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Observation
import PaicordLib

@Observable
final class GatewayStore {
	let accounts = TokenStore()
	
	@ObservationIgnored
	var captchaCallback: CaptchaChallengeHandler? = nil
	@ObservationIgnored
	var mfaCallback: MFAVerificationHandler? = nil
	
	@ObservationIgnored
	var gateway: UserGatewayManager?
	
	@ObservationIgnored
	var client: DiscordClient {
		(gateway?.client) ?? _unauthenticatedClient
	}
	
	@ObservationIgnored
	private lazy var _unauthenticatedClient: DefaultDiscordClient = {
		return DefaultDiscordClient.init(captchaCallback: self.captchaCallback, mfaCallback: self.mfaCallback) // mfa callback wont happen this is not logged in
	}()

	var state: GatewayState {
		gateway?.state.load(ordering: .relaxed) ?? GatewayState.noConnection
	}

	var eventTask: Task<Void, Never>? = nil

	func logIn(token: Secret) async {
		if [GatewayState.stopped, .noConnection].contains(state) == false {
			await gateway?.disconnect()
			eventTask?.cancel()
		}
		gateway = await UserGatewayManager(token: token)

		await gateway?.connect()
	}

	func logIn() async {
		if [GatewayState.stopped, .noConnection].contains(state) == false {
			await gateway?.disconnect()
			eventTask?.cancel()
		}

		guard let currentAccountID = accounts.currentAccountID else { return }
		let token = accounts.account(for: currentAccountID).token
		gateway = await UserGatewayManager(token: token)

		await gateway?.connect()
	}
}
