//
//  Attachments.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import AVKit
import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX
import Loupe

extension MessageCell {
  struct AttachmentsView: View {

    var fileAttachments: [DiscordChannel.Message.Attachment]

    var previewableAttachments: [DiscordChannel.Message.Attachment]

    init(attachments: [DiscordChannel.Message.Attachment]) {
      var previews: [DiscordChannel.Message.Attachment] = []
      var files: [DiscordChannel.Message.Attachment] = []
      for att in attachments {
        if let type = UTType(mimeType: att.content_type ?? ""),
          AttachmentGridItemPreview.supportedTypes.contains(type)
        {
          previews.append(att)
        } else {
          files.append(att)
        }
      }
      self.previewableAttachments = previews
      self.fileAttachments = files
    }

    @AppStorage("Paicord.Chat.Attachments.ShowMosaic") var showMosaic: Bool =
      false

    private let maxMosaicWidth: CGFloat = 500
    private let tileSpacing: CGFloat = 2

    var body: some View {
      VStack(alignment: .leading) {
        if showMosaic {
            VStack(alignment: .leading, spacing: 0) {
              mosaic
            }
        } else {
          // show as list
          list
        }

        // files
        ForEach(fileAttachments) { file in
          FileAttachmentView(attachment: file)
            .debugRender()
            .debugCompute()
        }
      }
    }

    // MARK: - Layouts

    @ViewBuilder
    var mosaic: some View {
        list
    }

    @ViewBuilder
    var list: some View {
      ForEach(previewableAttachments) { attachment in
        AttachmentSizedView(attachment: attachment) {
          AttachmentGridItemPreview(
            attachment: attachment
          )
        }
        .debugRender()
        .debugCompute()
      }
    }

    /// Designed to ensure attachments have a deterministic size, not using maxWidth/maxHeight
    struct AttachmentSizedView<Content: View>: View {
      let attachment: DiscordMedia
      let content: Content

      init(
        attachment: DiscordMedia,
        @ViewBuilder content: () -> Content
      ) {
        self.attachment = attachment
        self.content = content()
      }

      private let maxWidth: CGFloat = 500
      private let maxHeight: CGFloat = 300

      var body: some View {
        content
          .aspectRatio(attachment.aspectRatio, contentMode: .fit)
          .clipShape(.rounded)
          .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
      }
    }


    /// Handles images, videos
    struct AttachmentGridItemPreview: View {
      static let supportedTypes: [UTType] = [
        .png,
        .jpeg,
        .gif,
        .webP,
        .mpeg4Movie,
        .quickTimeMovie,
      ]

      var attachment: DiscordMedia

      var body: some View {
        switch attachment.type {
        case .png, .jpeg, .jpeg, .webP, .gif:
          ImageView(attachment: attachment)
        case .mpeg4Movie, .quickTimeMovie:
          VideoView(attachment: attachment)
        default:
          Text("\(attachment.type) unsupported")
        }
      }

      // preview for image
      struct ImageView: View {
        var attachment: DiscordMedia
        var body: some View {
          AnimatedImage(url: URL(string: attachment.proxyurl)) {
            if let placeholder = attachment.placeholder,
              let data = Data(base64Encoded: placeholder)
            {
              let img = thumbHashToImage(hash: data)
              #if os(macOS)
                Image(nsImage: img)
                  .resizable()
              #else
                Image(uiImage: img)
                  .resizable()
              #endif
            } else {
              Color.gray.opacity(0.2)
            }

          }
          .resizable()
        }
      }

      struct VideoView: View {
        var attachment: DiscordMedia
        @State var wantsPlayback: Bool = false

        var poster: URL {
          let url = URL(string: attachment.proxyurl)!
          var urlcomponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
          )!
          // replace host with media.discordapp.net
          urlcomponents.host = "media.discordapp.net"
          // add query parameter "format=png" to get poster image
          urlcomponents.queryItems =
            (urlcomponents.queryItems ?? []) + [
              URLQueryItem(name: "format", value: "png")
            ]
          return urlcomponents.url!
        }
        var body: some View {
          if !wantsPlayback {
            WebImage(url: poster)
              .resizable()
              .scaledToFill()
              .overlay(
                Button {
                  wantsPlayback = true
                  #if os(iOS)
                    try? AVAudioSession.sharedInstance().setCategory(.playback)
                  #endif
                } label: {
                  Image(systemName: "play.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(.circle)
                    .frame(width: 64, height: 64)
                }
                .buttonStyle(.borderless)
              )
              .clipped()
          } else {
            VideoPlayerView(attachment: attachment)
          }
        }

        struct VideoPlayerView: View {
          var attachment: DiscordMedia
          var player: AVPlayer

          init(attachment: DiscordMedia) {
            self.attachment = attachment
            self.player = AVPlayer(
              url: URL(string: attachment.proxyurl)!
            )

            // Auto-play
            self.player.play()
          }

          var body: some View {
            VideoPlayer(player: player)
          }
        }

      }
    }

    struct FileAttachmentView: View {
      @Environment(\.theme) var theme
      var attachment: DiscordChannel.Message.Attachment
      var body: some View {
        HStack {
          Image(systemName: "document.fill")
            .imageScale(.large)

          VStack(alignment: .leading) {
            Text(attachment.filename)
              .font(.headline)
            if let description = attachment.description {
              Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Text(
              ByteCountFormatter.string(
                fromByteCount: Int64(attachment.size),
                countStyle: .file
              )
            )
            .font(.caption)
            .foregroundStyle(.tertiary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)

          Button {
          } label: {
            Label("Download", systemImage: "arrow.down.circle")
          }
        }
        .padding()
        .background(
          theme.common.primaryButtonBackground.brightness(0.2)
            .mask {
              RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white, lineWidth: 1)
                .foregroundStyle(.clear)
            }
        )
        .background(theme.common.primaryButtonBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .frame(maxWidth: 400, alignment: .leading)
      }
    }
  }
}

#Preview {
  MessageCell.AttachmentsView(attachments: [
    .init(
      id: try! .makeFake(),
      filename: "meow.zip",
      description: "A zip file containing meow files",
      content_type: "application/zip",
      size: 137 * 1024 * 1024 * 1024 * 1024 * 1024,
      url: "https://example.com/meow.zip",
      proxy_url: "https://proxy.example.com/meow.zip"
    ),
    .init(
      id: .init("1426713358039646248"),
      filename: "image.png",
      description: nil,
      content_type: "image/png",
      size: 42341,
      url:
        "https://cdn.discordapp.com/attachments/1026504914131759104/1426713358039646248/image.png?ex=68ec39db&is=68eae85b&hm=85919b31ac64dcabbb8c8c8afcecb1faac3ab8bb8d1ab8198c33341a35891bb6&",
      proxy_url:
        "https://media.discordapp.net/attachments/1026504914131759104/1426713358039646248/image.png?ex=68ec39db&is=68eae85b&hm=85919b31ac64dcabbb8c8c8afcecb1faac3ab8bb8d1ab8198c33341a35891bb6&",
      placeholder: "0fcFA4ComJiJd/hnV3pwhQc=",
      height: 428,
      width: 888,
      ephemeral: nil,
      duration_secs: nil,
      waveform: nil,
      flags: nil
    ),
  ])
  .padding()
}

extension DiscordMedia {
  var type: UTType {
    if let mimeType = content_type, let type = UTType(mimeType: mimeType) {
      return type
    } else {
      return .data
    }
  }

  var aspectRatio: CGFloat? {
    if let width = self.width, let height = self.height {
      return width.toCGFloat / height.toCGFloat
    } else {
      return nil
    }
  }
}
