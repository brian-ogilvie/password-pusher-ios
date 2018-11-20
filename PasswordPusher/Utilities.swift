//
//  Utilities.swift
//  PasswordPusher
//
// Copyright 2018 ArcTouch, LLC.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//
import UIKit

func showBasicAlert(message: String) -> UIAlertController {
    let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertVC.addAction(dismiss)
    
    return alertVC
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
