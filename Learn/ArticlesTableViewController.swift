//
//  ArticlesTableViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit
import CoreData
import SafariServices

class ArticlesTableViewController: UITableViewController, ManagedObjectContextSettable, PocketAPISettable, SFSafariViewControllerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var pocketAPI: PocketAPI!
    var dataSource: FetchedResultsTableDataSource<ArticlesTableViewController>?
    var topic: Topic?
    var selectedIndexPath: NSIndexPath?
    var notif: NSObjectProtocol?
    var viewArchives = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let topic = topic else { fatalError("No topic found") }
        
        navigationItem.title = topic.iconAndName
        
        let request = LearnItem.sortedFetchRequest
        request.fetchBatchSize = 20
        request.predicate = getPredicateForFetchedResultsController()
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = FetchedResultsTableDataSource(tableView: tableView, fetchedResultsController: frc, delegate: self)
    }
    
    private func getPredicateForFetchedResultsController() -> NSPredicate {
        guard let topic = self.topic else { fatalError("No topic found") }
        return NSPredicate(format: "topic == %@ AND read == %@", topic, NSNumber(bool: viewArchives))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        notif = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] (_) -> Void in
            if let dataSource = self.dataSource {
                dataSource.refreshData()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        guard let notif = notif
        else { return }
        NSNotificationCenter.defaultCenter().removeObserver(notif)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? Cell,
            learnItem = cell.learnItem,
            url = learnItem.url
        else { return }
        
        let sfc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
        sfc.delegate = self
        presentViewController(sfc, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            if let learnItem = self.dataSource?.objectAtIndexPath(indexPath) {
                let actionSheet = UIAlertController(title: nil, message: "Are you sure you want to delete this article?", preferredStyle: .ActionSheet)
                let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                    self.managedObjectContext.performChanges {
                        self.managedObjectContext.deleteObject(learnItem)
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                actionSheet.addAction(deleteAction)
                actionSheet.addAction(cancelAction)
                self.presentViewController(actionSheet, animated: true, completion: nil)
            }
        }
        
        if viewArchives {
            let unArchiveAction = UITableViewRowAction(style: .Normal, title: "Mark Unread") { (action, indexPath) -> Void in
                if let learnItem = self.dataSource?.objectAtIndexPath(indexPath) {
                    self.managedObjectContext.performChanges {
                        learnItem.read = false
                    }
                }
            }
            actions.append(unArchiveAction)
        } else {
            let archiveAction = UITableViewRowAction(style: .Normal, title: "Archive") { (action, indexPath) -> Void in
                if let learnItem = self.dataSource?.objectAtIndexPath(indexPath) {
                    self.managedObjectContext.performChanges {
                        learnItem.read = true
                    }
                }
            }
            actions.append(archiveAction)
        }
        actions.append(deleteAction)
        return actions
    }
    
    @IBAction func viewArchiveButtonPressed(sender: UIBarButtonItem) {
        if viewArchives {
            viewArchives = false
            sender.title = "View Archive"
        } else {
            viewArchives = true
            sender.title = "View Unread"
        }
        dataSource?.fetchedResultsController.fetchRequest.predicate = getPredicateForFetchedResultsController()
        dataSource?.refreshData()
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ArticlesTableViewController: FetchedResultsTableDataSourceDelegate {
    typealias Cell = ArticleTableViewCell
    typealias Object = LearnItem
    
    func cellIdentifierForObject(object: Object) -> String {
        return "ArticleTableCell"
    }
    
    func configureCell(cell: Cell, object: Object) {
        cell.learnItem = object
    }
}