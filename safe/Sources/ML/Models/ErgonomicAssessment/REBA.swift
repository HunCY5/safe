//
//  REBA.swift
//  safe
//
//  Created by 신찬솔 on 7/23/25.
//

import Foundation
import CoreGraphics
import UIKit
import Combine

struct REBAEvaluator {
    static var selectedWeight: Int = 0
    private static var weightSubscriber: AnyCancellable?

    static func setWeightBinding(from publisher: Published<Int>.Publisher) {
        weightSubscriber = publisher
            .receive(on: DispatchQueue.main)
            .sink { newWeight in
                selectedWeight = newWeight
            }
    }
    
    static func rebaEvaluate(from angles: JointAngles, keypoints: [BodyPart: CGPoint]? = nil) -> Int {
        // Neck score (adjusted for relaxed sensitivity)
        var neckScore: Int
        if angles.neck < 10 {
            neckScore = 1
        } else if angles.neck < 40 {
            neckScore = 2
        } else {
            neckScore = 3
        }
        
        
        // Trunk score
        var trunkScore: Int
        if angles.trunk < 10 {
            trunkScore = 1
        } else if angles.trunk < 30 {
            trunkScore = 2
        } else if angles.trunk < 60 {
            trunkScore = 3
        }
        else {
            trunkScore = 4
        }
        
        if let keypoints = keypoints,
           let trunkBending = TwistAndBending.detectTrunkBending(from: keypoints) {
            neckScore += trunkBending
        }
        
        // Leg score
        let legLeft = angles.legLeft
        let legRight = angles.legRight
        
        var legScore: Int = 1
        if legLeft < 10 && legRight < 10 {
            legScore = 1
        } else if (legLeft >= 30 && legRight < 10) || (legRight >= 30 && legLeft < 10) {
            legScore = 2
        } else if (legLeft >= 30 && legLeft <= 60) || (legRight >= 30 && legRight <= 60) {
            legScore = 2
        } else if legLeft > 60 || legRight > 60 {
            legScore = 3
        }
        
        // Adjustment: both knees between 30–60 → +1, both knees >60 → +2
        if (legLeft >= 30 && legLeft <= 60) && (legRight >= 30 && legRight <= 60) {
            legScore += 1
        }
        if legLeft > 60 && legRight > 60 {
            legScore += 2
        }
        
        // Upper Arm score
        let upperArmScore: Int
        if angles.upperArm < 30 {
            upperArmScore = 1
        } else if angles.upperArm < 45 {
            upperArmScore = 2
        } else if angles.upperArm < 90 {
            upperArmScore = 3
        } else {
            upperArmScore = 4
        }
        
        // Lower Arm score
        let lowerArmScore = (angles.lowerArm >= 60 && angles.lowerArm <= 100) ? 1 : 2
        
        // Wrist score
        let wristScore = 1
        
       // 근로자가 들고 있는 무게에 대한 점수 가중치(A)
        var weightScore: Int = 0
        switch selectedWeight {
        case 0..<5:
            weightScore = 0
        case 5...10:
            weightScore = 1
        default:
            weightScore = 2
        }
        
        if let keypoints = keypoints {
            if let headTwist = TwistAndBending.detectHeadTwist(from: keypoints) {
                neckScore += headTwist
            }
            if let headBending = TwistAndBending.detectHeadBending(from: keypoints) {
                neckScore += headBending
            }
            if let trunkBending = TwistAndBending.detectTrunkBending(from: keypoints) {
                trunkScore += trunkBending
            }
        }
        
        let couplingScore = 0 // 근로자가 물체를 어떻게 잡고있는지에 대한 점수 가중치(B)
        // 0점: 박스에 양쪽 손잡이가 있어 파워그립으로 쉽게 들 수 있음
        // +1점: 들 수는 있으나 손잡이가 작거나 다른 부위(예: 팔꿈치, 허벅지)를 같이 써야 함
        // +2점: 손잡이 없음. 그냥 물체를 끌어안거나 손바닥 전체로 받쳐야 함
        // +3점: 물체 표면이 미끄럽거나, 불균형해서 안전하게 잡기 힘듦

        
        // Table A: Neck + Trunk + Leg
        let scoreA = rebaTableA(neck: neckScore, trunk: trunkScore,leg: legScore) + weightScore
        // Table B: Upper + Lower + Wrist
        let scoreB = rebaTableB(upper: upperArmScore, lower: lowerArmScore, wrist: wristScore) + couplingScore
        // Table C mapping (simplified risk lookup)
        return rebaTableC(scoreA: scoreA, scoreB: scoreB)
    }
    
    private static func rebaTableA(neck: Int, trunk: Int, leg: Int) -> Int {
        let neckIndex = min(max(neck - 1, 0), 2)
        let trunkIndex = min(max(trunk - 1, 0), 4)
        let legIndex = min(max(leg - 1, 0), 3)
        
        let tableA = [
            [[1,2,3,4], [1,2,3,4], [3,3,5,6]],
            [[2,3,4,5], [3,4,5,6], [4,5,6,7]],
            [[2,4,5,6], [4,5,6,7], [5,6,7,8]],
            [[3,5,6,7], [5,6,7,8], [6,7,8,9]],
            [[4,6,7,8], [6,7,8,9], [7,8,9,9]]
        ]
        
        return tableA[trunkIndex][neckIndex][legIndex]
    }
    
    private static func rebaTableB(upper: Int, lower: Int, wrist: Int) -> Int {
        let lowerIndex = min(max(lower - 1, 0), 1)
        let wristIndex = min(max(wrist - 1, 0), 2)
        let upperIndex = min(max(upper - 1, 0), 5)
        
        let tableB = [
            [[1, 2, 2], [1, 2, 3]],
            [[1, 2, 3], [2, 3, 4]],
            [[3, 4, 5], [4, 5, 5]],
            [[4, 5, 5], [5, 6, 7]],
            [[6, 7, 8], [7, 8, 8]],
            [[7, 8, 8], [8, 9, 9]]
        ]
        
        return tableB[upperIndex][lowerIndex][wristIndex]
    }
    
    private static func rebaTableC(scoreA: Int, scoreB: Int) -> Int {
        let row = min(max(scoreA - 1, 0), 11)
        let col = min(max(scoreB - 1, 0), 11)
        
        let tableC: [[Int]] = [
            [1, 1, 1, 2, 3, 3, 4, 5, 6, 7, 7, 7],
            [1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 7, 8],
            [2, 3, 3, 3, 4, 5, 6, 7, 7, 8, 8, 8],
            [3, 4, 4, 4, 5, 6, 7, 8, 8, 9, 9, 9],
            [4, 4, 4, 5, 6, 7, 8, 8, 9, 9, 9, 9],
            [6, 6, 6, 7, 8, 8, 9, 9, 10, 10, 10, 10],
            [7, 7, 7, 8, 9, 9, 9, 10, 10, 11, 11, 11],
            [8, 8, 8, 9, 10, 10, 10, 10, 10, 11, 11, 11],
            [9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12],
            [10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 12],
            [11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12],
            [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12]
        ]
        
        return tableC[row][col]
    }
    
    
    static var buffer = PostureEvaluatorBuffer()

    static func evaluateAndSummarize(from angles: JointAngles) -> (String, UIColor, Int)? {
        buffer.append(angles)

        guard buffer.isReady() else {
            return nil
        }

        let averaged = buffer.averagedAngles()
        // 정적 자세 판정: 평균 전 1분간의 버퍼를 사용
        let isStatic = isStaticPosture(in: buffer.buffer)
        let isRepetitive = isRepetitive(in: buffer.buffer)
        buffer.reset()

        var score = rebaEvaluate(from: averaged)
        if isStatic {
            score += 1
        }
        if isRepetitive {
            score += 1
        }
        let (label, color) = evaluateSummary(from: averaged)
        return (label, color, score)
    }
    
    
    private static func evaluateSummary(from angles: JointAngles) -> (String, UIColor) {
        let score = rebaEvaluate(from: angles)
        
        switch score {
        case 1:
            return ("무시해도 좋음 (조치: 필요 없음)", .systemGreen)
        case 2...3:
            return ("낮음 (조치: 필요할지도 모름)", .systemYellow)
        case 4...7:
            return ("보통 (조치: 필요함)", .systemOrange)
        case 8...10:
            return ("높음 (조치: 곧 필요함)", .systemRed)
        case 11...15:
            return ("매우 높음 (조치: 지금 즉시 필요함)", .systemRed)
        default:
            return ("알 수 없음", .gray)
        }
    }
    
    
    // 1분간의 JointAngles 버퍼에서 각도 변화가 적으면 정적자세로 간주
    private static func isStaticPosture(in values: [JointAngles], threshold: CGFloat = 5.0) -> Bool {
        guard values.count >= 30 else { return false }  // 2초 간격 * 30 = 1분

        let necks = values.map { $0.neck }
        let trunks = values.map { $0.trunk }
        let upperArms = values.map { $0.upperArm }

        guard let neckMax = necks.max(), let neckMin = necks.min(),
              let trunkMax = trunks.max(), let trunkMin = trunks.min(),
              let armMax = upperArms.max(), let armMin = upperArms.min() else {
            return false
        }

        let neckRange = neckMax - neckMin
        let trunkRange = trunkMax - trunkMin
        let armRange = armMax - armMin

        return neckRange < threshold && trunkRange < threshold && armRange < threshold
    }

    // 반복 동작 감지: 다리를 제외한 모든 관절(upperArm, lowerArm, neck, trunk)에 대해 확인, 하나라도 반복성 감지 시 true 반환
    private static func isRepetitive(in values: [JointAngles], threshold: CGFloat = 5.0, minRepeats: Int = 4) -> Bool {
        guard values.count >= 2 else { return false }

        let jointAngleSequences: [[CGFloat]] = [
            values.map { $0.upperArm },
            values.map { $0.lowerArm },
            values.map { $0.neck },
            values.map { $0.trunk },
        ]

        for jointAngles in jointAngleSequences {
            var repeatCount = 0
            for i in 1..<jointAngles.count {
                let diff = abs(jointAngles[i] - jointAngles[i - 1])
                if diff >= threshold {
                    repeatCount += 1
                    if repeatCount >= minRepeats {
                        return true
                    }
                }
            }
        }
        return false
    }
}
