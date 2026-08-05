//
//  PaicordImagePipeline.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 04/08/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation
import Nuke

final class AnimatableImageDecoder: ImageDecoding, @unchecked Sendable {
  private let base = ImageDecoders.Default()

  func decode(_ data: Data) throws -> ImageContainer {
    var container = try base.decode(data)
    switch container.type {
    case .some(.gif):
      break  // base already keeps it
    case .some(.webp):
      container.data = data
    case .some(.png) where Self.isAnimatedPNG(data):
      container.data = data
    default:
      break
    }
    return container
  }

  // check for animated png by looking for the acTL chunk before any IDAT chunks
  private static func isAnimatedPNG(_ data: Data) -> Bool {
    let pngSignature: [UInt8] = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    ]
    let acTLSignature: [UInt8] = [0x61, 0x63, 0x54, 0x4C]  // "acTL"
    let idatSignature: [UInt8] = [0x49, 0x44, 0x41, 0x54]  // "IDAT"

    guard data.count >= (pngSignature.count + 4) else { return false }

    return data.withUnsafeBytes { (rawBuffer: UnsafeRawBufferPointer) -> Bool in
      guard let baseAddress = rawBuffer.baseAddress else { return false }

      // ensure png
      for i in 0..<pngSignature.count {
        if baseAddress.load(fromByteOffset: i, as: UInt8.self)
          != pngSignature[i]
        {
          return false
        }
      }

      let endOffset = data.count - 3
      var offset = pngSignature.count

      while offset < endOffset {
        let b0 = baseAddress.load(fromByteOffset: offset, as: UInt8.self)
        let b1 = baseAddress.load(fromByteOffset: offset + 1, as: UInt8.self)
        let b2 = baseAddress.load(fromByteOffset: offset + 2, as: UInt8.self)
        let b3 = baseAddress.load(fromByteOffset: offset + 3, as: UInt8.self)

        // check for acTL
        if b0 == acTLSignature[0] && b1 == acTLSignature[1]
          && b2 == acTLSignature[2] && b3 == acTLSignature[3]
        {
          return true
        }

        // exit if idat found
        if b0 == idatSignature[0] && b1 == idatSignature[1]
          && b2 == idatSignature[2] && b3 == idatSignature[3]
        {
          return false
        }

        offset += 1
      }

      return false
    }
  }
}

enum PaicordImagePipeline {
  static func configure() {
    ImageDecoderRegistry.shared.register { _ in AnimatableImageDecoder() }

    ImagePipeline.shared = ImagePipeline {
      $0.dataCache = try? DataCache(name: "com.llsc12.paicord.imagecache")
      $0.dataCachePolicy = .automatic
      $0.imageCache = ImageCache.shared
      // large attachments break by default
      $0.maximumResponseDataSize = nil
    }
  }
}
