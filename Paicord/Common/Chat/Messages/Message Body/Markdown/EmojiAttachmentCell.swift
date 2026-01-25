//
//  EmojiAttachmentCell.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SDWebImageSwiftUI
import SwiftUI
import UniformTypeIdentifiers

extension MarkdownRendererVM {
  // Ensure view provider registration on both platforms
  private static let _emojiProviderRegistered: Void = {
    NSTextAttachment.registerViewProviderClass(
      CrossPlatformEmojiAttachmentViewProvider.self,
      forFileType: UTType.url.identifier
    )
  }()

  // Create an attachment backed by a view provider (macOS + iOS)
  func makeEmojiAttachment(url: URL, copyText: String) -> NSAttributedString {
    // ensure registration
    _ = Self._emojiProviderRegistered

    let urlData = try? NSKeyedArchiver.archivedData(
      withRootObject: url,
      requiringSecureCoding: false
    )
    let attachment = NSTextAttachment(data: urlData, ofType: UTType.url.identifier)
    attachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)

    let mutable = NSMutableAttributedString(attributedString: .init(attachment: attachment))
    mutable.addAttribute(.rawContent, value: copyText, range: NSRange(location: 0, length: mutable.length))
    return mutable
  }

  // Cross-platform view provider using NSTextAttachmentViewProvider
  final class CrossPlatformEmojiAttachmentViewProvider: NSTextAttachmentViewProvider {
    override func loadView() {
      guard let data = textAttachment?.contents,
            let url = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSURL.self, from: data) as URL? else {
        return
      }

      let emojiView = AnimatedImage(url: url)
        .resizable()
        .scaledToFit()
        .frame(width: 15, height: 15)
        .padding(-2) // slightly larger without increasing line height
        .offset(y: 2) // baseline alignment tweak

      #if os(macOS)
      let host = NSHostingView(rootView: AnyView(emojiView))
      host.frame = .init(origin: .zero, size: .init(width: 15, height: 15))
      host.wantsLayer = false
      self.view = host
      #else
      let host = UIHostingController(rootView: emojiView)
      host.view.backgroundColor = .clear
      self.view = host.view
      #endif
    }
  }
}
