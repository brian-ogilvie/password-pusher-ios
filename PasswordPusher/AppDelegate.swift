//
//  AppDelegate.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 3/22/19.
//  Copyright © 2019 Brian Ogilvie Development. All rights reserved.

import UIKit
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Mixpanel.initialize(token: "311498e25210cf80cc6bbe9a3be9104b")
        return true
    }
}

