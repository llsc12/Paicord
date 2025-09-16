//
//  SettingsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//  

import SwiftUI

struct SettingsView: View {
	@Environment(GatewayStore.self) var gs
	var body: some View {
		AsyncButton("Log out") {
			try await gs.
		} catch: {
			print("failed to logout: \(String(describing: $0))")
		}
	}
}
