// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TapTalk",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16) // Needs to be iOS 16+ for newer Google Maps SDKs
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PowerTalk",
            targets: ["PowerTalk"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/SDWebImage/SDWebImage",
            from: "5.21.0"
        ),
        .package(
            url: "https://github.com/googlemaps/ios-maps-sdk",
            from: "10.15.0"
        ),
        .package(
            url: "https://github.com/googlemaps/ios-places-sdk",
            from: "10.15.0"
        ),
        .package(
            url: "https://github.com/realm/realm-swift",
            from: "20.0.0"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PowerTalk",
            dependencies: [
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
                .product(name: "GooglePlaces", package: "ios-places-sdk"),
                .product(name: "Realm", package: "realm-swift"),
            ],
            path: "TapTalk",
            sources: ["Components", "Managers", "Models", "View Controllers", "Views"],
            resources: [
                .process("Supporting Files/Fonts"),
                .process("XIB")
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Components"),
                .headerSearchPath("Managers"),
                .headerSearchPath("Models"),
                .headerSearchPath("View Controllers"),
                .headerSearchPath("Views")
            ],
        ),
        .testTarget(
            name: "TapTalkTests",
            dependencies: ["PowerTalk"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
