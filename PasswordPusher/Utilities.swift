//
//  Utilities.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 3/22/19.
//  Copyright © 2019 Brian Ogilvie Development. All rights reserved.

import UIKit

extension UIViewController {
    func showBasicAlert(message: String) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(dismiss)
        self.present(alertVC, animated: true)
    }
}

//constrains view1 to exact frame of view2
func matchConstraints(of view1: UIView, to view2: UIView) {
    view1.translatesAutoresizingMaskIntoConstraints = false
    let view1Leading = view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor)
    let view1Trailing = view1.trailingAnchor.constraint(equalTo: view2.trailingAnchor)
    let view1Top = view1.topAnchor.constraint(equalTo: view2.topAnchor)
    let view1Bottom = view1.bottomAnchor.constraint(equalTo: view2.bottomAnchor)
    
    NSLayoutConstraint.activate([view1Leading, view1Trailing, view1Top, view1Bottom])
}

func deactivateConstraints(from view: UIView) {
    for constraint in view.constraints {
        constraint.isActive = false
    }
}
