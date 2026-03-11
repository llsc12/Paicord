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
  static var supportedCases: [Self] {
    [
      .aead_aes256_gcm_rtpsize,
      .aead_xchacha20_poly1305_rtpsize,
    ]
  }

  func decrypt(
    fullPacket: Data,
    with key: SymmetricKey,
    hasExtension: Bool
  ) -> Data? {
    let aadSize = hasExtension ? 16 : 12
    let rtpHeaderAAD = fullPacket.prefix(aadSize)

    let rtpNonceSuffix = fullPacket.suffix(4)
    let tagSize = 16

    let ciphertextStart = aadSize
    let ciphertextEnd = fullPacket.count - tagSize - 4

    guard ciphertextEnd > ciphertextStart else { return nil }

    let ciphertext = fullPacket[ciphertextStart..<ciphertextEnd]
    let tag = fullPacket[ciphertextEnd..<(ciphertextEnd + tagSize)]

    var nonceData = Data(repeating: 0, count: self.nonceLength)
    nonceData.replaceSubrange(0..<4, with: rtpNonceSuffix)

    switch self {
    case .aead_aes256_gcm_rtpsize:
      guard let nonce = try? AES.GCM.Nonce(data: nonceData),
        let box = try? AES.GCM.SealedBox(
          nonce: nonce,
          ciphertext: ciphertext,
          tag: tag
        )
      else { return nil }

      return try? AES.GCM.open(box, using: key, authenticating: rtpHeaderAAD)

    case .aead_xchacha20_poly1305_rtpsize:
      guard let nonce = try? ChaChaPoly.Nonce(data: nonceData),
        let box = try? ChaChaPoly.SealedBox(
          nonce: nonce,
          ciphertext: ciphertext,
          tag: tag
        )
      else { return nil }

      return try? ChaChaPoly.open(box, using: key, authenticating: rtpHeaderAAD)

    default:
      return nil
    }
  }

  func encrypt(
    buffer: consuming Data,
    using key: SymmetricKey,
    additionalData: Data,
    sequence: UInt32? = nil
  ) -> (ciphertext: Data, tag: Data, nonceSuffix: Data)? {

    let nonceSuffixValue: UInt32 = sequence ?? .random(in: .min ... .max)
    var leNonceSuffix = nonceSuffixValue.littleEndian
    let nonceSuffix = withUnsafeBytes(of: &leNonceSuffix) { Data($0) }

    var nonceData = Data(repeating: 0, count: self.nonceLength)
    nonceData.replaceSubrange(0..<nonceSuffix.count, with: nonceSuffix)

    switch self {
    case .aead_aes256_gcm_rtpsize:
      guard let aesNonce = try? AES.GCM.Nonce(data: nonceData) else {
        return nil
      }
      guard
        let sealed = try? AES.GCM.seal(
          buffer,
          using: key,
          nonce: aesNonce,
          authenticating: additionalData
        )
      else { return nil }
      return (sealed.ciphertext, sealed.tag, nonceSuffix)

    case .aead_xchacha20_poly1305_rtpsize:
      guard let chachaNonce = try? ChaChaPoly.Nonce(data: nonceData) else {
        return nil
      }
      guard
        let sealed = try? ChaChaPoly.seal(
          buffer,
          using: key,
          nonce: chachaNonce,
          authenticating: additionalData
        )
      else { return nil }
      return (sealed.ciphertext, sealed.tag, nonceSuffix)
    default:
      fatalError("[Voice Crypto] Unsupported encryption mode \(self)")
    }
  }

  private func buildEncryptedPacket(
    rtpHeader: Data,
    ciphertext: Data,
    tag: Data,
    nonceSuffix: Data
  ) -> ByteBuffer {

    var buffer = ByteBuffer()
    buffer.writeBytes(rtpHeader)
    buffer.writeBytes(ciphertext)
    buffer.writeBytes(tag)
    buffer.writeBytes(nonceSuffix)

    return buffer
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
