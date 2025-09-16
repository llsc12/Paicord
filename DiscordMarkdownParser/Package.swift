// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DiscordMarkdownParser",
	platforms: [
		.macOS(.v14), .iOS(.v17),
	],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "DiscordMarkdownParser",
			targets: ["DiscordMarkdownParser"])
	],
	dependencies: [
		.package(path: "../PaicordLib")
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "DiscordMarkdownParser",
			dependencies: [
				"PaicordLib"
			]),
		.testTarget(
			name: "DiscordMarkdownParserTests",
			dependencies: ["DiscordMarkdownParser"]),
	]
)

