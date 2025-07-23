//
//  PostureEvaluatorBuffer.swift
//  safe
//
//  Created by 신찬솔 on 7/24/25.
//


import Foundation
import UIKit

final class PostureEvaluatorBuffer {
    private var anglesBuffer: [JointAngles] = []
    private let maxSamples: Int

    init(maxSamples: Int = 5) {
        self.maxSamples = maxSamples
    }

    func append(_ angles: JointAngles) {
        anglesBuffer.append(angles)
    }

    func isReady() -> Bool {
        return anglesBuffer.count >= maxSamples
    }

    func reset() {
        anglesBuffer.removeAll()
    }

    var buffer: [JointAngles] {
        return anglesBuffer
    }

    func averagedAngles() -> JointAngles {
        let count = CGFloat(anglesBuffer.count)
        let sum = anglesBuffer.reduce(into: JointAngles(upperArm: 0, lowerArm: 0, neck: 0, trunk: 0, legLeft: 0, legRight: 0, rightgroin: 0, leftgroin: 0)) { acc, item in
            acc = JointAngles(
                upperArm: acc.upperArm + item.upperArm,
                lowerArm: acc.lowerArm + item.lowerArm,
                neck: acc.neck + item.neck,
                trunk: acc.trunk + item.trunk,
                legLeft: acc.legLeft + item.legLeft,
                legRight: acc.legRight + item.legRight,
                rightgroin: acc.rightgroin + item.rightgroin,
                leftgroin: acc.leftgroin + item.leftgroin
            )
        }

        return JointAngles(
            upperArm: sum.upperArm / count,
            lowerArm: sum.lowerArm / count,
            neck: sum.neck / count,
            trunk: sum.trunk / count,
            legLeft: sum.legLeft / count,
            legRight: sum.legRight / count,
            rightgroin: sum.rightgroin / count,
            leftgroin: sum.leftgroin / count
        )
    }
}
