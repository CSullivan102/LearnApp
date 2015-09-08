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
    var dataSource: UITableViewDataSource?
    var topic: Topic?
    var selectedIndexPath: NSIndexPath?
    var notif: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let topic = topic else { fatalError("No topic found") }
        
        navigationItem.title = topic.iconAndName
        
        let request = LearnItem.sortedFetchRequest
        request.fetchBatchSize = 20
        request.predicate = NSPredicate(format: "topic = %@", topic)
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = FetchedResultsTableDataSource(tableView: tableView, fetchedResultsController: frc, delegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        notif = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) {
            [unowned self] (_) -> Void in
            if let dataSource = self.dataSource as? FetchedResultsTableDataSource<ArticlesTableViewController> {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier,
            segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Invalid segue identifier \(segue.identifier)") }
        
        switch segueIdentifier {
        case .ShowCreateLearnItem:
            guard let nc = segue.destinationViewController as? UINavigationController,
            vc = nc.viewControllers.first as? CreateLearnItemViewController
            else { fatalError("Unexpected view controller for \(identifier) segue") }
            
            vc.managedObjectContext = managedObjectContext
            vc.topic = topic
            vc.pocketAPI = pocketAPI
        }
    }
    
    enum SegueIdentifier: String {
        case ShowCreateLearnItem = "ShowCreateLearnItem"
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