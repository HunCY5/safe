//
//  ManagerSignUpViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ManagerSignUpViewController: UIViewController, ManagerSignUpViewDelegate {
    func didTapVerifyButton(_ number: String) {
        verifyButtonTapped()
    }
    
    
    private let managerSignUpView = ManagerSignUpView()
    private let managerSignUpmodel = ManagerSignUpModel()
    private var isIDAvailable = false
    private var isBusinessNumberAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white
        
        // 기존 인스턴스를 사용하도록 수정
        managerSignUpView.translatesAutoresizingMaskIntoConstraints = false
        managerSignUpView.delegate = self
        
        managerSignUpView.passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        managerSignUpView.confirmPasswordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        view.addSubview(managerSignUpView)
        
        NSLayoutConstraint.activate([
            managerSignUpView.topAnchor.constraint(equalTo: view.topAnchor),
            managerSignUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            managerSignUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            managerSignUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        // 중복확인 및 사업자등록번호 확인 버튼 연결
        managerSignUpView.checkButton.addTarget(self, action: #selector(handleDuplicateCheck), for: .touchUpInside)
        managerSignUpView.verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        managerSignUpView.signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)

        // 입력 값 변경 감지
        [managerSignUpView.nameTextField,
         managerSignUpView.phoneTextField,
         managerSignUpView.businessNumberTextField,
         managerSignUpView.companyNameTextField,
         managerSignUpView.ManagerIDTextField,
         managerSignUpView.passwordTextField,
         managerSignUpView.confirmPasswordTextField
        ].forEach { tf in
            tf.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }
    @objc private func textFieldChanged() {
        let name = managerSignUpView.nameTextField.text ?? ""
        let phone = managerSignUpView.phoneTextField.text ?? ""
        let managerId = managerSignUpView.ManagerIDTextField.text ?? ""
        let password = managerSignUpView.passwordTextField.text ?? ""
        let confirm = managerSignUpView.confirmPasswordTextField.text ?? ""
        
        if !confirm.isEmpty {
            if password == confirm {
                managerSignUpView.passwordMatchLabel.text = "비밀번호가 일치합니다."
                managerSignUpView.passwordMatchLabel.textColor = .systemGreen
            } else {
                managerSignUpView.passwordMatchLabel.text = "비밀번호가 일치하지 않습니다."
                managerSignUpView.passwordMatchLabel.textColor = .red
            }
        } else {
            managerSignUpView.passwordMatchLabel.text = ""
        }
        
        let isFormValid = !name.isEmpty &&
        !managerId.isEmpty &&
        phone.count >= 10 &&
        phone.count <= 11 &&
        phone.allSatisfy { $0.isNumber } &&
        password.count >= 6 &&
        password == confirm
        managerSignUpView.signUpButton.isEnabled = isFormValid
        managerSignUpView.signUpButton.backgroundColor = isFormValid ? .systemOrange : .lightGray
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        // CrewSignUpView 내부의 scrollView를 찾음
        if let scrollView = managerSignUpView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.contentInset.bottom = keyboardHeight + 20
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let scrollView = managerSignUpView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    // CrewSignUpViewController의 중복확인 기능과 동일한 동작을 위한 메서드
    @objc private func handleDuplicateCheck() {
        checkDuplicateEmployeeId()
    }
    
    // Firestore에서 managerId와 employeeId 중복 확인
    private func checkDuplicateEmployeeId() {
        guard let managerId = managerSignUpView.ManagerIDTextField.text, !managerId.isEmpty else {
            showSimpleAlert(message: "관리자ID를 입력해주세요.")
            return
        }
        let db = Firestore.firestore()
        let group = DispatchGroup()
        var isManagerIdDuplicate = false
        var isEmployeeIdDuplicate = false

        group.enter()
        db.collection("users").whereField("managerId", isEqualTo: managerId).getDocuments { snapshot, error in
            defer { group.leave() }
            if let error = error {
                print("중복 확인 오류(managerId): \(error)")
                return
            }
            if let documents = snapshot?.documents, !documents.isEmpty {
                isManagerIdDuplicate = true
            }
        }

        group.enter()
        db.collection("users").whereField("employeeId", isEqualTo: managerId).getDocuments { snapshot, error in
            defer { group.leave() }
            if let error = error {
                print("중복 확인 오류(employeeId): \(error)")
                return
            }
            if let documents = snapshot?.documents, !documents.isEmpty {
                isEmployeeIdDuplicate = true
            }
        }

        group.notify(queue: .main) {
            if isManagerIdDuplicate || isEmployeeIdDuplicate {
                self.isIDAvailable = false
                self.showSimpleAlert(message: "이미 사용 중인 ID입니다.")
            } else {
                self.isIDAvailable = true
                self.showSimpleAlert(message: "사용 가능한 관리자ID입니다.")
            }
        }
    }
    
    // 간단 알림창 헬퍼 (타이틀 없이)
    private func showSimpleAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func didTapSignUpButton() {
        let name = managerSignUpView.nameTextField.text ?? ""
        let phone = managerSignUpView.phoneTextField.text ?? ""
        let managerId = managerSignUpView.ManagerIDTextField.text ?? ""
        let password = managerSignUpView.passwordTextField.text ?? ""
        let companyName = managerSignUpView.companyNameTextField.text ?? ""
        let businessNumber = managerSignUpView.businessNumberTextField.text ?? ""
        
        guard !name.isEmpty, !phone.isEmpty, !managerId.isEmpty, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "모든 필드를 입력해주세요.")
            return
        }
        
        guard isIDAvailable else {
            showAlert(title: "중복 확인 필요", message: "관리자ID 중복 확인을 먼저 해주세요.")
            return
        }
        
        guard isBusinessNumberAvailable else {
            showAlert(title: "사업자등록번호 확인 필요", message: "사업자등록번호 검증을 먼저 해주세요.")
            return
        }
        
        managerSignUpmodel.registerUser(name: name, phone: phone, companyName: companyName, businessNumber: businessNumber, managerId: managerId, password: password) { result in
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
    
    
    // 사업자등록번호 검증
    @objc private func verifyButtonTapped() {
        // 사업자등록번호 입력값 가져오기 및 숫자만 추출
        guard let rawBusinessNumber = managerSignUpView.businessNumberTextField.text else {
            managerSignUpView.businessNumberStatusLabel.text = "사업자등록번호를 입력해주세요."
            managerSignUpView.businessNumberStatusLabel.textColor = .systemRed
            self.isBusinessNumberAvailable = false
            return
        }
        let businessNumber = rawBusinessNumber.filter { $0.isNumber }
        guard !businessNumber.isEmpty else {
            managerSignUpView.businessNumberStatusLabel.text = "사업자등록번호를 입력해주세요."
            managerSignUpView.businessNumberStatusLabel.textColor = .systemRed
            self.isBusinessNumberAvailable = false
            return
        }
        guard businessNumber.count == 10 else {
            managerSignUpView.businessNumberStatusLabel.text = "사업자등록번호는 숫자 10자리여야 합니다."
            managerSignUpView.businessNumberStatusLabel.textColor = .systemRed
            self.isBusinessNumberAvailable = false
            return
        }
        let db = Firestore.firestore()
        // Firestore에서 동일한 사업자등록번호가 있는지 확인
        db.collection("users").whereField("businessNumber", isEqualTo: businessNumber).getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.managerSignUpView.businessNumberStatusLabel.text = "오류: \(error.localizedDescription)"
                    self.managerSignUpView.businessNumberStatusLabel.textColor = .systemRed
                    self.isBusinessNumberAvailable = false
                }
                return
            }
            if let documents = snapshot?.documents, !documents.isEmpty {
                DispatchQueue.main.async {
                    self.managerSignUpView.businessNumberStatusLabel.text = "이미 등록된 사업자등록번호입니다."
                    self.managerSignUpView.businessNumberStatusLabel.textColor = .systemRed
                    self.isBusinessNumberAvailable = false
                }
            } else {
                // API 검증 호출
                self.checkBusinessNumberValidation(businessNumber) { valid, status in
                    DispatchQueue.main.async {
                        self.managerSignUpView.businessNumberStatusLabel.text = status
                        self.managerSignUpView.businessNumberStatusLabel.textColor = valid ? .systemGreen : .systemRed
                        self.isBusinessNumberAvailable = valid
                        if valid {
                            self.managerSignUpView.businessNumberTextField.isEnabled = false
                            self.managerSignUpView.verifyButton.isEnabled = false
                            self.managerSignUpView.verifyButton.setTitleColor(.systemGray, for: .disabled)
                            self.managerSignUpView.verifyButton.layer.borderColor = UIColor.systemGray.cgColor
                        }
                    }
                }
            }
        }
    }
    
    // 사업자등록번호 API 호출
    func checkBusinessNumberValidation(_ number: String,
                                       completion: @escaping (Bool, String) -> Void
    ) {
        let apiKey = "fbK2g297uMEM8V6tRh8OrEcJYGYvS2aK%2FhLSkVSySexCD0yEVarZgDG7Li6ZbrOy1Wa%2B%2BIrb%2BdZHjwnpnSDHBA%3D%3D"
        let urlStr = "https://api.odcloud.kr/api/nts-businessman/v1/status?serviceKey=\(apiKey)"
        guard let url = URL(string: urlStr) else {
            return completion(false, "URL 생성 실패")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["b_no": [number]]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error = error {
                return completion(false, "네트워크 오류: \(error.localizedDescription)")
            }
            guard let d = data,
                  let obj = try? JSONSerialization.jsonObject(with: d) as? [String:Any],
                  let arr = obj["data"] as? [[String:Any]],
                  let first = arr.first,
                  let codeValue = first["b_stt_cd"] else {
                return completion(false, "파싱 실패")
            }
            let code: String
            if let s = codeValue as? String {
                code = s
            } else if let i = codeValue as? Int {
                code = String(i)
            } else {
                return completion(false, "파싱 실패")
            }
            if code == "01" {
                completion(true, "사용 가능한 사업자등록번호입니다.")
            } else {
                completion(false, "현재 운영 중인 사업자등록번호를 입력해주세요.")
            }
        }.resume()
    }
}
