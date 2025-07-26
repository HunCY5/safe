//
//  ChoiceLoginView.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit
import SnapKit

protocol ChoiceLoginViewDelegate: AnyObject {
    func didTapWorkerCard()
    func didTapManagerCard()
}

class ChoiceLoginView: UIView {
    
    weak var delegate: ChoiceLoginViewDelegate?
    
    // MARK: - UI Elements
    
    // App icon
    private let appIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "shield"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor.systemBlue
        return iv
    }()
    
    // App name
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "세잎"
        label.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        label.textAlignment = .center
        return label
    }()
    
    // Subtitle
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "현장 안전 관리 시스템"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    // Sub text
    private let subTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Safe · Smart · Secure"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.systemGray
        return label
    }()
    
    // 안내 텍스트
    private let guideTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인 유형 선택"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let guideSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "귀하의 역할에 맞는 로그인 방식을 선택해주세요"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = UIColor.systemGray
        return label
    }()
    
    // 근로자 로그인 카드
    let workerCard: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.systemBackground
        btn.layer.cornerRadius = 16
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 8
        btn.clipsToBounds = false
        btn.accessibilityIdentifier = "workerCard"
        return btn
    }()
    
    private let workerIcon: UIView = {
        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.systemBlue
        iconBg.layer.cornerRadius = 15
        let icon = UIImageView(image: UIImage(systemName: "person.3.fill"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        iconBg.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        return iconBg
    }()
    
    private let workerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "근로자 로그인"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .label
        return label
    }()
    
    private let workerDescLabel: UILabel = {
        let label = UILabel()
        label.text = "현장에서 근무하는 작업자를 위한 로그인"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let workerTagsView: UIView = {
        let tag1 = ChoiceLoginView.makeTagView(iconName: "person.2", text: "작업자")
        let tag2 = ChoiceLoginView.makeTagView(iconName: "shield", text: "안전 관리")
        let stack = UIStackView(arrangedSubviews: [tag1, tag2])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    // 관리자 로그인 카드
    let managerCard: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.systemBackground
        btn.layer.cornerRadius = 16
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 8
        btn.clipsToBounds = false
        btn.accessibilityIdentifier = "adminCard"
        return btn
    }()
    
    private let managerIcon: UIView = {
        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.systemOrange
        iconBg.layer.cornerRadius = 15
        let icon = UIImageView(image: UIImage(systemName: "person.fill.checkmark"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        iconBg.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        return iconBg
    }()
    
    private let managerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관리자 로그인"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .label
        return label
    }()
    
    private let managerDescLabel: UILabel = {
        let label = UILabel()
        label.text = "현장을 관리하는 관리자를 위한 로그인"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let managerTagsView: UIView = {
        let tag1 = ChoiceLoginView.makeTagView(iconName: "building.2", text: "관리자")
        let tag2 = ChoiceLoginView.makeTagView(iconName: "shield", text: "전체 관리")
        let stack = UIStackView(arrangedSubviews: [tag1, tag2])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    // 하단 설명 태그
    private let bottomTagsView: UIView = {
        let tag1 = ChoiceLoginView.makeTagLabel(text: "안전한 로그인")
        let tag2 = ChoiceLoginView.makeTagLabel(text: "실시간 모니터링")
        let tag3 = ChoiceLoginView.makeTagLabel(text: "스마트 관리")
        let stack = UIStackView(arrangedSubviews: [tag1, tag2, tag3])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    // 저작권 표기
    private let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = "© 2025 세잎. 모든 권리 보유."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = UIColor.systemGray3
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupUI()
        setupCardTouchAnimation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .systemGroupedBackground
        setupUI()
        setupCardTouchAnimation()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // 상단 스택
        let topStack = UIStackView(arrangedSubviews: [appIconView, appNameLabel, subtitleLabel, subTextLabel])
        topStack.axis = .vertical
        topStack.alignment = .center
        topStack.spacing = 6
        addSubview(topStack)
        appIconView.snp.makeConstraints { make in
            make.width.height.equalTo(56)
        }
        topStack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(32)
            make.centerX.equalToSuperview()
        }
        
        // 안내 텍스트 스택
        let guideStack = UIStackView(arrangedSubviews: [guideTitleLabel, guideSubtitleLabel])
        guideStack.axis = .vertical
        guideStack.alignment = .center
        guideStack.spacing = 5
        addSubview(guideStack)
        guideStack.snp.makeConstraints { make in
            make.top.equalTo(topStack.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        // 근로자 카드 내부 구성
        let workerInfoStack = UIStackView(arrangedSubviews: [workerTitleLabel, workerDescLabel, workerTagsView])
        workerInfoStack.axis = .vertical
        workerInfoStack.spacing = 10
        workerInfoStack.alignment = .leading
        
        let workerArrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        workerArrow.tintColor = .systemGray
        workerArrow.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }

        let workerCardStack = UIStackView(arrangedSubviews: [workerIcon, workerInfoStack, workerArrow])
        workerCardStack.axis = .horizontal
        workerCardStack.spacing = 16
        workerCardStack.alignment = .center
        workerIcon.snp.makeConstraints { make in
            make.width.height.equalTo(48)
        }
        workerCardStack.isUserInteractionEnabled = false
        workerCard.addSubview(workerCardStack)
        workerCardStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(18)
        }
        
        // 관리자 카드 내부 구성
        let managerInfoStack = UIStackView(arrangedSubviews: [managerTitleLabel, managerDescLabel, managerTagsView])
        managerInfoStack.axis = .vertical
        managerInfoStack.spacing = 10
        managerInfoStack.alignment = .leading
        
        let managerArrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        managerArrow.tintColor = .systemGray
        managerArrow.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }

        let managerCardStack = UIStackView(arrangedSubviews: [managerIcon, managerInfoStack, managerArrow])
        managerCardStack.axis = .horizontal
        managerCardStack.spacing = 16
        managerCardStack.alignment = .center
        managerIcon.snp.makeConstraints { make in
            make.width.height.equalTo(48)
        }
        managerCardStack.isUserInteractionEnabled = false
        managerCard.addSubview(managerCardStack)
        managerCardStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(18)
        }
        
        // 카드 스택
        let cardsStack = UIStackView(arrangedSubviews: [workerCard, managerCard])
        cardsStack.axis = .vertical
        cardsStack.spacing = 22
        cardsStack.alignment = .fill
        addSubview(cardsStack)
        cardsStack.snp.makeConstraints { make in
            make.top.equalTo(guideStack.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(28)
        }
        workerCard.snp.makeConstraints { make in
            make.height.equalTo(140)
        }
        managerCard.snp.makeConstraints { make in
            make.height.equalTo(140)
        }
        
        // 하단 태그
        addSubview(bottomTagsView)
        bottomTagsView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-44)
            make.centerX.equalToSuperview()
        }
        
        // 저작권 표기
        addSubview(copyrightLabel)
        copyrightLabel.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-14)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - 카드 터치 애니메이션
    private func setupCardTouchAnimation() {
        [workerCard, managerCard].forEach { card in
            card.addTarget(self, action: #selector(cardTouchDown(_:)), for: .touchDown)
            card.addTarget(self, action: #selector(cardTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func cardTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.13) {
            sender.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }
    }
    
    @objc private func cardTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.13) {
            sender.transform = .identity
        }
    }
    
    @objc private func cardTapped(_ sender: UIButton) {
        if sender == workerCard {
            delegate?.didTapWorkerCard()
        } else if sender == managerCard {
            delegate?.didTapManagerCard()
        }
    }
    
    // MARK: - Tag 생성
    private static func makeTagView(iconName: String, text: String) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = .systemGray
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }

        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemGray

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }
    // MARK: - Label Tag 생성
    private static func makeTagLabel(text: String) -> UILabel {
        let label = PaddingLabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.backgroundColor = UIColor.systemGray6
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.padding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        return label
    }
}

// MARK: - PaddingLabel
fileprivate class PaddingLabel: UILabel {
    var padding = UIEdgeInsets.zero
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}
