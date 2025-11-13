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
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  @Environment(\.userInterfaceIdiom) var idiom
  var body: some View {
    ScrollView {
      if idiom == .phone {
        VStack(spacing: 0) {
          Text("Direct Messages")
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
          Divider()
        }
      }

      let channels = gw.user.privateChannels.values
      LazyVStack(spacing: 4) {
        ForEach(channels) { channel in
          ChannelButton(channels: [:], channel: channel)
        }
      }
      .padding(.vertical, 4)
    }
    .frame(maxWidth: .infinity)
    .background(.tableBackground.opacity(0.5))
    .roundedCorners(radius: 10, corners: .topLeft)
  }
}
