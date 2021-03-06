//
//  AppDelegate.swift
//  KGHS
//
//  Created by Collin DeWaters on 2/21/18.
//  Copyright © 2018 Collin DeWaters. All rights reserved.
//

import UIKit
import UserNotifications

let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    //MARK: - Properties.
    ///The retrieved notification settings.
    public static var notificationSettings: UNNotificationSettings?

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Request permission to send notifications.
        AppDelegate.registerForNotifications { (allowed) in
            if !Settings.favoritedFirstEvent {
                Settings.dayNotificationsEnabled = true
                Settings.weekNotificationsEnabled = true
                Settings.hourNotificationsEnabled = true
            }
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        AppDelegate.retrieveNotificationSettings(withCompletion: { (settings) in
            AppDelegate.notificationSettings = settings
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: - UserNotifications.
    ///Registers the application to recieve notifications.
    class func registerForNotifications(withCompletion completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        //Request permission to send notifications.
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            //Run completion block.
            completion(granted)
        }
    }
    
    ///Retrieves the UserNotification settings.
    class func retrieveNotificationSettings(withCompletion completion: @escaping (UNNotificationSettings?) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        //Get the notification settings.
        center.getNotificationSettings { (settings) in
            //Set the settings property.
            AppDelegate.notificationSettings = settings
            
            //Run the completion block with no settings if the application is not authorized to schedule notifications.
            guard settings.authorizationStatus == .authorized else {
                completion(nil)
                return
            }
            
            //User authorized notifications.
            completion(settings)
        }
    }
    
    ///Schedules a local notification, given content, an identifier, and a date to send it.
    class func schedule(localNotificationWithContent content: UNNotificationContent, withIdentifier identifier: String, andSendDate sendDate: Date) {
        //Check if the notification settings show the user authorized.
        if AppDelegate.notificationSettings?.authorizationStatus == .authorized {
            //Create and add the request.
            let timeInterval = sendDate.timeIntervalSinceNow
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Notification Scheduling Error Occurred")
                }
            }
        }
    }
    
    ///Cancels a scheduled notification request, with a given identifier.
    class func cancel(notificationRequestWithIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    //MARK: - UNUserNotificationCenterDelegate.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Increment badge.
        UIApplication.shared.applicationIconBadgeNumber += 1
        completionHandler([.alert, .sound])
    }
}

//MARK : - UIColor Extension.
extension UIColor {
    static let blueTheme = UIColor(red:39/255.0, green:55/255.0, blue:164/255.0, alpha: 1)
    static let yellowTheme = UIColor(red:241/255.0, green:229/255.0, blue:76/255.0, alpha: 1)
}

//MARK: - UIViewController extension.
public extension UIViewController {
    public func hideHairline() {
        self.findHairline()?.isHidden = true
        self.findTabBarHairline()?.isHidden = true
    }
    
    public func showHairline() {
        self.findHairline()?.isHidden = false
        self.findTabBarHairline()?.isHidden = false
    }
    
    private func findHairline() -> UIImageView? {
        return navigationController?.navigationBar.subviews
            .flatMap { $0.subviews }
            .flatMap { $0 as? UIImageView }
            .filter { $0.bounds.size.width == self.navigationController?.navigationBar.bounds.size.width }
            .filter { $0.bounds.size.height <= 2 }
            .first
    }
    
    private func findTabBarHairline() -> UIImageView? {
        return tabBarController?.tabBar.subviews
            .flatMap { $0.subviews }
            .flatMap { $0 as? UIImageView }
            .filter { $0.bounds.size.width == self.navigationController?.navigationBar.bounds.size.width }
            .filter { $0.bounds.size.height <= 2 }
            .first
    }
}

//MARK: - String extension.
extension String {
    ///Returns the height of a String with a constrainted width and font.
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    ///Returns the width of a String with a constrainted height and font.
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

//MARK: - Date Extension.
extension Date {
    func add(days: Int = 0, months: Int = 0, years: Int = 0, hours: Int = 0) -> Date? {
        var dateComponent = DateComponents()
        
        dateComponent.month = months
        dateComponent.day = days
        dateComponent.year = years
        dateComponent.hour = hours
        
        return Calendar.current.date(byAdding: dateComponent, to: self)
    }
}

