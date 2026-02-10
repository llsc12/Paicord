// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "PaicordLib",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(
      name: "PaicordLib",
      type: .dynamic,
      targets: ["PaicordLib"]
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
      url: "https://github.com/apple/swift-syntax.git",
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
    .package(url: "https://source.skip.tools/skip.git", from: "1.7.1"),
    .package(url: "https://source.skip.tools/skip-bridge", from: "0.16.6"),
    .package(url: "https://source.skip.tools/skip-fuse.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "PaicordLib",
      dependencies: [
        .target(name: "DiscordAuth"),
        .target(name: "DiscordHTTP"),
        .target(name: "DiscordCore"),
        .target(name: "DiscordGateway"),
        .target(name: "DiscordModels"),
        .target(name: "DiscordUtilities"),
        .product(name: "SkipBridge", package: "skip-bridge"),
        .product(name: "SkipFuse", package: "skip-fuse"),
      ],
      plugins: [.plugin(name: "skipstone", package: "skip")]
    ),
    .target(
      name: "DiscordCore",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
        .product(name: "MultipartKit", package: "multipart-kit"),
        .product(name: "SkipBridge", package: "skip-bridge"),
      ],
      plugins: [.plugin(name: "skipstone", package: "skip")]
    ),
    .target(
      name: "DiscordHTTP",
      dependencies: [
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "SkipBridge", package: "skip-bridge"),
        .target(name: "DiscordModels"),
      ],
      plugins: [.plugin(name: "skipstone", package: "skip")]
    ),
    .target(
      name: "DiscordGateway",
      dependencies: [
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "WSClient", package: "swift-websocket"),
        .product(name: "libzstd", package: "zstd"),
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "_CryptoExtras", package: "swift-crypto"),
        .product(name: "SkipBridge", package: "skip-bridge"),
        .target(name: "DiscordHTTP"),
      ],
      plugins: [.plugin(name: "skipstone", package: "skip")]
    ),
    .target(
      name: "DiscordModels",
      dependencies: [
        .product(name: "NIOFoundationCompat", package: "swift-nio"),
        .product(name: "MultipartKit", package: "multipart-kit"),
        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
        .product(name: "UInt128", package: "UInt128"),
        .product(name: "SkipBridge", package: "skip-bridge"),
        .product(name: "SkipFuse", package: "skip-fuse"),
        .target(name: "DiscordCore"),
        .target(name: "UnstableEnumMacro"),
      ],
      plugins: [.plugin(name: "skipstone", package: "skip")]
    ),
    .target(
      name: "DiscordAuth",
      dependencies: [
        .product(name: "SkipBridge", package: "skip-bridge"),
        .target(name: "DiscordModels"),
      ],
      plugins: [.plugin(name: "skipstone", package: "skip")]
    ),
    .target(
      name: "DiscordUtilities",
      dependencies: [
        .product(name: "SkipBridge", package: "skip-bridge"),
        .target(name: "DiscordModels"),
      ],
      plugins: [.plugin(name: "skipstone", package: "skip")]
    ),
//    .plugin(
//      name: "GenerateAPIEndpoints",
//      capability: .command(
//        intent: .custom(
//          verb: "generate-api-endpoints",
//          description: "Generates API Endpoints"
//        ),
//        permissions: [
//          .writeToPackageDirectory(reason: "Add Generated Endpoints")
//        ]
//      ),
//      dependencies: [
//        .target(name: "GenerateAPIEndpointsExec")
//      ]
//    ),
//    .executableTarget(
//      name: "GenerateAPIEndpointsExec",
//      dependencies: [
//        .product(name: "NIOHTTP1", package: "swift-nio"),
//        .product(name: "Yams", package: "Yams"),
//      ],
//      path: "Plugins/GenerateAPIEndpointsExec",
//      resources: [.copy("Resources/openapi.yml")],
//    ),
//    .executableTarget(
//      name: "TestCode",
//      dependencies: [
//        .target(name: "PaicordLib")
//      ],
//    ),
    .macro(
      name: "UnstableEnumMacro",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ],
      path: "./Macros/UnstableEnumMacro",
    ),
//    .testTarget(
//      name: "DiscordBMTests",
//      dependencies: [
//        .target(name: "DiscordCore"),
//        .product(name: "SkipTest", package: "skip"),
//      ],
//    ),
//    .testTarget(
//      name: "MacroTests",
//      dependencies: [
//        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
//        .target(name: "UnstableEnumMacro"),
//        .product(name: "SkipTest", package: "skip"),
//      ],
//    ),
//    .testTarget(
//      name: "IntegrationTests",
//      dependencies: [
//        .target(name: "DiscordCore"),
//        .product(name: "SkipTest", package: "skip"),
//      ],
//    ),
  ]
)
