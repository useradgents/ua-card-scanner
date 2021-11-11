// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ua-card-scanner",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ua-card-scanner", targets: ["ua-card-scanner"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ua-card-scanner", dependencies: []),
        .testTarget(name: "ua-card-scannerTests", dependencies: ["ua-card-scanner"])
    ],
    swiftLanguageVersions: [.v5]
)
