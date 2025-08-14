//
//  CrewMessageView.swift
//  safe
//
//  Created by 신찬솔 on 8/14/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class CrewMessageView: UIView {

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "개별 메세지"
        lb.font = .boldSystemFont(ofSize: 24)
        lb.textColor = .label
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let recipientsTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "수신자 선택"
        lb.font = .systemFont(ofSize: 14, weight: .semibold)
        lb.textColor = .secondaryLabel
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let recipientsScroll: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let recipientsStack: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.alignment = .center
        st.spacing = 8
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()

    private let messageTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "메세지 내용"
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.textColor = .label
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let textViewContainer = UIView()
    private let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.isScrollEnabled = true
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    private let placeholderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "개별 메세지를 입력하세요."
        lb.font = .systemFont(ofSize: 16)
        lb.textColor = .placeholderText
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let sendButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("메세지 전송", for: .normal)
        bt.titleLabel?.font = .boldSystemFont(ofSize: 22)
        bt.backgroundColor = UIColor.systemOrange
        bt.setTitleColor(.white, for: .normal)
        bt.layer.cornerRadius = 14
        bt.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()

    struct Member: Hashable {
        let uid: String
        let name: String
        let phone: String
    }
    private var members: [Member] = []
    private var selectedUIDs: Set<String> = [] { didSet { updateSendButtonState() } }
    private var pendingPreselect: Set<String> = []
    
    private var companyListener: ListenerRegistration?
    private var memberListeners: [String: ListenerRegistration] = [:]
    private var hiddenObserver: NSKeyValueObservation?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        fetchMembers()
        hiddenObserver = observe(\.isHidden, options: [.new]) { [weak self] _, change in
            guard let self = self else { return }
            if change.newValue == true {
                self.clearRecipientSelection()
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        fetchMembers()
        hiddenObserver = observe(\.isHidden, options: [.new]) { [weak self] _, change in
            guard let self = self else { return }
            if change.newValue == true {
                self.clearRecipientSelection()
            }
        }
    }

    deinit {
        companyListener?.remove()
        memberListeners.values.forEach { $0.remove() }
        memberListeners.removeAll()
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(recipientsTitleLabel)
        addSubview(recipientsScroll)
        recipientsScroll.addSubview(recipientsStack)
        addSubview(messageTitleLabel)
        addSubview(textViewContainer)
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        textViewContainer.backgroundColor = UIColor.secondarySystemBackground
        textViewContainer.layer.cornerRadius = 14
        textViewContainer.layer.masksToBounds = true
        textViewContainer.addSubview(messageTextView)
        textViewContainer.addSubview(placeholderLabel)
        addSubview(sendButton)

        messageTextView.delegate = self
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            recipientsTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            recipientsTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            recipientsTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            recipientsScroll.topAnchor.constraint(equalTo: recipientsTitleLabel.bottomAnchor, constant: 8),
            recipientsScroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            recipientsScroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            recipientsScroll.heightAnchor.constraint(equalToConstant: 140),

            recipientsStack.topAnchor.constraint(equalTo: recipientsScroll.contentLayoutGuide.topAnchor),
            recipientsStack.leadingAnchor.constraint(equalTo: recipientsScroll.contentLayoutGuide.leadingAnchor),
            recipientsStack.trailingAnchor.constraint(equalTo: recipientsScroll.contentLayoutGuide.trailingAnchor),
            recipientsStack.bottomAnchor.constraint(equalTo: recipientsScroll.contentLayoutGuide.bottomAnchor),
            recipientsStack.heightAnchor.constraint(equalTo: recipientsScroll.frameLayoutGuide.heightAnchor),

            messageTitleLabel.topAnchor.constraint(equalTo: recipientsScroll.bottomAnchor, constant: 16),
            messageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            textViewContainer.topAnchor.constraint(equalTo: messageTitleLabel.bottomAnchor, constant: 8),
            textViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textViewContainer.heightAnchor.constraint(equalToConstant: 180),

            messageTextView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            messageTextView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor),
            messageTextView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor),
            messageTextView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: textViewContainer.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textViewContainer.trailingAnchor, constant: -16),

            sendButton.topAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sendButton.heightAnchor.constraint(equalToConstant: 60),
            bottomAnchor.constraint(greaterThanOrEqualTo: sendButton.bottomAnchor)
        ])

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func buildRecipientCards() {
        recipientsStack.arrangedSubviews.forEach { v in
            recipientsStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        for m in members {
            let card = RecipientCardView(model: .init(uid: m.uid, name: m.name))
            card.isSelected = selectedUIDs.contains(m.uid)
            card.addTarget(self, action: #selector(didToggleRecipient(_:)), for: .touchUpInside)
            recipientsStack.addArrangedSubview(card)
        }
        if !pendingPreselect.isEmpty {
            selectedUIDs.formUnion(pendingPreselect)
            pendingPreselect.removeAll()
        }
        for case let card as RecipientCardView in recipientsStack.arrangedSubviews {
            if let uid = card.model?.uid {
                card.isSelected = selectedUIDs.contains(uid)
            }
        }
    }

    private func clearRecipientSelection() {
        selectedUIDs.removeAll()
        for case let card as RecipientCardView in recipientsStack.arrangedSubviews {
            card.isSelected = false
        }
        updateSendButtonState()
    }

    private func updateSendButtonState() {
        sendButton.alpha = selectedUIDs.isEmpty ? 0.5 : 1.0
        sendButton.isEnabled = !selectedUIDs.isEmpty
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            clearRecipientSelection()
        }
    }

    @objc private func didToggleRecipient(_ sender: RecipientCardView) {
        guard let uid = sender.model?.uid else { return }
        if selectedUIDs.contains(uid) { selectedUIDs.remove(uid) } else { selectedUIDs.insert(uid) }
        sender.isSelected.toggle()
    }

    @objc private func didTapSend() {
        let text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            let alert = UIAlertController(title: nil, message: "메세지를 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            presentAlert(alert)
            return
        }

        let alert = UIAlertController(title: nil, message: "메세지를 전송했습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        presentAlert(alert)
    }
    
    func preselectRecipients(_ uids: Set<String>) {
        let known = Set(members.map { $0.uid })
        let now = uids.intersection(known)
        let later = uids.subtracting(known)

        if !now.isEmpty {
            selectedUIDs.formUnion(now)
            for case let card as RecipientCardView in recipientsStack.arrangedSubviews {
                if let uid = card.model?.uid {
                    card.isSelected = selectedUIDs.contains(uid)
                }
            }
        }
        if !later.isEmpty {
            pendingPreselect.formUnion(later)
        }
    }

    func fetchMembers() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(currentUID).getDocument { [weak self] snap, _ in
            guard let self = self, let data = snap?.data(), let company = data["companyName"] as? String else { return }
            self.companyListener?.remove()
            self.companyListener = db.collection(company).addSnapshotListener { [weak self] qsnap, _ in
                guard let self = self else { return }
                var uids: [String] = []
                qsnap?.documents.forEach { doc in
                    if let uid = (doc["uid"] as? String) ?? doc.documentID as String? {
                        uids.append(uid)
                    }
                }

                self.memberListeners.values.forEach { $0.remove() }
                self.memberListeners.removeAll()
                self.members.removeAll()

                let usersRef = db.collection("users")
                uids.forEach { uid in
                    let l = usersRef.document(uid).addSnapshotListener { [weak self] doc, _ in
                        guard let self = self, let d = doc?.data() else { return }
                        let name = (d["name"] as? String) ?? "-"
                        let phone = (d["phoneNumber"] as? String) ?? "-"
                        let member = Member(uid: uid, name: name, phone: phone)

                        if let idx = self.members.firstIndex(where: { $0.uid == uid }) {
                            self.members[idx] = member
                        } else {
                            self.members.append(member)
                        }
                        self.members.sort { $0.name < $1.name }
                        self.buildRecipientCards()
                    }
                    self.memberListeners[uid] = l
                }
            }
        }
    }
}

extension CrewMessageView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

private final class RecipientCardView: UIControl {
    struct Model { let uid: String; let name: String }
    var model: Model?

    private let container = UIView()
    private let avatar = UIView()
    private let initialLabel = UILabel()
    private let nameLabel = UILabel()

    init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 14
        container.isUserInteractionEnabled = false
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.tertiaryLabel.withAlphaComponent(0.25).cgColor

        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
        avatar.layer.cornerRadius = 14

        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        initialLabel.font = .boldSystemFont(ofSize: 24)
        initialLabel.textAlignment = .center
        initialLabel.textColor = .systemOrange

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center

        nameLabel.text = model?.name ?? "-"

        addSubview(container)
        container.addSubview(avatar)
        container.addSubview(nameLabel)

        if let n = model?.name, let f = n.first { initialLabel.text = String(f) } else { initialLabel.text = "?" }
        avatar.addSubview(initialLabel)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            avatar.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            avatar.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 56),
            avatar.heightAnchor.constraint(equalToConstant: 56),

            initialLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),

            heightAnchor.constraint(equalToConstant: 140),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 96)
        ])
        updateAppearance()
    }

    private func updateAppearance() {
        container.layer.borderColor = (isSelected ? UIColor.systemOrange : UIColor.tertiaryLabel.withAlphaComponent(0.25)).cgColor
        container.layer.borderWidth = isSelected ? 2 : 1
        container.backgroundColor = isSelected ? UIColor.systemOrange.withAlphaComponent(0.12) : .white
    }

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }
}

private extension UIView {
    func presentAlert(_ alert: UIAlertController) {
        guard let vc = nearestViewController() else { return }
        vc.present(alert, animated: true, completion: nil)
    }

    func nearestViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}
