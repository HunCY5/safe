//
//  PPEDetectior.swift
//  safe
//
//  Created by CHOI on 8/15/25.
//

import Foundation
import Vision
import CoreML
import OSLog

// 비즈니스 로직 처리: NMS/IoU/클러스터링, 간단 추적(EMA), PPE 판정(헬멧/조끼)

public protocol PPEDetectorDelegate: AnyObject {
    func ppeDetector(_ detector: PPEDetector, didProduce results: [PPERenderInfo])
}

public final class PPEDetector {
    private let modelName: String
    private let config: PPEConfig
    private let logger = Logger(subsystem: "com.yolodemo.app", category: "vision")

    private var vnModel: VNCoreMLModel!
    private var inflight = false

    // tracking
    private var tracks: [PPETrack] = []
    private var nextID = 1

    public weak var delegate: PPEDetectorDelegate?

    public init(modelName: String = "DetectionYolo11", config: PPEConfig = .init()) {
        self.modelName = modelName
        self.config = config
        loadModel()
    }

    private func loadModel() {
        do {
            guard let url = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
                fatalError("Model not found: \(modelName).mlmodelc")
            }
            let ml = try MLModel(contentsOf: url)
            self.vnModel = try VNCoreMLModel(for: ml)
        } catch {
            fatalError("Model load failed: \(error)")
        }
    }

    // MARK: - Public API
    public func process(pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation = .right) {
        guard !inflight else { return }
        inflight = true

        let req = VNCoreMLRequest(model: vnModel) { [weak self] req, _ in
            guard let self = self else { return }
            defer { self.inflight = false }
            let obs = (req.results as? [VNRecognizedObjectObservation]) ?? []
            if self.config.debugMode {
                var hist: [String:Int] = [:]
                for o in obs { if let id = o.labels.first?.identifier { hist[id, default: 0] += 1 } }
                self.logger.debug("Frame obs=\(obs.count), byTop=\(String(describing: hist))")
            }
            let results = self.postprocess(observations: obs)
            self.delegate?.ppeDetector(self, didProduce: results)
        }
        req.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        do { try handler.perform([req]) } catch {
            self.logger.error("Vision error: \(error.localizedDescription)")
            inflight = false
        }
    }

    // MARK: - Postprocess (원본 컨트롤러 로직 이동)
    private func postprocess(observations: [VNRecognizedObjectObservation]) -> [PPERenderInfo] {
        // Effective thresholds
        let tPersonEff: Float = config.debugMode ? max(0.20, config.tPerson - 0.20) : config.tPerson

        func isSmallPerson(_ r: CGRect) -> Bool { r.width < 0.02 || r.height < 0.04 }

        if config.debugMode {
            let personObs = observations.filter { $0.labels.first?.identifier == PPEClass.person.name }
            var small = 0, low = 0
            for o in personObs {
                let c = o.labels.first?.confidence ?? 0
                if isSmallPerson(o.boundingBox) { small += 1 }
                if c < tPersonEff { low += 1 }
            }
            logger.debug("Candidates person total=\(personObs.count), small=\(small), lowScore(<\(tPersonEff, format: .fixed(precision: 2)))=\(low)")
        }

        // 1) 클래스별 필터링
        let filtered: [(Int, VNRecognizedObjectObservation)] = observations.compactMap { o in
            guard let top = o.labels.first else { return nil }
            guard let idx = PPEClass.allCases.firstIndex(where: { $0.name == top.identifier }) else { return nil }
            let c = top.confidence
            let pass: Bool = {
                switch PPEClass(rawValue: idx)! {
                case .person: return c >= tPersonEff && !isSmallPerson(o.boundingBox)
                case .hardhat: return c >= config.tHelmet
                case .noHardhat: return c >= config.tNoHelmet
                case .vest: return c >= config.tVest
                case .noVest: return c >= config.tNoVest
                }
            }()
            return pass ? (idx, o) : nil
        }

        var personBoxes = filtered.filter { $0.0 == PPEClass.person.rawValue }.map { $0.1.boundingBox }
        let helmets   = filtered.filter { $0.0 == PPEClass.hardhat.rawValue   }.map { $0.1 }
        let noHelmets = filtered.filter { $0.0 == PPEClass.noHardhat.rawValue }.map { $0.1 }
        let vests     = filtered.filter { $0.0 == PPEClass.vest.rawValue      }.map { $0.1 }
        let noVests   = filtered.filter { $0.0 == PPEClass.noVest.rawValue    }.map { $0.1 }

        personBoxes = PPEGeom.nmsRects(personBoxes, iouThresh: 0.55)

        if personBoxes.isEmpty && (!(helmets.isEmpty && noHelmets.isEmpty && vests.isEmpty && noVests.isEmpty)) {
            let ppeRects = (helmets + noHelmets + vests + noVests).map { $0.boundingBox }
            let clusters = PPEGeom.clusterRects(ppeRects, iouJoin: 0.10)
            personBoxes = clusters.map { PPEGeom.padRect($0, xPad: 0.06, yPad: 0.12).standardized.constrainedToUnit() }
            personBoxes = PPEGeom.nmsRects(personBoxes, iouThresh: 0.45)
            if config.debugMode { logger.info("Synthesized \(personBoxes.count) person box(es) from PPE clusters") }
        }

        // 2) 간단 트래킹 (IoU 매칭 + EMA)
        var newPersons = personBoxes.sorted { $0.minX < $1.minX }
        var assigned = Array(repeating: -1, count: newPersons.count)
        var matchedTrackIdxs = Set<Int>()

        for (i, p) in newPersons.enumerated() {
            var best = -1; var bestIou: CGFloat = 0
            for (j, t) in tracks.enumerated() where !matchedTrackIdxs.contains(j) {
                let iouVal = PPEGeom.iouRect(p, t.bbox)
                if iouVal > bestIou { bestIou = iouVal; best = j }
            }
            if bestIou >= config.assocIou, best >= 0 { assigned[i] = best; matchedTrackIdxs.insert(best) }
        }

        var upd = tracks
        var activeIdxs = Set<Int>()

        for (i, pb) in newPersons.enumerated() {
            if assigned[i] >= 0 {
                let j = assigned[i]
                var t = upd[j]
                let old = t.bbox
                let a = config.boxEmaAlpha
                t.bbox = CGRect(x: old.minX*(1-a) + pb.minX*a,
                                y: old.minY*(1-a) + pb.minY*a,
                                width:  old.width*(1-a) + pb.width*a,
                                height: old.height*(1-a) + pb.height*a)
                t.miss = 0
                upd[j] = t
                activeIdxs.insert(j)
            } else {
                var t = PPETrack(id: nextID, bbox: pb)
                nextID += 1
                upd.append(t)
                activeIdxs.insert(upd.count - 1)
            }
        }

        for j in upd.indices {
            if !activeIdxs.contains(j) && !newPersons.contains(where: { PPEGeom.iouRect($0, upd[j].bbox) >= config.assocIou }) {
                upd[j].miss += 1
            }
        }
        upd.removeAll { $0.miss > config.maxMiss }

        // 중복 제거 (오래된 id 보존)
        var dedup: [PPETrack] = []
        for t in upd {
            var isDup = false
            for kept in dedup {
                let iouv = PPEGeom.iouRect(t.bbox, kept.bbox)
                let cdist = PPEGeom.centerDistance(t.bbox, kept.bbox)
                let minSide = min(min(t.bbox.width, t.bbox.height), min(kept.bbox.width, kept.bbox.height))
                let contain = PPEGeom.overlapSmallRatio(t.bbox, kept.bbox)
                if iouv > 0.45 || cdist < minSide*0.25 || contain > 0.75 {
                    if t.id < kept.id { if let idx = dedup.firstIndex(where: { $0.id == kept.id }) { dedup[idx] = t } }
                    isDup = true; break
                }
            }
            if !isDup { dedup.append(t) }
        }
        tracks = dedup

        // 3) 사람별 PPE 판정
        let currentTracks = tracks.enumerated().filter { $0.element.miss == 0 }
        var keepActiveIndices: [Int] = []
        for pair in currentTracks {
            let i = pair.offset
            var suppress = false
            for k in keepActiveIndices {
                if PPEGeom.iouRect(tracks[i].bbox, tracks[k].bbox) > 0.65 {
                    if tracks[i].id > tracks[k].id { suppress = true; break }
                }
            }
            if !suppress { keepActiveIndices.append(i) }
        }
        let ordered: [(offset: Int, element: PPETrack)] = keepActiveIndices
            .map { (offset: $0, element: tracks[$0]) }
            .sorted { $0.element.bbox.minX < $1.element.bbox.minX }
        var displayIndex: [Int:Int] = [:]
        for (rank, pair) in ordered.enumerated() { displayIndex[pair.offset] = rank + 1 }

        func match(child: CGRect, parent: CGRect) -> Bool {
            let center = CGPoint(x: child.midX, y: child.midY)
            if parent.contains(center) { return true }
            return PPEGeom.iou(child, parent) > config.iouThreshold
        }
        func maxConf(in list: [VNRecognizedObjectObservation], parent: CGRect) -> Float {
            var m: Float = 0
            for o in list {
                if match(child: o.boundingBox, parent: parent) {
                    if let c = o.labels.first?.confidence, c > m { m = c }
                }
            }
            return m
        }
        func isOnTorso(child: CGRect, of person: CGRect) -> Bool {
            let torso = CGRect(x: person.minX + person.width*0.05,
                               y: person.minY + person.height*0.30,
                               width: person.width*0.90,
                               height: person.height*0.50)
            return torso.contains(CGPoint(x: child.midX, y: child.midY))
        }

        var drawings: [PPERenderInfo] = []
        for (idx, _) in ordered.enumerated() {
            let trackIndex = ordered[idx].offset
            var t = tracks[trackIndex]
            let pBox = t.bbox

            let hMax  = maxConf(in: helmets,   parent: pBox)
            let nhMax = maxConf(in: noHelmets, parent: pBox)

            let torsoVests   = vests.filter   { isOnTorso(child: $0.boundingBox, of: pBox) }
            let torsoNoVests = noVests.filter { isOnTorso(child: $0.boundingBox, of: pBox) }
            func maxConf2(_ arr: [VNRecognizedObjectObservation]) -> Float { arr.map { $0.labels.first?.confidence ?? 0 }.max() ?? 0 }
            let vMax  = maxConf2(torsoVests)
            let nvMax = maxConf2(torsoNoVests)

            if config.debugMode {
                logger.debug("Track #\(t.id) hMax=\(hMax, format: .fixed(precision: 2))/nhMax=\(nhMax, format: .fixed(precision: 2)), vMax=\(vMax, format: .fixed(precision: 2))/nvMax=\(nvMax, format: .fixed(precision: 2))")
            }

            var helmetOKDecided: Bool?
            if hMax >= config.tHelmet && (hMax - nhMax) >= config.deltaMargin { helmetOKDecided = true }
            else if nhMax >= config.tNoHelmet && (nhMax - hMax) >= config.deltaMargin { helmetOKDecided = false }

            var vestOKDecided: Bool?
            if vMax >= config.tVest && (vMax - nvMax) >= config.deltaMargin { vestOKDecided = true }
            else if nvMax >= config.tNoVest && (nvMax - vMax) >= config.extraNoVestMargin { vestOKDecided = false }

            func majority(_ xs: [Bool]) -> Bool? {
                guard !xs.isEmpty else { return nil }
                let ones = xs.filter { $0 }.count
                let zeros = xs.count - ones
                return ones == zeros ? xs.last : (ones > zeros)
            }

            if let d = helmetOKDecided { t.helmetHist.append(d) }
            if let d = vestOKDecided   { t.vestHist.append(d) }
            if t.helmetHist.count > config.smoothWindow { t.helmetHist.removeFirst(t.helmetHist.count - config.smoothWindow) }
            if t.vestHist.count   > config.smoothWindow { t.vestHist.removeFirst(t.vestHist.count   - config.smoothWindow) }

            let helmetOK = majority(t.helmetHist) ?? (helmetOKDecided ?? false)
            let vestOK   = majority(t.vestHist)   ?? (vestOKDecided   ?? false)
            let allOK = helmetOK && vestOK
            tracks[trackIndex] = t

            let dispNo = displayIndex[trackIndex] ?? 0
            drawings.append(PPERenderInfo(normRectBL: pBox,
                                          allOK: allOK,
                                          helmetOK: helmetOK,
                                          vestOK: vestOK,
                                          title: "Person#\(dispNo)"))
        }
        return drawings
    }
}
