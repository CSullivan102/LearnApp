//
//  ShareViewController.swift
//  Share
//
//  Created by Christopher Sullivan on 8/23/15.
//  Copyright © 2015 Christopher Sullivan. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import LearnKit
import CoreData

class ShareViewController: UIViewController, UICollectionViewDelegate, PocketAuthenticationDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var dataSource: UICollectionViewDataSource?
    var shareURL: NSURL?
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
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chooseTopicButton: UIButton!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareModalView: UIView!
    @IBOutlet weak var backdropView: UIView!
    
    override func viewDidLoad() {
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
            attachment = item.attachments?.first as? NSItemProvider
            else { return }
        
        collectionViewHeightConstraint.constant = 0.0
        
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            attachment.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (urlProvider, error) -> Void in
                if let url = urlProvider as? NSURL {
                    self.shareURL = url
                    if let titleTextField = self.titleTextField {
                        titleTextField.text = item.attributedContentText?.string
                    }
                }
            })
        }
        
        managedObjectContext = createMainContext()
        
        let request = Topic.sortedFetchRequest
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = FetchedResultsCollectionDataSource(collectionView: collectionView, fetchedResultsController: frc, delegate: self)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    @IBAction func chooseTopicButtonPressed(sender: UIButton) {
        setCollectionViewHeight(175.0)
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
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = dataSource?.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? TopicShareCollectionViewCell,
            topic = cell.topic
        else { return }
        
        selectedTopic = topic
        setCollectionViewHeight(0)
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
        
        hideShareExtension()
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        hideShareExtension()
    }
    
    private func hideShareExtension() {
        let snapshot = shareModalView.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = shareModalView.convertRect(shareModalView.bounds, toView: view)
        view.addSubview(snapshot)
        shareModalView.removeFromSuperview()
        UIView.animateWithDuration(0.4,
                            delay: 0.0,
           usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
                          options: UIViewAnimationOptions.CurveEaseOut,
                       animations: { () -> Void in
            let currentFrame = snapshot.frame
            snapshot.frame = CGRect(x: currentFrame.midX, y: currentFrame.midY, width: 0, height: 0)
            self.backdropView.alpha = 0.0
        }) { (_) -> Void in
            self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
        }
    }
    
    func promptOAuthUserAuthWithURL(URL: NSURL) {
        return
    }
}

extension ShareViewController: FetchedResultsCollectionDataSourceDelegate {
    typealias Cell = TopicShareCollectionViewCell
    typealias Object = Topic
    
    func cellIdentifierForObject(object: Object) -> String {
        return "TopicShareCell"
    }
    
    func configureCell(cell: Cell, object: Object) {
        cell.topic = object
    }
}
