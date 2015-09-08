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
    func getExtensionContextInfo(completion: (NSURL?, String?) -> Void)
}

class ChooseTopicViewController: UIViewController, UICollectionViewDelegate, ManagedObjectContextSettable, UIViewControllerHeightRequestable, TopicCollectionControllable {
    var managedObjectContext: NSManagedObjectContext!
    var currentDataSource: UICollectionViewDataSource?
    var parentTopic: Topic?
    var delegate: ChooseTopicDelegate?
    var shareURL: NSURL?
    var itemTitle: String?
    var selectedTopic: Topic?
    var selectedSubtopic: Topic?
    var topicPickingState: TopicPickingState = .None
    
    let createTopicTransitioningDelegate = SmallModalTransitioningDelegate()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chooseTopicButton: UIButton!
    @IBOutlet weak var chooseSubTopicButton: UIButton!
    @IBOutlet weak var topicStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate?.getExtensionContextInfo() {
            url, itemTitle in
            self.shareURL = url
            self.itemTitle = itemTitle
            self.titleTextField.text = itemTitle
        }
        
        setupParentTopic {
            self.setupInitialFetchedResultsController()
        }
        
        collectionView.delegate = self
    }
    
    @IBAction func chooseTopicButtonPressed(sender: UIButton) {
        selectedTopic = nil
        selectedSubtopic = nil
        topicPickingState = .Topic
        setupInitialFetchedResultsController()
        animateViewStateChange()
    }
    
    @IBAction func chooseSubtopicButtonPressed(sender: UIButton) {
        selectedSubtopic = nil
        topicPickingState = .Subtopic
        animateViewStateChange()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? Cell
        else { return }
        
        if cell.addableCell {
            performSegueWithIdentifier(SegueIdentifier.ShowCreateTopic.rawValue, sender: nil)
        } else {
            guard let topic = cell.topic
            else { return }

            switch topicPickingState {
            case .Topic:
                didPickTopic(topic)
            case .Subtopic:
                didPickSubtopic(topic)
            case .None:
                return
            }
        }
    }
    
    private func didPickTopic(topic: Topic) {
        selectedTopic = topic
        topicPickingState = .Subtopic
        setupSubtopicDataSourceForTopic(topic)
        
        animateViewStateChange()
    }
    
    private func didPickSubtopic(subtopic: Topic) {
        selectedSubtopic = subtopic
        topicPickingState = .None
        
        animateViewStateChange()
    }
    
    private func setupInitialFetchedResultsController() {
        guard let topic = self.parentTopic
        else { fatalError("Tried to set up choose topic controller without parent") }
        
        let frc = getFetchedResultsControllerForTopic(topic)
        currentDataSource = AddableFetchedResultsCollectionDataSource(collectionView: collectionView, fetchedResultsController: frc, delegate: self)
        collectionView.dataSource = currentDataSource
        collectionView.reloadData()
    }
    
    private func setupSubtopicDataSourceForTopic(topic: Topic) {
        let frc = getFetchedResultsControllerForTopic(topic)
        currentDataSource = AddableFetchedResultsCollectionDataSource(collectionView: collectionView, fetchedResultsController: frc, delegate: self)
        collectionView.dataSource = currentDataSource
        collectionView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier,
            segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Invalid segue identifier \(segue.identifier)") }
        
        switch segueIdentifier {
        case .ShowCreateTopic:
            guard let vc = segue.destinationViewController as? CreateTopicViewController
                else { fatalError("Unexpected view controller for \(identifier) segue") }
            
            switch topicPickingState {
            case .Subtopic:
                vc.parentTopic = selectedTopic
            default:
                vc.parentTopic = parentTopic
            }
            
            vc.managedObjectContext = managedObjectContext
            vc.transitioningDelegate = createTopicTransitioningDelegate
            vc.modalPresentationStyle = .Custom
            vc.createTopicDelegate = self
        }
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        guard let managedObjectContext = managedObjectContext
            else { fatalError("Tried to post article without MOC") }
        
        guard let topic = selectedSubtopic, title = titleTextField.text where title.characters.count > 0
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
    
    private func animateViewStateChange() {
        updateButtonTitlesForCurrentState()
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                self.updateModalLayoutForCurrentState()
                self.view.layoutIfNeeded()
                // Set the superview to need layout so that PresentationControllers can adjust
                self.view.superview?.setNeedsLayout()
                self.view.superview?.layoutIfNeeded()
            }, completion: { _ in
                
        })
    }
    
    private func updateButtonTitlesForCurrentState() {
        var topicButtonTitle: String
        var subtopicButtonTitle: String
        if let topic = selectedTopic {
            topicButtonTitle = topic.iconAndName
        } else {
            topicButtonTitle = "Choose Topic"
        }
        
        if let subtopic = selectedSubtopic {
            subtopicButtonTitle = subtopic.iconAndName
        } else {
            subtopicButtonTitle = "Choose Subtopic"
        }
        
        chooseTopicButton.setTitle(topicButtonTitle, forState: .Normal)
        chooseSubTopicButton.setTitle(subtopicButtonTitle, forState: .Normal)
    }
    
    private func updateModalLayoutForCurrentState() {
        var subtopicButtonHidden: Bool
        var collectionViewHidden: Bool
        
        subtopicButtonHidden = (selectedTopic == nil)
        
        switch topicPickingState {
        case .Subtopic, .Topic:
            collectionViewHidden = false
        case .None:
            collectionViewHidden = true
        }
        
        chooseSubTopicButton.hidden = subtopicButtonHidden
        collectionView.hidden = collectionViewHidden
    }
    
    func preferredHeight() -> CGFloat {
        let baseHeight = topicStackView.frame.origin.y
        let margin: CGFloat = 16
        return baseHeight + topicStackView.frame.height + margin
    }
    
    enum SegueIdentifier: String {
        case ShowCreateTopic = "ShowCreateTopic"
    }
    
    enum TopicPickingState {
        case None
        case Topic
        case Subtopic
    }
}

extension ChooseTopicViewController: CreateTopicDelegate {
    func didCreateTopic(topic: Topic) {
        switch topicPickingState {
        case .Topic:
            didPickTopic(topic)
        case .Subtopic:
            didPickSubtopic(topic)
        case .None:
            return
        }
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