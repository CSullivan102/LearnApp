//
//  ChooseTopicViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 8/31/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import LearnKit
import CoreData

protocol ChooseTopicDelegate {
    func dismissChooseTopicController()
}

class ChooseTopicViewController: UIViewController, UICollectionViewDelegate, ManagedObjectContextSettable, UIViewControllerHeightRequestable {
    var managedObjectContext: NSManagedObjectContext!
    var dataSource: UICollectionViewDataSource?
    var delegate: ChooseTopicDelegate?
    var shareURL: NSURL?
    var itemTitle: String?
    var selectedTopic: Topic? {
        didSet {
            guard let chooseTopicButton = chooseTopicButton else {
                return
            }
            
            guard let topic = selectedTopic else {
                chooseTopicButton.setTitle("Choose Topic", forState: .Normal)
                return
            }
            
            chooseTopicButton.setTitle(topic.iconAndName, forState: .Normal)
        }
    }
    
    let createTopicTransitioningDelegate = CreateTopicSlidingTransitioningDelegate()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chooseTopicButton: UIButton!
    @IBOutlet weak var chooseTopicContainerView: UIView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.text = itemTitle
        
        collectionView.delegate = self
        
        collectionViewHeightConstraint.constant = 0.0
        
        let request = Topic.sortedFetchRequest
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = AddableFetchedResultsCollectionDataSource(collectionView: collectionView, fetchedResultsController: frc, delegate: self)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    @IBAction func chooseTopicButtonPressed(sender: UIButton) {
        setCollectionViewHeight(125.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = dataSource?.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? Cell
        else { return }
        
        if cell.addableCell {
            performSegueWithIdentifier(SegueIdentifier.ShowCreateTopic.rawValue, sender: nil)
        } else {
            guard let topic = cell.topic
            else { return }
            selectedTopic = topic
            setCollectionViewHeight(0)
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
            
            vc.managedObjectContext = managedObjectContext
            vc.transitioningDelegate = createTopicTransitioningDelegate
            vc.modalPresentationStyle = .Custom
        }
    }
    
    private func setCollectionViewHeight(height: CGFloat) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                self.collectionViewHeightConstraint.constant = height
                self.presentationController?.containerViewWillLayoutSubviews()
                self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        guard let managedObjectContext = managedObjectContext
            else { fatalError("Tried to post article without MOC") }
        
        guard let topic = selectedTopic, title = titleTextField.text where title.characters.count > 0
            else { return }
        
        if let shareURL = shareURL {
            let pocketAPI = PocketAPI(delegate: self)
            pocketAPI.addURLToPocket(shareURL) { pocketItem in
                print("Saved URL to Pocket!")
            }
        }
        
        managedObjectContext.performChanges {
            let learnItem: LearnItem = managedObjectContext.insertObject()
            learnItem.title = title
            learnItem.url = self.shareURL
            learnItem.itemType = .Article
            learnItem.read = false
            learnItem.dateAdded = NSDate()
            learnItem.topic = topic
        }
        delegate?.dismissChooseTopicController()
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        delegate?.dismissChooseTopicController()
    }
    
    func preferredHeight() -> CGFloat {
        let baseHeight: CGFloat = 150.0
        if collectionViewHeightConstraint != nil {
            return baseHeight + collectionViewHeightConstraint.constant
        }
        return baseHeight
    }
    
    enum SegueIdentifier: String {
        case ShowCreateTopic = "ShowCreateTopic"
    }
}

extension ChooseTopicViewController: SlidingTransitionViewController {
    func slidingViewForTransition() -> UIView {
        return chooseTopicContainerView
    }
}

extension ChooseTopicViewController: PocketAuthenticationDelegate {
    func promptOAuthUserAuthWithURL(URL: NSURL) {
        return
    }
}

extension ChooseTopicViewController: AddableFetchedResultsCollectionDataSourceDelegate {
    typealias Cell = TopicCollectionViewCell
    typealias Object = Topic
    typealias AddableCell = TopicCollectionViewCell
    
    func cellIdentifierForObject(object: Object) -> String {
        return "TopicShareCell"
    }
    
    func cellIdentifierForAddable() -> String {
        return "TopicShareCell"
    }
    
    func configureCell(cell: Cell, object: Object) {
        cell.topic = object
        cell.addableCell = false
    }
    
    func configureAddableCell(cell: AddableCell) {
        cell.addableCell = true
    }
}