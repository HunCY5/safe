//
//  ManagerLoginViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

class ManagerLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white

        let managerLoginView = ManagerLoginView()
        managerLoginView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(managerLoginView)

        NSLayoutConstraint.activate([
            managerLoginView.topAnchor.constraint(equalTo: view.topAnchor),
            managerLoginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            managerLoginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            managerLoginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
