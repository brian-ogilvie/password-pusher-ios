//
//  PasswordPusherHandler.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 3/22/19.
//  Copyright © 2019 Brian Ogilvie Development. All rights reserved.

import Foundation

class PasswordPusherHandler {
    func handlePush(password: String, expireDays: Int, expireViews: Int, success: @escaping (_ url: String) -> Void, failure: @escaping (_ error: UrlSessionError) -> Void) {
        guard let url = URL(string: URLs.pwPushAPI) else {
            failure(UrlSessionError.urlCreationError)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let httpParameters = HttpParameters(payload: password, expireAfterDays: expireDays, expireAfterViews: expireViews)
        guard let httpBody = try? JSONEncoder().encode(httpParameters) else {
            failure(UrlSessionError.httpBodyCreationError)
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if response == nil {
                failure(UrlSessionError.noServerResponse)
                return
            }
            guard let data = data else { failure(UrlSessionError.emptyDataInResponse); return }
            do {
                let passwordPushObject = try JSONDecoder().decode(PasswordPushObject.self, from: data)
                let urlToSend = URLs.pwPushPrefix + passwordPushObject.urlToken
                success(urlToSend)
            } catch {
                failure(UrlSessionError.unknownSessionError)
            }
        }.resume()
    }
}

extension PasswordPusherHandler {
    private struct URLs {
        static let pwPushAPI = "https://pwpush.com/p.json"
        static let pwPushPrefix = "https://pwpush.com/p/"
    }
    private struct Strings {
        static let noServerResponse = "Unable to get response from server."
    }
}
