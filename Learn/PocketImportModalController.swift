//
//  PocketImportModalController.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/14/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit
import CoreData

class PocketImportModalController: UIViewController, ManagedObjectContextSettable, UIViewControllerHeightRequestable, TopicCollectionControllable {
    var managedObjectContext: NSManagedObjectContext!
    var parentTopic: Topic?
    var selectedTopic: Topic?
    var pocketItemsToImport = [PocketItem]()
    var completionHandler: ([PocketItem] -> ())?
    
    @IBOutlet weak var chooseContainerHeightConstraint: NSLayoutConstraint!
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func importButtonPressed(sender: UIButton) {
        guard let topic = selectedTopic else {
            return
        }
        
        managedObjectContext.performChanges { () -> () in
            for pocketItem in self.pocketItemsToImport {
                let learnItem: LearnItem = self.managedObjectContext.insertObject()
                learnItem.itemType = .Article
                learnItem.read = false
                learnItem.dateAdded = NSDate()
                learnItem.topic = topic
                learnItem.copyDataFromPocketItem(pocketItem)
            }
            self.completionHandler?(self.pocketItemsToImport)
        }
    }
    
    func preferredHeight() -> CGFloat {
        return 72 + chooseContainerHeightConstraint.constant
    }
    
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        UIView.animateWithDuration(0.6,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 1.0,
            options: .CurveEaseOut,
            animations: { () -> Void in
                self.chooseContainerHeightConstraint.constant = container.preferredContentSize.height
                self.view.superview?.setNeedsLayout()
                self.view.superview?.layoutIfNeeded()
            },
            completion: nil)
        
        super.preferredContentSizeDidChangeForChildContentContainer(container)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier, segueIdentifier = SegueIdentifier(rawValue: identifier) else {
                return
        }
        
        switch segueIdentifier {
        case .EmbedTopicPicker:
            guard let vc = segue.destinationViewController as? ChooseTopicViewController else {
                fatalError("Unexpected view controller for \(identifier)")
            }
            
            vc.managedObjectContext = managedObjectContext
            vc.parentTopic = parentTopic
            vc.chooseTopicDelegate = self
        }
    }
    
    private enum SegueIdentifier: String {
        case EmbedTopicPicker = "EmbedTopicPicker"
    }
}

extension PocketImportModalController: ChooseTopicDelegate {
    func didChooseTopic(topic: Topic?) {
        selectedTopic = topic
    }
}