//
//  SafetyManagerViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

final class SafetyManagerViewController: UIViewController {
    
    private enum UIConst {
        /// 카메라 아이콘 배지 크기
        static let cameraBadgeSize: CGFloat = 84
        /// 카메라 아이콘  크기
        static let cameraIconSize: CGFloat  = 80
        /// 공통 좌우 여백
        static let headerHInset: CGFloat    = 16

        // 발생한 위험로그, AI 탐지기능 배지/아이콘 크기
        /// 헤더 제목 왼쪽의 사각 배지 한 변 길이
        static let headerBadgeSize: CGFloat  = 40
        /// 헤더 제목 왼쪽 아이콘 크기
        static let headerIconSize: CGFloat   = 50
        /// 헤더 배지 모서리 라운드
        static let headerBadgeCorner: CGFloat = 10

        /// PPE(안전장비) 카드 아이콘 크기
        static let ppeIconSize: CGFloat = 40
        /// 자세 평가 카드 아이콘 크기
        static let postureIconSize: CGFloat = 24
        /// 카드 내부 아이콘(좌측)들의 정렬 기준을 맞추기 위한 슬롯(고정 폭 컨테이너) 너비
        static let contentIconSlotWidth: CGFloat = 28
    }
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    // 상단바
    private let topBar = UIView()
    private let siteTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "안전감시"
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textColor = .label
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let siteSubtitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "서울 건설현장 A동"
        lb.font = .systemFont(ofSize: 13, weight: .regular)
        lb.textColor = .secondaryLabel
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    // 아이콘
    private let cameraBadge = UIView()     // 카메라 아이콘 배경
    private let riskIconBadge = UIView()   // 위험로그 배경
    private let aiIconBadge = UIView()     // AI 탐지기능 배경
    
    // 발생한 위험로그 좌측 아이콘
    private let riskHeaderIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "warning")?.withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // CCTV 아이콘
    private let aiHeaderIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cctv")?.withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // 카메라 아이콘
    private let cameraIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let headerCard = UIView()
    private let headerTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "안전 감시 시작"
        lb.font = .systemFont(ofSize: 24, weight: .bold)
        lb.textAlignment = .center
        lb.textColor = .label
        lb.numberOfLines = 1
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let headerSubtitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "실시간 카메라 모니터링을 시작합니다"
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        lb.textAlignment = .center
        lb.textColor = .secondaryLabel
        lb.numberOfLines = 0
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private lazy var startButton: UIButton = {
        var cfg = UIButton.Configuration.filled()
        cfg.cornerStyle = .large
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        var title = AttributedString("안전 감시 시작")
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        cfg.attributedTitle = title
        
        let btn = UIButton(configuration: cfg)
        btn.tintColor = .systemOrange // filled 배경색
        btn.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // 위험로그 card
    private let riskCard = UIView()
    private let aiGroupCard = UIView()
    private let riskTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "발생한 위험로그"
        lb.font = .systemFont(ofSize: 18, weight: .semibold)
        lb.textColor = .label
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let riskSubtitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "3개의 위험 상황이 감지되었습니다"
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        lb.textColor = .secondaryLabel
        lb.numberOfLines = 0
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private lazy var riskMoveButton: UIButton = {
        var cfg = UIButton.Configuration.filled()
        cfg.cornerStyle = .large
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        var title = AttributedString("위험로그로 이동")
        title.font = .systemFont(ofSize: 15, weight: .semibold)
        cfg.attributedTitle = title
        
        let btn = UIButton(configuration: cfg)
        btn.tintColor = .systemRed
        btn.addTarget(self, action: #selector(didTapRiskLog), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = .secondarySystemBackground // 색상
        view.addSubview(topBar)
        
        let topTextStack = UIStackView(arrangedSubviews: [siteTitleLabel, siteSubtitleLabel])
        topTextStack.axis = .vertical
        topTextStack.alignment = .leading
        topTextStack.spacing = 2
        topTextStack.translatesAutoresizingMaskIntoConstraints = false
        
        topBar.addSubview(topTextStack)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            topTextStack.topAnchor.constraint(equalTo: topBar.topAnchor, constant: 12),
            topTextStack.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            topTextStack.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            topTextStack.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -12)
        ])
        
        setupLayout()
    }
    
    // MARK: - action
    
    @objc private func didTapStart() {
        let vc = YOLOCameraViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapRiskLog() {
        let vc = LiskLogViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 레이아웃
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
        
        configureCard(headerCard)
        
        // 카메라 배지 옵션
        cameraBadge.translatesAutoresizingMaskIntoConstraints = false
        cameraBadge.backgroundColor = UIColor(red: 1.0, green: 0.73, blue: 0.36, alpha: 0.18)
        cameraBadge.layer.cornerRadius = UIConst.cameraBadgeSize / 2 // 84x84 기준
        cameraBadge.layer.masksToBounds = true
        
        cameraIconView.tintColor = .systemOrange
        cameraBadge.addSubview(cameraIconView)
        NSLayoutConstraint.activate([
            cameraIconView.centerXAnchor.constraint(equalTo: cameraBadge.centerXAnchor),
            cameraIconView.centerYAnchor.constraint(equalTo: cameraBadge.centerYAnchor),
            cameraIconView.widthAnchor.constraint(equalToConstant: UIConst.cameraIconSize),
            cameraIconView.heightAnchor.constraint(equalToConstant: UIConst.cameraIconSize),
        ])
        
        let headerInner = UIStackView(arrangedSubviews: [cameraBadge, headerTitleLabel, headerSubtitleLabel, startButton])
        headerInner.axis = .vertical
        headerInner.spacing = 12
        headerInner.alignment = .center
        headerInner.translatesAutoresizingMaskIntoConstraints = false
        
        headerCard.addSubview(headerInner)
        contentStack.addArrangedSubview(headerCard)
        
        NSLayoutConstraint.activate([
            cameraBadge.widthAnchor.constraint(equalToConstant: UIConst.cameraBadgeSize),
            cameraBadge.heightAnchor.constraint(equalToConstant: UIConst.cameraBadgeSize),
            
            startButton.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            
            headerInner.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 24),
            headerInner.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            headerInner.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            headerInner.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -24)
        ])
        
        configureCard(riskCard)
        
        // 위험로그 아이콘/배지 옵션
        riskIconBadge.translatesAutoresizingMaskIntoConstraints = false
        riskIconBadge.backgroundColor = UIColor(red: 1.0, green: 0.90, blue: 0.93, alpha: 1.0)
        riskIconBadge.layer.cornerRadius = UIConst.headerBadgeCorner
        riskIconBadge.layer.masksToBounds = true
        
        riskHeaderIconView.tintColor = .systemRed
        riskIconBadge.addSubview(riskHeaderIconView)
        NSLayoutConstraint.activate([
            riskHeaderIconView.centerXAnchor.constraint(equalTo: riskIconBadge.centerXAnchor),
            riskHeaderIconView.centerYAnchor.constraint(equalTo: riskIconBadge.centerYAnchor),
            riskHeaderIconView.widthAnchor.constraint(equalToConstant: UIConst.headerIconSize),
            riskHeaderIconView.heightAnchor.constraint(equalToConstant: UIConst.headerIconSize),
        ])
        
        let riskTop = UIStackView(arrangedSubviews: [riskIconBadge, riskTitleLabel, UIView()])
        riskTop.axis = .horizontal
        riskTop.alignment = .center
        riskTop.spacing = 10
        
        let riskInner = UIStackView(arrangedSubviews: [riskTop, riskSubtitleLabel, riskMoveButton])
        riskInner.axis = .vertical
        riskInner.spacing = 12
        riskInner.alignment = .fill
        riskInner.translatesAutoresizingMaskIntoConstraints = false
        
        riskCard.addSubview(riskInner)
        contentStack.addArrangedSubview(riskCard)
        
        NSLayoutConstraint.activate([
            riskInner.topAnchor.constraint(equalTo: riskCard.topAnchor, constant: 20),
            riskInner.leadingAnchor.constraint(equalTo: riskCard.leadingAnchor, constant: 16),
            riskInner.trailingAnchor.constraint(equalTo: riskCard.trailingAnchor, constant: -16),
            riskInner.bottomAnchor.constraint(equalTo: riskCard.bottomAnchor, constant: -20),
            
            riskMoveButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            riskIconBadge.widthAnchor.constraint(equalToConstant: UIConst.headerBadgeSize),
            riskIconBadge.heightAnchor.constraint(equalToConstant: UIConst.headerBadgeSize)
        ])
        
        // MARK: - AI 탐지기능 카드
        configureCard(aiGroupCard)
        let aiGroupStack = UIStackView()
        aiGroupStack.axis = .vertical
        aiGroupStack.spacing = 12
        aiGroupStack.alignment = .fill
        aiGroupStack.translatesAutoresizingMaskIntoConstraints = false
        aiGroupCard.addSubview(aiGroupStack)
        contentStack.addArrangedSubview(aiGroupCard)

        // AI 탐지기능 헤더 아이콘/배지 옵션
        
        aiIconBadge.translatesAutoresizingMaskIntoConstraints = false
        aiIconBadge.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 1.0, alpha: 1.0)
        aiIconBadge.layer.cornerRadius = UIConst.headerBadgeCorner
        aiIconBadge.layer.masksToBounds = true
        aiHeaderIconView.tintColor = .systemBlue
        aiIconBadge.addSubview(aiHeaderIconView)
        NSLayoutConstraint.activate([
            aiHeaderIconView.centerXAnchor.constraint(equalTo: aiIconBadge.centerXAnchor),
            aiHeaderIconView.centerYAnchor.constraint(equalTo: aiIconBadge.centerYAnchor),
            aiHeaderIconView.widthAnchor.constraint(equalToConstant: UIConst.headerIconSize),
            aiHeaderIconView.heightAnchor.constraint(equalToConstant: UIConst.headerIconSize),
        ])

        let aiHeaderTitle = UILabel()
        aiHeaderTitle.text = "AI 탐지기능"
        aiHeaderTitle.font = .systemFont(ofSize: 22, weight: .bold)
        aiHeaderTitle.textColor = .label

        let aiHeaderSubtitle = UILabel()
        aiHeaderSubtitle.text = "카메라를 통한 실시간 안전 모니터링"
        aiHeaderSubtitle.font = .systemFont(ofSize: 13, weight: .regular)
        aiHeaderSubtitle.textColor = .secondaryLabel
        aiHeaderSubtitle.numberOfLines = 0

        let aiHeaderRow = UIStackView(arrangedSubviews: [aiIconBadge, aiHeaderTitle, UIView()])
        aiHeaderRow.axis = .horizontal
        aiHeaderRow.alignment = .center
        aiHeaderRow.spacing = 10

        aiGroupStack.addArrangedSubview(aiHeaderRow)
        aiGroupStack.addArrangedSubview(aiHeaderSubtitle)

        NSLayoutConstraint.activate([
            aiIconBadge.widthAnchor.constraint(equalToConstant: UIConst.headerBadgeSize),
            aiIconBadge.heightAnchor.constraint(equalToConstant: UIConst.headerBadgeSize),
            
            aiGroupStack.topAnchor.constraint(equalTo: aiGroupCard.topAnchor, constant: 16),
            aiGroupStack.leadingAnchor.constraint(equalTo: aiGroupCard.leadingAnchor, constant: 16),
            aiGroupStack.trailingAnchor.constraint(equalTo: aiGroupCard.trailingAnchor, constant: -16),
            aiGroupStack.bottomAnchor.constraint(equalTo: aiGroupCard.bottomAnchor, constant: -16)
        ])

        // 내부 미니 카드
        
        // PPE 카드
        let ppeMini = UIView()
        ppeMini.backgroundColor = UIColor(red: 1.0, green: 0.94, blue: 0.90, alpha: 1.0) // 연오렌지
        ppeMini.layer.cornerRadius = 12
        ppeMini.translatesAutoresizingMaskIntoConstraints = false

        // PPE 아이콘
        let ppeIcon = UIImageView(image: UIImage(named: "ppe")?.withRenderingMode(.alwaysTemplate))
        ppeIcon.tintColor = .systemOrange
        ppeIcon.contentMode = .scaleAspectFit
        ppeIcon.translatesAutoresizingMaskIntoConstraints = false

        let ppeTitle = UILabel()
        ppeTitle.text = "안전장비 착용 탐지"
        ppeTitle.font = .systemFont(ofSize: 17, weight: .semibold)
        ppeTitle.textColor = .label

        let ppeSubtitle = UILabel()
        ppeSubtitle.text = "YOLO 딥러닝 모델 활용"
        ppeSubtitle.font = .systemFont(ofSize: 13, weight: .regular)
        ppeSubtitle.textColor = .secondaryLabel

        let ppeB1 = bulletLabel("안전모 착용 유무 실시간 감지")
        let ppeB2 = bulletLabel("안전조끼 착용 상태 모니터링")
        let ppeB3 = bulletLabel("미착용 시 즉시 알림 발송")

        // [정렬 규칙] PNG(Assets)와 SF Symbols의 내부 여백 차이를 제거하기 위해 고정 폭 슬롯을 사용
        // 좌측 아이콘을 고정 폭 슬롯에 넣어 PNG/SF 차이와 무관하게 동일 시작선을 맞춤
        let ppeIconSlot = UIView()
        ppeIconSlot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ppeIconSlot.widthAnchor.constraint(equalToConstant: UIConst.contentIconSlotWidth),
            ppeIconSlot.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConst.ppeIconSize)
        ])
        ppeIconSlot.addSubview(ppeIcon)
        NSLayoutConstraint.activate([
            ppeIcon.centerXAnchor.constraint(equalTo: ppeIconSlot.centerXAnchor),
            ppeIcon.centerYAnchor.constraint(equalTo: ppeIconSlot.centerYAnchor)
        ])

        let ppeHeaderRow = UIStackView(arrangedSubviews: [ppeIconSlot, ppeTitle, UIView()])
        ppeHeaderRow.axis = .horizontal
        ppeHeaderRow.spacing = 8
        ppeHeaderRow.alignment = .center

        let ppeStack = UIStackView(arrangedSubviews: [ppeHeaderRow, ppeSubtitle, ppeB1, ppeB2, ppeB3])
        ppeStack.axis = .vertical
        ppeStack.spacing = 8
        ppeStack.translatesAutoresizingMaskIntoConstraints = false

        ppeMini.addSubview(ppeStack)
        aiGroupStack.addArrangedSubview(ppeMini)

        NSLayoutConstraint.activate([
            ppeStack.topAnchor.constraint(equalTo: ppeMini.topAnchor, constant: 16),
            ppeStack.leadingAnchor.constraint(equalTo: ppeMini.leadingAnchor, constant: 16),
            ppeStack.trailingAnchor.constraint(equalTo: ppeMini.trailingAnchor, constant: -16),
            ppeStack.bottomAnchor.constraint(equalTo: ppeMini.bottomAnchor, constant: -16),
            ppeIcon.widthAnchor.constraint(equalToConstant: UIConst.ppeIconSize),    // PPE 아이콘 너비
            ppeIcon.heightAnchor.constraint(equalToConstant: UIConst.ppeIconSize)   // PPE 아이콘 높이
        ])

        // 자세 평가 카드
        let postureMini = UIView()
        postureMini.backgroundColor = UIColor(red: 0.91, green: 0.96, blue: 1.0, alpha: 1.0)
        postureMini.layer.cornerRadius = 12
        postureMini.translatesAutoresizingMaskIntoConstraints = false

        // 자세 평가 카드 좌측 아이콘
        let postureIcon = UIImageView(image: UIImage(systemName: "figure.walk"))
        postureIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        postureIcon.tintColor = .systemBlue
        postureIcon.translatesAutoresizingMaskIntoConstraints = false

        let postureTitle = UILabel()
        postureTitle.text = "근로자 자세 평가"
        postureTitle.font = .systemFont(ofSize: 17, weight: .semibold)
        postureTitle.textColor = .label

        let postureSubtitle = UILabel()
        postureSubtitle.text = "PoseNet & MoveNet 기반 분석"
        postureSubtitle.font = .systemFont(ofSize: 13, weight: .regular)
        postureSubtitle.textColor = .secondaryLabel

        let postureB1 = bulletLabel("OWAS 공식을 통한 작업 자세 위험도 평가")
        let postureB2 = bulletLabel("REBA 분석으로 근골격계 부담 측정")
        let postureB3 = bulletLabel("RULA 평가를 통한 상지 작업 위험성 분석")

        // 두 카드의 좌측 아이콘 시작선을 동일하게 맞추기 위해 고정 폭 슬롯 사용
        // 좌측 아이콘을 고정 폭 슬롯에 넣어 PNG/SF 차이와 무관하게 동일 시작선을 맞춤
        let postureIconSlot = UIView()
        postureIconSlot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postureIconSlot.widthAnchor.constraint(equalToConstant: UIConst.contentIconSlotWidth),
            postureIconSlot.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConst.postureIconSize)
        ])
        postureIcon.contentMode = .scaleAspectFit
        postureIconSlot.addSubview(postureIcon)
        NSLayoutConstraint.activate([
            postureIcon.centerXAnchor.constraint(equalTo: postureIconSlot.centerXAnchor),
            postureIcon.centerYAnchor.constraint(equalTo: postureIconSlot.centerYAnchor)
        ])

        let postureHeaderRow = UIStackView(arrangedSubviews: [postureIconSlot, postureTitle, UIView()])
        postureHeaderRow.axis = .horizontal
        postureHeaderRow.spacing = 8
        postureHeaderRow.alignment = .center

        let postureStack = UIStackView(arrangedSubviews: [postureHeaderRow, postureSubtitle, postureB1, postureB2, postureB3])
        postureStack.axis = .vertical
        postureStack.spacing = 8
        postureStack.translatesAutoresizingMaskIntoConstraints = false

        postureMini.addSubview(postureStack)
        aiGroupStack.addArrangedSubview(postureMini)

        NSLayoutConstraint.activate([
            postureStack.topAnchor.constraint(equalTo: postureMini.topAnchor, constant: 16),
            postureStack.leadingAnchor.constraint(equalTo: postureMini.leadingAnchor, constant: 16),
            postureStack.trailingAnchor.constraint(equalTo: postureMini.trailingAnchor, constant: -16),
            postureStack.bottomAnchor.constraint(equalTo: postureMini.bottomAnchor, constant: -16),
            postureIcon.widthAnchor.constraint(equalToConstant: UIConst.postureIconSize), // ← 자세 아이콘 크기(너비)
            postureIcon.heightAnchor.constraint(equalToConstant: UIConst.postureIconSize)  // ← 자세 아이콘 크기(높이)
        ])
    }
    
    private func configureCard(_ v: UIView) {
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 14
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func bulletLabel(_ text: String) -> UIStackView {
        let dot = UILabel()
        dot.text = "•"
        dot.font = .systemFont(ofSize: 14, weight: .bold)
        dot.textColor = .tertiaryLabel
        let lb = UILabel()
        lb.text = text
        lb.font = .systemFont(ofSize: 14)
        lb.textColor = .label
        lb.numberOfLines = 0
        let row = UIStackView(arrangedSubviews: [dot, lb])
        row.axis = .horizontal
        row.spacing = 6
        row.alignment = .top
        return row
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = view.safeAreaInsets.bottom + 8
        scrollView.contentInset.bottom = bottomInset
        scrollView.scrollIndicatorInsets.bottom = bottomInset
    }
}
