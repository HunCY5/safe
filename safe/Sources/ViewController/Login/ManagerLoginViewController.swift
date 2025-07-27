//
//  ManagerLoginViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol ManagerLoginDelegate: AnyObject {
    func didLoginSuccessfully()
}

class ManagerLoginViewController: UIViewController, ManagerLoginViewDelegate {
    private let managerLoginView = ManagerLoginView()
    private let managerLoginModel = ManagerLoginModel()
    weak var delegate: ManagerLoginDelegate?
    var onLoginSuccess: (() -> Void)?
    
    override func loadView() {
        view = managerLoginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white
        
        managerLoginView.delegate = self
        managerLoginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        // No need to add crewLoginView as subview or set constraints, since it's already the root view.
    }
    
    @objc private func loginButtonTapped() {
        guard let id = managerLoginView.idTextField.text, !id.isEmpty else {
            showAlert(title: "로그인 실패", message: "관리자ID를 입력해주세요.")
            return
        }
        guard let password = managerLoginView.passwordTextField.text, !password.isEmpty else {
            showAlert(title: "로그인 실패", message: "비밀번호를 입력해주세요.")
            return
        }

        managerLoginModel.login(managerId: id, password: password, expectedType: "manager") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        let tabBarController = MainTabBarController()
                        tabBarController.selectedIndex = 3
                        window.rootViewController = tabBarController
                        window.makeKeyAndVisible()
                    }
                case .failure(let error):
                    try? Auth.auth().signOut()
                    self?.showAlert(title: "로그인 실패", message: error.localizedDescription)
                }
            }
        }
    }
    
    func didTapLoginButton(id: String, password: String) {
        print("✅ 전달 받은 관리자ID: \(id), 비밀번호: \(password)")
        // This method can be used if needed, or removed if not used.
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
}
