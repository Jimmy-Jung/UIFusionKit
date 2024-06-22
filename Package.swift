// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "UIFusionKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "UIFusionKit",
            targets: ["UIFusionKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
    ],
    targets: [
        .target(
            name: "UIFusionKit",
            dependencies: [
                "Then",
                "SnapKit",
            ]
        ),
        .testTarget(
            name: "UIFusionKitTests",
            dependencies: ["UIFusionKit"]
        ),
    ]
)
