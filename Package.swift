// swift-tools-version:5.3
import PackageDescription

let package = Package(
    
    name: "ADPhotoKit",
    
    platforms: [
        .iOS(.v10)
    ],
    
    products: [
        .library(
            name: "ADPhotoKit",
            targets: ["ADPhotoKit"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "6.0.0"),
    ],
    
    targets: [
        .target(
            name: "ADPhotoKit",
            path: "ADPhotoKit/Classes",
            resources: [
                .process("ADPhotoKit/Assets")
            ],
            dependencies: [
                "SnapKit","Kingfisher"
        ]),
    ],
    
    // 库支持 Swift 语言版本
    swiftLanguageVersions: [
        .v5
    ]
)
