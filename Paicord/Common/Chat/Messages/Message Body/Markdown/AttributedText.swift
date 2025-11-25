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
    @Environment(\.openURL) private var openURL  // needed so we can signal that links were tapped.

    func makeCoordinator() -> Coordinator {
      Coordinator(openURL: openURL)
    }

    func makeNSView(context: Context) -> ModifiedCopyingTextView {
      let textView = ModifiedCopyingTextView()
      textView.customCoordinator = context.coordinator
      textView.isEditable = false
      textView.isSelectable = true
      textView.drawsBackground = false
      textView.textContainer?.lineFragmentPadding = 0
      textView.textStorage?.setAttributedString(attributedString)
      textView.isAutomaticLinkDetectionEnabled = false
      textView.linkTextAttributes = [:]  // use original attributes
      textView.delegate = context.coordinator
      textView.textContainer?.widthTracksTextView = true
      return textView
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

    final class Coordinator: NSObject, NSTextViewDelegate {
      let openURL: OpenURLAction
      private var lastAttributedStringHash: Int = 0

      init(openURL: OpenURLAction) {
        self.openURL = openURL
      }

      func isSame(as attributed: NSAttributedString) -> Bool {
        var hasher = Hasher()
        hasher.combine(attributed.string)
        // You can include other attribute-based hashing if necessary; keep it fast.
        hasher.combine(attributed.length)
        let h = hasher.finalize()
        return h == lastAttributedStringHash
      }

      func remember(attributedString: NSAttributedString) {
        var hasher = Hasher()
        hasher.combine(attributedString.string)
        hasher.combine(attributedString.length)
        lastAttributedStringHash = hasher.finalize()
      }
    }
  }

  // custom NSTextView to override copy behavior and additionally right click behavior
  class ModifiedCopyingTextView: NSTextView {

    // let swiftui handle context menu
    override func rightMouseDown(with event: NSEvent) {
      // instead of super.rightMouseDown, pass to next responder
      self.nextResponder?.rightMouseDown(with: event)
    }
    // could also handle mouseDown with control key pressed but i think its good to keep that.

    weak fileprivate var customCoordinator: _AttributedTextView.Coordinator?

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
      let selectedAttributedString = attributedString().attributedSubstring(
        from: selectedRange()
      )
      let selectedAttributedStringCopy = NSMutableAttributedString(
        attributedString: selectedAttributedString
      )

      selectedAttributedStringCopy.enumerateAttribute(
        NSAttributedString.Key.rawContent,
        in: NSMakeRange(0, selectedAttributedString.string.count),
        options: .reverse
      ) { value, range, _ in
        if let customText = value as? String {
          // Preserve existing attributes
          var range2 = NSRange(location: 0, length: 0)
          let attributes = selectedAttributedStringCopy.attributes(
            at: range.location,
            effectiveRange: &range2
          )

          selectedAttributedStringCopy.replaceCharacters(
            in: range,
            with: NSAttributedString(string: customText, attributes: attributes)
          )
        }
      }

      pboard.clearContents()
      pboard.writeObjects([selectedAttributedStringCopy.string as NSString])
      return true
    }
  }
#elseif os(iOS)
  import UIKit

  class ModifiedCopyingTextView: UITextView {

    override func canPerformAction(_ action: Selector, withSender sender: Any?)
      -> Bool
    {
      if action == #selector(copy(_:)) {
        return true
      }
      return super.canPerformAction(action, withSender: sender)
    }

    override func copy(_ sender: Any?) {
      let attributed = self.attributedText.attributedSubstring(
        from: selectedRange
      )

      let mutable = NSMutableAttributedString(attributedString: attributed)

      mutable.enumerateAttribute(
        NSAttributedString.Key.rawContent,
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

  private struct _AttributedTextView: UIViewRepresentable {
    var attributedString: NSAttributedString
    @Environment(\.lineLimit) private var lineLimit
    @Environment(\.openURL) private var openURL  // needed so we can signal that links were tapped.

    func makeCoordinator() -> Coordinator {
      Coordinator(openURL: openURL)
    }

    func makeUIView(context: Context) -> ModifiedCopyingTextView {
      let textView = ModifiedCopyingTextView()
      textView.delegate = context.coordinator
      textView.isEditable = false
      textView.isSelectable = true
      textView.isScrollEnabled = false
      textView.backgroundColor = .clear
      textView.textContainerInset = .zero
      textView.textContainer.lineFragmentPadding = 0
      textView.textContainer.maximumNumberOfLines = lineLimit ?? 0

      textView.textStorage.setAttributedString(attributedString)
      textView.dataDetectorTypes = []
      textView.isUserInteractionEnabled = true
      textView.linkTextAttributes = [:]

      // access layoutManager to force textkit compatibility mode on
      _ = textView.layoutManager
      return textView
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
      let fittingSize = CGSize(
        width: targetWidth,
        height: .greatestFiniteMagnitude
      )
      let size = uiView.sizeThatFits(fittingSize)
      return CGSize(width: targetWidth, height: size.height)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
      let openURL: OpenURLAction
      private var lastAttributedStringHash: Int = 0
      init(openURL: OpenURLAction) {
        self.openURL = openURL
      }

      func isSame(as attributed: NSAttributedString) -> Bool {
        var hasher = Hasher()
        hasher.combine(attributed.string)
        hasher.combine(attributed.length)
        let h = hasher.finalize()
        return h == lastAttributedStringHash
      }

      func remember(attributedString: NSAttributedString) {
        var hasher = Hasher()
        hasher.combine(attributedString.string)
        hasher.combine(attributedString.length)
        lastAttributedStringHash = hasher.finalize()
      }

      // tap link handler
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

#endif
