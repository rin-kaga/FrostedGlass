// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FrostedGlass",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FrostedGlass",
            targets: ["FrostedGlass"]
        )
    ],
    targets: [
        .target(
            name: "FrostedGlass",
            path: "Sources/FrostedGlass"
        )
    ]
)
