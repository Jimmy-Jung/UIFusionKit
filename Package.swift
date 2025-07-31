// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "UIFusionKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "UIFusionKit",
            targets: ["UIFusionKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.2.1"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.6"),
        .package(url: "https://github.com/layoutBox/FlexLayout.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/layoutBox/PinLayout.git", .upToNextMajor(from: "1.10.5")),
        .package(url: "https://github.com/ReactorKit/ReactorKit.git", .upToNextMajor(from: .init(3, 2, 0))),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: .init(6, 6, 0))),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: .init(1, 21, 0))),
    ],
    targets: [
        .target(
            name: "UIFusionKit",
            dependencies: [
                "Then",
                "SnapKit",
                "CombineCocoa",
                "Starscream",
                "FlexLayout",
                "PinLayout",
                "ReactorKit",
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "UIFusionKitTests",
            dependencies: ["UIFusionKit"]
        ),
        .testTarget(
            name: "CalculatorDomainTests",
            dependencies: ["UIFusionKit"],
            path: "Tests/CalculatorDomainTests"
        ),
    ]
)
