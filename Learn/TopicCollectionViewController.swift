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

class TopicCollectionViewController: UICollectionViewController, ManagedObjectContextSettable, PocketAPISettable, TopicCollectionControllable {
    
    var managedObjectContext: NSManagedObjectContext!
    var pocketAPI: PocketAPI!
    var dataSource: UICollectionViewDataSource?
    var indexPathForMenuController: NSIndexPath?
    var notif: NSObjectProtocol?
    var parentTopic: Topic?
    
    let createTopicTransitioningDelegate = SmallModalTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupParentTopic {
            self.setupFetchedResultsController()
        }
        
        setupNavigationItem()
    }
    
    private func setupNavigationItem() {
        if let parentTopic = parentTopic where parentTopic.baseTopic == false {
            navigationItem.titleView = nil
            navigationItem.title = parentTopic.iconAndName
        }
    }
    
    private func setupFetchedResultsController() {
        guard let topic = parentTopic else {
            fatalError("Tried to set up topic collection VC without a parent")
        }
        
        let frc = getFetchedResultsControllerForTopic(topic)
        dataSource = AddableFetchedResultsCollectionDataSource(collectionView: collectionView!, fetchedResultsController: frc, delegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        notif = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] (_) -> Void in
            if let dataSource = self.dataSource as? FetchedResultsCollectionDataSource<TopicCollectionViewController> {
                dataSource.refreshData()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        guard let notif = notif else {
            return
        }
        NSNotificationCenter.defaultCenter().removeObserver(notif)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = dataSource?.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? Cell else {
            return
        }

        if cell.addableCell {
            performSegueWithIdentifier(SegueIdentifier.ShowCreateTopic.rawValue, sender: nil)
        } else {
            guard let parentTopic = parentTopic, topic = cell.topic else {
                fatalError("Missing topic or parent topic when segue-ing on topic view controller")
            }
            
            if parentTopic.baseTopic {
                performSegueWithIdentifier(SegueIdentifier.ShowTopicView.rawValue, sender: topic)
            } else {
                performSegueWithIdentifier(SegueIdentifier.ShowArticles.rawValue, sender: topic)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier, segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(segue.identifier)")
        }
        
        switch segueIdentifier {
        case .ShowCreateTopic:
            guard let vc = segue.destinationViewController as? CreateTopicViewController else {
                fatalError("Unexpected view controller for \(identifier) segue")
            }
            
            if let topic = sender as? Topic {
                vc.topic = topic
            }

            vc.parentTopic = parentTopic
            vc.managedObjectContext = managedObjectContext
            
            vc.transitioningDelegate = createTopicTransitioningDelegate
            vc.modalPresentationStyle = .Custom
        case .ShowArticles:
            guard let vc = segue.destinationViewController as? ArticlesTableViewController else {
                fatalError("Unexpected view controller for \(identifier) segue")
            }
            guard let topic = sender as? Topic else {
                fatalError("Missing topic for \(identifier) segue")
            }
            vc.managedObjectContext = managedObjectContext
            vc.topic = topic
            vc.pocketAPI = pocketAPI
        case .ShowTopicView:
            guard let vc = segue.destinationViewController as? TopicCollectionViewController else {
                fatalError("Unexpected view controller for \(identifier) segue")
            }
            guard let topic = sender as? Topic else {
                fatalError("Missing topic for \(identifier) segue")
            }
            vc.managedObjectContext = managedObjectContext
            vc.parentTopic = topic
            vc.pocketAPI = pocketAPI
        case .ShowPocketImport:
            guard let vc = segue.destinationViewController as? PocketImportController else {
                fatalError("Unexpected view controller for \(identifier) segue")
            }
            
            vc.managedObjectContext = managedObjectContext
            vc.pocketAPI = pocketAPI
            
            vc.transitioningDelegate = createTopicTransitioningDelegate
            vc.modalPresentationStyle = .Custom
        }
    }
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .Began
        else { return }
        guard let indexPath = collectionView?.indexPathForItemAtPoint(sender.locationInView(collectionView)),
            cell = collectionView?.cellForItemAtIndexPath(indexPath) as? Cell else {
                return
        }
        
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
            topic = cell.topic else {
                return
        }
        
        performSegueWithIdentifier(SegueIdentifier.ShowCreateTopic.rawValue, sender: topic)
    }
    
    func deleteTopic(sender: AnyObject?) {
        guard let indexPath = indexPathForMenuController,
            cv = collectionView,
            cell = dataSource?.collectionView(cv, cellForItemAtIndexPath: indexPath) as? Cell,
            topic = cell.topic else {
                return
        }
        managedObjectContext.performChanges {
            self.managedObjectContext.deleteObject(topic)
        }
        indexPathForMenuController = nil
    }
    
    enum SegueIdentifier: String {
        case ShowCreateTopic = "ShowCreateTopic"
        case ShowArticles = "ShowArticles"
        case ShowTopicView = "ShowTopicView"
        case ShowPocketImport = "ShowPocketImport"
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
