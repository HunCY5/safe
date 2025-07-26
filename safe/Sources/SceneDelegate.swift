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
        
        let mainVC = MainTabBarController()
        window.rootViewController = mainVC
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

extension UIViewController {
    /// 탭 제스처를 등록하여 키보드를 화면 터치 시 dismiss합니다.
    func dismissKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // 버튼 클릭 등도 동작하게 유지
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}


