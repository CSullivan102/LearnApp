//
//  CreateTopicViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/19/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData

class CreateTopicViewController: UIViewController, ManagedObjectContextSettable {
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func create(sender: UIBarButtonItem) {
        createTopic()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func createTopic() {
        guard let nameValue = nameTextField?.text where nameValue.characters.count > 0
        else { return }
        managedObjectContext.performChanges {
            let topic: Topic = self.managedObjectContext.insertObject()
            topic.name = nameValue
        }
    }
}
