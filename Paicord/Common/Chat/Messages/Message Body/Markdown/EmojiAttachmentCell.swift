//
//  EmojiAttachmentCell.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SDWebImageSwiftUI
import SwiftUI

// Markdown VM Helper

extension MarkdownRendererVM {
  private static let _emojiProviderRegistered: Void = {
    NSTextAttachment.registerViewProviderClass(
      EmojiAttachmentViewProvider.self,
      forFileType: "public.url"
    )
  }()

  // TODO: replace with emoji type
  func makeEmojiAttachment(url: URL, copyText: String) -> NSAttributedString {
    // ensure registration
    _ = Self._emojiProviderRegistered

    #if os(macOS)
      let attachment = NSTextAttachment()
      attachment.attachmentCell = EmojiAttachmentCell(
        url: url,
        copyText: copyText
      )  // textkit1
    #elseif os(iOS)
      // textkit2
      let urlData = try? NSKeyedArchiver.archivedData(
        withRootObject: url,
        requiringSecureCoding: false
      )
      let attachment = NSTextAttachment(
        data: urlData,
        ofType: "public.url"
      )
      attachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
    #endif
    return NSAttributedString(attachment: attachment)
  }

  #if os(macOS)
    final class EmojiAttachmentCell: NSTextAttachmentCell {
      private let url: URL
      private var hostingView: NSHostingView<AnyView>?
      let copyText: String

      init(url: URL, copyText: String = "") {
        self.url = url
        self.copyText = copyText
        super.init(imageCell: nil)
      }

      required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }

      // The size of your emoji inside text
      override func cellSize() -> NSSize {
        return NSSize(width: 15, height: 15)
      }

      override func cellBaselineOffset() -> NSPoint {
        // Center align with text baseline
        return NSPoint(x: 0, y: -3)
      }

      override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        if hostingView == nil {
          let imageView = WebImage(url: url)
            .resizable()
            .scaledToFit()
            .frame(width: 15, height: 15)
            .padding(-2)  // makes emoji a bit bigger without increasing line height

          let host = NSHostingView(rootView: AnyView(imageView))
          host.frame = cellFrame
          host.wantsLayer = false
          hostingView = host
          controlView?.addSubview(host)
        }

        hostingView?.frame = cellFrame
      }
    }
  #elseif os(iOS)
    final class EmojiAttachmentViewProvider: NSTextAttachmentViewProvider {
      override func loadView() {
        guard let data = textAttachment?.contents,
          let url = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: NSURL.self,
            from: data
          ) as URL?
        else { return }

        let emojiView = WebImage(url: url)
          .resizable()
          .scaledToFit()
          .frame(width: 15, height: 15)
          .padding(-2)  // makes emoji a bit bigger without increasing line height
          .offset(y: 2)  // center align with text baseline

        let host = UIHostingController(rootView: emojiView)
        host.view.backgroundColor = .clear
        self.view = host.view
      }
    }
  #endif
}
