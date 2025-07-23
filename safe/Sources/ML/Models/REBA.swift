//
//  REBA.swift
//  safe
//
//  Created by 신찬솔 on 7/23/25.
//
import Foundation
import CoreGraphics
import UIKit

struct REBAEvaluator {
    
    static func rebaEvaluate(from angles: JointAngles, muscleUse: Bool = false) -> Int {
        // Neck score (adjusted for relaxed sensitivity)
        let neckScore: Int
        if angles.neck < 10 {
            neckScore = 1
        } else if angles.neck < 40 {
            neckScore = 2
        } else {
            neckScore = 3
        }
        
        // Trunk score
        let trunkScore: Int
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
        
        // Wrist score
        let wristScore = 2
        
        
        
        // Table A: Neck + Trunk + Leg
        let scoreA = rebaTableA(neck: neckScore, trunk: trunkScore,leg: legScore)
        // Table B: Upper + Lower + Wrist
        let scoreB = rebaTableB(upper: upperArmScore, lower: lowerArmScore, wrist: wristScore)
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
        buffer.reset()

        let score = rebaEvaluate(from: averaged)
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
    
    
    
}

