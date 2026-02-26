/// https://github.com/SwiftDiscordAudio/DiscordAudioKit/blob/main/Sources/DiscordRTP/RTP.swift

import NIOCore

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

/// Represents a Real-time Transport Protocol (RTP) packet used for audio streaming.
/// https://datatracker.ietf.org/doc/html/rfc3550#section-5.1
public struct RTPPacket: RawRepresentable {
  // MARK: - First byte

  /// This field identifies the version of RTP.  The version defined by
  /// this specification is two (2).  (The value 1 is used by the first
  /// draft version of RTP and the value 0 is used by the protocol
  /// initially implemented in the "vat" audio tool.)
  ///
  /// 2 bits
  public let version: UInt8

  /// If the padding bit is set, the packet contains one or more
  /// additional padding octets at the end which are not part of the
  /// payload.  The last octet of the padding contains a count of how
  /// many padding octets should be ignored, including itself.  Padding
  /// may be needed by some encryption algorithms with fixed block sizes
  /// or for carrying several RTP packets in a lower-layer protocol data
  /// unit.
  ///
  /// 1 bit
  public let padding: Bool

  /// If the extension bit is set, the fixed header MUST be followed by
  /// exactly one header extension, with a format defined in
  /// [Section 5.3.1](https://datatracker.ietf.org/doc/html/rfc3550#section-5.3.1).
  ///
  /// 1 bit
  public let `extension`: Bool

  // MARK: - Second byte

  /// The interpretation of the marker is defined by a profile.  It is
  /// intended to allow significant events such as frame boundaries to
  /// be marked in the packet stream.  A profile MAY define additional
  /// marker bits or specify that there is no marker bit by changing the
  /// number of bits in the payload type field
  ///
  /// 1 bit
  public let marker: Bool

  /// This field identifies the format of the RTP payload and determines
  /// its interpretation by the application.  A profile MAY specify a
  /// default static mapping of payload type codes to payload formats.
  /// Additional payload type codes MAY be defined dynamically through
  /// non-RTP means (see Section 3).  A set of default mappings for
  /// audio and video is specified in the companion RFC 3551 [1].  An
  /// RTP source MAY change the payload type during a session, but this
  /// field SHOULD NOT be used for multiplexing separate media streams
  /// (see Section 5.2).
  ///
  /// A receiver MUST ignore packets with payload types that it does not
  /// understand.
  ///
  /// 7 bits
  public let payloadType: RTPType

  // MARK: - Byte-aligned fields

  /// The sequence number increments by one for each RTP data packet
  /// sent, and may be used by the receiver to detect packet loss and to
  /// restore packet sequence.  The initial value of the sequence number
  /// SHOULD be random (unpredictable) to make known-plaintext attacks
  /// on encryption more difficult, even if the source itself does not
  /// encrypt according to the method in Section 9.1, because the
  /// packets may flow through a translator that does.
  ///
  /// 16 bits
  public let sequence: UInt16

  /// The timestamp reflects the sampling instant of the first octet in
  /// the RTP data packet.  The sampling instant MUST be derived from a
  /// clock that increments monotonically and linearly in time to allow
  /// synchronization and jitter calculations (see Section 6.4.1).  The
  /// resolution of the clock MUST be sufficient for the desired
  /// synchronization accuracy and for measuring packet arrival jitter
  /// (one tick per video frame is typically not sufficient).  The clock
  /// frequency is dependent on the format of data carried as payload
  /// and is specified statically in the profile or payload format
  /// specification that defines the format, or MAY be specified
  /// dynamically for payload formats defined through non-RTP means.  If
  /// RTP packets are generated periodically, the nominal sampling
  /// instant as determined from the sampling clock is to be used, not a
  /// reading of the system clock.  As an example, for fixed-rate audio
  /// the timestamp clock would likely increment by one for each
  /// sampling period.  If an audio application reads blocks covering
  /// 160 sampling periods from the input device, the timestamp would be
  /// increased by 160 for each such block, regardless of whether the
  /// block is transmitted in a packet or dropped as silent.
  ///
  /// The initial value of the timestamp SHOULD be random, as for the
  /// sequence number.  Several consecutive RTP packets will have equal
  /// timestamps if they are (logically) generated at once, e.g., belong
  /// to the same video frame.  Consecutive RTP packets MAY contain
  /// timestamps that are not monotonic if the data is not transmitted
  /// in the order it was sampled, as in the case of MPEG interpolated
  /// video frames.  (The sequence numbers of the packets as transmitted
  /// will still be monotonic.)
  ///
  /// RTP timestamps from different media streams may advance at
  /// different rates and usually have independent, random offsets.
  /// Therefore, although these timestamps are sufficient to reconstruct
  /// the timing of a single stream, directly comparing RTP timestamps
  /// from different media is not effective for synchronization.
  /// Instead, for each medium the RTP timestamp is related to the
  /// sampling instant by pairing it with a timestamp from a reference
  /// clock (wallclock) that represents the time when the data
  /// corresponding to the RTP timestamp was sampled.  The reference
  /// clock is shared by all media to be synchronized.  The timestamp
  /// pairs are not transmitted in every data packet, but at a lower
  /// rate in RTCP SR packets as described in Section 6.4.
  ///
  /// The sampling instant is chosen as the point of reference for the
  /// RTP timestamp because it is known to the transmitting endpoint and
  /// has a common definition for all media, independent of encoding
  /// delays or other processing.  The purpose is to allow synchronized
  /// presentation of all media sampled at the same time.
  ///
  /// 32 bits
  public let timestamp: UInt32

  /// The SSRC field identifies the synchronization source.
  ///
  /// 32 bits
  public let ssrc: UInt32

  /// The CSRC list identifies the contributing sources for the payload
  /// contained in this packet.  The number of identifiers is given by
  /// the CC field.  If there are more than 15 contributing sources,
  /// only 15 can be identified.
  ///
  /// 0 to 15 items, 32 bits each
  public let csrcs: [UInt32]

  /// Remaining payload data
  public let payload: ByteBuffer
  
  public init(
    payloadType: RTPType,
    sequence: UInt16,
    timestamp: UInt32,
    ssrc: UInt32,
    payload: ByteBuffer,
    marker: Bool = false
  ) {
    self.version = 2
    self.padding = false
    self.extension = false
    self.marker = marker
    self.payloadType = payloadType
    self.sequence = sequence
    self.timestamp = timestamp
    self.ssrc = ssrc
    self.csrcs = []
    self.payload = payload
  }

  public init?(rawValue: ByteBuffer) {
    var buffer: ByteBuffer = rawValue
    guard let firstByte = buffer.readInteger(as: UInt8.self) else {
      return nil
    }
    self.version = (firstByte & 0b11000000) >> 6
    self.padding = ((firstByte & 0b00100000) >> 5) == 1
    self.extension = ((firstByte & 0b00010000) >> 4) == 1

    // The CSRC count contains the number of CSRC identifiers that
    // follow the fixed header.
    // We don't bother storing this value since we can get it from the
    // csrcs array.
    let csrcCount = firstByte & 0b00001111

    guard let secondByte = buffer.readInteger(as: UInt8.self),
      let rtpType = RTPType(rawValue: secondByte & 0b01111111)
    else {
      return nil
    }
    self.marker = ((secondByte & 0b10000000) >> 7) == 1
    self.payloadType = rtpType

    guard let sequence = buffer.readInteger(as: UInt16.self),
      let timestamp = buffer.readInteger(as: UInt32.self),
      let ssrc = buffer.readInteger(as: UInt32.self)
    else {
      return nil
    }

    self.sequence = sequence
    self.timestamp = timestamp
    self.ssrc = ssrc

    var csrcs: [UInt32] = []
    for _ in 0..<csrcCount {
      guard let csrc = buffer.readInteger(as: UInt32.self) else {
        return nil
      }
      csrcs.append(csrc)
    }
    self.csrcs = csrcs

    self.payload = buffer
  }

  public var rawValue: ByteBuffer {
    var buffer = ByteBuffer()

    var firstByte: UInt8 = 0
    firstByte |= (self.version & 0b00000011) << 6
    firstByte |= (self.padding ? 1 : 0) << 5
    firstByte |= (self.extension ? 1 : 0) << 4
    firstByte |= UInt8(self.csrcs.count & 0b00001111)
    buffer.writeInteger(firstByte)

    var secondByte: UInt8 = 0
    secondByte |= (self.marker ? 1 : 0) << 7
    secondByte |= (self.payloadType.rawValue & 0b01111111)
    buffer.writeInteger(secondByte)

    buffer.writeInteger(self.sequence)
    buffer.writeInteger(self.timestamp)
    buffer.writeInteger(self.ssrc)

    for csrc in self.csrcs {
      buffer.writeInteger(csrc)
    }

    buffer.writeImmutableBuffer(self.payload)

    return buffer
  }
}
