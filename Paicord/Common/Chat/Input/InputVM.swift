//
//  InputVM.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import PhotosUI
import SwiftUIX

extension ChatView.InputBar {
  @Observable
  class InputVM {
    var channelStore: ChannelStore
    init(channelStore: ChannelStore) {
      self.channelStore = channelStore
    }

    /// The text field content
    var content: String = ""
    #if os(iOS)
      /// Photos selected from the system photo picker
      var selectedPhotos: [PhotosPickerItem] = [] {
        didSet {
          // this needs to figure out what items were added and removed from selectedPhotos and sync uploadItems accordingly
          let uploadItemsPhotoItems = uploadItems.compactMap {
            item -> PhotosPickerItem? in
            switch item {
            case .pickerItem(_, let photoItem):
              return photoItem
            default:
              return nil
            }
          }

          // find added items
          for photoItem in selectedPhotos {
            if uploadItemsPhotoItems.contains(photoItem) == false {
              let uploadItem = UploadItem.pickerItem(
                id: UUID(),
                item: photoItem
              )
              uploadItems.append(uploadItem)
            }
          }

          // remove deleted items
          for uploadItem in uploadItems {
            switch uploadItem {
            case .pickerItem(_, let photoItem):
              if selectedPhotos.contains(photoItem) == false {
                if let index = uploadItems.firstIndex(of: uploadItem) {
                  uploadItems.remove(at: index)
                }
              }
            default: continue
            }
          }

          // if the addition of new photos caused uploadItems to exceed 10, trim it
          if uploadItems.count > 10 {
            uploadItems = Array(uploadItems.prefix(10))
          }
          
          // prune selected photos again
          for uploadItem in uploadItems {
            switch uploadItem {
            case .pickerItem(_, let photoItem):
              if selectedPhotos.contains(photoItem) == false {
                if let index = uploadItems.firstIndex(of: uploadItem) {
                  uploadItems.remove(at: index)
                }
              }
            default: continue
            }
          }
        }
      }

    #endif
    /// Used to receive files from the file importer
    var selectedFiles: [URL] = [] {
      didSet {
        // when this is set, add the files to uploadItems
        for fileURL in selectedFiles {
          // get file size
          let fileSize: Int64
          do {
            let canAccess = fileURL.startAccessingSecurityScopedResource()
            defer {
              if canAccess { fileURL.stopAccessingSecurityScopedResource() }
            }

            let fileAttributes = try FileManager.default.attributesOfItem(
              atPath: fileURL.path
            )
            fileSize = fileAttributes[.size] as? Int64 ?? 0
          } catch {
            fileSize = 0
          }

          let uploadItem = UploadItem.file(
            id: UUID(),
            url: fileURL,
            size: fileSize
          )
          uploadItems.append(uploadItem)
        }
        // used to clear the array here but that causes recursion until stack overflow oops
        // its fine, setting this array again from the file importer will reset this array with new files to add as needed.

        // if the addition of new files caused uploadItems to exceed 10, trim it
        if uploadItems.count > 10 {
          uploadItems = Array(uploadItems.prefix(10))
        }
      }
    }
    
    /// Contains a reference to the message being replied to or edited, if any, inside of an action enum
    var messageAction: MessageAction? = nil {
      didSet {
        // when this is set to edit, set content to the message content
        if let action = messageAction {
          switch action {
          case .edit(let message):
            content = message.content
            uploadItems = [] // cant do anything other than edit text when editing a message
          case .reply:
            break
          }
        }
      }
    }

    /// The input bar displays items from this.
    var uploadItems: [UploadItem] = [] {
      didSet {
        // remove any selectedPhotos that are no longer in uploadItems
        #if os(iOS)
          let uploadItemsPhotoItems = uploadItems.compactMap {
            item -> PhotosPickerItem? in
            switch item {
            case .pickerItem(_, let photoItem):
              return photoItem
            default:
              return nil
            }
          }
          // remove deleted items
          for photoItem in selectedPhotos {
            if uploadItemsPhotoItems.contains(photoItem) == false {
              if let index = selectedPhotos.firstIndex(of: photoItem) {
                selectedPhotos.remove(at: index)
              }
            }
          }
        #endif
      }
    }

    func copy() -> InputVM {
      let vm = InputVM(channelStore: channelStore)
      #if os(iOS)
        vm.selectedPhotos = selectedPhotos
      #endif
      vm.uploadItems = uploadItems
      vm.messageAction = messageAction
      vm.content = content
      return vm
    }

    func reset() {
      #if os(iOS)
        selectedPhotos = []
      #endif
      selectedFiles = []
      uploadItems = []
      messageAction = nil
      content = ""
    }
  }
}

extension ChatView.InputBar.InputVM {
  enum MessageAction {
    case reply(message: DiscordChannel.Message, mention: Bool)
    case edit(message: DiscordChannel.Message)
  }
  
  enum UploadItem: Identifiable, Equatable {
    static func == (lhs: ChatView.InputBar.InputVM.UploadItem, rhs: ChatView.InputBar.InputVM.UploadItem) -> Bool
    {
      return lhs.id == rhs.id
    }

    case pickerItem(id: UUID, item: PhotosPickerItem)
    case file(id: UUID, url: URL, size: Int64)
    #if os(iOS)
      case cameraPhoto(id: UUID, image: UIImage)
      case cameraVideo(id: UUID, url: URL)
    #endif

    var id: UUID {
      switch self {
      #if os(iOS)
        case .pickerItem(let id, _),
          .file(let id, _, _),
          .cameraPhoto(let id, _),
          .cameraVideo(let id, _):
          return id
      #else
        case .pickerItem(let id, _),
          .file(let id, _, _):
          return id
      #endif
      }
    }

    func filesize() async -> Int? {
      switch self {
      case .pickerItem(_, let item):
        let data =
          try? await item.loadTransferable(type: Data.self)?.count ?? 0
        if let data {
          return Int(data)
        } else {
          return nil
        }
      case .file(_, _, let size):
        return Int(size)
      #if os(iOS)
        case .cameraPhoto(_, let image):
          if let imageData = image.pngData() {
            return Int(imageData.count)
          } else {
            return nil
          }
        case .cameraVideo(_, let url):
          do {
            let fileAttributes = try FileManager.default.attributesOfItem(
              atPath: url.path
            )
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            return Int(fileSize)
          } catch {
            return nil
          }
      #endif
      }
    }
  }

  func getThumbnail(for item: UploadItem) async -> Image? {
    switch item {
    case .pickerItem(_, let photoItem):
      if let thumbnail = try? await loadTransferable(from: photoItem) {
        return thumbnail.image
      } else {
        return nil
      }
    #if os(iOS)
      case .cameraPhoto(_, let image):
        return Image(uiImage: image)
      case .cameraVideo(_, let url):
        return nil  // TODO: generate thumbnail from video
    #endif
    case .file(_, let url, _):
      return nil
    }
  }

  private func loadTransferable(from imageSelection: PhotosPickerItem)
    async throws -> Thumbnail?
  {
    try await imageSelection.loadTransferable(type: Thumbnail.self)
  }
}

struct Thumbnail: Transferable {
  let image: Image

  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(importedContentType: .image) { data in
      #if canImport(AppKit)
        guard let nsImage = NSImage(data: data) else {
          throw NSError(
            domain: "Thumbnail",
            code: -1,
            userInfo: [
              NSLocalizedDescriptionKey: "Failed to create NSImage from data."
            ]
          )
        }
        let image = Image(nsImage: nsImage)
        return Thumbnail(image: image)
      #elseif canImport(UIKit)
        guard let uiImage = UIImage(data: data) else {
          throw NSError(
            domain: "Thumbnail",
            code: -1,
            userInfo: [
              NSLocalizedDescriptionKey: "Failed to create UIImage from data."
            ]
          )
        }
        let image = Image(uiImage: uiImage)
        return Thumbnail(image: image)
      #else
        throw NSError(
          domain: "Thumbnail",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unsupported platform for Thumbnail."
          ]
        )
      #endif
    }
  }
}
