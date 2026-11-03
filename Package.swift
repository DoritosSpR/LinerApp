// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LinerApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "LinerApp",
            targets: ["LinerApp"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LinerApp",
            dependencies: [
                "LinerCore",
                "LinerUI",
                "LinerFeatures",
            ],
            resources: [
                .process("../Resources"),
            ]
        ),
        .target(
            name: "LinerCore",
            dependencies: []
        ),
        .target(
            name: "LinerUI",
            dependencies: ["LinerCore"]
        ),
        .target(
            name: "LinerFeatures",
            dependencies: ["LinerCore", "LinerUI"]
        ),
    ]
)