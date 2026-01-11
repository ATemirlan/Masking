// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Masking",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Masking", targets: ["Masking"]),
        .library(name: "MaskingCore", targets: ["MaskingCore"]),
        .library(name: "MaskingUIKit", targets: ["MaskingUIKit"]),
        .library(name: "MaskingSwiftUI", targets: ["MaskingSwiftUI"])
    ],
    targets: [
        .target(name: "MaskingCore", path: "Sources/MaskingCore"),
        .target(name: "MaskingUIKit", dependencies: ["MaskingCore"], path: "Sources/MaskingUIKit"),
        .target(name: "MaskingSwiftUI", dependencies: ["MaskingCore", "MaskingUIKit"], path: "Sources/MaskingSwiftUI"),
        .target(name: "Masking", dependencies: ["MaskingCore", "MaskingUIKit", "MaskingSwiftUI"], path: "Sources/Masking"),
        .testTarget(name: "MaskingCoreTests", dependencies: ["MaskingCore"])
    ]
)
