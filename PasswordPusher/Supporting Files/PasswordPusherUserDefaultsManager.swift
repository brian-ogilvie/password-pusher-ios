//
//  PasswordPusherUserDefaultsManager.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 11/20/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import Foundation

class PasswordPusherUserDefaultsManager {
    var viewsToExpire: Float {
        get {
            return UserDefaults.standard.float(forKey: UserDefaultsKeys.viewsToExpire.rawValue)
        }
    }
    func restoreDefaults() -> DefaultSettings {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.saveDefaults.rawValue) == true {
            let views = UserDefaults.standard.integer(forKey: UserDefaultsKeys.viewsToExpire.rawValue)
            let time = UserDefaults.standard.integer(forKey: UserDefaultsKeys.timeToExpire.rawValue)
            let delete = UserDefaults.standard.bool(forKey: UserDefaultsKeys.optionalDelete.rawValue)
            let save = UserDefaults.standard.bool(forKey: UserDefaultsKeys.saveDefaults.rawValue)
            
            return DefaultSettings(time: time, views: views, delete: delete, save: save)
        } else { // restore from factory defaults
            return DefaultSettings()
        }
    }
    
    func saveUserDefaults(defaults: DefaultSettings) {
        if defaults.saveDefaults { //if user has selected to save settings for future
            UserDefaults.standard.set(defaults.viewsToExpire, forKey: UserDefaultsKeys.viewsToExpire.rawValue)
            UserDefaults.standard.set(defaults.timeToExpire, forKey: UserDefaultsKeys.timeToExpire.rawValue)
            UserDefaults.standard.set(defaults.optionalDelete, forKey: UserDefaultsKeys.optionalDelete.rawValue)
            UserDefaults.standard.set(defaults.saveDefaults, forKey: UserDefaultsKeys.saveDefaults.rawValue)
        } else {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.saveDefaults.rawValue)
        }
    }
}

extension PasswordPusherUserDefaultsManager {
    private enum UserDefaultsKeys: String {
        case saveDefaults
        case timeToExpire
        case viewsToExpire
        case optionalDelete
    }
}

struct DefaultSettings {
    let timeToExpire: Int
    let viewsToExpire: Int
    let optionalDelete: Bool
    let saveDefaults: Bool
    init() { // factory defaults
        timeToExpire = 7
        viewsToExpire = 5
        optionalDelete = true
        saveDefaults = false
    }
    init(time: Int, views: Int, delete: Bool, save: Bool) {
        timeToExpire = time
        viewsToExpire = views
        optionalDelete = delete
        saveDefaults = save
    }
}
