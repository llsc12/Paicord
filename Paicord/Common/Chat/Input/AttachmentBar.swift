//
//  AttachmentBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 22/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

extension ChatView.InputBar {
  struct AttachmentPreviewBar: View {
    var inputVM: ChatView.InputBar.InputVM

    var body: some View {
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 8) {
          ForEach(inputVM.uploadItems) { attachment in
            AttachmentPreview(inputVM: inputVM, attachment: attachment) {
              inputVM.uploadItems.removeAll { $0.id == attachment.id }
            }
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
      var body: some View {
        Group {
          switch attachment {
          case .pickerItem:
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
            .task {
              self.image = await inputVM.getThumbnail(for: attachment)
            }
          case .file(_, let url, let size):
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
          #if os(iOS)
            case .cameraPhoto:
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
              .task {
                self.image = await inputVM.getThumbnail(for: attachment)
              }
            case .cameraVideo:
              VStack {
                Image(systemName: "video.fill")
                  .resizable()
                  .scaledToFit()
                  .padding(20)
                  .background(Color.gray.opacity(0.3))
                  .aspectRatio(1, contentMode: .fill)
                // TODO: get this video preview working
              }
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
    }
  }
}
