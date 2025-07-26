//
//  ManagerLoginView.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

class ManagerLoginView: UIView {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        imageView.image = UIImage(systemName: "person.fill.checkmark", withConfiguration: config)
        imageView.tintColor = .systemOrange
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let appNameLabel: UILabel = { // 이곳에 앱 아이콘
        let label = UILabel()
        label.text = "관리자 로그인"
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "현장 관리자를 위한 통합 관리 시스템"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
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
        view.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 230/255, alpha: 1) // 연한 오렌지 배경
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "관리자 로그인 안내"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .systemOrange
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let guideText = [
            "사업자 등록번호는 회원가입 시에만 필요합니다",
            "관리자 계정으로 전체 현장을 관리할 수 있습니다",
            "기술 지원: support@safeapp.com"
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for text in guideText {
            let label = UILabel()
            label.text = "• \(text)"
            label.font = .systemFont(ofSize: 14)
            label.textColor = .systemOrange
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
    
    private let idTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "관리자 ID를 입력하세요"
        textField.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1)
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.textColor = .darkGray
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
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요"
        textField.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1)
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.textColor = .darkGray
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
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" 로그인", for: .normal)
        button.setImage(UIImage(systemName: "shield"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("비밀번호를 잊으셨나요?", for: .normal)
        button.setTitleColor(.systemOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1)
        self.setupViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1)
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
        idLabel.text = "관리자 ID"
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
        self.loginCardView.addSubview(self.idTextField)
        self.loginCardView.addSubview(self.passwordTextField)
        self.loginCardView.addSubview(self.loginButton)
        self.loginCardView.addSubview(self.forgotPasswordButton)
        
        self.addSubview(self.guideCardView)
        
        NSLayoutConstraint.activate([
            idLabel.topAnchor.constraint(equalTo: self.loginCardView.topAnchor, constant: 20),
            idLabel.leadingAnchor.constraint(equalTo: self.loginCardView.leadingAnchor, constant: 16),
            self.idTextField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8),
            
            pwLabel.topAnchor.constraint(equalTo: self.idTextField.bottomAnchor, constant: 16),
            pwLabel.leadingAnchor.constraint(equalTo: self.loginCardView.leadingAnchor, constant: 16),
            self.passwordTextField.topAnchor.constraint(equalTo: pwLabel.bottomAnchor, constant: 8),
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            self.logoImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 40),
            self.logoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 60),
            self.logoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            self.appNameLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 8),
            self.appNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.subtitleLabel.topAnchor.constraint(equalTo: self.appNameLabel.bottomAnchor, constant: 4),
            self.subtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.loginCardView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 30),
            self.loginCardView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            self.loginCardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            
            self.idTextField.leadingAnchor.constraint(equalTo: self.loginCardView.leadingAnchor, constant: 16),
            self.idTextField.trailingAnchor.constraint(equalTo: self.loginCardView.trailingAnchor, constant: -16),
            self.idTextField.heightAnchor.constraint(equalToConstant: 56),
            
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
}
