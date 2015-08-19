//
//  FetchedResultsDataSource.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/19/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FetchedResultsDataSource<D: FetchedResultsDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    private let fetchedResultsController: NSFetchedResultsController
    private let tableView: UITableView
    private let delegate: D
    
    init(tableView: UITableView, fetchedResultsController: NSFetchedResultsController, delegate: D) {
        self.tableView = tableView
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        
        super.init()
        
        fetchedResultsController.delegate = self
        tableView.dataSource = self
        try! fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            guard let unwrappedIndexPath = indexPath
            else { break }
            tableView.deleteRowsAtIndexPaths([unwrappedIndexPath], withRowAnimation: .Fade)
        case .Insert:
            guard let unwrappedIndexPath = newIndexPath
            else { break }
            tableView.insertRowsAtIndexPaths([unwrappedIndexPath], withRowAnimation: .Fade)
        case .Update:
            guard let unwrappedIndexPath = indexPath,
                cell = tableView.cellForRowAtIndexPath(unwrappedIndexPath) as? D.Cell,
                object = anObject as? D.Object
            else { break }
            delegate.configureCell(cell, object: object)
        case .Move:
            guard let unwrappedOldIndexPath = indexPath,
                unwrappedNewIndexPath = newIndexPath
            else { break }
            tableView.deleteRowsAtIndexPaths([unwrappedOldIndexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([unwrappedNewIndexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let object = objectAtIndexPath(indexPath)
            object.managedObjectContext?.performChanges {
                object.managedObjectContext?.deleteObject(object)
            }
        default: break
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sec.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = objectAtIndexPath(indexPath)
        let identifier = delegate.cellIdentifierForObject(object)
        guard let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? D.Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        delegate.configureCell(cell, object: object)
        return cell
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> D.Object {
        guard let obj = fetchedResultsController.objectAtIndexPath(indexPath) as? D.Object else {
            fatalError("Couldn't find object at index path in FetchedResultsDataSource")
        }
        return obj
    }
}

protocol FetchedResultsDataSourceDelegate {
    typealias Object: ManagedObject
    typealias Cell: UITableViewCell
    
    func cellIdentifierForObject(object: Object) -> String
    
    func configureCell(cell: Cell, object: Object)
}