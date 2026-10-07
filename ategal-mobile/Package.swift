// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "ategal-mobile",
    defaultLocalization: "gl-ES",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(name: "Ategal", type: .dynamic, targets: ["Ategal"]),
        .library(name: "AtegalCore", type: .dynamic, targets: ["AtegalCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/skiptools/skip.git", exact: "1.9.13"),
        .package(url: "https://github.com/skiptools/skip-model.git", exact: "1.8.0"),
        .package(url: "https://github.com/skiptools/skip-ui.git", exact: "1.61.0"),
        .package(url: "https://github.com/skiptools/skip-fuse.git", exact: "1.0.3"),
        .package(url: "https://github.com/skiptools/skip-fuse-ui.git", exact: "1.19.0"),
        .package(url: "https://github.com/skiptools/skip-unit.git", exact: "1.7.2"),
        .package(url: "https://github.com/skiptools/skip-bridge.git", exact: "0.18.0"),
        .package(
            url: "https://github.com/michele-theleftbit/skip-firebase-swift64.git",
            revision: "247a9d62ff473405854f763dc0b35e7770e174c8"
        ),
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
                .product(name: "SkipFirebaseCore", package: "skip-firebase-swift64"),
                .product(name: "SkipFirebaseAnalytics", package: "skip-firebase-swift64"),
                .product(name: "SkipFirebaseCrashlytics", package: "skip-firebase-swift64"),
                .product(name: "SkipFirebaseAuth", package: "skip-firebase-swift64"),
                .product(name: "SkipFirebaseMessaging", package: "skip-firebase-swift64"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS", condition: .when(platforms: [.iOS])),
                .product(name: "RStudioKit", package: "RStudioKit")
            ],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
    ]
)
