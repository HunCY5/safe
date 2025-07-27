//
//  SceneDelegate.swift
//  PoseEstimation
//
//  Created by CHOI on 7/21/25.
//

import UIKit
import FirebaseAuth

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
        
        // 로그인 여부 확인 후 tag3(Profile)로 이동
        if Auth.auth().currentUser == nil {
            mainVC.selectedIndex = 3
        }

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
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
