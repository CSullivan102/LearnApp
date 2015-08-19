//
//  ViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/18/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData

class TopicTableViewController: UITableViewController, ManagedObjectContextSettable {
    var managedObjectContext: NSManagedObjectContext!
    var dataSource: UITableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = Topic.sortedFetchRequest
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = FetchedResultsDataSource(tableView: tableView, fetchedResultsController: frc, delegate: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier,
            segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Invalid segue identifier \(segue.identifier)") }
        
        switch segueIdentifier {
        case .ShowCreateTopic:
            guard let nc = segue.destinationViewController as? UINavigationController,
                vc = nc.viewControllers.first as? CreateTopicViewController
            else { fatalError("Unexpected view controller for \(identifier) segue") }
            
            vc.managedObjectContext = managedObjectContext
        }
    }
    
    enum SegueIdentifier: String {
        case ShowCreateTopic = "ShowCreateTopic"
    }
}

extension TopicTableViewController: FetchedResultsDataSourceDelegate {
    typealias Cell = UITableViewCell
    typealias Object = Topic
    
    func cellIdentifierForObject(object: Object) -> String {
        return "TopicCell"
    }
    
    func configureCell(cell: Cell, object: Object) {
        cell.textLabel?.text = object.name
    }
}
