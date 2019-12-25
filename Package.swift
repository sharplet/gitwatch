// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "gitwatch",
  platforms: [
    .macOS(.v10_12),
  ],
  dependencies: [
    .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.0"),
  ],
  targets: [
    .target(name: "gitwatch", dependencies: ["Regex"]),
  ]
)
