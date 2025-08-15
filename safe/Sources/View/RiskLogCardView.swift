//
//  LiskLogCardView.swift
//  safe
//
//  Created by 신찬솔 on 8/16/25.
//

import UIKit

final class RiskLogCardView: UIView {

    struct LogItem {
        let type: String
        let timeStamp: Date
        let sector: String
        let score: Double?
        let poseType: String?
        let imageUrl: String?
        
    }

    var onTapDetail: ((LogItem) -> Void)?

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "위험 감지 로그"
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textColor = .label
        return lb
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = true
        return sv
    }()

    private let stackView: UIStackView = {
        let st = UIStackView()
        st.translatesAutoresizingMaskIntoConstraints = false
        st.axis = .vertical
        st.spacing = 12
        st.alignment = .fill
        st.distribution = .fill
        return st
    }()

    private let emptyLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "로그가 없습니다"
        lb.textAlignment = .center
        lb.textColor = .secondaryLabel
        lb.font = .systemFont(ofSize: 16, weight: .regular)
        lb.isHidden = true
        return lb
    }()

    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = .autoupdatingCurrent
        f.dateFormat = "yyyy-MM-dd\nHH:mm:ss"
        return f
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func updateLogs(_ logs: [LogItem]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyLabel.isHidden = !logs.isEmpty

        logs.forEach { item in
            let row = makeRow(for: item)
            stackView.addArrangedSubview(row)
        }
    }

    private func setup() {
        backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func makeRow(for item: LogItem) -> UIView {
        let shadow = UIView()
        shadow.translatesAutoresizingMaskIntoConstraints = false
        shadow.layer.masksToBounds = false
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOpacity = 0.12
        shadow.layer.shadowRadius = 10
        shadow.layer.shadowOffset = CGSize(width: 0, height: 6)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.secondarySystemBackground
        card.layer.cornerRadius = 12
        card.layer.masksToBounds = true

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = .systemRed
        dot.layer.cornerRadius = 6

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.text = titleForType(item.type, poseType: item.poseType)

        let detailButton = UIButton(type: .system)
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.setTitle("상세보기", for: .normal)
        detailButton.setTitleColor(.orange, for: .normal)
        detailButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        detailButton.setImage(UIImage(systemName: "eye"), for: .normal)
        detailButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .regular), forImageIn: .normal)
        detailButton.tintColor = .orange
        detailButton.contentHorizontalAlignment = .trailing
        detailButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.onTapDetail?(item)
        }), for: .touchUpInside)

        let timeIcon = UIImageView(image: UIImage(systemName: "clock"))
        timeIcon.translatesAutoresizingMaskIntoConstraints = false
        timeIcon.tintColor = .secondaryLabel

        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = .label
        timeLabel.numberOfLines = 2
        timeLabel.font = .systemFont(ofSize: 14, weight: .regular)
        timeLabel.text = dateFormatter.string(from: item.timeStamp)

        let sectorIcon = UIImageView(image: UIImage(systemName: "camera"))
        sectorIcon.translatesAutoresizingMaskIntoConstraints = false
        sectorIcon.tintColor = .secondaryLabel

        let sectorLabel = UILabel()
        sectorLabel.translatesAutoresizingMaskIntoConstraints = false
        sectorLabel.textColor = .label
        sectorLabel.font = .systemFont(ofSize: 14, weight: .regular)
        sectorLabel.text = item.sector

        let badgeText: String
        if item.type == "위험자세", let score = item.score {
            badgeText = "\(Int(score))점"
        } else {
            badgeText = ""
        }
        let badge = makeBadge(text: badgeText)
        badge.isHidden = !(item.type == "위험자세" && item.score != nil)

        if let pose = item.poseType, let raw = item.score {
            let intScore = Int(raw)
            let colors = badgeColors(for: pose, score: intScore)
            badge.backgroundColor = colors.bgColor
            if let lbl = badge.subviews.first(where: { $0 is UILabel }) as? UILabel {
                lbl.textColor = colors.textColor
            }
        }

        let topRow = UIStackView(arrangedSubviews: [dot, titleLabel, UIView(), detailButton])
        topRow.translatesAutoresizingMaskIntoConstraints = false
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 8

        let timeRow = UIStackView(arrangedSubviews: [timeIcon, timeLabel])
        timeRow.axis = .horizontal
        timeRow.alignment = .center
        timeRow.spacing = 6

        let sectorRow = UIStackView(arrangedSubviews: [sectorIcon, sectorLabel])
        sectorRow.axis = .horizontal
        sectorRow.alignment = .center
        sectorRow.spacing = 6

        let bottomRow = UIStackView(arrangedSubviews: [timeRow, sectorRow, UIView(), badge])
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 16

        let vertical = UIStackView(arrangedSubviews: [topRow, bottomRow])
        vertical.translatesAutoresizingMaskIntoConstraints = false
        vertical.axis = .vertical
        vertical.alignment = .fill
        vertical.spacing = 14

        shadow.addSubview(card)
        card.addSubview(vertical)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: shadow.topAnchor),
            card.leadingAnchor.constraint(equalTo: shadow.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: shadow.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: shadow.bottomAnchor),

            vertical.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            vertical.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            vertical.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            vertical.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),

            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12)
        ])

        DispatchQueue.main.async { [weak shadow] in
            guard let sh = shadow else { return }
            sh.layer.shadowPath = UIBezierPath(roundedRect: sh.bounds, cornerRadius: 12).cgPath
        }

        detailButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.onTapDetail?(item)
        }), for: .touchUpInside)

        return shadow
    }

    private func titleForType(_ type: String, poseType: String? = nil) -> String {
        switch type {
        case "위험자세":
            if let pose = poseType, !pose.isEmpty {
                return "자세 위험(\(pose))"
            } else {
                return "자세 위험"
            }
        case "안전모": return "안전모 미착용"
        case "안전조끼": return "조끼 미착용"
        default: return type
        }
    }

    private func makeBadge(text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.orange.withAlphaComponent(0.12)
        container.layer.cornerRadius = 16

        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = text
        lb.textColor = .systemRed
        lb.font = .systemFont(ofSize: 12, weight: .semibold)

        container.addSubview(lb)
        NSLayoutConstraint.activate([
            lb.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            lb.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            lb.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            lb.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        return container
    }

    private func badgeColors(for poseType: String, score: Int) -> (bgColor: UIColor, textColor: UIColor) {
        let key = poseType.uppercased()
        var isOrange = false
        var isRed = false

        switch key {
        case "OWAS":
            isOrange = (score == 3)
            isRed = (score >= 4)
        case "RULA":
            isOrange = (score == 5 || score == 6)
            isRed = (score >= 7)
        case "REBA":
            isOrange = (score == 8 || score == 9 || score == 10)
            isRed = (score >= 11)
        default:
            isOrange = true
            isRed = false
        }

        if isRed {
            return (UIColor.systemRed.withAlphaComponent(0.15), UIColor.systemRed)
        } else if isOrange {
            return (UIColor.systemOrange.withAlphaComponent(0.15), UIColor.systemOrange)
        } else {
            return (UIColor.systemOrange.withAlphaComponent(0.12), UIColor.systemOrange)
        }
    }
}
