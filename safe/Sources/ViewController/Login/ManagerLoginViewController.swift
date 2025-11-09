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

class ManagerLoginViewController: UIViewController{
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
        
        managerLoginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
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
                        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
                            window.rootViewController = tabBarController
                        })
                    }
                case .failure(let error):
                    try? Auth.auth().signOut()
                    self?.showAlert(title: "로그인 실패", message: error.localizedDescription)
                }
            }
        }
    }
    
 
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
}
