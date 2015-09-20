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
    
    let maxEmojiTextLength = 1
    
    @IBOutlet public weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet public weak var emojiTextField: UITextField! { didSet { emojiTextField.delegate = self } }
    @IBOutlet public weak var doneButton: UIButton!
    
    private var nameValid = false { didSet { checkModalValid() } }
    private var emojiValid = false { didSet { checkModalValid() } }
    private var modalValid = false {
        didSet {
            guard let doneButton = doneButton else {
                return
            }
            doneButton.enabled = modalValid
        }
    }
    
    private var currentKeyboardOffset: CGFloat = 0.0
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        emojiTextField.delegate = self
        
        if let topic = topic {
            nameTextField.text = topic.name
            emojiTextField.text = topic.icon
            doneButton.titleLabel?.text = "Save"
            nameValid = true
            emojiValid = true
        } else {
            doneButton.titleLabel?.text = "Create"
            nameValid = false
            emojiValid = false
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    private func checkModalValid() {
        modalValid = nameValid && emojiValid
    }
    
    func textFieldDidChangeNotification(notification: NSNotification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField == self.nameTextField {
            self.nameValid = textField.text?.characters.count > 0
        }
        if textField == self.emojiTextField {
            self.emojiValid = textField.text?.characters.count > 0
        }
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField != emojiTextField {
            return true
        }
        
        let existingStringLength: Int = textField.text?.lengthWithEmoji() ?? 0
        let newLength = existingStringLength + string.lengthWithEmoji() - range.length
        
        if newLength > maxEmojiTextLength {
            return false
        }
        
        let emojiRanges = [
            0x0080...0x00FF,
            0x2100...0x214F,
            0x2190...0x21FF,
            0x2300...0x23FF,
            0x25A0...0x27BF,
            0x2900...0x297F,
            0x2B00...0x2BFF,
            0x3001...0x303F,
            0x3200...0x32FF,
            0x1F000...0x1F02F,
            0x1F110...0x1F251,
            0x1F300...0x1F5FF,
            0x1F600...0x1F64F,
            0x1F680...0x1F6FF
        ]
        
        if let scalarVal = string.unicodeScalars.first?.value {
            var found = false
            for range in emojiRanges {
                if range.contains(Int(scalarVal)) {
                    found = true
                }
            }
            if !found {
                return false
            }
        }

        return true
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
