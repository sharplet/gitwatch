// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "gitwatch",
  platforms: [
    .macOS(.v10_12),
  ],
  targets: [
    .target(name: "gitwatch"),
  ]
)
