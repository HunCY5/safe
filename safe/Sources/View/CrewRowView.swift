//
//  CrewRowView.swift
//  safe
//
//  Created by 신찬솔 on 8/14/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct CrewMemberModel {
    let uid: String
    let employeeId: String
    let name: String
    let phoneNumber: String
    let working: Bool
    let resting: Bool
}

final class CrewRowView: UIView {

    private let container = UIView()
    private let avatarView = UIView()
    private let badge = UILabel()
    private let nameLabel = UILabel()
    private let statusDot = UIView()
    private let statusLabel = UILabel()
    private let empIdLabel = UILabel()
    private let phoneLabel = UILabel()
    private let restButton = UIButton(type: .system)
    private let messageButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(with model: CrewMemberModel) {
        let initial = model.name.isEmpty ? "#" : String(model.name.prefix(1))
        badge.text = initial

        nameLabel.text = model.name
        empIdLabel.text = "사번 \(model.employeeId)"
        
        phoneLabel.text = model.phoneNumber.isEmpty ? "-" : model.phoneNumber

        restButton.setTitle("☕️  휴식 알림", for: .normal)
        messageButton.setTitle("✉️  개별 메세지", for: .normal)

        let (text, color) = Self.statusTextColor(working: model.working, resting: model.resting)
        statusLabel.text = text
        statusDot.backgroundColor = color
    }

    private static func statusTextColor(working: Bool, resting: Bool) -> (String, UIColor) {
        switch (working, resting) {
        case (true, false): return ("근무중", UIColor.systemGreen)
        case (true, true):  return ("휴식중", UIColor.systemBlue)
        default:            return ("오프라인", UIColor.systemGray)
        }
    }

    private func setupUI() {
        backgroundColor = .clear

        container.backgroundColor = UIColor.secondarySystemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 6
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
        avatarView.layer.cornerRadius = 18
        avatarView.layer.masksToBounds = true
        avatarView.widthAnchor.constraint(equalToConstant: 72).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 72).isActive = true

        badge.textAlignment = .center
        badge.font = .boldSystemFont(ofSize: 36)
        badge.textColor = .systemOrange
        badge.backgroundColor = .clear
        badge.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            badge.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])

        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.textColor = .label
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.layer.cornerRadius = 6
        statusDot.widthAnchor.constraint(equalToConstant: 12).isActive = true
        statusDot.heightAnchor.constraint(equalToConstant: 12).isActive = true

        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textColor = .label
        statusLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let statusStack = UIStackView(arrangedSubviews: [statusDot, statusLabel])
        statusStack.axis = .horizontal
        statusStack.spacing = 8
        statusStack.alignment = .center

        empIdLabel.font = .systemFont(ofSize: 16, weight: .medium)
        empIdLabel.textColor = .secondaryLabel
        empIdLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let phoneIcon = UIImageView(image: UIImage(systemName: "phone"))
        phoneIcon.tintColor = .secondaryLabel
        phoneIcon.contentMode = .scaleAspectFit
        phoneIcon.translatesAutoresizingMaskIntoConstraints = false
        phoneIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        phoneIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true

        phoneLabel.font = .systemFont(ofSize: 16, weight: .medium)
        phoneLabel.textColor = .label
        phoneLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusDot.setContentHuggingPriority(.required, for: .horizontal)
        let nameRow = UIStackView(arrangedSubviews: [nameLabel, UIView(), statusStack])
        nameRow.axis = .horizontal
        nameRow.alignment = .firstBaseline
        nameRow.spacing = 12

        let spacer = UIView(); spacer.translatesAutoresizingMaskIntoConstraints = false; spacer.widthAnchor.constraint(equalToConstant: 16).isActive = true
        let infoRow = UIStackView(arrangedSubviews: [empIdLabel, spacer, phoneIcon, phoneLabel])
        infoRow.axis = .horizontal
        infoRow.alignment = .center
        infoRow.spacing = 10

        let leftColumn = UIStackView(arrangedSubviews: [nameRow, infoRow])
        leftColumn.axis = .vertical
        leftColumn.spacing = 8
        leftColumn.translatesAutoresizingMaskIntoConstraints = false
        
        let headerRow = UIStackView(arrangedSubviews: [avatarView, leftColumn])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = 16
        headerRow.translatesAutoresizingMaskIntoConstraints = false

        restButton.translatesAutoresizingMaskIntoConstraints = false
        restButton.backgroundColor = UIColor.systemOrange
        restButton.tintColor = .white
        restButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        restButton.layer.cornerRadius = 12
        restButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        restButton.addTarget(self, action: #selector(didTapRestButton), for: .touchUpInside)

        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.backgroundColor = .white
        messageButton.tintColor = .label
        messageButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        messageButton.layer.cornerRadius = 12
        messageButton.layer.borderWidth = 1
        messageButton.layer.borderColor = UIColor.systemGray4.cgColor
        messageButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)

        let buttonSpacer = UIView()
        let buttonRow = UIStackView(arrangedSubviews: [restButton, buttonSpacer, messageButton])
        buttonRow.axis = .horizontal
        buttonRow.alignment = .center
        buttonRow.spacing = 16
        buttonRow.translatesAutoresizingMaskIntoConstraints = false
        buttonRow.distribution = .fill
        restButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        restButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        messageButton.setContentHuggingPriority(.required, for: .horizontal)
        messageButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let verticalStack = UIStackView(arrangedSubviews: [headerRow, buttonRow])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),

            avatarView.widthAnchor.constraint(equalToConstant: 56),
            avatarView.heightAnchor.constraint(equalToConstant: 56),
            restButton.heightAnchor.constraint(equalToConstant: 48),
            restButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
            messageButton.heightAnchor.constraint(equalToConstant: 48),
            messageButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
        ])

    }
    
    @objc private func didTapRestButton() {
        let alert = UIAlertController(title: nil, message: "휴식알림을 전송했습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        presentAlert(alert)
    }

    private func presentAlert(_ alert: UIAlertController) {
        guard let vc = nearestViewController() else { return }
        vc.present(alert, animated: true, completion: nil)
    }

    private func nearestViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}

final class CrewListSectionView: UIView {

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "근로자 목록"
        lb.font = .boldSystemFont(ofSize: 24)
        lb.textColor = .label
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let countBadge: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = .boldSystemFont(ofSize: 12)
        lb.textColor = .label
        lb.backgroundColor = UIColor.secondarySystemFill
        lb.layer.cornerRadius = 18
        lb.layer.masksToBounds = true
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "총 0명"
        return lb
    }()

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let db = Firestore.firestore()
    private var companyListener: ListenerRegistration?
    private var userListeners: [String: ListenerRegistration] = [:]
    private var members: [String: CrewMemberModel] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        start()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        start()
    }

    deinit {
        companyListener?.remove()
        userListeners.values.forEach { $0.remove() }
        userListeners.removeAll()
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(countBadge)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            countBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            countBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            countBadge.heightAnchor.constraint(equalToConstant: 36),
            countBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 86)
        ])

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        let content = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: content.topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -8),
            stackView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor)
        ])

        let minH = heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        minH.priority = .defaultLow
        minH.isActive = true
    }

    private func start() {
        guard let me = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(me).getDocument { [weak self] snap, err in
            guard let self = self else { return }
            if let companyName = snap?.data()?["companyName"] as? String, !companyName.isEmpty {
                self.companyListener?.remove()
                self.companyListener = self.db.collection(companyName)
                    .addSnapshotListener { [weak self] qsnap, err in
                        guard let self = self else { return }
                        guard let docs = qsnap?.documents else { return }

                        let uids: [String] = docs.compactMap {
                            if let uid = $0.data()["uid"] as? String, !uid.isEmpty {
                                return uid
                            } else {
                                return $0.documentID
                            }
                        }

                        for (uid, l) in self.userListeners where !uids.contains(uid) {
                            l.remove()
                            self.userListeners.removeValue(forKey: uid)
                            self.members.removeValue(forKey: uid)
                        }

                        for uid in uids where self.userListeners[uid] == nil {
                            let l = self.db.collection("users").document(uid).addSnapshotListener { [weak self] dsnap, err in
                                guard let self = self else { return }
                                guard let d = dsnap?.data() else { return }
                                let employeeId = d["employeeId"] as? String ?? ""
                                let name = d["name"] as? String ?? ""
                                let phone = d["phoneNumber"] as? String ?? ""
                                let working = d["working"] as? Bool ?? false
                                let resting = d["resting"] as? Bool ?? false
                                let model = CrewMemberModel(
                                    uid: uid,
                                    employeeId: employeeId,
                                    name: name,
                                    phoneNumber: phone,
                                    working: working,
                                    resting: resting
                                )
                                self.members[uid] = model
                                DispatchQueue.main.async {
                                    self.render()
                                }
                            }
                            self.userListeners[uid] = l
                        }
                        DispatchQueue.main.async { self.render() }
                    }
            } else {
                return
            }
        }
    }

    private func render() {
        countBadge.text = "총 \(members.count)명"
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let sorted = members.values.sorted { $0.name < $1.name }
        for m in sorted {
            let row = CrewRowView()
            row.configure(with: m)
            stackView.addArrangedSubview(row)
        }
    }
}
