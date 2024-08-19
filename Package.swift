// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AWSAppSyncApolloInterceptors",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v9)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AWSAppSyncApolloInterceptors",
            targets: ["AWSAppSyncApolloInterceptors"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AWSAppSyncApolloInterceptors",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloWebSocket", package: "apollo-ios")
            ]),
        .testTarget(
            name: "AWSAppSyncApolloInterceptorsTests",
            dependencies: ["AWSAppSyncApolloInterceptors"]),
    ]
)
