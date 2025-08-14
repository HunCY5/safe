//
//  PPEDetectionModel.swift
//  safe
//
//  Created by CHOI on 8/15/25.
//

import UIKit
import Vision

// 클래스 enum/쓰레시홀드 설정 구조체, 트랙 구조체, 좌표계/IoU/NMS 등 헬퍼 제공

// MARK: - Classes (data.yaml 순서와 정확히 일치)
public enum PPEClass: Int, CaseIterable {
    case hardhat = 0
    case noHardhat = 1
    case noVest = 2
    case person = 3
    case vest = 4

    public var name: String {
        switch self {
        case .hardhat: return "Hardhat"
        case .noHardhat: return "NO-Hardhat"
        case .noVest: return "NO-Safety Vest"
        case .person: return "Person"
        case .vest: return "Safety Vest"
        }
    }
}

// MARK: - Thresholds & Config
public struct PPEConfig {
    public var tPerson: Float = 0.55
    public var tHelmet: Float = 0.45
    public var tNoHelmet: Float = 0.60
    public var tVest: Float = 0.55
    public var tNoVest: Float = 0.80

    public var deltaMargin: Float = 0.20
    public var extraNoVestMargin: Float = 0.30

    public var assocIou: CGFloat = 0.60
    public var maxMiss: Int = 8
    public var boxEmaAlpha: CGFloat = 0.6
    public var smoothWindow: Int = 8

    public var iouThreshold: CGFloat = 0.10 // PPE→Person 매칭 허용치

    public var debugMode: Bool = true
    public init() {}
}

// MARK: - Track & Result
public struct PPETrack {
    public let id: Int
    public var bbox: CGRect // Vision 정규좌표
    public var helmetHist: [Bool] = []
    public var vestHist: [Bool] = []
    public var miss: Int = 0
}

public struct PPERenderInfo {
    public let normRectBL: CGRect // Vision 정규좌표
    public let allOK: Bool
    public let helmetOK: Bool
    public let vestOK: Bool
    public let title: String
}

// MARK: - Geometry helpers (정규좌표 기반)
public enum PPEGeom {
    public static func iou(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let inter = a.intersection(b)
        let ia = max(0, inter.width) * max(0, inter.height)
        let ua = a.width * a.height + b.width * b.height - ia + 1e-9
        return ua > 0 ? ia / ua : 0
    }
    public static func iouRect(_ a: CGRect, _ b: CGRect) -> CGFloat { iou(a, b) }

    public static func centerDistance(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let dx = a.midX - b.midX, dy = a.midY - b.midY
        return sqrt(dx*dx + dy*dy)
    }

    public static func overlapSmallRatio(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let inter = a.intersection(b)
        let ia = max(0, inter.width) * max(0, inter.height)
        let sa = a.width * a.height
        let sb = b.width * b.height
        let small = max(1e-9, min(sa, sb))
        return ia / small
    }

    public static func nmsRects(_ rects: [CGRect], iouThresh: CGFloat) -> [CGRect] {
        var keep: [CGRect] = []
        var src = rects.sorted { $0.width*$0.height > $1.width*$1.height }
        while !src.isEmpty {
            let r = src.removeFirst()
            keep.append(r)
            src.removeAll { iouRect($0, r) > iouThresh }
        }
        return keep
    }

    public static func padRect(_ r: CGRect, xPad: CGFloat, yPad: CGFloat) -> CGRect {
        var x = max(0, r.minX - xPad)
        var y = max(0, r.minY - yPad)
        var w = min(1 - x, r.width + 2*xPad)
        var h = min(1 - y, r.height + 2*yPad)
        return CGRect(x: x, y: y, width: w, height: h)
    }

    public static func clusterRects(_ rects: [CGRect], iouJoin: CGFloat) -> [CGRect] {
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

    public static func toTopLeftNorm(fromBL rect: CGRect) -> CGRect {
        CGRect(x: rect.minX, y: 1 - rect.minY - rect.height, width: rect.width, height: rect.height)
    }
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
