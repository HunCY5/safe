//
//  ManagerSignUpView.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//


import UIKit

// MARK: - Protocol
protocol ManagerSignUpViewDelegate: AnyObject {
    func didTapLoginButton()
    func didTapVerifyButton(_ number: String)
}

class ManagerSignUpView: UIView, UIGestureRecognizerDelegate {

// MARK: - Delegate
weak var delegate: ManagerSignUpViewDelegate?

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

private let businessNumberLabel: UILabel = {
    let label = UILabel()
    label.text = "사업자 등록번호"
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .darkGray
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

let businessNumberTextField: UITextField = {
let textField = UITextField()
textField.placeholder = "사업자등록번호 10자리 입력"
textField.keyboardType = .numberPad
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
return textField
}()
let verifyButton: UIButton = {
let button = UIButton(type: .system)
button.setTitle("검증", for: .normal)
button.setTitleColor(UIColor(red: 255/255, green: 149/255, blue: 0, alpha: 1), for: .normal)
button.layer.borderWidth = 1
button.layer.borderColor = UIColor(red: 255/255, green: 149/255, blue: 0, alpha: 1).cgColor
button.layer.cornerRadius = 8
button.titleLabel?.font = .systemFont(ofSize: 14)
button.translatesAutoresizingMaskIntoConstraints = false
return button
}()

    // 사업자등록번호 상태 레이블
    let businessNumberStatusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
private let employeeNumberLabel: UILabel = {
    let label = UILabel()
    label.text = "관리자 ID"
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .darkGray
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
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
imageView.image = UIImage(systemName: "person.fill.checkmark", withConfiguration: config)
imageView.tintColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
imageView.translatesAutoresizingMaskIntoConstraints = false
return imageView
}()

private let appNameLabel: UILabel = { // 이곳에 앱 아이콘
let label = UILabel()
label.text = "관리자 회원가입"
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

let ManagerIDTextField: UITextField = {
let textField = UITextField()
textField.placeholder = "관리자ID를 입력하세요"
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

let checkButton: UIButton = {
let button = UIButton(type: .system)
button.setTitle("중복확인", for: .normal)
button.setTitleColor(UIColor(red: 255/255, green: 149/255, blue: 0, alpha: 1), for: .normal)
button.layer.borderWidth = 1
button.layer.borderColor = UIColor(red: 255/255, green: 149/255, blue: 0, alpha: 1).cgColor
button.layer.cornerRadius = 8
button.titleLabel?.font = .systemFont(ofSize: 14)
button.translatesAutoresizingMaskIntoConstraints = false
return button
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

let passwordMatchLabel: UILabel = {
   let label = UILabel()
   label.font = .systemFont(ofSize: 13)
   label.textColor = .red
   label.numberOfLines = 1
   label.textAlignment = .left
   label.translatesAutoresizingMaskIntoConstraints = false
   return label
}()

let signUpButton: UIButton = {
let button = UIButton(type: .system)
button.setTitle(" 회원가입", for: .normal)
button.setImage(UIImage(systemName: "shield"), for: .normal)
button.tintColor = .white
button.imageView?.contentMode = .scaleAspectFit
button.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
button.setTitleColor(.white, for: .normal)
button.titleLabel?.font = .boldSystemFont(ofSize: 17)
button.layer.cornerRadius = 16
button.translatesAutoresizingMaskIntoConstraints = false
return button
}()

let loginButton: UIButton = {
let button = UIButton(type: .system)
button.setTitle("이미 계정이 있으신가요? 로그인", for: .normal)
button.setTitleColor(UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1), for: .normal)
button.titleLabel?.font = .systemFont(ofSize: 14)
button.translatesAutoresizingMaskIntoConstraints = false
return button
}()

// MARK: - Initializers

override init(frame: CGRect) {
super.init(frame: frame)
self.backgroundColor = UIColor(red: 255/255, green: 240/255, blue: 220/255, alpha: 1)
self.setupViews()
self.setupConstraints()
self.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
//  self.checkButton.addTarget(self, action: #selector(checkDuplicateButtonTapped), for: .touchUpInside)
self.verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
}

required init?(coder: NSCoder) {
super.init(coder: coder)
self.backgroundColor = UIColor(red: 255/255, green: 240/255, blue: 220/255, alpha: 1)
self.setupViews()
self.setupConstraints()
self.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
//   self.checkButton.addTarget(self, action: #selector(checkDuplicateButtonTapped), for: .touchUpInside)
self.verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
}

// MARK: - Setup

private func setupViews() {
    // Set up scrollView and contentView first
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(scrollView)
    scrollView.addSubview(contentView)

    // Add touch delays/cancellation settings
    scrollView.delaysContentTouches = false
    scrollView.canCancelContentTouches = true

    contentView.addSubview(self.logoImageView)
    contentView.addSubview(self.appNameLabel)
    contentView.addSubview(self.subtitleLabel)
    contentView.addSubview(self.signUpCardView)

    // Add labels and text fields in order
    self.signUpCardView.addSubview(self.nameLabel)
    self.signUpCardView.addSubview(self.nameTextField)
    self.signUpCardView.addSubview(self.companyNameLabel)
    self.signUpCardView.addSubview(self.companyNameTextField)
    self.signUpCardView.addSubview(self.businessNumberLabel)
    self.signUpCardView.addSubview(self.businessNumberTextField)
    self.signUpCardView.addSubview(self.verifyButton)
    // Add businessNumberStatusLabel below businessNumberTextField
    self.signUpCardView.addSubview(self.businessNumberStatusLabel)
    self.signUpCardView.addSubview(self.employeeNumberLabel)
    self.signUpCardView.addSubview(self.ManagerIDTextField)
    self.signUpCardView.addSubview(self.checkButton)
    self.signUpCardView.addSubview(self.phoneLabel)
    self.signUpCardView.addSubview(self.phoneTextField)
    self.signUpCardView.addSubview(self.passwordLabel)
    self.signUpCardView.addSubview(self.passwordTextField)
    self.signUpCardView.addSubview(self.confirmPasswordLabel)
    self.signUpCardView.addSubview(self.confirmPasswordTextField)
    self.signUpCardView.addSubview(self.passwordMatchLabel)
    self.signUpCardView.addSubview(self.signUpButton)
    self.signUpCardView.addSubview(self.loginButton)
}

private func setupConstraints() {
NSLayoutConstraint.activate([
    // scrollView fills the safe area
    scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
    scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
    scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

    // contentView fills scrollView and matches width
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

    // 회사명 라벨 및 텍스트필드
    self.companyNameLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
    self.companyNameLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
    self.companyNameLabel.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 16),

    self.companyNameTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
    self.companyNameTextField.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
    self.companyNameTextField.topAnchor.constraint(equalTo: self.companyNameLabel.bottomAnchor, constant: 4),
    self.companyNameTextField.heightAnchor.constraint(equalToConstant: 56),

    // 사업자 등록번호 라벨, 텍스트필드, 검증 버튼
    self.businessNumberLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
    self.businessNumberLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
    self.businessNumberLabel.topAnchor.constraint(equalTo: self.companyNameTextField.bottomAnchor, constant: 16),

    self.businessNumberTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
    self.businessNumberTextField.trailingAnchor.constraint(equalTo: self.verifyButton.leadingAnchor, constant: -8),
    self.businessNumberTextField.topAnchor.constraint(equalTo: self.businessNumberLabel.bottomAnchor, constant: 4),
    self.businessNumberTextField.heightAnchor.constraint(equalToConstant: 40),

    self.verifyButton.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
    self.verifyButton.centerYAnchor.constraint(equalTo: self.businessNumberTextField.centerYAnchor),
    self.verifyButton.widthAnchor.constraint(equalToConstant: 60),
    self.verifyButton.heightAnchor.constraint(equalToConstant: 40),

    // 사업자 등록번호 상태 라벨
    self.businessNumberStatusLabel.topAnchor.constraint(equalTo: self.businessNumberTextField.bottomAnchor, constant: 4),
    self.businessNumberStatusLabel.leadingAnchor.constraint(equalTo: self.businessNumberTextField.leadingAnchor),
    self.businessNumberStatusLabel.trailingAnchor.constraint(equalTo: self.businessNumberTextField.trailingAnchor),

    // 관리자ID 라벨, 텍스트필드, 중복확인 버튼
    self.employeeNumberLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
    self.employeeNumberLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
    self.employeeNumberLabel.topAnchor.constraint(equalTo: self.businessNumberStatusLabel.bottomAnchor, constant: 12),

    self.ManagerIDTextField.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
    self.ManagerIDTextField.trailingAnchor.constraint(equalTo: self.checkButton.leadingAnchor, constant: -8),
    self.ManagerIDTextField.topAnchor.constraint(equalTo: self.employeeNumberLabel.bottomAnchor, constant: 4),
    self.ManagerIDTextField.heightAnchor.constraint(equalToConstant: 40),

    self.checkButton.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
    self.checkButton.centerYAnchor.constraint(equalTo: self.ManagerIDTextField.centerYAnchor),
    self.checkButton.widthAnchor.constraint(equalToConstant: 80),
    self.checkButton.heightAnchor.constraint(equalToConstant: 40),

    // 연락처 라벨 및 텍스트필드
    self.phoneLabel.leadingAnchor.constraint(equalTo: self.signUpCardView.leadingAnchor, constant: 16),
    self.phoneLabel.trailingAnchor.constraint(equalTo: self.signUpCardView.trailingAnchor, constant: -16),
    self.phoneLabel.topAnchor.constraint(equalTo: self.ManagerIDTextField.bottomAnchor, constant: 16),

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
    self.signUpButton.topAnchor.constraint(equalTo: self.confirmPasswordTextField.bottomAnchor, constant: 24),
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

@objc private func verifyButtonTapped() {
    let number = businessNumberTextField.text ?? ""
    delegate?.didTapVerifyButton(number)
}
}
