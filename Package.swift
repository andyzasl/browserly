// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Browserly",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Browserly",
            targets: ["Browserly"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Browserly",
            dependencies: [],
            path: "Sources/Browserly",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "BrowserlyTests",
            dependencies: ["Browserly"],
            path: "Tests/BrowserlyTests"
        ),
    ]
)
