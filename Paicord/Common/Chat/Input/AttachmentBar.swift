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
      @State var interval: TimeInterval? = nil

      private var fileInfo: (url: URL, size: Int64)? {
        guard case .file(_, let url, let size) = attachment else { return nil }
        return (url, size)
      }

      var body: some View {
        Group {
          if attachment.isMediaItem {
            thumbnailPreviewView
          } else if let url = fileInfo?.url, let size = fileInfo?.size {
            filePreviewView(
              url: url,
              size: size,
              image: image
            )
          }
        }
        .task(id: attachment.id) {
          guard image == nil else { return }
          self.image = await inputVM.getThumbnail(for: attachment)
        }
        .task(id: attachment.id) {
          guard interval == nil else { return }
          self.interval = await attachment.videoDuration()
        }
        .clipShape(.rounded)
        .overlay(alignment: .topTrailing) {
          Button {
            onRemove()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.white)
              .background(.black.opacity(0.7), in: .circle)
          }
          .buttonStyle(.borderless)
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
        .overlay(alignment: .bottomTrailing) {
          if let interval {
            let duration: Duration = .seconds(interval)
            Text(duration.formatted(.time(pattern: .minuteSecond)))
              .font(.caption2)
              .padding(3)
              .background(Color.black.opacity(0.7))
              .clipShape(.rect(cornerRadius: 4))
              .padding(5)
          }
        }
      }

      @ViewBuilder
      private func filePreviewView(url: URL, size: Int64, image: Image?)
        -> some View
      {
        HStack(spacing: 0) {
          if let image {
            image
            .resizable()
            .scaledToFit()
            .padding(10)
            .height(60)
            .aspectRatio(1, contentMode: .fill)
            .background(Color.gray.opacity(0.3))
          } else {
            Image(systemName: "doc.fill")
              .resizable()
              .scaledToFit()
              .padding(20)
              .height(60)
              .aspectRatio(1, contentMode: .fill)
              .background(Color.gray.opacity(0.3))
          }

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
