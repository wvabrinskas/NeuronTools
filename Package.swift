// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NeuronTools",
    platforms: [ .iOS(.v14),
                 .tvOS(.v14),
                 .watchOS(.v7),
                 .macOS(.v14)],
    products: [
        .executable(name: "Visualizer",
                    targets: ["NeuronVisualizer"]),
        .executable(name: "ModelPlayground",
                    targets: ["ModelPlayground"])
    ],
    dependencies: [
      .package(url: "https://github.com/wvabrinskas/Neuron.git", branch: "develop"),
      .package(url: "https://github.com/wvabrinskas/NumSwift.git", branch: "main"),
      .package(url: "https://github.com/wvabrinskas/Logger.git", from: "1.0.6"),
      .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
      .target(
          name: "Shared",
          dependencies: ["Neuron",
                         "NumSwift"]),
        .executableTarget(
            name: "NeuronVisualizer",
            dependencies: [
              "NumSwift",
              "Logger",
              "Neuron",
              "Shared",
              .product(name: "Numerics", package: "swift-numerics"),
            ]),
        .executableTarget(
            name: "ModelPlayground",
            dependencies: [
              "NumSwift",
              "Logger",
              "Neuron",
              "Shared",
              .product(name: "Numerics", package: "swift-numerics"),
            ])
    ]
)
