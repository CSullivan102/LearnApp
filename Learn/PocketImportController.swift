//
//  PocketImportController.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/8/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit
import CoreData

class PocketImportController: UITableViewController, ManagedObjectContextSettable, PocketAPISettable {
    
    var managedObjectContext: NSManagedObjectContext!
    var pocketAPI: PocketAPI!
    var pocketItems = [PocketItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pocketAPI.isAuthenticated() {
            updateViewForPocketAuthentication()
        } else {
            performSegueWithIdentifier(SegueIdentifier.ShowPocketAuth.rawValue, sender: nil)
        }
    }
    
    private func updateViewForPocketAuthentication() {
        if let authUser = pocketAPI.authenticatedUser {
            navigationItem.title = "✅ \(authUser)"
        }
        
        pocketAPI.getPocketItems(10) {
            items in
            self.pocketItems = items
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pocketItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pocketItem = pocketItems[indexPath.row]
        let identifier = "ArticleTableCell"
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ArticleTableViewCell
        else { fatalError("Wrong cell type for \(identifier)") }
        
        cell.pocketItem = pocketItem
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier, segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Invalid segue identifier \(segue.identifier)") }
        
        switch segueIdentifier {
        case .ShowPocketAuth:
            guard let vc = segue.destinationViewController as? PocketAuthModalController
            else { fatalError("Unexpected view controller for \(identifier) segue") }
            
            vc.pocketAPI = pocketAPI
            vc.completionHandler = {
                success in
                if success {
                    self.updateViewForPocketAuthentication()
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            vc.modalPresentationStyle = .Custom
            vc.transitioningDelegate = SmallModalTransitioningDelegate()
        }
    }
    
    enum SegueIdentifier: String {
        case ShowPocketAuth = "ShowPocketAuth"
    }
}