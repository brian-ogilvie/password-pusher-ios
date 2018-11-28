//
//  HttpParameters.swift
//  PasswordPusher
//
//  Copyright 2018 ArcTouch, LLC.
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

struct HttpParameters: Codable {
    var payload: String
    var expireAfterDays: Int
    var expireAfterViews: Int
    
    enum CodingKeys: String, CodingKey {
        case payload
        case expireAfterDays = "expire_after_days"
        case expireAfterViews = "expire_after_views"
    }
    init(payload: String, expireAfterDays: Int, expireAfterViews: Int) {
        self.payload = payload
        self.expireAfterDays = expireAfterDays
        self.expireAfterViews = expireAfterViews
    }
}
