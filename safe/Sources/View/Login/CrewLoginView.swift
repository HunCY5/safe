//
//  CrewLoginView.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

protocol CrewLoginViewDelegate: AnyObject {
    func didTapLoginButton(id: String, password: String)
}

class CrewLoginView: UIView {
    
    weak var delegate: CrewLoginViewDelegate?
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        imageView.image = UIImage(systemName: "shield", withConfiguration: config)
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let appNameLabel: UILabel = { // 이곳에 앱 아이콘
        let label = UILabel()
        label.text = "근로자 로그인"
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "현장 작업자를 위한 안전 관리 시스템"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let guideCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1) // 연한 파란 배경
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "근로자 로그인 안내"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor(red: 0/255, green: 60/255, blue: 170/255, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let guideText = [
            "사번은 관리자로부터 발급받은 번호를 입력하세요",
            "처음 로그인 시 회원가입이 필요합니다",
            "문의사항은 현장 관리자에게 연락하세요"
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for text in guideText {
            let label = UILabel()
            label.text = "• \(text)"
            label.font = .systemFont(ofSize: 14)
            label.textColor = UIColor(red: 0/255, green: 60/255, blue: 170/255, alpha: 1)
            stackView.addArrangedSubview(label)
        }

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])

        return view
    }()
    
     let employeeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "사번을 입력하세요"
        textField.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1)
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 1).cgColor
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 24))
        containerView.addSubview(imageView)
        imageView.center = containerView.center
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요"
        textField.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1)
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 1).cgColor
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "lock"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 24))
        containerView.addSubview(imageView)
        imageView.center = containerView.center
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        
        let toggleButton = UIButton(type: .system)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .systemGray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        toggleButton.addTarget(nil, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        textField.rightView = toggleButton
        textField.rightViewMode = .always
        
        return textField
    }()
    
     let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" 로그인", for: .normal)
        button.setImage(UIImage(systemName: "shield"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor(red: 0/255, green: 112/255, blue: 255/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("비밀번호를 잊으셨나요?", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 245/255, green: 250/255, blue: 255/255, alpha: 1)
        self.setupViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor(red: 245/255, green: 250/255, blue: 255/255, alpha: 1)
        self.setupViews()
        self.setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        self.addSubview(self.logoImageView)
        self.addSubview(self.appNameLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.loginCardView)
        
        let idLabel = UILabel()
        idLabel.text = "사번"
        idLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        idLabel.textColor = .label
        idLabel.translatesAutoresizingMaskIntoConstraints = false

        let pwLabel = UILabel()
        pwLabel.text = "비밀번호"
        pwLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        pwLabel.textColor = .label
        pwLabel.translatesAutoresizingMaskIntoConstraints = false

        self.loginCardView.addSubview(idLabel)
        self.loginCardView.addSubview(pwLabel)
        self.loginCardView.addSubview(self.employeeTextField)
        self.loginCardView.addSubview(self.passwordTextField)
        self.loginCardView.addSubview(self.loginButton)
        self.loginCardView.addSubview(self.forgotPasswordButton)
        
        // 로그인 버튼에 액션 연결
        self.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        self.addSubview(self.guideCardView)
        
        NSLayoutConstraint.activate([
            idLabel.topAnchor.constraint(equalTo: self.loginCardView.topAnchor, constant: 20),
            idLabel.leadingAnchor.constraint(equalTo: self.loginCardView.leadingAnchor, constant: 16),
            self.employeeTextField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8),
            
            pwLabel.topAnchor.constraint(equalTo: self.employeeTextField.bottomAnchor, constant: 16),
            pwLabel.leadingAnchor.constraint(equalTo: self.loginCardView.leadingAnchor, constant: 16),
            self.passwordTextField.topAnchor.constraint(equalTo: pwLabel.bottomAnchor, constant: 8),
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            self.logoImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 40),
            self.logoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 50),
            self.logoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            self.appNameLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 8),
            self.appNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.subtitleLabel.topAnchor.constraint(equalTo: self.appNameLabel.bottomAnchor, constant: 4),
            self.subtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.loginCardView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 30),
            self.loginCardView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            self.loginCardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            
            self.employeeTextField.leadingAnchor.constraint(equalTo: self.loginCardView.leadingAnchor, constant: 16),
            self.employeeTextField.trailingAnchor.constraint(equalTo: self.loginCardView.trailingAnchor, constant: -16),
            self.employeeTextField.heightAnchor.constraint(equalToConstant: 56),
            
            self.passwordTextField.leadingAnchor.constraint(equalTo: self.loginCardView.leadingAnchor, constant: 16),
            self.passwordTextField.trailingAnchor.constraint(equalTo: self.loginCardView.trailingAnchor, constant: -16),
            self.passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            
            self.loginButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 24),
            self.loginButton.leadingAnchor.constraint(equalTo: self.loginCardView.leadingAnchor, constant: 16),
            self.loginButton.trailingAnchor.constraint(equalTo: self.loginCardView.trailingAnchor, constant: -16),
            self.loginButton.heightAnchor.constraint(equalToConstant: 56),
            
            self.forgotPasswordButton.topAnchor.constraint(equalTo: self.loginButton.bottomAnchor, constant: 8),
            self.forgotPasswordButton.centerXAnchor.constraint(equalTo: self.loginCardView.centerXAnchor),
            
            self.forgotPasswordButton.bottomAnchor.constraint(equalTo: self.loginCardView.bottomAnchor, constant: -24),
        ])
        
        NSLayoutConstraint.activate([
            self.guideCardView.topAnchor.constraint(equalTo: self.loginCardView.bottomAnchor, constant: 24),
            self.guideCardView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            self.guideCardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        self.passwordTextField.isSecureTextEntry.toggle()
        let imageName = self.passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func loginButtonTapped() {
        guard let id = employeeTextField.text, !id.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("❌ 사번 또는 비밀번호가 비어있습니다.")
            return
        }
        delegate?.didTapLoginButton(id: id, password: password)
    }
}
