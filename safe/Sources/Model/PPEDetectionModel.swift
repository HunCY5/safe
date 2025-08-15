//
//  PPEDetectionModel.swift
//  safe
//
//  Created by CHOI on 8/15/25.
//

import CoreGraphics
import Vision
import Foundation

// 클래스 enum/쓰레시홀드 설정 구조체, 트랙 구조체, 좌표계/IoU/NMS 등 헬퍼 제공

public enum PersonOrigin { case detected, synthesized }

public enum PPEClass: Int { case hardhat = 0, noHardhat = 1, noVest = 2, person = 3, vest = 4 }

public struct PPEDetectionResult {
    public let personBoxVision: CGRect   // Vision normalized (origin at bottom-left)
    public let origin: PersonOrigin      // detected or synthesized
    public let helmetOK: Bool
    public let vestOK: Bool
    public var allOK: Bool { helmetOK && vestOK }
}

public struct PPEClasses {
    // Must exactly match data.yaml order and case
    public static let names = ["Hardhat","NO-Hardhat","NO-Safety Vest","Person","Safety Vest"]
    public static let personName = "Person"
}

public struct PPEParams {
    // thresholds
    public static var tPerson: Float   = 0.45
    public static var tHelmet: Float   = 0.55
    public static var tNoHelmet: Float = 0.70
    public static var tVest: Float     = 0.55
    public static var tNoVest: Float   = 0.80
    // margins (class 경쟁)
    public static let deltaMargin: Float = 0.20
    public static let extraNoVestMargin: Float = 0.30
    // match / tracking
    public static let iouThreshold: CGFloat = 0.10
    public static let assocIou: CGFloat = 0.60
    public static let assocIouRelaxed: CGFloat = 0.30
    public static let maxMiss = 8
    public static let boxEmaAlpha: CGFloat = 0.3
    public static let smoothWindow = 8
    // person 후보 필터
    public static let minPersonWidth:  CGFloat = 0.02
    public static let minPersonHeight: CGFloat = 0.04
    public static let personNmsIoU: CGFloat = 0.55
    // PPE-only 보조 person 합성
    public static let ppeClusterJoinIoU: CGFloat = 0.10
    public static let ppeSynthNmsIoU: CGFloat = 0.45
    public static let ppeSynthPadX: CGFloat = 0.06
    public static let ppeSynthPadY: CGFloat = 0.12
    // 활성 트랙 중복 억제/통합
    public static let dedupIoU: CGFloat = 0.60
    public static let dedupCenterFrac: CGFloat = 0.20
    public static let dedupContainSmall: CGFloat = 0.80
    public static let finalActiveIoU: CGFloat = 0.65
}


public func clusterRects(_ rects: [CGRect], iouJoin: CGFloat) -> [CGRect] {
    var remaining = rects
    var out: [CGRect] = []
    while !remaining.isEmpty {
        var r = remaining.removeFirst()
        var merged = true
        while merged {
            merged = false
            for (i, s) in remaining.enumerated().reversed() {
                if iouRect(r, s) >= iouJoin || r.intersects(s) {
                    r = r.union(s)
                    remaining.remove(at: i)
                    merged = true
                }
            }
        }
        out.append(r)
    }
    return out
}

public func iouRect(_ a: CGRect, _ b: CGRect) -> CGFloat {
    let inter = a.intersection(b)
    let ia = max(0, inter.width) * max(0, inter.height)
    let ua = a.width * a.height + b.width * b.height - ia + 1e-9
    return ua > 0 ? ia / ua : 0
}

public func nmsRects(_ rects: [CGRect], iouThresh: CGFloat) -> [CGRect] {
    var keep: [CGRect] = []
    var src = rects.sorted { $0.width * $0.height > $1.width * $1.height }
    while !src.isEmpty {
        let r = src.removeFirst()
        keep.append(r)
        src.removeAll { iouRect($0, r) > iouThresh }
    }
    return keep
}

public func centerDistance(_ a: CGRect, _ b: CGRect) -> CGFloat {
    let dx = a.midX - b.midX, dy = a.midY - b.midY
    return sqrt(dx*dx + dy*dy)
}

public func overlapSmallRatio(_ a: CGRect, _ b: CGRect) -> CGFloat {
    let inter = a.intersection(b)
    let ia = max(0, inter.width) * max(0, inter.height)
    let sa = a.width * a.height
    let sb = b.width * b.height
    let small = max(1e-9, min(sa, sb))
    return ia / small
}

public func padRect(_ r: CGRect, xPad: CGFloat, yPad: CGFloat) -> CGRect {
    let x = max(0, r.minX - xPad)
    let y = max(0, r.minY - yPad)
    let w = min(1 - x, r.width + 2 * xPad)
    let h = min(1 - y, r.height + 2 * yPad)
    return CGRect(x: x, y: y, width: w, height: h)
}

public extension CGRect {
    func constrainedToUnit() -> CGRect {
        let x = max(0, min(1, self.minX))
        let y = max(0, min(1, self.minY))
        let w = max(0, min(1 - x, self.width))
        let h = max(0, min(1 - y, self.height))
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
