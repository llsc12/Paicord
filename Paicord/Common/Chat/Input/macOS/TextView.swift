//
//  TextView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 04/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import SwiftUIX

#if os(macOS)
  extension ChatView.InputBar {
    struct TextView: View {
      var prompt: String
      @Binding var text: String
      var submit: () -> Void
      var onPasteFiles: (([URL]) -> Void)?

      init(
        _ prompt: String,
        text: Binding<String>,
        submit: @escaping () -> Void = {},
        onPasteFiles: (([URL]) -> Void)? = nil
      ) {
        self.prompt = prompt
        self._text = text
        self.submit = submit
        self.onPasteFiles = onPasteFiles
      }

      var body: some View {
        _TextView(text: $text, onSubmit: submit, onPasteFiles: onPasteFiles)
          .overlay(alignment: .leading) {
            if text.isEmpty {
              Text(prompt)
                .foregroundStyle(.secondary)
                .padding(5)
                .allowsHitTesting(false)
            }
          }
      }

      private struct _TextView: NSViewRepresentable {
        @Binding var text: String
        var onSubmit: () -> Void
        var onPasteFiles: (([URL]) -> Void)?
        let maxHeight: CGFloat = 150

        func makeNSView(context: Context) -> NSScrollView {
          let textStorage = NSTextStorage()
          let layoutManager = NSLayoutManager()
          textStorage.addLayoutManager(layoutManager)
          let textContainer = NSTextContainer()
          layoutManager.addTextContainer(textContainer)

          let textView = SubmissiveTextView(
            frame: .zero,
            textContainer: textContainer,
            undoManager: context.environment.undoManager
          )
          textView.isEditable = true
          textView.isRichText = false
          textView.importsGraphics = true
          textView.isVerticallyResizable = true
          textView.isHorizontallyResizable = false
          textView.textContainer?.widthTracksTextView = true
          textView.textContainerInset = .zero
          textView.drawsBackground = false
          textView.typingAttributes = [
            .font: preferredBodyFont(),
            .foregroundColor: labelColor(),
          ]
          textView.delegate = context.coordinator
          textView.onSubmit = onSubmit
          textView.onPasteFiles = onPasteFiles
          textView.minSize = .zero
          textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
          )

          let scrollView = NSScrollView()
          scrollView.documentView = textView
          scrollView.hasVerticalScroller = true
          scrollView.drawsBackground = false
          scrollView.borderType = .noBorder

          textView.autoresizingMask = [.width]

          return scrollView
        }

        func sizeThatFits(
          _ proposal: ProposedViewSize,
          nsView: NSScrollView,
          context: Context
        ) -> CGSize? {
          guard let textView = nsView.documentView as? NSTextView else {
            return nil
          }
          if let layoutManager = textView.layoutManager,
            let textContainer = textView.textContainer
          {
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            let contentHeight =
              usedRect.height + textView.textContainerInset.height * 2
            return CGSize(
              width: proposal.width ?? usedRect.width,
              height: min(contentHeight, maxHeight)
            )
          }
          return nil
        }

        func updateNSView(_ scrollView: NSScrollView, context: Context) {
          guard let textView = scrollView.documentView as? NSTextView else {
            return
          }

          if textView.string != text {
            textView.string = text
          }
        }

        func makeCoordinator() -> Coordinator {
          Coordinator(self)
        }

        class Coordinator: NSObject, NSTextViewDelegate {
          var parent: _TextView

          init(_ parent: _TextView) {
            self.parent = parent
          }

          func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
              return
            }
            parent.text = textView.string
          }
        }

        class SubmissiveTextView: NSTextView {
          var onSubmit: (() -> Void)?
          var onPasteFiles: (([URL]) -> Void)?
          weak var undoManagerRef: UndoManager?

          init(
            frame frameRect: NSRect,
            textContainer container: NSTextContainer?,
            undoManager: UndoManager? = nil
          ) {
            self.undoManagerRef = undoManager
            super.init(frame: frameRect, textContainer: container)
          }

          required init?(coder: NSCoder) {
            super.init(coder: coder)
          }

          override var undoManager: UndoManager? {
            if let undoManagerRef {
              return undoManagerRef
            } else {
              return super.undoManager
            }
          }

          override var acceptableDragTypes: [NSPasteboard.PasteboardType] {
            [
              NSPasteboard.PasteboardType.string,
              NSPasteboard.PasteboardType.rtf,
              NSPasteboard.PasteboardType.rtfd,
              NSPasteboard.PasteboardType.html,
            ]
          }

          override func paste(_ sender: Any?) {
            let pasteboard = NSPasteboard.general

            if let urls = pasteboard.readObjects(
              forClasses: [NSURL.self],
              options: nil
            ) as? [URL], !urls.isEmpty {
              let validURLs = urls.filter {
                $0.isFileURL && FileManager.default.fileExists(atPath: $0.path)
              }
              if !validURLs.isEmpty {
                onPasteFiles?(validURLs)
                return
              }
            }

            if let fileURLs = pasteboard.propertyList(forType: .fileURL)
              as? String,
              let url = URL(string: fileURLs),
              FileManager.default.fileExists(atPath: url.path)
            {
              onPasteFiles?([url])
              return
            }

            if pasteboard.types?.contains(.png) == true,
              let imageData = pasteboard.data(forType: .png),
              let fileURL = saveImageToTemp(data: imageData, extension: "png")
            {
              onPasteFiles?([fileURL])
              return
            }

            let jpegType = NSPasteboard.PasteboardType(rawValue: "public.jpeg")
            if pasteboard.types?.contains(jpegType) == true,
              let imageData = pasteboard.data(forType: jpegType),
              let fileURL = saveImageToTemp(data: imageData, extension: "jpg")
            {
              onPasteFiles?([fileURL])
              return
            }

            let heicType = NSPasteboard.PasteboardType(rawValue: "public.heic")
            if pasteboard.types?.contains(heicType) == true,
              let imageData = pasteboard.data(forType: heicType),
              let fileURL = saveImageToTemp(data: imageData, extension: "heic")
            {
              onPasteFiles?([fileURL])
              return
            }

            if pasteboard.types?.contains(.tiff) == true,
              let imageData = pasteboard.data(forType: .tiff),
              let bitmapRep = NSBitmapImageRep(data: imageData),
              let pngData = bitmapRep.representation(
                using: .png,
                properties: [:]
              ),
              let fileURL = saveImageToTemp(data: pngData, extension: "png")
            {
              onPasteFiles?([fileURL])
              return
            }

            if let image = NSImage(pasteboard: pasteboard), image.isValid,
              let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(
                using: .png,
                properties: [:]
              ),
              let fileURL = saveImageToTemp(data: pngData, extension: "png")
            {
              onPasteFiles?([fileURL])
              return
            }

            super.paste(sender)
          }

          private func saveImageToTemp(data: Data, extension ext: String)
            -> URL?
          {
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(
              UUID().uuidString + "." + ext
            )
            do {
              try data.write(to: fileURL)
              return fileURL
            } catch {
              return nil
            }
          }

          override func keyDown(with event: NSEvent) {
            if event.keyCode == 36 {  // Return key
              let shiftPressed = event.modifierFlags.contains(.shift)
              if !shiftPressed {
                onSubmit?()
                return
              }
            }
            super.keyDown(with: event)
          }
        }

        func preferredBodyFont() -> Any {
          return NSFont.systemFont(ofSize: NSFont.systemFontSize)
        }

        func labelColor() -> Any {
          return NSColor.labelColor
        }
      }
    }
  }
#endif
