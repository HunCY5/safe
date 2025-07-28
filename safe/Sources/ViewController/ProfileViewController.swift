//
//  ProfileViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    private var profileView: ProfileView?
    // MARK: - 근무 타이머 누적 상태 저장
    private var workedSeconds: Int = 0
    private var lastStartTime: Date?
    private var isPaused: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        self.title = "프로필 관리"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .white

        guard let user = Auth.auth().currentUser else {
            self.profileView = ProfileView(
                frame: .zero,
                isLoggedIn: false,
                userName: "",
                userId: "",
                isManager: false
            )
            guard let profileView = self.profileView else { return }
            profileView.translatesAutoresizingMaskIntoConstraints = false
            profileView.delegate = self
            view.addSubview(profileView)
            NSLayoutConstraint.activate([
                profileView.topAnchor.constraint(equalTo: view.topAnchor),
                profileView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let error = error {
                print("유저 정보 가져오기 실패: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("유저 정보 없음")
                return
            }

            let name = data["name"] as? String ?? "알 수 없음"
            let type = data["Type"] as? String ?? "crew"
            let phoneNumber = data["phoneNumber"] as? String ?? "알 수 없음"
            let companyName = data["companyName"] as? String ?? "알 수 없음"
            let businessNumber = data["businessNumber"] as? String
            let id: String
            if type == "manager" {
                id = data["managerId"] as? String ?? "N/A"
            } else {
                id = data["employeeId"] as? String ?? "N/A"
            }

            DispatchQueue.main.async {
                self.profileView = ProfileView(
                    frame: .zero,
                    isLoggedIn: true,
                    userName: name,
                    userId: "\(id)",
                    isManager: type == "manager"
                )
                guard let profileView = self.profileView else { return }
                profileView.translatesAutoresizingMaskIntoConstraints = false
                profileView.delegate = self
                self.view.addSubview(profileView)

                NSLayoutConstraint.activate([
                    profileView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    profileView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                    profileView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    profileView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                ])

                let privateInfoCard = profileView.setupPrivateInfoSection(
                    type: type,
                    phoneNumber: phoneNumber,
                    companyName: companyName,
                    businessNumber: businessNumber
                )
                profileView.contentStackView.insertArrangedSubview(privateInfoCard, at: 1)

                self.checkWorkingStatusFromFirebase()
            }
        }
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func didTapLoginButton() {
        let vc = ChoiceLoginViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapWorkerSignupButton() {
        let vc = CrewSignUpViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapManagerSignupButton() {
        let vc = ManagerSignUpViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapLogoutButton() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "예", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            do {
                try Auth.auth().signOut()

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    let tabBarController = MainTabBarController()
                    tabBarController.selectedIndex = 3
                    UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = tabBarController
                    })
                }
            } catch {
                print("로그아웃 실패: \(error.localizedDescription)")
            }
        }))
        present(alert, animated: true)
    }
}

// MARK: - 출퇴근/휴식 델리게이트 구현 및 Firestore 상태 업데이트
extension ProfileViewController {
    func didTapClockIn() {
        updateUserStatus(working: true, resting: false)
    }

    func didTapClockOut() {
        updateUserStatus(working: false, resting: false)
    }

    // MARK: - 휴식/재개 버튼 로직 개선 (실시간 Firestore 상태 확인)
    func didTapBreak() {
        handleBreakButtonTapped()
    }

    func didTapResume() {
        handleBreakButtonTapped()
    }

    // MARK: - 실시간 Firestore resting 상태 확인 후 휴식/재개 처리
    @objc private func handleBreakButtonTapped() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else { return }

            let isCurrentlyResting = data["resting"] as? Bool ?? false
            let currentWorked = data["workedSeconds"] as? Int ?? 0

            if isCurrentlyResting {
                let resumeTime = Date()
                userRef.updateData([
                    "resting": false,
                    "lastStartTime": Timestamp(date: resumeTime)
                ]) { [weak self] _ in
                    self?.workedSeconds = currentWorked
                    self?.lastStartTime = resumeTime
                    self?.startTimer(from: resumeTime)
                    self?.profileView?.breakButton.setTitle("휴식", for: .normal)
                    self?.profileView?.breakButton.backgroundColor = .systemGreen
                }
            } else {
                let pauseTime = Date()
                self.stopTimer()
                let elapsedThisSession = self.lastStartTime.map { Int(pauseTime.timeIntervalSince($0)) } ?? 0
                let totalWorked = currentWorked + elapsedThisSession
                userRef.updateData([
                    "resting": true,
                    "workedSeconds": totalWorked
                ]) { [weak self] _ in
                    self?.workedSeconds = totalWorked
                    self?.profileView?.breakButton.setTitle("재개", for: .normal)
                    self?.profileView?.breakButton.backgroundColor = .orange
                }
            }
        }
    }

    // MARK: - 타이머 제어 함수
    private func startTimer(from date: Date) {
        guard let clockIn = self.lastStartTime else { return }
        let elapsed = Int(Date().timeIntervalSince(clockIn)) + self.workedSeconds
        self.profileView?.startTimer(withElapsed: elapsed)
    }
    private func stopTimer() {
        self.profileView?.stopTimer()
    }

    private func applyTimerUI(working: Bool, resting: Bool, clockInTime: Date?, lastStartTime: Date?, workedSeconds: Int) {
        guard let profileView = self.profileView else { return }

        if working {
            profileView.clockInButton.isHidden = true
            profileView.attendanceStackView.isHidden = false

            var elapsed = workedSeconds
            if let lastStart = lastStartTime {
                if !resting {
                    elapsed += Int(Date().timeIntervalSince(lastStart))
                }
            }
            profileView.startTimer(withElapsed: elapsed)
            self.isPaused = resting
            self.profileView?.breakButton.setTitle(isPaused ? "재개" : "휴식", for: .normal)
            self.profileView?.breakButton.backgroundColor = isPaused ? .orange : .systemGreen
            if resting {
                profileView.stopTimer()
            }
        } else {
            profileView.clockInButton.isHidden = false
            profileView.attendanceStackView.isHidden = true
            profileView.stopTimer()
            profileView.startTimer(withElapsed: 0)
            profileView.stopTimer()
        }
    }

    private func checkWorkingStatusFromFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }

            let working = data["working"] as? Bool ?? false
            let resting = data["resting"] as? Bool ?? false
            if let workedSeconds = data["workedSeconds"] as? Int {
                self.workedSeconds = workedSeconds
            }
            let lastStartTS = data["lastStartTime"] as? Timestamp
            let clockInTS = data["clockInTime"] as? Timestamp

            self.lastStartTime = lastStartTS?.dateValue()

            DispatchQueue.main.async {
                self.applyTimerUI(
                    working: working,
                    resting: resting,
                    clockInTime: clockInTS?.dateValue(),
                    lastStartTime: self.lastStartTime,
                    workedSeconds: self.workedSeconds
                )
                if resting {
                    if let profileView = self.profileView {
                        profileView.timerLabel.text = profileView.formatTime(self.workedSeconds)
                    }
                }
            }
        }
    }

    // MARK: - Firestore 상태 업데이트
    private func updateUserStatus(working: Bool? = nil, resting: Bool? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)

        ref.getDocument { [weak self] snap, error in
            guard let self = self else { return }
            var updates: [String: Any] = [:]

            let now = Date()
            let data = snap?.data() ?? [:]

            var currentWorked = data["workedSeconds"] as? Int ?? 0
            let currentWorking = data["working"] as? Bool ?? false
            let currentResting = data["resting"] as? Bool ?? false
            let currentLastStart = (data["lastStartTime"] as? Timestamp)?.dateValue()

            // 1) 출근
            if let working = working, working == true {
                currentWorked = 0
                updates["working"] = true
                updates["resting"] = false
                updates["clockInTime"] = Timestamp(date: now)
                updates["lastStartTime"] = Timestamp(date: now)
                updates["workedSeconds"] = currentWorked
            }

            // 2) 퇴근
            if let working = working, working == false {
                if currentWorking, let lastStart = currentLastStart {
                    currentWorked += Int(now.timeIntervalSince(lastStart))
                }
                updates["working"] = false
                updates["resting"] = false
                updates["clockInTime"] = FieldValue.delete()
                updates["workedSeconds"] = FieldValue.delete()
                updates["lastStartTime"] = FieldValue.delete()
            }

            // 3) 휴식 시작
            if let resting = resting, resting == true {
                if currentWorking, !currentResting, let lastStart = currentLastStart {
                    currentWorked += Int(now.timeIntervalSince(lastStart))
                }
                updates["resting"] = true
                updates["workedSeconds"] = currentWorked
                updates["lastStartTime"] = FieldValue.delete()
            }

            // 4) 재개
            if let resting = resting, resting == false, working != false {
                updates["resting"] = false
                updates["lastStartTime"] = Timestamp(date: now)
            }

            ref.updateData(updates) { err in
                if let err = err {
                    print("출퇴근 상태 업데이트 실패: \(err.localizedDescription)")
                } else {
                    print("출퇴근 상태 업데이트 성공")
                    self.checkWorkingStatusFromFirebase()
                }
            }
        }
    }
}
