// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KyxEngine",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Telex", targets: ["Telex"]),
    ],
    targets: [
        .target(name: "Telex"),
        .testTarget(name: "TelexTests", dependencies: ["Telex"]),
    ]
)
