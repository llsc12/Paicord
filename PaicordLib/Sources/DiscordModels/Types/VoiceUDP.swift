//
//  VoiceUDP.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 19/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation

/// https://docs.discord.food/topics/voice-connections#rtp-packet-structure
///
/// FIELD                    TYPE                                       DESCRIPTION                                                                                   SIZE
/// Version + Flags 1  Unsigned byte                          The RTP version and flags (always 0x80 for voice)                           1 byte
/// Payload Type 2     Unsigned byte                          The type of payload (0x78 with the default Opus configuration)        1 byte
/// Sequence              Unsigned short (big endian)    The sequence number of the packet                                                  2 bytes
/// Timestamp            Unsigned integer (big endian)  The RTC timestamp of the packet                                                     4 bytes
/// SSRC                    Unsigned integer (big endian)  The SSRC of the user                                                                       4 bytes
/// Payload                 Binary data                               Encrypted audio/video data                                                               n bytes
///
/// Discord expects a playout delay RTP extension header on every video packet.
public struct RTPPacket: Sendable {
  public init(
    payloadType: UInt8,
    sequence: UInt16,
    timestamp: UInt32,
    ssrc: UInt32,
    payload: Data,
    playoutDelay: (min: UInt16, max: UInt16)? = nil
  ) {
    self.payloadType = payloadType
    self.sequence = sequence
    self.timestamp = timestamp
    self.ssrc = ssrc
    self.payload = payload
    self.playoutDelay = playoutDelay
  }

  public var payloadType: UInt8
  public var sequence: UInt16
  public var timestamp: UInt32
  public var ssrc: UInt32
  public var payload: Data
  public var playoutDelay: (min: UInt16, max: UInt16)?

  public func encode() -> Data {
    var data = Data()

    // 1 byte version and flags
    let version: UInt8 = 0b10 << 6
    let extensionBit: UInt8 = (playoutDelay != nil) ? 0b00010000 : 0
    let firstByte = version | extensionBit
    data.append(firstByte)

    // 1 byte payload type
    data.append(payloadType)

    // 2 byte sequence
    withUnsafeBytes(of: sequence.bigEndian) { data.append(contentsOf: $0) }

    // 4 byte timestamp
    withUnsafeBytes(of: timestamp.bigEndian) { data.append(contentsOf: $0) }

    // 4 byte ssrc
    withUnsafeBytes(of: ssrc.bigEndian) { data.append(contentsOf: $0) }

    // extension
    if let delay = playoutDelay {
      data.append(playoutDelayExtension(min: delay.min, max: delay.max))
    }

    // payload
    data.append(payload)

    return data
  }

  private func playoutDelayExtension(min: UInt16, max: UInt16) -> Data {
    var ext = Data(capacity: 8)

    // RFC5285 header
    let profile = UInt16(0xBEDE).bigEndian
    let lengthWords = UInt16(1).bigEndian

    withUnsafeBytes(of: profile) { ext.append(contentsOf: $0) }
    withUnsafeBytes(of: lengthWords) { ext.append(contentsOf: $0) }

    // extension entry (id = 5, len = 2, 3 byte payload)
    let id: UInt8 = 5
    let len: UInt8 = 2  // encoded as len-1 in RFC5285
    let headerByte: UInt8 = (id << 4) | len
    ext.append(headerByte)

    // pack 12-bit min max
    let min12 = UInt32(min & 0x0FFF)
    let max12 = UInt32(max & 0x0FFF)
    let packed: UInt32 = (min12 << 12) | max12

    ext.append(UInt8((packed >> 16) & 0xFF))
    ext.append(UInt8((packed >> 8) & 0xFF))
    ext.append(UInt8(packed & 0xFF))

    // padding to 32 bit boundary
    ext.append(UInt8(0))

    return ext
  }

}
