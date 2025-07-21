//
//  PoseAngle.swift
//  safe
//
//  Created by 신찬솔 on 7/22/25.
//

import Foundation
import CoreGraphics

enum PoseAngle {
    static func angle(between a: CGPoint, and b: CGPoint, and c: CGPoint) -> CGFloat {
        let ab = CGVector(dx: b.x - a.x, dy: b.y - a.y)
        let cb = CGVector(dx: b.x - c.x, dy: b.y - c.y)

        let dotProduct = ab.dx * cb.dx + ab.dy * cb.dy
        let magnitudeAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy)
        let magnitudeCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy)

        guard magnitudeAB > 0, magnitudeCB > 0 else {
            return 0
        }

        let cosineAngle = dotProduct / (magnitudeAB * magnitudeCB)
        let angle = acos(min(max(cosineAngle, -1.0), 1.0))

        return angle * 180 / .pi
    }

    static func measureJointAngles(from keypoints: [KeyPoint]) {
        struct Static {
            static var lastLoggedTime: Date = .distantPast
        }

        let now = Date()
        if now.timeIntervalSince(Static.lastLoggedTime) < 5.0 {
            return
        }

        Static.lastLoggedTime = now

        let kpDict = Dictionary(uniqueKeysWithValues: keypoints.map { ($0.bodyPart, $0.coordinate) })

        guard let shoulder = kpDict[.leftShoulder],
              let elbow = kpDict[.leftElbow],
              let wrist = kpDict[.leftWrist],
              let rightShoulder = kpDict[.rightShoulder],
              let rightElbow = kpDict[.rightElbow],
              let rightWrist = kpDict[.rightWrist],
              let leftHip = kpDict[.leftHip],
              let rightHip = kpDict[.rightHip],
              let leftKnee = kpDict[.leftKnee],
              let rightKnee = kpDict[.rightKnee],
              let leftAnkle = kpDict[.leftAnkle],
              let rightAnkle = kpDict[.rightAnkle] else {
            print("⚠️ 일부 관절 포인트가 누락되었습니다.")
            return
        }

        guard let nose = kpDict[.nose],
              let leftEar = kpDict[.leftEar],
              let rightEar = kpDict[.rightEar] else {
            print("⚠️ 귀 포인트가 누락되었습니다.")
            return
        }

        // 목 중심 기준선 (어깨 중앙)
        let shoulderCenter = CGPoint(x: (shoulder.x + rightShoulder.x) / 2,
                                     y: (shoulder.y + rightShoulder.y) / 2)
        // 얼굴 중심 (귀 사이 중간)
        let faceCenter = CGPoint(x: (leftEar.x + rightEar.x) / 2,
                                 y: (leftEar.y + rightEar.y) / 2)

        // 수직 기준점을 어깨 아래 방향으로 임의 설정 (y+ 방향)
        let verticalDown = CGPoint(x: shoulderCenter.x, y: shoulderCenter.y + 100)

        let neckAngle = 180 - angle(between: verticalDown, and: shoulderCenter, and: faceCenter)
        print("💡 목 각도 (정면 기준): \(neckAngle)도")

        // 왼팔
        let leftElbowAngle = 180 - angle(between: shoulder, and: elbow, and: wrist)
        print("💡 왼팔 (어깨-팔꿈치-손목) 관절 각도: \(leftElbowAngle)도")

        // 오른팔
        let rightElbowAngle = 180 - angle(between: rightShoulder, and: rightElbow, and: rightWrist)
        print("💡 오른팔 (어깨-팔꿈치-손목) 관절 각도: \(rightElbowAngle)도")

        // 허리 (좌우 평균 각도: 왼어깨-왼엉덩이-왼발목, 오른어깨-오른엉덩이-오른발목)
        // 어깨 각도
        let leftShoulderAngle = angle(between: leftHip, and: shoulder, and: elbow)
        print("💡 왼쪽 어깨 (엉덩이-어깨-팔꿈치) 관절 각도: \(leftShoulderAngle)도")

        let rightShoulderAngle = angle(between: rightHip, and: rightShoulder, and: rightElbow)
        print("💡 오른쪽 어깨 (엉덩이-어깨-팔꿈치) 관절 각도: \(rightShoulderAngle)도")

        let leftWaistAngle = angle(between: shoulder, and: leftHip, and: leftAnkle)
        let rightWaistAngle = angle(between: rightShoulder, and: rightHip, and: rightAnkle)
        let waistAngle = 180 - (leftWaistAngle + rightWaistAngle) / 2
        print("💡 허리 평균 각도 (좌우): \(waistAngle)도")

        // 왼다리
        let leftKneeAngle = 180 - angle(between: leftHip, and: leftKnee, and: leftAnkle)
        print("💡 왼다리 (엉덩이-무릎-발목) 관절 각도: \(leftKneeAngle)도")

        // 오른다리
        let rightKneeAngle = 180 - angle(between: rightHip, and: rightKnee, and: rightAnkle)
        print("💡 오른다리 (엉덩이-무릎-발목) 관절 각도: \(rightKneeAngle)도")
    }
}
