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

class ShareViewController: UIViewController, ChooseTopicDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var shareURL: NSURL?
    var itemTitle: String?
    let createTopicTransitionDelegate = CreateTopicTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
            attachment = item.attachments?.first as? NSItemProvider
            else { return }
        
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            attachment.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (urlProvider, error) -> Void in
                if let url = urlProvider as? NSURL {
                    self.shareURL = url
                    self.itemTitle = item.attributedContentText?.string
                }
            })
        }
        
        managedObjectContext = createMainContext()
        
        performSegueWithIdentifier(SegueIdentifier.ShowChooseTopicModal.rawValue, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier, segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Invalid segue identifier \(segue.identifier)") }
        switch segueIdentifier {
        case .ShowChooseTopicModal:
            guard let vc = segue.destinationViewController as? ChooseTopicViewController
                else { fatalError("Wrong view controller for segue") }
            
            vc.transitioningDelegate = createTopicTransitionDelegate
            vc.modalPresentationStyle = .Custom
            
            vc.managedObjectContext = managedObjectContext
            vc.delegate = self
            vc.shareURL = shareURL
            vc.itemTitle = itemTitle
        }
    }
    
    func dismissChooseTopicController() {
        dismissViewControllerAnimated(true) {
            self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
        }
    }
    
    enum SegueIdentifier: String {
        case ShowChooseTopicModal = "ShowChooseTopicModal"
    }
}
