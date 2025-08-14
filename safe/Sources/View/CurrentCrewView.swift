//
//  CurrentCrewView.swift
//  safe
//
//  Created by 신찬솔 on 8/13/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CurrentCrewView: UIView {
    
    private let countersStack = UIStackView()
    private let workingCard = StatCard(title: "근무중")
    private let restingCard = StatCard(title: "휴식중")
    private let offlineCard = StatCard(title: "오프라인")
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "현장 현황"
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = .label
        return l
    }()
    private let restAllButton = UIButton(type: .system)

    private var memberListeners: [String: ListenerRegistration] = [:]
    private var companyListener: ListenerRegistration?

    private var members: [String: MemberSnapshot] = [:]

    struct MemberSnapshot {
        let uid: String
        let name: String
        let phone: String
        let working: Bool
        let resting: Bool
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startListening()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        startListening()
    }

    deinit {
        companyListener?.remove()
        memberListeners.values.forEach { $0.remove() }
    }

    private func setupUI() {
        backgroundColor = .clear

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), restAllButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        countersStack.axis = .horizontal
        countersStack.alignment = .center
        countersStack.distribution = .fillEqually
        countersStack.spacing = 12

        [workingCard, restingCard, offlineCard].forEach { countersStack.addArrangedSubview($0) }

        addSubview(countersStack)
        countersStack.translatesAutoresizingMaskIntoConstraints = false

        restAllButton.setTitle("전체 휴식 알림 전송", for: .normal)
        restAllButton.backgroundColor = .systemOrange
        restAllButton.setTitleColor(.white, for: .normal)
        restAllButton.layer.cornerRadius = 10
        restAllButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        restAllButton.translatesAutoresizingMaskIntoConstraints = false
        restAllButton.addTarget(self, action: #selector(restAllButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            restAllButton.heightAnchor.constraint(equalToConstant: 30),
            restAllButton.widthAnchor.constraint(equalToConstant: 120),

            countersStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 16),
            countersStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            countersStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            countersStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        workingCard.applyColors(bg: UIColor.systemGreen.withAlphaComponent(0.15), title: UIColor.systemGreen, count: UIColor.systemGreen)
        restingCard.applyColors(bg: UIColor.systemBlue.withAlphaComponent(0.15), title: UIColor.systemBlue, count: UIColor.systemBlue)
        offlineCard.applyColors(bg: UIColor.systemGray5, title: UIColor.label, count: UIColor.label)

        updateCounters()
    }

    @objc private func restAllButtonTapped() {
        let alert = UIAlertController(title: nil, message: "전체휴식알림을 보냈습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        presentAlert(alert)
    }

    private func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).getDocument { [weak self] snap, err in
            guard let self = self else { return }
            if let err = err {
                print("회사명 로드 실패: \(err.localizedDescription)")
                return
            }
            guard let data = snap?.data(), let companyName = data["companyName"] as? String else {
                print("회사명 없음")
                return
            }
            self.listenCompanyCollection(named: companyName)
        }
    }

    private func listenCompanyCollection(named companyName: String) {
        let db = Firestore.firestore()

        companyListener?.remove()
        memberListeners.values.forEach { $0.remove() }
        memberListeners.removeAll()
        members.removeAll()
        updateCounters()

        companyListener = db.collection(companyName).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("회사 컬렉션 listen 실패: \(error.localizedDescription)")
                return
            }
            let docs = snapshot?.documents ?? []
            let uids = Set(docs.map { $0.documentID })

            for (uid, listener) in self.memberListeners where !uids.contains(uid) {
                listener.remove()
                self.memberListeners.removeValue(forKey: uid)
                self.members.removeValue(forKey: uid)
            }

            for uid in uids where self.memberListeners[uid] == nil {
                self.attachMemberListener(uid: uid)
            }
            DispatchQueue.main.async {
                self.updateCounters()
            }
        }
    }

    private func attachMemberListener(uid: String) {
        let db = Firestore.firestore()
        let listener = db.collection("users").document(uid).addSnapshotListener { [weak self] doc, err in
            guard let self = self else { return }
            if let err = err {
                print("멤버 리스너 실패(\(uid)): \(err.localizedDescription)")
                return
            }
            guard let d = doc?.data() else { return }
            let name = (d["name"] as? String) ?? "이름없음"
            let phone = (d["phoneNumber"] as? String) ?? "-"
            let working = (d["working"] as? Bool) ?? false
            let resting = (d["resting"] as? Bool) ?? false

            let m = MemberSnapshot(uid: uid, name: name, phone: phone, working: working, resting: resting)
            self.members[uid] = m
            DispatchQueue.main.async {
                self.updateCounters()
            }
        }
        memberListeners[uid] = listener
    }

    private func updateCounters() {
        var workingCnt = 0, restingCnt = 0, offlineCnt = 0
        for m in members.values {
            switch (m.working, m.resting) {
            case (true, false): workingCnt += 1
            case (true, true):  restingCnt += 1
            case (false, false): offlineCnt += 1
            default: offlineCnt += 1
            }
        }
        workingCard.count = workingCnt
        restingCard.count = restingCnt
        offlineCard.count = offlineCnt
    }


    private func statusText(for m: MemberSnapshot) -> String {
        switch (m.working, m.resting) {
        case (true, false): return "근무중"
        case (true, true):  return "휴식중"
        case (false, false): return "오프라인"
        default: return "오프라인"
        }
    }

    private func statusColor(for m: MemberSnapshot) -> UIColor {
        switch (m.working, m.resting) {
        case (true, false): return UIColor.systemGreen
        case (true, true):  return UIColor.systemBlue
        case (false, false): return UIColor.systemGray
        default: return UIColor.systemGray
        }
    }
    
    private final class StatCard: UIView {
        private let titleLabel = UILabel()
        private let countLabel = UILabel()

        var count: Int = 0 { didSet { countLabel.text = "\(count)" } }

        init(title: String) {
            super.init(frame: .zero)
            layer.cornerRadius = 16
            backgroundColor = UIColor.secondarySystemBackground
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.15
            layer.shadowRadius = 10
            layer.shadowOffset = CGSize(width: 0, height: 2)

            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            titleLabel.textColor = .label
            titleLabel.textAlignment = .center

            countLabel.text = "0"
            countLabel.font = .systemFont(ofSize: 44, weight: .bold)
            countLabel.textColor = .label
            countLabel.textAlignment = .center

            let v = UIStackView(arrangedSubviews: [UIView(), titleLabel, UIView(), countLabel, UIView()])
            v.axis = .vertical
            v.spacing = 8
            addSubview(v)
            v.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                v.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                v.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                v.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
            ])
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        func applyColors(bg: UIColor, title: UIColor, count: UIColor) {
            backgroundColor = bg
            titleLabel.textColor = title
            countLabel.textColor = count
        }
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
