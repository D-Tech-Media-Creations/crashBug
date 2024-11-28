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
               name: "AppResources",
               dependencies: [],
               resources: [
                   .process("Resources")]
           ),
    ]
)
