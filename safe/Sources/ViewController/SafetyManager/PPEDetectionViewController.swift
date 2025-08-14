//
//  PPEDetectionViewController.swift
//  safe
//
//  Created by CHOI on 8/15/25.
//

import UIKit
import AVFoundation
import OSLog

// 카메라 세팅/수집 담당
// 프레임 -> PPEDetector로 전달

final class PPEDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, PPEDetectorDelegate {

    // MARK: - Properties
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let overlay = PPEDetectionOverlayView()
    private let visionQueue = DispatchQueue(label: "vision.queue", qos: .userInitiated)
    private let log = Logger(subsystem: "com.yolodemo.app", category: "vision")

    private let detector = PPEDetector(modelName: "DetectionYolo11", config: {
        var c = PPEConfig()
        c.debugMode = true
        return c
    }())

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupOverlay()
        detector.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        overlay.frame = view.bounds
    }

    // MARK: - Camera
    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { fatalError("Camera input failed") }
        session.addInput(input)

        try? device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) { device.focusMode = .continuousAutoFocus }
        if device.isExposureModeSupported(.continuousAutoExposure) { device.exposureMode = .continuousAutoExposure }
        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) { device.whiteBalanceMode = .continuousAutoWhiteBalance }
        device.unlockForConfiguration()

        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: visionQueue)
        guard session.canAddOutput(videoOutput) else { fatalError("Cannot add video output") }
        session.addOutput(videoOutput)

        let conn = videoOutput.connection(with: .video)
        conn?.videoOrientation = .portrait

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        session.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in self?.session.startRunning() }
    }

    private func setupOverlay() {
        overlay.frame = view.bounds
        overlay.previewLayer = previewLayer
        overlay.isUserInteractionEnabled = false
        view.addSubview(overlay)
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        // iPhone 세로 고정 촬영 가정
        detector.process(pixelBuffer: pb, orientation: .right)
    }

    // MARK: - PPEDetectorDelegate
    func ppeDetector(_ detector: PPEDetector, didProduce results: [PPERenderInfo]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.overlay.previewLayer = self.previewLayer // 안전
            self.overlay.render(results: results)
        }
    }
}
