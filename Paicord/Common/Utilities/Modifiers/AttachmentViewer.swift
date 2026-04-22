//
//  AttachmentViewer.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/01/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import AVFoundation
import AVKit
import PaicordLib
import SDWebImageSwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

#if os(macOS)
  import AppKit
  import SDWebImage
#elseif os(iOS)
  import UIKit
  import SDWebImage
#endif

extension View {
  @ViewBuilder
  func attachmentViewer() -> some View {
    self.modifier(
      AttachmentViewerModifier()
    )
  }
}

private struct AttachmentViewerModifier: ViewModifier {
  @Environment(\.appState) var appState
  var contextMessage: DiscordChannel.PartialMessage? = nil
  func body(content: Content) -> some View {
    @Bindable var appState = appState
    #if os(macOS)
      content
        .overlay {
          if appState.showingAttachmentViewer {
            Color.black.opacity(0.25)
              .onTapGesture {
                appState.showingAttachmentViewer = false
              }
              .transition(.opacity)
          }
        }
        .overlay {
          if appState.showingAttachmentViewer {
            AttachmentViewer(
              contextMessage: appState.attachmentViewerContextMessage,
              attachments: $appState.attachmentViewerAttachments,
              selectedIndex: $appState.attachmentViewerIndex,
              isPresented: $appState.showingAttachmentViewer
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity.combined(with: .scale))
          }
        }
        .animation(.default, value: appState.showingAttachmentViewer)
    #else
      content
        .sheet(isPresented: $appState.showingAttachmentViewer) {
          AttachmentViewer(
            contextMessage: appState.attachmentViewerContextMessage,
            attachments: $appState.attachmentViewerAttachments,
            selectedIndex: $appState.attachmentViewerIndex,
            isPresented: $appState.showingAttachmentViewer
          )
        }
    #endif
  }
}

/// Le attachment viewer, a fullscreen sheet or an overlay that shows the attachments.
private struct AttachmentViewer: View {
  var contextMessage: DiscordChannel.PartialMessage? = nil
  @Binding var attachments: [DiscordMedia]
  @Binding var selectedIndex: Int?
  @Binding var isPresented: Bool

  var body: some View {
    #if os(iOS)
      TabView(selection: $selectedIndex) {
        ForEach(attachments.indices, id: \.self) { index in
          attachmentItemView(for: attachments[index], isPresented: $isPresented)
            .ignoresSafeArea(.container)
            .tag(index)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .ignoresSafeArea(.container)
    #else
      VStack(spacing: 0) {
        if let selectedIndex, attachments.indices.contains(selectedIndex) {
          attachmentItemView(
            for: attachments[selectedIndex],
            isPresented: $isPresented
          )
        } else {
          Text(verbatim: "")
            .onAppear {
              self.selectedIndex = attachments.indices.first
            }
        }

      }
      .safeAreaInset(edge: .bottom, spacing: 0) {
        Carousel(attachments: attachments, selectedIndex: $selectedIndex)
          .padding()
      }
    #endif
  }

  @ViewBuilder
  func attachmentItemView(
    for attachment: DiscordMedia,
    isPresented: Binding<Bool>
  ) -> some View {
    switch attachment.type {
    case .mpeg4Movie, .quickTimeMovie, .mp3, .mpeg4Audio,
      .init(mimeType: "audio/wav", conformingTo: .audio)!,
      .init(mimeType: "audio/flac", conformingTo: .audio)!,
      .init(mimeType: "audio/ogg", conformingTo: .audio)!:
      VideoPlayerView(attachment: attachment)
    case .png, .jpeg, .jpeg, .webP, .gif:
      ZoomableImageView(attachment: attachment, isPresented: isPresented)
    default:
      Text("Unsupported attachment type")
    }
  }

  #if os(macOS)
    struct Carousel: View {
      let attachments: [DiscordMedia]
      @Binding var selectedIndex: Int?

      @State private var scrollViewSize: CGSize = .zero
      @State private var contentSize: CGSize = .zero

      var body: some View {
        ScrollFadeMask(.horizontal) {
          LazyHStack(spacing: 2) {
            ForEach(attachments.indices, id: \.self) { index in
              if let attachment = attachments[safe: index] {
                Button {
                  selectedIndex = index
                } label: {
                  Color.clear
                    .frame(width: 38 * 1.5, height: 38 * 1.5)
                    .overlay {
                      MessageCell.AttachmentsView.AttachmentItemPreview(
                        attachment: attachment
                      )
                      .displayMode(asPoster: true)
                      .scaledToFill()
                      .clipped()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.borderless)
              }
            }
          }
          .maxHeight(38 * 1.5)
          .onGeometryChange(for: CGSize.self) {
            $0.size
          } action: {
            contentSize = $0
          }
        }
        .scrollIndicators(.hidden)
        .onGeometryChange(for: CGSize.self) {
          $0.size
        } action: {
          scrollViewSize = $0
        }
        .maxWidth(min(contentSize.width, 380))
      }
    }
  #endif
}

private struct VideoPlayerView: View {
  let attachment: DiscordMedia

  var body: some View {
    if let url = URL(string: attachment.proxyurl) {
      VideoPlayer(player: AVPlayer(url: url))
    } else {
      Text("Invalid video URL")
    }
  }
}

private struct ZoomableImageView: View {
  let attachment: DiscordMedia
  @Binding var isPresented: Bool
  var body: some View {
    #if os(iOS)
      IOSZoomableImageView(attachment: attachment)
    #elseif os(macOS)
      MacOSZoomableImageView(attachment: attachment, isPresented: $isPresented)
    #endif
  }

  #if os(iOS)
    struct IOSZoomableImageView: UIViewRepresentable {
      let attachment: DiscordMedia
      var url: URL? {
        URL(string: attachment.proxyurl)
      }

      func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 8.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.frame = .zero
        imageView.autoresizingMask = []

        scrollView.addSubview(imageView)

        context.coordinator.imageView = imageView
        context.coordinator.scrollView = scrollView

        let doubleTap = UITapGestureRecognizer(
          target: context.coordinator,
          action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        return scrollView
      }

      func updateUIView(_ uiView: UIScrollView, context: Context) {
        if let url = url, context.coordinator.currentURL != url {
          context.coordinator.currentURL = url
          context.coordinator.imageView?.sd_setImage(with: url) {
            image,
            _,
            _,
            _ in
            guard let image = image else { return }
            DispatchQueue.main.async {
              guard let imageView = context.coordinator.imageView else {
                return
              }
              let bounds = uiView.bounds.size
              guard bounds.width > 0, bounds.height > 0 else { return }

              let imageSize = image.size
              let scale = min(
                bounds.width / imageSize.width,
                bounds.height / imageSize.height
              )
              let fittedSize = CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
              )

              imageView.frame = CGRect(origin: .zero, size: fittedSize)
              uiView.contentSize = fittedSize

              uiView.minimumZoomScale = 1.0
              uiView.maximumZoomScale = 8.0
              uiView.zoomScale = 1.0

              context.coordinator.centerImage(in: uiView)
            }
          }
        } else {
          if let imageView = context.coordinator.imageView,
            let image = imageView.image
          {
            let bounds = uiView.bounds.size
            guard bounds.width > 0, bounds.height > 0 else {
              context.coordinator.centerImage(in: uiView)
              return
            }

            let imageSize = image.size
            let scale = min(
              bounds.width / imageSize.width,
              bounds.height / imageSize.height
            )
            let fittedSize = CGSize(
              width: imageSize.width * scale,
              height: imageSize.height * scale
            )

            imageView.frame = CGRect(origin: .zero, size: fittedSize)
            uiView.contentSize = fittedSize
            uiView.minimumZoomScale = 1.0
            if uiView.zoomScale < uiView.minimumZoomScale {
              uiView.zoomScale = uiView.minimumZoomScale
            }

            context.coordinator.centerImage(in: uiView)
          } else {
            context.coordinator.centerImage(in: uiView)
          }
        }
      }

      func makeCoordinator() -> Coordinator {
        Coordinator()
      }

      class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: SDAnimatedImageView?
        var scrollView: UIScrollView?
        var currentURL: URL?

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
          return imageView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
          centerImage(in: scrollView)
        }

        func centerImage(in scrollView: UIScrollView) {
          guard let imageView = imageView else { return }

          let boundsSize = scrollView.bounds.size
          let contentSize = scrollView.contentSize

          let horizontalPadding = max(
            (boundsSize.width - contentSize.width) / 2.0,
            0
          )
          let verticalPadding = max(
            (boundsSize.height - contentSize.height) / 2.0,
            0
          )
          scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
          )

          var desiredOffset = scrollView.contentOffset
          let maxOffsetX = max(0, contentSize.width - boundsSize.width)
          let maxOffsetY = max(0, contentSize.height - boundsSize.height)
          if contentSize.width <= boundsSize.width {
            desiredOffset.x = -horizontalPadding
          } else {
            desiredOffset.x = min(
              max(scrollView.contentOffset.x, 0),
              maxOffsetX
            )
          }

          if contentSize.height <= boundsSize.height {
            desiredOffset.y = -verticalPadding
          } else {
            desiredOffset.y = min(
              max(scrollView.contentOffset.y, 0),
              maxOffsetY
            )
          }

          if desiredOffset != scrollView.contentOffset {
            DispatchQueue.main.async {
              scrollView.setContentOffset(desiredOffset, animated: false)
            }
          }
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
          guard let scrollView = gesture.view as? UIScrollView else { return }

          if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
          } else {
            let point = gesture.location(in: imageView)
            let newZoom = min(scrollView.maximumZoomScale, 3.0)
            let scrollSize = CGSize(
              width: scrollView.bounds.width / newZoom,
              height: scrollView.bounds.height / newZoom
            )

            var origin = CGPoint(
              x: point.x - scrollSize.width / 2,
              y: point.y - scrollSize.height / 2
            )
            origin.x = max(origin.x, 0)
            origin.y = max(origin.y, 0)

            scrollView.zoom(
              to: CGRect(origin: origin, size: scrollSize),
              animated: true
            )
          }
        }
      }
    }
  #elseif os(macOS)
    struct MacOSZoomableImageView: NSViewRepresentable {
      let attachment: DiscordMedia
      @Binding var isPresented: Bool
      var url: URL? {
        URL(string: attachment.proxyurl)
      }

      func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.wantsLayer = true
        scrollView.layer?.backgroundColor = .clear

        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder

        scrollView.documentView?.wantsLayer = true
        scrollView.documentView?.layer?.backgroundColor = .clear

        scrollView.allowsMagnification = true
        scrollView.maxMagnification = 8.0
        scrollView.minMagnification = 1.0
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = false

        let clipView = NoScrollClipView()
        clipView.drawsBackground = false
        scrollView.contentView = clipView

        let imageView = SDAnimatedImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown

        let containerView = FlippedView()
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = .clear
        containerView.addSubview(imageView)
        scrollView.documentView = containerView

        context.coordinator.imageView = imageView
        context.coordinator.containerView = containerView
        context.coordinator.scrollView = scrollView

        let doubleTap = NSClickGestureRecognizer(
          target: context.coordinator,
          action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTap.numberOfClicksRequired = 2
        imageView.addGestureRecognizer(doubleTap)

        let panGesture = NSPanGestureRecognizer(
          target: context.coordinator,
          action: #selector(Coordinator.handlePan(_:))
        )
        imageView.addGestureRecognizer(panGesture)

        let backgroundTap = NSClickGestureRecognizer(
          target: context.coordinator,
          action: #selector(Coordinator.handleBackgroundTap(_:))
        )
        backgroundTap.numberOfClicksRequired = 1
        scrollView.addGestureRecognizer(backgroundTap)

        return scrollView
      }

      func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let url = url, context.coordinator.currentURL != url {
          context.coordinator.currentURL = url
          context.coordinator.imageView?.sd_setImage(with: url) {
            [weak nsView, context] image, _, _, _ in
            guard let nsView = nsView,
              let imageView = context.coordinator.imageView,
              let containerView = context.coordinator.containerView,
              let image = image
            else { return }
            DispatchQueue.main.async {
              let bounds = nsView.bounds.size
              guard bounds.width > 0, bounds.height > 0 else { return }
              let imageSize = image.size
              let scale = min(
                bounds.width / imageSize.width,
                bounds.height / imageSize.height
              )
              let fittedSize = CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
              )
              // Make the container fill the scroll view so the image can be centered
              containerView.frame = CGRect(origin: .zero, size: bounds)
              // Center the image within the container (FlippedView: y=0 is top)
              let originX = (bounds.width - fittedSize.width) / 2
              let originY = (bounds.height - fittedSize.height) / 2
              imageView.frame = CGRect(
                origin: CGPoint(x: originX, y: originY),
                size: fittedSize
              )
            }
          }
        }
      }

      func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
      }

      class Coordinator: NSObject {
        var imageView: NSImageView?
        var containerView: NSView?
        var scrollView: NSScrollView?
        var currentURL: URL?
        var isPresented: Binding<Bool>

        init(isPresented: Binding<Bool>) {
          self.isPresented = isPresented
        }

        @objc func handleDismissalTap() {
          isPresented.wrappedValue = false
        }

        @objc func handleBackgroundTap(_ gesture: NSClickGestureRecognizer) {
          guard
            let imageView = imageView,
            let containerView = containerView
          else { return }
          // Convert click into the container (document) view's coordinate space
          let clickInContainer = gesture.location(in: containerView)
          if !imageView.frame.contains(clickInContainer) {
            isPresented.wrappedValue = false
          }
        }

        @objc func handleDoubleTap(_ gesture: NSClickGestureRecognizer) {
          guard let scrollView = scrollView else { return }

          if scrollView.magnification > 1.0 {
            scrollView.animator().magnification = 1.0
          } else {
            var point = gesture.location(in: scrollView)
            point.y = scrollView.bounds.height - point.y
            let newMag: CGFloat = 3.0
            scrollView.animator().setMagnification(newMag, centeredAt: point)
          }
        }

        @objc func handlePan(_ gesture: NSPanGestureRecognizer) {
          guard let scrollView = scrollView,
            let imageView = imageView
          else { return }
          let mag = scrollView.magnification
          guard mag > 1.0 else { return }

          let imageFrame = imageView.frame
          let visibleDocWidth = scrollView.contentView.bounds.width
          let visibleDocHeight = scrollView.contentView.bounds.height

          let fitsX = imageFrame.width <= visibleDocWidth
          let minScrollX: CGFloat
          let maxScrollX: CGFloat
          if fitsX {
            let center = imageFrame.midX - visibleDocWidth / 2
            minScrollX = center
            maxScrollX = center
          } else {
            minScrollX = imageFrame.minX
            maxScrollX = imageFrame.maxX - visibleDocWidth
          }
          let fitsY = imageFrame.height <= visibleDocHeight
          let minScrollY: CGFloat
          let maxScrollY: CGFloat
          if fitsY {
            let center = imageFrame.midY - visibleDocHeight / 2
            minScrollY = center
            maxScrollY = center
          } else {
            minScrollY = imageFrame.minY
            maxScrollY = imageFrame.maxY - visibleDocHeight
          }

          switch gesture.state {
          case .began, .changed:
            let translation = gesture.translation(in: scrollView)
            let scale = 1.0 / mag
            let currentOrigin = scrollView.contentView.bounds.origin
            let newX = min(
              max(minScrollX, currentOrigin.x - translation.x * scale),
              maxScrollX
            )
            let newY = min(
              max(minScrollY, currentOrigin.y - translation.y * scale),
              maxScrollY
            )
            scrollView.contentView.scroll(to: CGPoint(x: newX, y: newY))
            gesture.setTranslation(.zero, in: scrollView)
          default:
            let currentOrigin = scrollView.contentView.bounds.origin
            let clampedOrigin = CGPoint(
              x: min(max(minScrollX, currentOrigin.x), maxScrollX),
              y: min(max(minScrollY, currentOrigin.y), maxScrollY)
            )
            if clampedOrigin != currentOrigin {
              NSView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut
              ) {
                scrollView.contentView.bounds.origin = clampedOrigin
              }
            }
          }
        }
      }
    }

    class FlippedView: NSView {
      override var isFlipped: Bool { true }
    }

    class NoScrollClipView: NSClipView {
      override func scrollWheel(with event: NSEvent) {
        guard let docView = documentView else {
          super.scrollWheel(with: event)
          return
        }

        let imageFrame = docView.subviews.first?.frame ?? docView.frame
        let visibleW = bounds.width
        let visibleH = bounds.height

        let widthDiff = visibleW - imageFrame.width
        let minScrollX: CGFloat
        let maxScrollX: CGFloat

        if widthDiff >= 0 {
          let desiredX = imageFrame.midX - visibleW / 2
          minScrollX = desiredX
          maxScrollX = desiredX
        } else {
          minScrollX = imageFrame.minX
          maxScrollX = imageFrame.maxX - visibleW
        }

        let heightDiff = visibleH - imageFrame.height
        let minScrollY: CGFloat
        let maxScrollY: CGFloat

        if heightDiff >= 0 {
          let desiredY = imageFrame.midY - visibleH / 2
          minScrollY = desiredY
          maxScrollY = desiredY
        } else {
          minScrollY = imageFrame.minY
          maxScrollY = imageFrame.maxY - visibleH
        }

        let currentOrigin = bounds.origin

        let dx = event.scrollingDeltaX
        let dy = event.scrollingDeltaY

        let newX = min(max(currentOrigin.x - dx, minScrollX), maxScrollX)
        let newY = min(max(currentOrigin.y - dy, minScrollY), maxScrollY)

        if newX != currentOrigin.x || newY != currentOrigin.y {
          scroll(to: NSPoint(x: newX, y: newY))
        }
      }
    }
  #endif
}

#Preview {
  @Previewable @State var index: Int? = nil

  let attachments: [DiscordChannel.Message.Attachment] = [
    .init(
      id: .init("1476578950737301543"),
      filename: "RDT_20260225_1511335244677953476625047.jpg",
      content_type: "image/jpeg",
      size: 82688,
      url:
        "https://cdn.discordapp.com/attachments/1026504914131759104/1476578950737301543/RDT_20260225_1511335244677953476625047.jpg?ex=69a1a2cf&is=69a0514f&hm=e2a60c2f89f91ac634c4ccf88bef0b78bf7cb15d22995ef5b4c120995035c28c&",
      proxy_url:
        "https://media.discordapp.net/attachments/1026504914131759104/1476578950737301543/RDT_20260225_1511335244677953476625047.jpg?ex=69a1a2cf&is=69a0514f&hm=e2a60c2f89f91ac634c4ccf88bef0b78bf7cb15d22995ef5b4c120995035c28c&",
    ),
    .init(
      id: .init("1476579186695995486"),
      filename: "RDT_20260225_1504358545961818775118267.jpg",
      content_type: "image/jpeg",
      size: 22822,
      url:
        "https://cdn.discordapp.com/attachments/1026504914131759104/1476579186695995486/RDT_20260225_1504358545961818775118267.jpg?ex=69a1a307&is=69a05187&hm=c7285e0a16b09764d9d2bd9649cf43f3b8dad3043901feeb7ba428b4651a7c2a&",
      proxy_url:
        "https://media.discordapp.net/attachments/1026504914131759104/1476579186695995486/RDT_20260225_1504358545961818775118267.jpg?ex=69a1a307&is=69a05187&hm=c7285e0a16b09764d9d2bd9649cf43f3b8dad3043901feeb7ba428b4651a7c2a&"
    ),
    .init(
      id: .init("1476582227981635625"),
      filename: "image.png",
      content_type: "image/png",
      size: 60839,
      url:
        "https://cdn.discordapp.com/attachments/1026504914131759104/1476582227981635625/image.png?ex=69a1a5dc&is=69a0545c&hm=403cbd5fca9fc3c405750bd8ea544bddd4726629508a2b5d90a85d60c31cdaa7&",
      proxy_url:
        "https://media.discordapp.net/attachments/1026504914131759104/1476582227981635625/image.png?ex=69a1a5dc&is=69a0545c&hm=403cbd5fca9fc3c405750bd8ea544bddd4726629508a2b5d90a85d60c31cdaa7&"
    ),
    .init(
      id: .init("1476679245957828638"),
      filename: "IMG_4210.png",
      content_type: "image/png",
      size: 427375,
      url:
        "https://cdn.discordapp.com/attachments/1428522655555915867/1476679245957828638/IMG_4210.png?ex=69a20037&is=69a0aeb7&hm=f424951868cc9e970ebed5c2378d83662d2214481ff33f2ed5e633274ee3e9cf&",
      proxy_url:
        "https://media.discordapp.net/attachments/1428522655555915867/1476679245957828638/IMG_4210.png?ex=69a20037&is=69a0aeb7&hm=f424951868cc9e970ebed5c2378d83662d2214481ff33f2ed5e633274ee3e9cf&"
    ),
    .init(
      id: .init("1476648572278669444"),
      filename: "IMG_4037.webp",
      content_type: "image/webp",
      size: 22822,
      url:
        "https://cdn.discordapp.com/attachments/1428522655555915867/1476648572278669444/IMG_4037.webp?ex=69a1e3a6&is=69a09226&hm=d775243daccefef013812392e35e7449884deec01949394a8ae5b94375439bae&",
      proxy_url:
        "https://media.discordapp.net/attachments/1428522655555915867/1476648572278669444/IMG_4037.webp?ex=69a1e3a6&is=69a09226&hm=d775243daccefef013812392e35e7449884deec01949394a8ae5b94375439bae&"
    ),
    .init(
      id: .init("1476236261185290420"),
      filename: "IMG_4150.png",
      content_type: "image/png",
      size: 60839,
      url:
        "https://cdn.discordapp.com/attachments/1428522655555915867/1476236261185290420/IMG_4150.png?ex=69a1b527&is=69a063a7&hm=3be27217a3f9b64c1e8b7e4dfacc604073ce64e398e63eecdce1bf51dc698284&",
      proxy_url:
        "https://media.discordapp.net/attachments/1428522655555915867/1476236261185290420/IMG_4150.png?ex=69a1b527&is=69a063a7&hm=3be27217a3f9b64c1e8b7e4dfacc604073ce64e398e63eecdce1bf51dc698284&"
    ),
    .init(
      id: .init("1475643804563538000"),
      filename: "IMG_4127.png",
      content_type: "image/png",
      size: 82688,
      url:
        "https://cdn.discordapp.com/attachments/1428522655555915867/1475643804563538000/IMG_4127.png?ex=69a187a3&is=69a03623&hm=9de5c7e71af6b4993dfaed8e0d07c0377c967f2e1289bd1bf18952c0febd998c&",
      proxy_url:
        "https://media.discordapp.net/attachments/1428522655555915867/1475643804563538000/IMG_4127.png?ex=69a187a3&is=69a03623&hm=9de5c7e71af6b4993dfaed8e0d07c0377c967f2e1289bd1bf18952c0febd998c&"
    ),
    .init(
      id: .init("1475987762531401738"),
      filename: "19c91d6940045-master_playlist.mov",
      content_type: "video/quicktime",
      size: 9_021_795,
      url:
        "https://cdn.discordapp.com/attachments/453278377999335431/1475987762531401738/19c91d6940045-master_playlist.mov?ex=69a17679&is=69a024f9&hm=e1f4412bc2583b51390cc2016fe91a7f5fb56966f7ed60bd7d465d61ecbb6b70&",
      proxy_url:
        "https://media.discordapp.net/attachments/453278377999335431/1475987762531401738/19c91d6940045-master_playlist.mov?ex=69a17679&is=69a024f9&hm=e1f4412bc2583b51390cc2016fe91a7f5fb56966f7ed60bd7d465d61ecbb6b70&"
    ),
    .init(
      id: .init("1476713612952342618"),
      filename: "B392763F-FB18-4A15-BA8A-260D8EB25B0D.mp4",
      content_type: "video/quicktime",
      size: 15_482_571,
      url:
        "https://cdn.discordapp.com/attachments/453278377999335431/1476713612952342618/B392763F-FB18-4A15-BA8A-260D8EB25B0D.mp4?ex=69a22039&is=69a0ceb9&hm=f933379aef5881455ce84cef667483e84403e09768df3456301468403ebd56c7&",
      proxy_url:
        "https://media.discordapp.net/attachments/453278377999335431/1476713612952342618/B392763F-FB18-4A15-BA8A-260D8EB25B0D.mp4?ex=69a22039&is=69a0ceb9&hm=f933379aef5881455ce84cef667483e84403e09768df3456301468403ebd56c7&"
    ),
  ]

  AttachmentViewer(
    attachments: .constant(attachments),
    selectedIndex: $index,
    isPresented: .constant(true)
  )
}
