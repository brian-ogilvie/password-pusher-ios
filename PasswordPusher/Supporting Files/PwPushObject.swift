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
<<<<<<< HEAD
    //var deletable: Bool
=======
>>>>>>> parent of 7bbf3ae... revert to initial blank project
    var deleted: Bool
    var expireDays: Int
    var expireViews: Int
    var expired: Bool
<<<<<<< HEAD
    //var firstView: Bool
=======
>>>>>>> parent of 7bbf3ae... revert to initial blank project
    var id: Int
    var payload: String
    var updatedAt: String
    var urlToken: String
    var userId: String?
    
    enum CodingKeys: String, CodingKey {
        case created = "created_at"
<<<<<<< HEAD
        //case deletable = "deletable_by_viewer"
=======
>>>>>>> parent of 7bbf3ae... revert to initial blank project
        case deleted
        case expireDays = "expire_after_days"
        case expireViews = "expire_after_views"
        case expired
<<<<<<< HEAD
        //case firstView = "first_view"
=======
>>>>>>> parent of 7bbf3ae... revert to initial blank project
        case id
        case payload
        case updatedAt = "updated_at"
        case urlToken = "url_token"
        case userId = "user_id"
    }
}
<<<<<<< HEAD

//Older API hosted at arctouch with limited fields
/*
 jsonData: {
 "created_at" = "2018-10-26T18:55:36Z";
 deleted = 0;
 "expire_after_days" = 7;
 "expire_after_views" = 5;
 expired = 0;
 id = 2379;
 payload = "GHMAa6zAdbNPKGAfN7WSIg==\n";
 "updated_at" = "2018-10-26T18:55:36Z";
 "url_token" = h5720tztda19y8zr;
 "user_id" = "<null>";
 }
 */
=======
>>>>>>> parent of 7bbf3ae... revert to initial blank project
