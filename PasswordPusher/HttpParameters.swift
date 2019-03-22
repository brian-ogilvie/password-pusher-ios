//
//  HttpParameters.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 3/22/19.
//  Copyright © 2019 Brian Ogilvie Development. All rights reserved.
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
