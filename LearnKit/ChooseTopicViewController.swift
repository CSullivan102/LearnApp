//
//  ChooseTopicViewController.swift
//  Learn
//
//  Created by Christopher Sullivan on 9/11/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import CoreData

public protocol ChooseTopicDelegate {
    func didChooseTopic(topic: Topic)
}

public class ChooseTopicViewController: UIViewController, UICollectionViewDelegate, ManagedObjectContextSettable, TopicCollectionControllable {
    public var managedObjectContext: NSManagedObjectContext!
    public var parentTopic: Topic?
    public var chooseTopicDelegate: ChooseTopicDelegate?
    
    private var selectedTopic: Topic?
    private var selectedSubtopic: Topic?
    private var currentDataSource: UICollectionViewDataSource?
    private var topicPickingState: TopicPickingState = .None
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chooseTopicButton: UIButton!
    @IBOutlet weak var chooseSubTopicButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupParentTopic {
            self.setupInitialFetchedResultsController()
        }
        
        collectionView.delegate = self

        preferredContentSize = stackView.bounds.size
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
    
    @IBAction func chooseTopicButtonPressed(sender: UIButton) {
        selectedTopic = nil
        selectedSubtopic = nil
        let prevTopicPickingState = topicPickingState
        topicPickingState = .Topic
        if prevTopicPickingState != topicPickingState {
            setupInitialFetchedResultsController()
            animateViewStateChange()
        }
    }
    
    @IBAction func chooseSubtopicButtonPressed(sender: UIButton) {
        selectedSubtopic = nil
        let prevTopicPickingState = topicPickingState
        topicPickingState = .Subtopic
        if prevTopicPickingState != topicPickingState {
            animateViewStateChange()
        }
    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
            vc.modalPresentationStyle = .Custom
            vc.createTopicDelegate = self
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
    
    private func animateViewStateChange() {
        updateButtonTitlesForCurrentState()
        updateModalLayoutForCurrentState()
        preferredContentSize = stackView.bounds.size
    }
    
    private func updateButtonTitlesForCurrentState() {
        var topicButtonTitle: String
        var subTopicButtonTitle: String
        if let topic = selectedTopic {
            topicButtonTitle = topic.iconAndName
        } else {
            topicButtonTitle = "Choose Topic"
        }
        
        if let subTopic = selectedSubtopic {
            subTopicButtonTitle = subTopic.iconAndName
        } else {
            subTopicButtonTitle = "Choose Subtopic"
        }
        
        chooseTopicButton.setTitle(topicButtonTitle, forState: .Normal)
        chooseSubTopicButton.setTitle(subTopicButtonTitle, forState: .Normal)
    }
    
    private func updateModalLayoutForCurrentState() {
        var subTopicButtonHidden: Bool
        var collectionViewHidden: Bool
        
        subTopicButtonHidden = (selectedTopic == nil)
        
        switch topicPickingState {
        case .Subtopic, .Topic:
            collectionViewHidden = false
        case .None:
            collectionViewHidden = true
        }
        
        chooseSubTopicButton.hidden = subTopicButtonHidden
        collectionView.hidden = collectionViewHidden
    }
    
    private enum SegueIdentifier: String {
        case ShowCreateTopic = "ShowCreateTopic"
    }
    
    private enum TopicPickingState {
        case None
        case Topic
        case Subtopic
    }
}

extension ChooseTopicViewController: CreateTopicDelegate {
    public func didCreateTopic(topic: Topic) {
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

extension ChooseTopicViewController: AddableFetchedResultsCollectionDataSourceDelegate {
    public typealias Cell = TopicCollectionViewCell
    public typealias Object = Topic
    public typealias AddableCell = TopicCollectionViewCell
    
    public func cellIdentifierForObject(object: Object) -> String {
        return "TopicShareCell"
    }
    
    public func cellIdentifierForAddable() -> String {
        return "TopicShareCell"
    }
    
    public func configureCell(cell: Cell, object: Object) {
        cell.topic = object
        cell.addableCell = false
    }
    
    public func configureAddableCell(cell: AddableCell) {
        cell.addableCell = true
    }
}