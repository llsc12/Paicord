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

extension MessageCell {
  struct AttachmentsView: View {

    var fileAttachments: [DiscordChannel.Message.Attachment]

    var previewableAttachments: [DiscordChannel.Message.Attachment]

    init(attachments: [DiscordChannel.Message.Attachment]) {
      var previews: [DiscordChannel.Message.Attachment] = []
      for att in attachments {
        if AttachmentGridItemPreview.supportedTypes.contains(
          att.content_type ?? ""
        ) {
          previews.append(att)
        }
      }
      self.previewableAttachments = previews

      var files: [DiscordChannel.Message.Attachment] = []
      for att in attachments {
        if !AttachmentGridItemPreview.supportedTypes.contains(
          att.content_type ?? ""
        ) {
          files.append(att)
        }
      }
      self.fileAttachments = files
    }

    var body: some View {
      VStack(alignment: .leading) {
        // previews
        switch previewableAttachments.count {
        case 1:
          let attachment = previewableAttachments[0]
          let aspectRatio: CGFloat? = {
            if let width = attachment.width, let height = attachment.height {
              return width.toCGFloat / height.toCGFloat
            } else {
              return nil
            }
          }()
          AttachmentGridItemPreview(
            attachment: attachment
          )
          .clipShape(.rounded)
          .aspectRatio(aspectRatio, contentMode: .fit)
          .frame(
            minWidth: 1,
            maxWidth: min(attachment.width?.toCGFloat, 400),
            minHeight: 1,
            maxHeight: min(attachment.height?.toCGFloat, 300),
            alignment: .leading
          )
        //					case
        default: EmptyView()
        }
        // files
        ForEach(fileAttachments, id: \.self) { file in
          FileAttachmentView(attachment: file)
        }
      }
      .frame(
        minWidth: 1,
        maxWidth: (350),
        minHeight: 1,
        maxHeight: 400,
        alignment: .leading
      )
    }

    // MARK: - Layouts

    // MARK: - Helper views

    /// Handles images, videos
    struct AttachmentGridItemPreview: View {
      static let supportedTypes: [String] = [
        "image/png",
        "image/jpeg",
        "image/jpg",
        "image/gif",
        "image/webp", 
        "video/mp4",
        "video/quicktime",
      ]

      var attachment: DiscordMedia

      var body: some View {
        switch attachment.content_type {
        case "image/png", "image/jpeg", "image/jpg", "image/webp", "image/gif":
          ImageView(attachment: attachment)

        case "video/mp4", "video/quicktime":
          VideoView(attachment: attachment)
        default:
          Text("mime type \(attachment.content_type ?? "unknown") unsupported")
        }
      }

      // preview for image
      struct ImageView: View {
        var attachment: DiscordMedia
        var body: some View {
          WebImage(url: URL(string: attachment.proxyurl)) {
            phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
            default:
              if let placeholder = attachment.placeholder,
                let data = Data(base64Encoded: placeholder)
              {
                let img = thumbHashToImage(hash: data)
                #if os(macOS)
                  Image(nsImage: img)
                    .resizable()
                    .scaledToFill()
                #else
                  Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                #endif
              } else {
                Color.gray.opacity(0.2)
              }
            }
          }
          .scaledToFit()
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
              .scaledToFit()
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
          Color.primaryButtonBackground.brightness(0.2)
            .mask {
              RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white, lineWidth: 1)
                .foregroundStyle(.clear)
            }
        )
        .background(.primaryButtonBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
