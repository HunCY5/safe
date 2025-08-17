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

import Accelerate
import Foundation

extension CGSize {
    
  func transformKeepAspect(toFitIn dest: CGSize) -> CGAffineTransform {
    let sourceRatio = self.height / self.width
    let destRatio = dest.height / dest.width

    // Calculates ratio `self` to `dest`.
    var ratio: CGFloat
    var x: CGFloat = 0
    var y: CGFloat = 0
    if sourceRatio > destRatio {
      // Source size is taller than destination. Resized to fit in destination height, and find
      // horizontal starting point to be centered.
      ratio = dest.height / self.height
      x = (dest.width - self.width * ratio) / 2
    } else {
      ratio = dest.width / self.width
      y = (dest.height - self.height * ratio) / 2
    }
    return CGAffineTransform(a: ratio, b: 0, c: 0, d: ratio, tx: x, ty: y)
  }

    /// 추가: AspectFill (잘리더라도 화면 꽉 채움)
    func transformKeepAspectFill(toFillIn dest: CGSize) -> CGAffineTransform {
      let sourceRatio = self.height / self.width
      let destRatio = dest.height / dest.width

      var ratio: CGFloat
      var x: CGFloat = 0
      var y: CGFloat = 0
      if sourceRatio > destRatio {
        // 화면이 더 넓을 때 → 폭 기준으로 맞추고, 세로는 잘릴 수 있음
        ratio = dest.width / self.width
        y = (dest.height - self.height * ratio) / 2
      } else {
        // 화면이 더 좁을 때 → 높이 기준으로 맞추고, 좌우가 잘릴 수 있음
        ratio = dest.height / self.height
        x = (dest.width - self.width * ratio) / 2
      }
      return CGAffineTransform(a: ratio, b: 0, c: 0, d: ratio, tx: x, ty: y)
    }
  }
