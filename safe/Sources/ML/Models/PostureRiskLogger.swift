//
//  PostureRiskLogger.swift
//  safe
//
//  Created by 신찬솔 on 8/18/25.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

final class PostureRiskLogger {
    static let shared = PostureRiskLogger()

    var sectorProvider: () -> String = { "" }
    var minInterval: TimeInterval = 10     // 동일 타입 연속 저장 쿨다운
    private var lastSavedAt: Date?

    func upload(image: UIImage, poseType: String, score: Int, completion: (() -> Void)? = nil) {
        if let t = lastSavedAt, Date().timeIntervalSince(t) < minInterval {
            completion?(); return
        }

        guard let data = image.pngData() else { completion?(); return }
        let storage = Storage.storage()
        let folder = "safetyLog/Posture"
        let df = DateFormatter(); df.dateFormat = "yyyyMMdd_HHmmss"
        let name = df.string(from: Date()) + "_" + UUID().uuidString + ".png"
        let ref = storage.reference().child(folder).child(name)

        ref.putData(data, metadata: nil) { _, err in
            guard err == nil else { completion?(); return }
            ref.downloadURL { url, err in
                guard err == nil, let url = url else { completion?(); return }

                let db = Firestore.firestore()
                let doc: [String: Any] = [
                    "imageUrl": url.absoluteString,
                    "poseType": poseType,       
                    "score": score,
                    "sector": self.sectorProvider(),
                    "timeStamp": Timestamp(date: Date()),
                    "type": "위험자세"
                ]
                db.collection("safetyLog").addDocument(data: doc) { _ in
                    self.lastSavedAt = Date()
                    completion?()
                }
            }
        }
    }
}
