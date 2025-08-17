
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
// =============================================================================

import AVFoundation
import UIKit
import os
import Combine


// MARK: - Weight Picker for REBA/OWAS
private let weightPickerView: UIPickerView = {
  let picker = UIPickerView()
  picker.translatesAutoresizingMaskIntoConstraints = false
  picker.isHidden = true
  return picker
}()

private let weightOptions = Array(0...50).map { "\($0)kg" }

final class WeightSelection: ObservableObject {
  @Published var selectedWeight: Int = 0
}

final class RiskDetectionViewController: UIViewController {

  // Lifecycle state flag
  private var isActive: Bool = false

  private let weightSelection = WeightSelection()
  private var cancellables = Set<AnyCancellable>()

  private let evaluationLabel: UILabel = {
    let label = UILabel()
    label.text = "측정 결과 없음"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private var overlayView: OverlayView!

  // PPE 통합
  private let ppeDetector = PPEDetector(modelName: "DetectionYolov11")
  private let ppeOverlayView = PPEDetectionOverlayView()
  private var latestImageSize: CGSize = .zero

  // 위험 로깅
  private let riskLogger = PPERiskLogger()
  private var lastBaseFrame: UIImage?

  // 모델 설정
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

  // 옵션 토글 상태
  private var isPostureOn = true
  private var isHelmetOn = true
  private var isVestOn = true

  enum EvaluationMethod: String, CaseIterable {
    case none = "자세평가X"
    case rula = "RULA"
    case reba = "REBA"
    case owas = "OWAS"

    var interval: TimeInterval {
      switch self {
      case .none: return 0
      case .rula, .reba, .owas: return 2.0
      }
    }
  }

  private var selectedEvaluationMethod: EvaluationMethod = .none {
    didSet { resetEvaluationTimer() }
  }
  private var evaluationTimer: Timer?

  private let segmentedControl: UISegmentedControl = {
    let control = UISegmentedControl(items: EvaluationMethod.allCases.map(\.rawValue))
    control.selectedSegmentIndex = 0
    control.translatesAutoresizingMaskIntoConstraints = false
    return control
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupOverlayView()

    // 네비게이션 바 버튼 메뉴 구성
    func makeMenu() -> UIMenu {
      let postureAction = UIAction(title: "자세 평가", state: isPostureOn ? .on : .off) { [weak self] _ in
        guard let self = self else { return }
        self.isPostureOn.toggle()
        self.resetEvaluationTimer()
        self.navigationItem.rightBarButtonItem?.menu = makeMenu()
      }
      let helmetAction = UIAction(title: "안전모", state: isHelmetOn ? .on : .off) { [weak self] _ in
        guard let self = self else { return }
        self.isHelmetOn.toggle()
        if !(self.isHelmetOn || self.isVestOn) { self.ppeOverlayView.clear() }
        self.navigationItem.rightBarButtonItem?.menu = makeMenu()
      }
      let vestAction = UIAction(title: "안전조끼", state: isVestOn ? .on : .off) { [weak self] _ in
        guard let self = self else { return }
        self.isVestOn.toggle()
        if !(self.isHelmetOn || self.isVestOn) { self.ppeOverlayView.clear() }
        self.navigationItem.rightBarButtonItem?.menu = makeMenu()
      }
      return UIMenu(title: "표시/평가 항목", children: [postureAction, helmetAction, vestAction])
    }
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "옵션", image: nil, primaryAction: nil, menu: makeMenu())

    // PPE 오버레이(자세 오버레이와 동일 프레임)
    ppeOverlayView.backgroundColor = .clear
    ppeOverlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(ppeOverlayView)
    NSLayoutConstraint.activate([
      ppeOverlayView.topAnchor.constraint(equalTo: overlayView.topAnchor),
      ppeOverlayView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
      ppeOverlayView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
      ppeOverlayView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),
    ])

    // 기존 UI
    view.addSubview(segmentedControl)
    segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
    NSLayoutConstraint.activate([
      segmentedControl.topAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: 8),
      segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    ])

    view.addSubview(evaluationLabel)
    NSLayoutConstraint.activate([
      evaluationLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
      evaluationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])

    // 무게 피커
    view.addSubview(weightPickerView)
    weightPickerView.dataSource = self
    weightPickerView.delegate = self
    NSLayoutConstraint.activate([
      weightPickerView.topAnchor.constraint(equalTo: evaluationLabel.bottomAnchor, constant: 12),
      weightPickerView.leadingAnchor.constraint(equalTo: evaluationLabel.leadingAnchor),
      weightPickerView.trailingAnchor.constraint(equalTo: evaluationLabel.trailingAnchor),
      weightPickerView.heightAnchor.constraint(equalToConstant: 80)
    ])

    // Combine: 무게 변경 바인딩
    weightSelection.$selectedWeight
      .sink { [weak self] newWeight in
        switch self?.selectedEvaluationMethod {
        case .rula:
          RULAEvaluator.selectedWeight = newWeight
        case .reba:
          REBAEvaluator.selectedWeight = newWeight
        case .owas:
          OWASEvaluator.selectedWeight = newWeight
          break
        default: break
        }
      }
      .store(in: &cancellables)

    ppeDetector.delegate = self

    riskLogger.sectorProvider = { SafetyManagerViewController.currentSectorName }
    riskLogger.thresholdSeconds = 10.0 

    OWASEvaluator.screenshotProvider = { [weak self] in
      guard let self = self else { return nil }
      return self.makeSkeletonOnlyScreenshot()
    }
    OWASEvaluator.saveHandler = { [weak self] image, score, poseType in
      guard let _ = self else { return }
      PostureRiskLogger.shared.sectorProvider = { SafetyManagerViewController.currentSectorName }
      PostureRiskLogger.shared.minInterval = 5
      PostureRiskLogger.shared.upload(image: image, poseType: poseType, score: score, completion: nil)
    }
    RULAEvaluator.screenshotProvider = { [weak self] in
        self?.makeSkeletonOnlyScreenshot()
    }
    RULAEvaluator.saveHandler = { [weak self] image, score, _ in
        guard let self = self else { return }
        PostureRiskLogger.shared.sectorProvider = { SafetyManagerViewController.currentSectorName }
        PostureRiskLogger.shared.minInterval = 5
        PostureRiskLogger.shared.upload(image: image, poseType: "RULA", score: score, completion: nil)
    }

    REBAEvaluator.screenshotProvider = { [weak self] in
        self?.makeSkeletonOnlyScreenshot()
    }
    REBAEvaluator.saveHandler = { [weak self] image, score, _ in
        guard let self = self else { return }
        PostureRiskLogger.shared.sectorProvider = { SafetyManagerViewController.currentSectorName }
        PostureRiskLogger.shared.minInterval = 5
        PostureRiskLogger.shared.upload(image: image, poseType: "REBA", score: score, completion: nil)
      }

    updateModel()
    configCameraCapture()
    resetEvaluationTimer()
  }

  private func setupOverlayView() {
    overlayView = OverlayView()
    overlayView.contentMode = .scaleAspectFill
    overlayView.clipsToBounds = true
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(overlayView)

    NSLayoutConstraint.activate([
      overlayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      overlayView.heightAnchor.constraint(equalToConstant: 525),
    ])
  }

  private func resetEvaluationTimer() {
    evaluationTimer?.invalidate()
    // 자세평가 Off 이거나, 선택이 none 이면 라벨 초기화하고 종료
    guard isPostureOn, selectedEvaluationMethod != .none else {
      DispatchQueue.main.async {
        self.evaluationLabel.text = "측정 결과 없음"
        self.evaluationLabel.textColor = .label
      }
      return
    }
    guard isActive else { return }

    evaluationTimer = Timer.scheduledTimer(withTimeInterval: selectedEvaluationMethod.interval, repeats: true) { [weak self] _ in
      guard let self = self,
            self.isPostureOn,
            self.selectedEvaluationMethod != .none,
            let keypoints = self.overlayView.latestKeypoints,
            let angles = PoseAngle.measureJointAngles(from: keypoints) else { return }
        
      print("✅ \(self.selectedEvaluationMethod.rawValue) 측정 완료")

      switch self.selectedEvaluationMethod {
      case .rula:
        if let (summary, color, score) = RULAEvaluator.evaluateAndSummarize(
          from: angles,
          keypoints: Dictionary(uniqueKeysWithValues: keypoints.map { ($0.bodyPart, $0.coordinate) })
        ) {
          DispatchQueue.main.async {
            self.evaluationLabel.text = "\(summary) (\(score))"
            self.evaluationLabel.textColor = color
          }
        }
      case .reba:
        if let (summary, color, score) = REBAEvaluator.evaluateAndSummarize(from: angles) {
          DispatchQueue.main.async {
            self.evaluationLabel.text = "\(summary) (\(score))"
            self.evaluationLabel.textColor = color
          }
        }
      case .owas:
        if let (summary, color, score) = OWASEvaluator.evaluateAndSummarize(
          from: angles,
          keypoints: Dictionary(uniqueKeysWithValues: keypoints.map { ($0.bodyPart, $0.coordinate) })
        ) {
          DispatchQueue.main.async {
            self.evaluationLabel.text = "\(summary) (\(score))"
            self.evaluationLabel.textColor = color
          }
        }
      case .none: break
      }
    }
  }

    private func makeSkeletonOnlyScreenshot() -> UIImage? {
        guard isActive else { return nil }
        guard let base = lastBaseFrame else { return nil }
        guard let keypoints = overlayView.latestKeypoints else { return nil }

        let targetSize = overlayView.bounds.size
        guard targetSize.width > 0, targetSize.height > 0 else { return nil }

        let rect = Self.aspectFillRect(for: base.size, in: targetSize)
        let scale = max(rect.width / base.size.width, rect.height / base.size.height)

        func mapPoint(_ p: CGPoint) -> CGPoint {
            let px: CGFloat
            let py: CGFloat
            if (0...1).contains(p.x) && (0...1).contains(p.y) {
                px = p.x * base.size.width
                py = p.y * base.size.height
            } else {
                px = p.x
                py = p.y
            }
            let x = rect.minX + px * scale
            let y = rect.minY + py * scale
            return CGPoint(x: x, y: y)
        }

        let pairs: [(BodyPart, BodyPart)] = [
            (.leftWrist, .leftElbow), (.leftElbow, .leftShoulder),
            (.leftShoulder, .rightShoulder),
            (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
            (.leftShoulder, .leftHip), (.leftHip, .rightHip), (.rightHip, .rightShoulder),
            (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
            (.rightHip, .rightKnee), (.rightKnee, .rightAnkle),
        ]

        let dict = Dictionary(uniqueKeysWithValues: keypoints.map { ($0.bodyPart, $0.coordinate) })

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let shot = renderer.image { ctx in
            base.draw(in: rect)

            let cg = ctx.cgContext
            cg.setBlendMode(.normal)
            cg.setLineWidth(3)
            cg.setLineCap(.round)
            cg.setLineJoin(.round)
            cg.setStrokeColor(UIColor.orange.cgColor)
            cg.setFillColor(UIColor.orange.cgColor)

            cg.beginPath()
            for (a, b) in pairs {
                if let p1 = dict[a], let p2 = dict[b] {
                    let m1 = mapPoint(p1)
                    let m2 = mapPoint(p2)
                    cg.move(to: m1)
                    cg.addLine(to: m2)
                }
            }
            cg.strokePath()

            let r: CGFloat = 3.0
            for kp in keypoints {
                let pt = mapPoint(kp.coordinate)
                let dot = CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)
                cg.fillEllipse(in: dot)
            }
        }
        return shot
    }
    
  @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
    selectedEvaluationMethod = EvaluationMethod.allCases[sender.selectedSegmentIndex]
      // RULA/REBA/OWAS일 때만 무게 피커 보이기 (자세평가가 켜져 있을 때 의미 있음)
    let showWeight = (selectedEvaluationMethod == .rula || selectedEvaluationMethod == .reba || selectedEvaluationMethod == .owas)
    weightPickerView.isHidden = !showWeight
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    isActive = true
    cameraFeedManager?.startRunning()
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
    self.tabBarController?.tabBar.isHidden = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    isActive = false
    evaluationTimer?.invalidate()
    evaluationTimer = nil
    cameraFeedManager?.stopRunning()
    cameraFeedManager?.delegate = nil
    ppeDetector.delegate = nil
    overlayView.image = nil
    ppeOverlayView.clear()
    self.tabBarController?.tabBar.isHidden = false
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  deinit {
    evaluationTimer?.invalidate()
    cameraFeedManager?.stopRunning()
    cameraFeedManager?.delegate = nil
    ppeDetector.delegate = nil
    cancellables.removeAll()
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
          self.poseEstimator = try PoseNet(threadCount: self.threadCount, delegate: self.delegate)
        case .movenetLighting, .movenetThunder:
          self.poseEstimator = try MoveNet(threadCount: self.threadCount, delegate: self.delegate, modelType: self.modelType)
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
extension RiskDetectionViewController : CameraFeedManagerDelegate {
  func cameraFeedManager(_ cameraFeedManager: CameraFeedManager, didOutput pixelBuffer: CVPixelBuffer) {
    guard isActive else { return }
    // PPE 좌표 변환용 원본 이미지 크기 저장
    latestImageSize = pixelBuffer.size

    // 스크린샷(배경)용 원본 프레임 보관 (스켈레톤 제외용)
    lastBaseFrame = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))

    // 자세 평가 토글 ON이면 포즈 실행
    if isPostureOn {
      self.runModel(pixelBuffer)
    } else {
        // 꺼져 있으면 스켈레톤 초기화(현재 프레임만 표시)
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
        self.overlayView.image = image
      }
    }

    if isHelmetOn || isVestOn {
      ppeDetector.process(pixelBuffer: pixelBuffer, orientation: .right)
    } else {
      DispatchQueue.main.async { [weak self] in
        self?.ppeOverlayView.clear()
      }
    }
  }

  private func runModel(_ pixelBuffer: CVPixelBuffer) {
    guard isActive else { return }
    guard !isRunning else { return }
    guard let estimator = poseEstimator else { return }

    queue.async {
      self.isRunning = true
      defer { self.isRunning = false }
      do {
        let (result, _) = try estimator.estimateSinglePose(on: pixelBuffer)
        DispatchQueue.main.async {
          let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
          if result.score < self.minimumScore {
            self.overlayView.image = image
            return
          }
          self.overlayView.draw(at: image, person: result)
        }
      } catch {
        os_log("Error running pose estimation.", type: .error)
        return
      }
    }
  }
}

// MARK: - PPEDetectorDelegate
extension RiskDetectionViewController: PPEDetectorDelegate {
  func detector(_ detector: PPEDetector, didProduce result: PPEDetectionResult?) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self, self.isActive else { return }

      // 오버레이 갱신
      if self.isHelmetOn || self.isVestOn {
        if let r = result {
          self.ppeOverlayView.render(result: r,
                                     imageSize: self.latestImageSize,
                                     in: self.overlayView,
                                     showHelmetLabel: self.isHelmetOn,
                                     showVestLabel: self.isVestOn)

          // Risk 로깅
          self.riskLogger.handle(
            result: r,
            baseFrame: self.lastBaseFrame,
            makePPEScreenshot: { [weak self] in
              guard let self = self, let base = self.lastBaseFrame else { return nil }

              let targetSize = self.overlayView.bounds.size
              guard targetSize.width > 0, targetSize.height > 0 else { return nil }

              // 오프스크린 오버레이(YOLO 라벨/박스만)
              let tempOverlay = PPEDetectionOverlayView(frame: CGRect(origin: .zero, size: targetSize))
              let tempImageView = UIImageView(frame: CGRect(origin: .zero, size: targetSize))
              tempOverlay.isOpaque = false

              // 이미지 좌표계 기준 렌더(스켈레톤은 추가 X)
              tempOverlay.render(result: r,
                                 imageSize: base.size,
                                 in: tempImageView,
                                 showHelmetLabel: self.isHelmetOn,
                                 showVestLabel: self.isVestOn)

              // 최종 합성: 배경(원본 프레임, aspectFill) + YOLO 오버레이
              let renderer = UIGraphicsImageRenderer(size: targetSize)
              let shot = renderer.image { ctx in
                let rect = Self.aspectFillRect(for: base.size, in: targetSize)
                base.draw(in: rect)
                tempOverlay.layer.render(in: ctx.cgContext)
              }
              return shot
            },
            detectHelmet: self.isHelmetOn,
            detectVest: self.isVestOn
          )

        } else {
          self.ppeOverlayView.clear()
        }
      } else {
        self.ppeOverlayView.clear()
      }
    }
  }

  // 배경 이미지를 overlayView 크기에 맞게 채우는 rect
  private static func aspectFillRect(for imageSize: CGSize, in boundsSize: CGSize) -> CGRect {
    guard imageSize.width > 0, imageSize.height > 0, boundsSize.width > 0, boundsSize.height > 0 else {
      return CGRect(origin: .zero, size: boundsSize)
    }
    let scale = max(boundsSize.width / imageSize.width, boundsSize.height / imageSize.height)
    let w = imageSize.width * scale
    let h = imageSize.height * scale
    let x = (boundsSize.width - w) / 2
    let y = (boundsSize.height - h) / 2
    return CGRect(x: x, y: y, width: w, height: h)
  }
}

enum Constants {
  static let defaultThreadCount = 4
  static let defaultDelegate: Delegates = .gpu
  static let defaultModelType: ModelType = .movenetThunder
  static let minimumScore: Float32 = 0.2
}

// MARK: - UIPickerViewDataSource & Delegate
extension RiskDetectionViewController : UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { weightOptions.count }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    weightOptions[row]
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    weightSelection.selectedWeight = row
  }
}


