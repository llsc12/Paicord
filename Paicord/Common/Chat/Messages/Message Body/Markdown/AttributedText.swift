//
//  AttributedText.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

struct AttributedText: View {
  var attributedString: NSAttributedString? = nil
  var body: some View {
    VStack {
      if let attributedString {
        _AttributedTextView(
          attributedString: attributedString
        )
        .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        EmptyView()
      }
    }
  }
}

#if os(macOS)
  import AppKit

  private struct _AttributedTextView: NSViewRepresentable {
    var attributedString: NSAttributedString
    @Environment(\.lineLimit) private var lineLimit

    func makeNSView(context: Context) -> ModifiedCopyingTextView {
      let textView = ModifiedCopyingTextView()
      textView.isEditable = false
      textView.isSelectable = true
      textView.drawsBackground = false
      textView.textContainer?.lineFragmentPadding = 0
      textView.textContainer?.maximumNumberOfLines = lineLimit ?? 0
      textView.textStorage?.setAttributedString(attributedString)
      return textView
    }

    func updateNSView(_ nsView: ModifiedCopyingTextView, context: Context) {
      nsView.textStorage?.setAttributedString(attributedString)
      nsView.textContainer?.maximumNumberOfLines = lineLimit ?? 0
    }

    func sizeThatFits(
      _ proposal: ProposedViewSize,
      nsView: ModifiedCopyingTextView,
      context: Context
    ) -> CGSize? {
      let targetWidth = proposal.width ?? 400
      guard let layoutManager = nsView.layoutManager,
        let textContainer = nsView.textContainer
      else {
        return nil
      }

      textContainer.containerSize = CGSize(
        width: targetWidth,
        height: .greatestFiniteMagnitude
      )
      layoutManager.ensureLayout(for: textContainer)

      let usedRect = layoutManager.usedRect(for: textContainer)
      return CGSize(width: targetWidth, height: usedRect.height)
    }
  }

  class ModifiedCopyingTextView: NSTextView {
    override func writeSelection(
      to pboard: NSPasteboard,
      type: NSPasteboard.PasteboardType
    ) -> Bool {
      let selectedAttributedString = attributedString().attributedSubstring(
        from: selectedRange()
      )
      let selectedAttributedStringCopy = NSMutableAttributedString(
        attributedString: selectedAttributedString
      )

      selectedAttributedStringCopy.enumerateAttribute(
        NSAttributedString.Key.attachment,
        in: NSMakeRange(0, (selectedAttributedString.string.count)),
        options: .reverse,
        using: {
          (
            _ value: Any?,
            _ range: NSRange,
            _ stop: UnsafeMutablePointer<ObjCBool>
          ) -> Void in

          if let textAttachment = value as? NSTextAttachment,
            let textAttachmentCell = textAttachment.attachmentCell
              as? MarkdownRendererVM.EmojiAttachmentCell
          {
            var range2: NSRange = NSRange(location: 0, length: 0)
            let attributes = selectedAttributedStringCopy.attributes(
              at: range.location,
              effectiveRange: &range2
            )

            selectedAttributedStringCopy.replaceCharacters(
              in: range,
              with: NSMutableAttributedString(
                string: textAttachmentCell.copyText
              )
            )
            selectedAttributedStringCopy.addAttributes(attributes, range: range)
          }
        }
      )

      pboard.clearContents()
      pboard.writeObjects([selectedAttributedStringCopy])

      return true
    }
  }
#elseif os(iOS)
  import UIKit

  private struct _AttributedTextView: UIViewRepresentable {
    var attributedString: NSAttributedString
    @Environment(\.lineLimit) private var lineLimit

    func makeUIView(context: Context) -> UITextView {
      let textView = UITextView()
      textView.isEditable = false
      textView.isSelectable = false
      textView.isScrollEnabled = false
      textView.backgroundColor = .clear
      textView.textContainerInset = .zero
      textView.textContainer.lineFragmentPadding = 0
      textView.textContainer.maximumNumberOfLines = lineLimit ?? 0

      textView.textStorage.setAttributedString(attributedString)
      textView.layoutManager.ensureLayout(for: textView.textContainer)
      return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
      uiView.textStorage.setAttributedString(attributedString)
      uiView.textContainer.maximumNumberOfLines = lineLimit ?? 0
      uiView.layoutManager.ensureLayout(for: uiView.textContainer)
    }

    func sizeThatFits(
      _ proposal: ProposedViewSize,
      uiView: UITextView,
      context: Context
    ) -> CGSize? {
      let targetWidth = proposal.width ?? UIScreen.main.bounds.width
      let fittingSize = CGSize(
        width: targetWidth,
        height: .greatestFiniteMagnitude
      )
      let size = uiView.sizeThatFits(fittingSize)
      return CGSize(width: targetWidth, height: size.height)
    }
  }

#endif
