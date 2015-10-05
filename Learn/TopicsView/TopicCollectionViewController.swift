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
    var parentTopic: Topic?
    
    let createTopicTransitioningDelegate = SmallModalTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupParentTopic {
            self.setupFetchedResultsController()
            if let baseParentTopic = self.parentTopic where baseParentTopic.baseTopic {
                HomescreenShortcutGenerator.generateShortcutsFromBaseTopic(baseParentTopic, andManagedObjectContext: self.managedObjectContext)
            }
        }
        
        if traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: collectionView!)
        } else { print("3D Touch is not available on this device.") }
        
        setupNavigationItem()
    }
    
    private func setupNavigationItem() {
        if case .SubTopic = topicViewState {
            navigationItem.titleView = nil
            navigationItem.title = parentTopic?.iconAndName
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDataSource:", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func refreshDataSource(notification: NSNotification) {
        if let dataSource = dataSource as? FetchedResultsCollectionDataSource<TopicCollectionViewController> {
            dataSource.refreshData()
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = dataSource?.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? Cell else {
            return
        }

        if cell.addableCell {
            performSegueWithIdentifier(SegueIdentifier.ShowCreateTopic.rawValue, sender: nil)
        } else {
            guard let topic = cell.topic else {
                fatalError("Missing topic when segue-ing on topic view controller")
            }
            
            switch topicViewState {
            case .BaseTopic:
                performSegueWithIdentifier(SegueIdentifier.ShowTopicView.rawValue, sender: topic)
            case .SubTopic:
                performSegueWithIdentifier(SegueIdentifier.ShowArticles.rawValue, sender: topic)
            }
        }
    }
    
    // MARK: Handle long press for edit/delete menu
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .Began else {
            return
        }
        guard let indexPath = collectionView?.indexPathForItemAtPoint(sender.locationInView(collectionView)),
            cell = collectionView?.cellForItemAtIndexPath(indexPath) as? Cell where !cell.addableCell else {
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
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier, segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(segue.identifier)")
        }
        
        switch segueIdentifier {
        case .ShowCreateTopic:
            guard let vc = segue.destinationViewController as? CreateTopicViewController else {
                fatalError("Unexpected view controller for \(identifier) segue")
            }

            vc.topic = sender as? Topic
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
            
            vc.topic = topic
            vc.managedObjectContext = managedObjectContext
            vc.pocketAPI = pocketAPI
        case .ShowTopicView:
            guard let vc = segue.destinationViewController as? TopicCollectionViewController else {
                fatalError("Unexpected view controller for \(identifier) segue")
            }
            guard let topic = sender as? Topic else {
                fatalError("Missing topic for \(identifier) segue")
            }
            
            vc.parentTopic = topic
            vc.managedObjectContext = managedObjectContext
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
    
    enum SegueIdentifier: String {
        case ShowCreateTopic = "ShowCreateTopic"
        case ShowArticles = "ShowArticles"
        case ShowTopicView = "ShowTopicView"
        case ShowPocketImport = "ShowPocketImport"
    }
}

extension TopicCollectionViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItemAtPoint(location),
            cell = collectionView?.cellForItemAtIndexPath(indexPath) as? Cell,
            topic = cell.topic else { return nil }

        previewingContext.sourceRect = cell.backgroundView?.frame ?? cell.frame
        
        switch topicViewState {
        case .BaseTopic:
            guard let vc = storyboard?.instantiateViewControllerWithIdentifier("TopicViewController") as? TopicCollectionViewController else {
                return nil
            }
            vc.parentTopic = topic
            vc.managedObjectContext = managedObjectContext
            vc.pocketAPI = pocketAPI
            vc.preferredContentSize = CGSize(width: 0.0, height: 200.0)
            return vc
        case .SubTopic:
            guard let vc = storyboard?.instantiateViewControllerWithIdentifier("ArticleViewController") as? ArticlesTableViewController else {
                return nil
            }
            vc.topic = topic
            vc.managedObjectContext = managedObjectContext
            vc.pocketAPI = pocketAPI
            vc.preferredContentSize = CGSize(width: 0.0, height: 400.0)
            return vc
        }
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
