//
//  EmbedsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 21/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import AVKit
import Foundation
import Loupe
import PaicordLib
import SDWebImageSwiftUI
import SwiftPrettyPrint
import SwiftUIX

extension MessageCell {
  struct EmbedsView: View {
    var embeds: [Embed]

    private let maxWidth: CGFloat = 500
    private let maxHeight: CGFloat = 300
    
    var body: some View {
      #warning(
        "redo this to support all embed types properly, eg gifs, embeds with multiple images."
      )
      ForEach(embeds) { embed in
        Group {
          switch embed.type {
          case .rich, .article:
            EmbedView(embed: embed)
          case .image:
            if let image = embed.image ?? embed.thumbnail,
              let url = URL(string: image.proxyurl)
            {
              AnimatedImage(url: url)
                .resizable()
                .aspectRatio(image.aspectRatio, contentMode: .fit)
                .clipShape(.rounded)
                .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            }
          case .gifv:
            if let video = embed.video {
              GifvView(media: video, staticMedia: embed.image)
            }
          case .link:
            LinkEmbedView(embed: embed)
          default:
            Text("Unsupported embed type: \(embed.type)")
          }
        }
        .debugRender()
        .debugCompute()
      }
    }

    struct EmbedView: View {
      var embed: Embed

      @Environment(\.userInterfaceIdiom) var idiom
      @Environment(\.channelStore) var channelStore
      @Environment(\.theme) var theme

      var embedWidth: CGFloat {
        switch idiom {
        case .phone:
          return 425 - 50
        default:
          return 425
        }
      }

      private var inlineColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
      }

      var body: some View {
        VStack(alignment: .leading, spacing: 8) {
          HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
              if let author = embed.author {
                HStack(spacing: 8) {
                  if let icon = author.proxy_icon_url,
                    let url = URL(string: icon)
                  {
                    AnimatedImage(url: url)
                      .resizable()
                      .scaledToFit()
                      .background(Color.gray.opacity(0.15))
                      .clipShape(.circle)
                      .frame(width: 20, height: 20)
                  }
                  Text(author.name)
                    .font(.caption)
                    .lineLimit(1)
                }
              }

              if let title = embed.title {
                if let link = embed.url,
                  let url = URL(string: link)
                {
                  Link(destination: url) {
                    Text(title)
                      .font(.headline)
                      .multilineTextAlignment(.leading)
                  }
                  .tint(Color(hexadecimal6: 0x00aafc))
                } else {
                  Text(title)
                    .font(.headline)
                    .foregroundColor(theme.markdown.text)
                    .multilineTextAlignment(.leading)
                }
              }

              if let desc = embed.description {
                MarkdownText(content: desc, channelStore: channelStore)
                  .equatable()
              }
            }

            if let thumb = embed.thumbnail?.proxy_url,
              let url = URL(string: thumb)
            {
              AnimatedImage(url: url)
                .resizable()
                .scaledToFit()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipped()
                .cornerRadius(6)
                .id("embed-thumbnail-\(url.description)")
            }
          }

          if let fields = embed.fields, !fields.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              // Separate inline and block fields
              let inlineFields = fields.filter { $0.inline ?? false }
              let blockFields = fields.filter { ($0.inline ?? false) == false }

              if !inlineFields.isEmpty {
                LazyVGrid(
                  columns: inlineColumns,
                  alignment: .leading,
                  spacing: 8
                ) {
                  ForEach(inlineFields) { field in
                    VStack(alignment: .leading, spacing: 4) {
                      Text(field.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                      MarkdownText(content: field.value)
                        .equatable()
                        .fixedSize(horizontal: false, vertical: true)
                    }
                  }
                }
              }

              ForEach(blockFields) { field in
                VStack(alignment: .leading, spacing: 4) {
                  Text(field.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                  MarkdownText(content: field.value)
                    .equatable()
                    .fixedSize(horizontal: false, vertical: true)
                }
              }
            }
          }

          if let image = embed.image,
            let imageURL = image.proxy_url,
            let url = URL(string: imageURL)
          {
            let aspectRatio: CGFloat? = {
              if let width = image.width, let height = image.height {
                return width.toCGFloat / height.toCGFloat
              } else {
                return nil
              }
            }()
            AnimatedImage(url: url)
              .resizable()
              .aspectRatio(aspectRatio, contentMode: .fit)
              .clipShape(.rounded)
              .frame(
                minWidth: 1,
                maxWidth: min(image.width?.toCGFloat, 400),
                minHeight: 1,
                maxHeight: min(image.height?.toCGFloat, 300),
                alignment: .leading
              )
              .id("embed-image-\(url.description)")
          }

          if embed.footer != nil || embed.timestamp != nil {
            HStack(spacing: 4) {
              if let footer = embed.footer {
                HStack(spacing: 6) {
                  if let icon = footer.proxy_icon_url,
                    let url = URL(string: icon)
                  {
                    AnimatedImage(url: url)
                      .resizable()
                      .scaledToFit()
                      .clipShape(Circle())
                      .frame(width: 16, height: 16)
                  }
                  Text(footer.text)
                    .font(.subheadline)
                }
              }

              if embed.footer != nil && embed.timestamp != nil {
                Text("•")
              }

              if let ts = embed.timestamp {
                Text(ts.date.formattedShort())
                  .font(.subheadline)
              }

              Spacer()
            }
          }
        }
        .padding(8)
        .frame(maxWidth: embedWidth)
        .padding(.horizontal, 8)
        .background {
          if let color = embed.color?.asColor() {
            Rectangle()
              .fill(color)
              .frame(width: 3)
              .frame(maxWidth: .infinity, alignment: .leading)
          } else {
            Rectangle()
              .fill(Color(hexadecimal6: 0x202225))
              .frame(width: 3)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .background(theme.common.tertiaryBackground)
        .clipShape(.rect(cornerRadius: 5))
      }
    }

    struct GifvView: View {
      var media: Embed.Media
      var staticMedia: Embed.Media? = nil  // soon, to use as poster
      private var player: AVPlayer

      private let maxWidth: CGFloat = 500
      private let maxHeight: CGFloat = 300
      
      init(media: Embed.Media, staticMedia: Embed.Media? = nil) {
        self.media = media
        self.staticMedia = staticMedia
        let sourceURL = URL(string: media.proxyurl)!
        let asset = AVAsset(url: sourceURL)
        let item: AVPlayerItem = .init(asset: asset)
        let player: AVPlayer = .init(playerItem: item)
        self.player = player
        // avplayerlooper is unreliable on both iOS and macOS, so we use a notification observer to loop instead
        // idk how this even happens bro
        NotificationCenter.default.addObserver(
          forName: .AVPlayerItemDidPlayToEndTime,
          object: item,
          queue: .main
        ) { _ in
          player.seek(to: .zero)
          player.play()
        }
      }
      var body: some View {
        AVPlayerLayerContainer(player: player)
          .aspectRatio(media.aspectRatio, contentMode: .fit)
          .clipShape(.rounded)
          .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
          .onAppear {
            player.play()
          }
          .onDisappear {
            player.seek(to: .zero)
            player.pause()
          }
      }

      struct AVPlayerLayerContainer: AppKitOrUIKitViewRepresentable {
        var player: AVPlayer

        typealias AppKitOrUIKitViewType = AppKitOrUIKitView

        func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitView {
          #if os(iOS)
            let view = PlayerView_iOS()
            view.player = player
            return view
          #elseif os(macOS)
            let view = PlayerView_macOS()
            view.player = player
            return view
          #endif
        }

        func updateAppKitOrUIKitView(
          _ view: AppKitOrUIKitViewType,
          context: Context
        ) {
          #if os(iOS)
            (view as? PlayerView_iOS)?.player = player
          #elseif os(macOS)
            (view as? PlayerView_macOS)?.player = player
          #endif
        }

        #if os(iOS)
          /// On iOS, override layerClass so the view’s layer *is* an AVPlayerLayer.
          class PlayerView_iOS: AppKitOrUIKitView {
            override class var layerClass: AnyClass {
              return AVPlayerLayer.self
            }

            var player: AVPlayer? {
              get { (layer as? AVPlayerLayer)?.player }
              set { (layer as? AVPlayerLayer)?.player = newValue }
            }
          }
        #elseif os(macOS)
          /// On macOS, NSView’s `layer` is a general CALayer; so we add/remove an AVPlayerLayer sublayer manually.
          class PlayerView_macOS: AppKitOrUIKitView {
            override init(frame frameRect: CGRect) {
              super.init(frame: frameRect)
              self.wantsLayer = true
            }
            required init?(coder: NSCoder) {
              super.init(coder: coder)
              self.wantsLayer = true
            }

            var player: AVPlayer? {
              didSet {
                updatePlayerLayer()
              }
            }

            private var playerLayer: AVPlayerLayer?

            override func layout() {
              super.layout()
              playerLayer?.frame = bounds
            }

            private func updatePlayerLayer() {
              // remove old
              playerLayer?.removeFromSuperlayer()

              guard let player = player else {
                playerLayer = nil
                return
              }
              let pl = AVPlayerLayer(player: player)
              pl.frame = bounds
              pl.videoGravity = .resizeAspect
              layer?.addSublayer(pl)
              self.playerLayer = pl
            }
          }
        #endif
      }

    }

    struct LinkEmbedView: View {
      var embed: Embed

      var linkType: SpecialLinkType {
        .init(embed: embed)
      }

      @Environment(\.colorScheme) var cs

      var body: some View {
        VStack {
          switch linkType {
          case .spotifyTrack:
            spotifyTrack(linkType.embedURL(colorScheme: cs))
          case .spotifyAlbum:
            spotifyAlbum(linkType.embedURL(colorScheme: cs))
          case .appleMusicTrack:
            appleMusicTrack(linkType.embedURL(colorScheme: cs))
          case .appleMusicAlbum:
            appleMusicAlbum(linkType.embedURL(colorScheme: cs))

          case .unknown: EmbedView(embed: embed)
          }
        }
        .maxHeight(350)
      }

      @ViewBuilder
      func spotifyTrack(_ url: URL) -> some View {
        WebView(url: url) {
          ProgressView()
            .maxWidth(.infinity)
            .maxHeight(.infinity)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(350 / 80, contentMode: .fit)
        .maxWidth(350)
        .clipShape(.rect(cornerRadius: 14))
      }

      @ViewBuilder
      func spotifyAlbum(_ url: URL) -> some View {
        WebView(url: url) {
          ProgressView()
            .maxWidth(.infinity)
            .maxHeight(.infinity)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(1, contentMode: .fit)
        .maxWidth(350)
        .clipShape(.rect(cornerRadius: 14))
      }

      @ViewBuilder
      func appleMusicTrack(_ url: URL) -> some View {
        WebView(url: url) {
          ProgressView()
            .maxWidth(.infinity)
            .maxHeight(.infinity)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(660 / 170, contentMode: .fit)
        .maxWidth(550)
        .clipShape(.rect(cornerRadius: 14))
      }

      @ViewBuilder
      func appleMusicAlbum(_ url: URL) -> some View {
        WebView(url: url) {
          ProgressView()
            .maxWidth(.infinity)
            .maxHeight(.infinity)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(660 / 450, contentMode: .fit)
        .maxWidth(550)
        .clipShape(.rect(cornerRadius: 14))
      }

      enum SpecialLinkType {
        case spotifyTrack(id: String)
        case spotifyAlbum(id: String)

        case appleMusicTrack(album: String, albumID: String, trackID: String)
        case appleMusicAlbum(album: String, albumID: String)

        case unknown

        func embedURL(colorScheme: ColorScheme) -> URL {
          switch self {
          case .spotifyTrack(let id):
            URL(string: "https://open.spotify.com/embed/track/\(id)")!
          case .spotifyAlbum(let id):
            URL(string: "https://open.spotify.com/embed/album/\(id)")!
          case .appleMusicTrack(let album, let albumID, let trackID):
            URL(
              string:
                "https://embed.music.apple.com/album/\(album)/\(albumID)?i=\(trackID)&theme=\(colorScheme == .dark ? "dark":"light")"
            )!
          case .appleMusicAlbum(let album, let albumID):
            URL(
              string: "https://embed.music.apple.com/album/\(album)/\(albumID)"
            )!
          case .unknown:
            fatalError(
              "No embed URL for unknown link type, try not to use this next time."
            )
          }
        }

        init(embed: Embed) {
          guard let urlString = embed.url, let url = URL(string: urlString)
          else {
            self = .unknown
            return
          }

          // Spotify link
          if url.host?.contains("spotify.com") == true {
            let pathComponents = url.pathComponents
            if pathComponents.count >= 3 {
              let type = pathComponents[1]
              let id = pathComponents[2]
              switch type {
              case "track":
                self = .spotifyTrack(id: id)
                return
              case "album":
                self = .spotifyAlbum(id: id)
                return
              default:
                break
              }
            }
          }

          // Apple Music link
          if url.host?.contains("music.apple.com") == true {

            var parts = Array(url.pathComponents.dropFirst())  // remove initial "/"

            // Remove 2-letter country code if present
            if let first = parts.first, first.count == 2 {
              parts.removeFirst()
            }

            if let first = parts.first, first == "album" {
              parts.removeFirst()
            }

            guard parts.count >= 2 else {
              self = .unknown
              return
            }

            let album = parts[0]
            let albumID = parts[1]

            let components = URLComponents(
              url: url,
              resolvingAgainstBaseURL: false
            )
            let trackID = components?.queryItems?
              .first(where: { $0.name == "i" })?
              .value

            if let trackID {
              self = .appleMusicTrack(
                album: album,
                albumID: albumID,
                trackID: trackID
              )
            } else {
              self = .appleMusicAlbum(album: album, albumID: albumID)
            }
            return
          }

          self = .unknown
        }
      }

    }

  }
}

#Preview {
  let sampleEmbed = Embed(
    title: "151.237.41.222",
    type: .rich,
    description: "*smelly*",
    url: "https://computernewb.com/vncresolver/embed?id=28938490",
    timestamp: .now,
    color: .red,
    footer: .init(
      text: "mugmin",
      icon_url: .exact(
        "https://media.discordapp.net/stickers/1396992289544601650.png?size=320&passthrough=true"
      ),
      proxy_icon_url:
        "https://media.discordapp.net/stickers/1396992289544601650.png?size=320&passthrough=true"
    ),
    image: Embed.Media(
      url: .exact(
        "https://computernewb.com/vncresolver/api/v1/screenshot/28938490"
      ),
      proxy_url:
        "https://computernewb.com/vncresolver/api/v1/screenshot/28938490",
      height: 480,
      width: 800
    ),
    thumbnail: .init(
      url: .exact(
        "https://computernewb.com/vncresolver/api/v1/screenshot/28938490"
      ),
      proxy_url:
        "https://computernewb.com/vncresolver/api/v1/screenshot/28938490",
      height: 100,
      width: 100
    ),
    video: nil,
    provider: nil,
    author: Embed.Author(
      name: "VNC Resolver Next (BETA)",
      url: "https://computernewb.com/vncresolver-next/",
      icon_url: .exact("https://computernewb.com/favicon.ico"),
      proxy_icon_url: "https://computernewb.com/favicon.ico"
    ),
    fields: [
      Embed.Field(
        name: "Who",
        value: "AS39024 Nastech OOD",
        inline: true
      ),
      Embed.Field(
        name: "Where",
        value: "Kazanlak, Stara Zagora, :flag_bg:",
        inline: true
      ),
      Embed.Field(
        name: "How",
        value: "HMI WebServer",
        inline: true
      ),
      Embed.Field(
        name: "Password",
        value: "1",
        inline: true
      ),
    ]
  )

  ScrollView {
    MessageCell.EmbedsView.EmbedView(embed: sampleEmbed)
      .padding()
  }
  .frame(height: 600)
}

extension Date {
  func formattedShort() -> String {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .short
    return df.string(from: self)
  }
}
