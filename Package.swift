// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-string",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "String",
            targets: ["String"]
        ),
        .library(
            name: "String Test Support",
            targets: ["String Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-memory-heap.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-span.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ownership.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "String",
            dependencies: [
                .product(name: "Memory Heap", package: "swift-memory-heap"),
                .product(name: "Span Protocol", package: "swift-span"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Ownership", package: "swift-ownership"),
            ],
            swiftSettings: [
                .define(
                    "STRING_AVAILABLE",
                    .when(platforms: [
                        .macOS, .iOS, .tvOS, .watchOS, .visionOS,
                        .linux, .windows, .android, .openbsd,
                    ])
                )
            ]
        ),
        .target(
            name: "String Test Support",
            dependencies: [
                "String",
                .product(
                    name: "Tagged Test Support",
                    package: "swift-tagged"
                ),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "String Tests",
            dependencies: [
                "String",
                "String Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
