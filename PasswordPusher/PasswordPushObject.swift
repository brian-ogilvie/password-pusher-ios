//
//  PasswordPushObject.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 3/22/19.
//  Copyright © 2019 Brian Ogilvie Development. All rights reserved.

import Foundation

struct PasswordPushObject: Decodable {
    var created: String
    var deleted: Bool
    var expireDays: Int
    var expireViews: Int
    var expired: Bool
    var id: Int
    var payload: String
    var updatedAt: String
    var urlToken: String
    var userId: String?
    
    enum CodingKeys: String, CodingKey {
        case created = "created_at"
        case deleted
        case expireDays = "expire_after_days"
        case expireViews = "expire_after_views"
        case expired
        case id
        case payload
        case updatedAt = "updated_at"
        case urlToken = "url_token"
        case userId = "user_id"
    }
}
