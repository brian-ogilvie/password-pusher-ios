//
//  ErrorMessage.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 11/27/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

enum UrlSessionError: Error {
    case urlCreationError// = "Unable to ceate URL"
    case httpBodyCreationError// = "Unable to create httpBody"
    case noServerResponse// = "Unable to get response from server"
    case emptyDataInResponse// = "Server response contained no data"
    case unknownSessionError// = "Unknown session error"
}
