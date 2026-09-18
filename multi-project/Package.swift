// swift-tools-version: 6.3
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "multi-project",
    defaultLocalization: "gl-ES",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(name: "Ategal", type: .dynamic, targets: ["Ategal"]),
        .library(name: "AtegalCore", type: .dynamic, targets: ["AtegalCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/skiptools/skip.git", exact: "1.9.9"),
        .package(url: "https://github.com/skiptools/skip-model.git", exact: "1.7.10"),
        .package(url: "https://github.com/skiptools/skip-ui.git", exact: "1.59.4"),
        .package(url: "https://github.com/skiptools/skip-fuse.git", exact: "1.0.3"),
        .package(url: "https://github.com/skiptools/skip-fuse-ui.git", exact: "1.18.2"),
        .package(url: "https://github.com/skiptools/skip-unit.git", exact: "1.7.2"),
        .package(url: "https://github.com/skiptools/skip-bridge.git", exact: "0.17.3"),
        .package(url: "https://github.com/skiptools/skip-firebase", exact: "0.20.4"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", exact: "10.0.0"),
        .package(path: "../../../MR/RStudioKit")
    ],
    targets: [
        .target(
            name: "Ategal",
            dependencies: [
                "AtegalCore",
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
                .product(name: "RStudioKit", package: "RStudioKit")
            ],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .target(
            name: "AtegalCore",
            dependencies: [
                .product(name: "SkipFuse", package: "skip-fuse"),
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
                .product(name: "SkipModel", package: "skip-model"),
                .product(name: "SkipUnit", package: "skip-unit"),
                .product(name: "SkipUI", package: "skip-ui"),
                .product(name: "SkipBridge", package: "skip-bridge"),
                .product(name: "SkipFirebaseCore", package: "skip-firebase"),
                .product(name: "SkipFirebaseAnalytics", package: "skip-firebase"),
                .product(name: "SkipFirebaseCrashlytics", package: "skip-firebase"),
                .product(name: "SkipFirebaseAuth", package: "skip-firebase"),
                .product(name: "SkipFirebaseMessaging", package: "skip-firebase"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS", condition: .when(platforms: [.iOS])),
                .product(name: "RStudioKit", package: "RStudioKit")
            ],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
    ]
)
