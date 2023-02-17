// swift-tools-version: 5.5
import PackageDescription

let package = Package(
  name: "intercept",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v11),
    .tvOS(.v11),
  ],
  products: [
    .library(name: "Intercept", targets: ["Intercept"]),
    .library(name: "InterceptObjC", targets: ["InterceptObjC"]),
  ],
  dependencies: [
    .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", branch: "master"),
  ],
  targets: [
    .target(name: "Intercept", dependencies: [
      "InterceptObjC",
      .product(name: "Introspect", package: "SwiftUI-Introspect"),
    ]),
    .target(name: "InterceptObjC", publicHeadersPath: "."),
    .testTarget(name: "InterceptTests", dependencies: ["Intercept"]),
  ]
)
