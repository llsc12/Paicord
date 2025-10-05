//
//  PaicordApp.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 31/08/2025.
//  Copyright © 2025 Lakhan Lothiyi. All rights reserved.
//

import Logging
import PaicordLib
import SDWebImageSVGCoder
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

#if canImport(FLEX)
	import FLEX
#endif

@main
struct PaiCordApp: App {
	let gatewayStore = GatewayStore.shared
	var appState = PaicordAppState()
	var challenges = Challenges()

	@Environment(\.userInterfaceIdiom) var idiom

	init() {
		// Set up svg support
		let SVGCoder = SDImageSVGCoder.shared
		SDImageCodersManager.shared.addCoder(SVGCoder)

		// i foubnd out this rly cool thing if u avoid logging 40mb of data to console the client isnt slow !!!!
//		#if DEBUG
//			DiscordGlobalConfiguration.makeLogger = { loggerLabel in
//				var logger = Logger(label: loggerLabel)
//				logger.logLevel = .trace
//				return logger
//			}
//		#endif
	}

	var body: some Scene {
		WindowGroup {
			RootView(
				gatewayStore: gatewayStore,
				appState: appState
			)
			.environment(challenges)
			.environment(appState)
			.environment(gatewayStore)
			.onAppear {
				#if canImport(FLEX)
					FLEXManager.shared.showExplorer()
				#endif
			}
		}
		#if os(macOS)
			.windowToolbarStyle(.unified)
		#endif
		.commands {
			AccountCommands(gatewayStore: gatewayStore)
		}
		#if os(macOS)
			Settings {
				SettingsView()
					.environment(gatewayStore)
			}
		#endif
	}
}
