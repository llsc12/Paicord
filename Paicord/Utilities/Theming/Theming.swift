//
//  Theming.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import HighlightSwift
import Playgrounds
import SwiftUIX

@Observable
class Theming {
  static let shared = Theming()

  var themes: [Theme] {
    Theming.defaultThemes + loadedThemes
  }

  var loadedThemes: [Theme] {
    didSet {
      save()
    }
  }

  // defaults to Paicord.Auto
  var currentThemeID: String =
    UserDefaults.standard.string(forKey: "Paicord.Theming.CurrentThemeID") ?? "Paicord.Auto"
  {
    didSet {
      UserDefaults.standard.set(
        currentThemeID,
        forKey: "Paicord.Theming.CurrentThemeID"
      )
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.setupAppearance()
      }
    }
  }

  var currentTheme: Theme {
    themes.first(where: { $0.id == currentThemeID }) ?? Theming.defaultThemes[0]
  }

  private init() {
    self.loadedThemes = []
    load()
    setupAppearance(observation: true)
  }

  func setupAppearance(observation: Bool = false) {
    #if canImport(UIKit)
      if observation {
        NotificationCenter.default.addObserver(
          forName: UIApplication.didBecomeActiveNotification,
          object: nil,
          queue: .main
        ) { _ in
          // update appearance
          UIApplication.shared.connectedScenes.map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .flatMap { $0.windows }
            .forEach { window in
            // set accent color
            window.tintColor = AppKitOrUIKitColor(
              self.currentTheme.common.accent
            )
          }
        }
      } else {
        // update appearance
        UIApplication.shared.connectedScenes.map { $0 as? UIWindowScene }
          .compactMap { $0 }
          .flatMap(\.windows)
          .forEach { window in
          // set accent color
          window.tintColor = AppKitOrUIKitColor(
            self.currentTheme.common.accent
          )
        }
      }
    #endif
  }

  func save() {
    // save to file ~/Library/Preferences/themes.json
    let data = try? JSONEncoder().encode(loadedThemes)
    let url = URL.libraryDirectory.appendingPathComponent(
      "Preferences/themes.json"
    )
    try? data?.write(to: url, options: .atomic)
  }

  func load() {
    let url = URL.libraryDirectory.appendingPathComponent(
      "Preferences/themes.json"
    )
    guard let data = try? Data(contentsOf: url) else { return }
    guard let themes = try? JSONDecoder().decode([Theme].self, from: data)
    else { return }
    self.loadedThemes = themes
  }
}

extension Theming {
  /// A Paicord theme definition.
  struct Theme: Sendable, Codable, Hashable, Equatable, Identifiable {
    /// Unique identifier for the theme.
    let id: String
    /// Metadata about the theme.
    let metadata: ThemeMetadata

    /// Common UI theme properties.
    let common: ThemeCommon

    /// Styling of Discord markdown elements.
    let markdown: ThemeMarkdown

    /// Metadata about a theme.
    struct ThemeMetadata: Sendable, Codable, Hashable, Equatable {
      /// The name of the theme.
      let name: String
      /// The author of the theme.
      let author: String
      /// A description of the theme.
      let description: String
      /// The version of the theme, use whatever versioning system you'd prefer.
      let version: String
    }

    /// Common UI theme properties.
    struct ThemeCommon: Sendable, Codable, Hashable, Equatable {
      /// Global accent color for the app, used on iOS and not macOS.
      let accent: Color

      /// Whether the app should be light or dark themed, or follow the system setting.
      /// If not included or `nil`, the app will follow the system setting.
      let colorScheme: ColorScheme?

      /// Used for links.
      let hyperlink: Color

      /// Primary button color, when the button is activated or as a static background
      let primaryButton: Color

      /// Background color for primary buttons, when not activated or as a static background
      let primaryButtonBackground: Color

      /// Less prominent button color.
      let tertiaryButton: Color

      /// Primary background color for views.
      let primaryBackground: Color

      /// Secondary background color for views.
      let secondaryBackground: Color

      /// Tertiary background color for views.
      let tertiaryBackground: Color
    }

    /// Styling of Discord markdown elements.
    struct ThemeMarkdown: Sendable, Codable, Hashable, Equatable {
      /// Color of body text.
      let text: Color

      /// Color of text that is less prominent, like in footnotes.
      let secondaryText: Color

      /// Color of mentions.
      let mentionText: Color

      /// Color of the background behind mentions.
      let mentionBackground: Color

      /// The color of the capsule to the left of a blockquote.
      let blockquoteCapsule: Color

      /// Background to separate inline code spans from normal text. Also used for timestamps and shown spoilers.
      let codeSpanBackground: Color

      /// Background color of code blocks.
      let codeBlockBackground: Color

      /// Border that goes around code blocks.
      let codeBlockBorder: Color

      let codeBlockSyntaxTheme: SyntaxTheme

      enum SyntaxTheme: Sendable, Codable, Hashable, Equatable {
        case a11y
        case atomOne
        case classic
        case edge
        case github
        case google
        case gradient
        case grayscale
        case harmonic16
        case heetch
        case horizon
        case humanoid
        case ia
        case isblEditor
        case kimbie
        case nnfx
        case pandaSyntax
        case papercolor
        case paraiso
        case qtcreator
        case silk
        case solarFlare
        case solarized
        case stackoverflow
        case standard
        case summerfruit
        case synthMidnightTerminal
        case tokyoNight
        case unikitty
        case xcode

        case custom(lightCSS: String, darkCSS: String)

        var highlightTheme: CodeTextColors {
          switch self {
          case .a11y: .theme(.a11y)
          case .atomOne: .theme(.atomOne)
          case .classic: .theme(.classic)
          case .edge: .theme(.edge)
          case .github: .theme(.github)
          case .google: .theme(.google)
          case .gradient: .theme(.gradient)
          case .grayscale: .theme(.grayscale)
          case .harmonic16: .theme(.harmonic16)
          case .heetch: .theme(.heetch)
          case .horizon: .theme(.horizon)
          case .humanoid: .theme(.humanoid)
          case .ia: .theme(.ia)
          case .isblEditor: .theme(.isblEditor)
          case .kimbie: .theme(.kimbie)
          case .nnfx: .theme(.nnfx)
          case .pandaSyntax: .theme(.pandaSyntax)
          case .papercolor: .theme(.papercolor)
          case .paraiso: .theme(.paraiso)
          case .qtcreator: .theme(.qtcreator)
          case .silk: .theme(.silk)
          case .solarFlare: .theme(.solarFlare)
          case .solarized: .theme(.solarized)
          case .stackoverflow: .theme(.stackoverflow)
          case .standard: .theme(.standard)
          case .summerfruit: .theme(.summerfruit)
          case .synthMidnightTerminal: .theme(.synthMidnightTerminal)
          case .tokyoNight: .theme(.tokyoNight)
          case .unikitty: .theme(.unikitty)
          case .xcode: .theme(.xcode)

          case .custom(let lightCSS, let darkCSS):
            .custom(dark: .custom(css: darkCSS), light: .custom(css: lightCSS))
          }
        }
      }
    }
  }
}

extension Theming {
  static let defaultThemes: [Theme] = [
    .init(
      id: "Paicord.Auto",
      metadata: .init(
        name: "Auto",
        author: "Paicord",
        description: "Reflects system color scheme.",
        version: "1.0"
      ),
      common: .init(
        accent: .init(hexadecimal6: 0x5E6AF5),
        colorScheme: nil,
        hyperlink: .init(
          light: .init(hexadecimal6: 0x908EFC),
          dark: .init(hexadecimal6: 0x8DA1FC)
        ),
        primaryButton: .init(hexadecimal6: 0x5E6AF5),
        primaryButtonBackground: .init(
          light: .init(hexadecimal6: 0xFEFFFE),
          dark: .init(hexadecimal6: 0x27282F)
        ),
        tertiaryButton: .init(
          light: .init(hexadecimal6: 0x4E5057),
          dark: .init(hexadecimal6: 0xC7C8CD)
        ),
        primaryBackground: .init(
          light: .init(hexadecimal6: 0xEAECEE),
          dark: .init(hexadecimal6: 0x131317)
        ),
        secondaryBackground: .init(
          light: .init(hexadecimal6: 0xEAECEE),
          dark: .init(hexadecimal6: 0x1C1D21)
        ),
        tertiaryBackground: .init(
          light: .init(hexadecimal6: 0xF1F3F5),
          dark: .init(hexadecimal6: 0x2C2C35)
        )
      ),
      markdown: .init(
        text: .primary,
        secondaryText: .secondary,
        mentionText: .init(
          light: .init(hexadecimal6: 0x0036FF),
          dark: .init(hexadecimal6: 0xced7ff)
        ),
        mentionBackground: .init(
          light: .init(hexadecimal6: 0xD2E3FF).opacity(0.8),
          dark: .init(hexadecimal6: 0x383c6f).opacity(0.8)
        ),
        blockquoteCapsule: .quaternaryLabel,
        codeSpanBackground: .init(
          light: .gray.opacity(0.2),
          dark: .gray.opacity(0.2)
        ),
        codeBlockBackground: .init(
          light: .init(hexadecimal6: 0xF1F3F5),
          dark: Color(hexadecimal6: 0x1f202f)
        ),
        codeBlockBorder: .init(
          light: Color(hexadecimal6: 0xDCDDDE),
          dark: Color(hexadecimal6: 0x373745)
        ),
        codeBlockSyntaxTheme: .xcode
      )
    ),
    // below are just auto's variants with constants for light and dark respectively
    .init(
      id: "Paicord.Light",
      metadata: .init(
        name: "Light",
        author: "Paicord",
        description: "Fixed light theme.",
        version: "1.0"
      ),
      common: .init(
        accent: .init(hexadecimal6: 0x5E6AF5),
        colorScheme: .light,
        hyperlink: .init(hexadecimal6: 0x908EFC),
        primaryButton: .init(hexadecimal6: 0x5E6AF5),
        primaryButtonBackground: .init(hexadecimal6: 0xFEFFFE),
        tertiaryButton: .init(hexadecimal6: 0x4E5057),
        primaryBackground: .init(hexadecimal6: 0xEAECEE),
        secondaryBackground: .init(hexadecimal6: 0xEAECEE),
        tertiaryBackground: .init(hexadecimal6: 0xF1F3F5)
      ),
      markdown: .init(
        text: .primary,
        secondaryText: .secondary,
        mentionText: .init(hexadecimal6: 0x0036FF),
        mentionBackground: .init(hexadecimal6: 0xD2E3FF).opacity(0.8),
        blockquoteCapsule: .quaternaryLabel,
        codeSpanBackground: .gray.opacity(0.2),
        codeBlockBackground: .init(hexadecimal6: 0xF1F3F5),
        codeBlockBorder: .init(hexadecimal6: 0xDCDDDE),
        codeBlockSyntaxTheme: .xcode
      )
    ),
    .init(
      id: "Paicord.Dark",
      metadata: .init(
        name: "Dark",
        author: "Paicord",
        description: "Fixed dark theme.",
        version: "1.0"
      ),
      common: .init(
        accent: .init(hexadecimal6: 0x5E6AF5),
        colorScheme: .dark,
        hyperlink: .init(hexadecimal6: 0x8DA1FC),
        primaryButton: .init(hexadecimal6: 0x5E6AF5),
        primaryButtonBackground: .init(hexadecimal6: 0x27282F),
        tertiaryButton: .init(hexadecimal6: 0xC7C8CD),
        primaryBackground: .init(hexadecimal6: 0x131317),
        secondaryBackground: .init(hexadecimal6: 0x1C1D21),
        tertiaryBackground: .init(hexadecimal6: 0x2C2C35)
      ),
      markdown: .init(
        text: .primary,
        secondaryText: .secondary,
        mentionText: .init(hexadecimal6: 0xced7ff),
        mentionBackground: .init(hexadecimal6: 0x383c6f).opacity(0.8),
        blockquoteCapsule: .quaternaryLabel,
        codeSpanBackground: .gray.opacity(0.2),
        codeBlockBackground: .init(hexadecimal6: 0x1f202f),
        codeBlockBorder: .init(hexadecimal6: 0x373745),
        codeBlockSyntaxTheme: .xcode
      )
    ),
  ]
}

extension Theming {
  enum Styling: Sendable, Codable, Hashable, Equatable {
    case color(Color)
    case gradient(Gradient, GradientType)
    case image(PlatformImageRepresentation, Set<ImageScaling>)

    enum GradientType: String, Sendable, Codable, Hashable, Equatable {
      case linear
      case radial
      case angular
    }

    struct ImageScaling: Sendable, OptionSet, Codable, Hashable, Equatable {
      let rawValue: Int

      // allows image to be resized
      static let resizable = ImageScaling(rawValue: 1 << 0)
      // scales the image to completely fill the container, image may be stretched or cropped (depends on if resizable is set)
      static let fill = ImageScaling(rawValue: 1 << 1)
      // scales the image to fit within the container, image may be stretched (depends on if resizable is set)
      static let fit = ImageScaling(rawValue: 1 << 2)
      // tiles the image to fill the container, image scale is not changed
      static let tile = ImageScaling(rawValue: 1 << 3)

      // below options require 'tile' to be set

      // width of image fits container, tiles to fill height
      static let tilingFitWidth = [Self.tile, ImageScaling(rawValue: 1 << 4)]
      // height of image fits container, tiles to fill width
      static let tilingFitHeight = [
        Self.tile, ImageScaling(rawValue: 1 << 5),
      ]
    }
  }
}

#Playground {
  let theme = Theming.defaultThemes.first!
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  let data = try! encoder.encode(theme)
  let jsonString = String(data: data, encoding: .utf8)!
  print(jsonString)
}
