//
//  PPEDetectionViewController.swift
//  safe
//
//  Created by CHOI on 8/15/25.
//

import UIKit
import AVFoundation

final class PPEDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, PPEDetectorDelegate {

    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let overlayView = PPEDetectionOverlayView()

    private let detector = PPEDetector(modelName: "DetectionYolov11")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupOverlay()
        detector.delegate = self
    }

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
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "ppe.camera.queue", qos: .userInitiated))
        guard session.canAddOutput(videoOutput) else { fatalError("Cannot add video output") }
        session.addOutput(videoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        session.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in self?.session.startRunning() }
    }

    private func setupOverlay() {
        overlayView.frame = view.bounds
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        overlayView.frame = view.bounds
    }

    // MARK: Camera delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        detector.process(pixelBuffer: pb, orientation: .right)
    }

    // MARK: Detector delegate
    func detector(_ detector: PPEDetector, didProduce result: PPEDetectionResult?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.overlayView.render(result: result, with: self.previewLayer)
        }
    }
}
