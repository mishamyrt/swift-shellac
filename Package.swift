// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shellac",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(name: "Shellac", targets: ["Shellac"])
    ],
    targets: [
        .target(
            name: "Shellac",
            path: "Sources"
        ),
        .testTarget(
            name: "ShellacTests",
            dependencies: ["Shellac"]
        )
    ]
)
