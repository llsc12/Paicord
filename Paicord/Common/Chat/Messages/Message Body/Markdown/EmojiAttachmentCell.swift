//
//  EmojiAttachmentCell.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SDWebImageSwiftUI
import SwiftUIX
import UniformTypeIdentifiers

class EmojiData: NSObject, NSSecureCoding {
  var url: URL
  var size: CGFloat

  init(url: URL, size: CGFloat) {
    self.url = url
    self.size = size
  }

  required convenience init?(coder: NSCoder) {
    guard
      let url = coder.decodeObject(
        of: NSURL.self,
        forKey: "url"
      ) as URL?
    else {
      return nil
    }

    let size =
      coder.decodeObject(
        of: NSNumber.self,
        forKey: "size"
      )?.doubleValue ?? 18.0

    self.init(url: url, size: CGFloat(size))
  }

  func encode(with coder: NSCoder) {
    coder.encode(url, forKey: "url")
    coder.encode(size, forKey: "size")
  }

  static var supportsSecureCoding: Bool {
    return true
  }
}

extension MarkdownRendererVM {
  // Create an attachment backed by a view provider (macOS + iOS)
  func makeEmojiAttachment(emoji: EmojiData, copyText: String)
    -> NSAttributedString
  {
    //    let string = emoji.url.absoluteString
    let data = try? NSKeyedArchiver.archivedData(
      withRootObject: emoji,
      requiringSecureCoding: true
    )
    let attachment = NSTextAttachment(
      data: data,
      ofType: "public.item"
    )
    attachment.bounds = CGRect(
      x: 0,
      y: 0,
      width: emoji.size,
      height: emoji.size
    )

    let mutable = NSMutableAttributedString(
      attributedString: .init(attachment: attachment)
    )
    mutable.addAttribute(
      .rawContent,
      value: copyText,
      range: NSRange(location: 0, length: mutable.length)
    )
    return mutable
  }

  // Cross-platform view provider using NSTextAttachmentViewProvider
  final class CrossPlatformEmojiAttachmentViewProvider:
    NSTextAttachmentViewProvider
  {
    override init(
      textAttachment: NSTextAttachment,
      parentView: AppKitOrUIKitView?,
      textLayoutManager: NSTextLayoutManager?,
      location: NSTextLocation
    ) {
      super.init(
        textAttachment: textAttachment,
        parentView: parentView,
        textLayoutManager: textLayoutManager,
        location: location
      )
      tracksTextAttachmentViewBounds = true
    }

    var textView: AppKitOrUIKitTextView? {
      #if os(macOS)
        self.view?.superview as? AppKitOrUIKitTextView
      #elseif os(iOS)
        self.view?.superview?.superview as? AppKitOrUIKitTextView
      #endif
    }

    var layoutManager: NSLayoutManager? {
      #if os(macOS)
        textView?.layoutManager
      #elseif os(iOS)
        textView?.layoutManager
      #endif
    }

    func invalidateAttachment() {
      // Find the range of the attachment in the storage
      if let storage = layoutManager?.textStorage {
        let fullRange = NSRange(location: 0, length: storage.length)
        storage.enumerateAttribute(.attachment, in: fullRange) {
          value,
          range,
          _ in
          if (value as? NSTextAttachment) == self.textAttachment {
            // Force layout only for this attachment
            layoutManager?.invalidateLayout(
              forCharacterRange: range,
              actualCharacterRange: nil
            )
            layoutManager?.ensureLayout(forCharacterRange: range)
          }
        }
      }
    }

    override func loadView() {

      guard let data = textAttachment?.contents,
        let emoji = try? NSKeyedUnarchiver.unarchivedObject(
          ofClass: EmojiData.self,
          from: data
        )
      else {
        return
      }

      let emojiView = AnimatedImage(url: emoji.url)
        .resizable()
        .onViewUpdate(perform: { view, ctx in
          self.invalidateAttachment()
        })
        .scaledToFit()
        .frame(width: emoji.size, height: emoji.size)
        .padding(-2)  // slightly larger without increasing line height
        .offset(y: 2)  // baseline alignment tweak

      #if os(macOS)
        let host = NSHostingView(rootView: emojiView)
        host.frame = .zero
        host.wantsLayer = false
        self.view = host
      #else
        //        let host = UIHostingController(rootView: emojiView)
        let host = UIHostingView(rootView: emojiView)
        host.frame = .zero
        host.backgroundColor = .clear
        self.view = host
      #endif
    }

    override func attachmentBounds(
      for attributes: [NSAttributedString.Key: Any],
      location: NSTextLocation,
      textContainer: NSTextContainer?,
      proposedLineFragment: CGRect,
      position: CGPoint
    ) -> CGRect {
      return CGRect(
        x: 0,
        y: 0,
        width: proposedLineFragment.height,
        height: proposedLineFragment.height
      )
    }
  }
}
