//
//  SharePasswordActivityItemProvider.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 10/29/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class SharePasswordActivityItemProvider: UIActivityItemProvider {
    var urlToShare: String
    
    init(urlToShare: String) {
        self.urlToShare = urlToShare
        super.init(placeholderItem: Strings.placeholder)
    }
    
    override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return Strings.placeholder
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return Strings.bodyPrefix + urlToShare
    }
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return Strings.emailSubject
    }
}

private struct Strings {
    static let placeholder = "This is the body."
    static let emailSubject = "Your new login credentials"
    static let bodyPrefix = "Your password: "
}
