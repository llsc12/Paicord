//
//  DocumentPickerViewController.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 04/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//  

import SwiftUIX

#if os(iOS)
  struct DocumentPickerViewController: UIViewControllerRepresentable {
    @Environment(\.colorScheme) var colorScheme
    let callback: ([URL]) -> Void

    init(callback: @escaping ([URL]) -> Void) {
      self.callback = callback
    }

    func makeUIViewController(context: Context)
      -> UIDocumentPickerViewController
    {
      // open any files
      let controller = UIDocumentPickerViewController(
        forOpeningContentTypes: [.data]
      )
      controller.allowsMultipleSelection = true
      controller.shouldShowFileExtensions = true
      controller.delegate = context.coordinator
      // it appears the color theme isn't inherited properly.
      controller.overrideUserInterfaceStyle = .init(colorScheme)
      return controller
    }

    func updateUIViewController(
      _ uiViewController: UIDocumentPickerViewController,
      context: Context
    ) {
      uiViewController.overrideUserInterfaceStyle = .init(colorScheme)
    }

    func makeCoordinator() -> Coordinator {
      Coordinator(callback: callback)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
      let callback: ([URL]) -> Void

      init(callback: @escaping ([URL]) -> Void) {
        self.callback = callback
      }

      func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
      ) {
        self.callback(urls)
      }

      func documentPickerWasCancelled(
        _ controller: UIDocumentPickerViewController
      ) {}
    }
  }
#endif
