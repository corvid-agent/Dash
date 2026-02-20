// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Dash",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Dash",
            path: "Sources/Dash"
        ),
        .executableTarget(
            name: "DashTests",
            path: "Tests/DashTests"
        ),
    ]
)
