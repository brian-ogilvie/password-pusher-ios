//
//  Utilities.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 10/1/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

func showBasicAlert(message: String) -> UIAlertController {
    let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertVC.addAction(dismiss)
    
    return alertVC
}
