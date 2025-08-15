//
//  RiskLogView.swift
//  safe
//
//  Created by 신찬솔 on 8/15/25.
//

import UIKit

final class RiskLogView: UIView {
    
    private let dateSelectButton: UIButton = {
        let button = UIButton(type: .system)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        let today = formatter.string(from: Date())
        button.setTitle(today, for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.05
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func setDateButtonTarget(_ target: Any, action: Selector) {
        dateSelectButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    var onDateChanged: ((Date) -> Void)?
    
    private func makeCard(title: String) -> (container: UIView, titleLabel: UILabel, countLabel: UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.25
        container.layer.shadowRadius = 6
        container.layer.shadowOffset = CGSize(width: 0, height: 4)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.text = title

        let countLabel = UILabel()
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = .systemFont(ofSize: 44, weight: .semibold)
        countLabel.textColor = .orange
        countLabel.textAlignment = .center
        countLabel.text = "0"

        container.addSubview(titleLabel)
        container.addSubview(countLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),

            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            countLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8),
            countLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -16)
        ])

        return (container, titleLabel, countLabel)
    }
    
    private lazy var helmetCard = makeCard(title: "안전모 미착용")
    private lazy var vestCard   = makeCard(title: "조끼 미착용")
    private lazy var postureCard = makeCard(title: "자세 위험")

    private let cardsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .fill
        s.distribution = .fillEqually
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .systemBackground
        addSubview(dateSelectButton)
        addSubview(cardsStack)
        cardsStack.addArrangedSubview(helmetCard.container)
        cardsStack.addArrangedSubview(vestCard.container)
        cardsStack.addArrangedSubview(postureCard.container)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            dateSelectButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            dateSelectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dateSelectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            dateSelectButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            cardsStack.topAnchor.constraint(equalTo: dateSelectButton.bottomAnchor, constant: 16),
            cardsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        helmetCard.container.heightAnchor.constraint(equalTo: helmetCard.container.widthAnchor).isActive = true
        vestCard.container.heightAnchor.constraint(equalTo: vestCard.container.widthAnchor).isActive = true
        postureCard.container.heightAnchor.constraint(equalTo: postureCard.container.widthAnchor).isActive = true
    }

    func setDate(_ date: Date) {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "yyyy년 MM월 dd일"
        dateSelectButton.setTitle(f.string(from: date), for: .normal)
    }
    
    func updateHelmetCount(_ value: Int) {
        helmetCard.countLabel.text = String(value)
    }

    func updateVestCount(_ value: Int) {
        vestCard.countLabel.text = String(value)
    }

    func updatePostureCount(_ value: Int) {
        postureCard.countLabel.text = String(value)
    }
}
