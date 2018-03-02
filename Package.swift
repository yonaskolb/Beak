// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Beak",
    products: [
        .executable(name: "beak", targets: ["Beak"]),
        .library(name: "BeakCore", targets: ["BeakCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten", from: "0.18.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.8.0"),
        .package(url: "https://github.com/kylef/Spectre.git", from: "0.8.0"),
        .package(url: "https://github.com/yonaskolb/swift-package-manager", .branch("untyped_arguments")),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "Beak",
            dependencies: [
              "BeakCore",
            ]),
        .target(
            name: "BeakCore",
            dependencies: [
              "SourceKittenFramework",
              "PathKit",
              "Utility",
              "SwiftShell",
            ]),
        .testTarget(name: "BeakTests", dependencies: [
          "BeakCore",
          "Spectre",
          "PathKit",
        ])
    ]
)
