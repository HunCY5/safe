//
//  ProfileViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        self.title = "프로필 관리"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .white

        guard let user = Auth.auth().currentUser else {
            let profileView = ProfileView(
                frame: .zero,
                isLoggedIn: false,
                userName: "",
                userId: "",
                isManager: false
            )
            profileView.translatesAutoresizingMaskIntoConstraints = false
            profileView.delegate = self
            view.addSubview(profileView)

            NSLayoutConstraint.activate([
                profileView.topAnchor.constraint(equalTo: view.topAnchor),
                profileView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let error = error {
                print("유저 정보 가져오기 실패: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("유저 정보 없음")
                return
            }

            let name = data["name"] as? String ?? "알 수 없음"
            let type = data["Type"] as? String ?? "crew"
            let phoneNumber = data["phoneNumber"] as? String ?? "알 수 없음"
            let companyName = data["companyName"] as? String ?? "알 수 없음"
            let businessNumber = data["businessNumber"] as? String
            let id: String
            if type == "manager" {
                id = data["managerId"] as? String ?? "N/A"
            } else {
                id = data["employeeId"] as? String ?? "N/A"
            }

            DispatchQueue.main.async {
                let profileView = ProfileView(
                    frame: .zero,
                    isLoggedIn: true,
                    userName: name,
                    userId: "\(id)",
                    isManager: type == "manager"
                )
                profileView.translatesAutoresizingMaskIntoConstraints = false
                profileView.delegate = self
                self.view.addSubview(profileView)

                NSLayoutConstraint.activate([
                    profileView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    profileView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                    profileView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    profileView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                ])

                let privateInfoCard = profileView.setupPrivateInfoSection(
                    type: type,
                    phoneNumber: phoneNumber,
                    companyName: companyName,
                    businessNumber: businessNumber
                )
                profileView.contentStackView.insertArrangedSubview(privateInfoCard, at: 1)
            }
        }
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func didTapLoginButton() {
        let vc = ChoiceLoginViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapWorkerSignupButton() {
        let vc = CrewSignUpViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapManagerSignupButton() {
        let vc = ManagerSignUpViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapLogoutButton() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "예", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            do {
                try Auth.auth().signOut()

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    let tabBarController = MainTabBarController()
                    tabBarController.selectedIndex = 3
                    UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = tabBarController
                    })
                }
            } catch {
                print("로그아웃 실패: \(error.localizedDescription)")
            }
        }))
        present(alert, animated: true)
    }
}
