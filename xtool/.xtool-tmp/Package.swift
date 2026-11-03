// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "LinerApp-Builder",
    platforms: [
        .iOS("17.0"),
    ],
    dependencies: [
        .package(name: "RootPackage", path: "../.."),
    ],
    targets: [
        .executableTarget(
    name: "LinerApp-App",
    dependencies: [
        .product(name: "LinerApp", package: "RootPackage"),
    ],
    linkerSettings: [
    .unsafeFlags([
        "-Xlinker", "-rpath", "-Xlinker", "@executable_path/Frameworks",
    ]),
]
)
    ]
)
