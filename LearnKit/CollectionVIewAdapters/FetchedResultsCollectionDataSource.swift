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
    
    private var dataProviderUpdates: [DataProviderUpdate<D.Object>]!
    
    public required init(collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController, delegate: D) {
        dataProviderUpdates = []
        self.collectionView = collectionView
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        
        super.init()
        
        fetchedResultsController.delegate = self
        collectionView.dataSource = self
        try! fetchedResultsController.performFetch()
        collectionView.reloadData()
    }
    
    public func refreshData() {
        try! fetchedResultsController.performFetch()
        collectionView.reloadData()
    }
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        dataProviderUpdates.removeAll()
    }

    //MARK: NSFetchedResultsControllerDelegate
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let update: DataProviderUpdate<D.Object>
        switch type {
        case .Insert:
            guard let unwrappedIndexPath = newIndexPath else {
                return
            }
            update = DataProviderUpdate.Insert(unwrappedIndexPath)
        case .Delete:
            guard let unwrappedIndexPath = indexPath else {
                return
            }
            update = DataProviderUpdate.Delete(unwrappedIndexPath)
        case .Update:
            guard let unwrappedIndexPath = indexPath, object = anObject as? D.Object else {
                return
            }
            update = DataProviderUpdate.Update(unwrappedIndexPath, object)
        case .Move:
            guard let unwrappedOldIndexPath = indexPath, unwrappedNewIndexPath = newIndexPath else {
                return
            }
            update = DataProviderUpdate.Move(unwrappedOldIndexPath, unwrappedNewIndexPath)
        }
        
        dataProviderUpdates.append(update)
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({ () -> Void in
            for update in self.dataProviderUpdates {
                switch update {
                case .Insert(let indexPath): self.collectionView.insertItemsAtIndexPaths([indexPath])
                case .Delete(let indexPath): self.collectionView.deleteItemsAtIndexPaths([indexPath])
                case .Update(let indexPath, let object):
                    guard let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? D.Cell else {
                            return
                    }
                    self.delegate.configureCell(cell, object: object)
                case .Move(let oldIndexPath, let newIndexPath):
                    self.collectionView.deleteItemsAtIndexPaths([oldIndexPath])
                    self.collectionView.insertItemsAtIndexPaths([newIndexPath])
                }
            }
        }) { (_) -> Void in
                self.dataProviderUpdates.removeAll()
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

private enum DataProviderUpdate<T> {
    case Insert(NSIndexPath)
    case Update(NSIndexPath, T)
    case Move(NSIndexPath, NSIndexPath)
    case Delete(NSIndexPath)
}

public protocol FetchedResultsCollectionDataSourceDelegate {
    typealias Object: ManagedObject
    typealias Cell: UICollectionViewCell
    
    func cellIdentifierForObject(object: Object) -> String
    func configureCell(cell: Cell, object: Object)
}