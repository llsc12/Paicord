//
//  CameraPicker.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

#if os(iOS)
import MobileCoreServices
import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// A SwiftUI wrapper around UIImagePickerController that supports both photo and video capture.
/// Usage: present as a sheet and handle the returned `Media` in the completion.
struct CameraPicker: UIViewControllerRepresentable {
  enum Media {
    case photo(UIImage)
    case video(URL)
  }

  @Environment(\.presentationMode) private var presentationMode
  var allowEditing: Bool = false
  var completion: (Result<Media, Error>) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.delegate = context.coordinator
    picker.allowsEditing = allowEditing

    // allow both photo and video capture
    picker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]

    picker.videoQuality = .typeMedium
    
    // use the rear camera by default
    picker.cameraDevice = .rear

    return picker
  }

  func updateUIViewController(
    _ uiViewController: UIImagePickerController,
    context: Context
  ) {
    // nothing to update
  }

  class Coordinator: NSObject, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
  {
    let parent: CameraPicker

    init(parent: CameraPicker) {
      self.parent = parent
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.presentationMode.wrappedValue.dismiss()
      // you can send a custom cancellation error or ignore
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

      defer { parent.presentationMode.wrappedValue.dismiss() }

      // detect media type
      if let mediaType = info[.mediaType] as? String {
        if mediaType == UTType.image.identifier {
          // Photo
          let imageKey: UIImagePickerController.InfoKey =
            parent.allowEditing ? .editedImage : .originalImage
          if let image = info[imageKey] as? UIImage {
            parent.completion(.success(.photo(image)))
          } else {
            parent.completion(
              .failure(
                NSError(
                  domain: "CameraPicker",
                  code: -1,
                  userInfo: [NSLocalizedDescriptionKey: "Failed to get image"]
                )
              )
            )
          }
          return
        }

        if mediaType == UTType.movie.identifier {
          // Video
          if let mediaURL = info[.mediaURL] as? URL {
            parent.completion(.success(.video(mediaURL)))
          } else {
            parent.completion(
              .failure(
                NSError(
                  domain: "CameraPicker",
                  code: -2,
                  userInfo: [
                    NSLocalizedDescriptionKey: "Failed to get video URL"
                  ]
                )
              )
            )
          }
          return
        }
      }

      parent.completion(
        .failure(
          NSError(
            domain: "CameraPicker",
            code: -3,
            userInfo: [NSLocalizedDescriptionKey: "Unknown media type"]
          )
        )
      )
    }
  }
}
#endif
