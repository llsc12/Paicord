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

extension EnvironmentValues {
  @Entry var profileAnimated: Bool = false
  @Entry var profileShowAvatarDecoration: Bool = false
  @Entry var profileHideOfflinePresence: Bool = false
  
  @Entry var nameplateAnimated: Bool = false
}

extension View {
  /// Whether to show animated avatars and decorations
  func profileAnimated(_ animated: Bool = true) -> some View {
    environment(\.profileAnimated, animated)
  }

  /// Whether to show avatar decorations
  func profileShowsAvatarDecoration(_ shown: Bool = true ) -> some View {
    environment(\.profileShowAvatarDecoration, shown)
  }
  
  /// Whether to hide offline presence indicator
  func profileHidesOfflinePresence(_ hide: Bool) -> some View {
    environment(\.profileHideOfflinePresence, hide)
  }
  
  /// Whether to show animated nameplates
  func nameplateAnimated(_ animated: Bool = true) -> some View {
    environment(\.nameplateAnimated, animated)
  }
}

/// Collection of ui components for profiles
enum Profile {
  struct Avatar: View {
    @Environment(\.guildStore) var guildStore
    let member: Guild.PartialMember?
    let user: PartialUser?
//    var animated: Bool = false
//    var showDecoration: Bool = false
    @Environment(\.profileAnimated) var animated
    @Environment(\.profileShowAvatarDecoration) var showDecoration

    var body: some View {
      Group {
        Utils.UserAvatarURL(member: member, user: user, animated: false) {
          url in
          WebImage(url: url) { phase in
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
          .overlay {
            if animated {
              Utils.UserAvatarURL(member: member, user: user, animated: true) {
                animatedURL in
                WebImage(url: animatedURL) { phase in
                  switch phase {
                  case .success(let image):
                    image
                      .resizable()
                      .scaledToFit()
                  default:
                    EmptyView()
                  }
                }
              }
            }
          }
        }
      }
      .clipShape(Circle())
      .overlay {
        if showDecoration,
          let decoration = member?.avatar_decoration_data
            ?? user?.avatar_decoration_data
        {
          AvatarDecorationView(
            decoration: decoration,
            animated: animated
          )
          .scaleEffect(1.2)
        }
      }
      .padding(10)
      .padding(-10)
    }
  }

  // Helper shape that draws a rect with a circular hole (uses even-odd fill)
  private struct RectWithCircleHole: Shape {
    var holeCenter: CGPoint
    var holeRadius: CGFloat

    func path(in rect: CGRect) -> Path {
      var p = Path()
      p.addRect(rect)
      p.addEllipse(
        in: CGRect(
          x: holeCenter.x - holeRadius,
          y: holeCenter.y - holeRadius,
          width: holeRadius * 2,
          height: holeRadius * 2
        )
      )
      return p
    }
  }

  struct AvatarWithPresence: View {
    @Environment(\.gateway) var gw
    let member: Guild.PartialMember?
    let user: PartialUser?
    @Environment(\.profileHideOfflinePresence) var hideOffline: Bool

    init(member: Guild.PartialMember? = nil, user: DiscordUser?) {
      self.member = member
      self.user = user?.toPartialUser()
    }
    init(member: Guild.PartialMember? = nil, user: PartialUser?) {
      self.member = member
      self.user = user
    }

    var body: some View {
      if let user {
        GeometryReader { geo in
          let size = min(geo.size.width, geo.size.height)
          let dotSize = size * 0.25
          let inset = dotSize * 0.55

          let presence: ActivityData? = {
            if user.id == gw.user.currentUser?.id,
              let session = gw.user.sessions.last
            {
              return session
            } else {
              return gw.user.presences[user.id]
            }
          }()

          // modified this to work around the masking cutting off avatar decorations that go out of frame.
          // can make the view look worse maybe.
          let scaleDown: CGFloat = 0.75
          let scaleUp: CGFloat = 1.0 / scaleDown

          let center = CGPoint(
            x: geo.size.width * 0.5,
            y: geo.size.height * 0.5
          )
          let originalHole = CGPoint(
            x: geo.size.width - inset,
            y: geo.size.height - inset
          )
          let scaledHole = CGPoint(
            x: center.x + scaleDown * (originalHole.x - center.x),
            y: center.y + scaleDown * (originalHole.y - center.y)
          )
          let scaledHoleRadius = (dotSize * 1.5 / 2) * scaleDown

          ZStack(alignment: .bottomTrailing) {
            Avatar(member: member, user: user)
              .scaleEffect(scaleDown)
              .mask(
                RectWithCircleHole(
                  holeCenter: scaledHole,
                  holeRadius: scaledHoleRadius
                )
                .fill(style: FillStyle(eoFill: true))
              )
              .scaleEffect(scaleUp)

            if let presence {
              let color: Color = {
                switch presence.status {
                case .online: return .init(hexadecimal6: 0x42a25a)
                case .afk: return .init(hexadecimal6: 0xca9653)
                case .doNotDisturb: return .init(hexadecimal6: 0xd83a42)
                default: return .init(hexadecimal6: 0x82838b)
                }
              }()

              Group {
                switch presence.status {
                case .online:
                  StatusIndicatorShapes.OnlineShape()
                case .afk:
                  StatusIndicatorShapes.IdleShape()
                case .doNotDisturb:
                  StatusIndicatorShapes.DNDShape()
                default:
                  StatusIndicatorShapes.InvisibleShape()
                    .hidden(hideOffline)
                }
              }
              .foregroundStyle(color)
              .frame(width: dotSize, height: dotSize)
              .position(
                x: geo.size.width - inset,
                y: geo.size.height - inset
              )
            } else {
              StatusIndicatorShapes.InvisibleShape()
                .foregroundStyle(Color.init(hexadecimal6: 0x82838b))
                .frame(width: dotSize, height: dotSize)
                .position(
                  x: geo.size.width - inset,
                  y: geo.size.height - inset
                )
                .hidden(hideOffline)
            }
          }
          .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
      }
    }
  }

  struct NameplateView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.nameplateAnimated) var animated
    let nameplate: DiscordUser.Collectibles.Nameplate

    var color: Color {
      switch colorScheme {
      case .light:
        nameplate.palette.color.light.asColor(ignoringZero: false)!
      case .dark:
        nameplate.palette.color.dark.asColor(ignoringZero: false)!
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
    
    var animatedURL: URL? {
      URL(
        string: CDNEndpoint.collectibleNameplate(
          asset: nameplate.asset,
          file: .apng
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
        if animated,
          let animatedURL
        {
          WebImage(url: animatedURL) { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .scaledToFill()
                .clipped()
            default:
              WebImage(url: staticURL)
                .resizable()
                .scaledToFill()
                .clipped()
            }
          }
        } else {
          WebImage(url: staticURL)
            .resizable()
            .scaledToFill()
            .clipped()
        }
      }
    }
  }

  struct BannerView: View {
    var body: some View {
      EmptyView()
    }
  }

  struct Badge: View {
    var badge: DiscordUser.Profile.Badge
    @State private var isHovered: Bool = false
    var body: some View {
      WebImage(url: badgeURL())
        .resizable()
        .scaledToFit()
        .frame(width: 16, height: 16)
        .onHover { isHovered = $0 }
        .popover(isPresented: $isHovered) {
          Text(badge.description)
            .padding(5)
        }
    }
    func badgeURL() -> URL? {
      // check if icon is already a url
      if badge.icon.starts(with: "http") {
        return URL(string: badge.icon)
      }

      // else fetch from cdn
      return URL(
        string: CDNEndpoint.profileBadge(icon: badge.icon).url + ".png"
      )
    }
  }

  struct ThemeColorsBackground: View {
    var colors: [DiscordColor]?

    var body: some View {
      if let colors,
        let primaryColor = colors.first?.asColor(ignoringZero: true),
        let secondaryColor = colors.last?.asColor(ignoringZero: true)
      {
        LinearGradient(
          gradient: .init(colors: [primaryColor, secondaryColor]),
          direction: .down
        )
      }
    }
  }

  struct BadgesView: View {
    @Environment(\.gateway) var gw
    var profile: DiscordUser.Profile?
    var member: Guild.PartialMember?
    var user: PartialUser?

    var body: some View {
      let badges =
      gw.externalBadges.badges(for: user?.id) + (profile?.guild_badges ?? []) + (profile?.badges ?? [])
      LazyHStack(spacing: 2) {
        ForEach(badges) { badge in
          Badge(badge: badge)
        }
      }
    }
  }
}

enum StatusIndicatorShapes {
  struct OnlineShape: View {
    var body: some View {
      Circle()
    }
  }
  struct IdleShape: View {
    var body: some View {
      GeometryReader { geo in
        let size = min(geo.size.width, geo.size.height)
        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
        let radius = size / 2

        let cutoutRadius = radius * 0.65
        let cutoutCenter = CGPoint(
          x: geo.size.width - radius * 1.5,
          y: geo.size.height - radius * 1.4
        )

        Circle()
          .frame(width: radius * 2, height: radius * 2)
          .position(center)
          .reverseMask {
            Circle()
              .frame(width: cutoutRadius * 2, height: cutoutRadius * 2)
              .position(cutoutCenter)
          }
      }
      .aspectRatio(1, contentMode: .fit)
    }
  }
  struct DNDShape: View {
    var body: some View {
      GeometryReader { geo in
        let size = min(geo.size.width, geo.size.height)
        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
        let radius = size / 2

        let capsuleWidth = size * 0.6
        let capsuleHeight = size * 0.18
        let capsuleCenter = center

        Circle()
          .frame(width: radius * 2, height: radius * 2)
          .position(center)
          .reverseMask {
            RoundedRectangle(cornerRadius: capsuleHeight / 2)
              .frame(width: capsuleWidth, height: capsuleHeight)
              .position(x: capsuleCenter.x, y: capsuleCenter.y)
          }
      }
      .aspectRatio(1, contentMode: .fit)
    }
  }
  struct InvisibleShape: View {
    var body: some View {
      GeometryReader { geo in
        let size = min(geo.size.width, geo.size.height)
        let radius = size / 2
        let cutoutRadius = radius * 0.5

        Circle()
          .frame(width: radius * 2, height: radius * 2)
          .reverseMask {
            Circle()
              .frame(width: cutoutRadius * 2, height: cutoutRadius * 2)
          }
      }
      .aspectRatio(1, contentMode: .fit)
    }
  }
}

struct AvatarDecorationView: View {
  var decoration: DiscordUser.AvatarDecoration
  var animated: Bool
  var body: some View {
    WebImage(url: avatarDecorationURL(animated: animated)) { phase in
      switch phase {
      case .success(let image):
        image
          .resizable()
      default:
        WebImage(url: avatarDecorationURL(animated: false))
          .resizable()
      }
    }
    .scaledToFit()
    .aspectRatio(1, contentMode: .fit)
  }

  func avatarDecorationURL(animated: Bool) -> URL? {
    URL(
      string: CDNEndpoint.avatarDecoration(asset: decoration.asset).url
        + ".png?size=128&passthrough=\(animated.description)"
    )
  }
}

#Preview {
  let decoration = DiscordUser.AvatarDecoration(
    asset: "a_741750ac1c9091a58059be33590c2821",
    sku_id: .init("1424960507143524495")
  )

  let llsc12 = DiscordUser(
    id: .init("381538809180848128"),
    username: "llsc12",
    discriminator: "0",
    global_name: nil,
    avatar: "df71b3f223666fd8331c9940c6f7cbd9",
    banner: nil,
    bot: false,
    system: false,
    mfa_enabled: true,
    accent_color: nil,
    locale: .englishUS,
    verified: true,
    email: nil,
    flags: .init(rawValue: 4_194_352),
    premium_type: nil,
    public_flags: .init(rawValue: 4_194_304),
    avatar_decoration_data: decoration
  )
  Group {
    Profile.AvatarWithPresence(
      member: nil,
      user: llsc12
    )
    .profileAnimated()
    .profileShowsAvatarDecoration()
    .frame(width: 100, height: 100)
  }
  //  .padding()
}
