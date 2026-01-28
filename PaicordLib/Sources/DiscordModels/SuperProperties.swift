//
//  SuperProperties.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 01/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import DiscordCore
import Foundation
import Playgrounds
import SwiftUI
import UInt128

#if canImport(UIKit)
  import UIKit
#endif

// Discord clients send a horrific header containing your host machine information,
// this is used for anti-abuse systems. It is sent at IDENTIFY in gateway and with all API requests as
// the `X-Super-Properties` header. This extension adds the extra data. The definition only has initializer
// for bot clients. This expands on it.
// TODO: add custom encode decodes so nil fields are included.
extension Gateway.Identify.ConnectionProperties {
  // ios useragent: Discord/83647 CFNetwork/3860.100.1 Darwin/25.0.0
  // ios super-properties: eyJvcyI6ImlPUyIsImJyb3dzZXIiOiJEaXNjb3JkIGlPUyIsImRldmljZSI6ImlQaG9uZTEzLDMiLCJzeXN0ZW1fbG9jYWxlIjoiZW4tR0IiLCJoYXNfY2xpZW50X21vZHMiOmZhbHNlLCJjbGllbnRfdmVyc2lvbiI6IjMwMC4wIiwicmVsZWFzZV9jaGFubmVsIjoic3RhYmxlIiwiZGV2aWNlX3ZlbmRvcl9pZCI6IjlGQTA0RUVCLTUyREYtNEZGNy05NzdFLTQ5NzU5RkI4MjExRSIsImRlc2lnbl9pZCI6MiwiYnJvd3Nlcl91c2VyX2FnZW50IjoiIiwiYnJvd3Nlcl92ZXJzaW9uIjoiIiwib3NfdmVyc2lvbiI6IjI2LjAiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjo4NjI1MSwiY2xpZW50X2V2ZW50X3NvdXJjZSI6bnVsbCwiY2xpZW50X2xhdW5jaF9pZCI6IjIwY2M0OTczLTYwYWYtNDZmMy1hZTFmLTBmMTk5N2I1MmU1YiIsImxhdW5jaF9zaWduYXR1cmUiOiIxNzYwMzEyNTg1MjIyMjA2MDAwIiwiY2xpZW50X2hlYXJ0YmVhdF9zZXNzaW9uX2lkIjoiOWVmNzk3MmMtYTJiMS00MjdmLWEzODAtMzA1ODFlNTFiNjQwIiwiY2xpZW50X2FwcF9zdGF0ZSI6ImFjdGl2ZSJ9

  // macos useragent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.358 Chrome/134.0.6998.205 Electron/35.3.0 Safari/537.36
  // macos super-properties: eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IkRpc2NvcmQgQ2xpZW50IiwicmVsZWFzZV9jaGFubmVsIjoic3RhYmxlIiwiY2xpZW50X3ZlcnNpb24iOiIwLjAuMzYzIiwib3NfdmVyc2lvbiI6IjI0LjUuMCIsIm9zX2FyY2giOiJ4NjQiLCJhcHBfYXJjaCI6Ing2NCIsInN5c3RlbV9sb2NhbGUiOiJlbi1VUyIsImhhc19jbGllbnRfbW9kcyI6ZmFsc2UsImNsaWVudF9sYXVuY2hfaWQiOiI1ZWIxZGU0Zi05YzQ4LTRlMGItYTNhZC00ZmZhZjZkZDA2NzEiLCJicm93c2VyX3VzZXJfYWdlbnQiOiJNb3ppbGxhLzUuMCAoTWFjaW50b3NoOyBJbnRlbCBNYWMgT1MgWCAxMF8xNV83KSBBcHBsZVdlYktpdC81MzcuMzYgKEtIVE1MLCBsaWtlIEdlY2tvKSBkaXNjb3JkLzAuMC4zNjMgQ2hyb21lLzEzNC4wLjY5OTguMjA1IEVsZWN0cm9uLzM1LjMuMCBTYWZhcmkvNTM3LjM2IiwiYnJvd3Nlcl92ZXJzaW9uIjoiMzUuMy4wIiwib3Nfc2RrX3ZlcnNpb24iOiIyNCIsImNsaWVudF9idWlsZF9udW1iZXIiOjQ1NzE3NCwibmF0aXZlX2J1aWxkX251bWJlciI6bnVsbCwiY2xpZW50X2V2ZW50X3NvdXJjZSI6bnVsbCwibGF1bmNoX3NpZ25hdHVyZSI6IjhkNmE4ODhiLTIwYjctNDZiNi05ZTc0LTZiOTEyYzFkYzUxNSIsImNsaWVudF9oZWFydGJlYXRfc2Vzc2lvbl9pZCI6ImNkNGY4ZDI4LTU3MWItNGU4MS1iMTQ2LWM1NWU3MjA5YWU2NCIsImNsaWVudF9hcHBfc3RhdGUiOiJmb2N1c2VkIn0

  // if this is in header, the user agent will be included, otherwise it will be nil
  public init(ws: Bool = true) {
    self.os = Self.__defaultOS
    self.browser = SuperProperties.browser()
    self.release_channel = "stable"
    self.system_locale = SuperProperties.GenerateLocaleHeader()
    self.has_client_mods = false
    self.device = SuperProperties.device()
    self.client_version = SuperProperties.client_version()
    self.os_version = SuperProperties.os_version()
    self.os_arch = SuperProperties.os_arch()
    self.app_arch = SuperProperties.os_arch()
    self.browser_user_agent = SuperProperties.useragent(ws: ws)
    self.browser_version = SuperProperties.browser_version()
    self.os_sdk_version = SuperProperties.os_sdk_version()
    self.client_build_number = SuperProperties.client_build_number()
    self.native_build_number = nil
    self.client_launch_id = SuperProperties.client_launch_id()
    self.launch_signature = SuperProperties.launch_signature()
    self.device_vendor_id = SuperProperties.device_vendor_id()
    self.client_app_state = SuperProperties.client_app_state()
    self.design_id = SuperProperties.design_id()
    self.client_heartbeat_session_id =
      SuperProperties.client_heartbeat_session_id()
    self.client_event_source = nil
  }

  public static var __defaultOS: String {
    #if os(macOS)
      return "Mac OS X"  // i dont know why but discord still uses this
    #elseif os(Linux)
      return "Linux"
    #elseif os(iOS)
      return "iOS"
    #elseif os(watchOS)
      return "watchOS"
    #elseif os(tvOS)
      return "tvOS"
    #elseif os(Windows)
      return "Windows"
    #elseif canImport(Musl)
      return "Musl"
    #elseif os(FreeBSD)
      return "FreeBSD"
    #elseif os(OpenBSD)
      return "OpenBSD"
    #elseif os(Android)
      return "Android"
    #elseif os(PS4)
      return "PS4"
    #elseif os(Cygwin)
      return "Cygwin"
    #elseif os(Haiku)
      return "Haiku"
    #elseif os(WASI)
      return "WASI"
    #else
      return "Unknown"
    #endif
  }
}

public enum SuperProperties {
  static let _initialisation_date = Date.now
  static let _client_launch_id = UUID()
  static let _launch_signature = UUID.generateLaunchSignature()

  // this needs to be regenerated every 30 minutes
  nonisolated(unsafe) private static
    var _client_heartbeat_session_id_last_generated: Date = Date
      .distantPast
  nonisolated(unsafe) private static var _client_heartbeat_session_id_cached:
    UUID? = nil
  static var _client_heartbeat_session_id: UUID {
    let now = Date.now
    if now.timeIntervalSince(_client_heartbeat_session_id_last_generated)
      > Double(Duration.minutes(30).components.seconds)
    {
      _client_heartbeat_session_id_last_generated = now
      _client_heartbeat_session_id_cached = UUID()
    }
    return _client_heartbeat_session_id_cached!
  }

  public static func GenerateSuperPropertiesHeader() -> String {
    let properties = Gateway.Identify.ConnectionProperties(ws: false)
    // try unsafe because it probably will be fine
    let encoded = try! DiscordGlobalConfiguration.encoder.encode(properties)
    return encoded.base64EncodedString()
  }

  public static func GenerateLocaleHeader() -> String {
    let locale = Locale.current

    if let languageCode = locale.language.languageCode?.identifier {
      if let regionCode = locale.region?.identifier {
        return "\(languageCode)-\(regionCode)"
      }
      return languageCode
    }

    // fallback
    return NSLocale.canonicalLanguageIdentifier(from: locale.identifier)
  }

  public static func GenerateTimezoneHeader() -> String {
    return TimeZone.current.identifier
  }

  public enum ContextPropertyContext {
    case createMessage
  }
  public static func GenerateContextPropertiesHeader(
    context: ContextPropertyContext
  ) -> String {
    let dict: [String: Any] =
      switch context {
      case .createMessage: ["location": "chat_input"]
      }
    let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
    return data.base64EncodedString()
  }

  /// If ws is false this will never return nil.
  public static func useragent(ws: Bool) -> String? {
    switch Gateway.Identify.ConnectionProperties.__defaultOS {
    // for these useragents, we will sub in values from the other functions
    case "iOS", "watchOS":
      if ws { return nil }  // no useragent when identifying browser_user_agent key in ws
      return
        "Discord/\(Self.client_build_number()!) CFNetwork/\(Self.cfnetwork_version()) Darwin/\(Self.kernel_version())"
    case "Mac OS X":
      return
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/\(Self.webkitVer()) (KHTML, like Gecko) discord/\(Self.client_version()) Chrome/\(Self.chromeVer()) Electron/\(Self.browser_version()) Safari/\(Self.webkitVer())"
    default:
      // TODO: do something better for other OSes
      return
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15"
    }
  }

  public static func chromeVer() -> String {
    "138.0.7204.251"
  }

  public static func webkitVer() -> String {
    "537.36"
  }

  public static func device() -> String? {
    #if os(iOS)
      // "iPhone13,3"
      // get the device model
      var systemInfo = utsname()
      uname(&systemInfo)
      let machineMirror = Mirror(reflecting: systemInfo.machine)
      let identifier = machineMirror.children.reduce("") {
        identifier,
        element in
        guard let value = element.value as? Int8, value != 0 else {
          return identifier
        }
        return identifier + String(UnicodeScalar(UInt8(value)))
      }
      return identifier
    #elseif os(watchOS)
      // no good way to handle this. just return hardcoded value for now.
      return "iPhone13,3"
    #elseif os(macOS)
      return nil
    #else
      return nil
    #endif
  }

  public static func os_version() -> String? {
    #if os(macOS)
      // get the kernel version on macos (idk why discord uses this)
      return Self.kernel_version()
    #elseif os(iOS)
      // avoids uikit, bc uikit is mainactor isolated
      var size: Int = 0
      // need buffer size
      if sysctlbyname("kern.osproductversion", nil, &size, nil, 0) != 0 {
        return nil
      }
      var buffer = [CChar](repeating: 0, count: size)
      if sysctlbyname("kern.osproductversion", &buffer, &size, nil, 0) != 0 {
        return nil
      }
      let convertedBuffer = buffer.map { UInt8($0) }
      let string = String(decoding: convertedBuffer.dropLast(), as: UTF8.self)
      return string
    #elseif os(watchOS)
      // only watchos 26 and above can be returned safely.
      var size: Int = 0
      // need buffer size
      if sysctlbyname("kern.osproductversion", nil, &size, nil, 0) != 0 {
        return nil
      }
      var buffer = [CChar](repeating: 0, count: size)
      if sysctlbyname("kern.osproductversion", &buffer, &size, nil, 0) != 0 {
        return nil
      }
      let convertedBuffer = buffer.map { UInt8($0) }
      let version = String(decoding: convertedBuffer.dropLast(), as: UTF8.self)
      let majorVersion =
        (version.split(separator: ".").first ?? "0").flatMap { Int($0) } ?? 0
      if majorVersion >= 26 {
        return version
      } else {
        // for watchos versions below 26, we buff the major version count to align with ios versions
        let components = version.split(separator: ".")
        // drop the major version
        let minorAndPatch = components.dropFirst()
        // last ios version before 26 was ios 18, but before watchos 26 was watchos 11.
        // we add 7 to the major version to align it with ios versions.
        return (majorVersion + 7).description + "."
          + minorAndPatch.joined(separator: ".")
      }
    #else
      return nil
    #endif
  }

  public static func os_arch() -> String? {
    #if os(macOS)  // discord only wants to see what arch their mac client is running on
      #if arch(x86_64)
        return "x64"
      #elseif arch(arm64)
        return "arm64"
      #else
        return nil
      #endif
    #else
      return nil
    #endif
  }

  public static func browser() -> String {
    switch Gateway.Identify.ConnectionProperties.__defaultOS {
    case "iOS", "watchOS":
      return "Discord iOS"
    case "Mac OS X":
      return "Discord Client"
    default:
      return "Safari"
    }
  }

  public static func browser_version() -> String {
    switch Gateway.Identify.ConnectionProperties.__defaultOS {
    case "iOS", "watchOS":
      return ""
    case "Mac OS X":
      return "37.6.0"
    default:
      return ""
    }
  }

  public static func client_version() -> String {
    switch Gateway.Identify.ConnectionProperties.__defaultOS {
    case "iOS", "watchOS":
      return "310.3"
    case "Mac OS X":
      return "0.0.372"
    default:
      return "0.0.372"
    }
  }

  public static func client_build_number() -> Int? {
    switch Gateway.Identify.ConnectionProperties.__defaultOS {
    case "iOS", "watchOS":
      return 91102
    case "Mac OS X":
      return 485097
    default:
      return nil
    }
  }

  public static func client_launch_id() -> String {
    return _client_launch_id.uuidString.lowercased()
  }

  public static func launch_signature() -> String? {
    #if os(macOS)
      return _launch_signature.uuidString.lowercased()
    #elseif os(iOS) || os(watchOS)
      // TODO: ios follows a different format, using an integer. not sure how this is generated yet.
      // for now, i was told its safe to use macos one instead.
      //    return nil
      return _launch_signature.uuidString.lowercased()
    #endif
  }

  public static func cfnetwork_version() -> String {
    let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
    let version = dictionary?["CFBundleShortVersionString"] as! String
    return version
  }

  public static func kernel_version() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let versionMirror = Mirror(reflecting: systemInfo.release)
    let version = versionMirror.children.reduce("") {
      version,
      element in
      guard let value = element.value as? Int8, value != 0 else {
        return version
      }
      return version + String(UnicodeScalar(UInt8(value)))
    }
    return version
  }

  public static func os_sdk_version() -> String? {
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS)
      let ver = Self.os_version()
      // get ver then split by . and get first value for major version which is the sdk version
      return ver?.components(separatedBy: ".").first ?? ""
    #else
      return nil
    #endif
  }

  public static func client_app_state() -> String {
    #if os(iOS) || os(watchOS)
      return "active"
    #elseif os(macOS)
      return "focused"
    #else
      return "unknown"
    #endif
  }

  public static func device_vendor_id() -> String? {
    #if os(iOS) || os(watchOS)
      DispatchQueue.main.sync {
        if let uuid = UIDevice.current.identifierForVendor {
          return uuid.uuidString.uppercased()
        }
        return UUID().uuidString.uppercased()  // fallback
      }
    #elseif os(macOS)
      return nil
    #else
      return nil
    #endif
  }

  public static func design_id() -> Int? {
    #if os(iOS) || os(watchOS)
      return 2
    #elseif os(macOS)
      return nil
    #else
      return nil
    #endif
  }

  public static func client_heartbeat_session_id() -> String {
    return _client_heartbeat_session_id.uuidString.lowercased()
  }
}

// code to generate a valid launch signature uuid
// https://docs.discord.food/reference#launch-signature
extension UUID {
  func toUInt128() -> UInt128 {
    let bytes = withUnsafeBytes(of: uuid) { Array($0) }  // 16 bytes, in order
    var value = UInt128(0)
    for b in bytes {
      value = (value << 8) | UInt128(b)
    }
    return value
  }

  static func generateLaunchSignature() -> UUID {
    let bits = UInt128(
      "0b00000000100000000001000000010000000010000001000000001000000000000010000010000001000000000100000000000001000000000000100000000000"
    )!

    let randomUInt = UUID().toUInt128()
    let maskInverted = ~bits & UInt128.max
    let newUInt = randomUInt & maskInverted
    let finalUInt = newUInt | bits

    return UUID.init(finalUInt)
  }
}

#Playground {
  let number: UInt = 1_734_653
  let parsed = IntBitField<Gateway.Capability>.init(rawValue: number)
  var capabilities: [Gateway.Capability] = []
  for cap in Gateway.Capability.allCases {
    if parsed.contains(cap) {
      capabilities.append(cap)
    }
  }
  print(capabilities)
}
