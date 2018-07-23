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
    public static var favoritedFirstEvent: Bool {
        set {
            Settings.userDefaults.set(newValue, forKey: "favoritedFirstEvent")
        }
        get {
            return Settings.userDefaults.bool(forKey: "favoritedFirstEvent")
        }
    }
    
    //MARK: - Notification Settings.
    public static var notifyFavoriteEvents: Bool {
        set {
            Settings.userDefaults.set(newValue, forKey: "notifyFavoriteEvents")
        }
        get {
            return Settings.userDefaults.bool(forKey: "notifyFavoriteEvents")
        }
    }

    public static var weekNotificationsEnabled: Bool {
        set {
            Settings.userDefaults.set(newValue, forKey: "weekNotificationsEnabled")
        }
        get {
            return Settings.userDefaults.bool(forKey: "weekNotificationsEnabled")
        }
    }
    
    public static var dayNotificationsEnabled: Bool {
        set {
            Settings.userDefaults.set(newValue, forKey: "dayNotificationsEnabled")
        }
        get {
            return Settings.userDefaults.bool(forKey: "dayNotificationsEnabled")
        }
    }

    public static var hourNotificationsEnabled: Bool {
        set {
            Settings.userDefaults.set(newValue, forKey: "hourNotificationsEnabled")
        }
        get {
            return Settings.userDefaults.bool(forKey: "hourNotificationsEnabled")
        }
    }

}
