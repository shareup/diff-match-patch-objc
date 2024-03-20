// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiffMatchPatchObjC",
    products: [
        .library(
            name: "DiffMatchPatchObjC",
            type: .dynamic,
            targets: ["DiffMatchPatchObjC"]
        ),
    ],
    targets: [
        .target(
            name: "DiffMatchPatchObjC",
            cSettings: [.unsafeFlags(["-fno-objc-arc"])]
        ),
        .testTarget(
            name: "DiffMatchPatchObjCTests",
            dependencies: ["DiffMatchPatchObjC"]
        ),
    ]
)
