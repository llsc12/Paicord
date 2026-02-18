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

    func makeNSView(context: Context) -> IntrinsicTextView {
      let textStorage = NSTextStorage()
      let layoutManager = NSLayoutManager()
      let textContainer = NSTextContainer()
      textContainer.maximumNumberOfLines = lineLimit ?? 0

      textStorage.addLayoutManager(layoutManager)
      layoutManager.addTextContainer(textContainer)

      let tv = IntrinsicTextView(frame: .zero, textContainer: textContainer)
      tv.isEditable = false
      tv.isSelectable = true
      tv.drawsBackground = false
      tv.textContainerInset = .zero
      tv.textContainer?.lineFragmentPadding = 0
      tv.textContainer?.widthTracksTextView = true
      tv.textContainer?.heightTracksTextView = false
      tv.isAutomaticLinkDetectionEnabled = false
      tv.linkTextAttributes = [:]
      tv.delegate = context.coordinator
      tv.customCoordinator = context.coordinator
      tv.usesAdaptiveColorMappingForDarkAppearance = true

      tv.setAttributedStringAndInvalidate(attributedString)
      tv.setLineLimitAndInvalidate(lineLimit)

      tv.setContentHuggingPriority(.required, for: .vertical)
      tv.setContentCompressionResistancePriority(.required, for: .vertical)
      tv.setContentHuggingPriority(.defaultLow, for: .horizontal)
      tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

      return tv
    }

    func updateNSView(_ nsView: IntrinsicTextView, context: Context) {
      nsView.customCoordinator = context.coordinator

      if nsView.attributedString() != attributedString {
        nsView.setAttributedStringAndInvalidate(attributedString)
      }

      nsView.setLineLimitAndInvalidate(lineLimit)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
      let openURL: OpenURLAction
      init(openURL: OpenURLAction) { self.openURL = openURL }

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

  final class IntrinsicTextView: ModifiedCopyingTextView {
    private var lastMeasuredWidth: CGFloat = -1
    private var lastLineLimit: Int? = nil

    func setAttributedStringAndInvalidate(_ s: NSAttributedString) {
      textStorage?.setAttributedString(s)
      invalidateIntrinsicAndLayout()
    }

    func setLineLimitAndInvalidate(_ lineLimit: Int?) {
      let normalized = (lineLimit == 0) ? nil : lineLimit
      if lastLineLimit != normalized {
        lastLineLimit = normalized
        textContainer?.maximumNumberOfLines = normalized ?? 0
        invalidateIntrinsicAndLayout()
      }
    }

    private func invalidateIntrinsicAndLayout() {
      invalidateIntrinsicContentSize()
      needsLayout = true
    }

    override func layout() {
      super.layout()

      let w = bounds.width
      if w > 0, abs(w - lastMeasuredWidth) > 0.5 {
        lastMeasuredWidth = w
        textContainer?.containerSize = CGSize(
          width: w,
          height: .greatestFiniteMagnitude
        )
        invalidateIntrinsicContentSize()
      }
    }

    override var intrinsicContentSize: NSSize {
      let w = bounds.width > 0 ? bounds.width : 400
      guard let layoutManager = layoutManager, let textContainer = textContainer
      else {
        return NSSize(width: w, height: 0)
      }

      textContainer.containerSize = CGSize(
        width: w,
        height: .greatestFiniteMagnitude
      )

      layoutManager.ensureLayout(for: textContainer)
      let used = layoutManager.usedRect(for: textContainer)

      return NSSize(width: w, height: ceil(used.height))
    }
  }

  class ModifiedCopyingTextView: NSTextView {
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

    func makeUIView(context: Context) -> IntrinsicTextView {
      let textStorage = NSTextStorage()
      let layoutManager = NSLayoutManager()
      let textContainer = NSTextContainer()

      textContainer.maximumNumberOfLines = lineLimit ?? 0
      textStorage.addLayoutManager(layoutManager)
      layoutManager.addTextContainer(textContainer)

      let tv = IntrinsicTextView(frame: .zero, textContainer: textContainer)
      tv.isEditable = false
      tv.isSelectable = true
      tv.isScrollEnabled = false
      tv.backgroundColor = .clear
      tv.textContainerInset = .zero
      tv.textContainer.lineFragmentPadding = 0
      tv.textContainer.widthTracksTextView = true
      tv.textContainer.heightTracksTextView = false
      tv.delegate = context.coordinator
      tv.dataDetectorTypes = []
      tv.linkTextAttributes = [:]

      tv.setAttributedTextPreservingSelection(attributedString)
      tv.setLineLimitAndInvalidate(lineLimit)

      tv.setContentHuggingPriority(.required, for: .vertical)
      tv.setContentCompressionResistancePriority(.required, for: .vertical)
      tv.setContentHuggingPriority(.defaultLow, for: .horizontal)
      tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

      return tv
    }

    func updateUIView(_ uiView: IntrinsicTextView, context: Context) {
      if uiView.attributedText != attributedString {
        uiView.setAttributedTextPreservingSelection(attributedString)
        uiView.invalidateIntrinsicAndLayout()
      }

      uiView.setLineLimitAndInvalidate(lineLimit)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
      let openURL: OpenURLAction
      init(openURL: OpenURLAction) { self.openURL = openURL }

      func textView(
        _ textView: UITextView,
        primaryActionFor textItem: UITextItem,
        defaultAction: UIAction
      ) -> UIAction? {
        switch textItem.content {
        case .link(let url):
          if PaicordChatLink(url: url) != nil {  // if parsing doesnt fail, handle internally
            openURL(url)
            return nil
          }
          fallthrough
        default:
          return defaultAction
        }
      }
    }
  }

  final class IntrinsicTextView: ModifiedCopyingTextView {
    private var lastMeasuredWidth: CGFloat = -1
    private var lastLineLimit: Int? = nil

    func setLineLimitAndInvalidate(_ lineLimit: Int?) {
      let normalized = (lineLimit == 0) ? nil : lineLimit
      if lastLineLimit != normalized {
        lastLineLimit = normalized
        textContainer.maximumNumberOfLines = normalized ?? 0
        invalidateIntrinsicAndLayout()
      }
    }

    fileprivate func invalidateIntrinsicAndLayout() {
      invalidateIntrinsicContentSize()
      setNeedsLayout()
      layoutIfNeeded()
    }

    override func layoutSubviews() {
      super.layoutSubviews()

      let w = bounds.width
      if w > 0, abs(w - lastMeasuredWidth) > 0.5 {
        lastMeasuredWidth = w
        textContainer.size = CGSize(width: w, height: .greatestFiniteMagnitude)
        invalidateIntrinsicContentSize()
      }
    }

    override var intrinsicContentSize: CGSize {
      let targetWidth = (bounds.width > 0) ? bounds.width : 400

      textContainer.size = CGSize(
        width: targetWidth,
        height: .greatestFiniteMagnitude
      )
      let used = layoutManager.usedRect(for: textContainer)

      return CGSize(width: targetWidth, height: ceil(used.height))
    }
  }

  class ModifiedCopyingTextView: UITextView {
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

    func setAttributedTextPreservingSelection(_ text: NSAttributedString) {
      let sel = selectedRange
      attributedText = text
      selectedRange = sel
    }
  }
#endif
