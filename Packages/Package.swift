// swift-tools-version:3.1

import PackageDescription

let package = Package(
  name: "Packages",
  dependencies: [
    .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2)
  ],
  exclude: [
    "Resources",
    "Pods",
    "Docs",
    "Tests",
    "build",
    ".build",
    "BitBar.xcworkspace",
    "BitBar.xcodeproj",
    "Sources/BitBar",
    "Sources/Startup",
    "Sources/Config",
    "Sources/CLI"
  ]
)
