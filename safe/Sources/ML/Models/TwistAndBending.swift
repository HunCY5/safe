//
//  HeadTwistAndBending.swift
//  safe
//
//  Created by 신찬솔 on 7/24/25.
//

import Foundation
import CoreGraphics
import UIKit


struct TwistAndBending {
    
    // 허리 기울임 감지
    static func detectTrunkBending(from keypoints: [BodyPart: CGPoint]) -> Int? {
        guard let leftShoulder = keypoints[.leftShoulder],
              let rightShoulder = keypoints[.rightShoulder] else {
            return nil
        }
        
        let shoulderYDifference = abs(leftShoulder.y - rightShoulder.y)
        if shoulderYDifference > 20 {
            print("허리가 뒤틀림")
            return 1
        }
        else {
            return 0
        }
        
    }
    
    // 머리 기울임 감지
    static func detectHeadBending(from keypoints: [BodyPart: CGPoint]) -> Int? {
        guard  let leftEar = keypoints[.leftEar],
               let rightEar = keypoints[.rightEar] else {
            return nil
        }
        
        let earYDifference = abs(leftEar.y - rightEar.y)
        if earYDifference > 20 {
            print("목이 옆으로 기울어짐")
            return 1 // 목이 옆으로 기울어짐
        }
        else {
            return 0
        }
    }
    // 머리 뒤틀림 및 옆모습 감지
    static func detectHeadTwist(from keypoints: [BodyPart: CGPoint]) -> Int? {
        guard   let leftEar = keypoints[.leftEar],
                let rightEar = keypoints[.rightEar],
                let leftShoulder = keypoints[.leftShoulder],
                let rightShoulder = keypoints[.rightShoulder],
                let leftEye = keypoints[.leftEye],
                let rightEye = keypoints[.rightEye] else {
            return nil
        }
        
        let earCenter = CGPoint(
            x: (leftEar.x + rightEar.x) / 2,
            y: (leftEar.y + rightEar.y) / 2
        )
        
        
        let shoulderCenter = CGPoint(
            x: (leftShoulder.x + rightShoulder.x) / 2,
            y: (leftShoulder.y + rightShoulder.y) / 2
        )
        
        let shoulderWidth = hypot(leftShoulder.x - rightShoulder.x, leftShoulder.y - rightShoulder.y)
        let earShoulderCenterDistance = hypot(earCenter.x - shoulderCenter.x, earCenter.y - shoulderCenter.y)
        
        let eyeThresholdRange: ClosedRange<CGFloat> = {
            let minX = min(leftEye.x, rightEye.x)
            let maxX = max(leftEye.x, rightEye.x)
            return minX ... maxX
        }()
        
        if earShoulderCenterDistance > shoulderWidth {
            if eyeThresholdRange.contains(earCenter.x) {
                print("머리 뒤틀림")
                return 1 // 머리 뒤틀림
            }
            else {
                return 0 // 옆모습
            }
        } else {
            if eyeThresholdRange.contains(earCenter.x) {
                return 0 // 정면
            }
            else {
                print("머리 뒤틀림")
                return 1 // 머리 뒤틀림
            }
        }
    }
}
