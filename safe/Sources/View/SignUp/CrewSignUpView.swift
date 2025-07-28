//
//  CrewSignUpView.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

// MARK: - Protocol
protocol CrewSignUpViewDelegate: AnyObject {
    func didTapLoginButton()
}


class CrewSignUpView: UIView, UIGestureRecognizerDelegate {
    // MARK: - Duplicate Check Button
    let duplicateCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("중복확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Delegate
    weak var delegate: CrewSignUpViewDelegate?

    // MARK: - Scroll View & Content View
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let employeeNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "사번"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "회사명"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let companyNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "회사명을 입력하세요"
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

        let imageView = UIImageView(image: UIImage(systemName: "building.2"))
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

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "연락처"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
    imageView.image = UIImage(systemName: "shield", withConfiguration: config)
    imageView.tintColor = .systemBlue
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
}()

private let appNameLabel: UILabel = {
    let label = UILabel()
    label.text = "근로자 회원가입"
    label.font = .systemFont(ofSize: 24, weight: .heavy)
    label.textColor = .black
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "현장 작업자를 위한 안전 관리 시스템"
    label.font = .systemFont(ofSize: 16)
    label.textColor = .darkGray
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

private let signUpCardView: UIView = {
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

 let nameTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "이름을 입력하세요"
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

let employeeNumberTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "사번을 입력하세요"
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

    let imageView = UIImageView(image: UIImage(systemName: "number"))
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

 let phoneTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "연락처를 입력하세요(- 제외)"
    textField.keyboardType = .phonePad
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

    let imageView = UIImageView(image: UIImage(systemName: "phone"))
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

 let confirmPasswordTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "비밀번호를 다시 입력하세요"
    textField.isSecureTextEntry = true
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

    let imageView = UIImageView(image: UIImage(systemName: "lock"))
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

 let passwordMatchLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 13)
    label.textColor = .red
    label.numberOfLines = 1
    label.textAlignment = .left
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

 let passwordTextField: UITextField = {
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

 let signUpButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(" 회원가입", for: .normal)
    button.setImage(UIImage(systemName: "shield"), for: .normal)
    button.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = .boldSystemFont(ofSize: 17)
    button.layer.cornerRadius = 16
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
}()

 let loginButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("이미 계정이 있으신가요? 로그인", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
}()

// MARK: - Initializers

override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor(red: 240/255, green: 250/255, blue: 255/255, alpha: 1)
    self.setupViews()
    self.setupConstraints()
}

required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.backgroundColor = UIColor(red: 240/255, green: 250/255, blue: 255/255, alpha: 1)
    self.setupViews()
    self.setupConstraints()
}

// MARK: - Setup

private func setupViews() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(scrollView)
    scrollView.addSubview(contentView)

    scrollView.delaysContentTouches = false
    scrollView.canCancelContentTouches = true

    contentView.addSubview(self.logoImageView)
    contentView.addSubview(self.appNameLabel)
    contentView.addSubview(self.subtitleLabel)
    contentView.addSubview(self.signUpCardView)

    self.signUpCardView.addSubview(self.nameLabel)
    self.signUpCardView.addSubview(self.nameTextField)
    self.signUpCardView.addSubview(self.employeeNumberLabel)
    self.signUpCardView.addSubview(self.employeeNumberTextField)
    self.signUpCardView.addSubview(self.duplicateCheckButton)
    self.signUpCardView.addSubview(self.companyNameLabel)
    self.signUpCardView.addSubview(self.companyNameTextField)
    self.signUpCardView.addSubview(self.phoneLabel)
    self.signUpCardView.addSubview(self.phoneTextField)
    self.signUpCardView.addSubview(self.passwordLabel)
    self.signUpCardView.addSubview(self.passwordTextField)
    self.signUpCardView.addSubview(self.confirmPasswordLabel)
    self.signUpCardView.addSubview(self.confirmPasswordTextField)
    self.signUpCardView.addSubview(self.passwordMatchLabel)
    self.signUpCardView.addSubview(self.signUpButton)
    self.signUpCardView.addSubview(self.loginButton)

    self.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
}

private func setupConstraints() {
    NSLayoutConstraint.activate([
        scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    ])

    NSLayoutConstraint.activate([
        self.logoImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
        self.logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        self.logoImageView.widthAnchor.constraint(equalToConstant: 60),
        self.logoImageView.heightAnchor.constraint(equalToConstant: 50),

        self.appNameLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 8),
        self.appNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

        self.subtitleLabel.topAnchor.constraint(equalTo: self.appNameLabel.bottomAnchor, constant: 4),
        self.subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

        self.signUpCardView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 30),
        self.signUpCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
        self.signUpCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
    ])

    NSLayoutConstraint.activate([
        // 이름 라벨 및 텍스트필드
        self.nameLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.nameLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.nameLabel.topAnchor.constraint(equalTo: self.signUpCardView.topAnchor, constant: 20),

        self.nameTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.nameTextField.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.nameTextField.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 4),
        self.nameTextField.heightAnchor.constraint(equalToConstant: 56),

        // 사번 라벨, 텍스트필드, 중복확인 버튼
        self.employeeNumberLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.employeeNumberLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.employeeNumberLabel.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 16),

        self.employeeNumberTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.employeeNumberTextField.trailingAnchor.constraint(equalTo: self.duplicateCheckButton.leadingAnchor, constant: -8),
        self.employeeNumberTextField.topAnchor.constraint(equalTo: self.employeeNumberLabel.bottomAnchor, constant: 4),
        self.employeeNumberTextField.heightAnchor.constraint(equalToConstant: 56),

        self.duplicateCheckButton.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.duplicateCheckButton.centerYAnchor.constraint(equalTo: self.employeeNumberTextField.centerYAnchor),
        self.duplicateCheckButton.widthAnchor.constraint(equalToConstant: 80),
        self.duplicateCheckButton.heightAnchor.constraint(equalToConstant: 40),

        // 회사명 라벨 및 텍스트필드
        self.companyNameLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.companyNameLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.companyNameLabel.topAnchor.constraint(equalTo: self.employeeNumberTextField.bottomAnchor, constant: 16),

        self.companyNameTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.companyNameTextField.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.companyNameTextField.topAnchor.constraint(equalTo: self.companyNameLabel.bottomAnchor, constant: 4),
        self.companyNameTextField.heightAnchor.constraint(equalToConstant: 56),

        // 연락처 라벨 및 텍스트필드
        self.phoneLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.phoneLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.phoneLabel.topAnchor.constraint(equalTo: self.companyNameTextField.bottomAnchor, constant: 16),

        self.phoneTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.phoneTextField.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.phoneTextField.topAnchor.constraint(equalTo: self.phoneLabel.bottomAnchor, constant: 4),
        self.phoneTextField.heightAnchor.constraint(equalToConstant: 56),

        // 비밀번호 라벨 및 텍스트필드
        self.passwordLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.passwordLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.passwordLabel.topAnchor.constraint(equalTo: self.phoneTextField.bottomAnchor, constant: 16),

        self.passwordTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.passwordTextField.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.passwordTextField.topAnchor.constraint(equalTo: self.passwordLabel.bottomAnchor, constant: 4),
        self.passwordTextField.heightAnchor.constraint(equalToConstant: 56),

        // 비밀번호 확인 라벨 및 텍스트필드
        self.confirmPasswordLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.confirmPasswordLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.confirmPasswordLabel.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 16),

        self.confirmPasswordTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.confirmPasswordTextField.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.confirmPasswordTextField.topAnchor.constraint(equalTo: self.confirmPasswordLabel.bottomAnchor, constant: 4),
        self.confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 56),

        // 패스워드 매치 라벨
        self.passwordMatchLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.passwordMatchLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.passwordMatchLabel.topAnchor.constraint(equalTo: self.confirmPasswordTextField.bottomAnchor, constant: 4),

        // 버튼들
        self.signUpButton.topAnchor.constraint(equalTo: self.passwordMatchLabel.bottomAnchor, constant: 16),
        self.signUpButton.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
        self.signUpButton.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
        self.signUpButton.heightAnchor.constraint(equalToConstant: 56),

        self.loginButton.topAnchor.constraint(equalTo: self.signUpButton.bottomAnchor, constant: 15),
        self.loginButton.centerXAnchor.constraint(equalTo: self.signUpCardView.centerXAnchor),

        self.loginButton.bottomAnchor.constraint(equalTo: self.signUpCardView.bottomAnchor, constant: -24),
        // 하단 여백 확보 (탭바 침범 방지)
        self.signUpCardView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -30)
    ])
}

// MARK: - UIGestureRecognizerDelegate
func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    let touchLocation = touch.location(in: self.signUpCardView)
    if self.signUpButton.frame.contains(touchLocation) ||
        self.loginButton.frame.contains(touchLocation) {
        return false
    }
    return true
}

// MARK: - Actions

@objc private func togglePasswordVisibility(_ sender: UIButton) {
    self.passwordTextField.isSecureTextEntry.toggle()
    let imageName = self.passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
    sender.setImage(UIImage(systemName: imageName), for: .normal)
}
    
    @objc private func loginButtonTapped() {
        delegate?.didTapLoginButton()
    }
    
}


