//
//  ThemingSupport.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 14/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUIX

#if canImport(AppKit)
  import AppKit
#endif

#if canImport(UIKit)
  import UIKit
#endif

extension EnvironmentValues {
  @Entry var theme: Theming.Theme = Theming.shared.currentTheme
}

// A representation of an image that can be encoded and decoded across platforms.
struct PlatformImageRepresentation: Codable, Hashable, Equatable, Sendable {
  let light: AppKitOrUIKitImage
  let dark: AppKitOrUIKitImage

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let imageDataLight = try container.decode(Data.self, forKey: .light)
    let imageDataDark = try container.decode(Data.self, forKey: .dark)
    #if canImport(UIKit)
      guard let uiImageLight = UIImage(data: imageDataLight) else {
        throw DecodingError.dataCorruptedError(
          forKey: .light,
          in: container,
          debugDescription: "Data could not be decoded into UIImage."
        )
      }
      guard let uiImageDark = UIImage(data: imageDataDark) else {
        throw DecodingError.dataCorruptedError(
          forKey: .dark,
          in: container,
          debugDescription: "Data could not be decoded into UIImage."
        )
      }
      self.light = uiImageLight
      self.dark = uiImageDark
    #elseif canImport(AppKit)
      guard let nsImageLight = NSImage(data: imageDataLight) else {
        throw DecodingError.dataCorruptedError(
          forKey: .light,
          in: container,
          debugDescription: "Data could not be decoded into NSImage."
        )
      }
      guard let nsImageDark = NSImage(data: imageDataDark) else {
        throw DecodingError.dataCorruptedError(
          forKey: .dark,
          in: container,
          debugDescription: "Data could not be decoded into NSImage."
        )
      }
      self.light = nsImageLight
      self.dark = nsImageDark
    #endif
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    #if canImport(UIKit)
      let uiImageLight = self.light
      guard
        let imageDataLight = uiImageLight.pngData()
      else {
        throw EncodingError.invalidValue(
          self.light,
          EncodingError.Context(
            codingPath: container.codingPath,
            debugDescription: "UIImage could not be converted to PNG data."
          )
        )
      }
      try container.encode(imageDataLight, forKey: .light)
      let uiImageDark = self.dark
      guard
        let imageDataDark = uiImageDark.pngData()
      else {
        throw EncodingError.invalidValue(
          self.dark,
          EncodingError.Context(
            codingPath: container.codingPath,
            debugDescription: "UIImage could not be converted to PNG data."
          )
        )
      }
      try container.encode(imageDataDark, forKey: .dark)
    #elseif canImport(AppKit)
      guard
        let tiffDataLight = self.light.tiffRepresentation,
        let bitmapLight = NSBitmapImageRep(data: tiffDataLight),
        let imageDataLight = bitmapLight.representation(
          using: .png,
          properties: [:]
        )
      else {
        throw EncodingError.invalidValue(
          self.light,
          EncodingError.Context(
            codingPath: container.codingPath,
            debugDescription: "NSImage could not be converted to PNG data."
          )
        )
      }
      guard
        let tiffDataDark = self.dark.tiffRepresentation,
        let bitmapDark = NSBitmapImageRep(data: tiffDataDark),
        let imageDataDark = bitmapDark.representation(
          using: .png,
          properties: [:]
        )
      else {
        throw EncodingError.invalidValue(
          self.dark,
          EncodingError.Context(
            codingPath: container.codingPath,
            debugDescription: "NSImage could not be converted to PNG data."
          )
        )
      }
      try container.encode(imageDataLight, forKey: .light)
      try container.encode(imageDataDark, forKey: .dark)
    #endif
  }

  enum CodingKeys: String, CodingKey {
    case light
    case dark
  }
}

extension Color: @retroactive Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let lightRepresentation = try container.decode(
      Representation.self,
      forKey: .light
    )
    let darkRepresentation = try container.decode(
      Representation.self,
      forKey: .dark
    )

    let lightColor = lightRepresentation.cgColor
    let darkColor = darkRepresentation.cgColor

    self = Color(
      light: Color(cgColor: lightColor),
      dark: Color(cgColor: darkColor)
    )
  }

  public func encode(to encoder: any Encoder) throws {
    let light: CGColor = {
      let platformColor: AppKitOrUIKitColor = .init(self)
      return platformColor.resolvedColor(with: .light).cgColor
    }()
    let dark: CGColor = {
      let platformColor: AppKitOrUIKitColor = .init(self)
      return platformColor.resolvedColor(with: .dark).cgColor
    }()

    let lightRepresentation = Representation(from: light)
    let darkRepresentation = Representation(from: dark)

    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(lightRepresentation, forKey: .light)
    try container.encode(darkRepresentation, forKey: .dark)
  }

  struct Representation: Codable {
    init(from color: CGColor) {
      let components = color.components ?? [0, 0, 0, 1]
      let red = components.count > 0 ? components[0] : 0
      let green = components.count > 1 ? components[1] : 0
      let blue = components.count > 2 ? components[2] : 0
      let alpha = components.count > 3 ? components[3] : 1
      let r = UInt8(clamping: Int(red * 255))
      let g = UInt8(clamping: Int(green * 255))
      let b = UInt8(clamping: Int(blue * 255))
      let a = UInt8(clamping: Int(alpha * 255))
      self.hexString = String(
        format: "#%02X%02X%02X%02X",
        r,
        g,
        b,
        a
      )
    }

    init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.hexString = try container.decode(String.self)
    }

    func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(hexString)
    }

    var cgColor: CGColor {
      let scanner = Scanner(string: hexString)
      scanner.currentIndex = hexString.startIndex

      var hexNumber: UInt64 = 0
      scanner.scanHexInt64(&hexNumber)

      let r = CGFloat((hexNumber & 0xff00_0000) >> 24) / 255
      let g = CGFloat((hexNumber & 0x00ff_0000) >> 16) / 255
      let b = CGFloat((hexNumber & 0x0000_ff00) >> 8) / 255
      let a = CGFloat(hexNumber & 0x0000_00ff) / 255

      return CGColor(
        red: r,
        green: g,
        blue: b,
        alpha: a
      )
    }

    let hexString: String
  }

  private enum CodingKeys: String, CodingKey {
    case light
    case dark
  }
}

extension AppKitOrUIKitColor {
  func resolvedColor(with colorScheme: ColorScheme) -> AppKitOrUIKitColor {
    #if os(iOS) || os(tvOS) || os(watchOS)
      let uiStyle: UIUserInterfaceStyle =
        (colorScheme == .dark) ? .dark : .light
      let traits = UITraitCollection(userInterfaceStyle: uiStyle)
      return self.resolvedColor(with: traits)
    #elseif os(macOS)
      let appearanceName: NSAppearance.Name = {
        switch colorScheme {
        case .light:
          return .aqua
        case .dark:
          return .darkAqua
        @unknown default:
          return .aqua
        }
      }()
      let appearance = NSAppearance(named: appearanceName)
      return self.resolvedColorValue(appearance: appearance)
    #endif
  }

  #if os(macOS)
    // https://stackoverflow.com/a/79490975/10002065
    private func resolvedColorValue(appearance: NSAppearance?) -> NSColor {
      guard let appearance else {
        return self
      }

      /// `NSAppearance.performAsCurrentDrawingAppearance` will let us
      /// retrieve NSColor variants for a given drawing appearance.
      /// Unfortunately there's no direct way to pass data out of the closure
      /// passed into this method, so create a local class that can shuttle
      /// values out.
      class ColorHolder {
        var cgColor: CGColor = .black
      }

      let holder = ColorHolder()
      appearance.performAsCurrentDrawingAppearance { [holder] in
        // Use `cgColor` to force `NSColor` to flatten into the appropriate
        // set of values for this appearance.
        holder.cgColor = self.cgColor
      }

      guard let nsColorValue = NSColor(cgColor: holder.cgColor) else {
        preconditionFailure(
          "Should not be possible to fail to create NSColor here!"
        )
      }
      return nsColorValue
    }
  #endif
}

extension Gradient: @retroactive Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let stops = try container.decode([Stop].self, forKey: .stops)
    self.init(stops: stops)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(stops, forKey: .stops)
  }

  enum CodingKeys: String, CodingKey {
    case stops
  }
}

extension Gradient.Stop: @retroactive Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let color = try container.decode(Color.self, forKey: .color)
    let location = try container.decode(CGFloat.self, forKey: .location)
    self.init(color: color, location: location)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(color, forKey: .color)
    try container.encode(location, forKey: .location)
  }

  enum CodingKeys: String, CodingKey {
    case color
    case location
  }
}

extension ColorScheme: @retroactive Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(String.self)
    switch value {
    case "light":
      self = .light
    case "dark":
      self = .dark
    default:
      self = .light
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .light:
      try container.encode("light")
    case .dark:
      try container.encode("dark")
    @unknown default:
      try container.encode("light")
    }
  }
}

extension Color {
  init(light: Color, dark: Color) {
    #if canImport(UIKit)
      self.init(light: UIColor(light), dark: UIColor(dark))
    #else
      self.init(light: NSColor(light), dark: NSColor(dark))
    #endif
  }

  #if canImport(UIKit)
    init(light: UIColor, dark: UIColor) {
      #if os(watchOS)
        // watchOS does not support light mode / dark mode
        // Per Apple HIG, prefer dark-style interfaces
        self.init(uiColor: dark)
      #else
        self.init(
          uiColor: UIColor(dynamicProvider: { traits in
            switch traits.userInterfaceStyle {
            case .light, .unspecified:
              return light

            case .dark:
              return dark

            @unknown default:
              assertionFailure(
                "Unknown userInterfaceStyle: \(traits.userInterfaceStyle)"
              )
              return light
            }
          })
        )
      #endif
    }
  #endif

  #if canImport(AppKit)
    init(light: NSColor, dark: NSColor) {
      self.init(
        nsColor: NSColor(
          name: nil,
          dynamicProvider: { appearance in
            switch appearance.name {
            case .aqua,
              .vibrantLight,
              .accessibilityHighContrastAqua,
              .accessibilityHighContrastVibrantLight:
              return light

            case .darkAqua,
              .vibrantDark,
              .accessibilityHighContrastDarkAqua,
              .accessibilityHighContrastVibrantDark:
              return dark

            default:
              assertionFailure("Unknown appearance: \(appearance.name)")
              return light
            }
          }
        )
      )
    }
  #endif
}
