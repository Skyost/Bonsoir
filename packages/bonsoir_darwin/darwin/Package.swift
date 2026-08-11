// swift-tools-version: 5.9
import PackageDescription

// Test-only package for the parts of the plugin that do not depend on Flutter.
//
// `bonsoir_darwin/Package.swift` cannot be resolved on its own: it depends on
// the `FlutterFramework` package that Flutter generates during an app build and
// that is not part of this repository, so `swift test` is not possible there.
// This package compiles the Flutter-free sources directly, which makes the
// resolution logic testable with a plain `swift test` from this directory.
//
// It is not shipped: neither the podspec nor Flutter's Swift Package Manager
// integration looks at this file.
let package = Package(
    name: "bonsoir_darwin_tests",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15")
    ],
    targets: [
        .target(
            name: "BonsoirDarwinCore",
            path: "bonsoir_darwin/Sources/bonsoir_darwin",
            // Everything else in the plugin needs Flutter, so it is left out.
            exclude: [
                "BonsoirAction.swift",
                "Generated.swift",
                "SuccessObject.swift",
                "SwiftBonsoirPlugin.swift",
                "Broadcast/BonsoirServiceBroadcast.swift",
                "Discovery/BonsoirServiceDiscovery.swift"
            ],
            sources: [
                "BonsoirService.swift",
                "Discovery/ServiceResolution.swift"
            ]
        ),
        .testTarget(
            name: "BonsoirDarwinCoreTests",
            dependencies: ["BonsoirDarwinCore"],
            path: "Tests/BonsoirDarwinCoreTests"
        )
    ]
)
