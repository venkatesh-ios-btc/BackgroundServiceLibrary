// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BackgroundServiceLibrary",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BackgroundServiceLibrary",
            targets: ["BackgroundServiceLibrary"]),
    ],
    targets: [
        .target(
            name: "BackgroundServiceLibrary",
            dependencies: []),
        .testTarget(
            name: "BackgroundServiceLibraryTests",
            dependencies: ["BackgroundServiceLibrary"]),
    ]
)
