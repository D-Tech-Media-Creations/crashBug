// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "crashBug",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "crashBug",
            targets: ["crashBug"]
        ),
    ],
    targets: [
        .target(
            name: "crashBug",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "crashBugTests",
            dependencies: ["crashBug"],
            path: "Tests"
        ),
    ]
)// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "crashBug",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "crashBug",
            targets: ["crashBug"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "crashBug"),

    ]
)
