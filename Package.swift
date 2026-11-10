// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "MantisShrimp",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "PostureCore"),
        .target(name: "ShrimpArt"),
        .executableTarget(name: "MantisShrimp", dependencies: ["PostureCore", "ShrimpArt"]),
        .executableTarget(name: "ShrimpIconTool", dependencies: ["ShrimpArt"]),
        .testTarget(name: "PostureCoreTests", dependencies: ["PostureCore"]),
    ]
)
