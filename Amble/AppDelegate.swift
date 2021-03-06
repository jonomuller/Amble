//
//  AppDelegate.swift
//  Amble
//
//  Created by Jono Muller on 20/02/2017.
//  Copyright © 2017 Jonathan Muller. All rights reserved.
//

import UIKit
import UserNotifications
import Locksmith
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  public static let DEVICE_TOKEN_KEY = "DeviceToken"
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (success, error) in
      if error != nil {
        print(error)
      }
    }
    
    application.registerForRemoteNotifications()
    
    let storyboardID: String!
    
    // If user's details are in keychain, log them in
    if let user = Locksmith.loadDataForUserAccount(userAccount: "Amble") {
      User.sharedInstance.userInfo = UserInfo(user: OtherUser(id: user["id"] as! String,
                                                              username: user["username"] as! String,
                                                              email: user["email"] as! String,
                                                              firstName: user["firstName"] as! String,
                                                              lastName: user["lastName"] as! String),
                                              jwt: user["jwt"] as! String)
      storyboardID = "Main"
      
      // Set badge count for invites tab
      // Value is set to the number of active received invites the user has
      APIManager.sharedInstance.getReceivedInvites(completion: { (response) in
        switch response {
        case .success(let json):
          var badgeValue = 0
          
          for (_, subJson): (String, JSON) in json["invites"] {
            if !subJson["accepted"].boolValue {
              badgeValue += 1
            }
          }
          
          if badgeValue > 0, let tbc = self.window?.rootViewController as? UITabBarController {
            tbc.viewControllers?[1].tabBarItem.badgeValue = String(badgeValue)
          }
        case .failure(let error):
          print("Could not set invites badge: \(error.localizedDescription)")
        }
      })
      
    } else {
      storyboardID = "Login"
    }
    
    let storyboard = UIStoryboard(name: storyboardID, bundle: nil)
    self.window?.rootViewController = storyboard.instantiateInitialViewController()
    
    return true
  }
  
  // MARK: - Push notification methods
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    let userDefaults = UserDefaults.standard
    
    if let savedDeviceToken: String = userDefaults.object(forKey: AppDelegate.DEVICE_TOKEN_KEY) as? String {
      if deviceTokenString != savedDeviceToken {
        userDefaults.set(deviceToken, forKey: AppDelegate.DEVICE_TOKEN_KEY)
        
        if let userInfo = User.sharedInstance.userInfo {
          APIManager.sharedInstance.registerToken(token: deviceTokenString, completion: { (response) in
            switch response {
            case .success:
              print("Updated device token")
            case .failure(let error):
              print("Failed registering device token: \(error.localizedDescription)")
            }
          })
        }
      }
    } else {
      userDefaults.set(deviceToken, forKey: AppDelegate.DEVICE_TOKEN_KEY)
    }
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    print(userInfo)
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
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

