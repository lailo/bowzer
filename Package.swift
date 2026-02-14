// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Bowzer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Bowzer", targets: ["Bowzer"])
    ],
    targets: [
        .executableTarget(
            name: "Bowzer",
            path: "Bowzer",
            exclude: ["Resources/Info.plist", "Bowzer.entitlements"]
        )
    ]
)
