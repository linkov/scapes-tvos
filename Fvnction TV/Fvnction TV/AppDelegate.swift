//
//  AppDelegate.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/20/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import GameController

protocol ReactToMotionEvents {
    func motionUpdate(motion: GCMotion) -> Void
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var motionDelegate: ReactToMotionEvents? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MSAppCenter.start("a4426705-a23b-40aa-8edc-e400557424fa", withServices:[
          MSAnalytics.self,
          MSCrashes.self
        ])
        let center = NotificationCenter.default
           center.addObserver(self, selector: #selector(setupControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
           center.addObserver(self, selector: #selector(setupControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
           GCController.startWirelessControllerDiscovery { () -> Void in }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    @objc func setupControllers(notif: NSNotification) {
        print("controller connection")
        let controllers = GCController.controllers()
        for controller in controllers {
            controller.motion?.valueChangedHandler = { (motion: GCMotion)->() in
                if let delegate = self.motionDelegate {
                    delegate.motionUpdate(motion: motion)
                }
            }
        }
    }


}

