//
//  CreateTopicViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/19/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData

public protocol CreateTopicDelegate {
    func didCreateTopic(topic: Topic)
}

public class CreateTopicViewController: UIViewController, ManagedObjectContextSettable, UIViewControllerHeightRequestable, UITextFieldDelegate {
   
    public var managedObjectContext: NSManagedObjectContext!
    public var createTopicDelegate: CreateTopicDelegate?
    public var parentTopic: Topic?
    public var topic: Topic?
    
    let createTopicModel = CreateTopicModel()
    
    @IBOutlet public weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet public weak var emojiTextField: UITextField! { didSet { emojiTextField.delegate = self } }
    @IBOutlet public weak var doneButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        
        if let topic = topic {
            nameTextField.text = topic.name
            emojiTextField.text = topic.icon
            doneButton.titleLabel?.text = "Save"
        } else {
            doneButton.titleLabel?.text = "Create"
        }
        
        checkModalValid()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    private func checkModalValid() {
        let nameValue = nameTextField.text ?? ""
        let iconValue = emojiTextField.text ?? ""
        let valid = createTopicModel.isValidTopicName(nameValue, andIcon: iconValue)
        setModalValid(valid)
    }

    private func setModalValid(valid: Bool) {
        doneButton.enabled = valid
    }
    
    func textFieldDidChangeNotification(notification: NSNotification) {
        checkModalValid()
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField != emojiTextField {
            return true
        }
        
        let oldString = textField.text ?? ""
        let newString = (oldString as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return createTopicModel.canChangeTopicIconToString(newString)
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction public func createTopic(sender: UIButton) {
        createTopic()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction public func cancel(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func createTopic() {
        guard let parentTopic = parentTopic else {
            fatalError("Trying to create/edit topic without parent")
        }
        
        guard let nameValue = nameTextField?.text where nameValue.characters.count > 0,
            let emojiValue = emojiTextField?.text where emojiValue.characters.count > 0 else {
                return
        }
        managedObjectContext.performChanges {
            if let topic = self.topic {
                topic.name = nameValue
                topic.icon = emojiValue
            } else {
                let newTopic: Topic = self.managedObjectContext.insertObject()
                newTopic.parent = parentTopic
                newTopic.name = nameValue
                newTopic.icon = emojiValue
                self.createTopicDelegate?.didCreateTopic(newTopic)
            }
        }
    }
    
    public func preferredHeight() -> CGFloat {
        return 150.0
    }
}
