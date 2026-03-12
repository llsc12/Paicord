/// https://github.com/SwiftDiscordAudio/DiscordAudioKit/blob/main/Sources/DiscordRTP/RTCP.swift

/// https://www.iana.org/assignments/rtp-parameters/rtp-parameters.xhtml#rtp-parameters-4
enum RTCPControlPacketType {
  case smpteTimeCodeMapping
  case extendedInterarrivalJitterReport
  case senderReport
  case receiverReport
  case sourceDescription
  case goodbye
  case applicationDefined
  case genericRTPFeedback
  case payloadSpecific
  case extendedReport
  case avbRTCPPacket
  case receiverSummaryInformation
  case portMapping
  case idmsSettings
  case reportingGroupReportingSources
  case splicingNotificationMessage

  init?(from: UInt8) {
    switch from {
    case 194: self = .smpteTimeCodeMapping
    case 195: self = .extendedInterarrivalJitterReport
    case 200: self = .senderReport
    case 201: self = .receiverReport
    case 202: self = .sourceDescription
    case 203: self = .goodbye
    case 204: self = .applicationDefined
    case 205: self = .genericRTPFeedback
    case 206: self = .payloadSpecific
    case 207: self = .extendedReport
    case 208: self = .avbRTCPPacket
    case 209: self = .receiverSummaryInformation
    case 210: self = .portMapping
    case 211: self = .idmsSettings
    case 212: self = .reportingGroupReportingSources
    case 213: self = .splicingNotificationMessage
    default:
      return nil
    }
  }
}
