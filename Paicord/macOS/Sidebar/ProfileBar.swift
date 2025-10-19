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
      #warning("replace with avatar presence view of some sort")
      AnimatedImage(url: profileURL(animated: true))
        .resizable()
        .scaledToFit()
        .maxHeight(40)
        .clipShape(.circle)

      VStack(alignment: .leading) {
        Text(
          gw.user.currentUser?.global_name ?? gw.user.currentUser?.username
            ?? "Unknown User"
        )
        .bold()
        if showingUsername {
          Text("@\(gw.user.currentUser?.username ?? "Unknown User")")
            .transition(.opacity)
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
            .padding(5)
            .background(.ultraThinMaterial)
            .clipShape(.circle)
        }
        .buttonStyle(.borderless)
      #elseif os(iOS)
        /// targetting ipad here, ios wouldnt have this at all
        // do something
      #endif
    }
    .padding(10)
    .background {
      if let nameplate = gw.user.currentUser?.collectibles?.nameplate {
        NameplateView(nameplate: nameplate)
          .brightness(-0.2)
      }
    }
    .clipped()
  }

  func profileURL(animated: Bool) -> URL? {
    if let id = gw.user.currentUser?.id,
      let avatar = gw.user.currentUser?.avatar
    {
      return URL(
        string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
          + "?size=128&animated=\(animated.description)"
      )
    } else {
      let discrim = gw.user.currentUser?.discriminator ?? "0"
      return URL(
        string: CDNEndpoint.defaultUserAvatar(discriminator: discrim).url
          + "?size=128"
      )
    }
  }
}

struct NameplateView: View {
  @Environment(\.colorScheme) var colorScheme
  let nameplate: DiscordUser.Collectibles.Nameplate

  var color: Color {
    switch colorScheme {
    case .light:
      nameplate.palette.color.light.asColor()
    case .dark:
      nameplate.palette.color.dark.asColor()
    @unknown default:
      fatalError()
    }
  }

  var staticURL: URL? {
    URL(
      string: CDNEndpoint.collectibleNameplate(
        asset: nameplate.asset,
        file: .static
      ).url
    )
  }

  var body: some View {
    ZStack {
      switch nameplate.palette {
      case .none, .__undocumented: EmptyView()
      default:
        LinearGradient(
          gradient: Gradient(stops: [
            .init(color: color.opacity(0.1), location: 0.0),
            .init(color: color.opacity(0.4), location: 1.0),
          ]),
          startPoint: .leading,
          endPoint: .trailing
        )
      }
      WebImage(url: staticURL)
        .resizable()
        .scaledToFill()
    }
  }
}
