// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TokenTea",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TokenTea", targets: ["TokenTea"])
    ],
    targets: [
        .executableTarget(
            name: "TokenTea",
            path: "Sources/TokenTea"
        ),
        .testTarget(
            name: "TokenTeaTests",
            dependencies: ["TokenTea"],
            path: "Tests/TokenTeaTests"
        )
    ]
)
