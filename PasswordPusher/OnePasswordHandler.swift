//
//  OnePasswordHandler.swift
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
