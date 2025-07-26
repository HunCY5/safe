//
//  MainTabBarController.swift
//  FaceInn
//
//  Created by 신찬솔 on 5/18/25.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let homeVC = UINavigationController(rootViewController: SafetyManagerViewController())
        homeVC.tabBarItem = UITabBarItem(title: "안전감시", image: UIImage(systemName: "shield"), tag: 0)

        let wishlistVC = UINavigationController(rootViewController: LiskLogViewController())
        wishlistVC.tabBarItem = UITabBarItem(title: "위험로그", image: UIImage(systemName: "exclamationmark.triangle"), tag: 1)

        let tripsVC = UINavigationController(rootViewController: CrewManageViewController())
        tripsVC.tabBarItem = UITabBarItem(title: "근로자", image: UIImage(systemName: "person.2"), tag: 2)

//        let messageVC = UINavigationController(rootViewController: MessageViewController())
//        messageVC.tabBarItem = UITabBarItem(title: "메시지", image: UIImage(systemName: "message"), tag: 3)

        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), tag: 3)

        viewControllers = [homeVC, wishlistVC, tripsVC/*, messageVC*/, profileVC]
    }
}
