//
//  ManagerSignUpModel.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ManagerSignUpModel {
    func checkEmployeeNumberDuplicate(employeeId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("managerId", isEqualTo: employeeId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let isAvailable = snapshot?.documents.isEmpty ?? true
                    completion(.success(isAvailable))
                }
            }
    }
    
    func registerUser(name: String, phone: String,companyName:String, businessNumber: String, managerId: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let email = "\(managerId)@safe.com"
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "UID 생성 실패"])))
                return
            }

            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "uid": uid,
                "name": name,
                "companyName": companyName,
                "businessNumber": businessNumber,
                "managerId": managerId,
                "phoneNumber": phone,
                "Type": "manager"
            ]

            db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    
}
