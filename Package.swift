// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ReleaseCheck",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "NetworkClient",
            path: "Sources/NetworkClient"
        ),
        .target(
            name: "TunesAPI",
            dependencies: ["NetworkClient"],
            path: "Sources/TunesAPI"
        ),
        .target(
            name: "SlackAPI",
            dependencies: ["NetworkClient"],
            path: "Sources/SlackAPI"
        ),
        .executableTarget(
            name: "recheck",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "TunesAPI",
                "SlackAPI"
            ],
            path: "Sources/ReleaseCheck"),
    ]
)
