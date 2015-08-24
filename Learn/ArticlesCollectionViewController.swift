//
//  ArticlesCollectionViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class ArticlesCollectionViewController: UICollectionViewController, ManagedObjectContextSettable, PocketAPISettable, SFSafariViewControllerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var pocketAPI: PocketAPI!
    var dataSource: UICollectionViewDataSource?
    var topic: Topic?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let topic = topic else { fatalError("No topic found") }
        
        navigationItem.title = topic.name
        
        let request = LearnItem.sortedFetchRequest
        request.fetchBatchSize = 20
        request.predicate = NSPredicate(format: "topic = %@", topic)
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = FetchedResultsCollectionDataSource(collectionView: collectionView!, fetchedResultsController: frc, delegate: self)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = dataSource?.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? ArticleCollectionViewCell,
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

extension ArticlesCollectionViewController: FetchedResultsCollectionDataSourceDelegate {
    typealias Cell = ArticleCollectionViewCell
    typealias Object = LearnItem
    
    func cellIdentifierForObject(object: Object) -> String {
        return "ArticleCollectionCell"
    }
    
    func configureCell(cell: Cell, object: Object) {
        cell.learnItem = object
    }
}