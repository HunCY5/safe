//
//  PPEDetector.swift
//  safe
//
//  Created by CHOI on 8/15/25.
//

import Foundation
import Vision
import CoreML
import CoreGraphics

protocol PPEDetectorDelegate: AnyObject {
    func detector(_ detector: PPEDetector, didProduce result: PPEDetectionResult?)
}

final class PPEDetector {
    weak var delegate: PPEDetectorDelegate?

    // Model
    private let modelName: String
    private var vnModel: VNCoreMLModel!

    // Tracking
    private struct Track {
        let id: Int
        var bbox: CGRect
        var helmetHist: [Bool] = []
        var vestHist: [Bool] = []
        var miss: Int = 0
        var seen: Int = 0
        var lastDraw: CGRect? = nil
    }
    private var tracks: [Track] = []
    private var nextID = 1

    // Locked-person tracking (one-person focus)
    private var lockedTrackID: Int? = nil
    private var lockedMissCount: Int = 0
    private let lockIouKeep: CGFloat = 0.30
    private let lockIouDrop: CGFloat = 0.20
    private let lockMissLimit: Int = 8

    private let visionQueue = DispatchQueue(label: "ppe.vision.queue", qos: .userInitiated)
    private var inflight = false
    // 출력 끊김 완화: 결과 유지 프레임 수(캐시 보관)
    private let outputHoldFrames: Int = 4

    // 최근 안정 결과 캐시(깜빡임 방지)
    private var lastStableResult: (result: PPEDetectionResult, hold: Int)? = nil

    init(modelName: String = "DetectionYolov11") { // .mlpackage/.mlmodelc base name
        self.modelName = modelName
        loadModel()
    }

    private func loadModel() {
        do {
            guard let url = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
                fatalError("Model not found: \(modelName).mlmodelc")
            }
            let ml = try MLModel(contentsOf: url)
            let newVNModel = try VNCoreMLModel(for: ml)
            self.vnModel = newVNModel
        } catch {
            fatalError("Model load failed: \(error)")
        }
    }

    // Reset locked person state
    func resetLock() {
        lockedTrackID = nil
        lockedMissCount = 0
        lastStableResult = nil
    }

    func process(pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation = .right) {
        if inflight { return }
        inflight = true
        let req = VNCoreMLRequest(model: vnModel) { [weak self] req, _ in
            guard let self = self else { return }
            let obs = (req.results as? [VNRecognizedObjectObservation]) ?? []
            self.postprocess(observations: obs)
            self.inflight = false
        }
        req.imageCropAndScaleOption = .centerCrop

        visionQueue.async {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
            do { try handler.perform([req]) } catch { self.inflight = false }
        }
    }

    private func postprocess(observations: [VNRecognizedObjectObservation]) {
        let tPersonEff: Float = PPEParams.tPerson
        func isSmallPerson(_ r: CGRect) -> Bool {
            r.width < PPEParams.minPersonWidth || r.height < PPEParams.minPersonHeight
        }

        // 1) filter by class/threshold
        let filtered: [(Int, VNRecognizedObjectObservation)] = observations.compactMap { o in
            guard let top = o.labels.first,
                  let idx = PPEClasses.names.firstIndex(of: top.identifier) else { return nil }
            let c = top.confidence
            let pass: Bool = {
                switch idx {
                case PPEClass.person.rawValue: return c >= tPersonEff && !isSmallPerson(o.boundingBox)
                case PPEClass.hardhat.rawValue: return c >= PPEParams.tHelmet
                case PPEClass.noHardhat.rawValue: return c >= PPEParams.tNoHelmet
                case PPEClass.vest.rawValue: return c >= PPEParams.tVest
                case PPEClass.noVest.rawValue: return c >= PPEParams.tNoVest
                default: return false
                }
            }()
            return pass ? (idx, o) : nil
        }

        var personBoxes = filtered.filter { $0.0 == PPEClass.person.rawValue }.map { $0.1.boundingBox }
        let helmets   = filtered.filter { $0.0 == PPEClass.hardhat.rawValue }.map { $0.1 }
        let noHelmets = filtered.filter { $0.0 == PPEClass.noHardhat.rawValue }.map { $0.1 }
        let vests     = filtered.filter { $0.0 == PPEClass.vest.rawValue }.map { $0.1 }
        let noVests   = filtered.filter { $0.0 == PPEClass.noVest.rawValue }.map { $0.1 }
        var personOrigins: [PersonOrigin] = Array(repeating: .detected, count: personBoxes.count)

        // 2) NMS for persons
        do {
            let sortedIdx = personBoxes.indices.sorted { (i, j) -> Bool in
                let ai = personBoxes[i]; let aj = personBoxes[j]
                return (ai.width*ai.height) > (aj.width*aj.height)
            }
            var srcBoxes = sortedIdx.map { personBoxes[$0] }
            var srcOrigins = sortedIdx.map { personOrigins[$0] }
            var keepBoxes: [CGRect] = []
            var keepOrigins: [PersonOrigin] = []
            while !srcBoxes.isEmpty {
                let r = srcBoxes.removeFirst()
                let o = srcOrigins.removeFirst()
                keepBoxes.append(r)
                keepOrigins.append(o)
                for k in (0..<srcBoxes.count).reversed() {
                    if iouRect(srcBoxes[k], r) > PPEParams.personNmsIoU {
                        srcBoxes.remove(at: k); srcOrigins.remove(at: k)
                    }
                }
            }
            personBoxes = keepBoxes
            personOrigins = keepOrigins
        }

        // 3) PPE-only 보조 person 합성
        if personBoxes.isEmpty && (!(helmets.isEmpty && noHelmets.isEmpty && vests.isEmpty && noVests.isEmpty)) {
            let ppeRects = (helmets + noHelmets + vests + noVests).map { $0.boundingBox }
            let clusters = clusterRects(ppeRects, iouJoin: PPEParams.ppeClusterJoinIoU)
            personBoxes = clusters
                .map { padRect($0, xPad: PPEParams.ppeSynthPadX, yPad: PPEParams.ppeSynthPadY).standardized.constrainedToUnit() }
            personBoxes = nmsRects(personBoxes, iouThresh: PPEParams.ppeSynthNmsIoU)
            personOrigins = Array(repeating: .synthesized, count: personBoxes.count)
        }

        // 4) Tracking (IoU + EMA)
        let zipped = zip(personBoxes, personOrigins).sorted { $0.0.minX < $1.0.minX }
        var newPersons = zipped.map { $0.0 }
        var newOrigins = zipped.map { $0.1 }
        var assigned = Array(repeating: -1, count: newPersons.count)
        var matched = Set<Int>()

        for (i, p) in newPersons.enumerated() {
            var best = -1; var bestIou: CGFloat = 0
            for (j, t) in tracks.enumerated() where !matched.contains(j) {
                let iouVal = iouRect(p, t.bbox)
                if iouVal > bestIou { bestIou = iouVal; best = j }
            }
            if bestIou >= PPEParams.assocIou, best >= 0 { assigned[i] = best; matched.insert(best) }
        }
        if !tracks.isEmpty {
            for i in newPersons.indices where assigned[i] == -1 {
                let p = newPersons[i]
                var best = -1; var bestScore: CGFloat = 0
                for (j, t) in tracks.enumerated() where !matched.contains(j) {
                    let iouVal = iouRect(p, t.bbox)
                    let cdist = centerDistance(p, t.bbox)
                    let minSide = min(min(p.width, p.height), min(t.bbox.width, t.bbox.height))
                    let close = (cdist < minSide * 0.30) ? 0.10 : 0.0
                    let score = iouVal + close
                    if score > bestScore { bestScore = score; best = j }
                }
                if best >= 0, bestScore >= PPEParams.assocIouRelaxed {
                    assigned[i] = best; matched.insert(best)
                }
            }
        }

        var upd = tracks
        var activeIdxs = Set<Int>()
        for (i, pb) in newPersons.enumerated() {
            if assigned[i] >= 0 {
                let j = assigned[i]
                var t = upd[j]
                let old = t.bbox
                let a = PPEParams.boxEmaAlpha
                t.bbox = CGRect(
                    x: old.minX*(1-a) + pb.minX*a,
                    y: old.minY*(1-a) + pb.minY*a,
                    width:  old.width*(1-a) + pb.width*a,
                    height: old.height*(1-a) + pb.height*a
                )
                t.miss = 0
                t.seen += 1
                if let ld = t.lastDraw {
                    let iouv = iouRect(t.bbox, ld)
                    if iouv > 0.50 {
                        let da: CGFloat = 0.20
                        t.lastDraw = CGRect(
                            x: ld.minX*(1-da) + t.bbox.minX*da,
                            y: ld.minY*(1-da) + t.bbox.minY*da,
                            width:  ld.width*(1-da) + t.bbox.width*da,
                            height: ld.height*(1-da) + t.bbox.height*da
                        )
                    } else {
                        t.lastDraw = t.bbox
                    }
                } else {
                    t.lastDraw = t.bbox
                }
                upd[j] = t
                activeIdxs.insert(j)
            } else {
                var t = Track(id: nextID, bbox: pb)
                nextID += 1
                t.seen = 1
                t.lastDraw = pb
                upd.append(t)
                activeIdxs.insert(upd.count - 1)
            }
        }
        for j in upd.indices {
            if !activeIdxs.contains(j) &&
               !newPersons.contains(where: { iouRect($0, upd[j].bbox) >= PPEParams.assocIou }) {
                upd[j].miss += 1
            }
        }
        upd.removeAll { $0.miss > PPEParams.maxMiss }

        var dedup: [Track] = []
        for t in upd {
            var isDup = false
            for kept in dedup {
                let iouv = iouRect(t.bbox, kept.bbox)
                let cdist = centerDistance(t.bbox, kept.bbox)
                let minSide = min(min(t.bbox.width, t.bbox.height), min(kept.bbox.width, kept.bbox.height))
                let contain = overlapSmallRatio(t.bbox, kept.bbox)
                if iouv > PPEParams.dedupIoU || cdist < minSide * PPEParams.dedupCenterFrac || contain > PPEParams.dedupContainSmall {
                    if t.id < kept.id, let idx = dedup.firstIndex(where: { $0.id == kept.id }) { dedup[idx] = t }
                    isDup = true; break
                }
            }
            if !isDup { dedup.append(t) }
        }
        tracks = dedup
        if tracks.count > 1 {
            var merged: [Track] = []
            outer: for t in tracks.sorted(by: { $0.id < $1.id }) {
                for (k, keep) in merged.enumerated() {
                    let iouv = iouRect(t.bbox, keep.bbox)
                    let cdist = centerDistance(t.bbox, keep.bbox)
                    let minSide = min(min(t.bbox.width, t.bbox.height), min(keep.bbox.width, keep.bbox.height))
                    if iouv > PPEParams.finalActiveIoU || cdist < minSide * 0.20 {
                        var newKeep = keep
                        if let ld = t.lastDraw, let kd = keep.lastDraw, iouRect(ld, kd) > 0.5 { let a: CGFloat = 0.5
                            newKeep.lastDraw = CGRect(
                                x: kd.minX*(1-a) + ld.minX*a,
                                y: kd.minY*(1-a) + ld.minY*a,
                                width:  kd.width*(1-a) + ld.width*a,
                                height: kd.height*(1-a) + ld.height*a
                            )
                        } else if newKeep.lastDraw == nil { newKeep.lastDraw = t.lastDraw }
                        if t.helmetHist.count > newKeep.helmetHist.count { newKeep.helmetHist = t.helmetHist }
                        if t.vestHist.count   > newKeep.vestHist.count   { newKeep.vestHist   = t.vestHist }
                        merged[k] = newKeep
                        continue outer
                    }
                }
                merged.append(t)
            }
            tracks = merged
        }

        // 5) 한 사람 선택 + 출력
        func originFor(trackBox: CGRect, newPersons: [CGRect], newOrigins: [PersonOrigin]) -> PersonOrigin {
            guard !newPersons.isEmpty else { return .detected }
            var best: (d: CGFloat, o: PersonOrigin) = (.greatestFiniteMagnitude, .detected)
            for (i, r) in newPersons.enumerated() {
                let dx = r.midX - trackBox.midX, dy = r.midY - trackBox.midY
                let d = dx*dx + dy*dy
                if d < best.d { best = (d, newOrigins[i]) }
            }
            return best.o
        }

        // 최근 탐지 유지
        let currentTracks = tracks.enumerated().filter { $0.element.seen >= 2 && $0.element.miss <= 1 }
        let screenCenter = CGPoint(x: 0.5, y: 0.5)
        func priorityKey(for t: Track) -> (Int, CGFloat, CGFloat, Int) {
            let ori = originFor(trackBox: t.bbox, newPersons: newPersons, newOrigins: newOrigins)
            let detectedRank = (ori == .detected) ? 1 : 0
            let area = t.bbox.width * t.bbox.height
            let dx = t.bbox.midX - screenCenter.x
            let dy = t.bbox.midY - screenCenter.y
            let centerNegDistance = -sqrt(dx*dx + dy*dy)
            return (detectedRank, area, centerNegDistance, -t.id)
        }

        // 우선 잠금된 트랙 유지 시도
        var selectedIndex: Int? = nil
        if let lockedID = lockedTrackID, let idx = tracks.firstIndex(where: { $0.id == lockedID }) {
            let lt = tracks[idx]
            // 현재 프레임의 후보들과 IoU를 비교하여 유지 여부 판단
            let bestIoU = newPersons.map { iouRect(lt.bbox, $0) }.max() ?? 0
            if lt.miss == 0 || bestIoU >= lockIouKeep {
                selectedIndex = idx
                lockedMissCount = 0
            } else if bestIoU < lockIouDrop || lt.miss > 0 {
                lockedMissCount += 1
                if lockedMissCount > lockMissLimit {
                    lockedTrackID = nil
                    lockedMissCount = 0
                }
            }
        }

        // 잠금이 없거나 유지 실패 시, 기존 우선순위로 선택
        if selectedIndex == nil {
            guard let chosen = currentTracks.max(by: { lhs, rhs in
                let a = priorityKey(for: lhs.element)
                let b = priorityKey(for: rhs.element)
                if a.0 != b.0 { return a.0 < b.0 }
                if a.1 != b.1 { return a.1 < b.1 }
                if a.2 != b.2 { return a.2 < b.2 }
                return a.3 < b.3
            }) else {
                // 활성 트랙이 잠시 사라진 경우 최근 결과를 잠깐 유지
                if var cached = self.lastStableResult, cached.hold > 0 {
                    cached.hold -= 1
                    self.lastStableResult = cached
                    delegate?.detector(self, didProduce: cached.result)
                } else {
                    delegate?.detector(self, didProduce: nil)
                }
                return
            }
            selectedIndex = chosen.offset
            if lockedTrackID == nil, let si = selectedIndex { lockedTrackID = tracks[si].id; lockedMissCount = 0 }
        }

        guard let trackIndex = selectedIndex else { delegate?.detector(self, didProduce: nil); return }
        var t = tracks[trackIndex]
        let pBox = t.bbox

        // 상체 기준 필터(조끼 오검출 억제, 범위 약간 넓힘)
        func isOnTorso(child: CGRect, of person: CGRect) -> Bool {
            let torso = CGRect(
                x: person.minX + person.width * 0.03,
                y: person.minY + person.height * 0.20,
                width:  person.width * 0.94,
                height: person.height * 0.65
            )
            let c = CGPoint(x: child.midX, y: child.midY)
            return torso.contains(c)
        }

        // 한 사람 제한 조건
        func maxConf(in list: [VNRecognizedObjectObservation], parent: CGRect) -> Float {
            var m: Float = 0
            for o in list {
                let child = o.boundingBox
                let center = CGPoint(x: child.midX, y: child.midY)
                if parent.contains(center) || iouRect(child, parent) > PPEParams.iouThreshold {
                    if let c = o.labels.first?.confidence, c > m { m = c }
                }
            }
            return m
        }

        let hMax  = maxConf(in: helmets,   parent: pBox)
        let nhMax = maxConf(in: noHelmets, parent: pBox)
        let torsoVests   = vests.filter   { isOnTorso(child: $0.boundingBox, of: pBox) }
        let torsoNoVests = noVests.filter { isOnTorso(child: $0.boundingBox, of: pBox) }
        let vMax  = maxConf(in: torsoVests,   parent: pBox)
        let nvMax = maxConf(in: torsoNoVests, parent: pBox)

        // 미착용 신호를 우선 고려(규정 위반 강조)
        var helmetOKDecided: Bool?
        if nhMax >= PPEParams.tNoHelmet {
            helmetOKDecided = false
        } else if hMax >= PPEParams.tHelmet && (hMax - nhMax) >= PPEParams.deltaMargin {
            helmetOKDecided = true
        }

        var vestOKDecided: Bool?
        if nvMax >= PPEParams.tNoVest {
            vestOKDecided = false
        } else if vMax >= PPEParams.tVest && (vMax - nvMax) >= PPEParams.deltaMargin {
            vestOKDecided = true
        }

        func majority(_ xs: [Bool]) -> Bool? {
            guard !xs.isEmpty else { return nil }
            let ones = xs.filter { $0 }.count
            let zeros = xs.count - ones
            return ones == zeros ? xs.last : (ones > zeros)
        }

        if let d = helmetOKDecided { t.helmetHist.append(d) }
        if let d = vestOKDecided   { t.vestHist.append(d) }
        if t.helmetHist.count > PPEParams.smoothWindow { t.helmetHist.removeFirst(t.helmetHist.count - PPEParams.smoothWindow) }
        if t.vestHist.count   > PPEParams.smoothWindow { t.vestHist.removeFirst(t.vestHist.count   - PPEParams.smoothWindow) }

        let helmetFinal: Bool = (majority(t.helmetHist) ?? helmetOKDecided) ?? false
        let vestFinal:   Bool = (majority(t.vestHist)   ?? vestOKDecided)   ?? false

        tracks[trackIndex] = t

        let origin = originFor(trackBox: pBox, newPersons: newPersons, newOrigins: newOrigins)
        let result = PPEDetectionResult(
            trackID: t.id,
            personBoxVision: (tracks[trackIndex].lastDraw ?? pBox),
            origin: origin,
            helmetOK: helmetFinal,
            vestOK: vestFinal
        )

        // 최신 안정 결과 보관(깜빡임 완화)
        self.lastStableResult = (result, outputHoldFrames)

        delegate?.detector(self, didProduce: result)
    }
}
