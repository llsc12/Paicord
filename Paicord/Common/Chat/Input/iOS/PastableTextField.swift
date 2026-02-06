//
//  PastableTextField.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 04/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import SwiftUIX

#if os(iOS)
  extension ChatView.InputBar {

    struct PastableTextField: UIViewRepresentable {
      var placeholder: String
      @Binding var text: String
      @Binding var isFocused: Bool
      var onPasteFiles: (([URL]) -> Void)?

      func makeUIView(context: Context) -> PastableUITextView {
        let textView = PastableUITextView()
        textView.delegate = context.coordinator
        textView.onPasteFiles = onPasteFiles
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
      }

      func updateUIView(_ textView: PastableUITextView, context: Context) {
        if textView.text != text {
          textView.text = text
        }

        textView.onPasteFiles = onPasteFiles

        context.coordinator.updatePlaceholder(
          textView,
          placeholder: placeholder,
          isEmpty: text.isEmpty
        )

        if isFocused {
          textView.becomeFirstResponder()
        } else {
          textView.resignFirstResponder()
        }
      }

      func makeCoordinator() -> Coordinator {
        Coordinator(self)
      }

      class Coordinator: NSObject, UITextViewDelegate {
        var parent: PastableTextField
        var placeholderLabel: UILabel?

        init(_ parent: PastableTextField) {
          self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
          parent.text = textView.text
          updatePlaceholder(
            textView,
            placeholder: parent.placeholder,
            isEmpty: textView.text.isEmpty
          )
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
          if parent.isFocused == false {
            parent.isFocused = true
          }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
          if parent.isFocused == true {
            parent.isFocused = false
          }
        }

        func updatePlaceholder(
          _ textView: UITextView,
          placeholder: String,
          isEmpty: Bool
        ) {
          if placeholderLabel == nil {
            let label = UILabel()
            label.text = placeholder
            label.font = textView.font
            label.textColor = .placeholderText
            label.translatesAutoresizingMaskIntoConstraints = false
            textView.addSubview(label)
            NSLayoutConstraint.activate([
              label.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
              label.topAnchor.constraint(equalTo: textView.topAnchor),
            ])
            placeholderLabel = label
          }
          placeholderLabel?.isHidden = !isEmpty
        }
      }

      class PastableUITextView: UITextView {
        var onPasteFiles: (([URL]) -> Void)?

        override func canPerformAction(
          _ action: Selector,
          withSender sender: Any?
        ) -> Bool {
          if action == #selector(paste(_:)) {
            if UIPasteboard.general.hasImages {
              return true
            }
          }
          return super.canPerformAction(action, withSender: sender)
        }

        // override paste to get data
        override func paste(_ sender: Any?) {
          let pasteboard = UIPasteboard.general

          if pasteboard.hasImages, let images = pasteboard.images,
            !images.isEmpty
          {
            let urls = images.compactMap { image -> URL? in
              let tempDir = FileManager.default.temporaryDirectory
              let fileURL = tempDir.appendingPathComponent(
                UUID().uuidString + ".png"
              )
              guard let imageData = image.pngData() else { return nil }
              do {
                try imageData.write(to: fileURL)
                return fileURL
              } catch {
                return nil
              }
            }
            if !urls.isEmpty {
              onPasteFiles?(urls)
              return
            }
          }
          // difficult to handle file urls, security scoped resources require fileimporter or documentpicker
          //        if pasteboard.hasURLs, let pasteURLs = pasteboard.urls {
          //          let fileURLs = pasteURLs.filter {
          //            $0.isFileURL && FileManager.default.fileExists(atPath: $0.path)
          //          }
          //          if !fileURLs.isEmpty {
          //            onPasteFiles?(fileURLs)
          //            return
          //          }
          //        }

          super.paste(sender)
        }
      }
    }
  }
#endif
