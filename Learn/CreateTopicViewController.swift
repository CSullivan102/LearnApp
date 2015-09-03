//
//  CreateTopicViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/19/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData

public class CreateTopicViewController: UIViewController, ManagedObjectContextSettable, UITextFieldDelegate {
    public var managedObjectContext: NSManagedObjectContext!
    
    public var topic: Topic?
    
    let maxEmojiTextLength = 1
    
    @IBOutlet public weak var nameTextField: UITextField!
    @IBOutlet public weak var emojiTextField: UITextField!
    @IBOutlet public weak var doneButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        emojiTextField.delegate = self
        
        if let topic = topic {
            nameTextField.text = topic.name
            emojiTextField.text = topic.icon
            doneButton.titleLabel?.text = "Save"
        } else {
            doneButton.titleLabel?.text = "Create"
        }
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = stringLength(textField.text) + stringLength(string) - range.length
        
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
    
    @IBAction public func createTopic(sender: UIButton) {
        createTopic()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction public func cancel(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func createTopic() {
        guard let nameValue = nameTextField?.text where nameValue.characters.count > 0,
            let emojiValue = emojiTextField?.text where emojiValue.characters.count > 0
        else { return }
        managedObjectContext.performChanges {
            if let topic = self.topic {
                topic.name = nameValue
                topic.icon = emojiValue
            } else {
                let newTopic: Topic = self.managedObjectContext.insertObject()
                newTopic.name = nameValue
                newTopic.icon = emojiValue
            }
        }
    }
    
    private func stringLength(str: String?) -> Int {
        guard let str = str else { return 0 }
        let range = Range<String.Index>(start: str.startIndex, end: str.endIndex)
        var length = 0
        str.enumerateSubstringsInRange(range, options: .ByComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) -> () in
            length++
        }
        return length
    }
}
