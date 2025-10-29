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
    var repeatEverySeconds: TimeInterval = 5.0
    // 상태 추적
    private var nonHelmetStart: Date?
    private var nonVestStart: Date?
    private var didLogHelmet = false
    private var didLogVest = false
    private var isUploading = false

    // 마지막 촬영 시각(반복 주기 판단)
        private var lastLogTimeHelmet: Date?
        private var lastLogTimeVest: Date?

        var sectorProvider: () -> String = { "" }

        func handle(result r: PPEDetectionResult?,
                    baseFrame: UIImage?,
                    makePPEScreenshot: () -> UIImage?,
                    detectHelmet: Bool,
                    detectVest: Bool) {
            if !detectHelmet { resetHelmet() }
            if !detectVest { resetVest() }

            guard let r = r else {
                resetHelmet(); resetVest()
                return
            }
            let now = Date()

            // 위반 에피소드 시작/종료 추적
            if detectHelmet {
                if !r.helmetOK { if nonHelmetStart == nil { nonHelmetStart = now } }
                else { resetHelmet() }
            }
            if detectVest {
                if !r.vestOK { if nonVestStart == nil { nonVestStart = now } }
                else { resetVest() }
            }

            // 반복 로깅 결정 로직
            var types: [String] = []

            // 안전모
            if detectHelmet, let s = nonHelmetStart, now.timeIntervalSince(s) >= thresholdSeconds {
                // 처음이거나, 마지막 촬영 이후 repeatEverySeconds 경과
                let canRepeat = (lastLogTimeHelmet == nil) || (now.timeIntervalSince(lastLogTimeHelmet!) >= repeatEverySeconds)
                if !didLogHelmet || canRepeat {
                    types.append("안전모 미착용")
                    didLogHelmet = true
                }
            }

            // 안전조끼
            if detectVest, let s = nonVestStart, now.timeIntervalSince(s) >= thresholdSeconds {
                let canRepeat = (lastLogTimeVest == nil) || (now.timeIntervalSince(lastLogTimeVest!) >= repeatEverySeconds)
                if !didLogVest || canRepeat {
                    types.append("안전조끼 미착용")
                    didLogVest = true
                }
            }

            guard !types.isEmpty else { return }
            guard !isUploading else { return }

            guard baseFrame != nil, let shot = makePPEScreenshot(),
                  let data = shot.pngData() else { return }

            isUploading = true
            uploadAndLog(imageData: data, types: types) { [weak self] in
                guard let self = self else { return }
                // 업로드 완료 시각을 마지막 촬영 시각으로 기록
                let t = Date()
                if types.contains("안전모 미착용") { self.lastLogTimeHelmet = t }
                if types.contains("안전조끼 미착용") { self.lastLogTimeVest = t }
                self.isUploading = false
            }
        }

        // 마지막 촬영 시각도 함께 리셋
        private func resetHelmet() { nonHelmetStart = nil; didLogHelmet = false; lastLogTimeHelmet = nil }
        private func resetVest()   { nonVestStart = nil;   didLogVest = false;   lastLogTimeVest   = nil }

    // (removed duplicate sectorProvider, handle, resetHelmet, resetVest)
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
