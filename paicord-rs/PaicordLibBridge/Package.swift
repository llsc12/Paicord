// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "PaicordLibBridge",
    products: [
        .library(name: "PaicordLibBridge", type: .static, targets: ["PaicordLibBridge"])
    ],
    dependencies: [
        .package(name: "PaicordLib", path: "../../PaicordLib")
    ],
    targets: [
        .target(
            name: "PaicordLibBridge",
            dependencies: ["PaicordLib"],
            path: "Sources",
        )
    ]
)