//
//  CrewManageView.swift
//  safe
//
//  Created by 신찬솔 on 7/30/25.
//

import UIKit


class CrewManageView: UIView {

    private let containerView = UIView()
    private let stackView = UIStackView()
    private let statusButton = UIButton()
    private let inviteButton = UIButton()
    private let messageButton = UIButton()
    private var selectedIndex: Int = 0 {
        didSet {
            updateTabSelection()
            onTabSelected?(selectedIndex)
        }
    }

    private let selectionIndicator = UIView()
    private var indicatorLeadingConstraint: NSLayoutConstraint?
    private var indicatorWidthConstraint: NSLayoutConstraint?
    private let currentCrewView = CurrentCrewView()
    private let crewListSectionView = CrewListSectionView()
    private let messageView = CrewMessageView()
    let registerCrewView = RegisterCrewView()
    
    var onTabSelected: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTabs()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTabs()
    }

    private func setupTabs() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 52)
        ])

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.alignment = .fill
        containerView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4)
        ])

        configureButton(statusButton, title: "현황", iconName: "person.2", index: 0)
        configureButton(inviteButton, title: "등록", iconName: "person.badge.plus", index: 1)
        configureButton(messageButton, title: "공지", iconName: "message", index: 2)

        containerView.addSubview(selectionIndicator)
        selectionIndicator.backgroundColor = .orange
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        indicatorLeadingConstraint = selectionIndicator.leadingAnchor.constraint(equalTo: statusButton.leadingAnchor)
        indicatorWidthConstraint = selectionIndicator.widthAnchor.constraint(equalTo: statusButton.widthAnchor)
        NSLayoutConstraint.activate([
            selectionIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            indicatorLeadingConstraint!,
            indicatorWidthConstraint!,
            selectionIndicator.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        addSubview(currentCrewView)
        currentCrewView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(crewListSectionView)
        crewListSectionView.translatesAutoresizingMaskIntoConstraints = false

        
        
        NSLayoutConstraint.activate([
            currentCrewView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            currentCrewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            currentCrewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            crewListSectionView.topAnchor.constraint(equalTo: currentCrewView.bottomAnchor, constant: 16),
            crewListSectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            crewListSectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            crewListSectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])

        addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            messageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            messageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            messageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
        messageView.isHidden = true

        currentCrewView.setContentCompressionResistancePriority(.required, for: .vertical)
        crewListSectionView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        currentCrewView.isHidden = false
        crewListSectionView.isHidden = false
        
        addSubview(registerCrewView)
        registerCrewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            registerCrewView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 32),
            registerCrewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            registerCrewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            registerCrewView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -32)
        ])
        registerCrewView.isHidden = true

        updateTabSelection()
    }

    private func configureButton(_ button: UIButton, title: String, iconName: String, index: Int) {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let image = UIImage(systemName: iconName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.setTitle(" " + title, for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.tintColor = .darkGray
        button.semanticContentAttribute = .forceLeftToRight
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        button.tag = index
        stackView.addArrangedSubview(button)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }

    @objc private func tabTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
    }

    private func updateTabSelection() {
        let buttons = [statusButton, inviteButton, messageButton]
        for (index, button) in buttons.enumerated() {
            if index == selectedIndex {
                button.setTitleColor(.orange, for: .normal)
                button.tintColor = .orange
            } else {
                button.setTitleColor(.darkGray, for: .normal)
                button.tintColor = .darkGray
            }
        }
        UIView.animate(withDuration: 0.25) {
            self.indicatorLeadingConstraint?.isActive = false
            self.indicatorLeadingConstraint = self.selectionIndicator.centerXAnchor.constraint(equalTo: buttons[self.selectedIndex].centerXAnchor)
            self.indicatorWidthConstraint?.isActive = false
            self.indicatorWidthConstraint = self.selectionIndicator.widthAnchor.constraint(equalTo: buttons[self.selectedIndex].widthAnchor, multiplier: 0.75)
            NSLayoutConstraint.activate([
                self.indicatorLeadingConstraint!,
                self.indicatorWidthConstraint!
            ])
            self.layoutIfNeeded()
        }
        currentCrewView.isHidden = selectedIndex != 0
        crewListSectionView.isHidden = selectedIndex != 0
        registerCrewView.isHidden = selectedIndex != 1
        messageView.isHidden = selectedIndex != 2
    }
}
