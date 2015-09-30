//
//  AppDelegate.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/18/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData
import LearnKit
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PocketAuthenticationDelegate, SFSafariViewControllerDelegate {

    var window: UIWindow?
    var pocketAPI: PocketAPI?
    
    private var oAuthSFVC: SFSafariViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let managedObjectContext = createMainContext()
        
        setupPocketAPI()
        
        guard let rootVC = window?.rootViewController as? UINavigationController,
            let vc = rootVC.viewControllers.first as? protocol<ManagedObjectContextSettable, PocketAPISettable> else {
            fatalError("Wrong View Controller Type as Root")
        }
        
        vc.managedObjectContext = managedObjectContext
        vc.pocketAPI = pocketAPI
        
        let _ = ShortcutGenerator(managedObjectContext: managedObjectContext)
        
        return true
    }

    private func setupPocketAPI() {
        pocketAPI = PocketAPI(delegate: self, andCredentialsManager: PocketAPICredentialsKeychainManager())
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        guard let rootVC = window?.rootViewController as? UINavigationController else {
            fatalError("Wrong View Controller Type as Root")
        }
        rootVC.popToRootViewControllerAnimated(false)
        
        if let vc = rootVC.viewControllers.first as? TopicCollectionViewController,
            userInfo = shortcutItem.userInfo,
            objectIDString = userInfo["objectID"] as? String,
            objectIDURL = NSURL(string: objectIDString),
            objectID = vc.managedObjectContext.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(objectIDURL),
            topic: Topic = vc.managedObjectContext.getObjectForObjectID(objectID) {
            vc.performSegueWithIdentifier(TopicCollectionViewController.SegueIdentifier.ShowTopicView.rawValue, sender: topic)
        }
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        guard let pocketAPI = pocketAPI else {
            fatalError("No Pocket API instance on oAuth callback")
        }
        if let sfvc = oAuthSFVC {
            safariViewControllerDidFinish(sfvc)
        }
        pocketAPI.oAuthCallbackReceived()
        return true
    }
    
    func promptOAuthUserAuthWithPocketAppURL(pocketAppURL: NSURL, orWebURL webURL: NSURL) {
        if UIApplication.sharedApplication().canOpenURL(pocketAppURL) {
            UIApplication.sharedApplication().openURL(pocketAppURL)
        } else {
            guard let rootVC = window?.rootViewController as? UINavigationController,
                vc = rootVC.topViewController else {
                return
            }
            oAuthSFVC = SFSafariViewController(URL: webURL)
            oAuthSFVC!.delegate = self
            
            if let presentedVC = vc.presentedViewController {
                vc.showViewController(oAuthSFVC!, sender: nil)
                presentedVC.dismissViewControllerAnimated(true, completion: nil)
            } else {
                vc.presentViewController(oAuthSFVC!, animated: true, completion: nil)
            }
        }
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        controller.navigationController?.popViewControllerAnimated(true)
    }
}

class ShortcutGenerator: TopicCollectionControllable {
    var managedObjectContext: NSManagedObjectContext!
    var parentTopic: Topic?
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        
        setupParentTopic { () -> Void in
            let fetchRequest = Topic.sortedFetchRequest
            fetchRequest.predicate = NSPredicate(parentTopic: self.parentTopic!)
            let results = try! self.managedObjectContext.executeFetchRequest(fetchRequest)
            if let topicArray = results as? [Topic] {
                var shortcutItems = [UIMutableApplicationShortcutItem]()
                for (index, topic) in topicArray.enumerate() where index < 3 {
                    let shortcutItem = UIMutableApplicationShortcutItem(type: "com.sullivan.j.chris.Learn.topic", localizedTitle: topic.iconAndName, localizedSubtitle: nil, icon: nil, userInfo: ["objectID": topic.objectID.URIRepresentation().absoluteString])
                    shortcutItems.append(shortcutItem)
                }
                UIApplication.sharedApplication().shortcutItems = shortcutItems
            }
        }
    }
}