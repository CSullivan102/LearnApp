//
//  ShareChooseTopicViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/31/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit
import CoreData

protocol LearnShareSheetDelegate {
    func dismissLearnShareSheetController()
    func getExtensionContextInfo(completion: (NSURL?, String?) -> Void)
}

class ShareChooseTopicViewController: UIViewController, UICollectionViewDelegate, ManagedObjectContextSettable, UIViewControllerHeightRequestable, TopicCollectionControllable {
    var managedObjectContext: NSManagedObjectContext!
    var parentTopic: Topic?
    var delegate: LearnShareSheetDelegate?
    var shareURL: NSURL?
    var itemTitle: String?
    var selectedTopic: Topic?
    
    let createTopicTransitioningDelegate = SmallModalTransitioningDelegate()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var topicStackView: UIStackView!
    @IBOutlet weak var chooseTopicContainerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate?.getExtensionContextInfo() {
            url, itemTitle in
            self.shareURL = url
            self.itemTitle = itemTitle
            self.titleTextField.text = itemTitle
        }
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        guard let managedObjectContext = managedObjectContext
            else { fatalError("Tried to post article without MOC") }
        
        guard let topic = selectedTopic, title = titleTextField.text where title.characters.count > 0
            else { return }
        
        if let shareURL = shareURL {
            managedObjectContext.performChanges {
                let learnItem: LearnItem = managedObjectContext.insertObject()
                learnItem.title = title
                learnItem.url = self.shareURL
                learnItem.itemType = .Article
                learnItem.read = false
                learnItem.dateAdded = NSDate()
                learnItem.topic = topic
                let pocketAPI = PocketAPI(delegate: self)
                if pocketAPI.isAuthenticated() {
                    pocketAPI.addURLToPocket(shareURL) { pocketItem in
                        managedObjectContext.performChanges {
                            learnItem.excerpt = pocketItem.excerpt
                            if let itemID = Int32(pocketItem.item_id) {
                                learnItem.pocketItemID = NSNumber(int: itemID)
                            }
                            if let images = pocketItem.images,
                                (_, firstImage) = images.first {
                                learnItem.imageURL = NSURL(string: firstImage.src)
                            }
                            if let wordCount = Int32(pocketItem.word_count) {
                                learnItem.wordCount = NSNumber(int: wordCount)
                            }
                            self.delegate?.dismissLearnShareSheetController()
                        }
                    }
                } else {
                    self.delegate?.dismissLearnShareSheetController()
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        delegate?.dismissLearnShareSheetController()
    }
    
    func preferredHeight() -> CGFloat {
        let baseHeight = topicStackView.frame.origin.y
        let margin: CGFloat = 16
        return baseHeight + topicStackView.frame.height + margin
    }
    
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        print("\(container.preferredContentSize)")
        chooseTopicContainerHeightConstraint.constant = container.preferredContentSize.height
        preferredContentSize.height = preferredHeight()
        super.preferredContentSizeDidChangeForChildContentContainer(container)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier,
            segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { return }
        
        switch segueIdentifier {
        case .EmbedChooseTopic:
            guard let vc = segue.destinationViewController as? ChooseTopicViewController
            else { fatalError("Unexpected view controller for \(identifier)") }
            
            vc.managedObjectContext = managedObjectContext
            vc.parentTopic = parentTopic
            vc.chooseTopicDelegate = self
        }
    }
    
    private enum SegueIdentifier: String {
        case EmbedChooseTopic = "EmbedChooseTopic"
    }
}

extension ShareChooseTopicViewController: ChooseTopicDelegate {
    func didChooseTopic(topic: Topic) {
        selectedTopic = topic
    }
}

extension ShareChooseTopicViewController: PocketAuthenticationDelegate {
    func promptOAuthUserAuthWithURL(URL: NSURL) {
        return
    }
}
