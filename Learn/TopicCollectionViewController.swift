//
//  TopicCollectionViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/20/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData
import LearnKit

class TopicCollectionViewController: UICollectionViewController, ManagedObjectContextSettable, PocketAPISettable {
    
    var managedObjectContext: NSManagedObjectContext!
    var pocketAPI: PocketAPI!
    var dataSource: UICollectionViewDataSource?
    var indexPathForMenuController: NSIndexPath?
    
    let createTopicTransitioningDelegate = CreateTopicTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = Topic.sortedFetchRequest
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = AddableFetchedResultsCollectionDataSource(collectionView: collectionView!, fetchedResultsController: frc, delegate: self)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = dataSource?.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? Cell
        else { return }

        if cell.addableCell {
            performSegueWithIdentifier(SegueIdentifier.ShowCreateTopic.rawValue, sender: nil)
        } else {
            guard let topic = cell.topic
            else { return }
            performSegueWithIdentifier(SegueIdentifier.ShowArticles.rawValue, sender: topic)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier,
            segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Invalid segue identifier \(segue.identifier)") }
        
        switch segueIdentifier {
        case .ShowCreateTopic:
            guard let vc = segue.destinationViewController as? CreateTopicViewController
            else { fatalError("Unexpected view controller for \(identifier) segue") }
            
            if let topic = sender as? Topic {
                vc.topic = topic
            }

            vc.managedObjectContext = managedObjectContext
            
            vc.transitioningDelegate = createTopicTransitioningDelegate
            vc.modalPresentationStyle = .Custom
        case .ShowArticles:
            guard let vc = segue.destinationViewController as? ArticlesCollectionViewController
            else { fatalError("Unexpected view controller for \(identifier) segue") }
            guard let topic = sender as? Topic else { fatalError("Missing topic for \(identifier) segue") }
            vc.managedObjectContext = managedObjectContext
            vc.topic = topic
            vc.pocketAPI = pocketAPI
        }
    }
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .Began
        else { return }
        guard let indexPath = collectionView?.indexPathForItemAtPoint(sender.locationInView(collectionView)),
            cell = collectionView?.cellForItemAtIndexPath(indexPath) as? Cell
        else { return }
        
        if cell.addableCell {
            return
        }
        
        indexPathForMenuController = indexPath
        
        let editMenuItem = UIMenuItem(title: "Edit", action: "editTopic:")
        let deleteMenuItem = UIMenuItem(title: "Delete", action: "deleteTopic:")
        
        let mc = UIMenuController.sharedMenuController()
        mc.menuItems = [editMenuItem, deleteMenuItem]
        mc.setTargetRect(cell.bounds, inView: cell)
        mc.setMenuVisible(true, animated: false)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "deleteTopic:" || action == "editTopic:" {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func editTopic(sender: AnyObject?) {
        guard let indexPath = indexPathForMenuController,
            cv = collectionView,
            cell = dataSource?.collectionView(cv, cellForItemAtIndexPath: indexPath) as? Cell,
            topic = cell.topic else { return }
        
        performSegueWithIdentifier(SegueIdentifier.ShowCreateTopic.rawValue, sender: topic)
    }
    
    func deleteTopic(sender: AnyObject?) {
        guard let indexPath = indexPathForMenuController,
            cv = collectionView,
            cell = dataSource?.collectionView(cv, cellForItemAtIndexPath: indexPath) as? Cell,
            topic = cell.topic else { return }
        managedObjectContext.performChanges {
            self.managedObjectContext.deleteObject(topic)
        }
        indexPathForMenuController = nil
    }
    
    enum SegueIdentifier: String {
        case ShowCreateTopic = "ShowCreateTopic"
        case ShowArticles = "ShowArticles"
    }
}

extension TopicCollectionViewController: AddableFetchedResultsCollectionDataSourceDelegate {
    typealias Cell = LabeledTopicCollectionViewCell
    typealias Object = Topic
    typealias AddableCell = LabeledTopicCollectionViewCell

    func cellIdentifierForObject(object: Object) -> String {
        return "TopicCollectionCell"
    }
    
    func cellIdentifierForAddable() -> String {
        return "TopicCollectionCell"
    }
    
    func configureCell(cell: Cell, object: Object) {
        cell.topic = object
    }
    
    func configureAddableCell(cell: AddableCell) {
        cell.addableCell = true
    }
}
