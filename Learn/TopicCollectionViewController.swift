//
//  TopicCollectionViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData


class TopicCollectionViewController: UICollectionViewController, ManagedObjectContextSettable, PocketAPISettable {
    
    var managedObjectContext: NSManagedObjectContext!
    var pocketAPI: PocketAPI!
    var dataSource: UICollectionViewDataSource?
    var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = Topic.sortedFetchRequest
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = FetchedResultsCollectionDataSource(collectionView: collectionView!, fetchedResultsController: frc, delegate: self)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = dataSource?.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? TopicCollectionViewCell,
            topic = cell.topic else { return }
        if let topics = topic.childTopics where topics.count > 0 {
            // Sub topics exists
        } else {
            performSegueWithIdentifier(SegueIdentifier.ShowArticles.rawValue, sender: topic)
        }
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
        case .ShowArticles:
            guard let vc = segue.destinationViewController as? ArticlesCollectionViewController
            else { fatalError("Unexpected view controller for \(identifier) segue") }
            guard let topic = sender as? Topic else { fatalError("Missing topic for \(identifier) segue") }
            vc.managedObjectContext = managedObjectContext
            vc.topic = topic
            vc.pocketAPI = pocketAPI
        }
    }
    
    enum SegueIdentifier: String {
        case ShowCreateTopic = "ShowCreateTopic"
        case ShowArticles = "ShowArticles"
    }
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .Began else { return }
        guard let indexPath = collectionView?.indexPathForItemAtPoint(sender.locationInView(collectionView)),
            cell = collectionView?.cellForItemAtIndexPath(indexPath)
        else { return }
        
        selectedIndexPath = indexPath
        
        let menuItem = UIMenuItem(title: "Delete", action: "deleteTopic:")
        
        let mc = UIMenuController.sharedMenuController()
        mc.menuItems = [menuItem]
        mc.setTargetRect(cell.bounds, inView: cell)
        mc.setMenuVisible(true, animated: false)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "deleteTopic:" {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func deleteTopic(sender: AnyObject?) {
        guard let indexPath = selectedIndexPath,
            cv = collectionView,
            cell = dataSource?.collectionView(cv, cellForItemAtIndexPath: indexPath) as? TopicCollectionViewCell,
            topic = cell.topic else { return }
        managedObjectContext.performChanges {
            self.managedObjectContext.deleteObject(topic)
        }
        selectedIndexPath = nil
    }
}

extension TopicCollectionViewController: FetchedResultsCollectionDataSourceDelegate {
    typealias Cell = TopicCollectionViewCell
    typealias Object = Topic

    func cellIdentifierForObject(object: Object) -> String {
        return "TopicCollectionCell"
    }
    
    func configureCell(cell: Cell, object: Object) {
        cell.topic = object
    }
}
