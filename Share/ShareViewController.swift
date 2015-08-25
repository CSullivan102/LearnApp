//
//  ShareViewController.swift
//  Share
//
//  Created by Christopher Sullivan on 8/23/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import LearnKit
import CoreData

class ShareViewController: SLComposeServiceViewController, TopicConfigTableViewControllerDelegate, PocketAuthenticationDelegate {

    var shareURL: NSURL?
    var shareURLTitle: String?
    var managedObjectContext: NSManagedObjectContext?
    var topicConfigItem = SLComposeSheetConfigurationItem()
    var topics: [Topic]?
    var topic: Topic?
    
    override func presentationAnimationDidFinish() {
        managedObjectContext = createMainContext()
        
        let request = Topic.sortedFetchRequest
        request.fetchBatchSize = 20
        if let results = try? managedObjectContext?.executeFetchRequest(request) {
            if let resultsAsTopics = results as? [Topic] {
                topics = resultsAsTopics
            }
        }
        
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
            attachment = item.attachments?.first as? NSItemProvider
        else { return }
        
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            attachment.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (urlProvider, error) -> Void in
                if let url = urlProvider as? NSURL {
                    self.shareURL = url
                    self.shareURLTitle = item.attributedTitle?.string
                }
            })
        }
    }
    
    override func isContentValid() -> Bool {
        if topic == nil {
            return false
        }
        if contentText.characters.count == 0 {
            return false
        }
        return true
    }

    override func didSelectPost() {
        // Make a new LearnItem
        guard let managedObjectContext = managedObjectContext
        else { fatalError("Tried to post article without MOC") }
        
        if let shareURL = shareURL {
            let pocketAPI = PocketAPI(delegate: self)
            pocketAPI.addURLToPocket(shareURL) { pocketItem in
                print("Saved URL to Pocket!")
            }
        }
        
        managedObjectContext.performChanges {
            let learnItem: LearnItem = managedObjectContext.insertObject()
            learnItem.title = self.contentText
            learnItem.url = self.shareURL
            learnItem.itemType = .Article
            learnItem.read = false
            learnItem.dateAdded = NSDate()
            learnItem.topic = self.topic
        }
        
        super.didSelectPost()
    }
    
    func promptOAuthUserAuthWithURL(URL: NSURL) {
        return
    }

    override func configurationItems() -> [AnyObject]! {
        topicConfigItem.title = "Topic"
        // set the value to the topic name if != nil
        topicConfigItem.tapHandler = {
            [unowned self] in
            let vc = TopicConfigTableViewController()
            vc.topics = self.topics
            vc.delegate = self
            self.pushConfigurationViewController(vc)
        }
        return [topicConfigItem]
    }
    
    func didSelectTopic(topic: Topic) {
        self.topic = topic
        topicConfigItem.value = topic.name
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.popConfigurationViewController()
        }
    }
}
