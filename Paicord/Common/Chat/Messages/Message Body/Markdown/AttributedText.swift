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
    Group {
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
    @Environment(\.openURL) private var openURL

    func makeCoordinator() -> Coordinator {
      Coordinator(openURL: openURL)
    }

    func makeNSView(context: Context) -> ModifiedCopyingTextView {
      let tv = ModifiedCopyingTextView()
      tv.isEditable = false
      tv.isSelectable = true
      tv.drawsBackground = false
      tv.textContainerInset = .zero
      tv.textContainer?.lineFragmentPadding = 0
      tv.textContainer?.widthTracksTextView = true
      tv.isAutomaticLinkDetectionEnabled = false
      tv.linkTextAttributes = [:]
      tv.delegate = context.coordinator
      tv.customCoordinator = context.coordinator
      tv.textStorage?.setAttributedString(attributedString)
      tv.textContainer?.maximumNumberOfLines = lineLimit ?? 0
      tv.usesAdaptiveColorMappingForDarkAppearance = true
      return tv
    }

    func updateNSView(_ nsView: ModifiedCopyingTextView, context: Context) {
      nsView.customCoordinator = context.coordinator
      if !context.coordinator.isSame(as: attributedString) {
        nsView.textStorage?.setAttributedString(attributedString)
        context.coordinator.remember(attributedString: attributedString)
      }
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
      else { return nil }
      textContainer.containerSize = CGSize(
        width: targetWidth,
        height: .greatestFiniteMagnitude
      )
      layoutManager.ensureLayout(for: textContainer)
      let used = layoutManager.usedRect(for: textContainer)
      return CGSize(width: targetWidth, height: used.height)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
      let openURL: OpenURLAction
      private var lastHash: Int = 0

      init(openURL: OpenURLAction) { self.openURL = openURL }

      func isSame(as attributed: NSAttributedString) -> Bool {
        var h = Hasher()
        h.combine(attributed.string)
        h.combine(attributed.length)
        return h.finalize() == lastHash
      }

      func remember(attributedString: NSAttributedString) {
        var h = Hasher()
        h.combine(attributedString.string)
        h.combine(attributedString.length)
        lastHash = h.finalize()
      }

      func textView(
        _ textView: NSTextView,
        clickedOnLink link: Any,
        at charIndex: Int
      ) -> Bool {
        if let url = link as? URL {
          openURL(url)
          return true
        }
        return false
      }
    }
  }

  // Custom NSTextView to preserve rawContent on copy and avoid context-menu conflicts
  final class ModifiedCopyingTextView: NSTextView {
    weak fileprivate var customCoordinator: _AttributedTextView.Coordinator?

    override func rightMouseDown(with event: NSEvent) {
      nextResponder?.rightMouseDown(with: event)
    }

    override func clicked(onLink link: Any, at charIndex: Int) {
      if let url = link as? URL {
        customCoordinator?.openURL(url)
      } else {
        super.clicked(onLink: link, at: charIndex)
      }
    }

    override func writeSelection(
      to pboard: NSPasteboard,
      type: NSPasteboard.PasteboardType
    ) -> Bool {
      let selected = attributedString().attributedSubstring(
        from: selectedRange()
      )
      let copy = NSMutableAttributedString(attributedString: selected)

      copy.enumerateAttribute(
        .rawContent,
        in: NSRange(location: 0, length: copy.length),
        options: .reverse
      ) { value, range, _ in
        if let customText = value as? String {
          var r = NSRange()
          let attrs = copy.attributes(at: range.location, effectiveRange: &r)
          copy.replaceCharacters(
            in: range,
            with: NSAttributedString(string: customText, attributes: attrs)
          )
        }
      }

      pboard.clearContents()
      pboard.writeObjects([copy.string as NSString])
      return true
    }
  }

#elseif os(iOS)
  import UIKit

  private struct _AttributedTextView: UIViewRepresentable {
    var attributedString: NSAttributedString
    @Environment(\.lineLimit) private var lineLimit
    @Environment(\.openURL) private var openURL

    func makeCoordinator() -> Coordinator {
      Coordinator(openURL: openURL)
    }

    func makeUIView(context: Context) -> ModifiedCopyingTextView {
      let tv = ModifiedCopyingTextView()
      tv.isEditable = false
      tv.isSelectable = true
      tv.isScrollEnabled = false
      tv.backgroundColor = .clear
      tv.textContainerInset = .zero
      tv.textContainer.lineFragmentPadding = 0
      tv.textContainer.maximumNumberOfLines = lineLimit ?? 0
      tv.delegate = context.coordinator
      tv.dataDetectorTypes = []
      tv.linkTextAttributes = [:]
      //
      // Force TextKit 1 compatibility for attachment view providers
      _ = tv.layoutManager

      tv.attributedText = attributedString
      return tv
    }

    func updateUIView(_ uiView: ModifiedCopyingTextView, context: Context) {
      if !context.coordinator.isSame(as: attributedString) {
        uiView.attributedText = attributedString
        context.coordinator.remember(attributedString: attributedString)
      }
      uiView.textContainer.maximumNumberOfLines = lineLimit ?? 0
      uiView.delegate = context.coordinator
    }

    func sizeThatFits(
      _ proposal: ProposedViewSize,
      uiView: ModifiedCopyingTextView,
      context: Context
    ) -> CGSize? {
      let targetWidth = proposal.width ?? UIScreen.main.bounds.width
      let fitting = CGSize(width: targetWidth, height: .greatestFiniteMagnitude)
      let size = uiView.sizeThatFits(fitting)
      return CGSize(width: targetWidth, height: size.height)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
      let openURL: OpenURLAction
      private var lastHash: Int = 0
      init(openURL: OpenURLAction) { self.openURL = openURL }

      func isSame(as attributed: NSAttributedString) -> Bool {
        var h = Hasher()
        h.combine(attributed.string)
        h.combine(attributed.length)
        return h.finalize() == lastHash
      }

      func remember(attributedString: NSAttributedString) {
        var h = Hasher()
        h.combine(attributedString.string)
        h.combine(attributedString.length)
        lastHash = h.finalize()
      }

      func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
      ) -> Bool {
        openURL(URL)
        if PaicordChatLink.init(url: URL) != nil {
          return false
        }
        return true
      }
    }
  }

  final class ModifiedCopyingTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?)
      -> Bool
    {
      if action == #selector(copy(_:)) { return true }
      return super.canPerformAction(action, withSender: sender)
    }

    override func copy(_ sender: Any?) {
      let attributed = self.attributedText.attributedSubstring(
        from: selectedRange
      )
      let mutable = NSMutableAttributedString(attributedString: attributed)

      mutable.enumerateAttribute(
        .rawContent,
        in: NSRange(location: 0, length: mutable.length),
        options: []
      ) { value, range, _ in
        if let custom = value as? String {
          mutable.replaceCharacters(
            in: range,
            with: NSAttributedString(string: custom)
          )
        }
      }

      super.copy(sender)
      UIPasteboard.general.string = mutable.string
    }
  }

#endif
