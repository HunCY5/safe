//
//  OWAS.swift
//  safe
//
//  Created by 신찬솔 on 7/24/25.
//

import Foundation
import CoreGraphics
import UIKit
import Combine

struct OWASEvaluator {
    static var selectedWeight: Int = 0
    private static var weightSubscriber: AnyCancellable?
    
    static var screenshotProvider: (() -> UIImage?)?
    static var saveHandler: ((UIImage, Int, String) -> Void)? 
    
    static func setWeightBinding(from publisher: Published<Int>.Publisher) {
        weightSubscriber = publisher
            .receive(on: DispatchQueue.main)
            .sink { newWeight in
                selectedWeight = newWeight
            }
    }
    
    static func owasEvaluate(from angles: JointAngles, keypoints: [BodyPart: CGPoint]? = nil) -> Int {
        
        var isSitting = angles.legLeft > 80 && angles.legRight > 80
        var isKneeOnGround: Bool = false
        if let keypoints = keypoints,
           let leftKnee = keypoints[.leftKnee],
           let rightKnee = keypoints[.rightKnee],
           let leftHip = keypoints[.leftHip],
           let rightHip = keypoints[.rightHip],
           let leftAnkle = keypoints[.leftAnkle],
           let rightAnkle = keypoints[.rightAnkle],
           let leftShoulder = keypoints[.leftShoulder],
           let rightShoulder = keypoints[.rightShoulder] {
            
            let kneeY = (leftKnee.y + rightKnee.y) / 2
            let hipY = (leftHip.y + rightHip.y) / 2
            let ankleY = (leftAnkle.y + rightAnkle.y) / 2
            let shoulderY = (leftShoulder.y + rightShoulder.y) / 2
            
            // 무릎이 바닥에 닿았는지 여부 판단
            let leftKneeOnGround = leftKnee.y > leftAnkle.y
            let rightKneeOnGround = rightKnee.y > rightAnkle.y
            isKneeOnGround = leftKneeOnGround || rightKneeOnGround
            
        }
        else {
            isSitting = false
            isKneeOnGround = false
        }
        
        // Trunk score
        var trunkScore: Int
        let adjustedTrunkAngle = isSitting ? abs(angles.trunk - 90) : angles.trunk
        
        if adjustedTrunkAngle < 10 {
            trunkScore = 1
        } else if adjustedTrunkAngle > 20 {
            trunkScore = 2
        } else if let keypoints = keypoints, TwistAndBending.detectTrunkBending(from: keypoints) != nil {
            trunkScore = 3
        } else if let keypoints = keypoints, TwistAndBending.detectTrunkBending(from: keypoints) != nil && adjustedTrunkAngle > 20 {
            trunkScore = 4
        } else {
            trunkScore = 1
        }
        
        let armScore: Int
        if let keypoints = keypoints,
           let leftWrist = keypoints[.leftWrist],
           let rightWrist = keypoints[.rightWrist],
           let leftShoulder = keypoints[.leftShoulder],
           let rightShoulder = keypoints[.rightShoulder] {
            
            let shoulderAverageY = (leftShoulder.y + rightShoulder.y) / 2.0
            
            let leftAbove = leftWrist.y < shoulderAverageY
            let rightAbove = rightWrist.y < shoulderAverageY
            
            switch (leftAbove, rightAbove) {
            case (true, true):
                armScore = 3
                print("양팔 어깨 위")
            case (true, false), (false, true):
                armScore = 2
                print("한팔 어깨 위")
            default:
                armScore = 1
                print("양팔 어깨 아래")
            }
        } else {
            armScore = 1
        }
        
        var legScore: Int
        let legAvg = (angles.legLeft + angles.legRight) / 2

        let groinAvg = (angles.leftgroin + angles.rightgroin) / 2
        
        if isSitting {
            legScore = 1
            print("앉아있음")
        }
        if buffer.isWalking() {
            legScore = 7
            print("걷고 있음")
        }
        else if isKneeOnGround {
            legScore = 6
            print("무릎 바닥")
        }
        else if (angles.legLeft > 40 && angles.legRight < 20) || (angles.legRight > 40 && angles.legLeft < 20) && !isSitting {
            legScore = 5
            print("한 무릎 굽힘")
        }
        else if angles.legLeft > 20 && angles.legRight > 20 && !isSitting {
            legScore = 4
            print("양 무릎 굽힘")
        }
        else if groinAvg > 5 && !isSitting {
            legScore = 3
            print("한발 똑바로")
        }
        else if legAvg < 10 && !isSitting {
            legScore = 2
            print("서있음")
        }
        else {
            legScore = 1
        }
        
        var weightScore: Int = 0
        
        if selectedWeight < 10 {
            weightScore = 1
        }
        else if selectedWeight < 20 {
            weightScore = 2
        }
        else {
            weightScore = 3
        }
        
        return owasTable(trunk: trunkScore, arm: armScore, leg: legScore , weight: weightScore)
    }
    
    // OWAS 결과 테이블 (trunk x arm x leg x weight)
    private static func owasTable(trunk: Int, arm: Int, leg: Int, weight: Int) -> Int {
        let owasTable = [
            [ // trunk 1
                [ [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [2, 2, 2], [1, 1, 1], [1, 1, 1] ], // arm 1
                [ [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [2, 2, 2], [1, 1, 1], [1, 1, 1] ], // arm 2
                [ [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [2, 2, 2], [1, 1, 1], [1, 1, 1] ]  // arm 3
            ],
            [ // trunk 2
                [ [1, 1, 1], [2, 2, 2], [2, 2, 2], [2, 2, 2], [3, 3, 3], [2, 2, 2], [2, 2, 2] ],
                [ [2, 2, 2], [2, 2, 2], [2, 2, 2], [2, 2, 2], [3, 3, 3], [3, 3, 3], [3, 3, 3] ],
                [ [3, 3, 3], [3, 3, 4], [2, 2, 2], [3, 3, 3], [4, 4, 4], [2, 3, 3], [3, 3, 3] ]
            ],
            [ // trunk 3
                [ [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 2, 2], [3, 3, 3], [1, 1, 1], [1, 1, 1] ],
                [ [2, 2, 2], [3, 3, 3], [1, 1, 1], [2, 2, 3], [4, 4, 4], [3, 3, 3], [3, 3, 3] ],
                [ [2, 3, 3], [2, 2, 3], [1, 1, 1], [2, 2, 3], [4, 4, 4], [3, 3, 3], [3, 3, 3] ]
            ],
            [ // trunk 4
                [ [2, 3, 3], [3, 4, 4], [2, 2, 3], [3, 3, 3], [4, 4, 4], [3, 3, 3], [3, 3, 3] ],
                [ [3, 3, 3], [4, 4, 4], [2, 3, 3], [3, 3, 4], [4, 4, 4], [4, 4, 4], [4, 4, 4] ],
                [ [3, 4, 4], [2, 3, 3], [2, 2, 3], [4, 4, 4], [4, 4, 4], [3, 4, 4], [4, 4, 4] ]
            ]
        ]
        let trunkIndex = max(0, min(3, trunk - 1))
        let armIndex = max(0, min(2, arm - 1))
        let legIndex = max(0, min(6, leg - 1))
        let weightIndex = max(0, min(2, weight - 1))
        return owasTable[trunkIndex][armIndex][legIndex][weightIndex]
    }
    
    static var buffer = PostureEvaluatorBuffer()

    static func evaluateAndSummarize(from angles: JointAngles, keypoints: [BodyPart: CGPoint]) -> (String, UIColor, Int)? {
        buffer.append(angles)

        guard buffer.isReady() else {
            return nil
        }

        let averaged = buffer.averagedAngles()
        buffer.reset()

        let score = owasEvaluate(from: averaged, keypoints: keypoints)
        let (label, color) = evaluateSummary(from: averaged, keypoints: keypoints)
        if score >= 3 {
            if let shot = screenshotProvider?() {
                saveHandler?(shot, score, "OWAS")
            }
        }
        return (label, color, score)
    }
    
    
    private static func evaluateSummary(from angles: JointAngles, keypoints: [BodyPart: CGPoint]) -> (String, UIColor) {
        let score = owasEvaluate(from: angles, keypoints: keypoints)

        switch score {
        case 1:
            return (
                "근골격계에 특별한 해를 끼치지 않음.",
                .systemGreen
            )
        case 2:
            return (
                "근골격계에 약간의 해를 끼침.",
                .systemYellow
            )
        case 3:
            return (
                "근골격계에 직접적인 해를 끼침.",
                .systemOrange
            )
        default: // 4 이상
            return (
                "근골격계에 매우 심각한 해를 끼침.",
                .systemRed
            )
        }
    }
    
}
