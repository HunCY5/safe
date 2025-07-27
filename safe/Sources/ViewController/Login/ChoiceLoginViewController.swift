//
//  ChoiceLoginViewController.swift
//  safe
//
//  Created by 신찬솔 on 7/27/25.
//

import UIKit

class ChoiceLoginViewController: UIViewController, ChoiceLoginViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTappedAround()
        view.backgroundColor = .white

        let choiceLoginView = ChoiceLoginView()
        choiceLoginView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(choiceLoginView)
        choiceLoginView.delegate = self

        NSLayoutConstraint.activate([
            choiceLoginView.topAnchor.constraint(equalTo: view.topAnchor),
            choiceLoginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            choiceLoginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            choiceLoginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func didTapWorkerCard() {
        let vc = CrewLoginViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapManagerCard() {
        let vc = ManagerLoginViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
