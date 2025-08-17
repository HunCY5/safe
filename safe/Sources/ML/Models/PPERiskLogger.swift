//
//  PPERiskLogger.swift
//  safe
//
//  Created by CHOI on 8/18/25.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

final class PPERiskLogger {
    // 미착용 지속 시간(초)
    var thresholdSeconds: TimeInterval = 5.0
    // 상태 추적
    private var nonHelmetStart: Date?
    private var nonVestStart: Date?
    private var didLogHelmet = false
    private var didLogVest = false
    private var isUploading = false


    var sectorProvider: () -> String = { "" }


    func handle(result r: PPEDetectionResult?,
                baseFrame: UIImage?,
                makePPEScreenshot: () -> UIImage?,
                detectHelmet: Bool,
                detectVest: Bool) {
        // 선택 해제된 PPE는 미착용 로그 생성 X
        if !detectHelmet { resetHelmet() }
        if !detectVest { resetVest() }

        guard let r = r else {
            resetHelmet(); resetVest()
            return
        }
        let now = Date()

        // 헬멧
        if detectHelmet {
            if !r.helmetOK {
                if nonHelmetStart == nil { nonHelmetStart = now }
            } else {
                resetHelmet()
            }
        }
        // 조끼
        if detectVest {
            if !r.vestOK {
                if nonVestStart == nil { nonVestStart = now }
            } else {
                resetVest()
            }
        }

        var types: [String] = []
        // 시간 지정
        if detectHelmet,
           let s = nonHelmetStart,
           now.timeIntervalSince(s) >= thresholdSeconds, !didLogHelmet {
            types.append("안전모 미착용"); didLogHelmet = true
        }
        if detectVest,
           let s = nonVestStart, now.timeIntervalSince(s) >= thresholdSeconds, !didLogVest {
            types.append("안전조끼 미착용"); didLogVest = true
        }
        guard !types.isEmpty else { return }
        guard !isUploading else { return }

        // 스냅샷 생성 요청
        guard baseFrame != nil, let shot = makePPEScreenshot(),
              let data = shot.pngData() else { return }

        isUploading = true
        uploadAndLog(imageData: data, types: types) { [weak self] in self?.isUploading = false }
    }

    private func resetHelmet() { nonHelmetStart = nil; didLogHelmet = false }
    private func resetVest()   { nonVestStart = nil;   didLogVest = false }

    private func uploadAndLog(imageData: Data, types: [String], completion: @escaping () -> Void) {
        let storage = Storage.storage()
        let folder = "safetyLog/PPEDetection"
        let fmt = DateFormatter(); fmt.dateFormat = "yyyyMMdd_HHmmss"
        let name = fmt.string(from: Date()) + "_" + UUID().uuidString + ".png"
        let ref = storage.reference().child(folder).child(name)

        ref.putData(imageData, metadata: nil) { _, err in
            guard err == nil else { completion(); return }
            ref.downloadURL { url, err in
                guard err == nil, let url = url else { completion(); return }
                let db = Firestore.firestore()
                let sector = self.sectorProvider()
                let now = Timestamp(date: Date())
                let group = DispatchGroup()

                for t in types {
                    group.enter()
                    db.collection("safetyLog").addDocument(data: [
                        "sector": sector,
                        "imageUrl": url.absoluteString,
                        "timeStamp": now,
                        "type": t
                    ]) { _ in group.leave() }
                }
                group.notify(queue: .main) { completion() }
            }
        }
    }
}
