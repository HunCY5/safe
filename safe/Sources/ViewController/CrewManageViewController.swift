//
//  CrewManageViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

class CrewManageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ ViewController.viewDidLoad 실행됨")

        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = "👋 Hello, UIKit!"
        label.textColor = .label
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
