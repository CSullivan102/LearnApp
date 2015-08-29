//
//  AddableFetchedResultsCollectionDataSource.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/27/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class AddableFetchedResultsCollectionDataSource<D: AddableFetchedResultsCollectionDataSourceDelegate>: FetchedResultsCollectionDataSource<D> {
    
    required public init(collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController, delegate: D) {
        super.init(collectionView: collectionView, fetchedResultsController: fetchedResultsController, delegate: delegate)
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let num = super.collectionView(collectionView, numberOfItemsInSection: section)
        return num + 1
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if addableCellAtIndexPath(indexPath) {
            // Addable row
            let identifier = delegate.cellIdentifierForAddable()
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? D.AddableCell
                else { fatalError("Unexpected cell type at \(indexPath)") }
            delegate.configureAddableCell(cell)
            return cell
        } else {
            return super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        }
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath) -> D.Object {
        if addableCellAtIndexPath(indexPath) {
            return D.Object()
        } else {
            return super.objectAtIndexPath(indexPath)
        }
    }
    
    private func addableCellAtIndexPath(indexPath: NSIndexPath) -> Bool {
        if indexPath.row == self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1 {
            return true
        }
        return false
    }
}

public protocol AddableFetchedResultsCollectionDataSourceDelegate : FetchedResultsCollectionDataSourceDelegate {
    typealias AddableCell: UICollectionViewCell
    
    func cellIdentifierForAddable() -> String
    func configureAddableCell(cell: AddableCell)
}
