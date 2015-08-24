//
//  AppDelegate.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/18/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pocketAPI: PocketAPI?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let managedObjectContext = createMainContext()
        
        setupPocketAPI()
        
        guard let rootVC = window?.rootViewController as? UINavigationController,
            let vc = rootVC.viewControllers.first as? protocol<ManagedObjectContextSettable, PocketAPISettable> else {
            fatalError("Wrong View Controller Type as Root")
        }
        
        vc.managedObjectContext = managedObjectContext
        vc.pocketAPI = pocketAPI
        
        return true
    }
    
    
    private func setupPocketAPI() {
        var pocketAppID: String?
        var pocketConsumerKey: String?
        if let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist") {
            if let pocketKeys = NSDictionary(contentsOfFile: path) {
                pocketAppID = pocketKeys["PocketAppId"] as? String
                pocketConsumerKey = pocketKeys["PocketConsumerKey"] as? String
            }
        }
        
        pocketAPI = PocketAPI(appId: pocketAppID, andConsumerKey: pocketConsumerKey)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        guard let pocketAPI = pocketAPI else { fatalError("No Pocket API instance on oAuth callback") }
        pocketAPI.oAuthCallbackReceived()
        return true
    }
}