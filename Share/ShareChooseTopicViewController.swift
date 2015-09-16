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

class ShareChooseTopicViewController: UIViewController, ManagedObjectContextSettable, UIViewControllerHeightRequestable, UITextFieldDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var delegate: LearnShareSheetDelegate?
    var shareURL: NSURL?
    var selectedTopic: Topic? { didSet { topicValid = (selectedTopic != nil) } }
    
    @IBOutlet weak var titleTextField: UITextField! { didSet { titleTextField.delegate = self } }
    @IBOutlet weak var chooseTopicContainerView: UIView!
    @IBOutlet weak var chooseContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    
    private var titleTextValid = false { didSet { checkModalValid() } }
    private var topicValid = false { didSet { checkModalValid() } }
    private var modalValid = false { didSet { saveButton.enabled = modalValid } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate?.getExtensionContextInfo() {
            url, itemTitle in
            self.shareURL = url
            self.titleTextField.text = itemTitle
            self.titleTextValid = self.titleTextIsValid(itemTitle)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextChangedNotification:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    private func checkModalValid() {
        print("\(titleTextValid) \(topicValid)")
        modalValid = titleTextValid && topicValid
    }
    
    func textFieldTextChangedNotification(notification: NSNotification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        
        if textField == titleTextField {
            titleTextValid = titleTextIsValid(textField.text)
        }
    }
    
    func titleTextIsValid(text: String?) -> Bool {
        let textLength = text?.characters.count ?? 0
        return textLength > 0
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        guard let managedObjectContext = managedObjectContext else {
            fatalError("Tried to post article without MOC")
        }
        
        guard let topic = selectedTopic, title = titleTextField.text where title.characters.count > 0 else {
            return
        }
        
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
                            learnItem.copyDataFromPocketItem(pocketItem)
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
        return 104 + chooseContainerHeightConstraint.constant
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
        case .EmbedChooseTopic:
            guard let vc = segue.destinationViewController as? ChooseTopicViewController
            else { fatalError("Unexpected view controller for \(identifier)") }
            
            vc.managedObjectContext = managedObjectContext
            vc.chooseTopicDelegate = self
        }
    }
    
    private enum SegueIdentifier: String {
        case EmbedChooseTopic = "EmbedChooseTopic"
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ShareChooseTopicViewController: ChooseTopicDelegate {
    func didChooseTopic(topic: Topic?) {
        selectedTopic = topic
    }
}

extension ShareChooseTopicViewController: PocketAuthenticationDelegate {
    func promptOAuthUserAuthWithURL(URL: NSURL) {
        return
    }
}
