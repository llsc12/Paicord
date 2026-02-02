//
//  SelectableMarkdownText.swift
//  Paicord
//
//  Created by Tnixc on 01/02/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

/// MVP multi select
struct SelectableMarkdownText: View {
  let blocks: [BlockInfo]
  
  struct BlockInfo: Identifiable {
    let id: String
    let attributedString: NSAttributedString
  }
  
  init(blocks: [BlockInfo]) {
    self.blocks = blocks
  }
  
  var body: some View {
    #if os(macOS)
    VStack(alignment: .leading, spacing: 4) {
      SelectableTextContainer(blocks: blocks)
    }
    #else
    // unreachable
    EmptyView()
    #endif
  }
}

#if os(macOS)
private struct SelectableTextContainer: NSViewRepresentable {
  let blocks: [SelectableMarkdownText.BlockInfo]
  @Environment(\.openURL) private var openURL
  
  func makeNSView(context: Context) -> CombinedTextView {
    let textView = CombinedTextView()
    textView.isEditable = false
    textView.isSelectable = true
    textView.drawsBackground = false
    textView.textContainerInset = .zero
    textView.textContainer?.lineFragmentPadding = 0
    textView.textContainer?.widthTracksTextView = true
    textView.isAutomaticLinkDetectionEnabled = false
    textView.linkTextAttributes = [:]
    textView.delegate = context.coordinator
    textView.usesAdaptiveColorMappingForDarkAppearance = true
    
    updateTextStorage(textView: textView, blocks: blocks)
    
    return textView
  }
  
  func updateNSView(_ nsView: CombinedTextView, context: Context) {
    updateTextStorage(textView: nsView, blocks: blocks)
  }
  
  private func updateTextStorage(textView: CombinedTextView, blocks: [SelectableMarkdownText.BlockInfo]) {
    let combined = NSMutableAttributedString()
    
    for (index, block) in blocks.enumerated() {
      combined.append(block.attributedString)
      
      // add line break between blocks (except after the last one)
      if index < blocks.count - 1 {
        combined.append(NSAttributedString(string: "\n"))
      }
    }
    
    if textView.attributedString() != combined {
      textView.textStorage?.setAttributedString(combined)
    }
  }
  
  func sizeThatFits(
    _ proposal: ProposedViewSize,
    nsView: CombinedTextView,
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
    
    let usedRect = layoutManager.usedRect(for: textContainer)
    return CGSize(width: targetWidth, height: ceil(usedRect.height))
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(openURL: openURL)
  }
  
  final class Coordinator: NSObject, NSTextViewDelegate {
    let openURL: OpenURLAction
    
    init(openURL: OpenURLAction) {
      self.openURL = openURL
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

final class CombinedTextView: NSTextView {
  override func rightMouseDown(with event: NSEvent) {
    nextResponder?.rightMouseDown(with: event)
  }
  
  override func writeSelection(
    to pboard: NSPasteboard,
    type: NSPasteboard.PasteboardType
  ) -> Bool {
    let selected = attributedString().attributedSubstring(from: selectedRange())
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
#endif

#Preview {
  let block1 = SelectableMarkdownText.BlockInfo(
    id: "1",
    attributedString: NSAttributedString(string: "First paragraph with some text.")
  )
  let block2 = SelectableMarkdownText.BlockInfo(
    id: "2",
    attributedString: NSAttributedString(string: "Second paragraph with more text to select.")
  )
  
  SelectableMarkdownText(blocks: [block1, block2])
    .padding()
}
