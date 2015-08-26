//
//  CreateTopicViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/19/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData
import LearnKit

class CreateTopicViewController: UIViewController, ManagedObjectContextSettable, UITextFieldDelegate {
    var managedObjectContext: NSManagedObjectContext!
    
    let maxEmojiTextLength = 1
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emojiTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        emojiTextField.delegate = self
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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
    
    @IBAction func create(sender: UIBarButtonItem) {
        createTopic()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func createTopic() {
        guard let nameValue = nameTextField?.text where nameValue.characters.count > 0,
            let emojiValue = emojiTextField?.text where emojiValue.characters.count > 0
        else { return }
        managedObjectContext.performChanges {
            let topic: Topic = self.managedObjectContext.insertObject()
            topic.name = nameValue
            topic.icon = emojiValue
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
