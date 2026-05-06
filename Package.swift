// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "Paicord",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  dependencies: [
    // Local
    .package(path: "PaicordLib"),
    .package(path: "DiscordMarkdownParser"),

    // App-level dependencies
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", branch: "master"),
    .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.3.0"),
    .package(url: "https://github.com/patskovn/MeshGradient", branch: "main"),
    .package(url: "https://github.com/SwiftUIX/SwiftUIX", branch: "master"),
    .package(url: "https://github.com/llsc12/hcaptcha", branch: "master"),
    .package(url: "https://github.com/FLEXTool/FLEX", branch: "master"),
    .package(url: "https://github.com/airbnb/lottie-spm", from: "4.5.2"),
    .package(url: "https://github.com/llsc12/HighlightSwift", branch: "main"),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI", from: "3.1.3"),
    .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.0"),
    .package(url: "https://github.com/YusukeHosonuma/SwiftPrettyPrint", from: "1.4.0"),
    .package(url: "https://github.com/llsc12/ColorCube", branch: "main"),
    .package(url: "https://github.com/Aeastr/SettingsKit", from: "1.0.1"),
    .package(url: "https://github.com/Aeastr/Conditionals", from: "1.2.0"),
    .package(url: "https://github.com/twostraws/CodeScanner", from: "2.5.2"),
    .package(url: "https://github.com/Aeastr/SwiftEmoji", from: "1.1.0"),
    .package(url: "https://github.com/Aeastr/Loupe", from: "3.0.0"),

    // Thank you lawd apple
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
  ],
  targets: [
    .executableTarget(
      name: "Paicord",
      dependencies: [
        // Local
        .product(name: "PaicordLib", package: "PaicordLib"),
        .product(name: "DiscordMarkdownParser", package: "DiscordMarkdownParser"),

        // External
        .product(name: "KeychainAccess", package: "KeychainAccess"),
        .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        .product(name: "MeshGradient", package: "MeshGradient"),
        .product(name: "MeshGradientCHeaders", package: "MeshGradient"),
        .product(name: "SwiftUIX", package: "SwiftUIX"),
        .product(name: "HCaptcha", package: "hcaptcha"),
        .product(name: "FLEX", package: "FLEX", condition: .when(platforms: [.iOS])),
        .product(name: "Lottie", package: "lottie-spm"),
        .product(name: "HighlightSwift", package: "HighlightSwift"),
        .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
        .product(name: "Sparkle", package: "Sparkle", condition: .when(platforms: [.macOS])),
        .product(name: "SwiftPrettyPrint", package: "SwiftPrettyPrint"),
        .product(name: "ColorCube", package: "ColorCube"),
        .product(name: "SettingsKit", package: "SettingsKit"),
        .product(name: "Conditionals", package: "Conditionals"),
        .product(name: "CodeScanner", package: "CodeScanner"),
        .product(name: "SwiftEmoji", package: "SwiftEmoji"),
        .product(name: "SwiftEmojiIndex", package: "SwiftEmoji"),
        .product(name: "Loupe", package: "Loupe"),

        // apple
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Algorithms", package: "swift-algorithms"),
      ],
      path: "Paicord",
      exclude: [
        "Info.plist",
        "Paicord.entitlements",
      ],
      resources: [
        .process("Resources"),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v5),
        .enableUpcomingFeature("ExistentialAny"),
      ]
    ),
  ]
)
