// swift-tools-version:5.5
import PackageDescription

let package = Package(
    
    name: "ADPhotoKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10)
    ],
    
    products: [
        .library(
            name: "ADPhotoKit",
            targets: ["ADPhotoKit"])
    ],
    
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "6.0.0")
    ],
    
    targets: [
        .target(
            name: "ADPhotoKit",
            dependencies: [
                "SnapKit","Kingfisher"
            ],
            path: "ADPhotoKit",
            resources: [
                .process("Assets/")
            ],
            swiftSettings: [
                .define("Module_Core"),
                .define("Module_UI"),
                .define("Module_ImageEdit")
            ]
        )
    ]
)
