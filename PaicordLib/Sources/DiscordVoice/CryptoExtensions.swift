//
//  CryptoExtensions.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 23/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Crypto
import DiscordModels
import Foundation
import NIOCore

/// https://github.com/SwiftDiscordAudio/DiscordAudioKit/blob/main/Sources/DiscordAudioKit/CryptoMode.swift

extension VoiceGateway.EncryptionMode {
  func decrypt(
    buffer: consuming ByteBuffer,
    with key: SymmetricKey,
  ) -> Data? {
    guard
      let rtpNonce = buffer.readBytes(length: rtpNonceLength),
      let ciphertext = buffer.readData(
        length: buffer.readableBytes - tagLength
      ),
      let tag = buffer.readData(length: tagLength)
    else {
      return nil
    }

    var nonce = Data(repeating: 0, count: nonceLength)
    nonce.replaceSubrange(
      nonce.count - rtpNonce.count..<nonce.count,
      with: rtpNonce
    )

    switch self {
    case .aead_aes256_gcm_rtpsize:
      guard
        let nonce = try? AES.GCM.Nonce(data: nonce),
        let box = try? AES.GCM.SealedBox(
          nonce: nonce,
          ciphertext: ciphertext,
          tag: tag
        )
      else {
        return nil
      }
      return try? AES.GCM.open(box, using: key)

    case .aead_xchacha20_poly1305_rtpsize:
      guard
        let nonce = try? ChaChaPoly.Nonce(data: nonce),
        let box = try? ChaChaPoly.SealedBox(
          nonce: nonce,
          ciphertext: ciphertext,
          tag: tag
        )
      else {
        return nil
      }
      return try? ChaChaPoly.open(box, using: key)
    default:
      fatalError(
        "[Voice Crypto] Unsupported deprecated encryption mode: \(self)"
      )
    }
  }

  /// The length of the nonce as it is stored in the RTP packet
  private var rtpNonceLength: Int {
    switch self {
    case .aead_aes256_gcm_rtpsize:
      return 4
    case .aead_xchacha20_poly1305_rtpsize:
      return 4
    default:
      return 24
    }
  }

  /// The length of the nonce as required by the crypto algorithm
  private var nonceLength: Int {
    switch self {
    case .aead_aes256_gcm_rtpsize:
      // From `AES.GCM.defaultNonceByteCount`
      return 12
    case .xsalsa20_poly1305_lite_rtpsize:
      // Other implementations sometimes use 24, but swift-crypto
      // requires 12.
      // From `ChaChaPoly.nonceByteCount`
      return 12
    default:
      return 24
    }
  }

  /// The length of the authentication tag used by the crypto algorithm
  private var tagLength: Int {
    switch self {
    case .aead_aes256_gcm_rtpsize:
      // From `AES.GCM.tagByteCount`
      return 16
    case .xsalsa20_poly1305_lite_rtpsize:
      // From `ChaChaPoly.tagByteCount`
      return 16
    default:
      return 16
    }
  }
}
