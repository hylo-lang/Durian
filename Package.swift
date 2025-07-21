// swift-tools-version: 6.1

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
