// swift-tools-version: 5.6
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
//    .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", exact: "0.11.0"),
//    .package(url: "https://github.com/siteline/swiftui-introspect.git", from: "1.0.0"),
    .package(url: "https://github.com/siteline/swiftui-introspect.git", exact: "0.3.1"),
  ],
  targets: [
    .target(name: "Intercept", dependencies: [
      "InterceptObjC",
      .product(name: "Introspect", package: "swiftui-introspect"),
    ]),
    .target(name: "InterceptObjC", publicHeadersPath: "."),
    .testTarget(name: "InterceptTests", dependencies: ["Intercept"]),
  ]
)
