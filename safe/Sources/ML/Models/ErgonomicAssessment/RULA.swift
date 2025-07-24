//
//  RULA.swift
//  safe
//
//  Created by 신찬솔 on 7/22/25.
//

import Foundation
import CoreGraphics
import UIKit
import Combine

struct RULAEvaluator {
    static var selectedWeight: Int = 0
    private static var weightSubscriber: AnyCancellable?

    static func setWeightBinding(from publisher: Published<Int>.Publisher) {
        weightSubscriber = publisher
            .receive(on: DispatchQueue.main)
            .sink { newWeight in
                selectedWeight = newWeight
            }
    }
    
    static func rulaEvaluate(from angles: JointAngles, keypoints: [BodyPart: CGPoint]? = nil) -> Int {
        // Upper Arm score
        let upperArmScore: Int
        if angles.upperArm < 30 {
            upperArmScore = 1
        } else if angles.upperArm < 55 {
            upperArmScore = 2
        } else if angles.upperArm < 90 {
            upperArmScore = 3
        } else {
            upperArmScore = 4
        }

        // Lower Arm score
        let lowerArmScore = (angles.lowerArm >= 60 && angles.lowerArm <= 100) ? 1 : 2

        // Wrist score (placeholder)
        let wristScore = 1
        let wristTwistScore = 1

        // Neck score (adjusted for relaxed sensitivity)
        var neckScore: Int
        if angles.neck < 10 {
            neckScore = 1
        } else if angles.neck < 20 {
            neckScore = 2
        } else {
            neckScore = 3
        }


        // Trunk score
        var trunkScore: Int
        if angles.trunk < 10 {
            trunkScore = 1
        } else if angles.trunk < 20 {
            trunkScore = 2
        } else if angles.trunk < 60 {
            trunkScore = 3
        } else {
            trunkScore = 4
        }

        // 근로자가 들고 있는 무게에 대한 점수 가중치(A)
         var weightScore: Int = 0
         switch selectedWeight {
         case 0...2:
             weightScore = 0
         case 3...10:
             weightScore = 1
         default:
             weightScore = 3
         }

        // Leg score
        let legAvg = (angles.legLeft + angles.legRight) / 2
        let groinAvg = (angles.leftgroin + angles.rightgroin) / 2
        
        let legScore = (legAvg < 30) || (groinAvg < 30) ? 1 : 2
        
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

        // Table A: (Upper + Lower + Wrist) + Weight
        let scoreA = rulaTableA(upper: upperArmScore, lower: lowerArmScore, wrist: wristScore, twist: wristTwistScore) + weightScore

        // Table B: Neck + Trunk + Leg
        let scoreB = rulaTableB(neck: neckScore, trunk: trunkScore, legs: legScore)

        // Table C mapping (simplified risk lookup) + + Weight
        return rulaTableC(scoreA: scoreA, scoreB: scoreB) + weightScore
    }

    private static func rulaTableA(upper: Int, lower: Int, wrist: Int, twist: Int) -> Int {
        let flatIndex = (upper - 1) * 3 + (lower - 1)
        let wristIndex = min(max(wrist - 1, 0), 3)
        let tableA: [[Int]] = [
            [1, 2, 2, 3], [2, 2, 3, 3], [3, 3, 3, 4],
            [3, 3, 4, 4], [4, 4, 4, 5], [4, 4, 5, 5],
            [3, 3, 4, 4], [4, 4, 4, 5], [4, 4, 5, 5],
            [4, 4, 4, 5], [4, 4, 5, 5], [4, 4, 5, 5],
            [4, 4, 5, 6], [5, 5, 6, 7], [6, 6, 7, 7],
            [7, 7, 8, 9], [8, 8, 9, 9], [9, 9, 9, 9]
        ]
        return tableA[min(flatIndex, tableA.count - 1)][wristIndex] + twist
    }

    private static func rulaTableB(neck: Int, trunk: Int, legs: Int) -> Int {
        let tableB: [[Int]] = [
            [1,3,2,3,3,4,5,5,6,6,7,7],
            [2,3,2,3,4,5,5,5,6,7,7,7],
            [3,3,3,4,4,5,5,6,6,7,7,7],
            [5,5,5,6,6,7,7,7,7,7,8,8],
            [7,7,7,7,7,8,8,8,8,8,8,8],
            [8,8,8,8,8,8,8,9,9,9,9,9]
        ]
        let row = min(max(neck - 1, 0), 5)
        let col = min(max(((trunk - 1) * 2) + (legs - 1), 0), 11)
        let score = tableB[row][col]
        return score
    }

    private static func rulaTableC(scoreA: Int, scoreB: Int) -> Int {
        let tableC: [[Int]] = [
            [1,2,3,3,4,5,5],
            [2,2,3,4,4,5,5],
            [3,3,3,4,5,5,6],
            [3,3,4,5,5,6,6],
            [4,4,5,5,6,6,7],
            [4,5,5,6,6,7,7],
            [5,5,6,6,7,7,7],
            [5,5,6,7,7,7,7]
        ]
        let row = min(max(scoreA - 1, 0), 7)
        let col = min(max(scoreB - 1, 0), 6)
        return tableC[row][col]
    }

    static var buffer = PostureEvaluatorBuffer()

    static func evaluateAndSummarize(from angles: JointAngles, keypoints: [BodyPart: CGPoint]) -> (String, UIColor, Int)? {
        buffer.append(angles)

        guard buffer.isReady() else {
            return nil
        }

        let averaged = buffer.averagedAngles()
        buffer.reset()

        let score = rulaEvaluate(from: averaged, keypoints: keypoints)
        let (label, color) = evaluateSummary(from: averaged)
        return (label, color, score)
    }

    private static func evaluateSummary(from angles: JointAngles) -> (String, UIColor) {
        let score = rulaEvaluate(from: angles)

        switch score {
        case 1, 2:
            return ("수용 가능한 작업", .systemGreen)
        case 3, 4:
            return ("추적 관찰 필요한 작업", .systemYellow)
        case 5, 6:
            return ("빠른 작업 개선", .systemOrange)
        default:
            return ("즉각 개선", .systemRed)
        }
    }
}
