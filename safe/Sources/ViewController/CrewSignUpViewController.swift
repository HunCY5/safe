//
//  CrewSignUpViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//
import UIKit

class CrewSignUpViewController: UIViewController, CrewSignUpViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white

        let crewSignUpView = CrewSignUpView()
        crewSignUpView.translatesAutoresizingMaskIntoConstraints = false
        crewSignUpView.delegate = self
        view.addSubview(crewSignUpView)

        NSLayoutConstraint.activate([
            crewSignUpView.topAnchor.constraint(equalTo: view.topAnchor),
            crewSignUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            crewSignUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            crewSignUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func didTapLoginButton() {
        let loginVC = CrewLoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
