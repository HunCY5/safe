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
// Modifications by Chansol Shin on 2025-07-22

import UIKit
import FirebaseCore
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  
      // Firebase 초기화
      FirebaseApp.configure()

      // 강제로 로그아웃 (자동 로그인 방지 목적)
     try? Auth.auth().signOut()

      if let user = Auth.auth().currentUser {
          print("✅ 로그인됨: \(user.uid)")
          print("이메일: \(user.email ?? "없음")")
          print("익명 사용자?: \(user.isAnonymous)")
          
          if user.isAnonymous {
              print("⚠️ 익명 로그인 상태입니다. 일반 로그인 필요")
          } else {
              print("✅ 일반 사용자 로그인 상태입니다.")
          }
      } else {
          print("❌ 로그인된 사용자 없음")
      }
      
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
  }

  func applicationWillTerminate(_ application: UIApplication) {
  }
}
