/// https://github.com/SwiftDiscordAudio/DiscordAudioKit/blob/main/Sources/DiscordRTP/RTPType.swift

/// https://www.iana.org/assignments/rtp-parameters/rtp-parameters.xhtml#rtp-parameters-1
public enum RTPType: RawRepresentable {
  case pcmu
  case gsm
  case g723
  case dvi4(DVI4SampleRate)
  case lpc
  case pcma
  case g722
  case l16(l16Channels)
  case qcelp
  case cn
  case mpa
  case g728
  case g729
  case celB
  case jpeg
  case nv
  case h261
  case mpv
  case mp2t
  case h263
  case dynamic(UInt8)

  public enum DVI4SampleRate {
    case `8000`
    case `16000`
    case `11025`
    case `22050`
  }

  public enum l16Channels: Int {
    case mono = 1
    case stereo = 2
  }

  public init?(rawValue: UInt8) {
    switch rawValue {
    case 0: self = .pcmu
    case 3: self = .gsm
    case 4: self = .g723
    case 5: self = .dvi4(.`8000`)
    case 6: self = .dvi4(.`16000`)
    case 7: self = .lpc
    case 8: self = .pcma
    case 9: self = .g722
    case 10: self = .l16(.mono)
    case 11: self = .l16(.stereo)
    case 12: self = .qcelp
    case 13: self = .cn
    case 14: self = .mpa
    case 15: self = .g728
    case 16: self = .dvi4(.`11025`)
    case 17: self = .dvi4(.`22050`)
    case 18: self = .g729
    case 25: self = .celB
    case 26: self = .jpeg
    case 28: self = .nv
    case 31: self = .h261
    case 32: self = .mpv
    case 33: self = .mp2t
    case 34: self = .h263
    case 96...127: self = .dynamic(rawValue)
    default:
      return nil
    }
  }

  public var rawValue: UInt8 {
    switch self {
    case .pcmu: return 0
    case .gsm: return 3
    case .g723: return 4
    case .dvi4(.`8000`): return 5
    case .dvi4(.`16000`): return 6
    case .lpc: return 7
    case .pcma: return 8
    case .g722: return 9
    case .l16(.mono): return 10
    case .l16(.stereo): return 11
    case .qcelp: return 12
    case .cn: return 13
    case .mpa: return 14
    case .g728: return 15
    case .dvi4(.`11025`): return 16
    case .dvi4(.`22050`): return 17
    case .g729: return 18
    case .celB: return 25
    case .jpeg: return 26
    case .nv: return 28
    case .h261: return 31
    case .mpv: return 32
    case .mp2t: return 33
    case .h263: return 34
    case .dynamic(let value): return value
    }
  }
}
