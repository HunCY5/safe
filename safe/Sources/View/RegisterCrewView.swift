//
//  RegisterCrewView.swift
//  safe
//
//  Created by 신찬솔 on 7/31/25.
//

import UIKit

class RegisterCrewView: UIView {

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "근로자 등록"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "사번"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

     let employeeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "사번을 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // infoLabel을 감싸는 카드 뷰 추가
    private let infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "등록 안내"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "입력된 사번을 기반으로 근로자가 등록됩니다.\n등록된 근로자는 관리자가 관리할 수 있습니다."
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

     let inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✉️ 근무자 등록", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        addSubview(cardView)

        cardView.addSubview(titleLabel)
        cardView.addSubview(idLabel)
        cardView.addSubview(employeeTextField)
        cardView.addSubview(infoCardView)
        infoCardView.addSubview(infoTitleLabel)
        infoCardView.addSubview(infoLabel)
        cardView.addSubview(inviteButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            idLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            idLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            idLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            employeeTextField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8),
            employeeTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            employeeTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            infoCardView.topAnchor.constraint(equalTo: employeeTextField.bottomAnchor, constant: 20),
            infoCardView.leadingAnchor.constraint(equalTo: employeeTextField.leadingAnchor),
            infoCardView.trailingAnchor.constraint(equalTo: employeeTextField.trailingAnchor),

            infoTitleLabel.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 12),
            infoTitleLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 12),
            infoTitleLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -12),

            infoLabel.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 4),
            infoLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -12),
            infoLabel.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -12),

            inviteButton.topAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: 24),
            inviteButton.leadingAnchor.constraint(equalTo: employeeTextField.leadingAnchor),
            inviteButton.trailingAnchor.constraint(equalTo: employeeTextField.trailingAnchor),
            inviteButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            inviteButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
