//
//  CrewSignUpViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class CrewSignUpViewController: UIViewController, CrewSignUpViewDelegate {

    private let crewSignUpView = CrewSignUpView()
    private let crewSignUpmodel = CrewSignUpModel()
    private var isEmployeeAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white

        // 기존 인스턴스를 사용하도록 수정
        crewSignUpView.translatesAutoresizingMaskIntoConstraints = false
        crewSignUpView.delegate = self

        crewSignUpView.passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        crewSignUpView.confirmPasswordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        view.addSubview(crewSignUpView)

        NSLayoutConstraint.activate([
            crewSignUpView.topAnchor.constraint(equalTo: view.topAnchor),
            crewSignUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            crewSignUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            crewSignUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // 키보드 알림 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        configureActions()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func didTapLoginButton() {
        let loginVC = CrewLoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    private func configureActions() {
        
        crewSignUpView.duplicateCheckButton.addTarget(self, action: #selector(didTapDuplicateCheckButton), for: .touchUpInside)
        crewSignUpView.signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)

        // 입력 값이 변경될 때마다 유효성 확인
        [crewSignUpView.nameTextField,
         crewSignUpView.phoneTextField,
         crewSignUpView.employeeNumberTextField,
         crewSignUpView.passwordTextField,
         crewSignUpView.confirmPasswordTextField
        ].forEach { tf in
            tf.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }
    @objc private func textFieldChanged() {
        let name = crewSignUpView.nameTextField.text ?? ""
        let phone = crewSignUpView.phoneTextField.text ?? ""
        let employeeId = crewSignUpView.employeeNumberTextField.text ?? ""
        let password = crewSignUpView.passwordTextField.text ?? ""
        let confirm = crewSignUpView.confirmPasswordTextField.text ?? ""

        if !confirm.isEmpty {
            if password == confirm {
                crewSignUpView.passwordMatchLabel.text = "비밀번호가 일치합니다."
                crewSignUpView.passwordMatchLabel.textColor = .systemGreen
            } else {
                crewSignUpView.passwordMatchLabel.text = "비밀번호가 일치하지 않습니다."
                crewSignUpView.passwordMatchLabel.textColor = .red
            }
        } else {
            crewSignUpView.passwordMatchLabel.text = ""
        }

        let isFormValid = !name.isEmpty &&
                        !employeeId.isEmpty &&
                          phone.count >= 10 &&
                          phone.count <= 11 &&
                          phone.allSatisfy { $0.isNumber } &&
                          password.count >= 6 &&
                          password == confirm
        crewSignUpView.signUpButton.isEnabled = isFormValid
        crewSignUpView.signUpButton.backgroundColor = isFormValid ? .systemBlue : .lightGray
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        // CrewSignUpView 내부의 scrollView를 찾음
        if let scrollView = crewSignUpView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.contentInset.bottom = keyboardHeight + 20
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        if let scrollView = crewSignUpView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    @objc private func didTapDuplicateCheckButton() {
        let enteredID = crewSignUpView.employeeNumberTextField.text ?? ""

        if enteredID.isEmpty {
            showAlert(title: "입력 오류", message: "사번을 입력해주세요.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .whereField("employeeId", isEqualTo: enteredID)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.showAlert(title: "오류", message: "데이터를 불러오는 중 오류 발생: \(error.localizedDescription)")
                    return
                }

                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.isEmployeeAvailable = false
                    self.showAlert(title: "중복된 사번", message: "이미 사용 중인 사번입니다.")
                } else {
                    self.isEmployeeAvailable = true
                    self.showAlert(title: "사용 가능", message: "사용 가능한 사번입니다.")
                }
            }
    }

    @objc private func didTapSignUpButton() {
        let name = crewSignUpView.nameTextField.text ?? ""
        let phone = crewSignUpView.phoneTextField.text ?? ""
        let employeeId = crewSignUpView.employeeNumberTextField.text ?? ""
        let password = crewSignUpView.passwordTextField.text ?? ""

        guard !name.isEmpty, !phone.isEmpty, !employeeId.isEmpty, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "모든 필드를 입력해주세요.")
            return
        }

        guard isEmployeeAvailable else {
            showAlert(title: "중복 확인 필요", message: "사번 중복 확인을 먼저 해주세요.")
            return
        }

        crewSignUpmodel.registerUser(name: name, phone: phone, employeeId: employeeId, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.showAlert(title: "등록 완료", message: "회원가입이 완료되었습니다.") {
                        let tabBarController = MainTabBarController()
                        tabBarController.selectedIndex = 3
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = tabBarController
                            window.makeKeyAndVisible()
                        }
                    }
                case .failure(let error):
                    self.showAlert(title: "등록 오류", message: "회원가입 중 오류 발생: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}
