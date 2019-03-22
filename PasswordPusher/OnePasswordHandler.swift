//
//  OnePasswordHandler.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 3/22/19.
//  Copyright © 2019 Brian Ogilvie Development. All rights reserved.
//

import Foundation

struct OnePasswordHandler {
    func searchOnePassword(for urlString: String, presentOn viewController: UIViewController, sender: Any?, success: @escaping (_ password: String) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        OnePasswordExtension.shared().findLogin(forURLString: urlString, for: viewController, sender: sender) { (loginDictionary, error) in
            if let password = loginDictionary?[AppExtensionPasswordKey] as? String {
                success(password)
            } else {
                failure(error)
            }
        }
    }
}
