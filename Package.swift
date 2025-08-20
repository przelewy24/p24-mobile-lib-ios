// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "P24",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "P24",
            targets: ["P24"]
        )
    ],
    targets: [
        .binaryTarget(
          name: "P24",
          path: "libP24.xcframework"
        )
    ]
)