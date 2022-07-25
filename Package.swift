// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "Durian",
  products: [
    .library(name: "Durian", targets: ["Durian"]),
  ],

  targets: [
    .target(name: "Durian", dependencies: []),
    .testTarget(name: "DurianTests", dependencies: ["Durian"])
  ])
