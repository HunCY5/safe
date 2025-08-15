//
//  RiskLogViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit
import FirebaseFirestore

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

        riskLogView.setDate(selectedDate) // 기본 텍스트: 현재 날짜
        riskLogView.setDateButtonTarget(self, action: #selector(presentDatePicker))
        riskLogView.onDateChanged = { [weak self] date in
            guard let self = self else { return }
            self.selectedDate = date
            self.listenSafetyLog()
        }
        
        listenSafetyLog()
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
                let logDate = self.dayFormatter.string(from: timestamp.dateValue())
                if logDate != selectedDateString {
                    continue
                }
                
                switch type {
                case "위험자세":
                    postureCount += 1
                case "안전모":
                    helmetCount += 1
                case "안전조끼":
                    vestCount += 1
                default:
                    break
                }
                
            }
            
            self.riskLogView.updateHelmetCount(helmetCount)
            self.riskLogView.updateVestCount(vestCount)
            self.riskLogView.updatePostureCount(postureCount)
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
}
