// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LBFileManager",
    platforms: [
        .macOS("14"),
        .watchOS("6.2"),
        .iOS("17"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LBFileManager",
            targets: ["LBFileManager"]
        ),
    ],
    dependencies: [
        .package(name: "LBFoundation", url: "https://github.com/LuisAlvarez12/LBFoundation.git", from: "2.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LBFileManager",
            dependencies: [
                .product(name: "LBFoundation", package: "LBFoundation"),
            ]
        ),
    ]
)
