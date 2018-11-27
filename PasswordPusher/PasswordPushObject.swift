//
//  PasswordPushObject.swift
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
