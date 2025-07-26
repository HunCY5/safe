//
//  CrewLoginViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//


import UIKit

class CrewLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white

        let crewLoginView = CrewLoginView()
        crewLoginView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(crewLoginView)

        NSLayoutConstraint.activate([
            crewLoginView.topAnchor.constraint(equalTo: view.topAnchor),
            crewLoginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            crewLoginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            crewLoginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
