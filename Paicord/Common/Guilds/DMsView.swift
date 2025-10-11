//
//  DMsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 06/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

//
//  DMsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 22/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

struct DMsView: View {
	@Environment(GatewayStore.self) var gw
	@Environment(PaicordAppState.self) var appState
	var body: some View {
		ScrollView {
			ForEach(Array(gw.user.privateChannels.values)) { channel in
				GuildView.ChannelButton(channels: [:], channel: channel)
			}
		}
		.frame(maxWidth: .infinity)
		.background(.tableBackground.opacity(0.5))
		.roundedCorners(radius: 10, corners: .topLeft)
	}
}
