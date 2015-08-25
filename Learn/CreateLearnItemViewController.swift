//
//  CreateLearnItemViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData
import LearnKit

class CreateLearnItemViewController: UIViewController, ManagedObjectContextSettable, PocketAPISettable {
    var managedObjectContext: NSManagedObjectContext!
    var pocketAPI: PocketAPI!
    var topic: Topic?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.becomeFirstResponder()
    }
    
    @IBAction func create(sender: UIBarButtonItem) {
        createLearnItem()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func createLearnItem() {
        guard let topic = topic else { fatalError("Tried to create a learn item with no topic") }
        
        guard let titleValue = titleTextField.text where titleValue.characters.count > 0,
        let urlValue = urlTextField.text,
        url = NSURL(string: urlValue)
        else { return }
        
        pocketAPI.addURLToPocket(url) { (pocketItem) -> () in
            print(pocketItem.item_id)
        }
        
        managedObjectContext.performChanges {
            let learnItem: LearnItem = self.managedObjectContext.insertObject()
            learnItem.title = titleValue
            learnItem.url = url
            learnItem.itemType = .Article
            learnItem.read = false
            learnItem.dateAdded = NSDate()
            learnItem.topic = topic
        }
    }
}
