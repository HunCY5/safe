//
//  MainTabBarController.swift
//  safe
//
//  Created by 신찬솔 on 07/27/25.
//

import UIKit
import FirebaseAuth

final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupTabs()
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = UIColor.systemGray3
    }

    private func setupTabs() {
        let SafeVS = UINavigationController(rootViewController: SafetyManagerViewController())
        SafeVS.tabBarItem = UITabBarItem(title: "안전감시", image: UIImage(systemName: "shield.fill"), tag: 0)

        let LogVC = UINavigationController(rootViewController: LiskLogViewController())
        LogVC.tabBarItem = UITabBarItem(title: "위험로그", image: UIImage(systemName: "exclamationmark.triangle.fill"), tag: 1)

        let CrewManageVC = UINavigationController(rootViewController: CrewManageViewController())
        CrewManageVC.tabBarItem = UITabBarItem(title: "근로자", image: UIImage(systemName: "person.2.fill"), tag: 2)

        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person.fill"), tag: 3)

        viewControllers = [SafeVS, LogVC, CrewManageVC, profileVC]
    }
    // 로그인 여부에 따라 탭 선택 제한
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let isLoggedIn = Auth.auth().currentUser != nil
        if !isLoggedIn {
            return viewController.tabBarItem.tag == 3
        }
        return true
    }
}
