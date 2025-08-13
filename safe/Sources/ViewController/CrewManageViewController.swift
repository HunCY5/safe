//
//  CrewManageViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CrewManageViewController: UIViewController {
  
    private var crewManageView = CrewManageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        self.title = "근로자 관리"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .white

        view.addSubview(crewManageView)

        crewManageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            crewManageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            crewManageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            crewManageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            crewManageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        
        crewManageView.registerCrewView.inviteButton.addTarget(self, action: #selector(registerCrewTapped), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func registerCrewTapped() {
        let textField = crewManageView.registerCrewView.employeeTextField
        guard let employeeId = textField.text, !employeeId.isEmpty else {
            showAlert(message: "사번을 입력해주세요.")
            return
        }

        guard let currentUser = Auth.auth().currentUser else {
            print("현재 로그인된 사용자가 없습니다.")
            return
        }

        let db = Firestore.firestore()

        db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("현재 사용자 정보 조회 실패: \(error?.localizedDescription ?? "알 수 없는 에러")")
                return
            }

            guard let companyName = data["companyName"] as? String else {
                print("현재 사용자 companyName 없음")
                return
            }

            db.collection("users").whereField("employeeId", isEqualTo: employeeId).getDocuments { querySnapshot, error in
                guard let docs = querySnapshot?.documents, let match = docs.first else {
                    self.showAlert(message: "해당 사번과 일치하는 사용자를 찾을 수 없습니다.")
                    return
                }

                let matchedUser = match.data()
                guard let matchedCompany = matchedUser["companyName"] as? String,
                      matchedCompany == companyName else {
                    self.showAlert(message: "해당 사번과 일치하는 사용자를 찾을 수 없습니다.")
                    return
                }

                let matchedUID = match.documentID
                let ref = db.collection(companyName).document(matchedUID)
                ref.getDocument { docSnapshot, err in
                    if let err = err {
                        print("기존 등록 여부 확인 실패: \(err.localizedDescription)")
                        return
                    }

                    if let doc = docSnapshot, doc.exists {
                        let alert = UIAlertController(title: "안내", message: "이미 등록된 근무자입니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                        return
                    }

                    ref.setData([
                        "registeredAt": Timestamp(),
                        "registeredBy": currentUser.uid
                    ]) { err in
                        if let err = err {
                            print("등록 실패: \(err.localizedDescription)")
                        } else {
                            print("근무자 등록 성공")
                            let alert = UIAlertController(title: "성공", message: "근무자 등록이 완료되었습니다.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
