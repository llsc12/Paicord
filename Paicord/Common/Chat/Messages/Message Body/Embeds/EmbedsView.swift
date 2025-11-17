//
//  EmbedsView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 21/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import AVKit
import Foundation
import PaicordLib
import SDWebImageSwiftUI
import SwiftPrettyPrint
import SwiftUIX

extension MessageCell {
  struct EmbedsView: View {
    var embeds: [Embed]

    var body: some View {
      #warning(
        "redo this to support all embed types properly, eg gifs, embeds with multiple images."
      )
      ForEach(embeds) { embed in
        switch embed.type {
        case .rich, .article:
          EmbedView(embed: embed)
        case .image:
          if let image = embed.image ?? embed.thumbnail,
            let url = URL(string: image.proxyurl)
          {
            let aspectRatio: CGFloat? = {
              if let width = image.width, let height = image.height {
                return width.toCGFloat / height.toCGFloat
              } else {
                return nil
              }
            }()
            WebImage(url: url)
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
          }
        case .gifv:
          if let video = embed.video {
            GifvView(media: video, staticMedia: embed.image)
          }
        default:
          Text("Unsupported embed type: \(embed.type)")
        }
      }
    }

    struct EmbedView: View {
      var embed: Embed

      @Environment(\.userInterfaceIdiom) var idiom
      @Environment(\.channelStore) var channelStore

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
                    WebImage(url: url) {
                      if case .success(let image) = $0 {
                        image
                          .resizable()
                          .scaledToFit()
                          .clipShape(.circle)
                          .frame(width: 20, height: 20)
                      } else {
                        Circle()
                          .fill(Color.gray.opacity(0.15))
                          .frame(width: 20, height: 20)
                      }
                    }

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
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                }
              }

              if let desc = embed.description {
                MarkdownText(content: desc, channelStore: channelStore)
              }
            }

            if let thumb = embed.thumbnail?.proxy_url,
              let url = URL(string: thumb)
            {
              WebImage(url: url)
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
            WebImage(url: url)
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
                    WebImage(url: url)
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
        .background(Color(hexadecimal6: 0x2b2d31))
        .clipShape(.rect(cornerRadius: 5))
      }
    }

    struct GifvView: View {
      var media: Embed.Media
      var staticMedia: Embed.Media? = nil  // soon, to use as poster
      private var player: AVQueuePlayer
      private var playerLooper: AVPlayerLooper

      init(media: Embed.Media, staticMedia: Embed.Media? = nil) {
        self.media = media
        self.staticMedia = staticMedia
        let sourceURL = URL(string: media.proxyurl)!
        let asset = AVAsset(url: sourceURL)
        let item: AVPlayerItem = .init(asset: asset)
        self.player = .init(playerItem: item)
        self.playerLooper = .init(player: player, templateItem: item)
      }
      var body: some View {
        let aspectRatio: CGFloat? = {
          if let width = media.width, let height = media.height {
            return width.toCGFloat / height.toCGFloat
          } else {
            return nil
          }
        }()
        AVPlayerLayerContainer(player: player)
          .clipShape(.rounded)
          .aspectRatio(aspectRatio, contentMode: .fit)
          .frame(
            minWidth: 1,
            maxWidth: min(media.width?.toCGFloat, 400),
            minHeight: 1,
            maxHeight: min(media.height?.toCGFloat, 300),
            alignment: .leading
          )
          .onAppear {
            player.play()
          }
          .onDisappear {
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

          func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
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
