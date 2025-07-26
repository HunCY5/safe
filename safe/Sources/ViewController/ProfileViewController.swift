//
//  ProfileViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white

        let profileView = ProfileView()
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.delegate = self
        view.addSubview(profileView)

        NSLayoutConstraint.activate([
            profileView.topAnchor.constraint(equalTo: view.topAnchor),
            profileView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func didTapLoginButton() {
        let vc = ChoiceLoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapWorkerSignupButton() {
        let vc = CrewSignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapManagerSignupButton() {
        let vc = ManagerSignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
