import ProjectDescription

let project = Project(
    name: "safe",
    targets: [
        .target(
            name: "safe",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.safe",
            infoPlist: .extendingDefault(
                with: [
                    // 카메라 접근 이유
                    "NSCameraUsageDescription": "세잎 앱이 실시간 자세 추적을 위해 카메라를 사용합니다.",
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
                    ]
                ]
            ),
            sources: ["safe/Sources/**"],
            resources: [
                "safe/Resources/**",
                "safe/Sources/ML/Models/**"
            ],
            dependencies: []
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
