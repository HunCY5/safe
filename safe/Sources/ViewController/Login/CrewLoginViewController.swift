//
//  CrewLoginViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol CrewLoginDelegate: AnyObject {
    func didLoginSuccessfully()
}

class CrewLoginViewController: UIViewController {
    private let crewLoginView = CrewLoginView()
    private let crewLoginModel = CrewLoginModel()
    weak var delegate: CrewLoginDelegate?
    var onLoginSuccess: (() -> Void)?
    
    override func loadView() {
        view = crewLoginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        
        crewLoginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func loginButtonTapped() {
        guard let id = crewLoginView.employeeTextField.text, !id.isEmpty else {
            showAlert(title: "로그인 실패", message: "사번을 입력해주세요.")
            return
        }
        guard let password = crewLoginView.passwordTextField.text, !password.isEmpty else {
            showAlert(title: "로그인 실패", message: "비밀번호를 입력해주세요.")
            return
        }

        crewLoginModel.login(empolyeeId: id, password: password, expectedType: "crew") { [weak self] result in
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
