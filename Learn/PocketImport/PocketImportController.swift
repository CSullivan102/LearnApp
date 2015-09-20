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
    var importedPocketItemIDs = [Int]()

    @IBOutlet weak var importButton: UIBarButtonItem!
    
    private var fetching = false
    private let fetchCount = 10
    private var fetchOffset = 0
    private let smallModalTransitioningDelegate = SmallModalTransitioningDelegate()
    private var modalValid = false { didSet { importButton.enabled = modalValid } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest(entityName: LearnItem.entityName)
        request.resultType = .DictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["pocketItemID"]
        
        if let pocketIDResultDict = try! managedObjectContext.executeFetchRequest(request) as? [[String: Int]] {
            for resultDict in pocketIDResultDict {
                guard let itemID = resultDict["pocketItemID"] else {
                    continue
                }
                importedPocketItemIDs.append(itemID)
            }
        }
        
        if pocketAPI.isAuthenticated() {
            updateViewForPocketAuthentication()
        } else {
            performSegueWithIdentifier(SegueIdentifier.ShowPocketAuth.rawValue, sender: nil)
        }
        
        checkModalValid()
    }
    
    private func updateViewForPocketAuthentication() {
        if let authUser = pocketAPI.authenticatedUser {
            navigationItem.title = authUser
        }
        
        fetchPocketItems {
            items in
            self.pocketItems = self.checkPocketItemsForImported(items)
            self.tableView.reloadData()
        }
    }
    
    private func checkPocketItemsForImported(pocketItems: [PocketItem]) -> [PocketItem] {
        return pocketItems.map { (item) -> PocketItem in
            var updatedItem = item
            if let itemID = Int(item.item_id) where self.importedPocketItemIDs.contains(itemID) {
                updatedItem.importedToLearn = true
            } else {
                updatedItem.importedToLearn = false
            }
            return updatedItem
        }
    }
    
    private func fetchPocketItems(completion: ([PocketItem]) -> ()) {
        if !fetching {
            fetching = true
            pocketAPI.getPocketItemsWithCount(fetchCount, andOffset: fetchOffset) {
                items in
                self.fetching = false
                self.fetchOffset += self.fetchCount
                completion(items)
            }
        }
    }
    
    private func checkModalValid() {
        if let indexPaths = tableView.indexPathsForSelectedRows where indexPaths.count > 0 {
            modalValid = true
        } else {
            modalValid = false
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        checkModalValid()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        checkModalValid()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pocketItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pocketItem = pocketItems[indexPath.row]
        let identifier = "PocketItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? PocketItemTableViewCell else {
            fatalError("Wrong cell type for \(identifier)")
        }
        
        cell.pocketItem = pocketItem
        
        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollPosition = scrollView.contentOffset.y
        let maxScrollPosition = scrollView.contentSize.height - tableView.frame.height

        if scrollPosition > maxScrollPosition {
            fetchPocketItems({
                items in
                let rowsToAddRange = (self.pocketItems.count ..< self.pocketItems.count + items.count)
                let indexPathsToAdd = rowsToAddRange.map { NSIndexPath(forRow: $0, inSection: 0) }
                self.pocketItems += self.checkPocketItemsForImported(items)
                self.tableView.insertRowsAtIndexPaths(indexPathsToAdd, withRowAnimation: .None)
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier, segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(segue.identifier)")
        }
        
        switch segueIdentifier {
        case .ShowPocketAuth:
            guard let vc = segue.destinationViewController as? PocketAuthModalController else {
                fatalError("Unexpected view controller for \(identifier) segue")
            }
            
            vc.pocketAPI = pocketAPI
            vc.completionHandler = {
                success in
                if success {
                    self.updateViewForPocketAuthentication()
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            vc.modalPresentationStyle = .Custom
            vc.transitioningDelegate = smallModalTransitioningDelegate
        case .ShowImportTopicPicker:
            guard let vc = segue.destinationViewController as? PocketImportModalController else {
                fatalError("Unexpected view controller for \(identifier) segue")
            }
            
            vc.managedObjectContext = managedObjectContext
            
            vc.transitioningDelegate = smallModalTransitioningDelegate
            vc.modalPresentationStyle = .Custom
            
            guard let indexPaths = tableView.indexPathsForSelectedRows where indexPaths.count > 0 else {
                return
            }
            
            let pocketItemsToImport = indexPaths.map({ (indexPath) -> PocketItem in
                return pocketItems[indexPath.row]
            })
            vc.pocketItemsToImport = pocketItemsToImport
            vc.completionHandler = {
                items in
                
                for indexPath in indexPaths {
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
                    self.pocketItems[indexPath.row].setImported(true)
                }
                self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    enum SegueIdentifier: String {
        case ShowPocketAuth = "ShowPocketAuth"
        case ShowImportTopicPicker = "ShowImportTopicPicker"
    }
}