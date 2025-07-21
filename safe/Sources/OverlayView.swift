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
// - Added drawing of mid-shoulder to mid-ear line to visualize neck angle.
// =============================================================================

import UIKit
import os

class OverlayView: UIImageView {

  private enum Config {
    static let dot = (radius: CGFloat(10), color: UIColor.orange)
    static let line = (width: CGFloat(5.0), color: UIColor.orange)
  }

  private static let lines = [
    (from: BodyPart.leftWrist, to: BodyPart.leftElbow),
    (from: BodyPart.leftElbow, to: BodyPart.leftShoulder),
    (from: BodyPart.leftShoulder, to: BodyPart.rightShoulder),
    (from: BodyPart.rightShoulder, to: BodyPart.rightElbow),
    (from: BodyPart.rightElbow, to: BodyPart.rightWrist),
    (from: BodyPart.leftShoulder, to: BodyPart.leftHip),
    (from: BodyPart.leftHip, to: BodyPart.rightHip),
    (from: BodyPart.rightHip, to: BodyPart.rightShoulder),
    (from: BodyPart.leftHip, to: BodyPart.leftKnee),
    (from: BodyPart.leftKnee, to: BodyPart.leftAnkle),
    (from: BodyPart.rightHip, to: BodyPart.rightKnee),
    (from: BodyPart.rightKnee, to: BodyPart.rightAnkle),
  ]

  var context: CGContext!

  func draw(at image: UIImage, person: Person) {
    if context == nil {
      UIGraphicsBeginImageContext(image.size)
      guard let context = UIGraphicsGetCurrentContext() else {
        fatalError("set current context faild")
      }
      self.context = context
    }
    guard let strokes = strokes(from: person) else { return }
    image.draw(at: .zero)
    context.setLineWidth(Config.dot.radius)
    drawDots(at: context, dots: strokes.dots)
    drawLines(at: context, lines: strokes.lines)
    context.setStrokeColor(UIColor.blue.cgColor)
    context.strokePath()
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
    self.image = newImage
  }

  private func drawDots(at context: CGContext, dots: [CGPoint]) {
    for dot in dots {
      let dotRect = CGRect(
        x: dot.x - Config.dot.radius / 2, y: dot.y - Config.dot.radius / 2,
        width: Config.dot.radius, height: Config.dot.radius)
      let path = CGPath(
        roundedRect: dotRect, cornerWidth: Config.dot.radius, cornerHeight: Config.dot.radius,
        transform: nil)
      context.addPath(path)
    }
  }

  private func drawLines(at context: CGContext, lines: [Line]) {
    for line in lines {
      context.move(to: CGPoint(x: line.from.x, y: line.from.y))
      context.addLine(to: CGPoint(x: line.to.x, y: line.to.y))
    }
  }

  private func strokes(from person: Person) -> Strokes? {
    var strokes = Strokes(dots: [], lines: [])
    // MARK: Visualization of detection result
    var bodyPartToDotMap: [BodyPart: CGPoint] = [:]
    for (index, part) in BodyPart.allCases.enumerated() {
      let position = CGPoint(
        x: person.keyPoints[index].coordinate.x,
        y: person.keyPoints[index].coordinate.y)
      bodyPartToDotMap[part] = position
      strokes.dots.append(position)
    }

    // 어깨 중간점과 귀 중간점 계산 및 시각화 라인 추가
    if let leftShoulder = bodyPartToDotMap[.leftShoulder],
       let rightShoulder = bodyPartToDotMap[.rightShoulder],
       let leftEar = bodyPartToDotMap[.leftEar],
       let rightEar = bodyPartToDotMap[.rightEar] {

      let midShoulder = CGPoint(
        x: (leftShoulder.x + rightShoulder.x) / 2,
        y: (leftShoulder.y + rightShoulder.y) / 2
      )

      let midEar = CGPoint(
        x: (leftEar.x + rightEar.x) / 2,
        y: (leftEar.y + rightEar.y) / 2
      )

      strokes.dots.append(midShoulder)
      strokes.dots.append(midEar)
      strokes.lines.append(Line(from: midShoulder, to: midEar))
    }

    do {
      try strokes.lines += OverlayView.lines.map { map throws -> Line in
        guard let from = bodyPartToDotMap[map.from] else {
          throw VisualizationError.missingBodyPart(of: map.from)
        }
        guard let to = bodyPartToDotMap[map.to] else {
          throw VisualizationError.missingBodyPart(of: map.to)
        }
        return Line(from: from, to: to)
      }
    } catch VisualizationError.missingBodyPart(let missingPart) {
      os_log("Visualization error: %s is missing.", type: .error, missingPart.rawValue)
      return nil
    } catch {
      os_log("Visualization error: %s", type: .error, error.localizedDescription)
      return nil
    }
    return strokes
  }
}

fileprivate struct Strokes {
  var dots: [CGPoint]
  var lines: [Line]
}

fileprivate struct Line {
  let from: CGPoint
  let to: CGPoint
}

fileprivate enum VisualizationError: Error {
  case missingBodyPart(of: BodyPart)
}
