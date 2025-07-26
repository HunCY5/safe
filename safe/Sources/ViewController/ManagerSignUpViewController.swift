//
//  ManagerSignUpViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

class ManagerSignUpViewController: UIViewController, ManagerSignUpViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white

        let managerSignUpView = ManagerSignUpView()
        managerSignUpView.delegate = self
        managerSignUpView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(managerSignUpView)

        NSLayoutConstraint.activate([
            managerSignUpView.topAnchor.constraint(equalTo: view.topAnchor),
            managerSignUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            managerSignUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            managerSignUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func didTapLoginButton() {
        let loginVC = ManagerLoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
