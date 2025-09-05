//
//  ServerButton.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 02/09/2025.
//

import SwiftUI

/// Shows a server, icon
struct ServerButton: View {
	var id: String = UUID().uuidString
	var body: some View {
		Button {
			print("Server button tapped: \(id)")
		} label: {
			Circle()
		}
	}
}

#Preview {
	ServerButton()
}
