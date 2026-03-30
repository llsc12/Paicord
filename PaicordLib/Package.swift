// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "PaicordLib",
  platforms: [
    .macOS(.v15),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(
      name: "PaicordLib",
      type: .dynamic,
      targets: ["PaicordLib"],
    ),
    .library(
      name: "DiscordCore",
      type: .dynamic,
      targets: ["DiscordCore"]
    ),
    .library(
      name: "DiscordHTTP",
      type: .dynamic,
      targets: ["DiscordHTTP"]
    ),
    .library(
      name: "DiscordGateway",
      type: .dynamic,
      targets: ["DiscordGateway"]
    ),
    .library(
      name: "DiscordModels",
      type: .dynamic,
      targets: ["DiscordModels"]
    ),
    .library(
      name: "DiscordUtilities",
      type: .dynamic,
      targets: ["DiscordUtilities"]
    ),
    .library(
      name: "DiscordAuth",
      type: .dynamic,
      targets: ["DiscordAuth"]
    ),
  ],
  traits: [
    "Non64BitSystemsCompatibility"
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.49.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2"),
    .package(
      url: "https://github.com/swift-server/async-http-client.git",
      from: "1.21.0"
    ),
    .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.5.3"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.5"),
    .package(
      url: "https://github.com/swiftlang/swift-syntax.git",
      "509.0.0"..<"603.0.0"
    ),
    .package(url: "https://github.com/facebook/zstd.git", from: "1.5.7"),
    .package(
      url: "https://github.com/hummingbird-project/swift-websocket.git",
      from: "1.2.0"
    ),
    .package(
      url: "https://github.com/apple/swift-protobuf.git",
      from: "1.27.0"
    ),
    .package(
      url: "https://github.com/Jitsusama/UInt128.git",
      branch: "master"
    ),
    .package(
      url: "https://github.com/apple/swift-crypto.git",
      "1.0.0"..<"5.0.0"
    ),
    .package(url: "https://github.com/swiftlang/swift-java", branch: "main"),
    .package(url: "https://github.com/swiftlang/swift-java-jni-core", branch: "main") // temporary
  ],
  targets: [
    .target(
      name: "PaicordLib",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java"),
        .product(name: "SwiftJavaJNICore", package: "swift-java-jni-core"),
        .target(name: "DiscordAuth"),
        .target(name: "DiscordHTTP"),
        .target(name: "DiscordCore"),
        .target(name: "DiscordGateway"),
        .target(name: "DiscordModels"),
        .target(name: "DiscordUtilities"),
      ],
      swiftSettings: swiftSettings,
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    ),
    .target(
      name: "DiscordCore",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
        .product(name: "MultipartKit", package: "multipart-kit"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "DiscordHTTP",
      dependencies: [
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .target(name: "DiscordModels"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "DiscordGateway",
      dependencies: [
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "WSClient", package: "swift-websocket"),
        .product(name: "libzstd", package: "zstd"),
        .target(name: "DiscordHTTP"),
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "_CryptoExtras", package: "swift-crypto"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "DiscordModels",
      dependencies: [
        .product(name: "NIOFoundationCompat", package: "swift-nio"),
        .product(name: "MultipartKit", package: "multipart-kit"),
        .target(name: "DiscordCore"),
        .target(name: "UnstableEnumMacro"),
        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
        .product(name: "UInt128", package: "UInt128"),
      ],
      exclude: ["Protobuf/README.md"],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "DiscordUtilities",
      dependencies: [
        .target(name: "DiscordModels")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "DiscordAuth",
      dependencies: [
        .target(name: "DiscordModels")
      ],
      swiftSettings: swiftSettings
    ),
    .plugin(
      name: "GenerateAPIEndpoints",
      capability: .command(
        intent: .custom(
          verb: "generate-api-endpoints",
          description: "Generates API Endpoints"
        ),
        permissions: [
          .writeToPackageDirectory(reason: "Add Generated Endpoints")
        ]
      ),
      dependencies: [
        .target(name: "GenerateAPIEndpointsExec")
      ]
    ),
    .executableTarget(
      name: "GenerateAPIEndpointsExec",
      dependencies: [
        .product(name: "NIOHTTP1", package: "swift-nio"),
        .product(name: "Yams", package: "Yams"),
      ],
      path: "Plugins/GenerateAPIEndpointsExec",
      resources: [.copy("Resources/openapi.yml")],
      swiftSettings: swiftSettings
    ),
    .executableTarget(
      name: "TestCode",
      dependencies: [
        .target(name: "PaicordLib")
      ],
      swiftSettings: swiftSettings
    ),
    .macro(
      name: "UnstableEnumMacro",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ],
      path: "./Macros/UnstableEnumMacro",
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "DiscordBMTests",
      dependencies: [
        .target(name: "PaicordLib")
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "MacroTests",
      dependencies: [
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        .target(name: "UnstableEnumMacro"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "IntegrationTests",
      dependencies: [
        .target(name: "PaicordLib")
      ],
      swiftSettings: swiftSettings
    ),
  ]
)

var featureFlags: [SwiftSetting] {
  [
    // fixes a swift module resolution bug when using swift-java
    .swiftLanguageMode(.v5),
    /// https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md
    /// Require `any` for existential types.
    .enableUpcomingFeature("ExistentialAny")
    //		.define("DISCORDBM_ENABLE_LOGGING_DURING_DECODE", .when(configuration: .debug)),
  ]
}

var swiftSettings: [SwiftSetting] {
  featureFlags
}
