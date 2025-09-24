//
//  ProfileBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 24/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

struct ProfileBar: View {
	@Environment(GatewayStore.self) var gw
	#if os(macOS)
	@Environment(\.openSettings) var openSettings
	#endif
	
	@State var showingUsername = false
	
	var body: some View {
		HStack {
			AnimatedImage(
				url: profileURL(animated: true)
			)
			.resizable()
			.scaledToFit()
			
			VStack(alignment: .leading) {
				Text(gw.currentUser.currentUser?.global_name ?? gw.currentUser.currentUser?.username ?? "Unknown User")
					.bold()
				if showingUsername {
					Text("@\(gw.currentUser.currentUser?.username ?? "Unknown User")")
						.transition(.flipFromTop.combined(with: .opacity))
				} else {
					// show status
				}
			}
			.background(.black.opacity(0.001))
			.onHover { showingUsername = $0 }
			.animation(.spring(), value: showingUsername)
			
			Spacer()
			
			#if os(macOS)
			Button {
				openSettings()
			} label: {
				Image(systemName: "gearshape.fill")
					.font(.title2)
			}
			.buttonStyle(.borderless)
			#endif
		}
		.padding(10)
		.frame(height: 55)
	}

	func profileURL(animated: Bool) -> URL? {
		if let id = gw.currentUser.currentUser?.id,
			let avatar = gw.currentUser.currentUser?.avatar
		{
			return URL(
				string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
					+ "?size=128&animated=\(animated.description)"
			)
		} else {
			let discrim = gw.currentUser.currentUser?.discriminator ?? "0"
			return URL(
				string: CDNEndpoint.defaultUserAvatar(discriminator: discrim).url
					+ "?size=128"
			)
		}
	}
}
