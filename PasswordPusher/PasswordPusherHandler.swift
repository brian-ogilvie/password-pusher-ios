//
//  PasswordPusherHandler.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 11/19/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

class PasswordPusherHandler {
    var delegate: PasswordPusherHandlerDelegate?
    
    func handlePush(password: String, expireDays: Int, expireViews: Int) {
        guard let url = URL(string: URLs.arctouchAPI) else {
            print("Unable to create url")
            return
        }
        let parameters = ["payload": password, "expire_after_days": String(expireDays), "expire_after_views": String(expireViews)]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Unable to create httpBody")
            return
        }
        request.httpBody = httpBody
        //TODO: add ability to cancel operation if long response time
        
        let session = URLSession.shared
        session.dataTask(with: request) { [weak self] (data, response, error) in
            if response == nil {
                DispatchQueue.main.async {
                    self?.delegate?.handleSessionError(message: Strings.noServerResponse)
                }
            }
            if let data = data {
                do {
                    let pwPushObject = try JSONDecoder().decode(PwPushObject.self, from: data)
                    let urlToSend = URLs.arctouchPrefix + pwPushObject.urlToken
                    DispatchQueue.main.async {
                        self?.delegate?.handleSessionSuccess(url: urlToSend)
                    }
                } catch let sessionError {
                    DispatchQueue.main.async {
                        self?.delegate?.handleSessionError(message: String(describing: sessionError))
                    }
                }
            }
        }.resume()
    }
}

extension PasswordPusherHandler {
    private struct URLs {
        static let pwPushAPI = "https://pwpush.com/p.json"
        static let arctouchAPI = "https://pwpush.arctouch.com/passwords.json"
        static let pwPushPrefix = "https://pwpush.com/p/"
        static let arctouchPrefix = "https://pwpush.arctouch.com/p/"
        static let placeholder = "https://jsonplaceholder.typicode.com/todos/1/posts"
    }
    private struct Strings {
        static let noServerResponse = "Unable to get response from server."
    }
}

protocol PasswordPusherHandlerDelegate {
    func handleSessionSuccess(url: String)
    func handleSessionError(message: String)
}
