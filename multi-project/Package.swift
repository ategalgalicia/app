// swift-tools-version: 6.3
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "multi-project",
    defaultLocalization: "gl-ES",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Ategal", type: .dynamic, targets: ["Ategal"]),
        .library(name: "AtegalCore", type: .dynamic, targets: ["AtegalCore"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.9.7"),
        .package(url: "https://source.skip.tools/skip-model.git", from: "1.7.9"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "1.59.2"),
        .package(url: "https://source.skip.tools/skip-fuse.git", from: "1.0.3"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.18.1"),
        .package(url: "https://source.skip.tools/skip-unit.git", from: "1.7.1"),
        .package(url: "https://source.skip.tools/skip-bridge.git", from: "0.17.3"),
        .package(url: "https://github.com/skiptools/skip-firebase", from: "0.20.3"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.2.0"),
        .package(path: "../../../MR/RStudioKit")
    ],
    targets: [
        .target(
            name: "Ategal",
            dependencies: [
                "AtegalCore",
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
                .product(
                    name: "RStudioKit",
                    package: "RStudioKit"
                )
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
                .product(
                    name: "GoogleSignIn",
                    package: "GoogleSignIn-iOS",
                    condition: .when(platforms: [.iOS])
                ),
                .product(
                    name: "RStudioKit",
                    package: "RStudioKit"
                )
            ],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .testTarget(
            name: "AtegalCoreTests",
            dependencies: ["AtegalCore"],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        )
    ]
)
