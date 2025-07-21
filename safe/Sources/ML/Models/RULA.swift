//
//  RULA.swift
//  safe
//
//  Created by 신찬솔 on 7/22/25.
//

import Foundation
import CoreGraphics
import UIKit

struct RULAEvaluator {
    struct JointAngles {
        let upperArm: CGFloat
        let lowerArm: CGFloat
        let neck: CGFloat
        let trunk: CGFloat
        let legLeft: CGFloat
        let legRight: CGFloat
    }

    static func evaluate(from angles: JointAngles, muscleUse: Bool = false) -> Int {
        // Upper Arm score
        let upperArmScore: Int
        if angles.upperArm < 20 {
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

        // Wrist score (placeholder)
        let wristScore = 1
        let wristTwistScore = 1

        // Neck score (adjusted for relaxed sensitivity)
        let neckScore: Int
        if angles.neck < 10 {
            neckScore = 1
        } else if angles.neck < 20 {
            neckScore = 2
        } else {
            neckScore = 3
        }

        // Trunk score
        let trunkScore: Int
        if angles.trunk < 10 {
            trunkScore = 1
        } else if angles.trunk < 20 {
            trunkScore = 2
        } else if angles.trunk < 60 {
            trunkScore = 3
        } else {
            trunkScore = 4
        }

        // Leg score
        let legAvg = (angles.legLeft + angles.legRight) / 2
        let legScore = (legAvg < 30) ? 1 : 2

        // Table A: Upper + Lower + Wrist
        let scoreA = rulaTableA(upper: upperArmScore, lower: lowerArmScore, wrist: wristScore, twist: wristTwistScore)

        // Muscle use bonus
        var mutableScoreA = scoreA
        if muscleUse {
            mutableScoreA += 1
        }

        // Table B: Neck + Trunk + Leg
        let scoreB = rulaTableB(neck: neckScore, trunk: trunkScore, legs: legScore, muscleUse: muscleUse)

        // Table C mapping (simplified risk lookup)
        return rulaTableC(scoreA: mutableScoreA, scoreB: scoreB)
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

    private static func rulaTableB(neck: Int, trunk: Int, legs: Int, muscleUse: Bool) -> Int {
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
        var score = tableB[row][col]
        if muscleUse { score += 1 }
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

    static func evaluateAndSummarize(from angles: JointAngles) -> (String, UIColor, Int)? {
        struct Buffer {
            static var recentAngles: [JointAngles] = []
        }

        Buffer.recentAngles.append(angles)

        guard Buffer.recentAngles.count >= 5 else {
            return nil
        }

        let averaged = averageJointAngles(from: Buffer.recentAngles)
        Buffer.recentAngles.removeAll()

        let score = evaluate(from: averaged)
        let (label, color) = evaluateSummary(from: averaged)
        return (label, color, score)
    }

    private static func averageJointAngles(from samples: [JointAngles]) -> JointAngles {
        let count = CGFloat(samples.count)
        let sum = samples.reduce(into: JointAngles(upperArm: 0, lowerArm: 0, neck: 0, trunk: 0, legLeft: 0, legRight: 0)) { acc, item in
            acc = JointAngles(
                upperArm: acc.upperArm + item.upperArm,
                lowerArm: acc.lowerArm + item.lowerArm,
                neck: acc.neck + item.neck,
                trunk: acc.trunk + item.trunk,
                legLeft: acc.legLeft + item.legLeft,
                legRight: acc.legRight + item.legRight
            )
        }

        return JointAngles(
            upperArm: sum.upperArm / count,
            lowerArm: sum.lowerArm / count,
            neck: sum.neck / count,
            trunk: sum.trunk / count,
            legLeft: sum.legLeft / count,
            legRight: sum.legRight / count
        )
    }

    private static func evaluateSummary(from angles: JointAngles) -> (String, UIColor) {
        let score = evaluate(from: angles)

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
