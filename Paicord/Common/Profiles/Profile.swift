//
//  Profile.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

/// Collection of ui components for profiles
enum Profile {
  struct Avatar: View {
    let member: Guild.PartialMember?
    let user: DiscordUser

    var body: some View {
      WebImage(url: avatarURL(animated: true)) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFit()
        default:
          Circle()
            .foregroundStyle(.gray.opacity(0.3))
        }
      }
      .clipShape(Circle())
    }

    func avatarURL(animated: Bool) -> URL? {
      let id = user.id
      if let avatar = member?.avatar ?? user.avatar {
        if avatar.starts(with: "a_"), animated {
          return URL(
            string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
              + ".gif?size=128&animated=true"
          )
        } else {
          return URL(
            string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
              + ".png?size=128&animated=false"
          )
        }
      } else {
        let discrim = user.discriminator
        return URL(
          string: CDNEndpoint.defaultUserAvatar(discriminator: discrim).url
            + "?size=128"
        )
      }
    }
  }

  struct AvatarWithPresence: View {
    @Environment(GatewayStore.self) var gw
    let member: Guild.PartialMember?
    let user: DiscordUser
    let testingPresence: Gateway.PresenceUpdate?

    var body: some View {
      GeometryReader { geo in
        let size = min(geo.size.width, geo.size.height)
        let dotSize = size * 0.28
        ZStack(alignment: .bottomTrailing) {
          Avatar(member: member, user: user)
            .clipShape(
              Circle()
                .path(in: CGRect(origin: .zero, size: geo.size))
                .subtracting(
                  Circle()
                    .path(in: CGRect(
                      x: geo.size.width - dotSize * 1.1,
                      y: geo.size.height - dotSize * 1.1,
                      width: dotSize,
                      height: dotSize
                    ))
                )
            )

          if let presence = testingPresence ?? gw.user.presences[user.id] {
            let color: Color = {
              switch presence.status {
              case .online: return .init(hexadecimal6: 0x42a25a)
              case .afk: return .init(hexadecimal6: 0xca9653)
              case .doNotDisturb: return .init(hexadecimal6: 0xd83a42)
              default: return .init(hexadecimal6: 0x82838b)
              }
            }()

            Circle()
              .fill(color)
              .frame(width: dotSize, height: dotSize)
              .offset(x: -dotSize * 0.15, y: -dotSize * 0.15)
              .shadow(radius: dotSize * 0.1)
          }
        }
        .frame(width: geo.size.width, height: geo.size.height)
      }
      .aspectRatio(1, contentMode: .fit)
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
          .clipped()
      }
    }
  }
}

#Preview {
  @Previewable @State var width: CGFloat = 100
  @Previewable @State var height: CGFloat = 100
  
  VStack {
    Profile.AvatarWithPresence(
      member: nil,
      user: DiscordUser(
        id: UserSnowflake("381538809180848128"),
        username: "llsc12",
        discriminator: "0",
        global_name: nil,
        avatar: "df71b3f223666fd8331c9940c6f7cbd9",
        bot: false,
        system: false,
        mfa_enabled: true,
        banner: nil,
        accent_color: nil,
        locale: nil,
        verified: true,
        email: nil,
        flags: .init(rawValue: 4_194_352),
        premium_type: DiscordUser.PremiumKind.none,
        public_flags: .init(rawValue: 4_194_304),
        collectibles: .init(
          nameplate: .init(
            asset: "nameplates/nameplates_v3/bonsai/",
            sku_id: .init("1382845914225442886"),
            label: "COLLECTIBLES_NAMEPLATES_VOL_3_BONSAI_A11Y",
            palette: .bubble_gum,
            expires_at: nil
          ),
        ),
        avatar_decoration_data: nil
      ),
      testingPresence: Gateway.PresenceUpdate(
        user: PartialUser(id: UserSnowflake("381538809180848128")),
        status: .online,
        activities: [],
        client_status: Gateway.ClientStatus(
          desktop: nil,
          mobile: nil,
          web: nil,
          embedded: nil
        )
      )
    )
    .frame(width: width, height: height)
    .environment(GatewayStore())
    
    Slider(value: $width, in: 50...300) {
      Text("Width")
    }
    Slider(value: $height, in: 50...300) {
      Text("Height")
    }
  }
}
