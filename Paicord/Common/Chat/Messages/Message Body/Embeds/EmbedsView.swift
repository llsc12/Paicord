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
      LazyVStack(alignment: .leading, spacing: 8) {
        ForEach(embeds.combineEmbedRuns(), id: \.embed) { embed in
          EmbedRow(embedData: embed)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }

    struct EmbedRow: View {
      let embedData: (embed: Embed, items: [Embed.Media])
      var embed: Embed {
        embedData.embed
      }

      var body: some View {
        Group {
          switch embed.type {
          case .rich, .article:
            EmbedView(embed: embed)
          case .image:
            if let image = embed.image ?? embed.thumbnail {
              AttachmentsView.AttachmentSizedView(attachment: image) {
                AttachmentsView.AttachmentItemPreview(attachment: image)
              }
            }
          case .gifv:
            if let video = embed.video {
              GifvView(media: video, staticMedia: embed.image)
            }
          case .link:
            LinkEmbedView(embed: embed, items: embedData.items)
          default:
            Text("Unsupported embed type: \(embed.type)")
          }
        }
        .debugRender()
        .debugCompute()
      }
    }

    struct EmbedView: View {
      let embed: Embed
      let items: [Embed.Media]

      init(embed: Embed, items: [Embed.Media] = []) {
        self.embed = embed
        self.items = items
      }

      @Environment(\.userInterfaceIdiom) var idiom
      @Environment(\.channelStore) var channelStore
      @Environment(\.theme) var theme

      private var embedWidth: CGFloat {
        switch idiom {
        case .phone:
          return 345
        default:
          return 425
        }
      }

      private var authorIconURL: URL? {
        if let icon = embed.author?.proxy_icon_url,
          let url = URL(string: icon)
        {
          return url
        } else if let icon = embed.author?.icon_url,
          let url = URL(string: icon.asString)
        {
          return url
        }
        return nil
      }

      private var thumbnailURL: URL? {
        if let thumb = embed.thumbnail?.proxyurl, let url = URL(string: thumb) {
          return url
        }
        return nil
      }

      private var footerIconURL: URL? {
        if let icon = embed.footer?.proxy_icon_url,
          let url = URL(string: icon)
        {
          return url
        } else if let icon = embed.footer?.icon_url,
          let url = URL(string: icon.asString)
        {
          return url
        }
        return nil
      }

      private var leftStripeColor: Color {
        if let color = embed.color?.asColor() { return color }
        return Color(hexadecimal6: 0x202225)
      }

      private func columns(forInlineCount count: Int) -> [GridItem] {
        let num = max(1, min(3, count))
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: num)
      }

      var body: some View {
        HStack(spacing: 0) {
          leftStripeColor
            .frame(width: 4)
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
              VStack(alignment: .leading, spacing: 6) {
                if let author = embed.author {
                  HStack(spacing: 8) {
                    if let url = authorIconURL {
                      AnimatedImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Circle())
                        .frame(width: 20, height: 20)
                    }
                    Text(author.name)
                      .font(.caption)
                      .lineLimit(1)
                  }
                }

                if let title = embed.title {
                  if let link = embed.url, let url = URL(string: link) {
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
              .padding(.trailing, thumbnailURL == nil ? 40 : 0)

              if embed.type != .article, let thumbURL = thumbnailURL {
                AnimatedImage(url: thumbURL)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 72, height: 72)
                  .clipped()
                  .cornerRadius(6)
              }
            }

            if let fields = embed.fields, !fields.isEmpty {
              let inlineFields = fields.filter { $0.inline ?? false }
              let blockFields = fields.filter { ($0.inline ?? false) == false }

              VStack(alignment: .leading, spacing: 8) {
                if !inlineFields.isEmpty {
                  LazyVGrid(
                    columns: columns(forInlineCount: inlineFields.count),
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
                  }
                }
              }
            }

            if !items.isEmpty {
              images
            } else if let image = embed.image {
              AttachmentsView.AttachmentSizedView(attachment: image) {
                AttachmentsView.AttachmentItemPreview(attachment: image)
              }
            }

            if embed.footer != nil || embed.timestamp != nil {
              HStack(spacing: 6) {
                if let footer = embed.footer {
                  HStack(spacing: 6) {
                    if let url = footerIconURL {
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

                if embed.footer != nil && embed.timestamp != nil { Text("•") }

                if let ts = embed.timestamp {
                  Text(ts.date.formattedShort())
                    .font(.subheadline)
                }

                Spacer()
              }
            }
          }
          .padding(8)
          .frame(maxWidth: embedWidth, alignment: .leading)
          .background(theme.common.tertiaryBackground)

        }
        .clipShape(.rounded)
      }

      @ViewBuilder var images: some View {
        switch items.count {
        case 0: EmptyView()
        case 1:
          AttachmentsView.AttachmentSizedView(attachment: items[0]) {
            AttachmentsView.AttachmentItemPreview(attachment: items[0])
          }
          .clipShape(.rounded)  
        case 2:
          HStack(spacing: 4) {
            ForEach(items.prefix(2), id: \.hashValue) { item in
              AttachmentsView.AttachmentItemPreview(attachment: item)
                .scaledToFill()
                .clipShape(.rect(cornerRadius: 4))
            }
          }
          .clipShape(.rounded)
        case 3:
          HStack(spacing: 4) {
            if let item = items.first {
              Color.almostClear
                .overlay {
                  AttachmentsView.AttachmentItemPreview(attachment: item)
                    .scaledToFill()
                }
                .clipShape(.rect(cornerRadius: 4))
            }

            VStack(spacing: 4) {
              ForEach(items.suffix(2), id: \.hashValue) { item in
                Color.almostClear
                  .overlay {
                    AttachmentsView.AttachmentItemPreview(attachment: item)
                      .scaledToFill()
                  }
                  .aspectRatio(1.6, contentMode: .fit)
                  .clipShape(.rect(cornerRadius: 4))
              }
            }
          }
          .clipShape(.rounded)
        default:
          VStack(spacing: 4) {
            HStack(spacing: 4) {
              ForEach(items.prefix(2), id: \.hashValue) { item in
                Color.almostClear
                  .overlay {
                    AttachmentsView.AttachmentItemPreview(attachment: item)
                      .scaledToFill()
                  }
                  .aspectRatio(1.6, contentMode: .fit)
                  .clipShape(.rounded)
              }
            }

            HStack(spacing: 4) {
              ForEach(items.suffix(2), id: \.hashValue) { item in
                Color.almostClear
                  .overlay {
                    AttachmentsView.AttachmentItemPreview(attachment: item)
                      .scaledToFill()
                  }
                  .aspectRatio(1.6, contentMode: .fit)
                  .clipShape(.rect(cornerRadius: 4))
              }
            }
          }
          .clipShape(.rounded)
        }
      }

    }

    struct GifvView: View {
      @State private var controller: PlayerController
      private let media: Embed.Media
      private let staticMedia: Embed.Media?

      private let maxWidth: CGFloat = 500
      private let maxHeight: CGFloat = 300

      init(media: Embed.Media, staticMedia: Embed.Media? = nil) {
        self.media = media
        self.staticMedia = staticMedia
        _controller = State(initialValue: PlayerController(media: media))
      }

      var body: some View {
        AVPlayerLayerContainer(player: controller.player)
          .aspectRatio(media.aspectRatio, contentMode: .fit)
          .clipShape(.rounded)
          .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .leading)
          .onAppear { controller.play() }
          .onDisappear { controller.pauseAndReset() }
      }

      @Observable
      final class PlayerController {
        let player: AVPlayer
        private var observerToken: Any?

        init(media: Embed.Media) {
          guard let url = URL(string: media.proxyurl)
          else {
            self.player = AVPlayer()
            return
          }
          let item = AVPlayerItem(asset: AVAsset(url: url))
          self.player = AVPlayer(playerItem: item)

          observerToken = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
          ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
          }
        }

        deinit {
          if let o = observerToken {
            NotificationCenter.default.removeObserver(o)
          }
          player.pause()
        }

        func play() { player.play() }
        func pauseAndReset() {
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
          class PlayerView_iOS: AppKitOrUIKitView {
            override class var layerClass: AnyClass { AVPlayerLayer.self }
            var player: AVPlayer? {
              get { (layer as? AVPlayerLayer)?.player }
              set { (layer as? AVPlayerLayer)?.player = newValue }
            }
          }
        #elseif os(macOS)
          class PlayerView_macOS: AppKitOrUIKitView {
            override init(frame frameRect: CGRect) {
              super.init(frame: frameRect)
              wantsLayer = true
            }
            required init?(coder: NSCoder) {
              super.init(coder: coder)
              wantsLayer = true
            }

            var player: AVPlayer? {
              didSet { updatePlayerLayer() }
            }

            private var playerLayer: AVPlayerLayer?

            override func layout() {
              super.layout()
              playerLayer?.frame = bounds
            }

            private func updatePlayerLayer() {
              playerLayer?.removeFromSuperlayer()
              guard let player = player else {
                playerLayer = nil
                return
              }
              let pl = AVPlayerLayer(player: player)
              pl.frame = bounds
              pl.videoGravity = .resizeAspect
              layer?.addSublayer(pl)
              playerLayer = pl
            }
          }
        #endif
      }
    }

    struct LinkEmbedView: View {
      var embed: Embed
      var items: [Embed.Media] = []

      var linkType: SpecialLinkType { .init(embed: embed) }

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
          case .unknown:
            EmbedView(embed: embed, items: items)
          }
        }
        .frame(maxHeight: 350)
      }

      @ViewBuilder
      func spotifyTrack(_ url: URL) -> some View {
        WebView(url: url) {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(350 / 80, contentMode: .fit)
        .frame(maxWidth: 350)
        .clipShape(RoundedRectangle(cornerRadius: 14))
      }

      @ViewBuilder
      func spotifyAlbum(_ url: URL) -> some View {
        WebView(url: url) {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 350)
        .clipShape(RoundedRectangle(cornerRadius: 14))
      }

      @ViewBuilder
      func appleMusicTrack(_ url: URL) -> some View {
        WebView(url: url) {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(660 / 170, contentMode: .fit)
        .frame(maxWidth: 550)
        .clipShape(RoundedRectangle(cornerRadius: 14))
      }

      @ViewBuilder
      func appleMusicAlbum(_ url: URL) -> some View {
        WebView(url: url) {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(660 / 450, contentMode: .fit)
        .frame(maxWidth: 550)
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
            return URL(string: "https://open.spotify.com/embed/track/\(id)")!
          case .spotifyAlbum(let id):
            return URL(string: "https://open.spotify.com/embed/album/\(id)")!
          case .appleMusicTrack(let album, let albumID, let trackID):
            return URL(
              string:
                "https://embed.music.apple.com/album/\(album)/\(albumID)?i=\(trackID)&theme=\(colorScheme == .dark ? "dark":"light")"
            )!
          case .appleMusicAlbum(let album, let albumID):
            return URL(
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

          // Spotify
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
              default: break
              }
            }
          }

          // Apple Music
          if url.host?.contains("music.apple.com") == true {
            var parts = Array(url.pathComponents.dropFirst())  // drop leading "/"
            if let first = parts.first, first.count == 2 { parts.removeFirst() }  // country code
            if let first = parts.first, first == "album" { parts.removeFirst() }
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
            let trackID = components?.queryItems?.first(where: {
              $0.name == "i"
            })?.value
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
      width: 800,
      height: 480,
      placeholder: nil,
      content_type: "image/png"
    ),
    thumbnail: .init(
      url: .exact(
        "https://computernewb.com/vncresolver/api/v1/screenshot/28938490"
      ),
      proxy_url:
        "https://computernewb.com/vncresolver/api/v1/screenshot/28938490",
      width: 100,
      height: 100,
      placeholder: nil,
      content_type: nil
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
  let githubEmbed = Embed(
    title:
      "GitHub - paigely/Navic: Navidrome client app for Android and iOS wi...",
    type: .article,
    description:
      "Navidrome client app for Android and iOS with Material 3 Expressive design - paigely/Navic",
    url: "https://github.com/paigely/navic",
    timestamp: nil,
    color: .mint,
    footer: nil,
    image: .init(
      url: .exact(
        "https://repository-images.githubusercontent.com/1126374551/8d14cb32-ef0e-4eac-ae32-1289702e8fac"
      ),
      proxy_url:
        "https://images-ext-1.discordapp.net/external/kHB2MhpEpm8vjvTPasbNwLiKKSwEj8kO2bIQpJY6dKA/https/repository-images.githubusercontent.com/1126374551/8d14cb32-ef0e-4eac-ae32-1289702e8fac",
      width: 1588,
      height: 794,
      placeholder: "DfgFDIAZWaiTaWiAe1sBlZj6dQ==",
      content_type: "image/png"
    ),
    thumbnail: nil,
    video: nil,
    provider: .init(name: "GitHub", url: nil),
    author: nil,
    fields: nil
  )

  let multiImagesEmbed: [Embed] = [
    .init(
      title: "Youtube downloader tool - Fastesttube!",
      type: .link,
      description:
        "Youtube fastesttube downloader will make your internet expirience faster harder beter stronger.",
      url: "https://kwizzu.com/",
      timestamp: nil,
      color: nil,
      footer: nil,
      image: .init(
        url: .exact("http://kwizzu.com/img/og_images/safari.jpg"),
        proxy_url:
          "https://images-ext-1.discordapp.net/external/4-JCkigetiYC_d9JQPgWi_CQ0WC-SKlE9XSQX-KgyA4/http/kwizzu.com/img/og_images/safari.jpg",
        width: 254,
        height: 254,
        placeholder: "MccJJwjot5eKd3d/h4V3mHd3eK/393sP",
        content_type: "image/jpeg"
      ),
      thumbnail: nil,
      video: nil,
      provider: nil,
      author: nil,
      fields: nil
    ),
    .init(
      title: nil,
      type: .rich,
      description: nil,
      url: "https://kwizzu.com/",
      timestamp: nil,
      color: nil,
      footer: nil,
      image: .init(
        url: .exact("http://kwizzu.com/img/og_images/chrome.jpg"),
        proxy_url:
          "https://images-ext-1.discordapp.net/external/MgVI1VquJAhYTmdFAA83YXyzJG4yw2IWllbyIrRR0Ys/http/kwizzu.com/img/og_images/chrome.jpg",
        width: 254,
        height: 254,
        placeholder: "bAkOLw71uaiJd4ifeHaHuFd3CnhZc58M",
        content_type: "image/jpeg"
      ),
      thumbnail: nil,
      video: nil,
      provider: nil,
      author: nil,
      fields: nil
    ),
    .init(
      title: nil,
      type: .rich,
      description: nil,
      url: "https://kwizzu.com/",
      timestamp: nil,
      color: nil,
      footer: nil,
      image: .init(
        url: .exact("http://kwizzu.com/img/og_images/firefox.jpg"),
        proxy_url:
          "https://images-ext-1.discordapp.net/external/u72B1u6S7la3q13xEZw_BhbwoLfdSM8jyl6dmT7hnUo/http/kwizzu.com/img/og_images/firefox.jpg",
        width: 254,
        height: 254,
        placeholder: "6jgSLw73p4l5d4eOh3Z4qGiIqQwZm4AE",
        content_type: "image/jpeg"
      ),
      thumbnail: nil,
      video: nil,
      provider: nil,
      author: nil,
      fields: nil
    ),
    .init(
      title: nil,
      type: .rich,
      description: nil,
      url: "https://kwizzu.com/",
      timestamp: nil,
      color: nil,
      footer: nil,
      image: .init(
        url: .exact("http://kwizzu.com/img/og_images/install.jpg"),
        proxy_url:
          "https://images-ext-1.discordapp.net/external/txsq-4DfejuwkeMifer_3NYBIgxDiYSMOxVpzceL_7E/http/kwizzu.com/img/og_images/install.jpg",
        width: 254,
        height: 254,
        placeholder: "eCkOVwqIiIh4d3d/d2eIOIh5eXcId4c",
        content_type: "image/jpeg"
      ),
      thumbnail: nil,
      video: nil,
      provider: nil,
      author: nil,
      fields: nil
    ),
  ]

  let threeImagesEmbed: [Embed] = [
    .init(
      title: "Youtube downloader tool - a!",
      type: .link,
      description:
        "Youtube fastesttube downloader will make your internet expirience faster harder beter stronger.",
      url: "https://a.com/",
      timestamp: nil,
      color: nil,
      footer: nil,
      image: .init(
        url: .exact("http://kwizzu.com/img/og_images/safari.jpg"),
        proxy_url:
          "https://images-ext-1.discordapp.net/external/4-JCkigetiYC_d9JQPgWi_CQ0WC-SKlE9XSQX-KgyA4/http/kwizzu.com/img/og_images/safari.jpg",
        width: 254,
        height: 254,
        placeholder: "MccJJwjot5eKd3d/h4V3mHd3eK/393sP",
        content_type: "image/jpeg"
      ),
      thumbnail: nil,
      video: nil,
      provider: nil,
      author: nil,
      fields: nil
    ),
    .init(
      title: nil,
      type: .rich,
      description: nil,
      url: "https://a.com/",
      timestamp: nil,
      color: nil,
      footer: nil,
      image: .init(
        url: .exact("http://kwizzu.com/img/og_images/chrome.jpg"),
        proxy_url:
          "https://images-ext-1.discordapp.net/external/MgVI1VquJAhYTmdFAA83YXyzJG4yw2IWllbyIrRR0Ys/http/kwizzu.com/img/og_images/chrome.jpg",
        width: 254,
        height: 254,
        placeholder: "bAkOLw71uaiJd4ifeHaHuFd3CnhZc58M",
        content_type: "image/jpeg"
      ),
      thumbnail: nil,
      video: nil,
      provider: nil,
      author: nil,
      fields: nil
    ),
    .init(
      title: nil,
      type: .rich,
      description: nil,
      url: "https://a.com/",
      timestamp: nil,
      color: nil,
      footer: nil,
      image: .init(
        url: .exact("http://kwizzu.com/img/og_images/firefox.jpg"),
        proxy_url:
          "https://images-ext-1.discordapp.net/external/u72B1u6S7la3q13xEZw_BhbwoLfdSM8jyl6dmT7hnUo/http/kwizzu.com/img/og_images/firefox.jpg",
        width: 254,
        height: 254,
        placeholder: "6jgSLw73p4l5d4eOh3Z4qGiIqQwZm4AE",
        content_type: "image/jpeg"
      ),
      thumbnail: nil,
      video: nil,
      provider: nil,
      author: nil,
      fields: nil
    ),
  ]

  ScrollView {
    MessageCell.EmbedsView.init(
      embeds: [sampleEmbed, githubEmbed] + threeImagesEmbed + multiImagesEmbed
    )
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

extension [Embed] {
  /// Reads the embeds, combines into tuples grouping embeds with multiple images.
  /// - Returns: An array of tuples, where each tuple contains an `Embed` and an array of `Embed.Media` objects that are associated with that embed.
  func combineEmbedRuns() -> [(embed: Embed, items: [Embed.Media])] {
    var combined = [(embed: Embed, items: [Embed.Media])]()
    for embed in self {
      // ensure type is rich, url is the same as focused embed, has image. every other field nil. else add embed as new entry.
      if let currentEmbedFocused = combined.last?.embed,  // 2nd embed or later.
        currentEmbedFocused.type == .link,
        embed.type == .rich,
        let image = embed.image,
        embed.url == currentEmbedFocused.url,
        embed.author == nil,
        embed.description == nil,
        embed.fields == nil,
        embed.footer == nil,
        embed.provider == nil,
        embed.thumbnail == nil,
        embed.video == nil
      {
        combined[combined.count - 1].items.append(image)
      } else {
        // first embed.
        let items = embed.image.map { [$0] } ?? []
        combined.append((embed: embed, items: items))
      }
    }
    return combined
  }
}
