//
//  ProfileView.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

protocol ProfileViewDelegate: AnyObject {
    func didTapLoginButton()
    func didTapWorkerSignupButton()
    func didTapManagerSignupButton()
}

class ProfileView: UIView {
    weak var delegate: ProfileViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("✅ ProfileView 초기화됨")

        self.backgroundColor = .systemGroupedBackground

        // 1. 로그인 필요 카드
        let loginCard = UIView()
        loginCard.translatesAutoresizingMaskIntoConstraints = false
        loginCard.backgroundColor = .white
        loginCard.layer.cornerRadius = 16

        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 40
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "person.fill"))
        icon.tintColor = .systemOrange
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(icon)

        let loginTitle = UILabel()
        loginTitle.text = "로그인이 필요합니다"
        loginTitle.font = UIFont.boldSystemFont(ofSize: 20)
        loginTitle.textAlignment = .center
        loginTitle.translatesAutoresizingMaskIntoConstraints = false

        let loginDescription = UILabel()
        loginDescription.text = "세잎 앱을 이용하려면\n로그인해주세요"
        loginDescription.numberOfLines = 2
        loginDescription.textColor = .secondaryLabel
        loginDescription.textAlignment = .center
        loginDescription.font = .systemFont(ofSize: 14)
        loginDescription.translatesAutoresizingMaskIntoConstraints = false

        let loginButton = UIButton(type: .system)
        loginButton.setTitle("로그인", for: .normal)
        loginButton.backgroundColor = .systemOrange
        loginButton.tintColor = .white
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.layer.cornerRadius = 12
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        addTouchAnimation(to: loginButton)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        loginCard.addSubview(iconContainer)
        loginCard.addSubview(icon)
        loginCard.addSubview(loginTitle)
        loginCard.addSubview(loginDescription)
        loginCard.addSubview(loginButton)
        self.addSubview(loginCard)

        // 앱 소개 카드 introCard 추가
        let introCard = UIView()
        introCard.translatesAutoresizingMaskIntoConstraints = false
        introCard.backgroundColor = .white
        introCard.layer.cornerRadius = 16
        self.addSubview(introCard)

        let introTitle = UILabel()
        introTitle.text = "세잎이란?"
        introTitle.font = UIFont.boldSystemFont(ofSize: 17)
        introTitle.translatesAutoresizingMaskIntoConstraints = false
        introCard.addSubview(introTitle)

        let items = [
            ("실시간 안전 감시", "AI 기반 위험 상황 자동 감지", UIColor.systemGreen),
            ("스마트 근로자 관리", "근무시간 관리 및 공지 기능", UIColor.systemBlue),
            ("통합 관리 시스템", "위험 요인을 한눈에 관리", UIColor.systemOrange)
        ]

        var lastItemBottom: NSLayoutYAxisAnchor = introTitle.bottomAnchor

        for (title, subtitle, color) in items {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = color.withAlphaComponent(0.2)
            dot.layer.cornerRadius = 10

            let innerDot = UIView()
            innerDot.translatesAutoresizingMaskIntoConstraints = false
            innerDot.backgroundColor = color
            innerDot.layer.cornerRadius = 5
            dot.addSubview(innerDot)

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = UIFont.systemFont(ofSize: 13)
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

            let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stack.axis = .vertical
            stack.spacing = 2
            stack.translatesAutoresizingMaskIntoConstraints = false

            let row = UIStackView(arrangedSubviews: [dot, stack])
            row.axis = .horizontal
            row.spacing = 12
            row.alignment = .top
            row.translatesAutoresizingMaskIntoConstraints = false

            introCard.addSubview(row)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 20),
                dot.heightAnchor.constraint(equalToConstant: 20),
                innerDot.widthAnchor.constraint(equalToConstant: 10),
                innerDot.heightAnchor.constraint(equalToConstant: 10),
                innerDot.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                innerDot.centerYAnchor.constraint(equalTo: dot.centerYAnchor),

                row.leadingAnchor.constraint(equalTo: introCard.leadingAnchor, constant: 20),
                row.trailingAnchor.constraint(equalTo: introCard.trailingAnchor, constant: -20),
                row.topAnchor.constraint(equalTo: lastItemBottom, constant: 16)
            ])

            lastItemBottom = row.bottomAnchor
        }

        // 하단 구분선 및 가입 버튼
        let dividerLine = UIView()
        dividerLine.backgroundColor = UIColor.systemGray5
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        loginCard.addSubview(dividerLine)

        let dividerLabel = UILabel()
        dividerLabel.text = "처음 이용하시나요?"
        dividerLabel.font = UIFont.systemFont(ofSize: 13)
        dividerLabel.textColor = .secondaryLabel
        dividerLabel.textAlignment = .center
        dividerLabel.translatesAutoresizingMaskIntoConstraints = false

        let workerSignupButton = UIButton(type: .system)
        workerSignupButton.setTitle("근로자 가입", for: .normal)
        workerSignupButton.setTitleColor(.systemBlue, for: .normal)
        workerSignupButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        workerSignupButton.translatesAutoresizingMaskIntoConstraints = false
        addTouchAnimation(to: workerSignupButton)
        workerSignupButton.addTarget(self, action: #selector(workerSignupButtonTapped), for: .touchUpInside)

        let managerSignupButton = UIButton(type: .system)
        managerSignupButton.setTitle("관리자 가입", for: .normal)
        managerSignupButton.setTitleColor(.systemRed, for: .normal)
        managerSignupButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        managerSignupButton.translatesAutoresizingMaskIntoConstraints = false
        addTouchAnimation(to: managerSignupButton)
        managerSignupButton.addTarget(self, action: #selector(managerSignupButtonTapped), for: .touchUpInside)

        loginCard.addSubview(dividerLabel)
        loginCard.addSubview(workerSignupButton)
        loginCard.addSubview(managerSignupButton)

        // 오토레이아웃
        NSLayoutConstraint.activate([
            loginCard.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            loginCard.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            loginCard.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            iconContainer.centerXAnchor.constraint(equalTo: loginCard.centerXAnchor),
            iconContainer.topAnchor.constraint(equalTo: loginCard.topAnchor, constant: 20),
            iconContainer.widthAnchor.constraint(equalToConstant: 80),
            iconContainer.heightAnchor.constraint(equalToConstant: 80),

            icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40),

            loginTitle.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 16),
            loginTitle.centerXAnchor.constraint(equalTo: loginCard.centerXAnchor),

            loginDescription.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 8),
            loginDescription.centerXAnchor.constraint(equalTo: loginCard.centerXAnchor),

            loginButton.topAnchor.constraint(equalTo: loginDescription.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: loginCard.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: loginCard.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.bottomAnchor.constraint(equalTo: dividerLine.topAnchor, constant: -24),

            dividerLine.leadingAnchor.constraint(equalTo: loginCard.leadingAnchor, constant: 20),
            dividerLine.trailingAnchor.constraint(equalTo: loginCard.trailingAnchor, constant: -20),
            dividerLine.heightAnchor.constraint(equalToConstant: 1),

            dividerLabel.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: 12),
            dividerLabel.centerXAnchor.constraint(equalTo: loginCard.centerXAnchor),

            workerSignupButton.topAnchor.constraint(equalTo: dividerLabel.bottomAnchor, constant: 8),
            workerSignupButton.trailingAnchor.constraint(equalTo: loginCard.centerXAnchor, constant: -40),

            managerSignupButton.topAnchor.constraint(equalTo: dividerLabel.bottomAnchor, constant: 8),
            managerSignupButton.leadingAnchor.constraint(equalTo: loginCard.centerXAnchor, constant: 40),
            managerSignupButton.bottomAnchor.constraint(equalTo: loginCard.bottomAnchor, constant: -24),

            // introCard
            introCard.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            introCard.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            introCard.topAnchor.constraint(equalTo: loginCard.bottomAnchor, constant: 20),
            introTitle.topAnchor.constraint(equalTo: introCard.topAnchor, constant: 20),
            introTitle.leadingAnchor.constraint(equalTo: introCard.leadingAnchor, constant: 20),
            introTitle.trailingAnchor.constraint(equalTo: introCard.trailingAnchor, constant: -20),
            lastItemBottom.constraint(equalTo: introCard.bottomAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Touch Animation for Buttons
    private func addTouchAnimation(to button: UIButton) {
        button.addTarget(self, action: #selector(scaleDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(scaleUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }

    @objc private func scaleDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    @objc private func scaleUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }

    @objc private func loginButtonTapped() {
        delegate?.didTapLoginButton()
    }
    
    @objc private func workerSignupButtonTapped() {
        delegate?.didTapWorkerSignupButton()
    }

    @objc private func managerSignupButtonTapped() {
        delegate?.didTapManagerSignupButton()
    }
}
