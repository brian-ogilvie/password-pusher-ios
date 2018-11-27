//
//  PasswordPusherHandler.swift
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

class PasswordPusherHandler {
    weak var delegate: PasswordPusherHandlerDelegate?
    
    func handlePush(password: String, expireDays: Int, expireViews: Int) {
        guard let url = URL(string: URLs.arctouchAPI) else {
            print("Unable to create url")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let httpParameters = HttpParameters(payload: password, expireAfterDays: expireDays, expireAfterViews: expireViews)
        guard let httpBody = try? JSONEncoder().encode(httpParameters) else {
            print("Unable to create httpBody")
           return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { [weak self] (data, response, error) in
            if response == nil {
                DispatchQueue.main.async {
                    self?.delegate?.handleSessionError(message: Strings.noServerResponse)
                }
            }
            if let data = data {
                do {
                    let pwPushObject = try JSONDecoder().decode(PasswordPushObject.self, from: data)
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

protocol PasswordPusherHandlerDelegate: AnyObject {
    func handleSessionSuccess(url: String)
    func handleSessionError(message: String)
}
