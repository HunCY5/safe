//
//  PPEDetectionOverlayView.swift
//  safe
//
//  Created by CHOI on 8/15/25.
//

import UIKit
import AVFoundation

// 컨트롤러가 붙여둔 previewLayer 좌표계로 사람 박스 생성, PPE 착용 유무 스택으로 표시

public final class PPEDetectionOverlayView: UIView {
    public weak var previewLayer: AVCaptureVideoPreviewLayer?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func render(results: [PPERenderInfo]) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        for d in results {
            guard let pl = previewLayer else { continue }
            let rectTL = PPEGeom.toTopLeftNorm(fromBL: d.normRectBL)
            let rectInView = pl.layerRectConverted(fromMetadataOutputRect: rectTL)
            drawRect(rectInView, color: d.allOK ? .systemGreen : .systemRed)

            var items: [(String, UIColor)] = [
                (d.title, d.allOK ? .systemGreen : .systemRed),
                (d.helmetOK ? "Helmet" : "No Helmet", d.helmetOK ? .systemGreen : .systemRed),
                (d.vestOK ? "Vest" : "No Vest", d.vestOK ? .systemGreen : .systemRed)
            ]
            drawStackedLabels(above: rectInView, items: items)
        }
    }

    private func drawRect(_ rect: CGRect, color: UIColor) {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(rect: rect).cgPath
        shape.strokeColor = color.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 2
        layer.addSublayer(shape)
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
        }
    }
}
