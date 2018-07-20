//
//  Settings.swift
//  KGHS
//
//  Created by Collin DeWaters on 7/20/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import Foundation

///`Settings`: handles background implementation for settings.
class Settings {
    
    private static let userDefaults = UserDefaults.standard
    
    //MARK: - Completed first session.
    public var completedFirstSession: Bool {
        set {
            Settings.userDefaults.set(newValue, forKey: "completedFirstSession")
        }
        get {
            return Settings.userDefaults.bool(forKey: "completedFirstSession")
        }
    }
    
    //MARK: - Notification Settings.
    public var notifyFavoriteEvents: Bool {
        set {
            Settings.userDefaults.set(newValue, forKey: "notifyFavoriteEvents")
        }
        get {
            return Settings.userDefaults.bool(forKey: "notifyFavoriteEvents")
        }
    }

}
