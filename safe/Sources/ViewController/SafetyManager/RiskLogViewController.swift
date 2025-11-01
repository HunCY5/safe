//
//  RiskLogViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit
import FirebaseFirestore
import Kingfisher

// 위험로그로 이동 버튼으로 이동 시, 날짜를 오늘로 설정
extension Notification.Name {
    static let riskLogSetToday = Notification.Name("riskLogSetToday")
}

final class RiskLogViewController: UIViewController {
    private let riskLogView = RiskLogView()
    private var selectedDate = Date()
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    private lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "yyyy년 MM월 dd일"
        return f
    }()
    
    private lazy var dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    override func loadView() {
        view = riskLogView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "위험 로그"
        
        // 오늘 날짜로 초기 표시
        riskLogView.setDate(selectedDate)
        riskLogView.setDateButtonTarget(self, action: #selector(presentDatePicker))
        riskLogView.onDateChanged = { [weak self] date in
            guard let self = self else { return }
            self.selectedDate = date
            self.listenSafetyLog()
        }
        riskLogView.setLogDetailHandler { [weak self] item in
            guard
                let self = self,
                let urlStr = item.imageUrl,
                let url = URL(string: urlStr)
            else {
                let alert = UIAlertController(title: "이미지를 불러올 수 없습니다",
                                              message: "유효한 이미지 주소가 없습니다.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
                return
            }
            self.presentImageModal(url: url)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setTodayAndReload),
                                               name: .riskLogSetToday,
                                               object: nil)
        
        listenSafetyLog()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .riskLogSetToday, object: nil)
    }
    
    @objc private func setTodayAndReload() {
        // KST 기준 오늘로 설정
        let tz = TimeZone(identifier: "Asia/Seoul") ?? .current
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        let today = Date()
        selectedDate = today
        riskLogView.setDate(today)
        listenSafetyLog()
    }
    
    private func normalizeType(_ raw: String) -> String {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if s.contains("helmet") || s.contains("안전모") { return "안전모" }
        if s.contains("no-helmet") { return "안전모" }
        if s.contains("vest") || s.contains("조끼") || s.contains("안전조끼") { return "안전조끼" }
        if s.contains("no-vest") { return "안전조끼" }
        if s.contains("위험자세") || s.contains("posture") || s.contains("pose") { return "위험자세" }
        return raw
    }
    
    private func listenSafetyLog() {
        listener?.remove()
        
        listener = db.collection("safetyLog").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching safetyLog documents: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            
            var helmetCount = 0
            var vestCount = 0
            var postureCount = 0
            
            var logItems: [RiskLogCardView.LogItem] = []
            
            let selectedDateString = self.dayFormatter.string(from: self.selectedDate)
            
            for doc in documents {
                let data = doc.data()
                
                guard let type = data["type"] as? String,
                      let timestamp = data["timeStamp"] as? Timestamp else {
                    continue
                }
                
                let sector = data["sector"] as? String
                let poseType = data["poseType"] as? String
                let score = data["score"] as? Double
                let imageUrl = data["imageUrl"] as? String
                let logDate = self.dayFormatter.string(from: timestamp.dateValue())
                if logDate != selectedDateString {
                    continue
                }
                
                let normType = self.normalizeType(type)
                
                switch normType {
                case "위험자세":
                    postureCount += 1
                case "안전모":
                    helmetCount += 1
                case "안전조끼":
                    vestCount += 1
                default:
                    break
                }
                
                let item = RiskLogCardView.LogItem(
                    type: normType,
                    timeStamp: timestamp.dateValue(),
                    sector: sector ?? "-",
                    score: (normType == "위험자세") ? score : nil,
                    poseType: poseType ?? "",
                    imageUrl: imageUrl
                )
                logItems.append(item)
            }
            
            self.riskLogView.updateHelmetCount(helmetCount)
            self.riskLogView.updateVestCount(vestCount)
            self.riskLogView.updatePostureCount(postureCount)
            let sorted = logItems.sorted { $0.timeStamp > $1.timeStamp }
            self.riskLogView.updateLogItems(sorted)
        }
    }
    
    @objc private func presentDatePicker() {
        let alert = UIAlertController(title: "날짜 선택", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ko_KR")
        picker.timeZone = TimeZone(identifier: "Asia/Seoul")
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        picker.date = selectedDate
        picker.frame = CGRect(x: 0, y: 30, width: alert.view.bounds.width - 20, height: 200)
        alert.view.addSubview(picker)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "선택", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let newDate = picker.date
            self.selectedDate = newDate
            self.riskLogView.setDate(newDate)
            self.riskLogView.onDateChanged?(newDate)
        }))
        
        if let pop = alert.popoverPresentationController {
            pop.sourceView = self.view
            pop.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY - 1, width: 1, height: 1)
            pop.permittedArrowDirections = []
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentImageModal(url: URL) {
        let modalVC = UIViewController()
        modalVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.92)
        modalVC.modalPresentationStyle = .overFullScreen

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.kf.indicatorType = .activity

        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("닫기", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addAction(UIAction(handler: { [weak modalVC] _ in
            modalVC?.dismiss(animated: true)
        }), for: .touchUpInside)

        modalVC.view.addSubview(imageView)
        modalVC.view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: modalVC.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: modalVC.view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: modalVC.view.trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: modalVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -60),

            closeButton.centerXAnchor.constraint(equalTo: modalVC.view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: modalVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        let tapToClose = UITapGestureRecognizer(target: self, action: #selector(dismissTopMostModal))
        modalVC.view.addGestureRecognizer(tapToClose)

        present(modalVC, animated: true)

        imageView.kf.setImage(
            with: url,
            options: [.transition(.fade(0.2)), .cacheOriginalImage],
            completionHandler: { [weak modalVC] result in
                if case .failure(let error) = result {
                    let alert = UIAlertController(title: "이미지 로드 실패",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    modalVC?.present(alert, animated: true)
                }
            }
        )
    }

    @objc private func dismissTopMostModal() {
        presentedViewController?.dismiss(animated: true)
    }
    
    @objc func detailButtonTapped(_ sender: UIButton) {
        print("Detail button was tapped in RiskLogViewController")
    }
}
