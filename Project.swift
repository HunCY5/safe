import ProjectDescription

let project = Project(
    name: "safe",
    packages: [
      .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.15.0")),
      .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0"))
      ],
    targets: [
        .target(
            name: "safe",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.safe",
            infoPlist: .extendingDefault(
                with: [
                    // 앱 이름
                    "CFBundleDisplayName": "세잎",
                    // 카메라 접근 이유
                    "NSCameraUsageDescription": "세잎 앱이 실시간 자세 추적 & 보호구 착용 탐지를 위해 카메라를 사용합니다.",
                    // 런치 스크린 기본값
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    // 씬 기반 라이프사이클 설정
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                                    
                                ]
                            ]
                        ]
                    ],
                    "UIDesignRequiresCompatibility": true,
                    // 앱 버전 정보
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",
                ]
            ),
            sources: ["safe/Sources/**"],
            resources: [
                // mlpackage는 폴더 참조로 번들에 포함
                .folderReference(path: "safe/Resources/DetectionYolov11.mlpackage"),
                // 나머지 일반 리소스(mlpackage 내부는 중복 포함되지 않도록 제외)
                .glob(pattern: "safe/Resources/**", excluding: ["safe/Resources/DetectionYolov11.mlpackage/**"]),
                .glob(pattern: "safe/Sources/ML/Models/**"),
                
            ],dependencies: [
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseAuth"),
                .package(product: "FirebaseFirestore"),
                .package(product: "FirebaseStorage"),
                .package(product: "FirebaseDatabase"),
                .package(product: "FirebaseMessaging"),
                .package(product: "Kingfisher")
            ],
        ),
        .target(
            name: "safeTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.safeTests",
            infoPlist: .default,
            sources: ["safe/Tests/**"],
            resources: [],
            dependencies: [.target(name: "safe")]
        ),
    ]
)
