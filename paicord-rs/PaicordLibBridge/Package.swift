// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "PaicordLibBridge",
    products: [
        .library(name: "PaicordLibBridge", type: .dynamic, targets: ["PaicordLibBridge"])
    ],
    dependencies: [
        .package(name: "PaicordLib", path: "../../PaicordLib"),
        .package(name: "DiscordMarkdownParser", path: "../../DiscordMarkdownParser")
    ],
    targets: [
        .target(
            name: "PaicordLibBridge",
            dependencies: ["PaicordLib", "DiscordMarkdownParser"],
            path: "Sources",
        )
    ]
)