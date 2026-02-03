//
//  AttachmentBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 22/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX
import UniformTypeIdentifiers

extension ChatView.InputBar {
  struct AttachmentPreviewBar: View {
    var inputVM: ChatView.InputBar.InputVM

    var body: some View {
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 8) {
          ForEach(inputVM.uploadItems) { attachment in
            AttachmentPreview(inputVM: inputVM, attachment: attachment) {
              // remove callback
              inputVM.uploadItems.removeAll { $0.id == attachment.id }
            }
            .transition(.blurReplace)
          }
        }
        .padding(.horizontal, 8)
      }
      .scrollClipDisabled()
      .padding(.top, 4)
    }

    struct AttachmentPreview: View {
      var inputVM: ChatView.InputBar.InputVM
      var attachment: ChatView.InputBar.InputVM.UploadItem
      var onRemove: () -> Void
      @State var image: Image? = nil

      private var fileInfo: (url: URL, size: Int64)? {
        guard case .file(_, let url, let size) = attachment else { return nil }
        return (url, size)
      }

      private var isMediaFile: Bool {
        guard let (url, _) = fileInfo else { return false }
        guard let typeIdentifier = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
              let utType = UTType(typeIdentifier) else { return false }
        let mediaTypes: [UTType] = [
          .image, .png, .jpeg, .gif, .webP, .heic, .heif, .tiff, .bmp,
          .movie, .video, .mpeg4Movie, .quickTimeMovie, .avi
        ]
        return mediaTypes.contains { utType.conforms(to: $0) }
      }

      var body: some View {
        Group {
          switch attachment {
          case .pickerItem:
            thumbnailPreviewView
              .task { self.image = await inputVM.getThumbnail(for: attachment) }
          case .file(_, let url, let size):
            if isMediaFile || image != nil {
              thumbnailPreviewView
                .task { self.image = await inputVM.getThumbnail(for: attachment) }
            } else {
              filePreviewView(url: url, size: size)
                .task { self.image = await inputVM.getThumbnail(for: attachment) }
            }
          #if os(iOS)
            case .cameraPhoto:
              thumbnailPreviewView
                .task { self.image = await inputVM.getThumbnail(for: attachment) }
            case .cameraVideo:
              thumbnailPreviewView
                .task { self.image = await inputVM.getThumbnail(for: attachment) }
          #endif
          }
        }
        .clipShape(.rounded)
        .overlay(alignment: .topTrailing) {
          Button {
            onRemove()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.white)
              .background(Color.black.opacity(0.7).clipShape(Circle()))
          }
          .frame(width: 10, height: 10)
          .offset(x: 2.5, y: -2.5)
        }
      }

      @ViewBuilder
      private var thumbnailPreviewView: some View {
        VStack {
          if let image {
            image
              .resizable()
              .scaledToFit()
              .scaledToFill()
              .maxWidth(60)
              .maxHeight(60)
              .aspectRatio(1, contentMode: .fill)
              .clipped()
          } else {
            Color.gray.opacity(0.3)
              .scaledToFill()
              .maxWidth(60)
              .maxHeight(60)
          }
        }
      }
      
      @ViewBuilder
      private func filePreviewView(url: URL, size: Int64) -> some View {
        HStack(spacing: 0) {
          Image(systemName: "doc.fill")
            .resizable()
            .scaledToFit()
            .padding(20)
            .height(60)
            .aspectRatio(1, contentMode: .fill)
            .background(Color.gray.opacity(0.3))

          VStack(alignment: .leading) {
            Text(url.lastPathComponent)
              .font(.caption)
              .lineLimit(2)
              .multilineTextAlignment(.leading)
            Text(
              ByteCountFormatter.string(
                fromByteCount: size,
                countStyle: .file
              )
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
          }
          .padding(5)
          .height(60)
          .minWidth(60)
          .maxWidth(120)
          .background(Color.black.opacity(0.3))
        }
      }
    }
  }
}
