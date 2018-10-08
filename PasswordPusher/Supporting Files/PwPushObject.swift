//
//  PwPushObject.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 10/8/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

struct PwPushObject: Decodable {
    var created: String
    var deletable: Bool
    var deleted: Bool
    var expireDays: Int
    var expireViews: Int
    var expired: Bool
    var firstView: Bool
    var id: Int
    var payload: String
    var updatedAt: String
    var urlToken: String
    var userId: String?
    
    enum CodingKeys: String, CodingKey {
        case created = "created_at"
        case deletable = "deletable_by_viewer"
        case deleted
        case expireDays = "expire_after_days"
        case expireViews = "expire_after_views"
        case expired
        case firstView = "first_view"
        case id
        case payload
        case updatedAt = "updated_at"
        case urlToken = "url_token"
        case userId = "user_id"
    }
}
