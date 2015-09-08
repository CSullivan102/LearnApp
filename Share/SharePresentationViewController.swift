//
//  SharePresentationViewController.swift
//  Share
//
//  Created by Christopher Sullivan on 8/23/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit
import MobileCoreServices
import CoreData

class SharePresentationViewController: UIViewController, ChooseTopicDelegate {
    var managedObjectContext: NSManagedObjectContext?
    let createTopicTransitionDelegate = SmallModalTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = createMainContext()
        
        self.performSegueWithIdentifier(SegueIdentifier.ShowChooseTopicModal.rawValue, sender: self)
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
            vc.delegate = self
            vc.managedObjectContext = managedObjectContext
            
        }
    }
    
    func dismissChooseTopicController() {
        dismissViewControllerAnimated(true) {
            self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
        }
    }
    
    func getExtensionContextInfo(completion: (NSURL?, String?) -> Void) {
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
            attachment = item.attachments?.first as? NSItemProvider
            else { return }
        
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            attachment.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (urlProvider, error) -> Void in
                if let url = urlProvider as? NSURL {
                    completion(url, item.attributedContentText?.string)
                } else {
                    completion(nil, nil)
                }
            })
        } else {
            completion(nil, nil)
        }
    }
    
    enum SegueIdentifier: String {
        case ShowChooseTopicModal = "ShowChooseTopicModal"
    }
}
