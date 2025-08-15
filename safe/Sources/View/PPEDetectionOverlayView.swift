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

    // 기존: 카메라 미리보기 레이어 기반 렌더
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

    // 추가: OverlayView(UIImageView) + 원본 imageSize 기반 렌더
    func render(result: PPEDetectionResult?, imageSize: CGSize, in imageView: UIImageView) {
        clear()
        guard let result = result else { return }

        // 1) Vision BL(좌하) -> TL(좌상) 정규좌표
        let bl = result.personBoxVision
        let tl = CGRect(
            x: bl.minX,
            y: 1.0 - bl.minY - bl.height,
            width: bl.width,
            height: bl.height
        )

        // 2) 정규 -> 이미지 픽셀 좌표
        let imgRect = CGRect(
            x: tl.minX * imageSize.width,
            y: tl.minY * imageSize.height,
            width: tl.width * imageSize.width,
            height: tl.height * imageSize.height
        )

        // 3) 이미지 좌표 -> 이미지뷰 좌표 (aspect-fit/fill 보정)
        let t = imageSize.transformKeepAspectFill(toFillIn: imageView.bounds.size)
        let viewRect = imgRect.applying(t)

        // 4) 그리기
        let shape = (layer as! CAShapeLayer)
        shape.path = UIBezierPath(rect: viewRect).cgPath
        shape.strokeColor = (result.allOK ? UIColor.systemGreen : UIColor.systemRed).cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 2

        let originText = (result.origin == .detected) ? "탐지" : "추정"
        let items: [(String, UIColor)] = [
            ("Person · \(originText)", result.allOK ? .systemGreen : .systemRed),
            (result.helmetOK ? "Helmet" : "No Helmet", result.helmetOK ? .systemGreen : .systemRed),
            (result.vestOK   ? "Vest"   : "No Vest",   result.vestOK   ? .systemGreen : .systemRed)
        ]
        drawStackedLabels(above: viewRect, items: items)
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
