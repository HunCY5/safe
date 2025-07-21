// Copyright 2021 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================
//
// Modifications by Chansol Shin on 2025-07-22
// - Added call to PoseAngle.measureJointAngles(from:) in runModel(_:) to log joint angles.
// =============================================================================

import AVFoundation
import UIKit
import os

final class ViewController: UIViewController {
  private var overlayView: OverlayView!
  private var modelType: ModelType = Constants.defaultModelType
  private var threadCount: Int = Constants.defaultThreadCount
  private var delegate: Delegates = Constants.defaultDelegate
  private let minimumScore = Constants.minimumScore

  
  private var imageViewFrame: CGRect?
  var overlayImage: OverlayView?
  private var poseEstimator: PoseEstimator?
  private var cameraFeedManager: CameraFeedManager!


  let queue = DispatchQueue(label: "serial_queue")

  var isRunning = false

  override func viewDidLoad() {
    super.viewDidLoad()
    setupOverlayView()
    updateModel()
    configCameraCapture()
  }

  private func setupOverlayView() {
    let topView = UIView()
    topView.backgroundColor = UIColor(white: 0.0, alpha: 0.47)
    topView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(topView)

    overlayView = OverlayView()
    overlayView.contentMode = .scaleAspectFill
    overlayView.clipsToBounds = true
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(overlayView)

    NSLayoutConstraint.activate([
      topView.topAnchor.constraint(equalTo: view.topAnchor),
      topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topView.heightAnchor.constraint(equalToConstant: 171),

      overlayView.topAnchor.constraint(equalTo: topView.bottomAnchor),
      overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      overlayView.heightAnchor.constraint(equalToConstant: 525),
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    cameraFeedManager?.startRunning()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    cameraFeedManager?.stopRunning()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    imageViewFrame = overlayView.frame
  }

  private func configCameraCapture() {
    cameraFeedManager = CameraFeedManager()
    cameraFeedManager.startRunning()
    cameraFeedManager.delegate = self
  }

  
  private func updateModel() {
    queue.async {
      do {
        switch self.modelType {
        case .posenet:
          self.poseEstimator = try PoseNet(
            threadCount: self.threadCount,
            delegate: self.delegate)
        case .movenetLighting, .movenetThunder:
          self.poseEstimator = try MoveNet(
            threadCount: self.threadCount,
            delegate: self.delegate,
            modelType: self.modelType)
        }
      } catch let error {
        os_log("Error: %@", log: .default, type: .error, String(describing: error))
      }
    }
  }

  @IBAction private func threadStepperValueChanged(_ sender: UIStepper) {
    threadCount = Int(sender.value)
    updateModel()
  }
  @IBAction private func delegatesValueChanged(_ sender: UISegmentedControl) {
    delegate = Delegates.allCases[sender.selectedSegmentIndex]
    updateModel()
  }

  @IBAction private func modelTypeValueChanged(_ sender: UISegmentedControl) {
    modelType = ModelType.allCases[sender.selectedSegmentIndex]
    updateModel()
  }
}

// MARK: - CameraFeedManagerDelegate Methods
extension ViewController: CameraFeedManagerDelegate {
  func cameraFeedManager(
    _ cameraFeedManager: CameraFeedManager, didOutput pixelBuffer: CVPixelBuffer
  ) {
    self.runModel(pixelBuffer)
  }

  private func runModel(_ pixelBuffer: CVPixelBuffer) {
    guard !isRunning else { return }

    guard let estimator = poseEstimator else { return }
    queue.async {
      self.isRunning = true
      defer { self.isRunning = false }
      do {
        let (result, times) = try estimator.estimateSinglePose(
            on: pixelBuffer)
        DispatchQueue.main.async {
      
          let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))

          if result.score < self.minimumScore {
            self.overlayView.image = image
            return
          }
          self.overlayView.draw(at: image, person: result)
          PoseAngle.measureJointAngles(from: result.keyPoints)
        }
      } catch {
        os_log("Error running pose estimation.", type: .error)
        return
      }
    }
  }
}

enum Constants {
  static let defaultThreadCount = 4
  static let defaultDelegate: Delegates = .gpu
  static let defaultModelType: ModelType = .movenetThunder
  static let minimumScore: Float32 = 0.2
}
