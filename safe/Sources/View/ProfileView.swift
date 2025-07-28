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
    func didTapLogoutButton()
}

class ProfileView: UIView {
    weak var delegate: ProfileViewDelegate?

    private let isLoggedIn: Bool
    private let userName: String
    private let userId: String
    private let isManager: Bool
    var contentStackView: UIStackView!

    // 출퇴근/휴식/타이머 UI 및 상태 변수
    private let clockInButton = UIButton(type: .system)
    private let clockOutButton = UIButton(type: .system)
    private let breakButton = UIButton(type: .system)
    private let timerLabel = UILabel()
    private var timer: Timer?
    private var seconds: Int = 0
    private var isPaused: Bool = false
    private let attendanceStackView = UIStackView()

    init(frame: CGRect, isLoggedIn: Bool, userName: String, userId: String, isManager: Bool) {
        self.isLoggedIn = isLoggedIn
        self.userName = userName
        self.userId = userId
        self.isManager = isManager
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundColor = .systemGroupedBackground

        // MARK: - ScrollView & StackView
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        self.contentStackView = stackView

        // MARK: - 로그인/유저 카드 추가
        if isLoggedIn {
            contentStackView.addArrangedSubview(makeUserCard())
            setupSettingSection(isManager: isManager)
        } else {
            contentStackView.addArrangedSubview(makeLoginCard())
        }

        if !isLoggedIn {
            let introCard = UIView()
            introCard.translatesAutoresizingMaskIntoConstraints = false
            introCard.backgroundColor = .white
            introCard.layer.cornerRadius = 16
            introCard.layer.shadowOpacity = 0.1
            introCard.layer.shadowOffset = CGSize(width: 0, height: 2)
            introCard.layer.shadowRadius = 4
            introCard.layer.masksToBounds = false

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

            NSLayoutConstraint.activate([
                introTitle.topAnchor.constraint(equalTo: introCard.topAnchor, constant: 20),
                introTitle.leadingAnchor.constraint(equalTo: introCard.leadingAnchor, constant: 20),
                introTitle.trailingAnchor.constraint(equalTo: introCard.trailingAnchor, constant: -20),
                lastItemBottom.constraint(equalTo: introCard.bottomAnchor, constant: -20)
            ])
            contentStackView.addArrangedSubview(introCard)
        }

        // MARK: - Support Card (고객지원)
        let supportCard = UIView()
        supportCard.translatesAutoresizingMaskIntoConstraints = false
        supportCard.backgroundColor = .white
        supportCard.layer.cornerRadius = 16
        supportCard.layer.shadowColor = UIColor.black.cgColor
        supportCard.layer.shadowOpacity = 0.1
        supportCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        supportCard.layer.shadowRadius = 4
        supportCard.layer.masksToBounds = false

        // 수직 스택 뷰 (supportStack)
        let supportStack = UIStackView()
        supportStack.axis = .vertical
        supportStack.spacing = 8
        supportStack.translatesAutoresizingMaskIntoConstraints = false
        supportCard.addSubview(supportStack)

        // 제목
        let supportTitle = UILabel()
        supportTitle.text = "고객지원"
        supportTitle.font = UIFont.boldSystemFont(ofSize: 17)
        supportTitle.translatesAutoresizingMaskIntoConstraints = false
        supportStack.addArrangedSubview(supportTitle)

        let supportSubtitle = UILabel()
        supportSubtitle.text = "서비스 이용에 도움이 필요하신가요?"
        supportSubtitle.font = UIFont.systemFont(ofSize: 13)
        supportSubtitle.textColor = .secondaryLabel
        supportSubtitle.translatesAutoresizingMaskIntoConstraints = false
        supportStack.addArrangedSubview(supportSubtitle)

        func makeSupportRow(iconName: String, title: String) -> UIStackView {
            let iconView = UIImageView(image: UIImage(systemName: iconName))
            iconView.tintColor = .label
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.setContentHuggingPriority(.required, for: .horizontal)
            iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
            iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 24).isActive = true

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            titleLabel.textColor = .label
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
            arrow.tintColor = .systemGray3
            arrow.contentMode = .scaleAspectFit
            arrow.translatesAutoresizingMaskIntoConstraints = false
            arrow.setContentHuggingPriority(.required, for: .horizontal)
            arrow.setContentCompressionResistancePriority(.required, for: .horizontal)
            arrow.widthAnchor.constraint(equalToConstant: 16).isActive = true
            arrow.heightAnchor.constraint(equalToConstant: 16).isActive = true

            let rowStack = UIStackView(arrangedSubviews: [iconView, titleLabel, arrow])
            rowStack.axis = .horizontal
            rowStack.alignment = .center
            rowStack.spacing = 10
            rowStack.isLayoutMarginsRelativeArrangement = true
            rowStack.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            rowStack.backgroundColor = .clear
            rowStack.isUserInteractionEnabled = true
            return rowStack
        }

        // 약관 버튼 Row
        let termsRow = makeSupportRow(iconName: "doc.text", title: "이용약관")
        let termsButton = UIButton(type: .system)
        termsButton.backgroundColor = .clear
        termsButton.isUserInteractionEnabled = true
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.accessibilityLabel = "이용약관"
        addTouchAnimation(to: termsButton)
        termsRow.addSubview(termsButton)
        NSLayoutConstraint.activate([
            termsButton.leadingAnchor.constraint(equalTo: termsRow.leadingAnchor),
            termsButton.trailingAnchor.constraint(equalTo: termsRow.trailingAnchor),
            termsButton.topAnchor.constraint(equalTo: termsRow.topAnchor),
            termsButton.bottomAnchor.constraint(equalTo: termsRow.bottomAnchor)
        ])
        supportStack.addArrangedSubview(termsRow)

        let privacyRow = makeSupportRow(iconName: "lock.shield", title: "개인정보 처리방침")
        let privacyButton = UIButton(type: .system)
        privacyButton.backgroundColor = .clear
        privacyButton.isUserInteractionEnabled = true
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.accessibilityLabel = "개인정보 처리방침"
        addTouchAnimation(to: privacyButton)
        privacyRow.addSubview(privacyButton)
        NSLayoutConstraint.activate([
            privacyButton.leadingAnchor.constraint(equalTo: privacyRow.leadingAnchor),
            privacyButton.trailingAnchor.constraint(equalTo: privacyRow.trailingAnchor),
            privacyButton.topAnchor.constraint(equalTo: privacyRow.topAnchor),
            privacyButton.bottomAnchor.constraint(equalTo: privacyRow.bottomAnchor)
        ])
        supportStack.addArrangedSubview(privacyRow)

        NSLayoutConstraint.activate([
            supportStack.topAnchor.constraint(equalTo: supportCard.topAnchor, constant: 20),
            supportStack.leadingAnchor.constraint(equalTo: supportCard.leadingAnchor, constant: 20),
            supportStack.trailingAnchor.constraint(equalTo: supportCard.trailingAnchor, constant: -20),
            supportStack.bottomAnchor.constraint(equalTo: supportCard.bottomAnchor, constant: -20),
        ])

        contentStackView.addArrangedSubview(supportCard)

        // MARK: - 버전 정보 표시
        let versionLabel = UILabel()
        versionLabel.text = "버전 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")"
        versionLabel.font = .systemFont(ofSize: 12)
        versionLabel.textColor = .lightGray
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(versionLabel)

        // MARK: - ScrollView 및 StackView 제약
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    // MARK: - 로그인 필요 카드
    private func makeLoginCard() -> UIView {
        let loginCard = UIView()
        loginCard.translatesAutoresizingMaskIntoConstraints = false
        loginCard.backgroundColor = .white
        loginCard.layer.cornerRadius = 16
        loginCard.layer.shadowColor = UIColor.black.cgColor
        loginCard.layer.shadowOpacity = 0.1
        loginCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        loginCard.layer.shadowRadius = 4
        loginCard.layer.masksToBounds = false
        
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

        NSLayoutConstraint.activate([
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
        ])

        return loginCard
    }

    // MARK: - 유저 카드
    private func makeUserCard() -> UIView {
        let userCard = UIView()
        userCard.translatesAutoresizingMaskIntoConstraints = false
        userCard.backgroundColor = .white
        userCard.layer.cornerRadius = 16
        userCard.layer.shadowOpacity = 0.1
        userCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        userCard.layer.shadowRadius = 4
        userCard.layer.masksToBounds = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = (isManager ? UIColor.systemOrange : UIColor.systemBlue).withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 40
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.widthAnchor.constraint(equalToConstant: 80).isActive = true
        iconContainer.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let icon = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        icon.tintColor = isManager ? .systemOrange : .systemBlue
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(icon)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40)
        ])

        // 정보 라벨들
        let nameLabel = UILabel()
        nameLabel.text = userName
        nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        nameLabel.textColor = .label
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        let roleLabel = UILabel()
        roleLabel.text = isManager ? "관리자" : "근로자"
        roleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        roleLabel.textColor = .white
        roleLabel.backgroundColor = isManager ? .systemOrange : .systemBlue
        roleLabel.textAlignment = .center
        roleLabel.layer.cornerRadius = 12
        roleLabel.layer.masksToBounds = true
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        roleLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

        let idLabel = UILabel()
        idLabel.text = "ID: \(userId)"
        idLabel.font = UIFont.systemFont(ofSize: 13)
        idLabel.textColor = .secondaryLabel
        idLabel.translatesAutoresizingMaskIntoConstraints = false

        let roleIdStack = UIStackView(arrangedSubviews: [roleLabel, idLabel])
        roleIdStack.axis = .horizontal
        roleIdStack.spacing = 8
        roleIdStack.alignment = .center

        let infoStack = UIStackView(arrangedSubviews: [nameLabel, roleIdStack])
        infoStack.axis = .vertical
        infoStack.spacing = 8
        infoStack.alignment = .leading

        let logoutButton = UIButton(type: .system)
        logoutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        logoutButton.imageView?.contentMode = .scaleAspectFill
        logoutButton.tintColor = .darkGray
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        addTouchAnimation(to: logoutButton)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)

        let horizontalStack = UIStackView(arrangedSubviews: [iconContainer, infoStack, logoutButton])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        logoutButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        userCard.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: userCard.topAnchor, constant: 20),
            horizontalStack.leadingAnchor.constraint(equalTo: userCard.leadingAnchor, constant: 20),
            horizontalStack.trailingAnchor.constraint(equalTo: userCard.trailingAnchor, constant: -20),
            idLabel.centerYAnchor.constraint(equalTo: roleLabel.centerYAnchor)
        ])

        // 출근/퇴근/휴식/타이머 UI
        if isManager {
            let stat1 = makeStatCard(value: "0", title: "관리 근로자", bgColor: UIColor.systemGreen.withAlphaComponent(0.1), textColor: .systemGreen)
            let stat2 = makeStatCard(value: "0", title: "활성 카메라", bgColor: UIColor.systemBlue.withAlphaComponent(0.1), textColor: .systemBlue)

            let statsStack = UIStackView(arrangedSubviews: [stat1, stat2])
            statsStack.axis = .horizontal
            statsStack.spacing = 12
            statsStack.distribution = .fillEqually
            statsStack.translatesAutoresizingMaskIntoConstraints = false

            userCard.addSubview(statsStack)

            NSLayoutConstraint.activate([
                statsStack.topAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 16),
                statsStack.leadingAnchor.constraint(equalTo: userCard.leadingAnchor, constant: 20),
                statsStack.trailingAnchor.constraint(equalTo: userCard.trailingAnchor, constant: -20),
                statsStack.bottomAnchor.constraint(equalTo: userCard.bottomAnchor, constant: -20),
                horizontalStack.bottomAnchor.constraint(equalTo: userCard.bottomAnchor, constant: -96)
            ])
        } else {
            setupAttendanceUI(in: userCard, below: horizontalStack)
            NSLayoutConstraint.activate([
                attendanceStackView.bottomAnchor.constraint(equalTo: userCard.bottomAnchor, constant: -20)
            ])
        }
        return userCard
    }

    // MARK: - 출근/퇴근/휴식/타이머 UI 셋업 (userCard 내부에서 호출)
    private func setupAttendanceUI(in parentView: UIView, below horizontalStack: UIStackView) {
        // 출근 버튼
        clockInButton.setTitle("출근", for: .normal)
        clockInButton.setTitleColor(.white, for: .normal)
        clockInButton.backgroundColor = .systemBlue
        clockInButton.layer.cornerRadius = 8
        clockInButton.addTarget(self, action: #selector(handleClockIn), for: .touchUpInside)
        clockInButton.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(clockInButton)

        NSLayoutConstraint.activate([
            clockInButton.topAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 24),
            clockInButton.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            clockInButton.widthAnchor.constraint(equalToConstant: 200),
            clockInButton.heightAnchor.constraint(equalToConstant: 32),
            clockInButton.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -20)
        ])

        // 퇴근, 타이머, 휴식 스택뷰
        clockOutButton.setTitle("퇴근", for: .normal)
        clockOutButton.setTitleColor(.white, for: .normal)
        clockOutButton.backgroundColor = .systemRed
        clockOutButton.layer.cornerRadius = 8
        clockOutButton.addTarget(self, action: #selector(handleClockOut), for: .touchUpInside)
        clockOutButton.translatesAutoresizingMaskIntoConstraints = false

        breakButton.setTitle("휴식", for: .normal)
        breakButton.setTitleColor(.white, for: .normal)
        breakButton.backgroundColor = .systemOrange
        breakButton.layer.cornerRadius = 8
        breakButton.addTarget(self, action: #selector(handleBreak), for: .touchUpInside)
        breakButton.translatesAutoresizingMaskIntoConstraints = false

        timerLabel.text = "00:00:00"
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        timerLabel.textAlignment = .center
        timerLabel.textColor = .black
        timerLabel.translatesAutoresizingMaskIntoConstraints = false

        attendanceStackView.axis = .horizontal
        attendanceStackView.spacing = 12
        attendanceStackView.alignment = .center
        attendanceStackView.translatesAutoresizingMaskIntoConstraints = false
        attendanceStackView.addArrangedSubview(breakButton)
        attendanceStackView.addArrangedSubview(timerLabel)
        attendanceStackView.addArrangedSubview(clockOutButton)
        attendanceStackView.isHidden = true
        parentView.addSubview(attendanceStackView)

        NSLayoutConstraint.activate([
            attendanceStackView.topAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 16),
            attendanceStackView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            clockOutButton.widthAnchor.constraint(equalToConstant: 120),
            breakButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }

    @objc private func handleClockIn() {
        clockInButton.isHidden = true
        attendanceStackView.isHidden = false
        startTimer()
    }

    @objc private func handleClockOut() {
        clockInButton.isHidden = false
        attendanceStackView.isHidden = true
        stopTimer()
        seconds = 0
        timerLabel.text = "00:00:00"
        breakButton.setTitle("휴식", for: .normal)
        isPaused = false
    }

    @objc private func handleBreak() {
        isPaused.toggle()
        breakButton.setTitle(isPaused ? "재개" : "휴식", for: .normal)
    }

    private func startTimer() {
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.seconds += 1
            let hours = self.seconds / 3600
            let minutes = (self.seconds % 3600) / 60
            let secs = self.seconds % 60
            self.timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, secs)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    @objc private func logoutButtonTapped() {
        delegate?.didTapLogoutButton()
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

private func makeStatCard(value: String, title: String, bgColor: UIColor, textColor: UIColor) -> UIView {
    let card = UIView()
    card.backgroundColor = bgColor
    card.layer.cornerRadius = 12
    card.translatesAutoresizingMaskIntoConstraints = false
    card.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
    card.layer.shadowOpacity = 0.1
    card.layer.shadowOffset = CGSize(width: 0, height: 2)
    card.layer.shadowRadius = 4
    card.layer.masksToBounds = false
    
    let valueLabel = UILabel()
    valueLabel.text = value
    valueLabel.font = UIFont.boldSystemFont(ofSize: 20)
    valueLabel.textColor = textColor
    valueLabel.textAlignment = .center

    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = UIFont.systemFont(ofSize: 13)
    titleLabel.textColor = textColor
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 1

    let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 4
    stack.translatesAutoresizingMaskIntoConstraints = false

    card.addSubview(stack)

    NSLayoutConstraint.activate([
        stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
        stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
        stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
        stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
    ])

    return card
}

// MARK: - 유저 정보로 View 구성
extension ProfileView {
    func configureView(user: (type: String, phoneNumber: String, companyName: String, businessNumber: String?)) {
        let privateInfoCard = setupPrivateInfoSection(
            type: user.type,
            phoneNumber: user.phoneNumber,
            companyName: user.companyName,
            businessNumber: user.businessNumber
        )
        if let first = contentStackView.arrangedSubviews.first,
            first.tag == 9999 {
            contentStackView.removeArrangedSubview(first)
            first.removeFromSuperview()
        }
        privateInfoCard.tag = 9999
        contentStackView.insertArrangedSubview(privateInfoCard, at: 0)
    }
}

// MARK: - Private Info Section 생성
extension ProfileView {
    func setupPrivateInfoSection(type: String, phoneNumber: String, companyName: String, businessNumber: String?) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.layer.masksToBounds = false
        
        let titleLabel = UILabel()
        titleLabel.text = "내 정보"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let infoStack = UIStackView()
        infoStack.axis = .vertical
        infoStack.spacing = 14
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        var items: [(UIImage?, String, String)] = [
            (UIImage(systemName: "phone"), "연락처", phoneNumber),
            (UIImage(systemName: "building.2"), "회사명", companyName)
        ]
        if type == "manager", let bizNum = businessNumber {
            items.append((UIImage(systemName: "doc.text"), "사업자 등록번호", bizNum))
        }
        
        for (icon, title, value) in items {
            let row = makeInfoRow(icon: icon, title: title, value: value)
            infoStack.addArrangedSubview(row)
        }
        
        card.addSubview(titleLabel)
        card.addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            infoStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            infoStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            infoStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }
    
    private func makeInfoRow(icon: UIImage?, title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray6
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: icon)
        iconImageView.tintColor = .systemGray
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = .gray
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.boldSystemFont(ofSize: 16)
        valueLabel.textColor = .black
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let horizontalStack = UIStackView(arrangedSubviews: [iconImageView, textStack])
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.spacing = 12
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(horizontalStack)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            horizontalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            horizontalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            horizontalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
    
    
    // MARK: - 설정 카드 Section
    private func setupSettingSection(isManager: Bool) {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.05
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "설정"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(makeSettingsItem(title: "비밀번호 변경", iconName: "key.fill"))
        stackView.addArrangedSubview(makeSettingsItem(title: "개인정보 수정", iconName: "person.crop.circle"))
        stackView.addArrangedSubview(makeSettingsItem(title: "알림 설정", iconName: "gearshape"))
        if isManager {
            stackView.addArrangedSubview(makeSettingsItem(title: "사업장 정보 수정", iconName: "building.2"))
        }
        
        container.addSubview(titleLabel)
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        contentStackView.addArrangedSubview(container)
    }
    
    private func makeSettingsItem(title: String, iconName: String) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle(nil, for: .normal)
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .darkGray
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let innerStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        innerStack.axis = .horizontal
        innerStack.spacing = 12
        innerStack.alignment = .center
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(innerStack)
        
        NSLayoutConstraint.activate([
            innerStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 32),
            innerStack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            innerStack.topAnchor.constraint(equalTo: button.topAnchor, constant: 12),
            innerStack.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -24)
        ])
        
        return button
    }
}

