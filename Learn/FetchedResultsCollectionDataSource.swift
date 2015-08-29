//
//  FetchedResultsCollectionDataSource.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class FetchedResultsCollectionDataSource<D: FetchedResultsCollectionDataSourceDelegate>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    private let fetchedResultsController: NSFetchedResultsController
    let collectionView: UICollectionView
    let delegate: D
    
    public required init(collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController, delegate: D) {
        self.collectionView = collectionView
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        
        super.init()
        
        fetchedResultsController.delegate = self
        collectionView.dataSource = self
        try! fetchedResultsController.performFetch()
        collectionView.reloadData()
    }
    
    //MARK: NSFetchedResultsControllerDelegate
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            guard let unwrappedIndexPath = indexPath
            else { break }
            collectionView.deleteItemsAtIndexPaths([unwrappedIndexPath])
        case .Insert:
            guard let unwrappedIndexPath = newIndexPath
            else { break }
            collectionView.insertItemsAtIndexPaths([unwrappedIndexPath])
        case .Update:
            guard let unwrappedIndexPath = indexPath,
                cell = collectionView.cellForItemAtIndexPath(unwrappedIndexPath) as? D.Cell,
                object = anObject as? D.Object
            else { break }
             delegate.configureCell(cell, object: object)
        case .Move:
            guard let unwrappedOldIndexPath = indexPath,
                unwrappedNewIndexPath = newIndexPath
                else { break }
            collectionView.deleteItemsAtIndexPaths([unwrappedOldIndexPath])
            collectionView.insertItemsAtIndexPaths([unwrappedNewIndexPath])
        }
    }
    
    //MARK: UICollectionViewDataSource
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sec = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sec.numberOfObjects
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let obj = objectAtIndexPath(indexPath)
        let identifier = delegate.cellIdentifierForObject(obj)
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? D.Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        delegate.configureCell(cell, object: obj)
        return cell
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> D.Object {
        guard let obj = fetchedResultsController.objectAtIndexPath(indexPath) as? D.Object else {
            fatalError("Couldn't find object at index path in FetchedResultsDataSource")
        }
        return obj
    }
}

public protocol FetchedResultsCollectionDataSourceDelegate {
    typealias Object: ManagedObject
    typealias Cell: UICollectionViewCell
    
    func cellIdentifierForObject(object: Object) -> String
    func configureCell(cell: Cell, object: Object)
}