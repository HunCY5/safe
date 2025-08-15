//
//  PPEDetectionOverlayView.swift
//  safe
//
//  Created by CHOI on 8/15/25.
//

import UIKit
import AVFoundation

final class PPEDetectionOverlayView: UIView {
    override class var layerClass: AnyClass { CAShapeLayer.self }
    private var labelLayers: [CATextLayer] = []

    func clear() {
        (layer as? CAShapeLayer)?.path = nil
        labelLayers.forEach { $0.removeFromSuperlayer() }
        labelLayers.removeAll()
    }

    func render(result: PPEDetectionResult?, with previewLayer: AVCaptureVideoPreviewLayer) {
        clear()
        guard let result = result else { return }
        // Vision → 미디어 → View 좌표 변환
        let bboxBL = result.personBoxVision
        let bboxTL = CGRect(x: bboxBL.origin.x,
                            y: 1.0 - bboxBL.origin.y - bboxBL.size.height,
                            width: bboxBL.size.width,
                            height: bboxBL.size.height)
        let rect = previewLayer.layerRectConverted(fromMetadataOutputRect: bboxTL)

        let shape = (layer as! CAShapeLayer)
        shape.path = UIBezierPath(rect: rect).cgPath
        shape.strokeColor = (result.allOK ? UIColor.systemGreen : UIColor.systemRed).cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 2

        let originText = (result.origin == .detected) ? "탐지" : "추정"
        let items: [(String, UIColor)] = [
            ("Person · \(originText)", result.allOK ? .systemGreen : .systemRed),
            (result.helmetOK ? "Helmet" : "No Helmet", result.helmetOK ? .systemGreen : .systemRed),
            (result.vestOK   ? "Vest"   : "No Vest",   result.vestOK   ? .systemGreen : .systemRed)
        ]
        drawStackedLabels(above: rect, items: items)
    }

    private func drawStackedLabels(above rect: CGRect, items: [(String, UIColor)]) {
        var y = max(rect.minY - 4, 0)
        for (text, color) in items.reversed() {
            let tl = CATextLayer()
            tl.contentsScale = UIScreen.main.scale
            tl.fontSize = 12
            tl.alignmentMode = .left
            tl.foregroundColor = UIColor.white.cgColor
            tl.backgroundColor = color.cgColor
            let pad: CGFloat = 4
            let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
            let w = size.width + pad * 2
            let h = size.height + pad
            y -= (h + 2)
            tl.string = text
            tl.frame = CGRect(x: rect.minX, y: y, width: w, height: h)
            layer.addSublayer(tl)
            labelLayers.append(tl)
        }
    }
}
