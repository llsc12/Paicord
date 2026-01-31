//
//  Attachments.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import AVKit
import Loupe
import PaicordLib
import SDWebImageSwiftUI
import Speech
import SwiftUIX

#if canImport(AppKit)
  import AppKit
#endif

extension MessageCell {
  struct AttachmentsView: View {

    var previewableAttachments: [DiscordChannel.Message.Attachment] = []
    var audioAttachments: [DiscordChannel.Message.Attachment] = []
    var fileAttachments: [DiscordChannel.Message.Attachment] = []

    init(attachments: [DiscordChannel.Message.Attachment]) {
      for att in attachments {
        if let type = UTType(mimeType: att.content_type ?? ""),
          AttachmentGridItemPreview.supportedTypes.contains(type)
        {
          previewableAttachments.append(att)
        } else if let type = UTType(mimeType: att.content_type ?? ""),
          AttachmentAudioPlayer.supportedTypes.contains(type)
        {
          audioAttachments.append(att)
        } else {
          fileAttachments.append(att)
        }
      }
    }

    @AppStorage("Paicord.Chat.Attachments.ShowMosaic") var showMosaic: Bool =
      false

    private let maxMosaicWidth: CGFloat = 500
    private let tileSpacing: CGFloat = 2

    var body: some View {
      VStack(alignment: .leading) {
        // previewable
        if showMosaic {
          VStack(alignment: .leading, spacing: 0) {
            mosaic
          }
        } else {
          // show as list
          list
        }

        // audio files
        ForEach(audioAttachments) { audio in
          AttachmentAudioPlayer(attachment: audio)
            .debugRender()
            .debugCompute()
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

    struct AttachmentAudioPlayer: View {
      static let supportedTypes: [UTType] = [
        .mp3,
        .mpeg4Audio,
        .init(mimeType: "audio/wav", conformingTo: .audio)!,
        .init(mimeType: "audio/flac", conformingTo: .audio)!,
        .init(mimeType: "audio/ogg", conformingTo: .audio)!,
      ]

      @Environment(\.theme) var theme
      var attachment: DiscordChannel.Message.Attachment
      var player: AVPlayer

      init(attachment: DiscordChannel.Message.Attachment) {
        self.attachment = attachment
        let audioURL = URL(string: attachment.url)!
        self.player = AVPlayer(url: audioURL)
        self._waveform = .init(
          initialValue: .init(repeating: 0.01, count: sampleCount)
        )
      }

      @State var duration: CMTime? = nil
      @State var currentTime: CMTime = .zero
      @State var isPlaying: Bool = false

      private var sampleCount: Int { 30 }
      @State private var waveform: [Float] = []

      var body: some View {
        HStack {
          Button {
            if isPlaying {
              #if os(iOS)
                try? AVAudioSession.sharedInstance().setActive(false)
              #endif
              player.pause()
              isPlaying = false
            } else {
              #if os(iOS)
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                try? AVAudioSession.sharedInstance().setActive(true)
              #endif
              player.play()
              isPlaying = true
            }
          } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
          }
          .buttonStyle(.borderedProminent)
          .buttonBorderShape(.circle)
          .controlSize(.large)

          WaveformView(
            waveform: waveform,
            progress: duration != nil
              ? CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration!)
              : 0,
            onSeek: {
              player.seek(
                to: CMTime(
                  seconds: (duration != nil
                    ? CMTimeGetSeconds(duration!) * $0
                    : 0),
                  preferredTimescale: 600
                )
              )
            }
          )

          transcriptButton

          if let duration {
            let remainingTime = duration - currentTime
            Text(
              String(
                format: "%02d:%02d",
                Int(CMTimeGetSeconds(remainingTime)) / 60,
                Int(CMTimeGetSeconds(remainingTime)) % 60
              )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
          } else {
            ProgressView()
              .scaleEffect(0.4)
              .frame(width: 10, height: 10)
          }
        }
        .padding(.small)
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
        .task {
          do {
            let duration = try await player.currentItem?.asset.load(.duration)
            self.duration = duration
          } catch {
            print("Failed to load audio duration: \(error)")
          }
          // observe time updates
          player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
          ) { time in
            self.currentTime = time
          }
          // observe end of playback
          NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
          ) { _ in
            self.isPlaying = false
            self.currentTime = .zero
            player.seek(to: .zero)
            #if os(iOS)
              try? AVAudioSession.sharedInstance().setActive(false)
            #endif
          }
        }  // load player
        .task {
          let url = URL(string: attachment.url)!

          do {
            waveform = try await WaveformExtractor.extract(
              from: url,
              samplesCount: sampleCount
            )
          } catch {
            print("Waveform failed:", error)
          }
        }  // load waveform
      }

      static var transcriptCache: [URL: String] = [:]
      @ViewStorage var transcript: String? = nil
      @State var showingTranscript: Bool = false

      @ViewBuilder
      var transcriptButton: some View {
        DownloadButton { proxy in
          if let cached = AttachmentAudioPlayer.transcriptCache[
            URL(string: attachment.url)!
          ] {
            return cached
          }

          typealias DownloadProxyType = DownloadButton<String>.DownloadProxy
          // get speech recognition permission
          let status = await SFSpeechRecognizer.requestAuthorization()
          guard status == .authorized else {
            throw "Speech recognition permission denied."
          }

          // set up session delegate to track progress
          final class SessionDelegate: NSObject, URLSessionDownloadDelegate {
            let proxy: DownloadProxyType
            nonisolated(unsafe) var continuation:
              CheckedContinuation<String, Error>?

            func urlSession(
              _ session: URLSession,
              downloadTask: URLSessionDownloadTask,
              didFinishDownloadingTo location: URL
            ) {
              continuation?.resume(returning: location.path)
            }

            func urlSession(
              _ session: URLSession,
              downloadTask: URLSessionDownloadTask,
              didWriteData bytesWritten: Int64,
              totalBytesWritten: Int64,
              totalBytesExpectedToWrite: Int64
            ) {
              let progress = Progress(
                totalUnitCount: totalBytesExpectedToWrite
              )
              progress.completedUnitCount = totalBytesWritten
              proxy.progress(progress)
            }

            func urlSession(
              _ session: URLSession,
              task: URLSessionTask,
              didCompleteWithError error: Error?
            ) {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let error {
                  self.continuation?.resume(throwing: error)
                }
              }
            }

            init(proxy: DownloadProxyType) {
              self.proxy = proxy
            }
          }

          let delegate = SessionDelegate(proxy: proxy)
          let session = URLSession(
            configuration: .default,
            delegate: delegate,
            delegateQueue: nil
          )

          let url = URL(string: attachment.url)!
          let (tempURL, res) = try await session.download(from: url)
          proxy.progress(nil)  // go back to indeterminate
          let fileURL = tempURL.deletingLastPathComponent()
            .appendingPathComponent(res.suggestedFilename ?? "temp.m4a")
          defer {
            try? FileManager.default.removeItem(at: tempURL)
            try? FileManager.default.removeItem(at: fileURL)
          }
          try FileManager.default.moveItem(at: tempURL, to: fileURL)
          let recognizer = SFSpeechRecognizer()
          let request = SFSpeechURLRecognitionRequest(url: fileURL)
          let result = try await recognizer?.recognition(with: request)
          guard let transcription = result?.bestTranscription.formattedString
          else {
            throw "Transcription failed."
          }

          AttachmentAudioPlayer.transcriptCache[url] = transcription
          return transcription
        } completion: { proxy, transcription in
          self.transcript = transcription
          self.showingTranscript = true
        }
        .errorTitle("Transcription Failed")
        .completionBehavior(.stayCompleted(allowsInteraction: true))
        .downloadSymbol(systemName: "text.bubble")
        .completionSymbol(systemName: "text.bubble")
        .popover(isPresented: $showingTranscript) {
          Text(transcript ?? "No transcript available.")
            .padding()
            .presentationDetents([.medium, .large])
        }
      }

      struct WaveformView: View {
        let waveform: [Float]
        let progress: Double
        @GestureState private var gestureProgress: Double? = nil
        let onSeek: ((Double) -> Void)?

        init(
          waveform: [Float],
          progress: Double,
          onSeek: ((Double) -> Void)? = nil
        ) {
          self.waveform = waveform
          self.progress = progress
          self.onSeek = onSeek
        }

        var body: some View {
          IntrinsicSizeReader { (size: CGSize?) in
            ZStack(alignment: .leading) {

              // unplayed
              waveformBars(color: .primary.opacity(0.3))

              // played
              waveformBars(color: .primary.opacity(0.8))
                .mask(alignment: .leading) {
                  Rectangle()
                    .frame(
                      width: (size?.width ?? 1) * (gestureProgress ?? progress)
                    )
                }
            }
            .background(.almostClear)
            .gesture(
              DragGesture(minimumDistance: 0)
                .updating($gestureProgress) { value, state, _ in
                  let p = min(max(value.location.x / (size?.width ?? 1), 0), 1)
                  state = p
                }
                .onEnded { value in
                  let p = min(max(value.location.x / (size?.width ?? 1), 0), 1)
                  onSeek?(p)
                }
            )
          }
        }

        @ViewBuilder
        private func waveformBars(color: Color) -> some View {
          HStack(alignment: .center, spacing: 2) {
            ForEach(waveform.indices, id: \.self) { i in
              let height = CGFloat(max(4, waveform[i] * 20))
              Capsule()
                .fill(color)
                .frame(width: 3.5, height: height)
            }
          }
        }
      }

      struct WaveformExtractor {
        static var waveformCache: [URL: [Float]] = [:]

        static func extract(
          from url: URL,
          samplesCount: Int = 120
        ) async throws -> [Float] {
          if let cached = waveformCache[url] {
            return cached
          }

          // sadly downloads are required to read audio data
          let (tempURL, res) = try await URLSession.shared.download(from: url)
          // rename bc AVAssetReader requires file extension?? keeping it in tmp.
          let fileURL = tempURL.deletingLastPathComponent()
            .appendingPathComponent(res.suggestedFilename ?? "temp.m4a")
          defer {
            try? FileManager.default.removeItem(at: tempURL)
            try? FileManager.default.removeItem(at: fileURL)
          }
          try FileManager.default.moveItem(at: tempURL, to: fileURL)

          let asset = AVURLAsset(url: fileURL)
          guard
            let track = try await asset.loadTracks(withMediaType: .audio).first
          else {
            return .init(repeating: 0.01, count: samplesCount)
          }

          let reader = try AVAssetReader(asset: asset)

          let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false,
          ]

          let output = AVAssetReaderTrackOutput(
            track: track,
            outputSettings: settings
          )
          reader.add(output)
          reader.startReading()

          var samples: [Float] = []

          while let buffer = output.copyNextSampleBuffer(),
            let block = CMSampleBufferGetDataBuffer(buffer)
          {

            let length = CMBlockBufferGetDataLength(block)
            var data = [Int16](repeating: 0, count: length / 2)

            CMBlockBufferCopyDataBytes(
              block,
              atOffset: 0,
              dataLength: length,
              destination: &data
            )

            samples.append(contentsOf: data.map { abs(Float($0)) })
            CMSampleBufferInvalidate(buffer)
          }

          guard !samples.isEmpty else { return [] }

          // downsample
          let stride = max(1, samples.count / samplesCount)
          var waveform: [Float] = []

          for i in Swift.stride(from: 0, to: samples.count, by: stride) {
            let chunk = samples[i..<min(i + stride, samples.count)]
            let avg = chunk.reduce(0, +) / Float(chunk.count)
            waveform.append(avg)
          }

          // normalise
          let maxVal = waveform.max() ?? 1

          let normalisedWaveform = waveform.map { $0 / maxVal }

          waveformCache[url] = normalisedWaveform

          return normalisedWaveform
        }
      }
    }

    struct FileAttachmentView: View {
      @AppStorage("Paicord.Chat.Attachments.DownloadsEphemeral")
      var ephemeralDownloads = false

      @Environment(\.theme) var theme
      var attachment: DiscordChannel.Message.Attachment

      #if os(iOS)
        @ViewStorage var localURL: URL? = nil
        @State var showingShareSheet: Bool = false
      #endif
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

          DownloadButton { proxy in
            final class SessionDelegate: NSObject, URLSessionDownloadDelegate {
              let proxy: DownloadButton<URL>.DownloadProxy
              nonisolated(unsafe) var continuation:
                CheckedContinuation<URL, Error>?
              let destinationURL: URL

              func urlSession(
                _ session: URLSession,
                downloadTask: URLSessionDownloadTask,
                didFinishDownloadingTo location: URL
              ) {
                do {
                  if FileManager.default.fileExists(atPath: destinationURL.path)
                  {
                    try FileManager.default.removeItem(at: destinationURL)
                  }
                  try FileManager.default.moveItem(
                    at: location,
                    to: destinationURL
                  )
                  continuation?.resume(returning: destinationURL)
                } catch {
                  continuation?.resume(throwing: error)
                }
              }

              func urlSession(
                _ session: URLSession,
                downloadTask: URLSessionDownloadTask,
                didWriteData bytesWritten: Int64,
                totalBytesWritten: Int64,
                totalBytesExpectedToWrite: Int64
              ) {
                let progress = Progress(
                  totalUnitCount: totalBytesExpectedToWrite
                )
                progress.completedUnitCount = totalBytesWritten
                proxy.progress(progress)
              }

              func urlSession(
                _ session: URLSession,
                task: URLSessionTask,
                didCompleteWithError error: Error?
              ) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  if let error {
                    self.continuation?.resume(throwing: error)
                  }
                }
              }

              init(
                proxy: DownloadButton<URL>.DownloadProxy,
                destinationURL: URL
              ) {
                self.proxy = proxy
                self.destinationURL = destinationURL
              }
            }

            #if os(iOS)
              var localURL: URL
              if ephemeralDownloads {
                localURL = URL.temporaryDirectory.appendingPathComponent(
                  attachment.filename
                )
              } else {
                localURL = URL.documentsDirectory.appendingPathComponent(
                  attachment.filename
                )
              }
            #else
              let localURL = URL.downloadsDirectory.appendingPathComponent(
                attachment.filename
              )
            #endif
            let delegate = SessionDelegate(
              proxy: proxy,
              destinationURL: localURL
            )
            try await Task.sleep(for: .seconds(0.8))  // simulate delay
            return try await withCheckedThrowingContinuation { continuation in
              delegate.continuation = continuation

              let session = URLSession(
                configuration: .default,
                delegate: delegate,
                delegateQueue: nil
              )

              let task = session.downloadTask(
                with: URL(string: attachment.url)!
              )
              task.resume()
            }

          } completion: { proxy, url in
            if FileManager.default.fileExists(atPath: url.path) == false {
              return proxy.reset()
            }

            #if os(macOS)
              // open enclosing folder
              NSWorkspace.shared.activateFileViewerSelecting([url])
            #else
              // open in share sheet
              if ephemeralDownloads {
                localURL = url
                showingShareSheet = true
              } else {
                openDocuments()
              }
            #endif
          }
          .completionBehavior(.stayCompleted(allowsInteraction: true))
          #if os(iOS)
            .sheet(isPresented: $showingShareSheet) {
              if let localURL {
                ActivityViewController(activityItems: [localURL])
                .presentationDetents([.medium, .large])
              }
            }
          #endif
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

      #if os(iOS)
        func openDocuments() {
          // https://stackoverflow.com/a/72360825
          let documentsUrl = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
          ).first!
          let sharedurl = documentsUrl.absoluteString.replacingOccurrences(
            of: "file://",
            with: "shareddocuments://"
          )
          let furl: URL = URL(string: sharedurl)!
          if UIApplication.shared.canOpenURL(furl) {
            UIApplication.shared.open(furl, options: [:])
          }
        }
      #endif
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

#if os(iOS)
  private struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [URL]

    func makeUIViewController(context: Context) -> UIActivityViewController {
      UIActivityViewController(
        activityItems: activityItems,
        applicationActivities: nil
      )
    }

    func updateUIViewController(
      _ uiViewController: UIActivityViewController,
      context: Context
    ) {}
  }
#endif

#Preview {
  let data = DiscordChannel.Message.Attachment(
    id: AttachmentSnowflake("1467172175759933684"),
    filename: "Ocean_Eyes.flac",
    description: nil,
    content_type: Optional("audio/flac"),
    size: 36_167_305,
    url:
      "https://cdn.discordapp.com/attachments/1026504914131759104/1467183399901991087/01_Ocean_Eyes.m4a?ex=697f7485&is=697e2305&hm=523155ab2204604c3b4f09d2dfd5b0b15dd04d628eb49de4a05a81fcc716a01f&",
    proxy_url:
      "https://media.discordapp.net/attachments/1026504914131759104/1467183399901991087/01_Ocean_Eyes.m4a?ex=697f7485&is=697e2305&hm=523155ab2204604c3b4f09d2dfd5b0b15dd04d628eb49de4a05a81fcc716a01f&",
    placeholder: nil,
    height: nil,
    width: nil,
    ephemeral: nil,
    duration_secs: nil,
    waveform: nil,
    flags: nil
  )

  MessageCell.AttachmentsView(attachments: [data])
    .padding()
}

extension SFSpeechRecognizer {
  static func requestAuthorization() async
    -> SFSpeechRecognizerAuthorizationStatus
  {
    return await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        continuation.resume(returning: status)
      }
    }
  }

  func recognition(
    with request: SFSpeechRecognitionRequest
  ) async throws -> SFSpeechRecognitionResult {

    var task: SFSpeechRecognitionTask?

    return try await withCheckedThrowingContinuation { continuation in
      task = self.recognitionTask(with: request) { result, error in
        if let error {
          continuation.resume(throwing: error)
          task?.cancel()
          return
        }

        guard let result, result.isFinal else { return }

        continuation.resume(returning: result)
        task?.cancel()
      }
    }
  }
}
