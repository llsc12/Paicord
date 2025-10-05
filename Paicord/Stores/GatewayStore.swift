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
	static let shared = GatewayStore()

	// Some setup for the gateway
	@ObservationIgnored var captchaCallback: CaptchaChallengeHandler?
	@ObservationIgnored var mfaCallback: MFAVerificationHandler?
	@ObservationIgnored private(set) var gateway: UserGatewayManager?

	@ObservationIgnored
	var client: DiscordClient {
		gateway?.client ?? unauthenticatedClient
	}

	@ObservationIgnored
	lazy var unauthenticatedClient: DefaultDiscordClient = {
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

	@ObservationIgnored
	var eventTask: Task<Void, Never>? = nil

	// MARK: - Gateway Management

	/// Disconnects current gateway and cancels event task if needed
	private func disconnectIfNeeded() async {
		guard !([.stopped, .noConnection].contains(state)) else { return }
		await gateway?.disconnect()
		eventTask?.cancel()
	}

	/// Connects to the gateway if it is not already connected
	func connectIfNeeded() async {
		guard [.stopped, .noConnection].contains(state), eventTask == nil else {
			return
		}
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

	/// Disconnects from the gateway. You must remove the current account from TokenStore before calling this.
	/// This will reset all stores.
	func logOut() async {
		await disconnectIfNeeded()
		gateway = nil
		resetStores()
	}

	func setupEventHandling() {
		eventTask = Task { @MainActor in
			guard let gateway else { return }
			for await event in await gateway.events {
				switch event.data {
				
				default: break
				}
			}
		}

		// Set up stores with gateway
		currentUser.setGateway(self.gateway)
		settings.setGateway(self.gateway)

		// Update existing channel stores
		for channelStore in channels.values {
			channelStore.setGateway(self.gateway)
		}

		// Update existing guild stores
		for guildStore in guilds.values {
			guildStore.setGateway(self.gateway)
		}
	}

	func resetStores() {
		currentUser = CurrentUserStore()
		settings = SettingsStore()
		channels = [:]
		guilds = [:]
	}

	// MARK: - Data Stores

	let accounts = TokenStore()
	var currentUser = CurrentUserStore()
	var settings = SettingsStore()

	private var channels: [ChannelSnowflake: ChannelStore] = [:]
	func getChannelStore(for id: ChannelSnowflake, from guild: GuildStore? = nil) -> ChannelStore {
		if let store = channels[id] {
			return store
		} else {
			let channel = guild?.channels[id] ?? currentUser.privateChannels[id]
			let store = ChannelStore(id: id, from: channel)
			store.setGateway(self.gateway)
			channels[id] = store
			return store
		}
	}

	private var guilds: [GuildSnowflake: GuildStore] = [:]
	func getGuildStore(for id: GuildSnowflake) -> GuildStore {
		print("Requesting guild store for \(id)")
		defer {
			if !subscribedGuilds.contains(id) {
				subscribedGuilds.insert(id)
				Task {
					await gateway?.updateGuildSubscriptions(
						payload:
								.init(subscriptions: [
									id: .init(
										typing: true,
										activities: false,
										threads: false,
										channels: [:],
										thread_member_lists: nil
									)
								])
					)
					print("Subscribed to guild \(id)")
				}
			}
		}
		if let store = guilds[id] {
			return store
		} else {
			let store = GuildStore(id: id, from: currentUser.guilds[id])
			store.setGateway(self.gateway)
			guilds[id] = store
			return store
		}
	}
	private var subscribedGuilds: Set<GuildSnowflake> = []

}
