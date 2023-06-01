//
//  AppDelegate.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import CoreData
import Firebase
import FirebaseCore
import FirebaseAppCheck
import GoogleMaps
import GooglePlaces
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var googleAPIKey = "AIzaSyAH1RgK1qot4jRe0k-_SnUtJUJZ9GKGCaE"
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        GMSServices.provideAPIKey(googleAPIKey)
        GMSPlacesClient.provideAPIKey(googleAPIKey)
        
        let user = Auth.auth().currentUser?.uid
        
        if user != nil {
            let pushManager = PushNotificationManager(userID: "\(user!)")
            pushManager.registerForPushNotifications()
        }
        
        let sender = PushNotificationSender()
        sender.sendPushNotification(to: "token", title: "Notification title", body: "Notification body")
        
        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (granted, error) in
            if error != nil {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            
            
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

