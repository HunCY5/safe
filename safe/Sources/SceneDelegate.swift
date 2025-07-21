//
//  SceneDelegate.swift
//  PoseEstimation
//
//  Created by CHOI on 7/21/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // ViewController.swift를 메인 루트로 설정
        let mainVC = ViewController()
        window.rootViewController = mainVC
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
