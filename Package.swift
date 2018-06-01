// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Beak",
    products: [
        .executable(name: "beak", targets: ["Beak"]),
        .library(name: "BeakCore", targets: ["BeakCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten", from: "0.19.1"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.8.0"),
        .package(url: "https://github.com/kylef/Spectre.git", from: "0.8.0"),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.1.0"),
    ],
    targets: [
        .target(
            name: "Beak",
            dependencies: [
                "BeakCLI",
            ]),
        .target(
            name: "BeakCLI",
            dependencies: [
                "BeakCore",
                "SwiftCLI",
            ]),
        .target(
            name: "BeakCore",
            dependencies: [
                "SourceKittenFramework",
                "PathKit",
                "SwiftCLI",
            ]),
        .testTarget(
            name: "BeakTests", 
            dependencies: [
                "BeakCore",
                "Spectre",
                "PathKit",
            ])
    ]
)
