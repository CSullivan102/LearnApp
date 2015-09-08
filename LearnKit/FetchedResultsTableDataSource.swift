//
//  FetchedResultsTableDataSource.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/8/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData

public class FetchedResultsTableDataSource<D: FetchedResultsTableDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    private let fetchedResultsController: NSFetchedResultsController
    let tableView: UITableView
    let delegate: D
    
    public required init(tableView: UITableView, fetchedResultsController: NSFetchedResultsController, delegate: D) {
        self.tableView = tableView
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        
        super.init()
        
        fetchedResultsController.delegate = self
        tableView.dataSource = self
        try! fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    public func refreshData() {
        try! fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            guard let unwrappedIndexPath = indexPath
            else { return }
            tableView.deleteRowsAtIndexPaths([unwrappedIndexPath], withRowAnimation: .Right)
        case .Insert:
            guard let unwrappedIndexPath = indexPath
            else { return }
            tableView.insertRowsAtIndexPaths([unwrappedIndexPath], withRowAnimation: .Right)
        case .Update:
            guard let unwrappedIndexPath = indexPath,
                cell = tableView.cellForRowAtIndexPath(unwrappedIndexPath) as? D.Cell,
                object = anObject as? D.Object
            else { return }
            delegate.configureCell(cell, object: object)
        case .Move:
            guard let unwrappedOldIndexPath = indexPath,
                unwrappedNewIndexPath = newIndexPath
            else { return }
            tableView.deleteRowsAtIndexPaths([unwrappedOldIndexPath], withRowAnimation: .Right)
            tableView.insertRowsAtIndexPaths([unwrappedNewIndexPath], withRowAnimation: .Right)
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = fetchedResultsController.sections?[section]
        else { return 0 }
        return sec.numberOfObjects
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let obj = objectAtIndexPath(indexPath)
        let identifier = delegate.cellIdentifierForObject(obj)
        guard let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? D.Cell
        else { fatalError("Unexpected cell type at \(indexPath)") }
        
        delegate.configureCell(cell, object: obj)
        
        return cell
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> D.Object {
        guard let obj = fetchedResultsController.objectAtIndexPath(indexPath) as? D.Object
        else { fatalError("Unexpected cell type at \(indexPath)") }
        return obj
    }
}

public protocol FetchedResultsTableDataSourceDelegate {
    typealias Object: ManagedObject
    typealias Cell: UITableViewCell
    
    func cellIdentifierForObject(object: Object) -> String
    func configureCell(cell: Cell, object: Object)
}